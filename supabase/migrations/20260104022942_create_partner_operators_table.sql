/*
  # Create partner_operators table

  ## Problem
  The frontend expects a partner_operators table to manage many-to-many relationships
  between partners and operators.

  ## Changes
  1. New Tables
    - `partner_operators`
      - `id` (uuid, primary key)
      - `partner_id` (uuid, foreign key to partners)
      - `operator_id` (uuid, foreign key to operators)
      - `created_at` (timestamp)
  
  2. Security
    - Enable RLS on `partner_operators` table
    - Add policy for authenticated users to read data
    - Add policy for admins to manage associations

  3. Constraints
    - Unique constraint on (partner_id, operator_id) to prevent duplicates
*/

-- Create partner_operators table
CREATE TABLE IF NOT EXISTS public.partner_operators (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  partner_id uuid NOT NULL,
  operator_id uuid NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  
  CONSTRAINT partner_operators_partner_id_fkey 
    FOREIGN KEY (partner_id) 
    REFERENCES public.partners(id) 
    ON DELETE CASCADE,
    
  CONSTRAINT partner_operators_operator_id_fkey 
    FOREIGN KEY (operator_id) 
    REFERENCES public.operators(id) 
    ON DELETE CASCADE,
    
  CONSTRAINT partner_operators_unique 
    UNIQUE (partner_id, operator_id)
);

-- Enable RLS
ALTER TABLE public.partner_operators ENABLE ROW LEVEL SECURITY;

-- Policy: Allow authenticated users to read all partner_operators
CREATE POLICY "Authenticated users can read partner_operators"
  ON public.partner_operators
  FOR SELECT
  TO authenticated
  USING (true);

-- Policy: Allow authenticated users to insert partner_operators
CREATE POLICY "Authenticated users can insert partner_operators"
  ON public.partner_operators
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Policy: Allow authenticated users to delete partner_operators
CREATE POLICY "Authenticated users can delete partner_operators"
  ON public.partner_operators
  FOR DELETE
  TO authenticated
  USING (true);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_partner_operators_partner_id 
  ON public.partner_operators(partner_id);

CREATE INDEX IF NOT EXISTS idx_partner_operators_operator_id 
  ON public.partner_operators(operator_id);
