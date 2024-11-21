CREATE TABLE egg_dozens AS
WITH DateRange AS (
    SELECT 
        r.product_id,
        MIN(r.nowtime) AS oldest_date,
        MAX(r.nowtime) AS recent_date
    FROM 
        raw r
    GROUP BY 
        r.product_id
),
FilteredData AS (
	SELECT 
		p.id AS product_id,
		p.product_name,
		p.vendor,
		DATE(r.nowtime) AS record_date,
		AVG(CAST(r.current_price AS FLOAT)) AS avg_price
	FROM 
		product p
	INNER JOIN 
		raw r
	ON 
		p.id = r.product_id
	INNER JOIN 
		DateRange dr
	ON 
		r.product_id = dr.product_id
		AND (r.nowtime = dr.oldest_date OR r.nowtime = dr.recent_date)
	WHERE 
		p.product_name LIKE '%eggs%' -- look for only the entries pertaining to eggs
		AND p.units LIKE '%12%' -- further look at only those with units containing 12 so that we get the price of dozens
		AND p.id NOT IN (3917999, 973325) -- Remove two elements that slipped by the two above filters and are not dozens of eggs
		AND r.current_price IS NOT NULL -- take no rows with null values
	GROUP BY 
		p.id, p.product_name, p.vendor, DATE(r.nowtime)
	ORDER BY 
		p.id, record_date
)
SELECT *
FROM FilteredData
WHERE product_id IN (
    SELECT product_id
    FROM FilteredData
    GROUP BY product_id
    HAVING COUNT(*) = 2 -- Keep only pairs since we need data on egg dozens with an old and new price to find the change
)
ORDER BY product_id, record_date;

-- Now that we have the pairs of data with the first listed price and the most recent listed price for only dozens of eggs
-- The next step is to make a table with one entry per product that shows their change in price along with the date and orginal prices

WITH price_pairs AS (
    SELECT 
        product_id, 
        product_name, 
        vendor, 
        record_date, 
        avg_price,
        ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY record_date) AS rn -- use this row number to decipher old and new price to find accurate price change
    FROM 
        egg_dozens
)
SELECT 
    p1.product_id, 
    p1.product_name, 
    p1.vendor,
    p1.record_date AS first_date, 
    p2.record_date AS last_date,
    p1.avg_price AS first_price, 
    p2.avg_price AS last_price,
    (p2.avg_price - p1.avg_price) AS price_change
FROM 
    price_pairs p1
JOIN 
    price_pairs p2 ON p1.product_id = p2.product_id AND p1.rn = 1 AND p2.rn = 2
ORDER BY 
    p1.product_id;
