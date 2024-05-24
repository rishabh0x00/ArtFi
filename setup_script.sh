PUBLISHERID_nft=         # first publisher id 
PUBLISHERID_gop_nft=     # second publisher id 
PUBLISHERID_gap_nft=     # third publisher id 
PUBLISHERID_trophy_nft=  # fourth publisher id 

UPGRADEID=               # upgrade cap id one

BASE_NFT_ADMINCAP=       # base nft admin cap
NFT_ADMINCAP=            # artfiNFT admin cap
GOP_NFT_ADMINCAP=        # gop admin cap
GAP_NFT_ADMINCAP=        # gap admin cap
TROPHY_NFT_ADMINCAP=     # trophy admin cap

NFT_MINTERCAP=           # nft minter cap

NFT_DISPLAY=             #  ArtfiNFT display object                                
GOP_NFT_DISPLAY=         #  gop nft display object
GAP_NFT_DISPLAY=         #  gap nft display object
TROPHY_NFT_DISPLAY=      #  trophy nft display object

NFT_NFTINFO=             # nft info of ArtfiNFT module
GOP_NFTINFO=             # nft info of GOP module
GAP_NFTINFO=             # nft info of GAP module
TROPHY_NFTINFO=          # nft info of Trophy module

ARTFI_NAME=""            #artfi name to update in metadata
ARTFI_DESCRIPTION=""     #artfi description to update in metadata

GOP_NAME=""              #GOP name to update in metadata
GOP_DESCRIPTION=""       #GOP description to update in metadata

GAP_NAME=""              #GAP name to update in metadata
GAP_DESCRIPTION=""       #GAP description to update in metadata

TROPHY_NAME=""           #Trophy name to update in metadata
TROPHY_DESCRIPTION=""    #Trophy description to update in metadata

PACKAGEID=               # package id

ADMIN=                   # new admin address

sui client call --package $PACKAGEID --module base_nft --function transfer_object --type-args 0x2::package::Publisher --args $PUBLISHERID_nft $ADMIN --gas-budget 3038988
sui client call --package $PACKAGEID --module base_nft --function transfer_object --type-args 0x2::package::Publisher --args $PUBLISHERID_gop_nft $ADMIN --gas-budget 3038988
sui client call --package $PACKAGEID --module base_nft --function transfer_object --type-args 0x2::package::Publisher --args $PUBLISHERID_gap_nft $ADMIN --gas-budget 3038988
sui client call --package $PACKAGEID --module base_nft --function transfer_object --type-args 0x2::package::Publisher --args $PUBLISHERID_trophy_nft $ADMIN --gas-budget 3038988
echo "transfer publisher object completed successfully"
sui client call --package $PACKAGEID --module base_nft --function transfer_object --type-args 0x2::package::UpgradeCap --args $UPGRADEID $ADMIN --gas-budget 3038988
echo "transfer UpgradeCap object completed successfully"
sui client call --package $PACKAGEID --module nft --function update_metadata --args $NFT_ADMINCAP $NFT_DISPLAY $NFT_NFTINFO $ARTFI_NAME $ARTFI_DESCRIPTION --gas-budget 3038988
sui client call --package $PACKAGEID --module gop --function update_metadata --args $GOP_NFT_ADMINCAP $GOP_NFT_DISPLAY $GOP_NFTINFO $GOP_NAME $GOP_DESCRIPTION --gas-budget 3038988
sui client call --package $PACKAGEID --module gap --function update_metadata --args $GAP_NFT_ADMINCAP $GAP_NFT_DISPLAY $GAP_NFTINFO $GAP_NAME $GAP_DESCRIPTION --gas-budget 3038988
sui client call --package $PACKAGEID --module trophy --function update_metadata --args $TROPHY_NFT_ADMINCAP $TROPHY_NFT_DISPLAY $TROPHY_NFTINFO $TROPHY_NAME $TROPHY_DESCRIPTION --gas-budget 3038988
echo "update metadata completed successfully"
sui client call --package $PACKAGEID --module base_nft --function transfer_object --type-args "0x2::display::Display<$PACKAGEID::nft::ArtfiNFT>" --args $NFT_DISPLAY $ADMIN --gas-budget 3038988
sui client call --package $PACKAGEID --module base_nft --function transfer_object --type-args "0x2::display::Display<$PACKAGEID::gop::GOPNFT>" --args $GOP_NFT_DISPLAY $ADMIN --gas-budget 3038988
sui client call --package $PACKAGEID --module base_nft --function transfer_object --type-args "0x2::display::Display<$PACKAGEID::gap::GAPNFT>" --args $GAP_NFT_DISPLAY $ADMIN --gas-budget 3038988
sui client call --package $PACKAGEID --module base_nft --function transfer_object --type-args "0x2::display::Display<$PACKAGEID::trophy::TrophyNFT>" --args $TROPHY_NFT_DISPLAY $ADMIN --gas-budget 3038988
echo "transfer Display object completed successfully"
sui client call --package $PACKAGEID --module base_nft --function transfer_admin_cap --args $BASE_NFT_ADMINCAP $ADMIN --gas-budget 3038988
sui client call --package $PACKAGEID --module nft --function transfer_admin_cap --args $NFT_ADMINCAP $ADMIN --gas-budget 3038988
sui client call --package $PACKAGEID --module gop --function transfer_admin_cap --args $GOP_NFT_ADMINCAP $ADMIN --gas-budget 3038988
sui client call --package $PACKAGEID --module gap --function transfer_admin_cap --args $GAP_NFT_ADMINCAP $ADMIN --gas-budget 3038988
sui client call --package $PACKAGEID --module trophy --function transfer_admin_cap --args $TROPHY_NFT_ADMINCAP $ADMIN --gas-budget 3038988
echo "transfer Admin cap object completed successfully"