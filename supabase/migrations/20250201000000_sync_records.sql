create table if not exists public.sync_records (
  user_id uuid not null references auth.users(id) on delete cascade,
  record_key text not null,
  entity_type text not null,
  payload jsonb not null,
  updated_at timestamptz not null,
  deleted boolean not null default false,
  primary key (user_id, record_key)
);

create index if not exists sync_records_user_updated_idx
  on public.sync_records (user_id, updated_at);

alter table public.sync_records enable row level security;

create policy "Users can read their sync records"
  on public.sync_records for select
  using (auth.uid() = user_id);

create policy "Users can insert their sync records"
  on public.sync_records for insert
  with check (auth.uid() = user_id);

create policy "Users can update their sync records"
  on public.sync_records for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create or replace function public.prevent_stale_sync_record()
returns trigger
language plpgsql
as $$
begin
  if new.updated_at < old.updated_at then
    return old;
  end if;
  return new;
end;
$$;

create trigger sync_records_reject_stale
before update on public.sync_records
for each row execute function public.prevent_stale_sync_record();
