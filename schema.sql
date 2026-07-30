-- ============================================================
--  ORBITE — schéma de base
--  À coller dans Supabase : SQL Editor → New query → Run
-- ============================================================

create extension if not exists "pgcrypto";

-- ------------------------------------------------------------
--  Table des tâches
-- ------------------------------------------------------------
create table if not exists public.tasks (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users (id) on delete cascade,

  title       text        not null default '',
  note        text        not null default '',
  descr       text        not null default '',

  due_date    date,
  due_time    time,
  remind      boolean     not null default false,

  checklist   jsonb       not null default '[]'::jsonb,
  category    text        not null default '',

  level       smallint    not null default 1 check (level between 0 and 2),
  done        boolean     not null default false,

  touched     timestamptz not null default now(),
  created_at  timestamptz not null default now()
);

comment on column public.tasks.level is '0 = Focus, 1 = À venir, 2 = Plus tard';

create index if not exists tasks_user_idx    on public.tasks (user_id);
create index if not exists tasks_browse_idx  on public.tasks (user_id, done, level);

-- ------------------------------------------------------------
--  Sécurité : chaque personne ne voit que ses propres tâches
-- ------------------------------------------------------------
alter table public.tasks enable row level security;

drop policy if exists tasks_select_own on public.tasks;
create policy tasks_select_own on public.tasks
  for select using (auth.uid() = user_id);

drop policy if exists tasks_insert_own on public.tasks;
create policy tasks_insert_own on public.tasks
  for insert with check (auth.uid() = user_id);

drop policy if exists tasks_update_own on public.tasks;
create policy tasks_update_own on public.tasks
  for update using (auth.uid() = user_id)
          with check (auth.uid() = user_id);

drop policy if exists tasks_delete_own on public.tasks;
create policy tasks_delete_own on public.tasks
  for delete using (auth.uid() = user_id);

-- ------------------------------------------------------------
--  Vérification
-- ------------------------------------------------------------
-- select * from pg_policies where tablename = 'tasks';
