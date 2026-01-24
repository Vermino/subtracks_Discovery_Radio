import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracks/database/database.dart';

void main() {
  test('index songs_source_id_user_rating_updated_idx should exist', () async {
    final db = SubtracksDatabase.connection(NativeDatabase.memory());

    // Ensure the database is created and migrations ran
    await db.customSelect('SELECT 1').get();

    final result = await db.customSelect(
      "SELECT name FROM sqlite_master WHERE type='index' AND name='songs_source_id_user_rating_updated_idx'"
    ).get();

    expect(result, isNotEmpty, reason: 'Index songs_source_id_user_rating_updated_idx not found');
    expect(result.first.read<String>('name'), 'songs_source_id_user_rating_updated_idx');

    await db.close();
  });
}
