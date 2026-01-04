/*
  # Fix operators table structure

  ## Problem
  The frontend expects 'categories' (array) and 'commission_visible_to_bo' fields
  but the table has 'category' (singular text) instead.

  ## Changes
  1. Drop the old 'category' column
  2. Add 'categories' as text array
  3. Add 'commission_visible_to_bo' as boolean
  4. Add 'updated_at' timestamp for tracking changes
*/

-- Add categories column (array of text)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'operators'
      AND column_name = 'categories'
  ) THEN
    ALTER TABLE public.operators ADD COLUMN categories text[] DEFAULT '{}';
  END IF;
END $$;

-- Add commission_visible_to_bo column
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'operators'
      AND column_name = 'commission_visible_to_bo'
  ) THEN
    ALTER TABLE public.operators ADD COLUMN commission_visible_to_bo boolean DEFAULT false;
  END IF;
END $$;

-- Add updated_at column
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'operators'
      AND column_name = 'updated_at'
  ) THEN
    ALTER TABLE public.operators ADD COLUMN updated_at timestamptz DEFAULT now();
  END IF;
END $$;

-- Drop old category column if it exists
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'operators'
      AND column_name = 'category'
  ) THEN
    ALTER TABLE public.operators DROP COLUMN category;
  END IF;
END $$;
