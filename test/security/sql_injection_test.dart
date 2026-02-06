import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracks/database/database.dart';
import 'package:subtracks/models/query.dart';

// IMPORTANT: This test verifies that we are NOT vulnerable to SQL Injection
// by checking if parameters are bound (using placeholders) instead of raw strings.

void main() {
  test('buildFilter prevents SQL injection by using variable binding', () {
    // A sample malicious input that would change the query structure if injected directly
    const maliciousValue = "foo' OR '1'='1";

    // Create a filter with this value
    final filter = FilterWith.equals(
        column: 'title',
        value: maliciousValue
    );

    // We create a context to see what SQL is generated
    // Using memory database is fine as we don't execute, just generate SQL
    final db = SubtracksDatabase.connection(NativeDatabase.memory());
    final context = GenerationContext.fromDb(db);

    // Generate the expression
    final expression = buildFilter(filter);

    // Write the expression into the context
    expression.writeInto(context);

    // Cleanup
    db.close();

    // Debug output
    print('Generated SQL: ${context.sql}');
    print('Bound Variables: ${context.boundVariables}');

    // VERIFICATION:

    // 1. The SQL should NOT contain the raw malicious string
    // If it does, it means we are just concatenating strings (VULNERABLE)
    if (context.sql.contains("foo' OR '1'='1")) {
      fail('CRITICAL: SQL Injection Vulnerability detected! Raw value found in SQL: ${context.sql}');
    }

    // 2. The SQL SHOULD contain a placeholder '?'
    expect(context.sql, contains('?'), reason: 'SQL should use placeholders for values');

    // 3. The bound variables list SHOULD contain the value
    expect(context.boundVariables, contains(maliciousValue), reason: 'Value should be bound as a variable');
  });

  test('buildFilter.greaterThan prevents SQL injection', () {
      const maliciousValue = "1; DROP TABLE users; --";
      final filter = FilterWith.greaterThan(column: 'play_count', value: maliciousValue);

      final db = SubtracksDatabase.connection(NativeDatabase.memory());
      final context = GenerationContext.fromDb(db);
      final expression = buildFilter(filter);
      expression.writeInto(context);
      db.close();

      if (context.sql.contains("DROP TABLE")) {
        fail('CRITICAL: SQL Injection Vulnerability in greaterThan! SQL: ${context.sql}');
      }
      expect(context.sql, contains('?'));
      expect(context.boundVariables, contains(maliciousValue));
  });
}
