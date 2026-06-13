# Karatê Miyamoto Damashii Caeté — Site Institucional

Site institucional esportivo para a academia Karatê Miyamoto Damashii Caeté — escola de Karatê Kyokushin com mais de 20 anos de história em Caeté/MG.

## Stack

- **Frontend:** React + TypeScript + Vite + Tailwind CSS + shadcn/ui + Framer Motion
- **Backend:** Supabase (PostgreSQL + Auth + Storage + RLS)
- **Builder:** Lovable
- **Deploy:** Vercel / Netlify

## Páginas

| Rota | Descrição |
|---|---|
| `/` | Home com hero, stats, modalidades, horários, depoimentos, eventos e notícias |
| `/sobre` | História, missão, visão, valores e Kyokushin |
| `/modalidades` | Turmas disponíveis com CTA WhatsApp |
| `/horarios` | Grade semanal de aulas por turma e público-alvo |
| `/professores` | Professores ativos com faixa e bio |
| `/eventos` | Eventos públicos com filtros por categoria |
| `/noticias` | Blog com categorias e página de artigo |
| `/galeria` | Fotos e vídeos com lightbox e filtros |
| `/documentos` | Downloads de fichas, regulamentos e comunicados |
| `/perguntas-frequentes` | FAQ com accordion e busca |
| `/contato` | Formulário LGPD, mapa e canais de contato |
| `/privacidade` | Política de privacidade — base legal, direitos do titular, retenção (LGPD) |
| `/area-do-aluno` | Login → dashboard do aluno (faixa, frequência, mensalidades, graduações) |
| `/admin` | Painel admin — CRUD completo de todo o conteúdo, alunos, contatos e configurações |

## Banco de dados — Supabase

### Tabelas

| Tabela | Descrição |
|---|---|
| `profiles` | Perfis de usuário com `role` (`admin` \| `student`) |
| `professors` | Professores/senseis |
| `modalities` | Modalidades oferecidas |
| `class_schedules` | Horários semanais de aula |
| `events` | Eventos públicos |
| `news` | Notícias/blog |
| `gallery` | Fotos e vídeos |
| `documents` | Documentos para download |
| `faq` | Perguntas frequentes |
| `testimonials` | Depoimentos de alunos |
| `students` | Cadastro de alunos |
| `graduations` | Histórico de faixas por aluno |
| `payments` | Mensalidades |
| `attendance` | Frequência às aulas |
| `contacts` | Leads do formulário de contato |
| `site_settings` | Configurações editáveis (WhatsApp, Instagram, endereço) |

### Controle de acesso (RLS)

- **Visitante anônimo** — leitura de conteúdo público (professores, modalidades, horários, eventos, notícias, galeria, documentos, FAQ, depoimentos, configurações)
- **Aluno logado** (`profiles.role = 'student'`) — leitura dos próprios dados (students, payments, attendance, graduations)
- **Admin** (`profiles.role = 'admin'`) — acesso completo a todas as tabelas via função `is_admin()`

> Novos usuários são criados automaticamente com `role = 'student'` via trigger. Para promover um admin, altere `profiles.role` diretamente no Supabase Dashboard.

## Setup

### 1. Supabase

1. Crie um projeto em [supabase.com](https://supabase.com)
2. Acesse **SQL Editor** e execute o arquivo `supabase/schema.sql`
3. Copie a **Project URL** e a **anon key** em Settings > API

### 2. Variáveis de ambiente

```env
VITE_SUPABASE_URL=sua_project_url
VITE_SUPABASE_ANON_KEY=sua_anon_key
```

### 3. Lovable

1. Acesse [lovable.dev](https://lovable.dev)
2. Crie um novo projeto
3. Conecte este repositório GitHub
4. Cole o prompt do arquivo `LOVABLE_PROMPT.md`
5. Configure as variáveis de ambiente com as credenciais do Supabase

### 4. Criar primeiro admin

Após o primeiro login no site, acesse o Supabase Dashboard > Table Editor > `profiles` e altere `role` de `student` para `admin` no registro do seu usuário.

## Contatos da Academia

- WhatsApp principal: [+55 31 98812-8515](https://wa.me/5531988128515)
- WhatsApp alternativo: [+55 31 99192-1476](https://wa.me/5531991921476)
- Instagram: [@karatemiyamotodamashiicaete](https://www.instagram.com/karatemiyamotodamashiicaete)
- Localização: Caeté/MG

## Desenvolvido por

**HelpDigital BH**
[helpdigitalbh.com.br](https://helpdigitalbh.com.br) | [(31) 99174-1488](https://wa.me/5531991741488) | [@helpdigitalbh](https://instagram.com/helpdigitalbh)
