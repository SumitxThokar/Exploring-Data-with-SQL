-- Data Cleaning with SQL
select * from NashvilleHousing

-- Standardize the SaleDate
select convSaleDate,cast(SaleDate as Date) from NashvilleHousing

alter table NashvilleHousing
add convSaleDate Date;

update NashvilleHousing
set convSaleDate=cast(SaleDate as Date)

-- Populating the property address ddata
select * from NashvilleHousing 

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress) from NashvilleHousing a
join NashvilleHousing b on a.ParcelID=b.ParcelID
where a.PropertyAddress is null and b.PropertyAddress is not null

update a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b on a.ParcelID=b.ParcelID
where a.PropertyAddress is null and b.PropertyAddress is not null

-- Breaking out Address into Individual column (Address, City, State)
select * from NashvilleHousing

select PropertyAddress,SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as State
from NashvilleHousing

alter table NashvilleHousing
add PropSplitAddress nvarchar(255);

update NashvilleHousing
set PropSplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

alter table NashvilleHousing
add PropSplitCity nvarchar(255);

update NashvilleHousing
set PropSplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

select * from NashvilleHousing

select PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from NashvilleHousing 

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1)

-- Changing Y, N in 'SoldAsVacant' column into Yes, No using CASE statement
select Distinct(SoldAsVacant) from NashvilleHousing

select SoldAsVacant, 
CASE WHEN SoldAsVacant='Y' THEN 'YES'
	 WHEN SoldAsVacant='N' THEN 'No'
	 ELSE SoldAsVacant
	 END
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant= CASE WHEN SoldAsVacant='Y' THEN 'YES'
	 WHEN SoldAsVacant='N' THEN 'No'
	 ELSE SoldAsVacant
	 END

-- Removing Duplicates. ( Without using UniqueID)
WITH RowNumCTE as (
select * ,
ROW_NUMBER()Over (Partition by ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference ORDER BY UniqueID) row_num
from NashvilleHousing
)
--order by row_num desc,ParcelID
--Delete
--from RowNumCTE 
--where row_num>1 

select *
from RowNumCTE 
where row_num>1 

-- Deleting Unused column
select * from NashvilleHousing

alter table NashVilleHousing
DROP COLUMN PropertyAddress,OwnerAddress,TaxDistrict

alter table NashVilleHousing
DROP COLUMN SaleDate