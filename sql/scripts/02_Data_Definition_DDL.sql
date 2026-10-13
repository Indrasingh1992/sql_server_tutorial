use MyDatabase;
/* ==============================================================================
   SQL Data Definition Language (DDL)
-------------------------------------------------------------------------------
   This guide covers the essential DDL commands used for defining and managing
   database structures, including creating, modifying, and deleting tables.

   Table of Contents:
     1. CREATE - Creating Tables
     2. ALTER - Modifying Table Structure
     3. DROP - Removing Tables
=================================================================================
*/

/* ============================================================================== 
   CREATE
=============================================================================== */

/* Create a new table called persons 
   with columns: id, person_name, birth_date, and phone */
Use MyDatabase;
-- check for the schema if table is already created but you are not known
-- If the table persons already exists, this will return the schema name
-- If it does not exist, it will return an empty result set

SELECT TABLE_SCHEMA
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME = 'persons';

/* Create with if not exist for table */
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'persons'
      AND TABLE_SCHEMA = 'dbo'  -- optional
)

BEGIN
   CREATE TABLE persons (
    id INT NOT NULL,
    person_name VARCHAR(50) NOT NULL,
    birth_date DATE,
    phone VARCHAR(15) NOT NULL,
    CONSTRAINT pk_persons PRIMARY KEY (id)
)
END
/* ============================================================================== 
   ALTER
=============================================================================== */

-- Add a new column called email to the persons table
ALTER TABLE persons
ADD email VARCHAR(50) NOT NULL

-- Remove the column phone from the persons table
ALTER TABLE persons
DROP COLUMN phone

/* ============================================================================== 
   DROP
=============================================================================== */

-- Delete the table persons from the database
DROP TABLE persons



select * from persons