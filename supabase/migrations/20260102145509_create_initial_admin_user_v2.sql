/*
  # Create Initial Admin User

  1. Purpose
    - Create a test admin user for immediate system access
    - Ensure proper auth.users and public.users synchronization
    - Bypass RLS restrictions for initial user creation

  2. User Details
    - Email: admin@leiritrix.com
    - Password: Admin123!
    - Role: admin
    - Status: active

  3. Security
    - Password is properly hashed using crypt
    - Email is confirmed by default
    - Identity record created for email provider
*/

DO $$
DECLARE
  user_id uuid := gen_random_uuid();
  existing_user_id uuid;
BEGIN
  -- Check if user already exists
  SELECT id INTO existing_user_id
  FROM auth.users
  WHERE email = 'admin@leiritrix.com';

  -- Only create if doesn't exist
  IF existing_user_id IS NULL THEN
    -- Insert into auth.users
    INSERT INTO auth.users (
      id,
      instance_id,
      email,
      encrypted_password,
      email_confirmed_at,
      raw_app_meta_data,
      raw_user_meta_data,
      created_at,
      updated_at,
      confirmation_token,
      email_change,
      email_change_token_new,
      recovery_token,
      aud,
      role
    ) VALUES (
      user_id,
      '00000000-0000-0000-0000-000000000000',
      'admin@leiritrix.com',
      crypt('Admin123!', gen_salt('bf')),
      NOW(),
      '{"provider":"email","providers":["email"]}'::jsonb,
      '{}'::jsonb,
      NOW(),
      NOW(),
      '',
      '',
      '',
      '',
      'authenticated',
      'authenticated'
    );

    -- Insert identity record
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
        'email', 'admin@leiritrix.com',
        'email_verified', true,
        'provider', 'email'
      ),
      NULL,
      NOW(),
      NOW()
    );

    -- Insert into public.users
    INSERT INTO public.users (
      id,
      email,
      name,
      role,
      active,
      created_at
    ) VALUES (
      user_id,
      'admin@leiritrix.com',
      'Admin User',
      'admin',
      true,
      NOW()
    );
    
    RAISE NOTICE 'Admin user created with ID: %', user_id;
  ELSE
    RAISE NOTICE 'Admin user already exists with ID: %', existing_user_id;
  END IF;

END $$;
