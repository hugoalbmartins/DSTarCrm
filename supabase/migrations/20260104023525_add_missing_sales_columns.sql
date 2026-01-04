/*
  # Add missing columns to sales table

  ## Problem
  The frontend sale form expects several columns that don't exist in the sales table:
  - sale_type: Type of sale (nova_instalacao, refid)
  - energy_type: Type of energy for energia sales (eletricidade, gas, dual)
  - cpe: CPE code for electricity
  - potencia: Power rating for electricity
  - cui: CUI code for gas
  - escalao: Gas tier
  - loyalty_months: Contract loyalty period in months

  ## Changes
  1. Add all missing columns to the sales table
  2. All new columns are nullable to support different sale categories
  3. Add check constraints where appropriate

  ## Notes
  - These fields are only relevant for specific sale categories
  - Energy fields (cpe, potencia, cui, escalao) are only for "energia" category
  - sale_type is for "energia" and "telecomunicacoes" categories
  - loyalty_months applies to all categories
*/

-- Add sale_type column
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' 
      AND table_name = 'sales' 
      AND column_name = 'sale_type'
  ) THEN
    ALTER TABLE public.sales 
    ADD COLUMN sale_type text;
    
    ALTER TABLE public.sales 
    ADD CONSTRAINT sales_sale_type_check 
    CHECK (sale_type IS NULL OR sale_type IN ('nova_instalacao', 'refid'));
  END IF;
END $$;

-- Add energy_type column
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' 
      AND table_name = 'sales' 
      AND column_name = 'energy_type'
  ) THEN
    ALTER TABLE public.sales 
    ADD COLUMN energy_type text;
    
    ALTER TABLE public.sales 
    ADD CONSTRAINT sales_energy_type_check 
    CHECK (energy_type IS NULL OR energy_type IN ('eletricidade', 'gas', 'dual'));
  END IF;
END $$;

-- Add cpe column (electricity code)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' 
      AND table_name = 'sales' 
      AND column_name = 'cpe'
  ) THEN
    ALTER TABLE public.sales 
    ADD COLUMN cpe text;
  END IF;
END $$;

-- Add potencia column (electricity power rating)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' 
      AND table_name = 'sales' 
      AND column_name = 'potencia'
  ) THEN
    ALTER TABLE public.sales 
    ADD COLUMN potencia text;
  END IF;
END $$;

-- Add cui column (gas code)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' 
      AND table_name = 'sales' 
      AND column_name = 'cui'
  ) THEN
    ALTER TABLE public.sales 
    ADD COLUMN cui text;
  END IF;
END $$;

-- Add escalao column (gas tier)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' 
      AND table_name = 'sales' 
      AND column_name = 'escalao'
  ) THEN
    ALTER TABLE public.sales 
    ADD COLUMN escalao text;
  END IF;
END $$;

-- Add loyalty_months column
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' 
      AND table_name = 'sales' 
      AND column_name = 'loyalty_months'
  ) THEN
    ALTER TABLE public.sales 
    ADD COLUMN loyalty_months integer DEFAULT 0;
  END IF;
END $$;

-- Create index for better query performance on sale_type
CREATE INDEX IF NOT EXISTS idx_sales_sale_type ON public.sales(sale_type);

-- Create index for better query performance on category
CREATE INDEX IF NOT EXISTS idx_sales_category ON public.sales(category);
