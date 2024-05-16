# ArtFi NFT Sui

## Prerequisites

### Install Sui
You can also install Sui from binaries or from source, as detailed in the Install Sui page.
Go to [Install Sui](https://docs.sui.io/guides/developer/getting-started/sui-install).

Should have set active address and have native tokens in your wallet to execute transactions

### Sui Address
An address is a way to uniquely and anonymously identify an account that exists on the Sui blockchain network. In other words, an address is a way for a user to store and use tokens on the Sui network, without providing any personally identifying information
[Sui Address](https://docs.sui.io/guides/developer/getting-started/get-address)

### Faucet Sui Tokens
Sui faucet is a helpful tool where Sui developers can get free test SUI tokens to deploy and interact with their programs on Sui's Devnet and Testnet networks. There is no faucet for Sui Mainnet.
[Get Coins](https://docs.sui.io/guides/developer/getting-started/get-coins)

### Deploy NFT using script
- run `cd scripts && npm install` to install package
- return project directory
- run `./deploy_script.sh` to deploy NFT
    - - Enter admin address, to transfer admin, publisher and upgrade ID
    - - Enter name of NFT you want to give
    - - Enter description of NFT

## Cli Commands 

### Build
Use the following command to build package:

`sui move build`

A successful build returns a response similar to the following:

    UPDATING GIT DEPENDENCY https://github.com/MystenLabs/sui.git
    INCLUDING DEPENDENCY Sui
    INCLUDING DEPENDENCY MoveStdlib
    BUILDING collection

### Testing a package
Sui includes support for the Move testing framework. Using the framework, you can write unit tests that analyze Move code much like test frameworks for other languages, such as the built-in Rust testing framework or the JUnit framework for Java.

Use the following command to test package:

`sui move test`

### Publish a Package
Before you can call functions in a Move package (beyond an emulated Sui execution scenario), that package must be available on the Sui network. When you publish a package, you are actually creating an immutable Sui object on the network that anyone can access.

To publish your package to the Sui network, use the publish CLI command in the root of your package. Use the --gas-budget flag to set a value for the maximum amount of gas the transaction can cost. If the cost of the transaction is more than the budget you set, the transaction fails and your package doesn't publish.

`sui client publish --gas-budget <GAS>`

If the publish transaction is successful, your terminal or console responds with the details of the publish transaction separated into sections, including transaction data, transaction effects, transaction block events, object changes, and balance changes.

### Call function
To call a public function of package, use command.

`sui client call --package <PACKAGE-ID> --module <nft> --function <FUNCTION> --args <ARGUMENTS>  --gas-budget <GAS>`
