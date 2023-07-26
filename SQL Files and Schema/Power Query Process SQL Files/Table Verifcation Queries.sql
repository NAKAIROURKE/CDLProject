-------AD HOC QUERIES TO UNDERSTAND AND CHECK DATA LOADED IN EACH TABLE-----
	--HOUSEKEEPING PRIOR TO ANALYSIS--
	--Since we only have 32 games played, not all players and teams will have the same amount of data available
	--We will first determine which players and teams have the majority of data and then will analyze their stats for future dashboard/metric creation in Tableau/Google Data Studio/Metabase



-------------------------------------------------------------------------------
---------------------VERIFY WHETHER PRIMARY KEYS HAVE DUPLICATES---------------
-------------------------------------------------------------------------------


With count_column as  ---Creating a flag column within the inner query of the CTE count_column so I can aggregate the count instead of showing each row with the dupe/no dupe string
	(Select
	match_id,
	CASE WHEN count(match_id) > 1 THEN 'Duplicates'
		WHEN	count(match_id) = 1 THEN 'No Duplicates'
	END as count_flag
	
	From match
	
	Group by 1)
	
Select
	count_flag,
	Count(count_flag)

From count_column

Group by 1; 				--- 32 rows in the table, 32 counted in the No Duplicates Row





With count_column as
	(Select
	match_map_id,
	CASE WHEN count(match_map_id) > 1 THEN 'Duplicates'
		WHEN	count(match_map_id) = 1 THEN 'No Duplicates'
	END as count_flag
	
	From matchmaps
	
	Group by 1)
	
Select
	count_flag,
	Count(count_flag)
	
From count_column

Group by 1; 				 --- 159 rows in the table, 159 counted in the No Duplicates Row





WITH COUNT_COLUMN AS
	(SELECT MATCH_STATS_ID,
			CASE
							WHEN COUNT(MATCH_STATS_ID) > 1 THEN 'Duplicates'
							WHEN COUNT(MATCH_STATS_ID) = 1 THEN 'No Duplicates'
			END AS COUNT_FLAG
		FROM MATCHSTATS
		GROUP BY 1)
SELECT COUNT_FLAG,
	COUNT(COUNT_FLAG)
FROM COUNT_COLUMN
GROUP BY 1; 				--993 rows in the table, 993 counted 

-------------------------------------------------------------------------------
----------DETERMINE WHICH TEAMS AND PLAYERS TO INCLUDE FOR ANALYSIS------------
-------------------------------------------------------------------------------




------TEAM LEVEL --------

CREATE VIEW TEAM_MATCHES_PLAYED AS
SELECT 
	T.TEAM_NAME,
	COUNT(M.MATCH_ID) AS MATCHES_PLAYED
FROM MATCH M
JOIN TEAM T ON T.TEAM_ID = M.HOST_TEAM_ID
OR T.TEAM_ID = M.GUEST_TEAM_ID
GROUP BY 1
ORDER BY 2 DESC;


SELECT 
	FLOOR(AVG(MATCHES_PLAYED)) AS AVG_MATCHES_PLAYED,
	MAX(MATCHES_PLAYED),
	MIN(MATCHES_PLAYED)
FROM TEAM_MATCHES_PLAYED;
											-----avg matches played by one team is 5. We rounded down with floor instead of using round(0)

SELECT 
	TEAM_NAME,
	MATCHES_PLAYED
FROM TEAM_MATCHES_PLAYED
WHERE MATCHES_PLAYED >=
		(SELECT FLOOR(AVG(MATCHES_PLAYED))
			FROM TEAM_MATCHES_PLAYED)
;
											----FOR TEAM LEVEL ANALYSIS WE CAN ALSO INCLUDE TORONTO ULTRA WITH OUR FOUR PRE SELECTED TEAMS FOR THIS P.O.C


------PLAYER LEVEL --------

CREATE VIEW vw_PLAYER_GAMES_PLAYED AS
SELECT 
	P.ALIAS,
	T.TEAM_NAME,
	COUNT(DISTINCT MS.MATCH_STATS_ID) AS TOTAL_MAPS_PLAYED
FROM MATCHSTATS MS
JOIN PLAYER P ON P.PLAYER_ID = MS.PLAYER_ID
JOIN TEAM T ON P.TEAM_ID = T.TEAM_ID
GROUP BY 1,2
ORDER BY 3 DESC;





SELECT FLOOR(AVG(TOTAL_MAPS_PLAYED)) AS AVERAGE_MAPS_PLAYED
FROM vw_PLAYER_GAMES_PLAYED;
/*"average_maps_played"
42*/




SELECT 
	ALIAS
FROM vw_PLAYER_GAMES_PLAYED
WHERE TOTAL_MAPS_PLAYED >	(SELECT FLOOR(AVG(TOTAL_MAPS_PLAYED)) FROM vw_PLAYER_GAMES_PLAYED);

--ALL PLAYERS WITH MORE MAPS PLAYED THAN AVERAGE. WE WILL INCLUDE THESE PLAYERS FOR ANALYSIS
/* total_maps_played"
"Drazah"
"Envoy"
"Kenny"
"Octane"
"KiSMET"
"Priestahh"
"Hydra"
"Accuracy"
"Mack"
"Pred"
"Sib"
"Shotzzy"
"Skyz"
"Dashy"
"Insight"
"CleanX"
"Scrap"
"TJHaLy"
"Clayster"
"Ghosty"
"Temp"
"Vivid"
"Owakening" 	
TOTAL: 23 ROWS*/












