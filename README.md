# CDLProject
CDL DB for 2023 Analysis


This project was created in order to provide granular analysis for teams and individual players for the Call of Duty League  2023 

The Call of Duty League ,CDL, provides limited stats on their website https://www.callofdutyleague.com/en-us/. These stats are aggregated by each match or aggregated by player for the entire season.
My brother and I follow the CDL and would like to answer questions that are more precise or nuanced then what the CDL website has to offer. 
In order to accomplish this, I cleaned and loaded data from the CDL website into a relational database I created in order to answer ad hoc questions in finer detail. 

The data, in the form of a json file, was downloaded from each individual match page from the CDL website. An example json file can be found in the project named "JSON example file.txt". 
Since I am less experienced with this format and the editor I am using for my SQL queries, pgAdmin, can import data easily from CSV filetypes, I decided to transform my data into CSV file formats. I chose four teams (Seattle, LA Thieves, OpTic Texas, and NY Subliners) and downloaded all json files for their matches during the first and last qualifier stages. I will continue to add matches if this prototype provides useful information. 
I used an online json to csv converted and refined the data in KNIME. KNIME is a node-based analytic platform I used for some analytics courses during my junior year at NMSU. In KNIME, I imported each CSV file for each match. 
I removed all unwanted columns and renamed all included columns with clear, refined names. Each cleaned CSV was appended into one MASTERCSV. The process is shown in the KNIME Wkflows folder along with a screenshot if the user does not have KNIME installed.  

This MASTERCSV was used to create my relational DB schema. The schema needed to be as normalized as possible so I created six tables with the roughly fifty columns in the MASTERCSV. The tables are named team, player, map, match, matchmaps, and matchstats. The match table is a transaction table as it has a UNIX timestamp column to mark when the game was played. The MASTERSCV was then trimmed down to match the columns needed for each table and then imported using pgAdmin Import/Export Data. All columns that could not be imported were updated using SQL queries. All table creation and data insertion are contained in the "CDL Table Creation.sql". 

Since I only have 32 matches from the season, not all teams and players are fully represented and so analysis might skew if there isnt an equal amount available. I first determined the average match count and matchstat count for teams and players respectively. Then, found which teams/players had more match rows and matchstats rows than the average. These are the teams/players we will analyze first. These queries can be found in the "Table Verification Queries.sql". 
