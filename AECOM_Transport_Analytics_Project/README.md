# Transport Network Performance & Reliability Analytics
**Portfolio prototype | Simulated data | September 2026**

## Objective
Demonstrate an end-to-end workflow for integrating, validating, analysing and visualising transport operations data.

**All records are simulated. This is an independent portfolio project and is not affiliated with AECOM or a real transport operator.**

## Scenario
A fictional Dublin transport operator wants to understand route reliability, journey delays, cancellations, passenger demand and service disruptions. Operational data arrives in separate CSV files.

## Dataset
- 8 fictional routes
- 40 route-stop records (approximate coordinates for mapping)
- 2,880 scheduled trips across 30 days
- Passenger totals for operated trips
- Simulated incident records

## Tools
Excel/CSV for source inspection; Python/pandas for ETL and validation; PostgreSQL for relational storage and SQL analysis; Power BI for reporting.

## Run
From this folder:
`python python/etl_pipeline.py`

The script checks unique identifiers and foreign-key relationships, standardises text, calculates actual duration and delay, derives an on-time flag, joins passenger totals and exports processed data.

## PostgreSQL
Create a database, then run `sql/transport_analytics.sql` to create tables and execute example analysis queries. Import the five CSV files in `data/raw/` into their corresponding tables using pgAdmin.

## Power BI report pages
1. Network overview: scheduled/operated/cancelled journeys, cancellation rate, average delay, on-time percentage.
2. Route performance: average delay and on-time percentage by route.
3. Time patterns: delay by departure hour and service date.
4. Passenger demand and incidents: passenger totals by route and incident count by type.
5. Map: stop coordinates from `stops.csv`.

## Definitions
Delay = actual journey duration minus scheduled journey duration.
On time = operated journey with delay of five minutes or less.
Cancellation rate = cancelled scheduled journeys divided by all scheduled journeys.
Cancelled journeys are excluded from delay and punctuality averages.

## Limitations
Synthetic data does not represent actual Dublin transport performance. Passenger counts are trip-level simulated totals, not stop-level observed boardings. Coordinates are approximate and included only to demonstrate mapping. The analysis identifies patterns and does not prove causation.

