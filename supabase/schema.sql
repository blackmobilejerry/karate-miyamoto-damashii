-- ============================================================
-- SCHEMA SUPABASE — Karatê Miyamoto Damashii Caeté
-- ============================================================

-- EXTENSÕES
create extension if not exists "uuid-ossp";

-- ============================================================
-- PROFESSORES / SENSEIS
-- ============================================================
create table public.professors (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  belt text not null,               -- ex: "Faixa Preta 5º Dan"
  experience_years integer,
  bio text,
  specialties text[],               -- array de especialidades
  photo_url text,
  is_active boolean default true,
  display_order integer default 0,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- ============================================================
-- MODALIDADES
-- ============================================================
create table public.modalities (
  id uuid primary key default uuid_generate_v4(),
  title text not null,
  description text,
  icon text,                        -- nome do ícone lucide/heroicons
  target_audience text,             -- "infantil", "jovens", "adultos", "todos"
  is_active boolean default true,
  display_order integer default 0,
  created_at timestamptz default now()
);

-- ============================================================
-- EVENTOS
-- ============================================================
create table public.events (
  id uuid primary key default uuid_generate_v4(),
  title text not null,
  description text,
  category text not null,           -- 'exame_faixa','campeonato','seminario','treino_especial','aula_aberta','interno'
  event_date date not null,
  event_time time,
  location text,
  address text,
  image_url text,
  is_public boolean default true,
  registration_link text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- ============================================================
-- NOTÍCIAS / BLOG
-- ============================================================
create table public.news (
  id uuid primary key default uuid_generate_v4(),
  title text not null,
  slug text unique not null,
  summary text,
  content text,
  cover_image_url text,
  category text,                    -- 'campeonato','entrega_faixa','novas_turmas','dicas','eventos','geral'
  author text default 'Redação',
  is_published boolean default false,
  published_at timestamptz,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- ============================================================
-- GALERIA
-- ============================================================
create table public.gallery (
  id uuid primary key default uuid_generate_v4(),
  title text,
  description text,
  media_url text not null,
  media_type text default 'image',  -- 'image' ou 'video'
  category text,                    -- 'treinos','campeonatos','exames','eventos','alunos','professores'
  thumbnail_url text,
  is_active boolean default true,
  display_order integer default 0,
  created_at timestamptz default now()
);

-- ============================================================
-- DOCUMENTOS
-- ============================================================
create table public.documents (
  id uuid primary key default uuid_generate_v4(),
  title text not null,
  description text,
  file_url text not null,
  category text,                    -- 'matricula','regulamento','calendario','exame_faixa','autorizacao','comunicado'
  is_public boolean default true,
  display_order integer default 0,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- ============================================================
-- FAQ
-- ============================================================
create table public.faq (
  id uuid primary key default uuid_generate_v4(),
  question text not null,
  answer text not null,
  category text default 'geral',
  display_order integer default 0,
  is_active boolean default true,
  created_at timestamptz default now()
);

-- ============================================================
-- DEPOIMENTOS / TESTIMONIALS
-- ============================================================
create table public.testimonials (
  id uuid primary key default uuid_generate_v4(),
  author_name text not null,
  author_role text,                 -- ex: "Mãe de aluno", "Aluno faixa verde"
  content text not null,
  photo_url text,
  rating integer check (rating between 1 and 5),
  is_active boolean default true,
  display_order integer default 0,
  created_at timestamptz default now()
);

-- ============================================================
-- ALUNOS (área do aluno — fase 2)
-- ============================================================
create table public.students (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references auth.users(id) on delete cascade,
  full_name text not null,
  birth_date date,
  cpf text,
  phone text,
  guardian_name text,              -- responsável para menores
  guardian_phone text,
  belt text default 'Branca',
  enrollment_date date default current_date,
  is_active boolean default true,
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- ============================================================
-- MENSALIDADES
-- ============================================================
create table public.payments (
  id uuid primary key default uuid_generate_v4(),
  student_id uuid references public.students(id) on delete cascade,
  reference_month date not null,   -- primeiro dia do mês de referência
  amount decimal(10,2) not null,
  status text default 'pendente',  -- 'pendente','pago','atrasado','isento'
  payment_date date,
  notes text,
  created_at timestamptz default now()
);

-- ============================================================
-- FREQUÊNCIA
-- ============================================================
create table public.attendance (
  id uuid primary key default uuid_generate_v4(),
  student_id uuid references public.students(id) on delete cascade,
  class_date date not null,
  present boolean default true,
  notes text,
  created_at timestamptz default now()
);

-- ============================================================
-- CONTATO / LEADS
-- ============================================================
create table public.contacts (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  email text,
  phone text,
  message text,
  interest text,                   -- modalidade de interesse
  source text default 'site',
  is_read boolean default false,
  created_at timestamptz default now()
);

-- ============================================================
-- CONFIGURAÇÕES DO SITE
-- ============================================================
create table public.site_settings (
  id uuid primary key default uuid_generate_v4(),
  key text unique not null,
  value text,
  description text,
  updated_at timestamptz default now()
);

-- ============================================================
-- RLS (Row Level Security)
-- ============================================================

-- Habilitar RLS em todas as tabelas
alter table public.professors enable row level security;
alter table public.modalities enable row level security;
alter table public.events enable row level security;
alter table public.news enable row level security;
alter table public.gallery enable row level security;
alter table public.documents enable row level security;
alter table public.faq enable row level security;
alter table public.testimonials enable row level security;
alter table public.students enable row level security;
alter table public.payments enable row level security;
alter table public.attendance enable row level security;
alter table public.contacts enable row level security;
alter table public.site_settings enable row level security;

-- POLÍTICAS PÚBLICAS (leitura sem autenticação)
create policy "Public read professors" on public.professors for select using (is_active = true);
create policy "Public read modalities" on public.modalities for select using (is_active = true);
create policy "Public read events" on public.events for select using (is_public = true);
create policy "Public read news" on public.news for select using (is_published = true);
create policy "Public read gallery" on public.gallery for select using (is_active = true);
create policy "Public read documents" on public.documents for select using (is_public = true);
create policy "Public read faq" on public.faq for select using (is_active = true);
create policy "Public read testimonials" on public.testimonials for select using (is_active = true);
create policy "Public read site_settings" on public.site_settings for select using (true);

-- POLÍTICA PARA CONTATOS (inserção pública)
create policy "Anyone can insert contact" on public.contacts for insert with check (true);

-- POLÍTICAS ADMIN (autenticados podem tudo)
create policy "Authenticated full access professors" on public.professors for all using (auth.role() = 'authenticated');
create policy "Authenticated full access modalities" on public.modalities for all using (auth.role() = 'authenticated');
create policy "Authenticated full access events" on public.events for all using (auth.role() = 'authenticated');
create policy "Authenticated full access news" on public.news for all using (auth.role() = 'authenticated');
create policy "Authenticated full access gallery" on public.gallery for all using (auth.role() = 'authenticated');
create policy "Authenticated full access documents" on public.documents for all using (auth.role() = 'authenticated');
create policy "Authenticated full access faq" on public.faq for all using (auth.role() = 'authenticated');
create policy "Authenticated full access testimonials" on public.testimonials for all using (auth.role() = 'authenticated');
create policy "Authenticated full access students" on public.students for all using (auth.role() = 'authenticated');
create policy "Authenticated full access payments" on public.payments for all using (auth.role() = 'authenticated');
create policy "Authenticated full access attendance" on public.attendance for all using (auth.role() = 'authenticated');
create policy "Authenticated full access contacts" on public.contacts for all using (auth.role() = 'authenticated');
create policy "Authenticated full access site_settings" on public.site_settings for all using (auth.role() = 'authenticated');

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
('Karatê Infantil', 'Turma especialmente desenvolvida para crianças de 4 a 10 anos. Foco em coordenação motora, disciplina, atenção e valores como respeito e responsabilidade.', 'infantil', 1),
('Karatê para Jovens', 'Para adolescentes de 11 a 17 anos. Desenvolvimento técnico, físico e emocional com metodologia adaptada à fase da juventude.', 'jovens', 2),
('Karatê Adulto', 'Turmas para maiores de 18 anos, do iniciante ao avançado. Condicionamento físico, técnica, disciplina e desenvolvimento pessoal.', 'adultos', 3),
('Treinamento para Competição', 'Preparação específica para atletas que desejam competir em campeonatos regionais e estaduais de Karatê Kyokushin.', 'todos', 4),
('Defesa Pessoal', 'Técnicas práticas de defesa pessoal baseadas no Karatê Kyokushin. Indicado para todas as idades.', 'todos', 5),
('Condicionamento Físico', 'Treinos focados em força, resistência, flexibilidade e agilidade através das técnicas do Karatê.', 'adultos', 6),
('Preparação para Exames de Faixa', 'Treinos complementares para alunos se preparando para os exames de graduação.', 'todos', 7),
('Aula Experimental', 'Venha conhecer a academia sem compromisso! Agende sua aula experimental gratuita.', 'todos', 8);

-- ============================================================
-- DADOS INICIAIS — CONFIGURAÇÕES
-- ============================================================
insert into public.site_settings (key, value, description) values
('whatsapp_primary', '5531988128515', 'WhatsApp principal da academia'),
('whatsapp_secondary', '5531991921476', 'WhatsApp alternativo da academia'),
('instagram_url', 'https://www.instagram.com/karatemiyamotodamashiicaete', 'Instagram oficial'),
('academy_name', 'Karatê Miyamoto Damashii Caeté', 'Nome oficial da academia'),
('academy_city', 'Caeté/MG', 'Cidade da academia'),
('developer_name', 'HelpDigital BH', 'Nome do desenvolvedor'),
('developer_url', 'https://helpdigitalbh.com.br', 'Site do desenvolvedor'),
('developer_whatsapp', '5531991741488', 'WhatsApp do desenvolvedor'),
('developer_instagram', '@helpdigitalbh', 'Instagram do desenvolvedor');
