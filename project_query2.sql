USE Project;

/*
Cleaning Data in SQL Queries
*/

SELECT * FROM NashvilleHousing;



-- Standardize Date Format
SELECT SaleDate
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing                            -- Making new column where SaleDate will be stored in DATE format.
ADD SaleDateConverted DATE;                          

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE,SaleDate)

SELECT SaleDateConverted
FROM NashvilleHousing;




-- Populate Property Address data
SELECT *                                                --  There are NULL values in PropertyAddress Column.
FROM NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID;



SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress             -- Same ParcelIDs should have same PropertyAddress.
FROM NashvilleHousing a JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;



UPDATE a                                                                     -- Populating null values with the PropertyAddress of same corresponding ParcelID using ISNULL().
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ];


SELECT PropertyAddress 
FROM NashvilleHousing
WHERE PropertyAddress IS NULL;






-- Breaking out Address into Individual Columns (Address, City, State)
	
	-- First for PropertyAddress

SELECT PropertyAddress
FROM NashvilleHousing;


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,                   -- splitting the PropertyAddress by delimiter ',' to separate address from city using SUBSTRING().
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM NashvilleHousing;


ALTER TABLE NashvilleHousing                                   -- Making a new column to store only address of the property
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing                                        -- storing only the address in the PropertySplitAddress.
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);



ALTER TABLE NashvilleHousing                                   -- Making a new column to store only city in which the property is located
ADD PropertySplitCity NVARCHAR(255);


UPDATE NashvilleHousing											-- storing city names only in PropertySplitCity.
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));


SELECT * FROM NashvilleHousing;

	
	-- Now For OwnerAddress, separating address, city and state using PARSENAME().

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Address,
		PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City,
		 PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State
FROM NashvilleHousing;




ALTER TABLE NashvilleHousing                      -- Making New separate columns for address, city and state.
ADD OwnerSplitAddress NVARCHAR(255),
	OwnerSplitCity NVARCHAR(255),
	OwnerSplitState NVARCHAR(255);


UPDATE NashvilleHousing                             -- Updating those new columns(storing data in them)
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);



SELECT * FROM NashvilleHousing;




-- Change Y and N to Yes and No in "Sold as Vacant" field



SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant;



Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From .NashvilleHousing;



UPDATE NashvilleHousing											
SET SoldAsVacant = (CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END);



SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant;






-- Remove Duplicates

WITH RowNumCTE AS(									-- Counting the number of duplicate values using a CTE
SELECT *,
		ROW_NUMBER() OVER (							-- Finding the duplicate rows after partioning by some specific columns
		PARTITION BY ParcelID,						-- Row number = n indicates that the row appeared for the nth time(n = 1 implies unique row & n > 1 implies duplicate row)
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
						ORDER BY 
						   UniqueID
						   ) row_num
FROM NashvilleHousing
)
SELECT COUNT(*)
FROM RowNumCTE
WHERE row_num >1;



WITH RowNumCTE AS(						-- Deleting the duplicate rows.
SELECT *,
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
						ORDER BY 
						   UniqueID
						   ) row_num
FROM NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num >1;




WITH RowNumCTE AS(
SELECT *,
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
						ORDER BY 
						   UniqueID
						   ) row_num
FROM NashvilleHousing
)
SELECT COUNT(*)
FROM RowNumCTE
WHERE row_num >1;







-- Delete Unused Columns



Select *
From NashvilleHousing


ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate