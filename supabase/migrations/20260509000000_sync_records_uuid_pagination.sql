-- Additive support for UUID-based sync record keys and paginated pulls.
-- Keeps the single sync_records table and existing RLS/stale-update trigger.

create index if not exists sync_records_user_updated_key_idx
  on public.sync_records (user_id, updated_at, record_key);
