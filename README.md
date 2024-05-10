# ArtFi NFT Sui


## Cli Commands 

### Build
Use the following command to build package:

- sui move build

A successful build returns a response similar to the following:

    UPDATING GIT DEPENDENCY https://github.com/MystenLabs/sui.git
    INCLUDING DEPENDENCY Sui
    INCLUDING DEPENDENCY MoveStdlib
    BUILDING hello_sui


### Testing a package
Sui includes support for the Move testing framework. Using the framework, you can write unit tests that analyze Move code much like test frameworks for other languages, such as the built-in Rust testing framework or the JUnit framework for Java.

Use the following command to test package:

- sui move test

A successful test returns a response similar to the following:

    INCLUDING DEPENDENCY Sui
    INCLUDING DEPENDENCY MoveStdlib
    BUILDING hello_sui
    Running Move unit tests
    [ PASS    ] 0x0::nft_tests::nft_artfi_royalty_test
    [ PASS    ] 0x0::nft_tests::nft_artist_royalty_test
    [ PASS    ] 0x0::nft_tests::nft_description_test
    [ PASS    ] 0x0::nft_tests::nft_name_test
    [ PASS    ] 0x0::nft_tests::nft_royalty_test
    [ PASS    ] 0x0::nft_tests::nft_stakingContract_royalty_test
    [ PASS    ] 0x0::nft_tests::nft_url_test
    [ PASS    ] 0x0::nft_tests::test_burn_nft
    [ PASS    ] 0x0::nft_tests::test_mint_nft
    [ PASS    ] 0x0::nft_tests::test_module_init
    [ PASS    ] 0x0::nft_tests::test_transfer_admin_cap
    [ PASS    ] 0x0::nft_tests::test_transfer_minter_cap
    [ PASS    ] 0x0::nft_tests::test_transfer_nft
    [ PASS    ] 0x0::nft_tests::test_will_error_on_transfer_admin_cap_by_other_address
    [ PASS    ] 0x0::nft_tests::test_will_error_on_transfer_minter_cap_by_other_address
    [ PASS    ] 0x0::nft_tests::test_will_error_on_transfer_nft_by_other_address
    [ PASS    ] 0x0::nft_tests::update_description_test
    Test result: OK. Total tests: 17; passed: 17; failed: 0

### Publish a Package
Before you can call functions in a Move package (beyond an emulated Sui execution scenario), that package must be available on the Sui network. When you publish a package, you are actually creating an immutable Sui object on the network that anyone can access.

To publish your package to the Sui network, use the publish CLI command in the root of your package. Use the --gas-budget flag to set a value for the maximum amount of gas the transaction can cost. If the cost of the transaction is more than the budget you set, the transaction fails and your package doesn't publish.

- sui client publish --gas-budget `GAS`

If the publish transaction is successful, your terminal or console responds with the details of the publish transaction separated into sections, including transaction data, transaction effects, transaction block events, object changes, and balance changes.

### Upgrading
Use command to upgrade packages that meet the previous requirements
- sui client upgrade --gas-budget `GAS-BUDGET-AMOUNT` --upgrade-capability `UPGRADE-CAP-ID`

providing values for the following flags:

-   --gas-budget: The maximum number of gas units that can be expended before the network cancels the transaction.
- --upgrade-capability: The ID of the UpgradeCap. You receive this ID as a return from the publish command.

To make sure your other packages can use this package as a dependency, you must update the manifest (Move.toml file) for your package to include this information.

Update the alias address and add a new published-at entry in the [package] section, both pointing to the value of the on-chain ID:

The `published-at` value allows the Move compiler to verify dependencies against on-chain versions of those packages.

#### Upgrade requirements
To upgrade a package, your package must satisfy the following requirements:

- You must have an `UpgradeTicket` for the package you want to upgrade. The Sui network issues `UpgradeCaps` when you publish a package, then you can issue UpgradeTickets as the owner of that UpgradeCap. The Sui Client CLI handles this requirement automatically.
- Your changes must be layout-compatible with the previous version.
    - Existing public function signatures must remain the same.
    - Existing struct layouts (including struct abilities) must remain the same.
    - You can add new structs and functions.
    - You can remove generic type constraints from existing functions (public or otherwise).
    - You can change function implementations.
    - You can change non-public function signatures, including friend and entry function signatures.

### Call function
To call a public function of package, use command.
- sui client call --package `PACKAGE-ID` --module `nft` --function `FUNCTION` --args `ARGUMENTS`  --gas-budget `GAS`
