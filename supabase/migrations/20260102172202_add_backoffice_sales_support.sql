/*
  # Adicionar Suporte para Vendas de Backoffice

  1. Alterações na Tabela `sales`
    - Adicionar coluna `is_backoffice` (boolean) - Identifica se a venda é do backoffice
    - Adicionar coluna `commission_backoffice` (numeric) - Comissão total para vendas do backoffice
    
  2. Notas
    - Por padrão, todas as vendas existentes são de vendedor (is_backoffice = false)
    - commission_backoffice será NULL para vendas de vendedor
    - Quando is_backoffice = true, seller_id deve ser NULL
*/

-- Add is_backoffice column
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'sales' AND column_name = 'is_backoffice'
  ) THEN
    ALTER TABLE sales ADD COLUMN is_backoffice boolean NOT NULL DEFAULT false;
  END IF;
END $$;

-- Add commission_backoffice column
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'sales' AND column_name = 'commission_backoffice'
  ) THEN
    ALTER TABLE sales ADD COLUMN commission_backoffice numeric DEFAULT 0;
  END IF;
END $$;

-- Add comment for clarity
COMMENT ON COLUMN sales.is_backoffice IS 'Indica se a venda foi feita pelo backoffice (true) ou por um vendedor (false)';
COMMENT ON COLUMN sales.commission_backoffice IS 'Comissão total para vendas do backoffice. NULL para vendas de vendedor.';