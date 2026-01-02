/*
  # Force Complete Schema Refresh
  
  This migration forces a complete schema refresh by:
  1. Temporarily disabling and re-enabling RLS
  2. Recreating foreign key constraints
  3. Forcing PostgREST cache invalidation
  4. Ensuring all tables are properly exposed
*/

-- Temporarily disable and re-enable RLS to force cache refresh
ALTER TABLE operators DISABLE ROW LEVEL SECURITY;
ALTER TABLE operators ENABLE ROW LEVEL SECURITY;

ALTER TABLE sales DISABLE ROW LEVEL SECURITY;
ALTER TABLE sales ENABLE ROW LEVEL SECURITY;

-- Ensure foreign key constraint is properly named and visible
ALTER TABLE sales 
  DROP CONSTRAINT IF EXISTS sales_operator_id_fkey CASCADE;

ALTER TABLE sales
  ADD CONSTRAINT sales_operator_id_fkey 
    FOREIGN KEY (operator_id) 
    REFERENCES operators(id) 
    ON DELETE SET NULL;

-- Create an index on the foreign key for better performance
DROP INDEX IF EXISTS idx_sales_operator_id;
CREATE INDEX idx_sales_operator_id ON sales(operator_id);

-- Force PostgREST reloads
SELECT pg_notify('pgrst', 'reload schema');
SELECT pg_notify('pgrst', 'reload config');
