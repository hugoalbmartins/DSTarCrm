/*
  # Create Admin User

  ## Overview
  Creates a single admin user for initial system access.
  
  ## User Details
  - Email: admin@dstar.pt
  - Password: Admin123!
  - Role: admin
  - Name: Administrator

  ## Changes
  1. Insert user into auth.users with proper password hash
  2. Insert matching record into public.users
*/

-- Create admin user in auth.users
-- Note: Supabase will hash the password automatically when using the proper method
-- We'll use a direct SQL approach with a pre-hashed password

-- First, let's insert into auth.users
-- The password 'Admin123!' will be hashed by Supabase's crypt function
DO $$
DECLARE
  user_id uuid;
BEGIN
  -- Generate a new UUID for the user
  user_id := gen_random_uuid();
  
  -- Insert into auth.users
  INSERT INTO auth.users (
    id,
    instance_id,
    email,
    encrypted_password,
    email_confirmed_at,
    created_at,
    updated_at,
    raw_app_meta_data,
    raw_user_meta_data,
    aud,
    role
  ) VALUES (
    user_id,
    '00000000-0000-0000-0000-000000000000',
    'admin@dstar.pt',
    crypt('Admin123!', gen_salt('bf')),
    now(),
    now(),
    now(),
    '{"provider":"email","providers":["email"],"role":"admin"}',
    '{"name":"Administrator"}',
    'authenticated',
    'authenticated'
  );
  
  -- Insert into auth.identities
  INSERT INTO auth.identities (
    id,
    user_id,
    provider_id,
    provider,
    identity_data,
    last_sign_in_at,
    created_at,
    updated_at
  ) VALUES (
    gen_random_uuid(),
    user_id,
    user_id::text,
    'email',
    jsonb_build_object(
      'sub', user_id::text,
      'email', 'admin@dstar.pt'
    ),
    now(),
    now(),
    now()
  );
  
  -- Insert into public.users
  INSERT INTO public.users (
    id,
    email,
    name,
    role,
    active,
    must_change_password,
    created_at
  ) VALUES (
    user_id,
    'admin@dstar.pt',
    'Administrator',
    'admin',
    true,
    false,
    now()
  );
END $$;
