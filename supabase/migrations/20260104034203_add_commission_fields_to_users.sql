/*
  # Adicionar Campos de Comissão à Tabela Users

  1. Alterações
    - Adiciona `commission_percentage` (decimal) à tabela `users`
      - Percentagem de comissão para utilizadores backoffice
      - Valor padrão: 0
    - Adiciona `commission_threshold` (decimal) à tabela `users`
      - Valor mínimo de comissões de operadoras para ativar comissão backoffice
      - Valor padrão: 0
    
  2. Notas
    - Estes campos são usados apenas para utilizadores do tipo 'backoffice'
    - A comissão backoffice é calculada como: (comissões operadoras visíveis) * (commission_percentage / 100)
    - A comissão só é aplicada se as comissões operadoras >= commission_threshold
*/

-- Add commission fields to users table
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' 
    AND table_name = 'users' 
    AND column_name = 'commission_percentage'
  ) THEN
    ALTER TABLE public.users 
    ADD COLUMN commission_percentage numeric(5,2) DEFAULT 0 NOT NULL;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' 
    AND table_name = 'users' 
    AND column_name = 'commission_threshold'
  ) THEN
    ALTER TABLE public.users 
    ADD COLUMN commission_threshold numeric(10,2) DEFAULT 0 NOT NULL;
  END IF;
END $$;