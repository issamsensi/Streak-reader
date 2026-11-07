import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/datasources/local/app_database.dart';
import 'sync_config.dart';

class SyncService {
  SyncService(this.database);

  final AppDatabase database;
  SupabaseClient get _client => Supabase.instance.client;

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (!SyncConfig.isConfigured) return;
    await Supabase.initialize(
      url: SyncConfig.url,
      publishableKey: SyncConfig.anonKey,
    );
    _initialized = true;
  }

  /// Configured *and* initialized. Accessing [Supabase.instance] before
  /// [initialize] throws, so consumers must gate on this, not config alone.
  bool get isAvailable => SyncConfig.isConfigured && _initialized;
  User? get currentUser => isAvailable ? _client.auth.currentUser : null;

  Future<bool> signInWithGoogle() async {
    if (!isAvailable) return false;
    return _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.streakreader://login-callback',
    );
  }

  Future<void> signOut() async {
    if (isAvailable) await _client.auth.signOut();
  }

  Future<void> synchronize() async {
    if (!isAvailable || currentUser == null) return;
    await _push();
    await _pull();
  }

  Future<void> _push() async {
    final pending = await database.getPendingSyncRecords();
    if (pending.isEmpty) return;
    final userId = currentUser?.id;
    if (userId == null) return;
    final rows = pending
        .map(
          (record) => {
            'user_id': userId,
            'record_key': record.recordKey,
            'entity_type': record.entityType,
            'payload': jsonDecode(record.payload),
            'updated_at': record.updatedAt.toUtc().toIso8601String(),
            'deleted': record.deleted,
          },
        )
        .toList();
    await _client.from('sync_records').upsert(rows);
    await database.markSyncRecordsUploaded(pending.map((record) => record.id));
  }

  Future<void> _pull() async {
    final rows = await _client
        .from('sync_records')
        .select('record_key, entity_type, payload, updated_at, deleted')
        .order('updated_at');
    final local = {
      for (final record in await database.getAllSyncRecords())
        record.recordKey: record,
    };
    for (final row in rows) {
      final key = row['record_key'] as String;
      final remoteUpdated = DateTime.parse(row['updated_at'] as String);
      final localUpdated = local[key]?.updatedAt;
      if (localUpdated != null && !remoteUpdated.isAfter(localUpdated)) {
        continue;
      }
      await database.saveSyncRecord(
        SyncRecordsCompanion.insert(
          recordKey: key,
          entityType: row['entity_type'] as String,
          payload: jsonEncode(row['payload']),
          updatedAt: remoteUpdated,
          deleted: Value(row['deleted'] as bool? ?? false),
          pending: const Value(false),
        ),
      );
      if (row['deleted'] != true) {
        await database.applyRemoteSyncRecord(
          entityType: row['entity_type'] as String,
          payload: jsonEncode(row['payload']),
        );
      }
    }
  }
}
