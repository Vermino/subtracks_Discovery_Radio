import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:subtracks/database/database.dart';
import 'package:subtracks/models/query.dart';

void main() {
  test('buildFilter generates safe SQL with bound variables', () {
    final filter = FilterWith.equals(
      column: 'title',
      value: "' OR 1=1 --",
    );

    final expr = buildFilter<bool>(filter);

    // Setup GenerationContext
    final db = SubtracksDatabase.connection(NativeDatabase.memory());
    final context = GenerationContext.fromDb(db);

    // Write expression into context
    expr.writeInto(context);

    // Verify SQL uses placeholder
    print('Generated SQL: ${context.sql}');

    // Drift might wrap custom expressions in parens
    expect(context.sql, anyOf(contains('title = ?'), contains('(title) = ?')));
    expect(context.sql, isNot(contains("' OR 1=1 --")));

    // Verify variable is bound
    expect(context.introducedVariables, hasLength(1));
    expect(context.introducedVariables.first.value, equals("' OR 1=1 --"));
  });
}
