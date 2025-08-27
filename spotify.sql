-- create table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);



-- Retrieve the names of all tracks that have more than 1 billion streams.

SELECT artist, track, stream FROM spotify
WHERE stream > 100000000
ORDER BY stream desc;

-- List all albums along with their respective artists.

SELECT  album, artist FROM spotify;

-- Get the total number of comments for tracks where licensed = TRUE.

SELECT spotify.licensed, sum(comments) 
FROM spotify
GROUP BY 1
HAVING spotify.licensed = 'true';

-- Find all tracks that belong to the album type single.

SELECT track, album_type FROM spotify
WHERE album_type = 'single';

-- Count the total number of tracks by each artist.
SELECT artist, count(*) FROM spotify
GROUP BY 1
ORDER BY count(track) desc;

-- Calculate the average danceability of tracks in each album.
SELECT album, AVG(spotify.danceability) from spotify
GROUP BY 1
ORDER BY AVG(spotify.danceability) desc;

-- Find the top 5 tracks with the highest energy values.
SELECT artist, track, energy
FROM spotify
ORDER BY energy desc
LIMIT 5;

-- List all tracks along with their views and likes where official_video = TRUE.
SELECT artist, track,views,likes from spotify
WHERE official_video = 'true'
ORDER BY 3 DESC, 4 DESC;

-- For each album, calculate the total views of all associated tracks.
SELECT album,sum(views) AS total_views
FROM spotify
GROUP BY 1
ORDER BY 2 DESC;

-- Retrieve the track names that have been streamed on Spotify more than YouTube.
-- Planning Time: 0.037 ms Execution Time: 6.688 ms
SELECT artist, track,most_played_on
FROM spotify
WHERE most_played_on = 'Spotify';

-- Find the top 3 most-viewed tracks for each artist using window functions.
SELECT artist, track, rnk, views
FROM
(
	SELECT *,
	RANK() OVER (PARTITION BY artist ORDER BY views DESC) as rnk
	FROM spotify
) as tb1
WHERE rnk <=3;

-- Write a query to find tracks where the liveness score is above the average.
SELECT track, liveness 
FROM spotify
WHERE liveness > (SELECT AVG(liveness) as avg_live
					FROM spotify)
ORDER BY 2;

-- Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
WITH cte
AS
(SELECT 
	album,
	MAX(energy) as highest_energy,
	MIN(energy) as lowest_energery
FROM spotify
GROUP BY 1
)
SELECT 
	album,
	highest_energy - lowest_energery as energy_diff
FROM cte
ORDER BY 2 DESC;

-- Find tracks where the energy-to-liveness ratio is greater than 1.2.

SELECT track,round((energy+liveness)::numeric,2) as energy_liveness
FROM spotify
WHERE energy+liveness > 1.2
ORDER BY 2;

-- Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
SELECT 
	artist, album, SUM(likes) OVER (ORDER BY views) as total_likes,views
FROM spotify;

-- Query Optimization
DROP INDEX index_artist;
CREATE index index_artist ON spotify(artist);

SELECT * FROM spotify;

EXPLAIN ANALYSE
SELECT artist, track, views
FROM spotify
WHERE artist = 'Gorillaz'
	and 
	 most_played_on = 'Youtube'
ORDER BY stream DESC LIMIT 25;

