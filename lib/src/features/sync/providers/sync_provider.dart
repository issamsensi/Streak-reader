import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/sync/sync_service.dart';
import '../../../core/di/providers.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(ref.watch(databaseProvider));
});

/// Signed-in user, updated on every auth state change.
final syncUserProvider = StreamProvider<User?>((ref) {
  return ref.watch(syncServiceProvider).authStateChanges;
});

final syncAvailableProvider = Provider<bool>((ref) {
  return ref.watch(syncServiceProvider).isAvailable;
});
