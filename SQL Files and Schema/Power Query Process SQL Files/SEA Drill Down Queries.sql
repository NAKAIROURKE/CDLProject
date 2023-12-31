/* EXAMPLE OF A DRILL DOWN FOR A SELECTED TEAM. HERE WE CHECKED THE W/L MATCH RECORD, SAW THAT SEA HAS A LOSING RECORD, AND DECIDED TO DELVE DEEPER INTO THEIR TEAM STATS. 
WE FIND OUT THAT SEA HAS A LOSING RECORD ON BREENBERGH HOTEL (4-12) AND INVESTIGATED THE MODE WITH THE MOST LOSSES (CDL CONTROL). WE THEN CHECK THE AVERAGED STATS PER SEA VERSUS THE AVG CDL STATS 
IN CERTAIN PLAYER CATEGORIES (KILLS, DEATHS, UNTRADED KILLS, ETC) TO DETERMINE IF THEIR TEAM PLAY IS OFF OR IF A PLAYER ON THER TEAM NEEDS INVESTIGATION FOR POOR PERFORMANCE. */


SELECT -----QUERY TO DISPLAY HOW MANY TIMES TEAM PLAYED A MAP
	T.ABV,
	M.MAP_NAME,
	COUNT(MM.MAP_ID)AS TIMES_PLAYED,
	COUNT(CASE WHEN MM.MAP_WINNING_TEAM_ID = T.TEAM_ID THEN MM.MAP_WINNING_TEAM_ID END) AS MAP_WINS,
	RANK () OVER (PARTITION BY T.ABV ORDER BY COUNT(MM.MAP_ID) DESC) AS RANKING
FROM MATCHMAPS MM
JOIN MAP M
	ON M.MAP_ID = MM.MAP_ID
JOIN TEAM T
	ON T.TEAM_ID IN (MM.MAP_WINNING_TEAM_ID, MM.MAP_LOSING_TEAM_ID)
WHERE T.ABV IN ('TX','TOR','SEA','NY','LAT')	

GROUP BY T.ABV,M.MAP_NAME;



SELECT  ----QUERY TO DETERMINE WHICH MAP/MAP MODE COMBINATIONS SEA IS LOSING THE MOST
	T.ABV,
	M.MAP_NAME,
	M.MAP_MODE,
	COUNT(CASE WHEN MM.MAP_WINNING_TEAM_ID = T.TEAM_ID THEN MM.MAP_WINNING_TEAM_ID END) AS MAP_WINS,
	COUNT(CASE WHEN MM.MAP_LOSING_TEAM_ID = T.TEAM_ID THEN MM.MAP_LOSING_TEAM_ID END) AS MAP_LOSSES
	
FROM 
	 MATCHMAPS MM
JOIN MAP M
	ON MM.MAP_ID = M.MAP_ID
JOIN TEAM T
	ON T.TEAM_ID IN (MM.MAP_WINNING_TEAM_ID,MM.MAP_LOSING_TEAM_ID)
WHERE T.ABV = 'SEA'

GROUP BY 1,2,3
ORDER BY 5 DESC;
/*"SEA"	"Breenbergh Hotel"	"CDL Control"	2	6
"SEA"	"Breenbergh Hotel"	"CDL Hardpoint"	2	4
"SEA"	"Al Bagra Fortress"	"CDL SnD"		0	3
"SEA"	"Embassy"	"CDL Hardpoint"			2	2*/






-----Overall KD ratio with Individual Player KD ratios for Atlanta Faze------
/* track 3 teams overall win record along with individual player kill/death ratio in respect to time (x axis) */
WITH ATL_STATS AS (
	
	SELECT *
	FROM MATCH M
	JOIN TEAM T
		ON T.TEAM_ID IN (WINNING_TEAM_ID,LOSING_TEAM_ID)
	/*JOIN MATCHMAPS MM
		ON MM.MATCH_ID = M.MATCH_ID */
	WHERE T.ABV = 'ATL'
		/*AND MM.MAP_MODE LIKE '%point' */
	
	ORDER BY PLAY_TIME),

	RECORD_FLAG AS (
	
	SELECT
	ABV,
	TO_TIMESTAMP(PLAY_TIME) AS DATE_PLAYED,
	(CASE WHEN WINNING_TEAM_ID = TEAM_ID THEN 1 ELSE 0 END) AS MAP_WINS,
	(CASE WHEN LOSING_TEAM_ID = TEAM_ID THEN 1 ELSE 0 END) AS MAP_LOSSES
	
	FROM ATL_STATS)
	
SELECT ABV,
		DATE_PLAYED,
		MAP_WINS,
		MAP_LOSSES,
		SUM(MAP_WINS) OVER (ORDER BY DATE_PLAYED ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS WIN_COUNTER,
		SUM(MAP_LOSSES) OVER (ORDER BY DATE_PLAYED ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS LOSS_COUNTER	

FROM RECORD_FLAG	;
		
		
	
SELECT
	P.ALIAS,
	ROUND(AVG(MS.KILL_DEATH_RATIO),2) AS KDR_PER_MATCH,
	TO_TIMESTAMP(M.PLAY_TIME) AS DATE_PLAYED
	
FROM MATCHSTATS MS
JOIN MATCH M
	ON M.MATCH_ID = MS.MATCH_ID
JOIN PLAYER P
	ON P.PLAYER_ID = MS.PLAYER_ID
JOIN TEAM T
	ON T.TEAM_ID = P.TEAM_ID
WHERE T.ABV = 'ATL'	
GROUP BY 3,1
ORDER BY 3;

SELECT
	ROUND(AVG(MS.KILL_DEATH_RATIO),2) AS KDR_PER_MATCH,
	TO_TIMESTAMP(M.PLAY_TIME) AS DATE_PLAYED
	
FROM MATCHSTATS MS
JOIN MATCH M
	ON M.MATCH_ID = MS.MATCH_ID
JOIN PLAYER P
	ON P.PLAYER_ID = MS.PLAYER_ID
JOIN TEAM T
	ON T.TEAM_ID = P.TEAM_ID
WHERE T.ABV = 'ATL'	
GROUP BY 2
ORDER BY 2;



	

