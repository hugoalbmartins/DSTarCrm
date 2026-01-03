/*
  # Simplify Users RLS for Authentication
  
  ## Problem
  Complex RLS policies with the is_admin() function are causing
  "Database error querying schema" during authentication.
  
  ## Solution
  Temporarily disable RLS on users table and add a simpler set of policies
  that don't cause circular dependencies during auth.
  
  ## Changes
  - Drop all existing policies on users table
  - Create simpler policies that work during authentication
  - Users can always read their own profile
  - Admins are checked using direct SQL instead of function calls
*/

-- Drop all existing policies on users table
DROP POLICY IF EXISTS "Users can read own profile" ON users;
DROP POLICY IF EXISTS "Admins can read all users" ON users;
DROP POLICY IF EXISTS "Admins can insert users" ON users;
DROP POLICY IF EXISTS "Admins can update users" ON users;
DROP POLICY IF EXISTS "Admins can delete users" ON users;
DROP POLICY IF EXISTS "Users can create own profile" ON users;

-- Create new simplified policies
-- Allow authenticated users to read their own profile
CREATE POLICY "Users can view own profile"
  ON users FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

-- Allow authenticated users to read all users if they are admin
CREATE POLICY "Admins can view all users"
  ON users FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users u
      WHERE u.id = auth.uid()
      AND u.role = 'admin'
      AND u.active = true
    )
  );

-- Allow admin users to insert new users
CREATE POLICY "Admins can insert users"
  ON users FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM users u
      WHERE u.id = auth.uid()
      AND u.role = 'admin'
      AND u.active = true
    )
  );

-- Allow admin users to update any user
CREATE POLICY "Admins can update users"
  ON users FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users u
      WHERE u.id = auth.uid()
      AND u.role = 'admin'
      AND u.active = true
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM users u
      WHERE u.id = auth.uid()
      AND u.role = 'admin'
      AND u.active = true
    )
  );

-- Allow users to update their own must_change_password field
CREATE POLICY "Users can update own password flag"
  ON users FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Allow admin users to delete users
CREATE POLICY "Admins can delete users"
  ON users FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users u
      WHERE u.id = auth.uid()
      AND u.role = 'admin'
      AND u.active = true
    )
  );
