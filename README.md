# Leiritrix CRM

Sistema de gestão de vendas para parceiros Leiritrix.

## Funcionalidades

- Dashboard com métricas e estatísticas
- Gestão de vendas (criar, editar, visualizar)
- Gestão de parceiros
- Gestão de utilizadores (apenas Admin)
- Relatórios e exportação de dados
- Sistema de alertas de fidelização
- Autenticação segura com Supabase Auth
- Row Level Security (RLS) para proteção de dados

## Tecnologias

- Frontend: React 18, Vite, React Router, Tailwind CSS, shadcn/ui
- Backend: Supabase (PostgreSQL, Auth, RLS)
- Build: Vite (rápido e otimizado)

## Estrutura de Pastas

```
frontend/
├── src/
│   ├── components/     # Componentes UI (shadcn/ui)
│   ├── pages/          # Páginas da aplicação
│   ├── services/       # Serviços de integração Supabase
│   ├── lib/            # Configuração Supabase
│   └── hooks/          # Custom hooks
├── public/
└── package.json
```

## Como Executar

### Instalação

```bash
cd frontend
npm install
```

### Desenvolvimento

```bash
npm run dev
```

O frontend executa em http://localhost:3000

### Build de Produção

```bash
npm run build
```

## Configuração Supabase

As variáveis de ambiente já estão configuradas no ficheiro `.env`:

- `VITE_SUPABASE_URL`: URL do projeto Supabase
- `VITE_SUPABASE_ANON_KEY`: Chave pública do Supabase

## Base de Dados

O sistema utiliza PostgreSQL através do Supabase com as seguintes tabelas:

- `users`: Utilizadores do sistema
- `partners`: Parceiros comerciais
- `sales`: Registos de vendas

Todas as tabelas têm Row Level Security (RLS) ativado para garantir segurança dos dados.

## Deploy no Vercel

### Passo 1: Push do Código para o Git

Certifique-se de que o código está num repositório Git (GitHub, GitLab ou Bitbucket).

### Passo 2: Importar Projeto no Vercel

1. Aceda a [vercel.com](https://vercel.com)
2. Clique em "New Project"
3. Importe o seu repositório
4. O Vercel detectará automaticamente as configurações do `vercel.json`

### Passo 3: Configurar Variáveis de Ambiente

No dashboard do Vercel, adicione as seguintes variáveis de ambiente:

```
VITE_SUPABASE_URL=https://kzvzjrgmqneqygwfihzw.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt6dnpqcmdtcW5lcXlnd2ZpaHp3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjczNTQ5NjAsImV4cCI6MjA4MjkzMDk2MH0.jTpjTMRtI1mM9eNrKTnLXeVKWEtkUFji_h7HAJyp4HI
```

**Importante:** Estas variáveis devem ser adicionadas na secção "Environment Variables" do projeto no Vercel.

### Passo 4: Deploy

Clique em "Deploy" e aguarde a conclusão do build. O Vercel executará automaticamente:
1. `npm install` na pasta frontend
2. `npm run build` para gerar a build de produção
3. Deploy dos ficheiros estáticos

### Notas Importantes

- O `vercel.json` está configurado para redirecionar todas as rotas para `/index.html` (necessário para o React Router)
- As variáveis de ambiente devem ser prefixadas com `VITE_` para serem acessíveis no código frontend
- Após o primeiro deploy, todos os pushes para a branch principal acionarão um deploy automático

## Credenciais de Acesso

**Administrador:**
- Email: admin@leiritrix.com
- Password: Admin123!@#

Este utilizador tem acesso total ao sistema incluindo gestão de utilizadores e parceiros.
