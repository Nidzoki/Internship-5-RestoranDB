-- QUERIES

-- 1. 
SELECT * FROM Dish WHERE Price < 15

-- 2.

SELECT * FROM OrderDetails WHERE 
EXTRACT(YEAR FROM DateTime) = 2023
AND Price > 50;

-- 3.

SELECT s.StaffId, s.Name, s.Surname, COUNT(o.OrderId) AS DeliveryCount 
FROM Staff s JOIN OrderDetails o ON s.StaffId = o.DeliveryGuyId 
WHERE s.Role = 'Delivery' 
GROUP BY s.StaffId, s.Name, s.Surname 
HAVING COUNT(o.OrderId) > 3; -- don't have enough dummy data to do this

-- 4. 

SELECT * FROM Staff WHERE Role = 'Chef' 
AND RestaurantId = (
	SELECT RestaurantId FROM Restaurant WHERE CityId = (
		SELECT CityId FROM City WHERE Name = 'Zagreb'));

-- 5.

SELECT r.RestaurantId, r.Name, COUNT(o.OrderId) AS NumberOfOrders
FROM Restaurant r
JOIN City c ON r.CityId = c.CityId
JOIN OrderDetails o ON r.RestaurantId = o.RestaurantId
WHERE c.Name = 'Split'
    AND EXTRACT(YEAR FROM o.DateTime) = 2023
GROUP BY r.RestaurantId, r.Name;

-- 6.

SELECT d.Name, COUNT(od.DishId) AS NumberOfOrders
FROM Dish d
JOIN OrderDish od ON d.DishId = od.DishId
JOIN OrderDetails o ON od.OrderId = o.OrderId
WHERE d.Category = 'Dessert'
    AND EXTRACT(MONTH FROM o.DateTime) = 12
    AND EXTRACT(YEAR FROM o.DateTime) = 2023
GROUP BY d.Name
HAVING COUNT(od.DishId) > 10;

-- 7.

SELECT c.Surname, COUNT(o.OrderId) AS NumberOfOrders
FROM Customer c
JOIN OrderDetails o ON c.CustomerId = o.CustomerId
WHERE c.Surname LIKE 'M%'
GROUP BY c.Surname;

-- 8.

SELECT r.Name, AVG(re.Mark) AS AverageRating
FROM Restaurant r
JOIN OrderDetails o ON r.RestaurantId = o.RestaurantId
JOIN Review re ON o.OrderId = re.OrderId
JOIN City c ON r.CityId = c.CityId
WHERE c.Name = 'Rijeka'
GROUP BY r.Name;

-- 9.

SELECT DISTINCT r.RestaurantId, r.Name
FROM Restaurant r
JOIN OrderDetails o ON r.RestaurantId = o.RestaurantId
WHERE r.Capacity > 30
AND o.Type = 'Delivery';

-- 10.

DELETE FROM Review
WHERE DishId IN (
    SELECT d.DishId
    FROM Dish d
    LEFT JOIN OrderDish od ON d.DishId = od.DishId
    LEFT JOIN OrderDetails o ON od.OrderId = o.OrderId
    WHERE o.DateTime IS NULL OR o.DateTime < CURRENT_DATE - INTERVAL '2 years'
);

DELETE FROM OrderDish 
WHERE DishId IN (
    SELECT d.DishId
    FROM Dish d
    LEFT JOIN OrderDish od ON d.DishId = od.DishId
    LEFT JOIN OrderDetails o ON od.OrderId = o.OrderId
    WHERE o.DateTime IS NULL OR o.DateTime < CURRENT_DATE - INTERVAL '2 years'
);

DELETE FROM Dish 
WHERE DishId IN (
    SELECT d.DishId
    FROM Dish d
    LEFT JOIN OrderDish od ON d.DishId = od.DishId
    LEFT JOIN OrderDetails o ON od.OrderId = o.OrderId
    WHERE o.DateTime IS NULL OR o.DateTime < CURRENT_DATE - INTERVAL '2 years'
);

-- 11.

UPDATE Customer
SET LoyaltyCard = FALSE
WHERE CustomerId IN (
    SELECT c.CustomerId
    FROM Customer c
    LEFT JOIN OrderDetails o ON c.CustomerId = o.CustomerId
    WHERE o.DateTime IS NULL OR o.DateTime < CURRENT_DATE - INTERVAL '1 year'
);

