-- 0. Check & delete existing user 
SELECT * FROM pg_catalog.pg_user;
SELECT * FROM pg_roles WHERE rolname = 'new_user';
--DROP USER npmuser;

-- 1. Create the database (if not already exists)
CREATE DATABASE new_db;

-- 2. Create the user with password
CREATE USER new_user WITH PASSWORD 'new_usernew_user123';

-- 3. Grant full privileges on the database
GRANT ALL PRIVILEGES ON DATABASE new_db TO new_user;

-- 4. Switch db and grant schema/table privileges
\c new_db;

-- 5. Allow user to use schema
GRANT ALL ON SCHEMA public TO new_user;

-- 6. Grant all DDL & DML on existing tables
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO new_user;

-- 7. Grant on sequences (needed for SERIAL / IDENTITY columns)
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO new_user;

-- 8. Make it apply automatically to future tables/sequences
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT ALL PRIVILEGES ON TABLES TO new_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT ALL PRIVILEGES ON SEQUENCES TO new_user;
