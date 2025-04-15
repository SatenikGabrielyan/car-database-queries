-- Calculate the average price of cars for each model, ordered by average price descending.

SELECT 
    m.name AS model,
    AVG(c.price) AS average_price
FROM 
    cars c
JOIN 
    models m ON c.model_id = m.id
GROUP BY 
    m.name
ORDER BY 
    average_price DESC;

-- Find the oldest and newest car years for each make.

SELECT 
    mk.name AS make,
    MIN(c.year) AS oldest_year,
    MAX(c.year) AS newest_year
FROM 
    cars c
JOIN 
    models m ON c.model_id = m.id
JOIN 
    makes mk ON m.make_id = mk.id
GROUP BY 
    mk.name
ORDER BY 
    mk.name;

-- List models with more than 1 car, along with the count of cars.

SELECT 
    m.name AS model,
    COUNT(*) AS car_count
FROM 
    cars c
JOIN 
    models m ON c.model_id = m.id
GROUP BY 
    m.name
HAVING 
    COUNT(*) > 1
ORDER BY 
    car_count DESC;

-- List makes that have at least one car with the 'GPS' feature (use an EXISTS subquery)

SELECT DISTINCT mk.name AS make
FROM makes mk
WHERE EXISTS (
    SELECT 1
    FROM cars c
    JOIN models m ON c.model_id = m.id
    JOIN car_features cf ON c.id = cf.car_id
    JOIN features f ON cf.feature_id = f.id
    WHERE m.make_id = mk.id AND f.name = 'GPS'
)
ORDER BY mk.name;



-- Retrieve cars from models that have no features assigned (use a NOT EXISTS subquery).
SELECT 
    c.id AS car_id,
    mk.name AS make,
    m.name AS model,
    c.year,
    c.price,
    c.vin
FROM 
    cars c
JOIN 
    models m ON c.model_id = m.id
JOIN 
    makes mk ON m.make_id = mk.id
WHERE 
    NOT EXISTS (
        SELECT 1
        FROM cars c2
        JOIN car_features cf ON cf.car_id = c2.id
        WHERE c2.model_id = m.id
    )
ORDER BY 
    mk.name, m.name;

-- Extract the first 5 characters of each VIN and show them alongside the full VIN.

SELECT 
    id AS car_id,
    vin,
    SUBSTRING(vin, 1, 5) AS short_vin
FROM 
    cars
ORDER BY 
    id;

-- Find all cars that have both 'GPS' and 'Sunroof' features.

-- Find all cars that have both 'GPS' and 'Sunroof' features
SELECT 
    c.id AS car_id,
    mk.name AS make,
    m.name AS model,
    c.year,
    c.price
FROM 
    cars c
JOIN 
    models m ON c.model_id = m.id
JOIN 
    makes mk ON m.make_id = mk.id
WHERE 
    EXISTS (
        SELECT 1
        FROM car_features cf1
        JOIN features f1 ON cf1.feature_id = f1.id
        WHERE cf1.car_id = c.id AND f1.name = 'GPS'
    )
    AND EXISTS (
        SELECT 1
        FROM car_features cf2
        JOIN features f2 ON cf2.feature_id = f2.id
        WHERE cf2.car_id = c.id AND f2.name = 'Sunroof'
    )
ORDER BY 
    mk.name, m.name;

-- List makes with the total number of unique features across all their cars.

SELECT 
    mk.name AS make,
    COUNT(DISTINCT f.id) AS unique_feature_count
FROM 
    makes mk
LEFT JOIN models m ON mk.id = m.make_id
LEFT JOIN cars c ON m.id = c.model_id
LEFT JOIN car_features cf ON c.id = cf.car_id
LEFT JOIN features f ON cf.feature_id = f.id
GROUP BY 
    mk.name
ORDER BY 
    unique_feature_count DESC;


-- Retrieve cars that have more than 2 features, along with a concatenated list of feature names

SELECT 
    c.id AS car_id,
    mk.name AS make,
    m.name AS model,
    COUNT(DISTINCT cf.feature_id) AS feature_count,
    GROUP_CONCAT(DISTINCT f.name ORDER BY f.name SEPARATOR ', ') AS features_list
FROM 
    cars c
JOIN 
    models m ON c.model_id = m.id
JOIN 
    makes mk ON m.make_id = mk.id
JOIN 
    car_features cf ON c.id = cf.car_id
JOIN 
    features f ON cf.feature_id = f.id
GROUP BY 
    c.id, mk.name, m.name
HAVING 
    COUNT(DISTINCT cf.feature_id) > 2
ORDER BY 
    feature_count DESC;