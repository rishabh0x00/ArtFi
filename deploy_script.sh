echo "provide gas for deployment"
read GAS
sui client publish --gas-budget $GAS