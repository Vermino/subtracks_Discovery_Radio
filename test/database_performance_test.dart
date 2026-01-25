import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracks/database/database.dart';

void main() {
  test('songs table has index on (source_id, genre) used by queries', () async {
    final db = SubtracksDatabase.connection(NativeDatabase.memory());
    addTearDown(db.close);

    // Ensure database is created (this triggers migration)
    await db.customSelect('SELECT 1').getSingle();

    // Insert a dummy source to satisfy foreign key constraints
    await db.into(db.sources).insert(
          SourcesCompanion.insert(
            name: 'Test Source',
            address: Uri.parse('http://example.com'),
          ),
        );

    // Check if the index is used for a genre query
    final explainResult = await db.customSelect(
      'EXPLAIN QUERY PLAN SELECT COUNT(*) FROM songs WHERE source_id = 1 AND genre = \'Rock\'',
    ).get();

    bool usesIndex = false;
    for (final row in explainResult) {
      // The column name for detail varies by sqlite version/mode, usually 'detail'
      final detail = row.data['detail'].toString();
      print('Explain detail: $detail');
      // "USING INDEX" or "USING COVERING INDEX"
      if (detail.contains('songs_source_id_genre_idx')) {
        usesIndex = true;
      }
    }

    expect(usesIndex, isTrue, reason: 'Query should use the songs_source_id_genre_idx index');
  });
}
