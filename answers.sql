-- Database: Library Management System

-- ------------------------------------------------------------------------------
--  Table: Members
--  Description: Stores information about library members.
-- ------------------------------------------------------------------------------
CREATE TABLE Members (
    MemberID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    DateOfBirth DATE,
    Gender ENUM('Male', 'Female', 'Other') NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    PhoneNumber VARCHAR(20) UNIQUE,
    Address VARCHAR(255),
    JoinDate DATE NOT NULL
);

-- ------------------------------------------------------------------------------
--  Table: Books
--  Description: Stores information about books in the library.
-- ------------------------------------------------------------------------------
CREATE TABLE Books (
    BookID INT AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    Author VARCHAR(100) NOT NULL,
    ISBN VARCHAR(20) UNIQUE NOT NULL,
    Genre VARCHAR(50),
    PublicationYear INT,
    CopiesAvailable INT NOT NULL,
    TotalCopies INT NOT NULL,  -- Added to track total copies, important for statistics
    Publisher VARCHAR(100)
);

-- ------------------------------------------------------------------------------
-- Table: Authors
-- Description:  Stores information about authors.  This is a separate table
--               to avoid duplicating author information if an author has
--               multiple books.  It's related to the Books table via
--               a one-to-many relationship.
-- ------------------------------------------------------------------------------
CREATE TABLE Authors (
    AuthorID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Biography TEXT
);

-- Add a foreign key to the Books table to reference Authors
ALTER TABLE Books
ADD COLUMN AuthorID INT,
ADD FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID);

-- ------------------------------------------------------------------------------
--  Table: BookLoans
--  Description: Stores information about book loans.
--               This is a junction table for the many-to-many relationship
--               between Members and Books.
-- ------------------------------------------------------------------------------
CREATE TABLE BookLoans (
    LoanID INT AUTO_INCREMENT PRIMARY KEY,
    MemberID INT,
    BookID INT,
    LoanDate DATE NOT NULL,
    ReturnDate DATE,
    DueDate DATE NOT NULL,  -- Added due date
    Status ENUM('Loaned', 'Returned', 'Overdue') NOT NULL DEFAULT 'Loaned',
    FOREIGN KEY (MemberID) REFERENCES Members(MemberID),
    FOREIGN KEY (BookID) REFERENCES Books(BookID)
);

-- ------------------------------------------------------------------------------
--  Table: Fines
--  Description: Stores information about fines for overdue books.
-- ------------------------------------------------------------------------------
CREATE TABLE Fines (
    FineID INT AUTO_INCREMENT PRIMARY KEY,
    LoanID INT,
    FineAmount DECIMAL(10, 2) NOT NULL,
    PaymentDate DATE,
    Status ENUM('Unpaid', 'Paid', 'Waived') NOT NULL DEFAULT 'Unpaid',
    FOREIGN KEY (LoanID) REFERENCES BookLoans(LoanID)
);

-- ------------------------------------------------------------------------------
-- Table: BookReservations
-- Description: Stores information about book reservations.
-- ------------------------------------------------------------------------------
CREATE TABLE BookReservations (
    ReservationID INT AUTO_INCREMENT PRIMARY KEY,
    MemberID INT,
    BookID INT,
    ReservationDate DATE NOT NULL,
    Status ENUM('Pending', 'Active', 'Cancelled', 'Completed') NOT NULL DEFAULT 'Pending',
    FOREIGN KEY (MemberID) REFERENCES Members(MemberID),
    FOREIGN KEY (BookID) REFERENCES Books(BookID)
);

-- ------------------------------------------------------------------------------
--  Table: LibraryStaff
--  Description: Stores information about library staff members.
-- ------------------------------------------------------------------------------
CREATE TABLE LibraryStaff (
    StaffID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    PhoneNumber VARCHAR(20) UNIQUE,
    JobTitle VARCHAR(100) NOT NULL,
    HireDate DATE NOT NULL,
    Role ENUM('Librarian', 'Assistant', 'Manager') NOT NULL
);

-- ------------------------------------------------------------------------------
-- Table: Events
-- Description:  Stores information about library events.
-- ------------------------------------------------------------------------------
CREATE TABLE Events (
    EventID INT AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    Description TEXT,
    EventDate DATE NOT NULL,
    StartTime TIME,
    EndTime TIME,
    Location VARCHAR(255),
    Organizer VARCHAR(100),  -- Can be a staff member or external
    Capacity INT,
    RegistrationDeadline DATE
);

-- ------------------------------------------------------------------------------
-- Table: EventRegistrations
-- Description:  Junction table for members registering for events (M-M relationship).
-- ------------------------------------------------------------------------------
CREATE TABLE EventRegistrations (
    RegistrationID INT AUTO_INCREMENT PRIMARY KEY,
    EventID INT,
    MemberID INT,
    RegistrationDate DATE NOT NULL,
    Status ENUM('Registered', 'Attended', 'Cancelled') NOT NULL DEFAULT 'Registered',
    FOREIGN KEY (EventID) REFERENCES Events(EventID),
    FOREIGN KEY (MemberID) REFERENCES Members(MemberID)
);

-- ------------------------------------------------------------------------------
--  Table: BookReviews
--  Description: Stores reviews for books.
-- ------------------------------------------------------------------------------
CREATE TABLE BookReviews (
    ReviewID INT AUTO_INCREMENT PRIMARY KEY,
    BookID INT,
    MemberID INT,
    Rating INT NOT NULL CHECK (Rating >= 1 AND Rating <= 5),  -- Constrain rating to 1-5
    ReviewText TEXT,
    ReviewDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (BookID) REFERENCES Books(BookID),
    FOREIGN KEY (MemberID) REFERENCES Members(MemberID)
);

-- ------------------------------------------------------------------------------
-- Table: LibrarySettings
-- Description:  Stores library-wide settings.  Useful for things like
--               default loan periods, fine rates, etc.  This makes
--               it easy to change these values without altering the
--               database schema.
-- ------------------------------------------------------------------------------
CREATE TABLE LibrarySettings (
    SettingID INT AUTO_INCREMENT PRIMARY KEY,
    SettingName VARCHAR(50) UNIQUE NOT NULL,
    SettingValue VARCHAR(255) NOT NULL,
    Description TEXT
);

-- Insert some default settings
INSERT INTO LibrarySettings (SettingName, SettingValue, Description) VALUES
    ('DefaultLoanDuration', '21', 'Default number of days for book loans'),
    ('FinePerDay', '0.50', 'Amount of fine per day for overdue books'),
    ('MaxBookLoans', '5', 'Maximum number of books a member can have loaned out at one time'),
    ('ReservationExpiryDays', '3', 'Number of days a reservation is valid after the book becomes available');
