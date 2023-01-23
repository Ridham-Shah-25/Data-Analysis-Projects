select *
from PortfolioProject.dbo.NashvilleHousing

-- Standardize Date Format


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ALTER column SaleDate date



--Populate Property Address Data

SELECT *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

Update a 
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


--Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255)

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255)

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255)

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255)

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255)

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1)


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT Distinct(SoldAsVacant),COUNT(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

Select SoldAsVacant,
CASE When SoldAsVacant='Y' THEN 'Yes'
	 When SoldAsVacant='N' THEN 'No'
	 ELSE SoldAsVacant
	 end
from PortfolioProject.dbo.NashvilleHousing

Update PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant=
CASE When SoldAsVacant='Y' THEN 'Yes'
	 When SoldAsVacant='N' THEN 'No'
	 ELSE SoldAsVacant
	 end


-- Remove Duplicates


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID) 
					row_num
From PortfolioProject.dbo.NashvilleHousing
)
SELECT *
From RowNumCTE
Where row_num > 1


--Delete Unused Columns


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

select *
from PortfolioProject.dbo.NashvilleHousing

