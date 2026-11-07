import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streak_reader/src/core/sync/sync_service.dart';
import 'package:streak_reader/src/data/datasources/local/app_database.dart';

void main() {
  test('uninitialized sync service fails closed without throwing', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final sync = SyncService(db);

    // The settings screen reads these before main() initialization (and in
    // tests where Supabase.initialize was never called); they must not throw.
    expect(sync.isAvailable, isFalse);
    expect(sync.currentUser, isNull);
    expect(await sync.authStateChanges.first, isNull);
    expect(
      await sync.signInWithEmail('a@example.com', 'password'),
      'Sync is not available.',
    );
    expect(
      await sync.signUpWithEmail('a@example.com', 'password'),
      'Sync is not available.',
    );
  });
}
