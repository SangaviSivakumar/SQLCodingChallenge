show schemas;
use petadoptionplatform;
show databases;
create database PetPals;
use PetPals;
show tables;

create table Pets(
	PetID INT PRIMARY KEY,
    Name varchar(30) NOT NULL,
    Age INT NOT NULL,
    Breed varchar(50) NOT NULL,
    Type ENUM('Dog','Cat','Rabbit'),
    AvailableForAdoption BIT(1) DEFAULT 0
);

create table Shelters(
	ShelterID INT PRIMARY KEY,
    Name varchar(30) NOT NULL,
    Location varchar(50),
    PetID INT NOT NULL,
    FOREIGN KEY(PetID) REFERENCES Pets(PetID)
);

create table Donations(
	DonationID INT PRIMARY KEY,
    DonorName varchar(50) NOT NULL,
    DonationType ENUM('Cash','Item') NOT NULL,
    DonationAmount DECIMAL(10,2) DEFAULT 0.00,
    DonatioItem varchar(30) NOT NULL,
    DonationDate TIMESTAMP NOT NULL,
    ShelterID INT NOT NULL,
    FOREIGN KEY(ShelterID) REFERENCES Shelters(ShelterID)
);

create table AdoptionEvents(
	EventID INT PRIMARY KEY,
    EventName varchar(50) NOT NULL,
    EventDate TIMESTAMP NOT NULL,
    LOCATION varchar(50)
);

create table Participants(
	ParticipantID INT PRIMARY KEY,
    ParticipantName varchar(40) NOT NULL,
    ParticipantType ENUM('Shelter','Adoption'),
    EventID INT NOT NULL,
    FOREIGN KEY(EventID) REFERENCES AdoptionEvents(EventID)    
);


INSERT INTO Pets (PetID, Name, Age, Breed, Type, AvailableForAdoption)
VALUES 
(1, 'Simba', 3, 'Labrador', 'Dog', 1),
(2, 'Chittu', 2, 'Persian', 'Cat', 1),
(3, 'Bunty', 1, 'Angora', 'Rabbit', 0),
(4, 'Rocky', 4, 'Beagle', 'Dog', 1);


INSERT INTO Shelters (ShelterID, Name, Location, PetID)
VALUES 
(1, 'Paws Care', 'Chennai', 1),
(2, 'Safe Haven', 'Coimbatore', 2),
(3, 'Hope Shelter', 'Madurai', 3),
(4, 'Happy Tails', 'Trichy', 4);


INSERT INTO Donations (DonationID, DonorName, DonationType, DonationAmount, DonatioItem, DonationDate, ShelterID)
VALUES 
(1, 'Arun Kumar', 'Cash', 5000.00, '', '2025-03-25 10:00:00', 1),
(2, 'Lakshmi Narayanan', 'Item', 0.00, 'Dog Food', '2025-03-26 14:30:00', 2),
(3, 'Meena Iyer', 'Cash', 3000.00, '', '2025-03-27 09:15:00', 3),
(4, 'Rajeshwari', 'Item', 0.00, 'Cat Litter', '2025-03-28 16:45:00', 4);


INSERT INTO AdoptionEvents (EventID, EventName, EventDate, LOCATION)
VALUES 
(1, 'Pet Adoption Drive Chennai', '2025-04-10 09:00:00', 'Chennai'),
(2, 'Coimbatore Pet Fest', '2025-04-15 10:00:00', 'Coimbatore');


INSERT INTO Participants (ParticipantID, ParticipantName, ParticipantType, EventID)
VALUES 
(1, 'Paws Care', 'Shelter', 1),
(2, 'Safe Haven', 'Shelter', 2),
(3, 'Meena Iyer', 'Adoption', 1),
(4, 'Rajeshwari', 'Adoption', 2);



/* 5. Write an SQL query that retrieves a list of available pets (those marked as available for adoption)
from the "Pets" table. Include the pet's name, age, breed, and type in the result set. Ensure that
the query filters out pets that are not available for adoption.*/

select Name,Age,Breed,Type
from Pets 
where AvailableForAdoption = 1;

/* 6. Write an SQL query that retrieves the names of participants (shelters and adopters) registered
for a specific adoption event. Use a parameter to specify the event ID. Ensure that the query
joins the necessary tables to retrieve the participant names and types.*/

select p.ParticipantName 
from Participants p
join AdoptionEvents e using(EventID)
where EventName = "Coimbatore Pet Fest";

/* 7. Create a stored procedure in SQL that allows a shelter to update its information (name and
location) in the "Shelters" table. Use parameters to pass the shelter ID and the new information.
Ensure that the procedure performs the update and handles potential errors, such as an invalid
shelter ID. */
delimiter //
create procedure updateshelterinfo(in ShelterID int, in new_name varchar(255), in new_location varchar(255))
begin
update Shelters set name = new_name, location = new_location where Shelterid = Shelter_id;
end //
delimiter ;

/*8. Write an SQL query that calculates and retrieves the total donation amount for each shelter (by
shelter name) from the "Donations" table. The result should include the shelter name and the
total donation amount. Ensure that the query handles cases where a shelter has received no
donations.*/
SELECT 
    s.Name AS ShelterName, 
    COALESCE(SUM(d.DonationAmount), 0) AS TotalDonationAmount
FROM Shelters s
LEFT JOIN Donations d ON s.ShelterID = d.ShelterID
GROUP BY s.Name;


/* --- 9. Write an SQL query that retrieves the names of pets from the "Pets" table that do not have an
owner (i.e., where "OwnerID" is null). Include the pet's name, age, breed, and type in the result
set. */
ALTER TABLE Pets ADD COLUMN OwnerID INT NULL;
select Name,Age,Breed,Type
from Pets
where OwnerID IS NULL;

/* 10. Write an SQL query that retrieves the total donation amount for each month and year (e.g.,
January 2023) from the "Donations" table. The result should include the month-year and the
corresponding total donation amount. Ensure that the query handles cases where no donations
were made in a specific month-year. */ 
SELECT 
    DATE_FORMAT(DonationDate, '%M %Y') AS MonthYear,
    COALESCE(SUM(DonationAmount), 0) AS TotalDonationAmount
FROM Donations
GROUP BY MonthYear
ORDER BY STR_TO_DATE(MonthYear, '%M %Y');


/* 11. Retrieve a list of distinct breeds for all pets that are either aged between 1 and 3 years or older
than 5 years.*/
select DISTINCT Breed
from Pets
where (Age BETWEEN 1 AND 3) OR (Age > 5);


/* 12. Retrieve a list of pets and their respective shelters where the pets are currently available for
adoption.*/
select p.Name AS PetName, p.Breed, p.Type, s.Name AS ShelterName, s.Location
from Pets p
join Shelters s ON p.PetID = s.PetID
where p.AvailableForAdoption = 1;

/* 13. Find the total number of participants in events organized by shelters located in specific city.
Example: City=Chennai*/
select COUNT(p.ParticipantID) AS TotalParticipants
from Participants p
join AdoptionEvents ae ON p.EventID = ae.EventID
join Shelters s ON s.Name = p.ParticipantName
where s.Location = 'Chennai';

/* 14. Retrieve a list of unique breeds for pets with ages between 1 and 5 years.*/ 
select DISTINCT Breed
from Pets
where Age BETWEEN 1 AND 5;

/* 15. Find the pets that have not been adopted by selecting their information from the 'Pet' table. */
select PetID, Name,Age,Breed,Type,AvailableForAdoption
from Pets
where OwnerID IS NULL;

/*16. Retrieve the names of all adopted pets along with the adopter's name from the 'Adoption' and
'User' tables.*/
select p.Name AS PetName,a.ParticipantName
from AdoptionEvents a
join Pets p ON a.PetID = p.PetID;


/* 17. Retrieve a list of all shelters along with the count of pets currently available for adoption in each
shelter.*/
select s.ShelterID,s.Name AS ShelterName,s.Location,COALESCE(COUNT(p.PetID), 0) AS AvailablePetsCount
from Shelters s
left join Pets p ON s.PetID = p.PetID AND p.AvailableForAdoption = 1
group by s.ShelterID, s.Name, s.Location
order by AvailablePetsCount DESC;

/* 18. Find pairs of pets from the same shelter that have the same breed.*/
select p1.PetID AS Pet1_ID, p1.Name AS Pet1_Name, p2.PetID AS Pet2_ID, p2.Name AS Pet2_Name, p1.Breed, s.Name AS ShelterName, s.Location
from Pets p1
join Pets p2 ON p1.Breed = p2.Breed 
    AND p1.PetID < p2.PetID  
join Shelters s ON p1.PetID = s.PetID AND p2.PetID = s.PetID 
order by s.Name, p1.Breed;

/* 19. List all possible combinations of shelters and adoption events.*/
select s.ShelterID,s.Name AS ShelterName,s.Location,e.EventID,e.EventName,e.EventDate
from Shelters s
cross join AdoptionEvents e
order by s.ShelterID, e.EventDate;

/* 20. Determine the shelter that has the highest number of adopted pets.*/
ALTER TABLE AdoptionEvents 
ADD COLUMN PetID INT,
ADD CONSTRAINT fk_adoptionevent_pet FOREIGN KEY (PetID) REFERENCES Pets(PetID) ON DELETE SET NULL;

ALTER TABLE AdoptionEvents 
ADD COLUMN ShelterID INT,
ADD CONSTRAINT fk_adoptionevent_shelter FOREIGN KEY (ShelterID) REFERENCES Shelters(ShelterID) ON DELETE SET NULL;

select s.ShelterID,s.Name AS ShelterName,s.Location,COUNT(a.PetID) AS AdoptedPetsCount
from Shelters s
join Pets p ON p.ShelterID = s.ShelterID  
join AdoptionEvents a ON a.PetID = p.PetID 
group by s.ShelterID, s.Name, s.Location
order by AdoptedPetsCount DESC
LIMIT 1;





