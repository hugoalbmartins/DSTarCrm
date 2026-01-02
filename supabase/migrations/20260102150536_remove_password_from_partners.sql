/*
  # Remove Password Fields from Partners Table

  1. Purpose
    - Partners are business entities, not user accounts
    - Remove authentication-related fields that don't belong
    - Add contact_person field that is actually needed

  2. Changes
    - Remove password column
    - Remove must_change_password column
    - Add contact_person column for storing contact name

  3. Security
    - No authentication logic needed for partners
    - Partners table is for business records only
*/

-- Add contact_person column if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'partners' AND column_name = 'contact_person'
  ) THEN
    ALTER TABLE partners ADD COLUMN contact_person text;
  END IF;
END $$;

-- Remove password-related columns
ALTER TABLE partners DROP COLUMN IF EXISTS password;
ALTER TABLE partners DROP COLUMN IF EXISTS must_change_password;
