-- ============================================================
-- MIGRAÇÃO v1 → v2 — Karatê Miyamoto Damashii Caeté
-- Execute este arquivo no Supabase SQL Editor caso já tenha
-- rodado o schema.sql original (v1).
-- ============================================================

-- ============================================================
-- 1. PERFIS DE USUÁRIO (admin vs aluno)
-- ============================================================
create table if not exists public.profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  full_name   text,
  role        text not null default 'student'
                   check (role in ('admin', 'student')),
  created_at  timestamptz default now(),
  updated_at  timestamptz default now()
);

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
as $$
begin
  insert into public.profiles (id, full_name, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', ''),
    'student'
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

create or replace function public.is_admin()
returns boolean
language sql
security definer
stable
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

-- ============================================================
-- 2. HORÁRIOS DE AULA
-- ============================================================
create table if not exists public.class_schedules (
  id              uuid primary key default uuid_generate_v4(),
  modality_id     uuid references public.modalities(id) on delete set null,
  modality_name   text not null,
  day_of_week     integer not null check (day_of_week between 0 and 6),
  start_time      time not null,
  end_time        time not null,
  instructor      text,
  location        text,
  target_audience text,
  max_students    integer,
  notes           text,
  is_active       boolean default true,
  display_order   integer default 0,
  created_at      timestamptz default now(),
  updated_at      timestamptz default now()
);

-- ============================================================
-- 3. HISTÓRICO DE GRADUAÇÕES
-- ============================================================
create table if not exists public.graduations (
  id            uuid primary key default uuid_generate_v4(),
  student_id    uuid not null references public.students(id) on delete cascade,
  belt          text not null,
  exam_date     date not null,
  exam_location text,
  examiner      text,
  notes         text,
  created_at    timestamptz default now()
);

-- ============================================================
-- 4. COLUNAS NOVAS EM TABELAS EXISTENTES
-- ============================================================

-- contacts: consent_lgpd + updated_at
alter table public.contacts
  add column if not exists consent_lgpd boolean not null default false,
  add column if not exists updated_at   timestamptz default now();

-- gallery: alt_text
alter table public.gallery
  add column if not exists alt_text text;

-- payments: payment_method + updated_at
alter table public.payments
  add column if not exists payment_method text,
  add column if not exists updated_at     timestamptz default now();

-- professors: photo_alt
alter table public.professors
  add column if not exists photo_alt text;

-- modalities: updated_at
alter table public.modalities
  add column if not exists updated_at timestamptz default now();

-- students: unique em cpf (só adiciona se não existir)
do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'students_cpf_key'
  ) then
    alter table public.students add constraint students_cpf_key unique (cpf);
  end if;
end $$;

-- ============================================================
-- 5. INDEXES
-- ============================================================
create index if not exists idx_news_slug          on public.news (slug);
create index if not exists idx_news_published      on public.news (is_published, published_at desc);
create index if not exists idx_events_date         on public.events (event_date, is_public);
create index if not exists idx_gallery_category    on public.gallery (category, is_active);
create index if not exists idx_contacts_is_read    on public.contacts (is_read, created_at desc);
create index if not exists idx_students_user_id    on public.students (user_id);
create index if not exists idx_payments_student    on public.payments (student_id, reference_month);
create index if not exists idx_attendance_student  on public.attendance (student_id, class_date);
create index if not exists idx_graduations_student on public.graduations (student_id, exam_date);
create index if not exists idx_schedules_day       on public.class_schedules (day_of_week, is_active);

-- ============================================================
-- 6. RLS — habilitar nas novas tabelas
-- ============================================================
alter table public.profiles        enable row level security;
alter table public.class_schedules enable row level security;
alter table public.graduations     enable row level security;

-- ============================================================
-- 7. REMOVER políticas antigas (autenticado = admin — ERRADO)
-- ============================================================
drop policy if exists "Authenticated full access professors"   on public.professors;
drop policy if exists "Authenticated full access modalities"   on public.modalities;
drop policy if exists "Authenticated full access events"       on public.events;
drop policy if exists "Authenticated full access news"         on public.news;
drop policy if exists "Authenticated full access gallery"      on public.gallery;
drop policy if exists "Authenticated full access documents"    on public.documents;
drop policy if exists "Authenticated full access faq"          on public.faq;
drop policy if exists "Authenticated full access testimonials" on public.testimonials;
drop policy if exists "Authenticated full access students"     on public.students;
drop policy if exists "Authenticated full access payments"     on public.payments;
drop policy if exists "Authenticated full access attendance"   on public.attendance;
drop policy if exists "Authenticated full access contacts"     on public.contacts;
drop policy if exists "Authenticated full access site_settings" on public.site_settings;

-- ============================================================
-- 8. NOVAS políticas públicas (class_schedules)
-- ============================================================
create policy "Public read class_schedules"
  on public.class_schedules for select using (is_active = true);

-- ============================================================
-- 9. POLÍTICAS — alunos leem próprios dados
-- ============================================================
create policy "Students read own profile"
  on public.students for select using (user_id = auth.uid());

create policy "Students read own payments"
  on public.payments for select
  using (student_id in (
    select id from public.students where user_id = auth.uid()
  ));

create policy "Students read own attendance"
  on public.attendance for select
  using (student_id in (
    select id from public.students where user_id = auth.uid()
  ));

create policy "Students read own graduations"
  on public.graduations for select
  using (student_id in (
    select id from public.students where user_id = auth.uid()
  ));

create policy "Users read own profile"
  on public.profiles for select using (id = auth.uid());

create policy "Users update own profile"
  on public.profiles for update using (id = auth.uid());

-- Contato: só permite inserção com consent_lgpd = true
drop policy if exists "Anyone can insert contact" on public.contacts;
create policy "Anyone can insert contact"
  on public.contacts for insert with check (consent_lgpd = true);

-- ============================================================
-- 10. POLÍTICAS ADMIN — só role = 'admin'
-- ============================================================
create policy "Admin full access profiles"        on public.profiles        for all using (is_admin());
create policy "Admin full access professors"      on public.professors       for all using (is_admin());
create policy "Admin full access modalities"      on public.modalities       for all using (is_admin());
create policy "Admin full access class_schedules" on public.class_schedules  for all using (is_admin());
create policy "Admin full access events"          on public.events           for all using (is_admin());
create policy "Admin full access news"            on public.news             for all using (is_admin());
create policy "Admin full access gallery"         on public.gallery          for all using (is_admin());
create policy "Admin full access documents"       on public.documents        for all using (is_admin());
create policy "Admin full access faq"             on public.faq              for all using (is_admin());
create policy "Admin full access testimonials"    on public.testimonials     for all using (is_admin());
create policy "Admin full access students"        on public.students         for all using (is_admin());
create policy "Admin full access graduations"     on public.graduations      for all using (is_admin());
create policy "Admin full access payments"        on public.payments         for all using (is_admin());
create policy "Admin full access attendance"      on public.attendance       for all using (is_admin());
create policy "Admin full access contacts"        on public.contacts         for all using (is_admin());
create policy "Admin full access site_settings"   on public.site_settings    for all using (is_admin());

-- ============================================================
-- 11. SEED — HORÁRIOS DE AULA
-- day_of_week: 1=Segunda 2=Terça 3=Quarta 4=Quinta 5=Sexta 6=Sábado
-- ============================================================
insert into public.class_schedules
  (modality_name, day_of_week, start_time, end_time, target_audience, display_order)
values
  ('Karatê Infantil',             1, '17:00', '18:00', 'infantil', 10),
  ('Karatê Infantil',             3, '17:00', '18:00', 'infantil', 11),
  ('Karatê Infantil',             5, '17:00', '18:00', 'infantil', 12),
  ('Karatê para Jovens',          1, '18:00', '19:00', 'jovens',   20),
  ('Karatê para Jovens',          3, '18:00', '19:00', 'jovens',   21),
  ('Karatê para Jovens',          5, '18:00', '19:00', 'jovens',   22),
  ('Karatê Adulto',               1, '19:00', '20:30', 'adultos',  30),
  ('Karatê Adulto',               3, '19:00', '20:30', 'adultos',  31),
  ('Karatê Adulto',               5, '19:00', '20:30', 'adultos',  32),
  ('Karatê Adulto',               6, '08:00', '10:00', 'adultos',  33),
  ('Treinamento para Competição', 2, '18:00', '20:00', 'todos',    40),
  ('Treinamento para Competição', 4, '18:00', '20:00', 'todos',    41),
  ('Treinamento para Competição', 6, '10:00', '12:00', 'todos',    42);

-- Vincula modality_id pelo título
update public.class_schedules cs
set modality_id = m.id
from public.modalities m
where m.title = cs.modality_name;
