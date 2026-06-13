-- ============================================================
-- SCHEMA SUPABASE — Karatê Miyamoto Damashii Caeté
-- v2.0 — com RLS por role, horários, graduações e correções
-- ============================================================

-- EXTENSÕES
create extension if not exists "uuid-ossp";

-- ============================================================
-- PERFIS DE USUÁRIO (controle de acesso admin vs aluno)
-- ============================================================
create table public.profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  full_name   text,
  role        text not null default 'student'
                   check (role in ('admin', 'student')),
  created_at  timestamptz default now(),
  updated_at  timestamptz default now()
);

-- Cria perfil automaticamente quando um novo usuário se registra
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
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Função auxiliar: retorna true se o usuário logado for admin
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
-- PROFESSORES / SENSEIS
-- ============================================================
create table public.professors (
  id               uuid primary key default uuid_generate_v4(),
  name             text not null,
  belt             text not null,           -- ex: "Faixa Preta 5º Dan"
  experience_years integer,
  bio              text,
  specialties      text[],                  -- array de especialidades
  photo_url        text,
  photo_alt        text,                    -- texto alternativo (acessibilidade)
  is_active        boolean default true,
  display_order    integer default 0,
  created_at       timestamptz default now(),
  updated_at       timestamptz default now()
);

-- ============================================================
-- MODALIDADES
-- ============================================================
create table public.modalities (
  id              uuid primary key default uuid_generate_v4(),
  title           text not null,
  description     text,
  icon            text,                     -- nome do ícone lucide/heroicons
  target_audience text,                     -- 'infantil','jovens','adultos','todos'
  is_active       boolean default true,
  display_order   integer default 0,
  created_at      timestamptz default now(),
  updated_at      timestamptz default now()
);

-- ============================================================
-- HORÁRIOS DE AULA
-- day_of_week: 0=Domingo 1=Segunda 2=Terça 3=Quarta
--              4=Quinta  5=Sexta  6=Sábado
-- ============================================================
create table public.class_schedules (
  id              uuid primary key default uuid_generate_v4(),
  modality_id     uuid references public.modalities(id) on delete set null,
  modality_name   text not null,            -- nome da turma exibido no site
  day_of_week     integer not null check (day_of_week between 0 and 6),
  start_time      time not null,
  end_time        time not null,
  instructor      text,                     -- nome do professor (texto livre)
  location        text,                     -- ex: "Tatame principal", "Sala 2"
  target_audience text,                     -- 'infantil','jovens','adultos','todos'
  max_students    integer,
  notes           text,
  is_active       boolean default true,
  display_order   integer default 0,
  created_at      timestamptz default now(),
  updated_at      timestamptz default now()
);

-- ============================================================
-- EVENTOS
-- ============================================================
create table public.events (
  id                uuid primary key default uuid_generate_v4(),
  title             text not null,
  description       text,
  category          text not null,          -- 'exame_faixa','campeonato','seminario','treino_especial','aula_aberta','interno'
  event_date        date not null,
  event_time        time,
  location          text,
  address           text,
  image_url         text,
  is_public         boolean default true,
  registration_link text,
  created_at        timestamptz default now(),
  updated_at        timestamptz default now()
);

-- ============================================================
-- NOTÍCIAS / BLOG
-- ============================================================
create table public.news (
  id              uuid primary key default uuid_generate_v4(),
  title           text not null,
  slug            text unique not null,
  summary         text,
  content         text,
  cover_image_url text,
  category        text,                     -- 'campeonato','entrega_faixa','novas_turmas','dicas','eventos','geral'
  author          text default 'Redação',
  is_published    boolean default false,
  published_at    timestamptz,
  created_at      timestamptz default now(),
  updated_at      timestamptz default now()
);

-- ============================================================
-- GALERIA
-- ============================================================
create table public.gallery (
  id            uuid primary key default uuid_generate_v4(),
  title         text,
  description   text,
  alt_text      text,                       -- texto alternativo obrigatório (WCAG / acessibilidade)
  media_url     text not null,
  media_type    text default 'image',       -- 'image' ou 'video'
  category      text,                       -- 'treinos','campeonatos','exames','eventos','alunos','professores'
  thumbnail_url text,
  is_active     boolean default true,
  display_order integer default 0,
  created_at    timestamptz default now()
);

-- ============================================================
-- DOCUMENTOS
-- ============================================================
create table public.documents (
  id           uuid primary key default uuid_generate_v4(),
  title        text not null,
  description  text,
  file_url     text not null,
  category     text,                        -- 'matricula','regulamento','calendario','exame_faixa','autorizacao','comunicado'
  is_public    boolean default true,
  display_order integer default 0,
  created_at   timestamptz default now(),
  updated_at   timestamptz default now()
);

-- ============================================================
-- FAQ
-- ============================================================
create table public.faq (
  id            uuid primary key default uuid_generate_v4(),
  question      text not null,
  answer        text not null,
  category      text default 'geral',
  display_order integer default 0,
  is_active     boolean default true,
  created_at    timestamptz default now()
);

-- ============================================================
-- DEPOIMENTOS / TESTIMONIALS
-- ============================================================
create table public.testimonials (
  id            uuid primary key default uuid_generate_v4(),
  author_name   text not null,
  author_role   text,                       -- ex: "Mãe de aluno", "Aluno faixa verde"
  content       text not null,
  photo_url     text,
  rating        integer check (rating between 1 and 5),
  is_active     boolean default true,
  display_order integer default 0,
  created_at    timestamptz default now()
);

-- ============================================================
-- ALUNOS
-- ============================================================
create table public.students (
  id              uuid primary key default uuid_generate_v4(),
  user_id         uuid references auth.users(id) on delete cascade,
  full_name       text not null,
  birth_date      date,
  cpf             text unique,              -- CPF único por aluno
  phone           text,
  guardian_name   text,                     -- responsável para menores
  guardian_phone  text,
  belt            text default 'Branca',
  enrollment_date date default current_date,
  is_active       boolean default true,
  notes           text,
  created_at      timestamptz default now(),
  updated_at      timestamptz default now()
);

-- ============================================================
-- HISTÓRICO DE GRADUAÇÕES (faixas conquistadas)
-- ============================================================
create table public.graduations (
  id            uuid primary key default uuid_generate_v4(),
  student_id    uuid not null references public.students(id) on delete cascade,
  belt          text not null,             -- faixa conquistada ex: "Faixa Amarela"
  exam_date     date not null,
  exam_location text,
  examiner      text,                      -- professor avaliador
  notes         text,
  created_at    timestamptz default now()
);

-- ============================================================
-- MENSALIDADES
-- ============================================================
create table public.payments (
  id              uuid primary key default uuid_generate_v4(),
  student_id      uuid not null references public.students(id) on delete cascade,
  reference_month date not null,           -- primeiro dia do mês de referência
  amount          decimal(10,2) not null,
  status          text default 'pendente'
                       check (status in ('pendente','pago','atrasado','isento')),
  payment_date    date,
  payment_method  text,                    -- 'pix','dinheiro','cartao','transferencia'
  notes           text,
  created_at      timestamptz default now(),
  updated_at      timestamptz default now()
);

-- ============================================================
-- FREQUÊNCIA
-- ============================================================
create table public.attendance (
  id          uuid primary key default uuid_generate_v4(),
  student_id  uuid not null references public.students(id) on delete cascade,
  class_date  date not null,
  present     boolean default true,
  notes       text,
  created_at  timestamptz default now()
);

-- ============================================================
-- CONTATO / LEADS
-- ============================================================
create table public.contacts (
  id            uuid primary key default uuid_generate_v4(),
  name          text not null,
  email         text,
  phone         text,
  message       text,
  interest      text,                      -- modalidade de interesse
  source        text default 'site',
  consent_lgpd  boolean not null default false, -- consentimento LGPD obrigatório
  is_read       boolean default false,
  created_at    timestamptz default now(),
  updated_at    timestamptz default now()
);

-- ============================================================
-- CONFIGURAÇÕES DO SITE
-- ============================================================
create table public.site_settings (
  id          uuid primary key default uuid_generate_v4(),
  key         text unique not null,
  value       text,
  description text,
  updated_at  timestamptz default now()
);

-- ============================================================
-- INDEXES — campos de busca frequente
-- ============================================================
create index idx_news_slug        on public.news (slug);
create index idx_news_published   on public.news (is_published, published_at desc);
create index idx_events_date      on public.events (event_date, is_public);
create index idx_gallery_category on public.gallery (category, is_active);
create index idx_contacts_is_read on public.contacts (is_read, created_at desc);
create index idx_students_user_id on public.students (user_id);
create index idx_payments_student on public.payments (student_id, reference_month);
create index idx_attendance_student on public.attendance (student_id, class_date);
create index idx_graduations_student on public.graduations (student_id, exam_date);
create index idx_schedules_day    on public.class_schedules (day_of_week, is_active);

-- ============================================================
-- RLS (Row Level Security)
-- ============================================================
alter table public.profiles       enable row level security;
alter table public.professors     enable row level security;
alter table public.modalities     enable row level security;
alter table public.class_schedules enable row level security;
alter table public.events         enable row level security;
alter table public.news           enable row level security;
alter table public.gallery        enable row level security;
alter table public.documents      enable row level security;
alter table public.faq            enable row level security;
alter table public.testimonials   enable row level security;
alter table public.students       enable row level security;
alter table public.graduations    enable row level security;
alter table public.payments       enable row level security;
alter table public.attendance     enable row level security;
alter table public.contacts       enable row level security;
alter table public.site_settings  enable row level security;

-- ------------------------------------------------------------
-- POLÍTICAS PÚBLICAS (leitura sem autenticação)
-- ------------------------------------------------------------
create policy "Public read professors"
  on public.professors for select using (is_active = true);

create policy "Public read modalities"
  on public.modalities for select using (is_active = true);

create policy "Public read class_schedules"
  on public.class_schedules for select using (is_active = true);

create policy "Public read events"
  on public.events for select using (is_public = true);

create policy "Public read news"
  on public.news for select using (is_published = true);

create policy "Public read gallery"
  on public.gallery for select using (is_active = true);

create policy "Public read documents"
  on public.documents for select using (is_public = true);

create policy "Public read faq"
  on public.faq for select using (is_active = true);

create policy "Public read testimonials"
  on public.testimonials for select using (is_active = true);

create policy "Public read site_settings"
  on public.site_settings for select using (true);

-- ------------------------------------------------------------
-- POLÍTICA PARA CONTATOS (inserção pública, apenas se LGPD aceito)
-- ------------------------------------------------------------
create policy "Anyone can insert contact"
  on public.contacts for insert with check (consent_lgpd = true);

-- ------------------------------------------------------------
-- ALUNOS — leitura do próprio perfil
-- ------------------------------------------------------------
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

-- ------------------------------------------------------------
-- POLÍTICAS ADMIN — apenas usuários com role = 'admin'
-- ------------------------------------------------------------
create policy "Admin full access profiles"
  on public.profiles for all using (is_admin());

create policy "Admin full access professors"
  on public.professors for all using (is_admin());

create policy "Admin full access modalities"
  on public.modalities for all using (is_admin());

create policy "Admin full access class_schedules"
  on public.class_schedules for all using (is_admin());

create policy "Admin full access events"
  on public.events for all using (is_admin());

create policy "Admin full access news"
  on public.news for all using (is_admin());

create policy "Admin full access gallery"
  on public.gallery for all using (is_admin());

create policy "Admin full access documents"
  on public.documents for all using (is_admin());

create policy "Admin full access faq"
  on public.faq for all using (is_admin());

create policy "Admin full access testimonials"
  on public.testimonials for all using (is_admin());

create policy "Admin full access students"
  on public.students for all using (is_admin());

create policy "Admin full access graduations"
  on public.graduations for all using (is_admin());

create policy "Admin full access payments"
  on public.payments for all using (is_admin());

create policy "Admin full access attendance"
  on public.attendance for all using (is_admin());

create policy "Admin full access contacts"
  on public.contacts for all using (is_admin());

create policy "Admin full access site_settings"
  on public.site_settings for all using (is_admin());

-- ============================================================
-- DADOS INICIAIS — FAQ
-- ============================================================
insert into public.faq (question, answer, display_order) values
('A partir de qual idade posso começar?', 'Aceitamos alunos a partir de 4 anos de idade. Temos turmas específicas para cada faixa etária, garantindo um aprendizado adequado ao desenvolvimento de cada criança.', 1),
('Preciso ter experiência para fazer aula?', 'Não! Recebemos alunos de todos os níveis, do iniciante ao avançado. Nossas turmas são organizadas por nível, então você sempre estará em um ambiente adequado ao seu desenvolvimento.', 2),
('Posso fazer uma aula experimental?', 'Sim! Oferecemos aulas experimentais gratuitas. Entre em contato pelo WhatsApp para agendar o melhor dia para você.', 3),
('O Karatê é indicado para crianças?', 'Com certeza! O Karatê Kyokushin é excelente para crianças. Desenvolve disciplina, concentração, coordenação motora, autoconfiança e respeito — valores essenciais para a formação do caráter.', 4),
('O Karatê ajuda na disciplina?', 'Sim, é um dos principais benefícios. O Karatê ensina disciplina, respeito às regras, foco e autocontrole — habilidades que os alunos levam para todos os aspectos da vida.', 5),
('Quais roupas preciso usar no início?', 'Para as primeiras aulas, pode usar roupas confortáveis, como bermuda e camiseta. Após a matrícula, orientamos sobre a compra do kimono (gi) oficial.', 6),
('Como funcionam os exames de faixa?', 'Os exames de faixa são realizados periodicamente ao longo do ano. O professor avalia o progresso técnico e comportamental do aluno antes de indicá-lo para o exame. A evolução respeita o ritmo e dedicação de cada um.', 7),
('A academia participa de campeonatos?', 'Sim! Participamos de campeonatos regionais e estaduais de Karatê Kyokushin. A participação em competições é opcional e sempre incentivada para alunos que desejam evoluir no aspecto esportivo.', 8),
('Como faço a matrícula?', 'Entre em contato pelo WhatsApp (31) 98812-8515 para agendar uma visita ou aula experimental. Nossa equipe irá orientar sobre os documentos necessários e planos disponíveis.', 9);

-- ============================================================
-- DADOS INICIAIS — MODALIDADES
-- ============================================================
insert into public.modalities (title, description, target_audience, display_order) values
('Karatê Infantil',                'Turma especialmente desenvolvida para crianças de 4 a 10 anos. Foco em coordenação motora, disciplina, atenção e valores como respeito e responsabilidade.',                                      'infantil', 1),
('Karatê para Jovens',             'Para adolescentes de 11 a 17 anos. Desenvolvimento técnico, físico e emocional com metodologia adaptada à fase da juventude.',                                                                    'jovens',   2),
('Karatê Adulto',                  'Turmas para maiores de 18 anos, do iniciante ao avançado. Condicionamento físico, técnica, disciplina e desenvolvimento pessoal.',                                                               'adultos',  3),
('Treinamento para Competição',    'Preparação específica para atletas que desejam competir em campeonatos regionais e estaduais de Karatê Kyokushin.',                                                                               'todos',    4),
('Defesa Pessoal',                 'Técnicas práticas de defesa pessoal baseadas no Karatê Kyokushin. Indicado para todas as idades.',                                                                                               'todos',    5),
('Condicionamento Físico',         'Treinos focados em força, resistência, flexibilidade e agilidade através das técnicas do Karatê.',                                                                                               'adultos',  6),
('Preparação para Exames de Faixa','Treinos complementares para alunos se preparando para os exames de graduação.',                                                                                                                  'todos',    7),
('Aula Experimental',              'Venha conhecer a academia sem compromisso! Agende sua aula experimental gratuita.',                                                                                                              'todos',    8);

-- ============================================================
-- DADOS INICIAIS — HORÁRIOS DE AULA
-- day_of_week: 1=Segunda 2=Terça 3=Quarta 4=Quinta 5=Sexta 6=Sábado
-- ============================================================
insert into public.class_schedules
  (modality_name, day_of_week, start_time, end_time, target_audience, display_order)
values
  -- Infantil: Segunda, Quarta, Sexta
  ('Karatê Infantil', 1, '17:00', '18:00', 'infantil', 10),
  ('Karatê Infantil', 3, '17:00', '18:00', 'infantil', 11),
  ('Karatê Infantil', 5, '17:00', '18:00', 'infantil', 12),

  -- Jovens: Segunda, Quarta, Sexta
  ('Karatê para Jovens', 1, '18:00', '19:00', 'jovens', 20),
  ('Karatê para Jovens', 3, '18:00', '19:00', 'jovens', 21),
  ('Karatê para Jovens', 5, '18:00', '19:00', 'jovens', 22),

  -- Adulto: Segunda, Quarta, Sexta + Sábado
  ('Karatê Adulto', 1, '19:00', '20:30', 'adultos', 30),
  ('Karatê Adulto', 3, '19:00', '20:30', 'adultos', 31),
  ('Karatê Adulto', 5, '19:00', '20:30', 'adultos', 32),
  ('Karatê Adulto', 6, '08:00', '10:00', 'adultos', 33),

  -- Competição: Terça, Quinta + Sábado
  ('Treinamento para Competição', 2, '18:00', '20:00', 'todos', 40),
  ('Treinamento para Competição', 4, '18:00', '20:00', 'todos', 41),
  ('Treinamento para Competição', 6, '10:00', '12:00', 'todos', 42);

-- Vincula horários às modalidades pelo título
update public.class_schedules cs
set modality_id = m.id
from public.modalities m
where m.title = cs.modality_name;

-- ============================================================
-- DADOS INICIAIS — CONFIGURAÇÕES
-- ============================================================
insert into public.site_settings (key, value, description) values
('whatsapp_primary',    '5531988128515',                                          'WhatsApp principal da academia'),
('whatsapp_secondary',  '5531991921476',                                          'WhatsApp alternativo da academia'),
('instagram_url',       'https://www.instagram.com/karatemiyamotodamashiicaete',  'Instagram oficial'),
('academy_name',        'Karatê Miyamoto Damashii Caeté',                         'Nome oficial da academia'),
('academy_city',        'Caété/MG',                                               'Cidade da academia'),
('academy_address',     'Caeté/MG — endereço a confirmar',                        'Endereço completo da academia'),
('developer_name',      'HelpDigital BH',                                         'Nome do desenvolvedor'),
('developer_url',       'https://helpdigitalbh.com.br',                           'Site do desenvolvedor'),
('developer_whatsapp',  '5531991741488',                                          'WhatsApp do desenvolvedor'),
('developer_instagram', '@helpdigitalbh',                                         'Instagram do desenvolvedor');
