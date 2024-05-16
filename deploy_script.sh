echo "Enter Admin address"
read ADMIN
echo "Enter NFT name"
read NAME
echo "Enter NFT description"
read DESCRIPTION
node scripts/deploy.js
chmod +x scripts/deployed_addresses.json
PUBLISHERID=$(jq '.types_id | .[4]' scripts/deployed_addresses.json)
UPGRADEID=$(jq '.types_id | .[5]' scripts/deployed_addresses.json)
ADMINCAP=$(jq '.types_id | .[1]' scripts/deployed_addresses.json)
MINTERCAP=$(jq '.types_id | .[2]' scripts/deployed_addresses.json)
DISPLAY=$(jq '.types_id | .[3]' scripts/deployed_addresses.json)
PACKAGEID=$(jq '.PACKAGE_ID' scripts/deployed_addresses.json | tr -d '"')
sui client call --package $PACKAGEID --module nft --function transfer_publisher_object --args $ADMINCAP $PUBLISHERID $ADMIN --gas-budget 3038988
sui client call --package $PACKAGEID --module nft --function transfer_upgrade_cap --args $ADMINCAP $UPGRADEID $ADMIN --gas-budget 3038988
sui client call --package $PACKAGEID --module nft --function update_metadata --args $MINTERCAP $DISPLAY $NAME $DESCRIPTION --gas-budget 3038988
sui client call --package $PACKAGEID --module nft --function transfer_admin_cap --args $ADMINCAP $ADMIN --gas-budget 3038988