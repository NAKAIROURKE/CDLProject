-- This Schema is for Analysis of 4 selected Call of Duty League ,CDL, teams during the 2023 Season. 
-- This DB is created from scratch with 6 tables (Team, Map, Player, Match, MatchMaps, MatchStats)
-- The data was retrieved from each CDL match website link (Ex. https://www.callofdutyleague.com/en-us/match/8810?utm_source=cdlweb&utm_medium=schedule&campaign=general )
-- The file format retrieved was a json format, cleaned and formatted via KNIME and then loaded into the created SQL tables.
-- Tables 'team', 'Map', and 'Player' were entered manually while tables 'MatchMaps', 'Match', and 'MatchStats' were imported from the CSV file created through the KNIME
-- cleaning process.
-- These tables were based off the ERDPLUS schema, included in the GitHub, created for this project. 


CREATE Table team
(
  team_name VARCHAR(45), --Not Null not needed when column is declared as Primary Key as this is implied
  team_id INT NOT NULL, 
  Abv VARCHAR(5),
  PRIMARY KEY (team_id) --UNIQUE not required as primary key is considered a unique column 
);

CREATE TABLE map
(
  map_id	SERIAL, --Autoincrements a row number for this table. map_id was not taken from json data so we can create this ourselves
  map_name 	VARCHAR(75) NOT NULL,
  map_mode 	VARCHAR(75),
  PRIMARY KEY (map_id)
);

CREATE TABLE player
(
  player_id INT,
  first_name VARCHAR(45) NULL, --Can have missing player name if unknown
  last_name VARCHAR(45) NOT NULL, -- NEED AT MIN player_id and last_name to ID player for stats
  alias VARCHAR(30) NULL, --Can have missing alias if changing or undecided
  team_id INT NULL, -- Can have missing team_id if released or Free Agent
  PRIMARY KEY (player_id),
  FOREIGN KEY (team_id) REFERENCES team(team_id) ON DELETE CASCADE ON UPDATE CASCADE--Removes f_key from row if the team_id is deleted from parent table 'team' (Team leaves the competitive scene or changes name)
);

CREATE TABLE Match
(
  match_id INT,
  play_time bigint, --the jason data provided unix timestamps for our date played so we will keep it in that format and use CAST() whenever we want to use for analysis
  host_team_id INT,
  guest_team_id INT,	
  host_team_games_won INT NOT NULL,
  guest_team_games_won INT NOT NULL,
  winning_team_id INT,
  losing_team_id INT,
  PRIMARY KEY (match_id),
  FOREIGN KEY (host_team_id) REFERENCES team(team_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (guest_team_id) REFERENCES team(team_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (winning_team_id) REFERENCES team(team_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (losing_team_id) References team(team_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE matchmaps
(
  match_map_id INT,
  host_team_id INT,
  guest_team_id INT,
  host_score INT DEFAULT 0, --Set default values if score missing/ noted in error
  guest_score INT DEFAULT 0,
  match_id INT,
  map_name varchar(75),
  map_mode varchar(75),	
  map_id INT,
  map_winning_team_id INT,
  map_losing_team_id INT,
  PRIMARY KEY (match_map_id),
  FOREIGN KEY (match_id) REFERENCES Match(match_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (map_id) REFERENCES map(map_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (map_winning_team_id) REFERENCES team(team_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (map_losing_team_id) REFERENCES team(team_id)ON DELETE CASCADE ON UPDATE CASCADE
);
--Will probably drop columns map_name/mode if match_map_id can be used instead as fkey after initial set up since then you can query both tables and they will have matching info

CREATE TABLE MatchStats
(
  match_stats_id serial,
  player_id INT  ,
  match_id INT ,
  map_name varchar(75),
  map_mode varchar(75),
  total_kills INT  ,
  total_deaths INT  ,
  total_assists INT  ,
  kill_death_ratio numeric(4,2),
  total_score INT  ,
  damage_dealt  INT ,
  highest_streak INT,
  untraded_deaths INT,
  traded_deaths INT,
  untraded_kills INT   ,
  traded_kills INT   ,	
  tacticals_used INT,
  lethals_used INT  ,
  dead_silence_time INT  ,
  distance_traveled  numeric (10,3) , --10 dig total 3 after dec
  first_blood_kills INT  ,
  aces INT  ,
  hp_hill_time INT  ,
  hp_hill_time_contested INT  ,
  rotation_kills INT ,
  PRIMARY KEY (match_stats_id),
  FOREIGN KEY (match_id) REFERENCES match(match_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (player_id) REFERENCES player(player_id) ON DELETE CASCADE ON UPDATE CASCADE
);

--------------------------------------------------------LOAD DATA INTO CREATED TABLES---------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO team --Manually entering team table values since there are only 12 teams in the Pro League
VALUES ( 'Long Royal Ravens',10,'LDN'), --team_id value pulled from json data. Will not change so there is no adjustment needed for match IDs
('Las Vegas Legion', 15, 'LV'),
('New York Subliners',13, 'NY' ),
('Los Angeles Guerrillas',11,'LAG'),
('Boston Breach',138, 'BOS'),
('Los Angeles Thieves',69, 'LAT'),
('Atlanta FaZe',7,'ATL'),
('OpTic Texas',6,'TX'),
('Florida Mutineers', 9, 'FLA'),
('Minnesota Rokkr',12,'MIN'),
('Seattle Surge',16,'SEA'),
('Toronto Ultra',17,'TOR');


INSERT INTO map(map_name,map_mode) -- Parentheses indicating which columns have data being entered into
VALUES ('Breenbergh Hotel','CDL Control'),
('El Asilo','CDL Control'),
('Al Bagra Fortress','CDL Control'),
('Himmelmatt Expo','CDL Control'),
('Al Bagra Fortress','CDL Hardpoint'),
('Breenbergh Hotel','CDL Hardpoint'),
('Mercado Las Almas','CDL Hardpoint'),
('Zarqwa Hydroelectric','CDL Hardpoint'),
('Embassy', 'CDL Hardpoint'),
('Breenbergh Hotel','CDL SnD'),
('El Asilo','CDL SnD'),
('Embassy','CDL SnD'),
('Al Bagra Fortress','CDL SnD'),
('Mercado Las Almas','CDL SnD');


-------------------------INSERT team_id VALUES INTO player table.--------------------------

-- We import from player_table.csv for columns player_id, first_name, last_name and then update table and set team_id column with nested query

--player_table_cleaed.csv did not have Daniel 'Ghosty' Rothe 572 in the file so we will add him manually

INSERT INTO player
VALUES(572, 'Daniel','Rothe','Ghosty',6);


-- Updating teams who stuck together manually since there will only be four players with shared team_id
-- Assigning team_ids to players who were with the organization during the MAJOR V Qualifiers or never played for another pro team. Will deal with players with multiple team_ids at a later date.
UPDATE player 
SET team_id = (Select team_id
			  From team
			  Where abv = 'ATL')
Where 		alias IN ('aBeZy','Simp','SlasheR','Cellium');	

Update player
SET team_id = (Select team_id  --Player WARDY subbed in for NY for one series during major V
			  From team
			  Where	abv = 'NY')
Where	lower(alias) IN ('hydra','priestahh','kismet','skyz','wardy');	  --added lower function so i dont miss players if their capitalization is unusual

Update player
SET team_id = (Select team_id
			  From team
			  Where	abv = 'SEA')
Where	lower(alias) IN ('accuracy','sib','pred','mack');

Update player
SET team_id = (Select team_id
			  From team
			  Where	abv = 'LAT')
Where	lower(alias) IN ('octane','kenny','drazah','envoy');

Update player
SET team_id = (Select team_id -- PLAYER HUKE traded from LAG to TX after MAJ 1
			  From team
			  Where	abv = 'TX')
Where	lower(alias) IN ('dashy','illey','ghosty','scump')
	OR	lower(alias) LIKE 'shot%';  --forgot how shotzzy spelled his alias so i used LIKE operator
	
Update player
SET team_id = (Select team_id
			  From team
			  Where	abv = 'BOS')
Where	lower(alias) IN ('kremp','owakening','vivid','beans','nero','methodz');

Update player  ---STANDY IS A POINT OF EMPHASIS ON team_id because he played for TOR ULTRA AND LV LEGION DURING THE 2023 Season
SET team_id = (Select team_id
			  From team
			  Where	abv = 'TOR')
Where	lower(alias) IN ('scrap','insight','cleanx','hicksy');

Update player
SET team_id = (Select team_id
			  From team
			  Where	abv = 'LV')
Where	lower(alias) IN ('clayster','tjhaly','prolute','temp');

Update player
SET team_id = (Select team_id
			  From team
			  Where	abv = 'MIN')
Where	lower(alias) IN ('attach','cammy','afro','bance','fame');

Update player
SET team_id = (Select team_id
			  From team
			  Where	abv = 'LV')
Where	lower(alias) IN ('clayster','tjhaly','prolute','temp','2real');

Update player
SET team_id = (Select team_id
			  From team
			  Where	abv = 'FLA')
Where	lower(alias) IN ('havok','brack','felo','vikul','capsidal','majormaniak','davpadie');

Update player
SET team_id = (Select team_id
			  From team
			  Where	abv = 'LDN')
Where	lower(alias) IN ('paulehx','nastie','uli','asim','skrapz')
	OR 	lower(first_name) LIKE 'trei'; --dont know if his alias 'Zero is spelled with a number'

Update player
SET team_id = (Select team_id
			  From team
			  Where	abv = 'LAG')
Where	lower(alias) IN ('arcitys','assault','joedeceives','neptune','exceed','spart');


-------------------------------------------INSERT DATA INTO match TABLE----------------------------------------------
--Followed import data process with csv for table. Right click on match table ->Import/Export Data
-- home_score and away_score do not have default 0 values for their columns when using the Import/Export Data tool 
-- so we will set that via query
Update matchmaps
Set home_score = 0
Where home_score IS NULL;

Update matchmaps
Set away_score = 0
Where away_score IS NULL;


--------------- ENTERING map_id from map_id table where we match map_names and filter by scoring amount (each mode can only have up to a certain amount of scoring)


--ENTER HARDPOINT map_id FIRST. In the future, adjust home_score >6 since the other modes (SnD and Control) cannot have a score higher than 6 incase a hardpoint expires from time
UPDATE matchmaps
SET map_id = (SELECT map_id from map --Fortress
			 Where map_name LIKE '%ortress'
			 AND map_mode LIKE '%point')
Where (host_score = 250 OR guest_score = 250)
	AND (map_name LIKE '%ortress');
	
UPDATE matchmaps
SET map_id = (SELECT map_id from map --Hotel
			 Where map_name LIKE '%otel'
			 AND map_mode LIKE '%point')
Where (host_score = 250 OR guest_score = 250)
	AND (map_name LIKE '%otel');

UPDATE matchmaps
SET map_id = (SELECT map_id from map
			 Where map_name LIKE '%cado%' --Mercado
			 AND map_mode LIKE '%point')
Where (host_score = 250 OR guest_score = 250)
	AND (map_name LIKE '%cado%');
	
UPDATE matchmaps
SET map_id = (SELECT map_id from map
			 Where map_name LIKE '%electric' --Hydro
			 AND map_mode LIKE '%point')
Where (host_score = 250 OR guest_score = 250)
	AND (map_name LIKE '%electric');
	
UPDATE matchmaps
SET map_id = (SELECT map_id from map
			 Where map_name = 'Embassy' --Embassy
			 AND map_mode LIKE '%point')
Where (host_score = 250 OR guest_score = 250)
	AND (map_name = 'Embassy');		
	
----- ENTER SnD map_id. Similar process to hardpoint scores but will limit max score to =6 since SnD cannot be won without 6 points 	

UPDATE matchmaps
SET map_id = (SELECT map_id from map
			 Where map_name LIKE '%otel' --Hotel
			 AND map_mode LIKE '%SnD')
Where (host_score = 6 AND guest_score < 6)
	OR (host_score <6 AND guest_score = 6)
	AND (map_name LIKE '%otel');
	
UPDATE matchmaps
SET map_id = (SELECT map_id from map
			 Where map_name LIKE '%silo' --El Asilo
			 AND map_mode LIKE '%SnD')
Where (host_score = 6 OR guest_score = 6)
	AND (map_name LIKE '%silo');
	
UPDATE matchmaps
SET map_id = (SELECT map_id from map
			 Where map_name = 'Embassy' --Embassy
			 AND map_mode LIKE '%SnD')
Where (host_score = 6 OR guest_score = 6)
	AND (map_name = 'Embassy');	
	
UPDATE matchmaps
SET map_id = (SELECT map_id from map
			 Where map_name LIKE '%ortress' --Fortress
			 AND map_mode LIKE '%SnD')
Where (host_score = 6 OR guest_score = 6)
	AND (map_name LIKE '%ortress');
	
UPDATE matchmaps
SET map_id = (SELECT map_id from map
			 Where map_name LIKE '%cado%' --Mercado Las Almas
			 AND map_mode LIKE '%SnD')
Where (host_score = 6 OR guest_score = 6)
	AND (map_name LIKE '%cado%');	
	
	
-----Enter Control map_id. Same process as before except score = 3 as this is the max score per map. Extra condition added to distinguish between SnD scores. 
	--The max total score (home score + away score < 6 points) 

UPDATE matchmaps
SET map_id = (SELECT map_id from map
			 Where map_name LIKE '%otel' --Hotel
			 AND map_mode LIKE '%trol')
Where (host_score = 3 OR guest_score = 3)
	AND (map_name LIKE '%otel')
	AND host_score + guest_score <6;
	
UPDATE matchmaps
SET map_id = (SELECT map_id from map
			 Where map_name LIKE '%silo' --El Asilo
			 AND map_mode LIKE '%trol')
Where (host_score = 3 OR guest_score = 3)
	AND (map_name LIKE '%silo')
	AND host_score + guest_score <6;
	
UPDATE matchmaps
SET map_id = (SELECT map_id from map
			 Where map_name LIKE '%ortress' --Fortress
			 AND map_mode LIKE '%trol')
Where (host_score = 3 OR guest_score = 3)
	AND (map_name LIKE '%ortress')
	AND host_score + guest_score <6;
	
UPDATE matchmaps
SET map_id = (SELECT map_id from map
			 Where map_name LIKE '%xpo' --Himmelmatt Expo
			 AND map_mode LIKE '%trol')
Where (host_score = 3 OR guest_score = 3)
	AND (map_name LIKE '%xpo')
	AND host_score + guest_score <6;
	
	
	
------------------INSERT DATA INTO matchstats TABLE----------------------------	
--INSERTED WITH IMPORT/EXPORT DATA. NO MANUAL ENTRY 


---------------------------------TRUNCATING ALL TABLES EXCEPT map and team. Will enter all information for Qualifiers 1-5 from new Power Query Automated Cleaning
drop table match;
Truncate table matchstats;
Truncate table matchmaps;
Truncate table match;
truncate table player;

SELECT COUNT(*) as matches_played from matchmaps where host_score is not null;