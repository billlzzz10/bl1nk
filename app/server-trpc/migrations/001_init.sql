-- See earlier migrations spec; creating core tables
create table if not exists accounts (
  id uuid primary key,
  email text unique not null,
  password_hash text,
  status text not null default 'active',
  created_at timestamptz not null default now(),
  last_login_at timestamptz
);

create table if not exists workspaces (
  id uuid primary key,
  name text not null,
  owner_account_id uuid references accounts(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists workspace_members (
  id uuid primary key,
  workspace_id uuid not null references workspaces(id) on delete cascade,
  account_id uuid not null references accounts(id) on delete cascade,
  role text not null check (role in ('owner','admin','member','viewer')),
  created_at timestamptz not null default now(),
  unique (workspace_id, account_id)
);

create table if not exists chat_threads (
  id uuid primary key,
  workspace_id uuid not null references workspaces(id) on delete cascade,
  title text,
  model_config jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists chat_threads_ws_updated_idx on chat_threads (workspace_id, updated_at desc);

create table if not exists chat_messages (
  id uuid primary key,
  thread_id uuid not null references chat_threads(id) on delete cascade,
  workspace_id uuid not null references workspaces(id) on delete cascade,
  role text not null check (role in ('user','assistant')),
  text text not null,
  status text not null check (status in ('pending','streaming','completed','error')),
  meta jsonb,
  parent_id uuid references chat_messages(id) on delete set null,
  created_at timestamptz not null default now()
);
create index if not exists chat_messages_thread_created_idx on chat_messages (thread_id, created_at asc);
create index if not exists chat_messages_ws_created_idx on chat_messages (workspace_id, created_at desc);

create table if not exists chat_context_files (
  id uuid primary key,
  workspace_id uuid not null references workspaces(id) on delete cascade,
  name text not null,
  source_type text not null check (source_type in ('upload','web')),
  loader_type text not null check (loader_type in ('pdf','txt','markdown','unknown')),
  path text,
  url text,
  hash text not null,
  status text not null check (status in ('uploading','pending_chunks','ready','error')),
  created_at timestamptz not null default now(),
  unique (workspace_id, hash)
);

create table if not exists thread_attachments (
  thread_id uuid not null references chat_threads(id) on delete cascade,
  file_id uuid not null references chat_context_files(id) on delete cascade,
  added_at timestamptz not null default now(),
  primary key (thread_id, file_id)
);

create table if not exists share_states (
  entity_id uuid primary key references chat_threads(id) on delete cascade,
  visibility text not null check (visibility in ('private','workspace','public','url')),
  slug text unique,
  url text,
  permissions jsonb,
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create table if not exists publish_states (
  entity_id uuid primary key references chat_threads(id) on delete cascade,
  status text not null check (status in ('draft','published','unpublished')),
  slug text unique,
  last_published_at timestamptz
);

create table if not exists export_jobs (
  id uuid primary key,
  thread_id uuid not null references chat_threads(id) on delete cascade,
  format text not null check (format in ('pdf','markdown','txt')),
  status text not null check (status in ('queued','running','done','error')),
  output_url text,
  error text,
  requested_by uuid references accounts(id) on delete set null,
  created_at timestamptz not null default now(),
  finished_at timestamptz
);

create table if not exists jobs (
  job_id uuid primary key,
  workspace_id uuid not null references workspaces(id) on delete cascade,
  job_type text not null check (job_type in ('export','publish','file_chunking','file_embedding','reindex_embeddings','cleanup','backfill')),
  payload jsonb not null,
  status text not null check (status in ('pending','running','completed','failed','canceled')) default 'pending',
  attempts int not null default 0,
  max_attempts int not null default 3,
  priority int not null default 0,
  dedup_key text,
  scheduled_at timestamptz,
  started_at timestamptz,
  finished_at timestamptz,
  error text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create unique index if not exists jobs_dedup_key_uidx on jobs (dedup_key) where dedup_key is not null;
create index if not exists jobs_ws_status_idx on jobs (workspace_id, status, priority, coalesce(scheduled_at, created_at));

alter table chat_threads enable row level security;
alter table chat_messages enable row level security;
alter table chat_context_files enable row level security;
alter table thread_attachments enable row level security;
alter table jobs enable row level security;

-- Add basic RLS policies (customize based on your auth system)
create policy "Users can access threads in their workspaces" on chat_threads
  for all using (workspace_id in (
    select workspace_id from workspace_members 
    where account_id = current_setting('app.current_user_id')::uuid
  ));

create policy "Users can access messages in their workspaces" on chat_messages
  for all using (workspace_id in (
    select workspace_id from workspace_members 
    where account_id = current_setting('app.current_user_id')::uuid
  ));

