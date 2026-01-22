## 2024-05-22 - SQL Injection in Dynamic Filter Builder
**Vulnerability:** SQL Injection in `buildFilter` via unsafe string interpolation of values in `CustomExpression`.
**Learning:** Using `CustomExpression` in Drift/Moor requires extreme caution. It interprets string content as raw SQL. Interpolating user input into it bypasses all protections.
**Prevention:** Always use `Variable` or `Expression` builder methods (like `.equals`, `.isBiggerThan`) which automatically handle parameter binding. Never interpolate values into SQL strings.
