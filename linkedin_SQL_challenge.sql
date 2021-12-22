Select FirstName, LastName, Email
FROM Customers
ORDER BY LastName;

CREATE TABLE ResponseInfo(CustomerID, PartySize)
CREATE TABLE ResponseInfo("CustomerID"INTEGER, "PartySize" INTEGER);

SELECT * 
from Dishes
ORDER BY Price;

SELECT * 
From Dishes
WHERE Type IS "Appetizer" OR Type is "Beverage"

SELECT * 
From Dishes
WHERE Type is not "Beverage"

INSERT into Customers 
(FirstName,LastName,Email,Address,City,State,Phone,Birthday)
VALUES("Satish","S","sat@abc.com","jordan st","Portland","OR","999999","01/01/1000");

UPDATE Customers SET Address="N washington St",
   City= "Memphis, State= TN"
WHERE CustomerID = "101";
Select FirstName,LastName,CustomerID,Address From Customers Where CustomerID="100";

DELETE 
FROM Customers 
where CustomerID ="101"

Select CustomerID from Customers where Email="jvaan1d@wisdompets.com";

Insert INTO ResponseInfo(CustomerID,PartySize)
VALUES (CustomerID,PartySize) from Reservations where CustomerID = "50";

SELECT Customers.FirstName,Customers.LastName,Customers.CustomerID,Reservations.ReservationID,Reservations.PartySize
 from Customers
JOIN Reservations
 on  Reservations.CustomerID =Customers.CustomerID Where FirstName like '%K%';



INSERT into Reservations (ReservationID,CustomerID,Date,PartySize)
Values ("2001",(Select CustomerID from Customers Where Customers.FirstName="Sam" and Customers.LastName="McAdams"),"2020-07-14 18:00:00","5")

Insert into OrdersDishes (OrderID,DishID)
values (10001,(Select DishID from Dishes where Name ="House Salad"))

Insert into OrdersDishes (OrdersDishesID,OrderID,DishID)
values (4023,10001,(Select DishID from Dishes where Name ="Mini Cheeseburgers"))

Insert into OrdersDishes (OrdersDishesID,OrderID,DishID)
values (4024,10001,(Select DishID from Dishes where Name ="Tropical Blue Smoothie"))

Select SUM(Dishes.Price)
from Dishes
join OrdersDishes 
on OrdersDishes.DishID=Dishes.DishID 
where OrdersDishes.OrderID="10001"

Insert into CustomersDishes
(CustomersDishesID,CustomerID,DishID)
Values(
"1001",
(Select CustomerID from Customers Where FirstName="Cleo"),
(Select DishID from Dishes Where Name ="Quinoa Salmon Salad"));

Select
Customers.FirstName,Customers.LastName,Count(Orders.CustomerID),Customers.Email
From Orders 
Join Customers
On Orders.CustomerID = Customers.CustomerID
Group by Orders.CustomerID 
order by count(orders.CustomerID) DESC 
Limit 5;


SELECT COUNT(Author) FROM Books WHERE Title is "Dracula";

SELECT COUNT(LOANS.BookID) 
FROM Loans
join Books
on books.BookID = loans.BookID
where books.Title is "Dracula" and loans.ReturnedDate is NULL;

INSERT INTO LOANS(BookID,PatronID,LoanDate,DueDate)
Values((SELECT BookID from Books Where Barcode is "2855934983"),
        (SELECT PatronID from Patrons where Email is "jvaan@wisdompets.com"),
      "2020-08-25","2020-09-08"),
      ((SELECT BookID from Books Where Barcode is "4043822646"),
        (SELECT PatronID from Patrons where Email is "jvaan@wisdompets.com"),
      "2020-08-25","2020-09-08");

SELECT books.Title, books.Author, patrons.Email from books 
join loans 
on loans.BookID=books.BookID
join Patrons on loans.PatronID=patrons.PatronID
where Loans.DueDate is "2020-06-13"    

update loans 
set ReturnedDate = "2020-06-05"
where BookID=(select BookID from books where barcode = "6435968624")
and ReturnedDate is NULL;

SELECT Patrons.Email, Patrons.FirstName , count(loans.PatronID)
from Patrons
join loans on loans.PatronID = Patrons.PatronID
group by loans.PatronID
order by count(loans.PatronID) 
LIMIT 10;

SELECT books.title, books.Published
from books 
join loans on Loans.BookID=Books.BookID
where books.Published like "189%" and loans.ReturnedDate is Not Null
group by books.BookID
order by books.title, loans.BookID

SELECT count(loans.BookID), loans.BookID, books.Title
from Loans
join books on books.BookID=Loans.BookID
group by books.title
order by count(loans.BookID) DESC
LIMIT 5;

SELECT books.BookID, books.Published, count(DISTINCT(books.Title))
from Books
group by books.Published
order by count(books.published) DESC;

SELECT Books.BookID, Books.Title, Books.Author, Books.Published, count(DISTINCT(books.BookID))
FROM Books 
WHERE Books.Published like "189%"  
AND Books.BookID NOT IN (SELECT Loans.BookID FROM Loans WHERE ReturnedDate is NULL)
GROUP by books.Title
ORDER BY count(DISTINCT(books.BookID));
