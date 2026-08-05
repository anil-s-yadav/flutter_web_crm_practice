-- Run this script in phpMyAdmin or MySQL CLI to add missing columns to the existing candidates table.
-- These columns are needed for the full candidate form data to be stored.

ALTER TABLE candidates
  ADD COLUMN IF NOT EXISTS age INT DEFAULT 25 AFTER alternate_phone,
  ADD COLUMN IF NOT EXISTS address TEXT AFTER age,
  ADD COLUMN IF NOT EXISTS city VARCHAR(100) AFTER address,
  ADD COLUMN IF NOT EXISTS state VARCHAR(100) AFTER city,
  ADD COLUMN IF NOT EXISTS religion VARCHAR(50) AFTER state,
  ADD COLUMN IF NOT EXISTS education VARCHAR(100) DEFAULT 'Not Specified' AFTER religion,
  ADD COLUMN IF NOT EXISTS experience_years INT DEFAULT 0 AFTER education,
  ADD COLUMN IF NOT EXISTS languages VARCHAR(255) AFTER experience_years;
