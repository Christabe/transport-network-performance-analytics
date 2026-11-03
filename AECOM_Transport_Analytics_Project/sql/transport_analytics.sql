-- PostgreSQL schema: Transport Network Performance & Reliability Analytics
CREATE TABLE routes(route_id INT PRIMARY KEY, route_code VARCHAR(10) UNIQUE NOT NULL, route_name VARCHAR(100), origin VARCHAR(80), destination VARCHAR(80));
CREATE TABLE stops(stop_id INT PRIMARY KEY, route_id INT REFERENCES routes(route_id), stop_name VARCHAR(100), stop_sequence INT, latitude NUMERIC(9,6), longitude NUMERIC(9,6));
CREATE TABLE trips(trip_id INT PRIMARY KEY, route_id INT REFERENCES routes(route_id), scheduled_departure TIMESTAMP, actual_arrival TIMESTAMP, service_status VARCHAR(20), scheduled_duration_minutes INT);
CREATE TABLE passenger_counts(passenger_count_id INT PRIMARY KEY, trip_id INT REFERENCES trips(trip_id), passenger_count INT CHECK(passenger_count>=0));
CREATE TABLE incidents(incident_id INT PRIMARY KEY, trip_id INT REFERENCES trips(trip_id), route_id INT REFERENCES routes(route_id), incident_type VARCHAR(60), duration_minutes INT, incident_date DATE);

-- 1. Overall service reliability
SELECT COUNT(*) scheduled_trips,
 COUNT(*) FILTER(WHERE service_status='Operated') operated_trips,
 COUNT(*) FILTER(WHERE service_status='Cancelled') cancelled_trips,
 ROUND(100.0*COUNT(*) FILTER(WHERE service_status='Cancelled')/COUNT(*),2) cancellation_rate_pct
FROM trips;

-- 2. Route-level delay and punctuality
WITH x AS (
 SELECT r.route_code,r.route_name,t.service_status,
 EXTRACT(EPOCH FROM(t.actual_arrival-t.scheduled_departure))/60-t.scheduled_duration_minutes delay_minutes
 FROM trips t JOIN routes r USING(route_id)
)
SELECT route_code,route_name,
 ROUND(AVG(delay_minutes) FILTER(WHERE service_status='Operated'),2) avg_delay_minutes,
 ROUND(100.0*COUNT(*) FILTER(WHERE service_status='Operated' AND delay_minutes<=5)/
 NULLIF(COUNT(*) FILTER(WHERE service_status='Operated'),0),2) on_time_pct
FROM x GROUP BY route_code,route_name ORDER BY avg_delay_minutes DESC;

-- 3. Delay by departure hour
SELECT EXTRACT(HOUR FROM scheduled_departure) departure_hour,
 ROUND(AVG(EXTRACT(EPOCH FROM(actual_arrival-scheduled_departure))/60-scheduled_duration_minutes)
 FILTER(WHERE service_status='Operated'),2) avg_delay_minutes
FROM trips GROUP BY departure_hour ORDER BY departure_hour;

-- 4. Passenger demand by route
SELECT r.route_code,r.route_name,SUM(p.passenger_count) total_passengers,
 ROUND(AVG(p.passenger_count),1) avg_passengers_per_trip
FROM routes r JOIN trips t USING(route_id) JOIN passenger_counts p USING(trip_id)
GROUP BY r.route_code,r.route_name ORDER BY total_passengers DESC;

-- 5. Incidents by route and type
SELECT r.route_code,i.incident_type,COUNT(*) incident_count,SUM(i.duration_minutes) disruption_minutes
FROM incidents i JOIN routes r USING(route_id)
GROUP BY r.route_code,i.incident_type ORDER BY incident_count DESC;
