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

  /// Emits the signed-in user on every auth change (sign-in/out, token
  /// refresh), starting from the current session when there is one.
  Stream<User?> get authStateChanges async* {
    if (!isAvailable) {
      yield null;
      return;
    }
    yield currentUser;
    yield* _client.auth.onAuthStateChange.map((event) => event.session?.user);
  }

  Future<bool> signInWithGoogle() async {
    if (!isAvailable) return false;
    return _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.streakreader://login-callback',
    );
  }

  /// Email/password sign-in. Returns null on success, otherwise a
  /// user-readable error message.
  Future<String?> signInWithEmail(String email, String password) async {
    if (!isAvailable) return 'Sync is not available.';
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return response.session == null ? 'Sign-in did not complete.' : null;
    } on AuthException catch (error) {
      return error.message;
    } catch (_) {
      return 'Sign-in failed. Check your connection and try again.';
    }
  }

  /// Creates an email/password account. Returns null when a session is
  /// active afterwards; returns a notice when email confirmation is
  /// required first.
  Future<String?> signUpWithEmail(String email, String password) async {
    if (!isAvailable) return 'Sync is not available.';
    try {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
      );
      if (response.session != null) return null;
      return 'Account created. Confirm it from the email we sent, then sign in.';
    } on AuthException catch (error) {
      return error.message;
    } catch (_) {
      return 'Sign-up failed. Check your connection and try again.';
    }
  }

  Future<void> signOut() async {
    if (isAvailable) await _client.auth.signOut();
  }

  static const _pullBatchSize = 200;

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
    var offset = 0;
    while (true) {
      final rows = await _client
          .from('sync_records')
          .select('record_key, entity_type, payload, updated_at, deleted')
          .order('updated_at')
          .order('record_key')
          .range(offset, offset + _pullBatchSize - 1);
      if (rows.isEmpty) break;

      final local = {
        for (final record in await database.getAllSyncRecords())
          record.recordKey: record.updatedAt,
      };
      for (final row in rows) {
        final key = row['record_key'] as String;
        final remoteUpdated = DateTime.parse(row['updated_at'] as String).toUtc();
        final localUpdated = local[key];
        final deleted = row['deleted'] as bool? ?? false;
        if (localUpdated != null && !remoteUpdated.isAfter(localUpdated)) {
          continue;
        }
        final payload = jsonEncode(row['payload']);
        await database.saveSyncRecord(
          SyncRecordsCompanion.insert(
            recordKey: key,
            entityType: row['entity_type'] as String,
            payload: payload,
            updatedAt: remoteUpdated,
            deleted: Value(deleted),
            pending: const Value(false),
          ),
        );
        await database.applyRemoteSyncRecord(
          entityType: row['entity_type'] as String,
          payload: payload,
          deleted: deleted,
        );
        local[key] = remoteUpdated;
      }
      if (rows.length < _pullBatchSize) break;
      offset += rows.length;
    }
  }
}
