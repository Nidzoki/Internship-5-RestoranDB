CREATE DATABASE Restaurant;

CREATE TABLE City(
    CityId SERIAL PRIMARY KEY,
    Name VARCHAR(30) NOT NULL,
);


CREATE TABLE Restaurant (
    RestaurantId SERIAL PRIMARY KEY,
    Name VARCHAR(30) NOT NULL,
    CityId INT NOT NULL,
    Capacity INT,
    OpeningTime TIME,
    ClosingTime TIME,
    FOREIGN KEY (CityId) REFERENCES City(CityId)
);

CREATE TABLE Dish (
    DishId SERIAL PRIMARY KEY,
    RestaurantId INT NOT NULL,
    Name VARCHAR(30) NOT NULL,
    Category VARCHAR(30) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    Calories INT NOT NULL,
    Available BOOLEAN NOT NULL,
    FOREIGN KEY (RestaurantId) REFERENCES Restaurant(RestaurantId)
);

CREATE TABLE Customer (
    CustomerId SERIAL PRIMARY KEY,
    Name VARCHAR(30) NOT NULL,
    Surname VARCHAR(30) NOT NULL,
    CityId INT NOT NULL,
    LoyaltyCard BOOLEAN NOT NULL,
    FOREIGN KEY (CityId) REFERENCES City(CityId)
);

CREATE TABLE Staff (
    StaffId SERIAL PRIMARY KEY,
    RestaurantId INT NOT NULL,
    Name VARCHAR(30) NOT NULL,
    Surname VARCHAR(30) NOT NULL,
    Age INT NOT NULL,
    Role VARCHAR(20) NOT NULL,
    DriversLicence BOOLEAN,
    FOREIGN KEY (RestaurantId) REFERENCES Restaurant(RestaurantId)
);

CREATE TABLE OrderDetails (
    OrderId SERIAL PRIMARY KEY,
    CustomerId INT NOT NULL,
    RestaurantId INT,
    DateTime TIMESTAMP NOT NULL,
    DeliveryAddress VARCHAR(50),
    Price DECIMAL(10,2) NOT NULL,
    Type VARCHAR(20) NOT NULL,
    DeliveryGuyId INT,
    FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId),
    FOREIGN KEY (RestaurantId) REFERENCES Restaurant(RestaurantId),
    FOREIGN KEY (DeliveryGuyId) REFERENCES Staff(StaffId)
);

CREATE TABLE OrderDish (
    OrderId INT NOT NULL,
    DishId INT NOT NULL,
    Quantity INT NOT NULL,
    PRIMARY KEY (OrderId, DishId),
    FOREIGN KEY (OrderId) REFERENCES OrderDetails(OrderId),
    FOREIGN KEY (DishId) REFERENCES Dish(DishId)
);

CREATE TABLE Review (
    ReviewId SERIAL PRIMARY KEY,
    CustomerId INT NOT NULL,
    DishId INT,
    OrderId INT,
    Mark INT NOT NULL,
    Comment TEXT,
    FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId),
    FOREIGN KEY (DishId) REFERENCES Dish(DishId),
    FOREIGN KEY (OrderId) REFERENCES OrderDetails(OrderId)
);

CREATE TABLE LoyaltyCard (
    LoyaltyCardId SERIAL PRIMARY KEY,
    CustomerId INT NOT NULL,
    FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId)
);

-- Constraints --

-- This constraint only works using trigger for some reason

CREATE OR REPLACE FUNCTION CheckCustomerLoyalty() RETURNS TRIGGER AS $$ 
BEGIN 
	IF (SELECT COUNT(*) FROM OrderDetails WHERE CustomerId = NEW.CustomerId) <= 15 
	OR (SELECT SUM(Price) FROM OrderDetails WHERE CustomerId = NEW.CustomerId) <= 1000 THEN 
		RAISE EXCEPTION 'Customer does not meet the requirements for a loyalty card.'; 
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER LoyaltyCheckTrigger 
BEFORE INSERT OR UPDATE ON Customer 
FOR EACH ROW 
WHEN (NEW.LoyaltyCard = TRUE) 
EXECUTE FUNCTION CheckCustomerLoyalty();

-- End of weird constraint

ALTER TABLE Staff ADD CONSTRAINT CookOverEighteen CHECK (
    CASE WHEN Role = 'Chef' THEN Age >= 18 ELSE TRUE END
);

ALTER TABLE Staff ADD CONSTRAINT DriversLicenceConstraint CHECK (
    CASE WHEN Role = 'Delivery' THEN DriversLicence ELSE TRUE END
);
