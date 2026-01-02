/*
  # Add Sales Tracking Fields

  1. Changes to `sales` table
    - Add `req` (text, nullable) - REQ number for telecommunications sales
    - Add `active_date` (date, nullable) - Date when the sale became active
    - Add `loyalty_end_date` (date, nullable) - Calculated end date of loyalty period

  2. Trigger
    - Auto-calculate loyalty_end_date when active_date and loyalty_months are set
*/

-- Add req column (for telecommunications)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'sales' AND column_name = 'req'
  ) THEN
    ALTER TABLE sales ADD COLUMN req text;
  END IF;
END $$;

-- Add active_date column
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'sales' AND column_name = 'active_date'
  ) THEN
    ALTER TABLE sales ADD COLUMN active_date date;
  END IF;
END $$;

-- Add loyalty_end_date column
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'sales' AND column_name = 'loyalty_end_date'
  ) THEN
    ALTER TABLE sales ADD COLUMN loyalty_end_date date;
  END IF;
END $$;

-- Create function to auto-calculate loyalty_end_date
CREATE OR REPLACE FUNCTION calculate_loyalty_end_date()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.active_date IS NOT NULL AND NEW.loyalty_months > 0 THEN
    NEW.loyalty_end_date := NEW.active_date + (NEW.loyalty_months || ' months')::interval;
  ELSE
    NEW.loyalty_end_date := NULL;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for automatic calculation
DROP TRIGGER IF EXISTS trigger_calculate_loyalty_end_date ON sales;
CREATE TRIGGER trigger_calculate_loyalty_end_date
  BEFORE INSERT OR UPDATE ON sales
  FOR EACH ROW
  EXECUTE FUNCTION calculate_loyalty_end_date();
