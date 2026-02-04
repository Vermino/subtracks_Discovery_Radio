## 2024-05-24 - Redundant Database Indexes
**Learning:** SQLite (and Drift) automatically creates an index for the Primary Key. When the Primary Key is composite (e.g., `(source_id, id)`), it serves as an index for the first column (`source_id`) and the combination of columns. Therefore, creating a separate index on `source_id` is redundant.
**Action:** Always check the Primary Key definition before adding single-column indexes. Remove redundant indexes to save disk space and improve write performance.
