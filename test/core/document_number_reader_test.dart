import 'package:flutter_test/flutter_test.dart';
import 'package:urban_services/core/utils/document_number_reader.dart';

void main() {
  group('extractAadhaar', () {
    test('reads a spaced number from card text', () {
      const text =
          'Government of India\nAbhay Kumar\nDOB: 01/02/1995\n'
          'MALE\n2341 2341 2346\nMera Aadhaar, Meri Pehchan';
      expect(extractAadhaar(text), '234123412346');
    });

    test('reads an unspaced number', () {
      expect(extractAadhaar('No. 987654321012'), '987654321012');
    });

    test('rejects a failing checksum (OCR misread)', () {
      expect(extractAadhaar('2341 2341 2347'), isNull);
    });

    test('rejects a masked card', () {
      expect(extractAadhaar('XXXX XXXX 2346'), isNull);
    });

    test('rejects numbers starting with 0 or 1', () {
      // Passes Verhoeff, but no Aadhaar starts with 1.
      expect(isValidVerhoeff('123412341234'), isTrue);
      expect(extractAadhaar('1234 1234 1234'), isNull);
    });

    test('skips the 16-digit VID and finds the Aadhaar number', () {
      const text = 'VID : 9123 4567 8912 3456\n2341 2341 2346';
      expect(extractAadhaar(text), '234123412346');
    });
  });

  group('extractPan', () {
    test('reads a clean PAN', () {
      const text =
          'INCOME TAX DEPARTMENT\nGOVT. OF INDIA\n'
          'Permanent Account Number Card\nABCPE1234F\nABHAY KUMAR';
      expect(extractPan(text), 'ABCPE1234F');
    });

    test('corrects letter/digit OCR confusions by position', () {
      // 8 read for B (letter slot), Z and O read for 2 and 0 (digit slots).
      expect(extractPan('A8CPE1ZO4F'), 'ABCPE1204F');
    });

    test('ignores 10-letter words and invalid holder types', () {
      expect(extractPan('GOVERNMENT DEPARTMENT'), isNull);
      // 4th character must be a holder type (P, C, H, F, A, T, B, L, J, G).
      expect(extractPan('ABCDE1234F'), isNull);
    });
  });
}
