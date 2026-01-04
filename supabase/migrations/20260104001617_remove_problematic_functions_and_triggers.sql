/*
  # Remove problematic functions and triggers causing auth errors

  ## Problem
  The is_admin() function marked as SECURITY DEFINER and the trigger
  on auth.users are causing "Database error querying schema" during login.
  
  These functions create conflicts when the auth system tries to validate
  credentials while also querying the users table.

  ## Solution
  - Drop the is_admin() function
  - Drop the trigger on auth.users that inserts into public.users
  - Drop the handle_new_user() function
  
  These are not needed since:
  - Admin checks can be done directly in application code
  - Users can be created manually when needed
  - RLS is already disabled on the users table

  ## Changes
  - Remove is_admin() function
  - Remove on_auth_user_created trigger
  - Remove handle_new_user() function
*/

-- Drop the trigger on auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Drop the function that handles new users
DROP FUNCTION IF EXISTS handle_new_user();

-- Drop the is_admin function
DROP FUNCTION IF EXISTS is_admin();
