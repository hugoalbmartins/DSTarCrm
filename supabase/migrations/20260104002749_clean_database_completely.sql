/*
  # Clean Database Completely

  ## Overview
  This migration removes ALL existing tables, functions, triggers, and policies
  to start fresh with a clean slate.

  ## Changes
  1. Drop all tables in correct order (respecting foreign keys)
  2. Drop all functions
  3. Drop all triggers
  4. Clean auth.users table
*/

-- Drop all tables (in reverse dependency order)
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS sale_operators CASCADE;
DROP TABLE IF EXISTS sales CASCADE;
DROP TABLE IF EXISTS operators CASCADE;
DROP TABLE IF EXISTS partners CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Drop any remaining functions
DROP FUNCTION IF EXISTS is_admin() CASCADE;
DROP FUNCTION IF EXISTS handle_new_user() CASCADE;

-- Clean auth.users table (keep the table, just remove all users)
DELETE FROM auth.users;
