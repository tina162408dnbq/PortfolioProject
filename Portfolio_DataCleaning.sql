/*
Cleaning Data in SQL Queries
*/

select * 
from PorfolioProject.Housing;

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

select SaleDate, convert(SaleDate, date)
from PorfolioProject.Housing;

update Housing
set  SaleDate = convert(SaleDate, date);





 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data
-- Explain: (it's having the same parcelID but one has propertyAddress, another one is null, so we populate the address 
-- because it litterally should have the same value)

select *
from PorfolioProject.Housing
order by ParcelID;

alter table Housing -- change datatype of ParcelID column from text to varchar(255)
modify column ParcelID varchar(255);

CREATE INDEX idx_ParcelID -- create index for table to make retreive data faster
ON Housing (ParcelID);

-- retrieve any data that has the same ParcelID
select a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress , ifnull(a.PropertyAddress, b.PropertyAddress)
from PorfolioProject.Housing a
join PorfolioProject.Housing b
	on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;



--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
-- Part A: split the PropertyAddress
select PropertyAddress
from PorfolioProject.Housing;

-- Try to check the splitting is correct or not 
select
substring(PropertyAddress, 1, locate(',', PropertyAddress)-1) as Address, 
substring(PropertyAddress, locate(',', PropertyAddress)+1, length(PropertyAddress)) as City
from PorfolioProject.Housing;

-- After making sure the split is correct, add a new column and update the table
-- Update the address after splitting
alter table Housing
Add PropertySplitAddress nvarchar(255);

update Housing
set PropertySplitAddress = substring(PropertyAddress, 1, locate(',', PropertyAddress)-1);

-- Update the city after splitting
alter table Housing
Add PropertySplitCity nvarchar(255);

update Housing
set PropertySplitCity = substring(PropertyAddress, 1, locate(',', PropertyAddress)-1);

-- Part B: split the Owner Address
Select ownerAddress
from PorfolioProject.Housing;

select 
substring_index(ownerAddress,',',-1), -- split the address from the right to get the State
substring_index(substring_index(ownerAddress,',',2),',',-1), -- get the string from the left and then substring the right part of the string
substring_index(ownerAddress,',',1) -- get the firat part of the string from the left 
-- substring_index(ownerAddress,',',1)
from PorfolioProject.Housing;

select 
-- substring_index(substring_index(ownerAddress,',',2),',',-1)
substring_index(ownerAddress,',',1)
from PorfolioProject.Housing;


alter table Housing
Add OwnerSplitAddress nvarchar(255);

update Housing
set OwnerSplitAddress = substring_index(ownerAddress,',',1);


alter table Housing
Add OwnerSplitCity nvarchar(255);

update Housing
set OwnerSplitCity = substring_index(substring_index(ownerAddress,',',2),',',-1);


alter table Housing
Add OwnerSplitState nvarchar(255);

update Housing
set OwnerSplitState = substring_index(ownerAddress,',',-1);

select *
from PorfolioProject.Housing;


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

-- Couting the distinct on SoldAsVacant
select distinct(SoldAsVacant)
from PorfolioProject.Housing;

select distinct(SoldAsVacant), count(SoldAsVacant)
from PorfolioProject.Housing
group by SoldAsVacant
order by 2;

Select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes' 
	 when SoldAsVacant = 'N' then 'No'
     else SoldAsVacant
     end
from PorfolioProject.Housing;


update Housing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes' 
	 when SoldAsVacant = 'N' then 'No'
     else SoldAsVacant
     end;
     




-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

-- show records that are duplicated in the table
Select ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference, count(*)
from PorfolioProject.Housing
group by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
having count(*) > 1;

-- Checking uniqueID is unique or not??
select uniqueID, count(*)
from PorfolioProject.Housing
group by UniqueID
having count(*) > 1;

-- delete those duplicate rows by keeping track the uniqueID
delete h1 from PorfolioProject.Housing h1
inner join PorfolioProject.Housing h2
where h1.uniqueID < h2.UniqueID 
	and h1.ParcelID = h2.ParcelID 
    and h1.PropertyAddress = h2.PropertyAddress
    and h1.SaleDate = h2.SaleDate
    and h1.SalePrice = h2.SalePrice
    and h1.LegalReference = h2.LegalReference;




-----------------------------------------------------------------------------------------------
-- Delete Unused Columns

select * 
from PorfolioProject.Housing;

alter table PorfolioProject.Housing
drop PropertyAddress,
drop OwnerAddress,
drop TaxDistrict;



-----------------------------------------------------------------------------------------------

-- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


-- sp_configure 'show advanced options', 1;
-- RECONFIGURE;
-- GO
-- sp_configure 'Ad Hoc Distributed Queries', 1;
-- RECONFIGURE;
-- GO


-- USE PortfolioProject 

-- GO 

-- EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

-- GO 

-- EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

-- GO 


-- Using BULK INSERT

-- USE PortfolioProject;
-- GO
-- BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
-- );
-- GO


-- Using OPENROWSET
-- USE PortfolioProject;
-- GO
-- SELECT * INTO nashvilleHousing
-- FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
-- GO