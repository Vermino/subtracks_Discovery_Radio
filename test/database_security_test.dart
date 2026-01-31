import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:subtracks/database/database.dart';
import 'package:subtracks/models/query.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

void main() {
  test('buildFilter generates secure SQL with bound variables', () {
    const maliciousValue = "'; DROP TABLE songs; --";
    const filter = FilterWith.equals(
      column: 'title',
      value: maliciousValue,
    );

    final expression = buildFilter<bool>(filter);

    final db = SubtracksDatabase.connection(NativeDatabase.memory());
    final context = GenerationContext.fromDb(db);
    expression.writeInto(context);

    // Verify SQL uses placeholders
    expect(context.sql, contains('?'));
    // Verify SQL does NOT contain the raw malicious string
    expect(context.sql, isNot(contains(maliciousValue)));

    // Verify the value is bound correctly
    expect(context.boundVariables, hasLength(1));
    expect(context.boundVariables.first, equals(maliciousValue));

    db.close();
  });

  test('buildFilter handles isIn with multiple values securely', () {
    const maliciousValue = "'); DROP TABLE songs; --";
    final filter = FilterWith.isIn(
      column: 'genre',
      values: ['Rock', maliciousValue].lock,
    );

    final expression = buildFilter<bool>(filter);

    final db = SubtracksDatabase.connection(NativeDatabase.memory());
    final context = GenerationContext.fromDb(db);
    expression.writeInto(context);

    // Verify SQL uses placeholders
    expect(context.sql, contains('?'));

    // Verify variables are bound
    expect(context.boundVariables, hasLength(2));
    expect(context.boundVariables[0], equals('Rock'));
    expect(context.boundVariables[1], equals(maliciousValue));

    db.close();
  });
}
