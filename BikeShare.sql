ALTER TABLE tripdata_apr_22$
ALTER COLUMN start_station_id nvarchar(255)

ALTER TABLE tripdata_May_22$
ALTER COLUMN start_station_id nvarchar(255)

ALTER TABLE tripdata_Jul_22$
ALTER COLUMN start_station_id nvarchar(255)

ALTER TABLE tripdata_Sep_22$
ALTER COLUMN start_station_id nvarchar(255)

ALTER TABLE tripdata_Oct_22$
ALTER COLUMN start_station_id nvarchar(255)

ALTER TABLE tripdata_Nov_22$
ALTER COLUMN end_station_id nvarchar(255)

ALTER TABLE tripdata_Dec_22$
ALTER COLUMN end_station_id nvarchar(255)

ALTER TABLE tripdata_Mar_23$
ALTER COLUMN start_station_id nvarchar(255)

-- joining the tables 
WITH year_tripdata AS
(
	SELECT *
	  FROM tripdata_Apr_22$
	 UNION
	SELECT *
	  FROM tripdata_May_22$
         UNION
	SELECT *
	  FROM tripdata_Jun_22$
	 UNION
	SELECT *
	  FROM tripdata_Jul_22$
         UNION
        SELECT *
	  FROM tripdata_Aug_22$
	 UNION
	SELECT *
	  FROM tripdata_Sep_22$
	 UNION
	SELECT *
	  FROM tripdata_Oct_22$
	 UNION
	SELECT *
	  FROM tripdata_Nov_22$
	 UNION
	SELECT *
	  FROM tripdata_Dec_22$
	 UNION
	SELECT *
	  FROM tripdata_Jan_23$
	 UNION
	SELECT *
	  FROM tripdata_Feb_23$
	 UNION
	SELECT *
	  FROM tripdata_Mar_23$
),

--removing incomplete rows from the combined dataset
useable_table AS
(
	SELECT ride_id, 
	       rideable_type, 
	       member_casual, 
	       started_at,
	       CAST(started_at AS date) AS date_of_year, 
       	       ended_at, 
   	       day_of_week, 
	       start_station_name, 
       	       start_station_id, 
	       end_station_name, 
	       end_station_id
	  FROM year_tripdata
	 WHERE start_station_name NOT LIKE '%NULL%'
	   AND start_station_id NOT LIKE '%NULL%'
	   AND end_station_name NOT LIKE '%NULL%'
	   AND end_station_id NOT LIKE '%NULL%'
),

-- total number of rides
total_rides AS
(
	SELECT COUNT(member_casual) AS total_ride
	  FROM useable_table
),

--total number of rides based on ridership
total_rides_per_ridership AS
(
	SELECT COUNT(member_casual) AS total_ride,
	       member_casual
	  FROM useable_table
	 GROUP BY member_casual
),

--total number of rides based on type of ride
total_rides_per_type AS
(
	SELECT COUNT(rideable_type) AS total_ride,
	       member_casual,
	       rideable_type
	  FROM useable_table
	 GROUP BY rideable_type, member_casual
),

--variation in trips per ridership throughout the year
--showing number of rides per day
day_trip_casual AS
(
	SELECT COUNT(member_casual) AS casual,
	       date_of_year
	  FROM useable_table
	 WHERE member_casual = 'casual'
	 GROUP BY date_of_year
),

day_trip_member AS
(
        SELECT COUNT(member_casual) AS member,
               date_of_year
          FROM useable_table
         WHERE member_casual = 'member'
         GROUP BY date_of_year
 ),

 day_trip_membervscasual AS
 (
	SELECT dtm.date_of_year, 
	       casual, 
	       member
	  FROM day_trip_member AS dtm
	       JOIN day_trip_casual AS dtc
	       ON dtm.date_of_year = dtc.date_of_year
      -- ORDER BY date_of_year
 ),

--showing number of rides per day of the week
weekday_trip_casual as
(
        SELECT COUNT(member_casual) AS casual,
               day_of_week
          FROM useable_table
         WHERE member_casual = 'casual'
         GROUP BY day_of_week
 ),

 weekday_trip_member as
(
        SELECT COUNT(member_casual) AS member,
               day_of_week
          FROM useable_table
         WHERE member_casual = 'member'
         GROUP BY day_of_week
 ),

 weekday_trip as
 ( 
        SELECT wdm.day_of_week, 
	       casual, 
	       member
          FROM weekday_trip_member AS wdm
	       JOIN weekday_trip_casual AS wdc
	       ON wdm.day_of_week = wdc.day_of_week
-- ORDER BY day_of_week
 ),

 --Aggregate rider length as Minutes
aggre_data AS 
(
	SELECT *,
	       DATEDIFF(MINUTE, started_at, ended_at) as total_minutes
	  FROM useable_table
),

--average ride_length for both ridership
avg_ride_casual AS
(
        SELECT AVG(total_minutes) AS avg_ride_casual
          FROM aggre_data
         WHERE total_minutes >= 1
           AND
	       member_casual = 'casual'
),

avg_ride_member AS
(
         SELECT AVG(total_minutes) AS avg_ride_member
           FROM aggre_data
          WHERE total_minutes >= 1
            AND
	        member_casual = 'member'
)
SELECT *
  FROM avg_ride_member;
