class SyncConfig {
  const SyncConfig._();

  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://yteqylwmiygtjzqgiylx.supabase.co',
  );
  static const anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    // Publishable client key for the streak reader project. Safe to ship:
    // all data access is gated by row-level security on sync_records.
    defaultValue:
        'sb_publishable_uPCJWxvLzWKicKXc6Ge8ZA_7Oagfjzc',
  );

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
