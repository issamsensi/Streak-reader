import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/sync/sync_service.dart';
import '../../../core/di/providers.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(ref.watch(databaseProvider));
});

final syncAvailableProvider = Provider<bool>((ref) {
  return ref.watch(syncServiceProvider).isAvailable;
});
