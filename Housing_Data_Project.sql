-- checking data

select * from nashville_housing 
fetch first 10 row only;

-- Populate Property Address

select * from nashville_housing
where PropertyAddress is null
order by parcelid;


select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, coalesce(a.propertyaddress,b.propertyaddress) from nashville_housing a
join nashville_housing b 
	on a.parcelid = b.parcelid
	and a.UniqueID <> b.UniqueID
where a.propertyaddress is null;

update nashville_housing
set propertyaddress = coalesce(a.propertyaddress,b.propertyaddress)
from nashville_housing a
join nashville_housing b 
	on a.parcelid = b.parcelid
	and a.UniqueID <> b.UniqueID
where a.propertyaddress is null;


-- Breaking out Address into Individual Columns using substrings

select propertyaddress from nashville_housing;

select 
substring(propertyaddress, 1, strpos(propertyaddress, ',') - 1) as Address,
substring(propertyaddress, strpos(propertyaddress, ',') + 1, length(propertyaddress)) as Address from nashville_housing;


alter table nashville_housing
add PropertySplitAddress varchar(255);

update nashville_housing
set PropertySplitAddress = substring(propertyaddress, 1, strpos(propertyaddress, ',') - 1) 

alter table nashville_housing
add PropertySplitCity varchar(255);

update nashville_housing
set PropertySplitCity = substring(propertyaddress, strpos(propertyaddress, ',') + 1, length(propertyaddress))


-- Breaking Out Owner Address Into Seperate Columns using split_part

select 
split_part(owneraddress, ',', 1), 
split_part(owneraddress, ',', 2), 
split_part(owneraddress, ',', 3) 
from nashville_housing

alter table nashville_housing
add OwnerSplitAddress varchar(255),
add OwnerSplitCity varchar(255),
add OwnerSplitState varchar(255);

update nashville_housing
set OwnersplitAddress = split_part(owneraddress, ',', 1),
set OwnersplitCity = split_part(owneraddress, ',', 2),
set OwnerSplitState = split_part(owneraddress, ',', 3);


-- Change y and n to yes and no in 'Sold as Vacant' field

select distinct(soldasvacant), count(soldasvacant) from nashville_housing
group by soldasvacant
order by 2;


select soldasvacant, case when soldasvacant = 'Y' then 'Yes'
	when soldasvacant = 'N' then 'No'
	else soldasvacant
	end
from nashville_housing;


update nashville_housing
set soldasvacant = case when soldasvacant = 'Y' then 'Yes'
	when soldasvacant = 'N' then 'No'
	else soldasvacant
	end;



--Removing Duplicates

with RowNumCTE as(
select *, row_number() over(
	partition by propertyaddress, 
	saleprice, 
	saledate, 
	legalreference
		order by uniqueid
		) row_num
from nashville_housing
)
select * from RowNumCTE
where row_num > 1

	
delete from nashville_housing
where parcelid in (
	select parcelid from (
						select parcelid,
							row_number() over (partition by propertyaddress, saleprice, saledate, legalreference) row_num
						from nashville_housing
					) s
					where row_num > 1
			)


-- Deleting Unused Columns

select * from nashville_housing

Alter table nashville_housing
drop column owneraddress,
drop column taxdistrict,
drop column propertyaddress