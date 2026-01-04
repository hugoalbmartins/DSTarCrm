/*
  # Add missing columns for sale editing and tracking

  ## Problem
  The sale detail/edit page expects several columns that don't exist:
  - req: Requisition number for telecommunications
  - commission_backoffice: Backoffice commission value
  - is_backoffice: Flag to identify backoffice sales
  - active_date: Date when sale was activated
  - loyalty_end_date: Calculated end date of loyalty period

  ## Changes
  1. Add all missing columns to the sales table
  2. Create trigger to automatically calculate loyalty_end_date
  3. Add indexes for better performance

  ## Notes
  - loyalty_end_date is calculated as active_date + loyalty_months
  - is_backoffice defaults to false
  - All commission fields default to 0
*/

-- Add req column (for telecommunications)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' 
      AND table_name = 'sales' 
      AND column_name = 'req'
  ) THEN
    ALTER TABLE public.sales 
    ADD COLUMN req text;
  END IF;
END $$;

-- Add commission_backoffice column
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' 
      AND table_name = 'sales' 
      AND column_name = 'commission_backoffice'
  ) THEN
    ALTER TABLE public.sales 
    ADD COLUMN commission_backoffice numeric DEFAULT 0;
  END IF;
END $$;

-- Add is_backoffice column
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' 
      AND table_name = 'sales' 
      AND column_name = 'is_backoffice'
  ) THEN
    ALTER TABLE public.sales 
    ADD COLUMN is_backoffice boolean DEFAULT false;
  END IF;
END $$;

-- Add active_date column
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' 
      AND table_name = 'sales' 
      AND column_name = 'active_date'
  ) THEN
    ALTER TABLE public.sales 
    ADD COLUMN active_date timestamptz;
  END IF;
END $$;

-- Add loyalty_end_date column
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' 
      AND table_name = 'sales' 
      AND column_name = 'loyalty_end_date'
  ) THEN
    ALTER TABLE public.sales 
    ADD COLUMN loyalty_end_date timestamptz;
  END IF;
END $$;

-- Create function to calculate loyalty_end_date
CREATE OR REPLACE FUNCTION calculate_loyalty_end_date()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.active_date IS NOT NULL AND NEW.loyalty_months IS NOT NULL AND NEW.loyalty_months > 0 THEN
    NEW.loyalty_end_date := NEW.active_date + (NEW.loyalty_months || ' months')::interval;
  ELSE
    NEW.loyalty_end_date := NULL;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update loyalty_end_date
DROP TRIGGER IF EXISTS set_loyalty_end_date ON public.sales;
CREATE TRIGGER set_loyalty_end_date
  BEFORE INSERT OR UPDATE OF active_date, loyalty_months
  ON public.sales
  FOR EACH ROW
  EXECUTE FUNCTION calculate_loyalty_end_date();

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_sales_active_date ON public.sales(active_date);
CREATE INDEX IF NOT EXISTS idx_sales_loyalty_end_date ON public.sales(loyalty_end_date);
CREATE INDEX IF NOT EXISTS idx_sales_is_backoffice ON public.sales(is_backoffice);
CREATE INDEX IF NOT EXISTS idx_sales_req ON public.sales(req) WHERE req IS NOT NULL;
