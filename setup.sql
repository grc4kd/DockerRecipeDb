/*

Enter custom T-SQL here that would run after SQL Server has started up. 

*/

CREATE LOGIN testuser WITH PASSWORD = 'testing-change-me-123';
CREATE USER testuser FOR LOGIN testuser;
ALTER SERVER ROLE sysadmin ADD MEMBER testuser;
ALTER LOGIN sa DISABLE;
CREATE DATABASE RecipeDb;
GO
