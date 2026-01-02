/*
  # Restore Auth Users Grants

  1. Purpose
    - Restore necessary grants on auth.users for Supabase Auth to function
    - The previous migration incorrectly revoked permissions needed by Auth service
    - Auth service needs to query auth.users during login

  2. Changes
    - Grant necessary SELECT permissions back to service roles
    - Ensure auth.users is accessible by the auth service

  3. Security
    - Only grants necessary permissions for authentication
    - Does not expose sensitive data to unauthorized users
*/

-- Grant necessary permissions for auth service to function
GRANT SELECT ON auth.users TO postgres, service_role;
GRANT SELECT ON auth.identities TO postgres, service_role;

-- Ensure auth functions are accessible
GRANT USAGE ON SCHEMA auth TO postgres, service_role, authenticated, anon;
