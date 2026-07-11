# auckland-asset-management
A council-style GIS asset-management system for Auckland stormwater, roads and parks — Python, PostGIS, spatial SQL.
# Auckland Infrastructure Asset-Management System

A council-style GIS asset-management prototype that ingests open infrastructure
data, scores stormwater pipes for renewal priority, cross-references them with
roads and parks using spatial SQL, and presents the result as an interactive
multi-layer dashboard.

**Focus area:** Auckland — Rodney Local Board (stormwater board code 175).
The methodology scales to all of Auckland; Rodney was chosen as a representative
pilot area.

![Dashboard](outputs/dashboard_screenshot.png)

---

## What this project does

1. **Ingests** Auckland Council + Auckland Transport open data (stormwater pipes,
   parks, road centrelines).
2. **Cleans & reprojects** to NZ Transverse Mercator (EPSG:2193) for metric
   analysis; filters to in-service assets in the focus area.
3. **Scores** each stormwater pipe for renewal priority using a weighted model
   (age 40%, material risk 35%, diameter/criticality 25%).
4. **Stores** all layers in a PostGIS spatial database.
5. **Analyses across layers** with spatial SQL — e.g. identifying which
   high-priority pipes are road-adjacent (higher renewal cost).
6. **Visualises** everything in an interactive Leaflet/folium dashboard with a
   layer toggle and legend.

## Key findings (Rodney focus area)

- **20,086** in-service stormwater pipes assessed.
- **229** pipes (**1.1%**, ~5.6 km) are high-priority for renewal.
- High-priority group averages **59.4 years** old vs **28.6** for the network.
- **64** high-priority pipes are asbestos-cement or earthenware — brittle,
  failure-prone legacy materials.
- **137 (~60%)** of high-priority pipes run within 10 m of a road, adding
  excavation and traffic-management cost to their renewal.
- Two 1900-installed concrete pipes remain in service at **126 years**.

## Tech stack

| Purpose | Tool |
|---|---|
| Data handling / ETL | Python, GeoPandas |
| Spatial database | PostgreSQL + PostGIS |
| Spatial analysis | Spatial SQL (`ST_Length`, `ST_DWithin`) |
| Interactive dashboard | folium / Leaflet |
| Notebook environment | Jupyter |

*Built on an open-source stack. The workflow is directly transferable to an Esri
environment (ArcGIS Pro · Experience Builder · Survey123).*

## Repository structure

```
.
├── README.md
├── notebooks/
│   └── asset_analysis.ipynb        # full reproducible pipeline
├── outputs/
│   ├── dashboard.html              # interactive multi-layer dashboard
│   ├── dashboard_screenshot.png    # preview image
│   ├── stormwater_scored.gpkg      # scored pipes (GeoPackage)
│   ├── RECOMMENDATION.md            # one-page recommendation
│   └── Stormwater_Renewal_Recommendation.docx
└── data/                           # (not committed — see Data sources)
```

## Data sources

All open data, free to use:

- **Stormwater pipes** — Auckland Council Open Data
  (data-aucklandcouncil.opendata.arcgis.com)
- **Parks (Park Extents)** — Auckland Council Open Data
- **Road centrelines** — Auckland Transport Open GIS Data
  (data-atgis.opendata.arcgis.com), CC BY 4.0

Raw data files are not committed to keep the repo light. Download them from the
sources above into a `data/` folder to reproduce.

## How to reproduce

1. Install PostgreSQL + PostGIS; create a database `auckland_assets` and enable
   PostGIS (`CREATE EXTENSION postgis;`).
2. Create a Python environment with: `geopandas sqlalchemy geoalchemy2 psycopg2
   folium mapclassify jupyter matplotlib`.
3. Download the three datasets into `data/`.
4. Open `notebooks/asset_analysis.ipynb` and run all cells (update the database
   password and file paths as needed).

## Method notes & data quality

- Installation dates often record only the year; ages are reported to year
  resolution.
- A small number of records carry implausible/missing dates and were treated as
  medium priority rather than excluded.
- Stormwater and parks datasets use different local-board coding (numeric codes
  vs names); layers were aligned **spatially** rather than by code — Rodney was
  confirmed as board 175 via a spatial join.

## License

Analysis code: MIT. Underlying data: as per each provider's license
(Auckland Council / Auckland Transport, CC BY 4.0).
