create extension if not exists pgcrypto;

create table if not exists public.tecnicos (
  id uuid primary key,
  nome text not null,
  email text unique not null,
  created_at timestamptz not null default now()
);

create table if not exists public.chamados (
  id uuid primary key default gen_random_uuid(),
  numero_chamado text not null,
  patrimonio text not null,
  ip text not null default '',
  localidade text not null default '',
  memoria_ram text not null,
  armazenamento_tipo text not null,
  armazenamento_outros text,
  problema text not null,
  resolucao text not null,
  tecnico_id uuid not null references public.tecnicos(id) on delete restrict,
  tecnico_nome text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.historico_alteracoes (
  id uuid primary key default gen_random_uuid(),
  chamado_id uuid not null references public.chamados(id) on delete cascade,
  patrimonio text not null,
  tecnico_id uuid not null references public.tecnicos(id) on delete restrict,
  tecnico_nome text not null,
  acao text not null,
  resumo text,
  created_at timestamptz not null default now()
);

create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_chamados_updated_at on public.chamados;
create trigger trg_chamados_updated_at
before update on public.chamados
for each row
execute function public.set_updated_at();

alter table public.tecnicos enable row level security;
alter table public.chamados enable row level security;
alter table public.historico_alteracoes enable row level security;

drop policy if exists "tecnicos_select_own" on public.tecnicos;
create policy "tecnicos_select_own"
on public.tecnicos
for select to authenticated
using (auth.uid() = id);

drop policy if exists "tecnicos_insert_own" on public.tecnicos;
create policy "tecnicos_insert_own"
on public.tecnicos
for insert to authenticated
with check (auth.uid() = id);

drop policy if exists "tecnicos_update_own" on public.tecnicos;
create policy "tecnicos_update_own"
on public.tecnicos
for update to authenticated
using (auth.uid() = id)
with check (auth.uid() = id);

drop policy if exists "chamados_all_authenticated" on public.chamados;
create policy "chamados_all_authenticated"
on public.chamados
for all to authenticated
using (true)
with check (true);

drop policy if exists "historico_all_authenticated" on public.historico_alteracoes;
create policy "historico_all_authenticated"
on public.historico_alteracoes
for all to authenticated
using (true)
with check (true);
