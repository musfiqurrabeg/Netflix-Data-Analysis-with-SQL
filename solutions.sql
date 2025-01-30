-- Netflix Data Analysis using SQL
-- 15 Business Problems of Netflix

-- 1. Count the number of Movies vs TV Shows

SELECT 
	type, 
	COUNT(*)
FROM netflix
GROUP BY 1


-- 2. Find the most common rating for movies and TV shows

-- WAY-1
SELECT
	type,
	rating
FROM (
	SELECT 
		type,
		rating,
		COUNT(*),
		RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
	FROM netflix
	GROUP BY 1,2
	--ORDER BY 1,3 DESC
) AS t1
WHERE ranking = 1

-- WAY-2
WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;


-- 3. List all movies released in a specific year (e.g., 2020)

SELECT * FROM netflix
WHERE type = 'Movie' AND release_year = 2020



-- 4. Find the top 5 countries with the most content on Netflix

SELECT *
FROM (
	SELECT 
		UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
		COUNT(*) AS total_content
	FROM netflix
	GROUP BY 1
	ORDER BY 2 DESC
) AS t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5



-- 5. Identify the longest movie

SELECT *
FROM netflix
WHERE type = 'Movie' AND duration IS NOT NULL
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC



-- 6. Find content added in last 5 years

SELECT *,
		date_added
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'



-- 7. Find all the movies/TV Shows by Director 'Rajiv Chilaka'.

SELECT * 
FROM (
	SELECT 
		*,
		UNNEST(STRING_TO_ARRAY(director, ',')) AS director_name
	FROM netflix
) WHERE director_name ILIKE '%Rajiv Chilaka%'



-- 8. List all TV shows with more than 5 seasons

SELECT *
FROM netflix
WHERE type='TV Show' AND SPLIT_PART(duration, ' ', 1)::INT > 5


-- 9. Count the number of content items in each genre

SELECT
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
	COUNT(*) as total_content
FROM netflix
GROUP BY 1

-- 10. Find each year and the average numbrs of content release by India on Netflix.
--Return top 5 year with highest average release.

SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS date,
	COUNT(*) as yearly_content,
	ROUND(COUNT(*)/(SELECT COUNT(*) FROM netflix WHERE country = 'India'):: numeric *100 , 2)as avg_content_per_year
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5



-- 11. List all movies that are documentaries.

SELECT * FROM netflix
WHERE listed_in ILIKE '%documentaries%'



-- 12. Find all content without a director

SELECT * FROM netflix
WHERE director IS NULL


-- 13. DInd how many movies actor 'Salmana Khan' appeared in last 10 years

SELECT * FROM netflix
WHERE casts ILIKE '%salman khan%'
AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10



-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT
	UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
	COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10


/*
Question 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/

WITH category_content 
AS
(
SELECT
	*,
	CASE
		WHEN description ILIKE '%kill%'OR description ILIKE '%violence%' THEN 'bad'
		ELSE 'good'
	END AS category
FROM netflix
)
SELECT 
	category,
	COUNT(*) AS total_content
FROM category_content
GROUP BY 1
ORDER BY 1 DESC

SELECT * FROM netflix
WHERE description ILIKE '%kill%'
OR
description ILIKE '%violence%'

