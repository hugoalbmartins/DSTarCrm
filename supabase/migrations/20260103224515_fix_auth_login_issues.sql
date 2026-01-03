/*
  # Fix Authentication Login Issues
  
  ## Problem
  "Database error querying schema" occurs during login due to RLS policies
  being evaluated before authentication is fully complete.
  
  ## Solution
  Improve the is_admin() function to handle NULL auth.uid() gracefully
  and ensure it doesn't cause circular dependencies during authentication.
  
  ## Changes
  - Update is_admin() function with better NULL handling
  - Add explicit NULL check before querying users table
*/

-- Drop and recreate the is_admin function with improved NULL handling
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
DECLARE
  current_user_id uuid;
BEGIN
  -- Get current user ID
  current_user_id := auth.uid();
  
  -- If no user is authenticated, return false immediately
  IF current_user_id IS NULL THEN
    RETURN false;
  END IF;
  
  -- Check if user is admin
  RETURN EXISTS (
    SELECT 1 FROM users
    WHERE id = current_user_id
    AND role = 'admin'
    AND active = true
  );
EXCEPTION 
  WHEN undefined_table THEN
    -- If users table doesn't exist yet (during migration), return false
    RETURN false;
  WHEN OTHERS THEN
    -- For any other error, return false
    RETURN false;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- Ensure the function has proper permissions
GRANT EXECUTE ON FUNCTION is_admin() TO authenticated;
GRANT EXECUTE ON FUNCTION is_admin() TO anon;
