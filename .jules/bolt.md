## 2024-05-22 - [Database Index Optimization]
**Learning:** Adding indexes to frequently filtered columns (like `genre` and `user_rating`) in the `songs` table can significantly improve query performance, especially in large libraries. This is a low-hanging fruit for backend performance.
**Action:** Always check `tables.drift` for missing indexes on columns used in `WHERE` clauses, especially for large tables like `songs`.
