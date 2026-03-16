-- Creates the schemas needed by the pipeline.
-- Runs automatically on first container start via docker-entrypoint-initdb.d.

CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS marts;
