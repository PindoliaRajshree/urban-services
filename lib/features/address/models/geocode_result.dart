// File: lib/features/address/models/geocode_result.dart
// Purpose: Parsed, address-form-ready result of a Google Geocoding API
// reverse-geocode call (lat/lng -> address). See GoogleGeocodingService.

class GeocodeResult {
  final String formattedAddress;
  final String city;
  final String state;
  final String pincode;
  final String country;

  const GeocodeResult({
    required this.formattedAddress,
    required this.city,
    required this.state,
    required this.pincode,
    required this.country,
  });

  /// Builds a [GeocodeResult] from one entry of Google's Geocoding API
  /// `results` array.
  factory GeocodeResult.fromGoogleResult(Map<String, dynamic> result) {
    final components =
        (result['address_components'] as List?)?.cast<Map<String, dynamic>>() ??
        const [];

    String pick(List<String> wantedTypes) {
      for (final component in components) {
        final types =
            (component['types'] as List?)?.cast<String>() ?? const [];
        if (wantedTypes.any(types.contains)) {
          return (component['long_name'] as String?)?.trim() ?? '';
        }
      }
      return '';
    }

    // Google represents locations with no interpolated street address
    // (common outside city cores — a lot of India geocodes this way) with
    // a "Plus Code" grid reference like "6PP8+H66" prefixed onto
    // formatted_address (e.g. "6PP8+H66, Navavas, Madhapar, Bhuj,
    // Gujarat, 370020, India"). It's accurate but looks broken/unreadable
    // in an address form, so strip it and keep the rest of the address —
    // falling back to a locality-based description built from the
    // components in the rare case the whole result was just the code.
    final rawFormatted = (result['formatted_address'] as String?)?.trim() ?? '';
    final plusCodePattern = RegExp(
      r'^[23456789CFGHJMPQRVWX]{4,8}\+[23456789CFGHJMPQRVWX]{2,3}\s*,?\s*',
      caseSensitive: false,
    );
    final withoutPlusCode = rawFormatted.replaceFirst(plusCodePattern, '').trim();

    final formattedAddress = withoutPlusCode.isNotEmpty
        ? withoutPlusCode
        : [
            pick(['sublocality', 'sublocality_level_1', 'neighborhood']),
            pick(['locality', 'postal_town', 'administrative_area_level_2']),
            pick(['administrative_area_level_1']),
          ].where((part) => part.isNotEmpty).join(', ');

    return GeocodeResult(
      formattedAddress: formattedAddress,
      // `locality` covers most cities; `postal_town` and
      // `administrative_area_level_2` are fallbacks Google uses in areas
      // where `locality` isn't populated (e.g. parts of the UK, or Indian
      // districts/talukas).
      city: pick(['locality', 'postal_town', 'administrative_area_level_2']),
      state: pick(['administrative_area_level_1']),
      pincode: pick(['postal_code']),
      country: pick(['country']),
    );
  }
}
