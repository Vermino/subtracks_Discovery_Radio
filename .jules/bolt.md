## 2026-02-04 - Drift Database Optimization
**Learning:** The `songs` table in this Drift database powers "Liked Songs" and rating-based views but lacked a composite index on `(source_id, user_rating, updated)`, causing potential full table scans on these frequent queries.
**Action:** When optimizing Drift queries for specific filters/sorts, ensure corresponding composite indexes exist and properly handle the migration version bump in `database.dart`.
