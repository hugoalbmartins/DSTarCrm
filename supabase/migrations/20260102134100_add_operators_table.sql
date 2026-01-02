/*
  # Create Operators Table and Add to Sales
  
  ## Overview
  This migration creates a new operators (operadoras) system that allows partners to have 
  multiple operators, with control over commission visibility for backoffice users.
  
  ## 1. New Tables
  
  ### `operators`
  - `id` (uuid, primary key) - Unique identifier for the operator
  - `name` (text, NOT NULL) - Name of the operator
  - `partner_id` (uuid, FK to partners, NOT NULL) - Partner that owns this operator
  - `commission_visible_to_bo` (boolean, default false) - Controls if backoffice can see commissions
  - `active` (boolean, default true) - Whether the operator is active
  - `created_at` (timestamptz) - When the operator was created
  - `updated_at` (timestamptz) - Last update timestamp
  
  ## 2. Sales Table Changes
  - Add `operator_id` (uuid, FK to operators, nullable) - Links sale to an operator
  
  ## 3. Security (RLS Policies)
  
  ### Operators Table
  - Admins can perform all operations (SELECT, INSERT, UPDATE, DELETE)
  - Partners can only view their own operators
  - Backoffice users can view all operators
  
  ## 4. Important Notes
  - A partner can have multiple operators
  - Commission visibility is controlled at the operator level
  - If `commission_visible_to_bo = false`, backoffice users cannot see commission values
  - Existing sales will have null operator_id (can be updated later)
  - Indexes are created for performance optimization
*/

-- Create operators table
CREATE TABLE IF NOT EXISTS operators (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  partner_id uuid NOT NULL REFERENCES partners(id) ON DELETE CASCADE,
  commission_visible_to_bo boolean DEFAULT false NOT NULL,
  active boolean DEFAULT true NOT NULL,
  created_at timestamptz DEFAULT now() NOT NULL,
  updated_at timestamptz DEFAULT now() NOT NULL
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_operators_partner_id ON operators(partner_id);
CREATE INDEX IF NOT EXISTS idx_operators_active ON operators(active);

-- Add operator_id to sales table
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'sales' AND column_name = 'operator_id'
  ) THEN
    ALTER TABLE sales ADD COLUMN operator_id uuid REFERENCES operators(id) ON DELETE SET NULL;
  END IF;
END $$;

-- Create index for sales operator_id
CREATE INDEX IF NOT EXISTS idx_sales_operator_id ON sales(operator_id);

-- Enable RLS on operators table
ALTER TABLE operators ENABLE ROW LEVEL SECURITY;

-- RLS Policies for operators

-- Admins can view all operators
CREATE POLICY "Admins can view all operators"
  ON operators FOR SELECT
  TO authenticated
  USING (is_admin());

-- Admins can insert operators
CREATE POLICY "Admins can insert operators"
  ON operators FOR INSERT
  TO authenticated
  WITH CHECK (is_admin());

-- Admins can update operators
CREATE POLICY "Admins can update operators"
  ON operators FOR UPDATE
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- Admins can delete operators
CREATE POLICY "Admins can delete operators"
  ON operators FOR DELETE
  TO authenticated
  USING (is_admin());

-- Backoffice users can view all operators
CREATE POLICY "Backoffice can view all operators"
  ON operators FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid()
      AND users.role = 'backoffice'
      AND users.active = true
    )
  );

-- Partners can view their own operators
CREATE POLICY "Partners can view own operators"
  ON operators FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM partners
      WHERE partners.id = partner_id
      AND partners.id = auth.uid()
      AND partners.active = true
    )
  );

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_operators_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update updated_at
DROP TRIGGER IF EXISTS trigger_operators_updated_at ON operators;
CREATE TRIGGER trigger_operators_updated_at
  BEFORE UPDATE ON operators
  FOR EACH ROW
  EXECUTE FUNCTION update_operators_updated_at();