# ArtFi NFT Sui

## Prerequisites

### Install Sui
You can install Sui from binaries or from source, as detailed on the Install Sui page.
Go to [Install Sui](https://docs.sui.io/guides/developer/getting-started/sui-install).

### Sui Address
An address  is a way to uniquely and anonymously identify an account that exists on the Sui blockchain network. 

Should have set [active-address](https://docs.sui.io/guides/developer/getting-started/get-address) to execute transactions.

### Faucet Sui Tokens
You will also need native tokens in your wallet to execute transactions.

Sui faucet is a helpful tool where Sui developers can get free test SUI tokens to deploy and interact with their programs on Sui's Devnet and Testnet networks.
[Get Coins](https://docs.sui.io/guides/developer/getting-started/get-coins)

### Deploy NFT using script

- Should have `jq` installed. Follow the link to set it up [Install jq](https://jqlang.github.io/jq/download/)
- Run `chmod +x setup_script.sh and chmod +x deploy_script.sh` to give permissions to execute
- Run `cd scripts && npm install` to install packages
- Return to the project directory using `cd ..`
- Create .env file 
    - Add network URL in which your NFT will be deployed, like mainnet, testnet and devnet
    - Add deployer keystore, it can be found by running the command `cat ~/.sui/sui_config/sui.keystore`
- Run `./deploy_script.sh` to deploy NFT
- Run `./setup_script.sh` to transfer object to new admin and update metadata of display
    - fill all fields in setup_script.sh, values can be found in deployed_addresses.json file
    - fill new admin address to change
    - fill name and description in setup_script.sh to update metadata of display in each module

## CLI Commands 

### Build
Use the following command to build the package:

`sui move build`

A successful build returns a response similar to the following:

    UPDATING GIT DEPENDENCY https://github.com/MystenLabs/sui.git
    INCLUDING DEPENDENCY Sui
    INCLUDING DEPENDENCY MoveStdlib
    BUILDING collection

### Testing a package
Sui includes support for the Move testing framework. Using the framework, you can write unit tests that analyze Move code much like test frameworks for other languages, such as the built-in Rust testing framework or the JUnit framework for Java.

Use the following command to test the package:

`sui move test`

### Publish a Package
Before you can call functions in a Move package (beyond an emulated Sui execution scenario), that package must be available on the Sui network. When you publish a package, you are actually creating an immutable Sui object on the network that anyone can access.

To publish your package to the Sui network, use the publish CLI command in the root of your package. Use the --gas-budget flag to set a value for the maximum amount of gas the transaction can cost. If the cost of the transaction is more than the budget you set, the transaction fails and your package doesn't publish.

`sui client publish --gas-budget <GAS>`

If the publish transaction is successful, your terminal or console responds with the details of the publish transaction separated into sections, including transaction data, transaction effects, transaction block events, object changes, and balance changes.

### Call function
To call a public function of package, use command.

`sui client call --package <PACKAGE-ID> --module <nft> --function <FUNCTION> --args <ARGUMENTS>  --gas-budget <GAS>`
