/*
  # Recreate admin user with proper configuration

  ## Problem
  Auth server returning "Database error querying schema" error.

  ## Solution
  Delete and recreate user following Supabase Auth patterns.

  ## Changes
  - Delete all user-related records
  - Create fresh admin user with proper configuration
*/

-- Delete existing users with proper type casting
DELETE FROM public.users WHERE email = 'admin@dstar.pt';
DELETE FROM auth.identities WHERE user_id IN (SELECT id FROM auth.users WHERE email = 'admin@dstar.pt');
DELETE FROM auth.sessions WHERE user_id IN (SELECT id FROM auth.users WHERE email = 'admin@dstar.pt');
DELETE FROM auth.refresh_tokens WHERE user_id IN (SELECT id::text FROM auth.users WHERE email = 'admin@dstar.pt');
DELETE FROM auth.users WHERE email = 'admin@dstar.pt';

-- Create the user
WITH new_user AS (
  INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    recovery_sent_at,
    last_sign_in_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at,
    confirmation_token,
    email_change,
    email_change_token_new,
    recovery_token
  ) VALUES (
    '00000000-0000-0000-0000-000000000000',
    gen_random_uuid(),
    'authenticated',
    'authenticated',
    'admin@dstar.pt',
    crypt('Admin123!', gen_salt('bf')),
    now(),
    now(),
    NULL,
    jsonb_build_object('provider', 'email', 'providers', jsonb_build_array('email')),
    jsonb_build_object('name', 'Administrator'),
    now(),
    now(),
    '',
    '',
    '',
    ''
  )
  RETURNING *
)
INSERT INTO auth.identities (
  id,
  user_id,
  provider_id,
  identity_data,
  provider,
  last_sign_in_at,
  created_at,
  updated_at
)
SELECT 
  gen_random_uuid(),
  id,
  id::text,
  jsonb_build_object(
    'sub', id::text,
    'email', email,
    'email_verified', true,
    'phone_verified', false,
    'provider', 'email'
  ),
  'email',
  NULL,
  now(),
  now()
FROM new_user;

-- Create public.users record
INSERT INTO public.users (id, email, name, role, active, must_change_password)
SELECT 
  id,
  'admin@dstar.pt',
  'Administrator',
  'admin',
  true,
  false
FROM auth.users
WHERE email = 'admin@dstar.pt';
