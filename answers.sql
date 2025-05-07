
-- Create a new table in 1NF
CREATE TABLE ProductDetail_1NF AS
SELECT 
    OrderID,
    CustomerName,
    TRIM(Product) AS Product
FROM (
    SELECT 
        OrderID,
        CustomerName,
        -- Split the Products string into separate rows
        REGEXP_SUBSTR(Products, '[^,]+', 1, LEVEL) AS Product
    FROM ProductDetail
    CONNECT BY 
        PRIOR OrderID = OrderID AND
        PRIOR SYS_GUID() IS NOT NULL AND
        LEVEL <= LENGTH(REGEXP_REPLACE(Products, '[^,]', '')) + 1
    )
WHERE Product IS NOT NULL;



-- Using JSON functions 
SELECT 
    OrderID,
    CustomerName,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Products, ',', n.n), ',', -1)) AS Product
FROM ProductDetail
CROSS JOIN (
    SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL
    SELECT 4 UNION ALL SELECT 5 -- Add more numbers if needed
) n
WHERE n.n <= LENGTH(Products) - LENGTH(REPLACE(Products, ',', '')) + 1;



-- Create Orders table (contains order-level information)
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerName VARCHAR(100)
);

-- Create OrderItems table (contains product-level information)
CREATE TABLE OrderItems (
    OrderID INT,
    Product VARCHAR(100),
    Quantity INT,
    PRIMARY KEY (OrderID, Product),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

-- Insert data into Orders table
INSERT INTO Orders (OrderID, CustomerName)
SELECT DISTINCT OrderID, CustomerName
FROM OrderDetails;

-- Insert data into OrderItems table
INSERT INTO OrderItems (OrderID, Product, Quantity)
SELECT OrderID, Product, Quantity
FROM OrderDetails;