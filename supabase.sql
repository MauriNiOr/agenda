-- DAW Planner · Cuentas privadas con Supabase
-- Ejecutar una vez en Supabase > SQL Editor con el proyecto correcto.
-- Cada cuenta solo podrá consultar/modificar su propia agenda.
create table if not exists public.planner_data (
  user_id uuid primary key references auth.users(id) on delete cascade,
  revision bigint not null default 0,
  events jsonb not null default '[]'::jsonb
    check (jsonb_typeof(events) = 'array'),
  deleted jsonb not null default '{}'::jsonb
    check (jsonb_typeof(deleted) = 'object'),
  updated_at timestamptz not null default now()
);

alter table public.planner_data enable row level security;

drop policy if exists planner_select_own on public.planner_data;
create policy planner_select_own on public.planner_data
  for select to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists planner_insert_own on public.planner_data;
create policy planner_insert_own on public.planner_data
  for insert to authenticated
  with check ((select auth.uid()) = user_id);

drop policy if exists planner_update_own on public.planner_data;
create policy planner_update_own on public.planner_data
  for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

revoke all on public.planner_data from anon;
grant select, insert, update on public.planner_data to authenticated;

-- Guardado con control de versión: si dos dispositivos guardan
-- simultáneamente, uno reintenta leyendo los nuevos datos.
create or replace function public.planner_save(
  expected_revision bigint,
  next_events jsonb,
  next_deleted jsonb
) returns boolean
language plpgsql
security invoker
set search_path = ''
as $$
declare
  affected integer;
  current_uid uuid;
begin
  current_uid := (select auth.uid());
  if current_uid is null then
    raise exception 'Debes iniciar sesión';
  end if;
  if jsonb_typeof(next_events) is distinct from 'array'
    or jsonb_typeof(next_deleted) is distinct from 'object' then
    raise exception 'Formato de agenda no válido';
  end if;
  insert into public.planner_data as p
    (user_id, revision, events, deleted, updated_at)
  values
    (current_uid, 1, next_events, next_deleted, now())
  on conflict (user_id) do update
    set revision = p.revision + 1,
        events = excluded.events,
        deleted = excluded.deleted,
        updated_at = now()
    where p.revision = expected_revision;

  get diagnostics affected = row_count;
  return affected = 1;
end;
$$;

revoke all on function public.planner_save(bigint,jsonb,jsonb) from public;
revoke all on function public.planner_save(bigint,jsonb,jsonb) from anon;
grant execute on function public.planner_save(bigint,jsonb,jsonb) to authenticated;
