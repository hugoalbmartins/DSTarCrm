/*
  # Data Cleanup and Cascade Delete Configuration

  1. Purpose
    - Clean all data except admin@leiritrix.com user
    - Configure CASCADE deletes so related data is automatically cleaned when records are deleted

  2. Data Cleanup
    - Delete all partners (CASCADE will delete partner_operators)
    - Delete all operators (CASCADE will delete partner_operators and set sales.operator_id to NULL)
    - Keep only admin@leiritrix.com user

  3. Cascade Configuration Changes
    - sales.seller_id: Change from SET NULL to CASCADE (when user deleted, delete their sales)
    - sales.partner_id: Change from SET NULL to CASCADE (when partner deleted, delete related sales)
    - sales.operator_id: Keep as SET NULL (preserve sales history when operator deleted)

  4. Security
    - Ensures clean data deletion
    - Maintains referential integrity
*/

-- Step 1: Delete all partners (this will CASCADE to partner_operators)
DELETE FROM partners;

-- Step 2: Delete all operators (this will CASCADE to partner_operators)
DELETE FROM operators;

-- Step 3: Delete all users except admin
DELETE FROM users WHERE email != 'admin@leiritrix.com';

-- Step 4: Update foreign key constraints to CASCADE properly

-- Drop existing constraints on sales table
ALTER TABLE sales DROP CONSTRAINT IF EXISTS sales_seller_id_fkey;
ALTER TABLE sales DROP CONSTRAINT IF EXISTS sales_partner_id_fkey;

-- Recreate constraints with CASCADE behavior
ALTER TABLE sales
  ADD CONSTRAINT sales_seller_id_fkey
  FOREIGN KEY (seller_id)
  REFERENCES users(id)
  ON DELETE CASCADE;

ALTER TABLE sales
  ADD CONSTRAINT sales_partner_id_fkey
  FOREIGN KEY (partner_id)
  REFERENCES partners(id)
  ON DELETE CASCADE;

-- Note: sales.operator_id remains SET NULL to preserve sales history
