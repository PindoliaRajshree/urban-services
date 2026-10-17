// File: lib/core/location/region_data.dart
// Purpose: Country / state / city lists for address pickers, read from the
// data bundled with the country_state_city package. The JSON is decoded
// and filtered on a background isolate (city.json alone is ~25MB) and
// cached per lookup.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

/// A country or state: its display name and ISO code.
class Region {
  const Region(this.name, this.isoCode);

  final String name;
  final String isoCode;
}

const _assets = 'packages/country_state_city/lib/assets';

final Map<String, Future<List<Region>>> _regionCache = {};
final Map<String, Future<List<String>>> _cityCache = {};

/// All countries, by name.
Future<List<Region>> loadCountries() => _regionCache.putIfAbsent(
  'countries',
  () async => compute(
    _parseCountries,
    await rootBundle.loadString('$_assets/country.json', cache: false),
  ),
);

/// States of the country with ISO code [countryCode], by name.
Future<List<Region>> loadStates(String countryCode) =>
    _regionCache.putIfAbsent('states:$countryCode', () async {
      final json = await rootBundle.loadString(
        '$_assets/state.json',
        cache: false,
      );
      return compute(_parseStates, (json, countryCode));
    });

/// City names of one state, alphabetical.
Future<List<String>> loadCities(String countryCode, String stateCode) =>
    _cityCache.putIfAbsent('$countryCode:$stateCode', () async {
      final json = await rootBundle.loadString(
        '$_assets/city.json',
        cache: false,
      );
      return compute(_parseCities, (json, countryCode, stateCode));
    });

// --- Isolate entry points (top-level so `compute` can send them) ---

List<Region> _parseCountries(String json) =>
    _regions(_decodeList(json), (_) => true);

List<Region> _parseStates((String, String) args) {
  final (json, countryCode) = args;
  return _regions(_decodeList(json), (e) => e['countryCode'] == countryCode);
}

List<String> _parseCities((String, String, String) args) {
  final (json, countryCode, stateCode) = args;
  final names = {
    for (final e in _decodeList(json))
      if (e['countryCode'] == countryCode && e['stateCode'] == stateCode)
        e['name'] as String,
  }.toList()..sort();
  return names;
}

List<Region> _regions(
  List<Map<String, dynamic>> data,
  bool Function(Map<String, dynamic>) where,
) => [
  for (final e in data)
    if (where(e)) Region(e['name'] as String, e['isoCode'] as String),
]..sort((a, b) => a.name.compareTo(b.name));

List<Map<String, dynamic>> _decodeList(String json) =>
    (jsonDecode(json) as List).cast<Map<String, dynamic>>();
