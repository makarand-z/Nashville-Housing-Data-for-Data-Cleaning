
-- Cleaning up the data

SELECT * FROM mak_test.dbo.NashvilleHousing


-- Standardizing date

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

Select SaleDateconverted, CONVERT(Date,SaleDate) as Date
From mak_test.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateconverted Date;

Update NashvilleHousing
SET SaleDateconverted = CONVERT(Date,SaleDate)


-- Populating Property Address

SELECT * 
FROM mak_test.dbo.NashvilleHousing			--identifying nulls in PropertyAddress
--where PropertyAddress is null
order by ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, COALESCE(a.PropertyAddress, b.PropertyAddress) 
FROM mak_test.dbo.NashvilleHousing a
JOIN mak_test.dbo.NashvilleHousing b   
	ON a.ParcelID = b.ParcelID				--comparing nulls in PropertyAddress
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM mak_test.dbo.NashvilleHousing a
JOIN mak_test.dbo.NashvilleHousing b		--replacing nulls with correct values
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null


-- Splitting address into individual columns - Street name, City, State

SELECT PropertyAddress 
FROM mak_test.dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM mak_test.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)					--updating PropertySplitAddress using SUBSTRING

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT * 
FROM mak_test.dbo.NashvilleHousing

SELECT  
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM mak_test.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)											--updating OwnerSplitAddress using PARSENAME

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

SELECT * 
FROM mak_test.dbo.NashvilleHousing


-- Changing  Y and N in Sold as vacant column

SELECT SoldAsVacant,
	CASE When SoldAsVacant = 'Y' THEN 'Yes'
		 When SoldAsVacant = 'N' THEN 'No'																		
		 ELSE SoldAsVacant
		 END
FROM mak_test.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'														--standardizing values of SoldAsVacant col
		 When SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END

-- Removing Duplicates


WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
			 SalePrice,                 
			 SaleDate,
			 LegalReference
			 ORDER BY 
			 UniqueID) as row_num
FROM mak_test.dbo.NashvilleHousing)
SELECT * FROM RowNumCTE
WHERE row_num > 1	                --selecting duplicates
ORDER BY PropertyAddress

WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
			 SalePrice,                 
			 SaleDate,
			 LegalReference
			 ORDER BY 
			 UniqueID) as row_num
FROM mak_test.dbo.NashvilleHousing)
DELETE FROM RowNumCTE
WHERE row_num > 1					--deleting duplicates


-- Deleting unused columns

ALTER TABLE mak_test.dbo.NashvilleHousing 
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict, SaleDate
