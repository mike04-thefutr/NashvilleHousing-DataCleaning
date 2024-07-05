SELECT *
FROM dbo.NashvilleHousing 

-----------------------------------------------------------------------------------------------------------------
/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM NashvilleHousing

-----------------------------------------------------------------------------------------------------------------
----Standardize the date format
SELECT SaleDateConverted, CONVERT(date, SaleDate)
FROM dbo.NashvilleHousing

Update NashvilleHousing 
SET SaleDate = CONVERT(date, SaleDate)

ALTER TABLE NashvilleHousing 
ADD SaleDateConverted Date; 

UPDATE NashvilleHousing 
SET SaleDateConverted = CONVERT(date, SaleDate)

------------------------------------------------------------------------------------------------------------

---Populate Property Address Data 
SELECT *
FROM dbo.NashvilleHousing
---WHERE PropertyAddress is NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHousing a 
JOIN dbo.NashvilleHousing b 
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHousing a 
JOIN dbo.NashvilleHousing b 
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

------------------------------------------------------------------------------------------------------------
---Breaking out Address Into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM dbo.NashvilleHousing
---WHERE PropertyAddress is NULL
---ORDER BY ParcelID
 
-----charindex specifies a position 
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address 
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address 
FROM dbo.NashvilleHousing

------------------------------------------------------------------------------------------------------------
ALTER TABLE NashvilleHousing 
ADD PropertySplitAddress NVARCHAR(255); 

UPDATE NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE NashvilleHousing 
ADD PropertySplitCity NVARCHAR(255); 

UPDATE NashvilleHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT * 
FROM dbo.NashvilleHousing



SELECT OwnerAddress
FROM dbo.NashvilleHousing

----applying parsename and when to use it: delimited stuff, stuff delimited by a specific value, looks for periods too.
SELECT 
PARSENAME(REPLACE(OwnerAddress, ',','.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',','.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',','.') , 1)
FROM dbo.NashvilleHousing


ALTER TABLE NashvilleHousing 
ADD OwnerSplitAddress NVARCHAR(255); 

UPDATE NashvilleHousing 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.') , 3)


ALTER TABLE NashvilleHousing 
ADD OwnerSplitCity NVARCHAR(255); 

UPDATE NashvilleHousing 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.') , 2)


ALTER TABLE NashvilleHousing 
ADD OwnerSplitState NVARCHAR(255); 

UPDATE NashvilleHousing 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.') , 1)


SELECT * 
FROM dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------
---Change Y and N to Yes and No in "Sold As Vacant" column field 

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

----we then proceed to use case statements to change something to another term using when, then, else and end. 
---- after the query, you want to update table to reflect those changes you made within query 


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant ='Y' Then 'Yes'
       WHEN SoldAsVacant = 'N' Then 'No'
	   ELSE SoldAsVacant 
	   END 
FROM dbo.NashvilleHousing


UPDATE NashvilleHousing 
SET SoldAsVacant = CASE WHEN SoldAsVacant ='Y' Then 'Yes'
       WHEN SoldAsVacant = 'N' Then 'No'
	   ELSE SoldAsVacant 
	   END 

--------------------------------------------------------------------------------------------------------------------
----Removing Duplicates 

WITH RowNumCTE AS (
SELECT *, 
      ROW_NUMBER () OVER(
	  PARTITION BY ParcelID, 
	               PropertyAddress,
				   SalePrice,
				   SaleDate,
				   LegalReference 
				   ORDER BY 
				   UniqueID
				   ) row_num 
FROM dbo.NashvilleHousing
---ORDER BY ParcelID
) 
SELECT *    -----you type the function DELETE to remove duplicates then put SELECT * to see if duplicates been removed 
FROM RowNumCTE
WHERE row_num > 1 
---ORDER BY PropertyAddress

------------------------------------------------------------------------------------------------------------
---Delete Unused Columns 

SELECT * 
FROM dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE dbo.NashvilleHousing
DROP COLUMN SaleDate

--important takeaways, whole point of project is to clean the data and make it more usable 