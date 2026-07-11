-- ============================================================
-- Auckland Infrastructure Asset-Management System
-- Spatial SQL analyses (PostGIS)
-- ============================================================
-- All geometries are in EPSG:2193 (metres), so ST_Length / ST_Area
-- return metric results directly.


-- ------------------------------------------------------------
-- QUERY 1 — High-priority pipe length by material
-- "Of the pipes flagged for renewal, how much (km) of each
--  material are we dealing with?"
-- ------------------------------------------------------------
SELECT
    "SW_MATERIAL"                                     AS material,
    COUNT(*)                                          AS pipe_count,
    ROUND(SUM(ST_Length(geometry))::numeric/1000, 2) AS total_km,
    ROUND(AVG(priority_score)::numeric, 2)           AS avg_priority
FROM stormwater_scored
WHERE priority_score >= 3.5
GROUP BY "SW_MATERIAL"
ORDER BY total_km DESC;


-- ------------------------------------------------------------
-- QUERY 2 — Road-crossing high-priority pipes
-- "How many high-priority pipes run within 10 m of a road?"
-- (road-adjacent renewals cost more: excavation, traffic mgmt)
-- ------------------------------------------------------------
SELECT
    COUNT(*) AS road_crossing_pipes
FROM stormwater_scored p
WHERE p.priority_score >= 3.5
  AND EXISTS (
      SELECT 1 FROM roads_focus r
      WHERE ST_DWithin(p.geometry, r.geometry, 10)
  );


-- ------------------------------------------------------------
-- QUERY 3 — Road renewal-coordination ranking
-- "Which roads sit above the most high-priority pipe, so road
--  and pipe renewal can be coordinated (dig once)?"
-- ------------------------------------------------------------
SELECT
    r.road_name,
    COUNT(p."SW_GIS_ID")                    AS nearby_priority_pipe_count,
    ROUND(SUM(ST_Length(p.geometry))::numeric, 1) AS nearby_priority_pipe_m
FROM roads_focus r
JOIN stormwater_scored p
    ON p.priority_score >= 3.5
   AND ST_DWithin(r.geometry, p.geometry, 10)
GROUP BY r.road_name
ORDER BY nearby_priority_pipe_m DESC
LIMIT 10;


-- ------------------------------------------------------------
-- QUERY 4 — Parks containing high-priority pipes
-- "Which parks have high-priority stormwater pipe inside their
--  boundary (renewal there involves park land / access)?"
-- ------------------------------------------------------------
SELECT
    pk."SITE",
    pk."AssetGroup",
    ROUND((ST_Area(pk.geometry)/10000.0)::numeric, 2)   AS area_ha,
    COUNT(p."SW_GIS_ID")                                AS priority_pipes_inside,
    ROUND(SUM(ST_Length(
        ST_Intersection(p.geometry, pk.geometry)))::numeric, 1) AS pipe_m_inside
FROM parks_focus pk
JOIN stormwater_scored p
    ON p.priority_score >= 3.5
   AND ST_Intersects(pk.geometry, p.geometry)
GROUP BY pk."SITE", pk."AssetGroup", pk.geometry
ORDER BY pipe_m_inside DESC
LIMIT 10;
