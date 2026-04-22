import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tennisbookings/global_helpers/helper_functions.dart';
import 'package:tennisbookings/global_helpers/mixins.dart';
import 'package:tennisbookings/global_helpers/class_extensions.dart';

class _Item with HasId {
  @override
  final String id;
  _Item(this.id);
}

class _Named extends HasName {
  @override
  final String name;
  _Named(this.name);
}

void main() {
  group('findByIdOrNull', () {
    final items = [_Item('a'), _Item('b'), _Item('c')];

    test('returns item when id matches', () {
      final result = findByIdOrNull<_Item>(items, 'b');
      expect(result?.id, 'b');
    });

    test('returns null when id not in list', () {
      expect(findByIdOrNull<_Item>(items, 'z'), isNull);
    });

    test('returns null for empty list', () {
      expect(findByIdOrNull<_Item>([], 'a'), isNull);
    });

    test('returns null when id is null', () {
      expect(findByIdOrNull<_Item>(items, null), isNull);
    });
  });

  group('sortAlphabetically', () {
    test('sorts unsorted list', () {
      final list = [_Named('Charlie'), _Named('Alice'), _Named('Bob')];
      final sorted = sortAlphabetically<_Named>(list);
      expect(sorted.map((e) => e.name).toList(), ['Alice', 'Bob', 'Charlie']);
    });

    test('already sorted list stays sorted', () {
      final list = [_Named('Alpha'), _Named('Beta')];
      final sorted = sortAlphabetically<_Named>(list);
      expect(sorted.map((e) => e.name).toList(), ['Alpha', 'Beta']);
    });

    test('single element list is unchanged', () {
      final list = [_Named('Only')];
      final sorted = sortAlphabetically<_Named>(list);
      expect(sorted.length, 1);
      expect(sorted[0].name, 'Only');
    });

    test('empty list returns empty', () {
      expect(sortAlphabetically<_Named>(<_Named>[]), isEmpty);
    });
  });

  group('getContrastColor', () {
    test('white returns black', () {
      expect(getContrastColor(Colors.white), Colors.black);
    });

    test('yellow returns black', () {
      expect(getContrastColor(Colors.yellow), Colors.black);
    });

    test('black returns white', () {
      expect(getContrastColor(Colors.black), Colors.white);
    });

    test('dark blue returns white', () {
      expect(getContrastColor(Colors.blue.shade900), Colors.white);
    });
  });
}
