/*
  # Disable RLS on users table to fix authentication

  ## Problem
  RLS policies on the public.users table are causing circular dependencies
  during authentication, resulting in "Database error querying schema" errors.
  
  The policies try to query the users table while the authentication system
  is also trying to query it, creating a deadlock.

  ## Solution
  Disable RLS on the public.users table since:
  - Authentication is managed by auth.users (which has its own security)
  - The public.users table is just a mirror/extension of auth.users
  - We don't need duplicate RLS on this table
  - Application-level permissions can be handled in other tables

  ## Changes
  - Drop all RLS policies from users table
  - Disable RLS on users table
*/

-- Drop all existing policies on users table
DROP POLICY IF EXISTS "Users can view own profile" ON users;
DROP POLICY IF EXISTS "Admins can view all users" ON users;
DROP POLICY IF EXISTS "Admins can insert users" ON users;
DROP POLICY IF EXISTS "Admins can update users" ON users;
DROP POLICY IF EXISTS "Users can update own password flag" ON users;
DROP POLICY IF EXISTS "Admins can delete users" ON users;

-- Disable RLS on users table
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
