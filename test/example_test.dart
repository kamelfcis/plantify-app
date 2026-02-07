import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Example Tests', () {
    test('Sample test', () {
      expect(1 + 1, equals(2));
    });

    test('String operations', () {
      final text = 'Hello World';
      expect(text.toLowerCase(), equals('hello world'));
      expect(text.toUpperCase(), equals('HELLO WORLD'));
    });

    test('List operations', () {
      final list = [1, 2, 3, 4, 5];
      expect(list.length, equals(5));
      expect(list.first, equals(1));
      expect(list.last, equals(5));
    });
  });
}

