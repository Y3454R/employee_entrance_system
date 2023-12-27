-- Drop tables if they exist
DROP TABLE IF EXISTS time_tracking;
DROP TABLE IF EXISTS verification;
DROP TABLE IF EXISTS employees;

-- Create employees table
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    position VARCHAR(100) NOT NULL,
    department VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20) NOT NULL
);

-- Create verification table
CREATE TABLE verification (
    id BIGSERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(id),
    verification_token VARCHAR(100) NOT NULL
);

-- Create time_tracking table
CREATE TABLE time_tracking (
    id BIGSERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(id),
    checkin_time TIMESTAMP,
    checkout_time TIMESTAMP,
    working_hours NUMERIC(5, 2)
);


-- Drop the trigger function if it exists
DROP FUNCTION IF EXISTS calculate_working_hours() CASCADE;

-- Create the trigger function
CREATE OR REPLACE FUNCTION calculate_working_hours()
    RETURNS TRIGGER AS
$$
BEGIN
    -- Calculate working hours only if both checkin_time and checkout_time are not null
    IF NEW.checkin_time IS NOT NULL AND NEW.checkout_time IS NOT NULL THEN
        NEW.working_hours := ROUND(EXTRACT(EPOCH FROM (NEW.checkout_time - NEW.checkin_time)) / 3600, 2);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop the trigger if it exists
DROP TRIGGER IF EXISTS calculate_working_hours_trigger ON time_tracking;

-- Create the trigger
CREATE TRIGGER calculate_working_hours_trigger
BEFORE INSERT OR UPDATE ON time_tracking
FOR EACH ROW
EXECUTE FUNCTION calculate_working_hours();


-- Insert employees
INSERT INTO employees (email, position, department, phone_number)
VALUES
  ('employee1@example.com', 'Position 1', 'Department 1', '123-456-7890'),
  ('employee2@example.com', 'Position 2', 'Department 2', '234-567-8901'),
  ('employee3@example.com', 'Position 3', 'Department 3', '345-678-9012'),
  ('employee4@example.com', 'Position 4', 'Department 4', '456-789-0123'),
  ('employee5@example.com', 'Position 5', 'Department 5', '567-890-1234');


-- Insert verification tokens
INSERT INTO verification (employee_id, verification_token)
VALUES
  (1, 'token1'),
  (2, 'token2'),
  (3, 'token3'),
  (4, 'token4'),
  (5, 'token5');


-- Insert time_tracking records
INSERT INTO time_tracking (employee_id, checkin_time, checkout_time)
VALUES
  (1, '2023-01-01 09:00:00', '2023-01-01 17:00:00'),
  (2, '2023-01-02 08:30:00', NULL),
  (3, NULL, NULL),
  (4, NULL, '2023-01-03 18:30:00'),
  (5, '2023-01-04 10:00:00', NULL);


-- CHECKING
SELECT * FROM employees;
SELECT * FROM verification;
SELECT * FROM time_tracking;


-- Update checkin_time for employee with id = 3
UPDATE time_tracking
SET checkin_time = '2023-01-05 10:30:00'
WHERE employee_id = 3;

-- checking

SELECT * FROM time_tracking;

-- Update checkout_time for employee with id = 3
UPDATE time_tracking
SET checkout_time = '2023-01-05 18:00:00'
WHERE employee_id = 3;

-- checking

SELECT * FROM time_tracking;


