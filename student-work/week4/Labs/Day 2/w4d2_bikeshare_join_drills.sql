-- Business question: add the lookup details for each trip's start station.
-- SELECT
--   trips.trip_id,
--   trips.start_station_id,
--   trips.start_station_name,
--   stations.name AS station_lookup_name,
--   stations.status
-- FROM `bigquery-public-data.austin_bikeshare.bikeshare_trips` AS trips
-- INNER JOIN `bigquery-public-data.austin_bikeshare.bikeshare_stations` AS stations
--   ON trips.start_station_id = stations.station_id
-- LIMIT 20;

--q1
-- SELECT
--   trips.trip_id, trips.start_station_id, trips.start_station_name, trips.end_station_id, trips.end_station_name, trips.duration_minutes
-- FROM `bigquery-public-data.austin_bikeshare.bikeshare_trips` AS trips
-- INNER JOIN `bigquery-public-data.austin_bikeshare.bikeshare_stations` AS stations
--   ON trips.start_station_id = stations.station_id
-- LIMIT 20;


--q3
--count all the rows
--count on distinct 
-- SELECT count(stations.station_id)
-- FROM `bigquery-public-data.austin_bikeshare.bikeshare_stations` AS stations;

#101 vs 101
-- SELECT distinct count(stations.station_id)
-- FROM `bigquery-public-data.austin_bikeshare.bikeshare_stations` AS stations;

--Every station id is unique


--q4
-- SELECT trips.trip_id, trips.start_station_name, trips.end_station_name, trips.duration_minutes
-- FROM `bigquery-public-data.austin_bikeshare.bikeshare_trips` AS trips
-- INNER JOIN `bigquery-public-data.austin_bikeshare.bikeshare_stations` AS stations
--   ON trips.start_station_id = stations.station_id
-- LIMIT 20;

--q5

-- SELECT trips.trip_id, stations.station_id
-- FROM `bigquery-public-data.austin_bikeshare.bikeshare_trips` AS trips
-- LEFT JOIN `bigquery-public-data.austin_bikeshare.bikeshare_stations` AS stations
--   ON trips.start_station_id = stations.station_id
-- WHERE stations.station_id is NULL;

--q6


-- SELECT stations.station_id, count(trips.trip_id) as trip_count
-- FROM `bigquery-public-data.austin_bikeshare.bikeshare_stations` AS stations
-- LEFT JOIN `bigquery-public-data.austin_bikeshare.bikeshare_trips` AS trips
--   ON trips.start_station_id = stations.station_id
-- --WHERE trips.start_station_name is NULL
-- GROUP BY stations.station_id
-- HAVING trip_count = 0
-- ORDER BY trip_count
-- LIMIT 25;

-- left join implicitly includes nulls?

