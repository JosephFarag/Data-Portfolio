/*

This project is based on Housing Data in Nashville.
We'll use various different SQL techniques to clean the dataset

*/

--Standardize Date Format

SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

-- Populate Property Address Data

SELECT *
FROM PortfolioProject..NashvilleHousing
-- WHERE PropertyAddress is NULL
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL


-- Breaking out Address into Individual Columns (address, City, State)

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject..NashvilleHousing

-- OwnerAddress

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM PortfolioProject..NashvilleHousing

-- Change Y and N to Yes and No in 'Sold as Vacant' field

SELECT DISTINCT(SoldasVacant), COUNT(SoldasVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldasVacant
Order by 2


SELECT DISTINCT(SoldasVacant),
  CASE When SoldasVacant = 'Y' THEN 'Yes'
	   WHEN SoldasVacant = 'N' THEN 'No'
	   ELSE SoldasVacant
	   END
FROM PortfolioProject..NashvilleHousing


UPDATE NashvilleHousing
SET SoldasVacant = CASE When SoldasVacant = 'Y' THEN 'Yes'
	   WHEN SoldasVacant = 'N' THEN 'No'
	   ELSE SoldasVacant
	   END


-- Remove Duplicates

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

FROM PortfolioProject..NashvilleHousing

)
SELECT *
FROM RowNumCTE
WHERE row_num > 1



-- Delete Unused Columns


SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
