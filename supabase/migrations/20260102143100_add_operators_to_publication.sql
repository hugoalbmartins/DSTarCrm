/*
  # Add operators table to Supabase publications
  
  This migration adds the operators table to the necessary publications
  so that PostgREST can properly expose it via the REST API.
  
  1. Changes
    - Add operators table to supabase_realtime publication if it exists
    - Ensure table is visible to PostgREST API
*/

-- Add operators to supabase_realtime publication if it exists
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE operators;
  END IF;
END $$;

-- Add a comment to trigger schema reload
COMMENT ON TABLE operators IS 'Operators/service providers available in the system';

-- Force PostgREST to reload
NOTIFY pgrst, 'reload schema';
