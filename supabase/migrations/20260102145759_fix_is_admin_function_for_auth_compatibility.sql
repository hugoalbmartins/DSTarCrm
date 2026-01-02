/*
  # Fix is_admin Function for Auth Compatibility

  1. Purpose
    - Ensure is_admin() function doesn't interfere with Supabase Auth
    - Handle cases where auth.uid() might be null during authentication
    - Prevent circular dependencies during login

  2. Changes
    - Update is_admin() function to handle null auth.uid() gracefully
    - Add additional safety checks
    - Ensure function doesn't cause schema query errors

  3. Security
    - Maintains SECURITY DEFINER for RLS bypass
    - Returns false for any error or null cases
*/

-- Drop and recreate is_admin function with better error handling
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  current_user_id uuid;
  user_role text;
  user_active boolean;
BEGIN
  -- Get current user ID safely
  current_user_id := auth.uid();
  
  -- If no authenticated user, return false immediately
  IF current_user_id IS NULL THEN
    RETURN false;
  END IF;
  
  -- Query user info with explicit column selection
  SELECT role, active 
  INTO user_role, user_active
  FROM public.users
  WHERE id = current_user_id;
  
  -- Check if user exists and is admin
  IF user_role = 'admin' AND user_active = true THEN
    RETURN true;
  END IF;
  
  RETURN false;
  
EXCEPTION 
  WHEN OTHERS THEN
    -- Log error for debugging but don't fail
    RETURN false;
END;
$$;

-- Revoke unnecessary grants that were added
REVOKE ALL ON auth.users FROM anon;
REVOKE ALL ON auth.users FROM authenticated;

-- Ensure proper grants on public functions
GRANT EXECUTE ON FUNCTION public.is_admin() TO authenticated, anon;
