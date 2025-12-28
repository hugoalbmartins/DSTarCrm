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

- Frontend: React 19, React Router, Tailwind CSS, shadcn/ui
- Backend: Supabase (PostgreSQL, Auth, RLS)
- Build: Create React App com CRACO

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
npm install --legacy-peer-deps
```

### Desenvolvimento

```bash
npm start
```

O frontend executa em http://localhost:3000

### Build de Produção

```bash
npm run build
```

## Configuração Supabase

As variáveis de ambiente já estão configuradas no ficheiro `.env`:

- `REACT_APP_SUPABASE_URL`: URL do projeto Supabase
- `REACT_APP_SUPABASE_ANON_KEY`: Chave pública do Supabase

## Base de Dados

O sistema utiliza PostgreSQL através do Supabase com as seguintes tabelas:

- `users`: Utilizadores do sistema
- `partners`: Parceiros comerciais
- `sales`: Registos de vendas

Todas as tabelas têm Row Level Security (RLS) ativado para garantir segurança dos dados.

## Credenciais de Acesso

**Administrador:**
- Email: admin@leiritrix.pt
- Password: admin123

Este utilizador tem acesso total ao sistema incluindo gestão de utilizadores e parceiros.
