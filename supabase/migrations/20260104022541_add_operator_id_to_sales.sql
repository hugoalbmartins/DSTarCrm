/*
  # Add operator_id to sales table

  ## Problem
  The frontend expects to query sales with a direct relationship to operators through operator_id,
  but the sales table is missing this column.

  ## Changes
  1. Add operator_id column to sales table
  2. Add foreign key constraint to operators table
  3. Update sale_operators data to match (if needed)
*/

-- Add operator_id column to sales table
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'sales'
      AND column_name = 'operator_id'
  ) THEN
    ALTER TABLE public.sales ADD COLUMN operator_id uuid;
  END IF;
END $$;

-- Add foreign key constraint
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_schema = 'public'
      AND table_name = 'sales'
      AND constraint_name = 'sales_operator_id_fkey'
  ) THEN
    ALTER TABLE public.sales
      ADD CONSTRAINT sales_operator_id_fkey
      FOREIGN KEY (operator_id)
      REFERENCES public.operators(id)
      ON DELETE SET NULL;
  END IF;
END $$;
