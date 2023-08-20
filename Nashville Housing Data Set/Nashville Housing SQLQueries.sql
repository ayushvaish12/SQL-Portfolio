/*
Cleaning Housing Data in SQL
*/

SELECT *
FROM [Nashville Housing Data Cleaning]..NashvilleHousing

--Formating  all the dates

SELECT [Sale Date] ,CONVERT(Date,[Sale Date])
FROM [Nashville Housing Data Cleaning]..NashvilleHousing

ALTER TABLE [Nashville Housing Data Cleaning]..NashvilleHousing
Add SaleDateFormatted Date;

UPDATE [Nashville Housing Data Cleaning]..NashvilleHousing
SET SaleDateFormatted = CONVERT(date,[Sale Date]);


--Populating Property Address Column (some rows contains null values)

SELECT [Property Address],[Parcel ID],City,State,Neighborhood,SaleDateFormatted
FROM [Nashville Housing Data Cleaning]..NashvilleHousing
Where [Property Address] is null;


SELECT a.[Parcel ID],a.[Property Address],b.[Parcel ID],b.[Property Address], ISNULL(a.[Property Address],b.[Property Address])
FROM [Nashville Housing Data Cleaning]..NashvilleHousing a
Join [Nashville Housing Data Cleaning]..NashvilleHousing b
	on a.[Parcel ID] = b.[Parcel ID]
	AND a.UniqueID <> b.UniqueID
WHERE a.[Property Address] is null


UPDATE a
SET [Property Address] = ISNULL(a.[Property Address],b.[Property Address])
FROM [Nashville Housing Data Cleaning]..NashvilleHousing a
Join [Nashville Housing Data Cleaning]..NashvilleHousing b
	on a.[Parcel ID] = b.[Parcel ID]
	AND a.UniqueID <> b.UniqueID
WHERE a.[Property Address] is null


--Formating address Splitting into diff columns (Address, City, State, Street etc)

--To seperate string where comma is found (by charindex)

SELECT [Property Address], try_cast(Trim(SUBSTRING([Property Address],1,CHARINDEX(' ',[Property Address]))) as float) as HouseNo,
TRIM(SUBSTRING([Property Address],CHARINDEX(' ',[Property Address])+1,LEN([Property Address]))) as Street
FROM [Nashville Housing Data Cleaning]..NashvilleHousing


ALTER TABLE [Nashville Housing Data Cleaning]..NashvilleHousing
ALTER Column HouseNo Nvarchar(255); -- changed datatype

UPDATE [Nashville Housing Data Cleaning]..NashvilleHousing
SET HouseNo = Trim(SUBSTRING([Property Address],1,CHARINDEX(' ',[Property Address])));

ALTER TABLE [Nashville Housing Data Cleaning]..NashvilleHousing
Add Street Nvarchar(255);

UPDATE [Nashville Housing Data Cleaning]..NashvilleHousing
SET Street = TRIM(SUBSTRING([Property Address],CHARINDEX(' ',[Property Address])+1,LEN([Property Address])));

--Use of Parsename can be used but it works backwards

--Replace some of the Y and N to Yes & No respectively

SELECT distinct([Sold As Vacant]),COUNT([Sold As Vacant])
FROM [Nashville Housing Data Cleaning]..NashvilleHousing
group by [Sold As Vacant] order by 2




SELECT [Sold As Vacant]
, CASE When [Sold As Vacant] ='Y' THEN 'Yes'
	   When [Sold As Vacant] = 'N' THEN 'No'
	   else [Sold As Vacant]
	   END
FROM [Nashville Housing Data Cleaning]..NashvilleHousing

Update NashvilleHousing
SET [Sold As Vacant] = CASE When [Sold As Vacant] ='Y' THEN 'Yes'
	   When [Sold As Vacant] = 'N' THEN 'No'
	   else [Sold As Vacant]
	   END


-- Remove duplicate values
WITH RownoCte as (
SELECT *,	
ROW_NUMBER() OVER (
Partition by [Parcel ID],
			 [Property Address],
			 [Sale Price],
			 [Sale Date],
			 [Legal Reference]
			 ORDER BY
			 UniqueID
) row_num
FROM [Nashville Housing Data Cleaning]..NashvilleHousing
)
SELECT * --to delete use DELETE FROM -----remove order by
FROM RownoCte
WHERE row_num>1
Order by [Property Address]


-- Delete unused columns

ALTER TABLE [Nashville Housing Data Cleaning]..NashvilleHousing
DROP COLUMN columnnames;