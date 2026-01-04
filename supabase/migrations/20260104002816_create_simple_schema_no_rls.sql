/*
  # Create Simple Schema Without RLS

  ## Overview
  This migration creates a clean, simple database schema WITHOUT Row Level Security
  to ensure authentication works properly first. RLS can be added later once the
  basic system is working.

  ## New Tables
  
  ### users
  - `id` (uuid, primary key) - Matches auth.users.id
  - `email` (text, unique) - User email
  - `name` (text) - User full name
  - `role` (text) - User role: admin, backoffice, or vendedor
  - `active` (boolean) - Whether user account is active
  - `must_change_password` (boolean) - Force password change on next login
  - `created_at` (timestamptz) - Account creation timestamp
  
  ### partners
  - `id` (uuid, primary key)
  - `name` (text) - Partner name
  - `email` (text, unique) - Partner email
  - `phone` (text) - Partner phone
  - `address` (text) - Partner address
  - `nif` (text) - Tax ID
  - `active` (boolean) - Whether partner is active
  - `created_at` (timestamptz)
  
  ### operators
  - `id` (uuid, primary key)
  - `name` (text) - Operator name
  - `category` (text) - energia, telecomunicacoes, or paineis_solares
  - `active` (boolean) - Whether operator is active
  - `created_at` (timestamptz)
  
  ### sales
  - `id` (uuid, primary key)
  - `seller_id` (uuid) - Reference to users table
  - `partner_id` (uuid) - Reference to partners table
  - `client_name` (text) - Client name
  - `client_phone` (text) - Client phone
  - `client_email` (text) - Client email
  - `client_nif` (text) - Client tax ID
  - `street_address` (text) - Client street address
  - `postal_code` (text) - Client postal code
  - `city` (text) - Client city
  - `category` (text) - energia, telecomunicacoes, or paineis_solares
  - `status` (text) - Sale status
  - `contract_value` (numeric) - Contract value
  - `commission_seller` (numeric) - Seller commission amount
  - `commission_partner` (numeric) - Partner commission amount
  - `commission_percentage_seller` (numeric) - Seller commission percentage
  - `commission_percentage_partner` (numeric) - Partner commission percentage
  - `commission_minimum_threshold` (numeric) - Minimum threshold for commission
  - `notes` (text) - Additional notes
  - `created_at` (timestamptz)
  - `updated_at` (timestamptz)
  
  ### sale_operators
  - `id` (uuid, primary key)
  - `sale_id` (uuid) - Reference to sales
  - `operator_id` (uuid) - Reference to operators
  - `created_at` (timestamptz)
  
  ### notifications
  - `id` (uuid, primary key)
  - `user_id` (uuid) - Reference to users
  - `title` (text) - Notification title
  - `message` (text) - Notification message
  - `type` (text) - Notification type
  - `sale_id` (uuid) - Optional reference to sale
  - `read` (boolean) - Whether notification was read
  - `created_at` (timestamptz)

  ## Security
  - NO RLS policies initially - authentication must work first
  - All tables created WITHOUT row level security enabled
*/

-- Create users table
CREATE TABLE users (
  id uuid PRIMARY KEY,
  email text UNIQUE NOT NULL,
  name text NOT NULL,
  role text NOT NULL CHECK (role IN ('admin', 'backoffice', 'vendedor')),
  active boolean DEFAULT true,
  must_change_password boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

-- Create partners table
CREATE TABLE partners (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  email text UNIQUE,
  phone text,
  address text,
  nif text,
  active boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

-- Create operators table
CREATE TABLE operators (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  category text NOT NULL CHECK (category IN ('energia', 'telecomunicacoes', 'paineis_solares')),
  active boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

-- Create sales table
CREATE TABLE sales (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  seller_id uuid REFERENCES users(id) ON DELETE SET NULL,
  partner_id uuid REFERENCES partners(id) ON DELETE SET NULL,
  client_name text NOT NULL,
  client_phone text NOT NULL,
  client_email text,
  client_nif text DEFAULT '000000000',
  street_address text DEFAULT 'A atualizar',
  postal_code text DEFAULT '0000-000',
  city text DEFAULT 'A atualizar',
  category text NOT NULL CHECK (category IN ('energia', 'telecomunicacoes', 'paineis_solares')),
  status text DEFAULT 'pendente',
  contract_value numeric DEFAULT 0,
  commission_seller numeric DEFAULT 0,
  commission_partner numeric DEFAULT 0,
  commission_percentage_seller numeric DEFAULT 0,
  commission_percentage_partner numeric DEFAULT 0,
  commission_minimum_threshold numeric DEFAULT 0,
  notes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create sale_operators junction table
CREATE TABLE sale_operators (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  sale_id uuid NOT NULL REFERENCES sales(id) ON DELETE CASCADE,
  operator_id uuid NOT NULL REFERENCES operators(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now()
);

-- Create notifications table
CREATE TABLE notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title text NOT NULL,
  message text NOT NULL,
  type text NOT NULL CHECK (type IN ('sale_created', 'sale_status_changed', 'general')),
  sale_id uuid REFERENCES sales(id) ON DELETE CASCADE,
  read boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

-- Create indexes for better query performance
CREATE INDEX idx_sales_seller_id ON sales(seller_id);
CREATE INDEX idx_sales_partner_id ON sales(partner_id);
CREATE INDEX idx_sales_status ON sales(status);
CREATE INDEX idx_sales_created_at ON sales(created_at);
CREATE INDEX idx_sale_operators_sale_id ON sale_operators(sale_id);
CREATE INDEX idx_sale_operators_operator_id ON sale_operators(operator_id);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_read ON notifications(read);
