# PROMPT LOVABLE — Karatê Miyamoto Damashii Caeté

> Cole este prompt completo no Lovable para gerar o projeto.

---

## PROMPT

Create a complete, professional, modern, and responsive institutional sports website for **Karatê Miyamoto Damashii Caeté** academy — a Karate Kyokushin school with 20+ years of history located in Caeté, Minas Gerais, Brazil.

### TECH STACK
- React + TypeScript + Vite
- Tailwind CSS
- shadcn/ui components
- Supabase (backend, auth, storage)
- React Router DOM (SPA navigation)
- Lucide React (icons)
- Framer Motion (light animations)

---

### DESIGN SYSTEM

**Color Palette:**
- Primary: `#0a0a0a` (deep black)
- Secondary: `#c8102e` (martial arts red)
- Accent: `#d4af37` (gold/achievement)
- Background: `#0f0f0f`
- Surface: `#1a1a1a`
- Text primary: `#ffffff`
- Text secondary: `#a0a0a0`
- Border: `#2a2a2a`

**Typography:**
- Headings: Bold, strong, uppercase for hero elements
- Body: Clean, readable sans-serif
- Use font-size scale that respects mobile readability

**Visual Style:**
- Dark sports/martial arts aesthetic
- Strong geometric elements
- Red diagonal accent lines
- Gold trim for achievements and highlights
- Subtle noise texture on dark backgrounds
- Light entrance animations (fade-in-up, stagger children)
- No excessive animations — fast, clean, professional

---

### SITE STRUCTURE & PAGES

#### 1. LAYOUT (shared)
- **Sticky header** with logo left, navigation center/right, WhatsApp CTA button
- **Mobile hamburger menu** with full-screen overlay
- **Floating WhatsApp button** fixed bottom-right (primary number)
- **Footer** with links, social, developer credit

**Navigation items:**
Início | Sobre | Modalidades | Professores | Eventos | Galeria | Notícias | Documentos | FAQ | Contato | Área do Aluno

---

#### 2. HOME PAGE (`/`)

**Hero Section:**
- Full-viewport height
- Dark background with overlay gradient (black to transparent)
- Background: use a high-quality placeholder image or dark geometric pattern (martial arts themed)
- **H1:** "Karatê Miyamoto Damashii Caeté"
- **H2/subtitle:** "Tradição, disciplina e evolução através do Karatê Kyokushin."
- **CTA button primary:** "Falar no WhatsApp" → `https://wa.me/5531988128515?text=Olá,%20tenho%20interesse%20nas%20aulas%20de%20karatê%20da%20Miyamoto%20Damashii%20Caeté.`
- **CTA button secondary:** "Conheça a Academia" → scrolls to #sobre
- Red accent line or diagonal element on hero

**Stats Bar:**
- "20+ Anos de Tradição" | "Centenas de Alunos Formados" | "Kyokushin" | "Caeté/MG"

**About Teaser Section:**
- Two columns: text left, decorative element right
- Brief intro text about the academy
- "Saiba mais" button → /sobre

**Modalities Section:**
- Section title: "Nossas Modalidades"
- Grid of 4 cards (2x2 on mobile, 4x2 on desktop) loaded from Supabase `modalities` table
- Each card: icon, title, short description, "Tenho interesse" button → WhatsApp

**Benefits Section:**
- Title: "Benefícios do Karatê"
- Grid of icons + short text for 10 benefits:
  1. Melhora da disciplina
  2. Aumento da concentração
  3. Desenvolvimento da autoconfiança
  4. Melhora do condicionamento físico
  5. Coordenação motora
  6. Controle emocional
  7. Respeito às regras
  8. Trabalho em equipe
  9. Formação de caráter
  10. Superação de limites

**Testimonials Section:**
- Carousel/grid of testimonials from Supabase `testimonials` table
- Fallback: 3 placeholder testimonial cards

**Events Teaser:**
- "Próximos Eventos" — show next 3 events from Supabase
- "Ver todos os eventos" → /eventos

**News Teaser:**
- "Últimas Notícias" — show latest 3 published news from Supabase
- "Ver todas as notícias" → /noticias

**CTA Section:**
- Dark red background
- "Comece sua evolução hoje."
- "Agende uma aula experimental gratuita e descubra o poder do Karatê Kyokushin."
- Button: "Agendar Aula Experimental" → WhatsApp

---

#### 3. ABOUT PAGE (`/sobre`)

**Page Hero:** Title "Sobre a Academia" with breadcrumb

**Academy Story Section:**
- Rich text block with academy description
- "A Karatê Miyamoto Damashii Caeté é uma academia voltada à formação de alunos por meio do Karatê Kyokushin, unindo tradição, técnica, disciplina e desenvolvimento pessoal. Com mais de 20 anos de atuação..."
- Image placeholder (training photo)

**Mission/Vision/Values Section:**
Three cards side by side:
- **Missão:** "Promover o desenvolvimento físico, mental e emocional dos alunos por meio do Karatê Kyokushin, formando pessoas mais disciplinadas, confiantes e preparadas para os desafios da vida."
- **Visão:** "Ser referência regional no ensino do Karatê, na formação de atletas e no desenvolvimento humano por meio das artes marciais."
- **Valores:** Grid of value badges: Disciplina | Respeito | Honra | Superação | Foco | Família | Tradição | Compromisso | Ética | Evolução Contínua

**Karatê Kyokushin Info:**
- Brief explanation of Kyokushin style
- History and principles

---

#### 4. MODALITIES PAGE (`/modalidades`)

- Page hero with title
- Fetch all active modalities from Supabase `modalities` table
- Large cards with: icon, title, target audience badge, full description
- Each card has "Tenho interesse" button → WhatsApp with pre-filled text mentioning the modality

---

#### 5. PROFESSORS PAGE (`/professores`)

- Fetch from Supabase `professors` table where `is_active = true`
- Card layout: photo, name, belt badge (gold styling), experience years, bio, specialties tags
- If no records: show placeholder cards with "Informações do professor em breve."
- Ordered by `display_order`

---

#### 6. EVENTS PAGE (`/eventos`)

- Filter tabs: Todos | Exames de Faixa | Campeonatos | Seminários | Treinos Especiais | Aulas Abertas | Eventos Internos
- Fetch from Supabase `events` table where `is_public = true`
- Event cards: cover image, category badge, title, date (formatted pt-BR), location, short description
- "Saiba mais" button → event detail modal or `/eventos/:id`
- Empty state: "Nenhum evento cadastrado ainda. Fique atento às novidades!"

---

#### 7. NEWS PAGE (`/noticias`)

- Blog layout with featured post + grid
- Fetch from Supabase `news` table where `is_published = true`, ordered by `published_at DESC`
- Category filter: Todos | Campeonatos | Entrega de Faixas | Novas Turmas | Dicas | Eventos
- News card: cover image, category badge, title, summary, date, "Leia mais" → `/noticias/:slug`

**News Detail Page (`/noticias/:slug`):**
- Full article with cover image, title, author, date, content
- "Compartilhar no WhatsApp" button

---

#### 8. GALLERY PAGE (`/galeria`)

- Category filter tabs: Todos | Treinos | Campeonatos | Exames de Faixa | Eventos | Alunos | Professores
- Masonry or uniform grid layout
- Fetch from Supabase `gallery` table where `is_active = true`
- Lightbox on click for images
- Video thumbnails with play button overlay
- Empty state: placeholder grid with "Galeria em construção"
- Note: "Instagram integration coming soon"

---

#### 9. DOCUMENTS PAGE (`/documentos`)

- Fetch from Supabase `documents` table where `is_public = true`
- Category groups: Ficha de Matrícula | Regulamento Interno | Calendário | Exame de Faixa | Autorização | Comunicados
- Each document: icon (PDF/DOC), title, description, download button
- Empty state per category: "Documento em breve."

---

#### 10. FAQ PAGE (`/perguntas-frequentes`)

- Fetch from Supabase `faq` table where `is_active = true`, ordered by `display_order`
- Accordion component (one open at a time)
- Search filter input
- CTA at bottom: "Não encontrou sua dúvida?" → WhatsApp button

---

#### 11. CONTACT PAGE (`/contato`)

**Contact info card:**
- Name: Karatê Miyamoto Damashii Caeté
- Location: Caeté/MG
- WhatsApp: (31) 98812-8515 → link
- WhatsApp alternativo: (31) 99192-1476 → link
- Instagram: @karatemiyamotodamashiicaete → link

**Contact form:**
- Fields: Nome*, Email, Telefone*, Mensagem*, Modalidade de interesse (select)
- On submit: INSERT into Supabase `contacts` table
- Success toast: "Mensagem enviada! Entraremos em contato em breve."

**Google Maps embed:**
- Embed map for "Caeté, MG" (address placeholder — editable in settings)

---

#### 12. STUDENT AREA (`/area-do-aluno`)

- Current state: "Área em Desenvolvimento"
- Show a professional coming-soon card
- List features coming:
  - Dados do aluno e graduação
  - Controle de frequência
  - Próximos exames de faixa
  - Situação de mensalidades
  - Comunicados e documentos
  - Histórico de evolução
- CTA button: "Fale conosco pelo WhatsApp" → WhatsApp

---

### SUPABASE INTEGRATION

Connect to Supabase using environment variables:
- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_ANON_KEY`

Create a `src/lib/supabase.ts` client file.

Create typed hooks/queries for each table using Supabase's generated types.

All public-facing data fetches use the anon key with RLS policies already configured.

---

### SEO

In `index.html` and per-page meta tags:
- **Title:** "Karatê Miyamoto Damashii Caeté | Karatê Kyokushin em Caeté/MG"
- **Description:** "Academia Karatê Miyamoto Damashii Caeté. Aulas de Karatê Kyokushin para crianças, jovens e adultos. Disciplina, respeito, defesa pessoal, competição e desenvolvimento humano em Caeté/MG."
- **Keywords:** karatê em Caeté, karatê kyokushin Caeté, academia de karatê Caeté, aula de karatê infantil Caeté, artes marciais Caeté, Miyamoto Damashii Caeté
- Open Graph tags for social sharing

---

### WHATSAPP LINKS

Primary: `https://wa.me/5531988128515?text=Olá,%20tenho%20interesse%20nas%20aulas%20de%20karatê%20da%20Miyamoto%20Damashii%20Caeté.`
Secondary: `https://wa.me/5531991921476?text=Olá,%20tenho%20interesse%20nas%20aulas%20de%20karatê%20da%20Miyamoto%20Damashii%20Caeté.`

---

### FLOATING WHATSAPP BUTTON

Fixed position, bottom-right corner, z-index high.
Pulse animation.
Opens primary WhatsApp link.
Show/hide based on scroll position (show after 100px scroll).

---

### FOOTER

```
Karatê Miyamoto Damashii Caeté
Tradição, disciplina e evolução através do Karatê Kyokushin.

Quick links: Início | Sobre | Modalidades | Eventos | Galeria | Contato

Instagram: @karatemiyamotodamashiicaete
WhatsApp: (31) 98812-8515

Desenvolvido por HelpDigital BH
helpdigitalbh.com.br | (31) 99174-1488 | @helpdigitalbh
```

---

### IMPORTANT NOTES

- All text content is in Brazilian Portuguese
- Dates formatted as DD/MM/YYYY
- Phone numbers formatted as (31) XXXXX-XXXX
- Use `loading` skeletons while fetching data
- Use `toast` for form submissions and errors
- Mobile-first responsive design
- All images should have proper alt text
- Keyboard navigation accessible
- No Lorem Ipsum — use placeholder content related to the academy

---

### PHRASES TO USE THROUGHOUT THE SITE

- "Mais que uma luta, uma formação para a vida."
- "Disciplina, respeito e superação em cada treino."
- "Comece sua evolução hoje."
- "Agende uma aula experimental gratuita."
- "20 anos formando campeões dentro e fora do tatame."
- "OSS!" (traditional Kyokushin greeting — use tastefully)
