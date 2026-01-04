/*
  # Add Mudança de Casa sale type and service selection

  ## Changes
  1. Add new sale type "mudanca_casa" (house move)
  2. Add service selection fields for sales:
     - services_tv: TV service activated
     - services_net: Internet service activated
     - services_lr: Landline (Linha Rede) service activated
     - services_moveis_count: Number of mobile lines (0-5)
  3. Add allowed sale types field to operators table:
     - allowed_sale_types: Array of allowed sale types per operator

  ## Notes
  - Services are only applicable to telecomunicacoes category
  - Services apply to nova_instalacao and mudanca_casa types
  - Operators can restrict which sale types they support
*/

-- Add service fields to sales table
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' 
      AND table_name = 'sales' 
      AND column_name = 'services_tv'
  ) THEN
    ALTER TABLE public.sales 
    ADD COLUMN services_tv boolean DEFAULT false;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' 
      AND table_name = 'sales' 
      AND column_name = 'services_net'
  ) THEN
    ALTER TABLE public.sales 
    ADD COLUMN services_net boolean DEFAULT false;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' 
      AND table_name = 'sales' 
      AND column_name = 'services_lr'
  ) THEN
    ALTER TABLE public.sales 
    ADD COLUMN services_lr boolean DEFAULT false;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' 
      AND table_name = 'sales' 
      AND column_name = 'services_moveis_count'
  ) THEN
    ALTER TABLE public.sales 
    ADD COLUMN services_moveis_count integer DEFAULT 0 CHECK (services_moveis_count >= 0 AND services_moveis_count <= 5);
  END IF;
END $$;

-- Add allowed_sale_types to operators table
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' 
      AND table_name = 'operators' 
      AND column_name = 'allowed_sale_types'
  ) THEN
    ALTER TABLE public.operators 
    ADD COLUMN allowed_sale_types text[] DEFAULT ARRAY['nova_instalacao', 'refid', 'mudanca_casa']::text[];
  END IF;
END $$;

-- Add comment to explain sale types
COMMENT ON COLUMN public.operators.allowed_sale_types IS 'Array of allowed sale types: nova_instalacao, refid, mudanca_casa';

-- Create index for service fields
CREATE INDEX IF NOT EXISTS idx_sales_services ON public.sales(services_tv, services_net, services_lr, services_moveis_count) 
WHERE category = 'telecomunicacoes';
