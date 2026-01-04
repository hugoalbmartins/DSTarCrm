/*
  # Add contact_person column to partners table

  ## Problem
  The frontend is trying to insert/update a 'contact_person' field but the column doesn't exist.

  ## Solution
  Add the missing column to the partners table.

  ## Changes
  - Add contact_person column to partners table
*/

-- Add contact_person column if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'partners'
      AND column_name = 'contact_person'
  ) THEN
    ALTER TABLE public.partners ADD COLUMN contact_person text;
  END IF;
END $$;
