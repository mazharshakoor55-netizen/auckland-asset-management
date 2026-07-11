-- ============================================================
-- Auckland Infrastructure Asset-Management System
-- PostGIS database setup
-- ============================================================
-- Requires: PostgreSQL 14+ with the PostGIS extension available.

-- 1. Create the project database (run from the default 'postgres' db)
--    CREATE DATABASE auckland_assets;

-- 2. Connect to auckland_assets, then enable the spatial extension:
CREATE EXTENSION IF NOT EXISTS postgis;

-- 3. Confirm PostGIS is available:
SELECT PostGIS_Version();

-- ------------------------------------------------------------
-- Tables are loaded from Python (GeoPandas .to_postgis), all in
-- EPSG:2193 (NZ Transverse Mercator, metres):
--
--   stormwater_scored : in-service stormwater pipes for the focus
--                       area, with a computed renewal priority_score
--   roads_focus       : road centrelines clipped to the focus area
--   parks_focus       : park extent polygons clipped to the focus area
-- ------------------------------------------------------------
