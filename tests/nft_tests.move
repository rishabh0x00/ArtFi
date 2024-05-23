#[test_only]
module collection::nft_tests {
    // Test attribute is placed before the `fun` keyword. Can be both above or
    // right before the `fun` keyword: `#[test] fun my_test() { ... }`
    // The name of the test would be `book::testing::simple_test`.
    #[test_only]
    use collection::nft;
    use collection::base_nft;
    use sui::url;
    use std::string;
    use sui::tx_context;
    use sui::object;
    use sui::package;

    #[test_only] use sui::test_utils;
    #[test_only] use sui::test_scenario;
    #[test_only] use sui::display;

    #[test]
    // test `name` function
    fun nft_name_test() {
        let name = b"Artfi";
        let nft_url = b"Artfi_NFT";
        let fraction_id = 12;
        let artfi_royalty = 4;
        let artist_royalty = 3;
        let staking_contract_royalty = 3;
        let royalty = nft::new_royalty(artfi_royalty, artist_royalty, staking_contract_royalty);
        let nft_info = nft::new_nft_info(string::utf8(name), royalty);
        let test_net_nft = nft::new_artfi_nft(
            string::utf8(name),
            url::new_unsafe_from_bytes(nft_url), 
            fraction_id,
            &mut nft_info,
            &mut tx_context::dummy()
        );

        assert!(nft::name(&test_net_nft) == &string::utf8(b"Artfi"), 1);

        let dummy_address = @0xCAFE;
        sui::transfer::public_transfer(test_net_nft, dummy_address);
        test_utils::destroy<nft::NFTInfo>(nft_info);
        
    }

    // test `description` function
    #[test]
    fun nft_description_test() {
        let initial_owner = @0xCAFE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            nft::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario,initial_owner);
        {
            let display_object = test_scenario::take_from_sender<display::Display<nft::ArtfiNFT>>(&scenario);

            assert!(nft::description(&display_object) == string::utf8(b"Artfi NFT"), 1);

            test_scenario::return_to_sender<display::Display<nft::ArtfiNFT>>(&scenario, display_object);
        };

        test_scenario::end(scenario);
    }

    #[test]
    // test `url` function
    fun nft_url_test() {
        let name = b"Artfi";
        let nft_url = b" ";
        let fraction_id = 12;
        let artfi_royalty = 4;
        let artist_royalty = 3;
        let staking_contract_royalty = 3;
        let royalty = nft::new_royalty(artfi_royalty, artist_royalty, staking_contract_royalty);
        let nft_info = nft::new_nft_info(string::utf8(name), royalty);
        let test_net_nft = nft::new_artfi_nft(
            string::utf8(name),
            url::new_unsafe_from_bytes(nft_url), 
            fraction_id,
            &mut nft_info,
            &mut tx_context::dummy()
        );
        assert!(nft::url(&test_net_nft) ==  &url::new_unsafe_from_bytes(nft_url), 1);

        test_utils::destroy<nft::ArtfiNFT>(test_net_nft);
        test_utils::destroy<nft::NFTInfo>(nft_info);
    }

    #[test]
    // test `royalty`
    fun nft_royalty_test() {
        let name = b"Artfi";
        let nft_url = b" ";
        let fraction_id = 12;
        let artfi_royalty = 4;
        let artist_royalty = 3;
        let staking_contract_royalty = 3;
        let royalty = nft::new_royalty(artfi_royalty, artist_royalty, staking_contract_royalty);
        let nft_info = nft::new_nft_info(string::utf8(name), royalty);
        let test_net_nft = nft::new_artfi_nft(
            string::utf8(name),
            url::new_unsafe_from_bytes(nft_url), 
            fraction_id,
            &mut nft_info,
            &mut tx_context::dummy()
        );
        let royalty_instance = nft::new_royalty(4, 3, 3); 
        assert!(nft::royalty(&test_net_nft, &nft_info) == royalty_instance, 1);

        test_utils::destroy<nft::ArtfiNFT>(test_net_nft);
        test_utils::destroy<nft::Royalty>(royalty_instance);
        test_utils::destroy<nft::NFTInfo>(nft_info);
    }

    #[test]
    // test `artfi`
    fun nft_artfi_royalty_test() {
        let name = b"Artfi";
        let nft_url = b" ";
        let fraction_id = 12;
        let artfi_royalty = 4;
        let artist_royalty = 3;
        let staking_contract_royalty = 3;
        let royalty = nft::new_royalty(artfi_royalty, artist_royalty, staking_contract_royalty);
        let nft_info = nft::new_nft_info(string::utf8(name), royalty);
        let test_net_nft = nft::new_artfi_nft(
            string::utf8(name),
            url::new_unsafe_from_bytes(nft_url), 
            fraction_id,
            &mut nft_info,
            &mut tx_context::dummy()
        );
        assert!(nft::artfi_royalty(&test_net_nft, &nft_info) ==  4, 1);

        test_utils::destroy<nft::ArtfiNFT>(test_net_nft);
        test_utils::destroy<nft::NFTInfo>(nft_info);
    }

    #[test]
    // test `artist`
    fun nft_artist_royalty_test() {
        let name = b"Artfi";
        let nft_url = b" ";
        let fraction_id = 12;
        let artfi_royalty = 4;
        let artist_royalty = 3;
        let staking_contract_royalty = 3;
        let royalty = nft::new_royalty(artfi_royalty, artist_royalty, staking_contract_royalty);
        let nft_info = nft::new_nft_info(string::utf8(name), royalty);
        let test_net_nft = nft::new_artfi_nft(
            string::utf8(name),
            url::new_unsafe_from_bytes(nft_url), 
            fraction_id,
            &mut nft_info,
            &mut tx_context::dummy()
        );
        assert!(nft::artist_royalty(&test_net_nft, &nft_info) ==  3, 1);

        test_utils::destroy<nft::ArtfiNFT>(test_net_nft);
        test_utils::destroy<nft::NFTInfo>(nft_info);
    }

    #[test]
    // test `staking contract`
    fun nft_staking_contract_royalty_test() {
        let name = b"Artfi";
        let nft_url = b" ";
        let fraction_id = 12;
        let artfi_royalty = 4;
        let artist_royalty = 3;
        let staking_contract_royalty = 3;
        let royalty = nft::new_royalty(artfi_royalty, artist_royalty, staking_contract_royalty);
        let nft_info = nft::new_nft_info(string::utf8(name), royalty);
        let test_net_nft = nft::new_artfi_nft(
            string::utf8(name),
            url::new_unsafe_from_bytes(nft_url), 
            fraction_id,
            &mut nft_info,
            &mut tx_context::dummy()
        );
        assert!(nft::staking_contract_royalty(&test_net_nft, &nft_info) ==  3, 1);

        test_utils::destroy<nft::ArtfiNFT>(test_net_nft);
        test_utils::destroy<nft::NFTInfo>(nft_info);
    }

    #[test]
    fun test_module_init() {

        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            nft::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario,initial_owner);
        {
            let admin_cap = test_scenario::take_from_sender<nft::AdminCap>(&scenario);

            nft::transfer_minter_cap(&admin_cap, final_owner, test_scenario::ctx(&mut scenario));

             test_utils::destroy<nft::AdminCap>(admin_cap);

        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_transfer_minter_cap() {

        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            nft::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario,initial_owner);
        {
            let admin_cap = test_scenario::take_from_sender<nft::AdminCap>(&scenario);

            nft::transfer_minter_cap(&admin_cap, final_owner, test_scenario::ctx(&mut scenario));

             test_utils::destroy<nft::AdminCap>(admin_cap);

        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_transfer_admin_cap() {

        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            nft::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario,initial_owner);
        {
            let admin_cap = test_scenario::take_from_sender<nft::AdminCap>(&scenario);

            nft::transfer_admin_cap(admin_cap, final_owner, test_scenario::ctx(&mut scenario));

        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_publisher() {

        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            nft::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario,initial_owner);
        {
            let publisher = test_scenario::take_from_sender<package::Publisher>(&scenario);

            base_nft::transfer_object(publisher, final_owner, test_scenario::ctx(&mut scenario));
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_mint_nft() {

        let url = b" ";
        let fraction_id = 12;

        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            nft::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {

            let minter_cap = test_scenario::take_from_sender<nft::MinterCap>(&scenario);
            let nft_info = test_scenario::take_shared<nft::NFTInfo>(&scenario);
            nft::mint_nft(
                &minter_cap, 
                &mut nft_info,
                url, 
                final_owner, 
                fraction_id, 
                test_scenario::ctx(&mut scenario)
            );

            test_utils::destroy<nft::MinterCap>(minter_cap);
            test_scenario::return_shared(nft_info);
        };

        test_scenario::next_tx(&mut scenario,final_owner);
        {
            let nftToken = test_scenario::take_from_sender<nft::ArtfiNFT>(&scenario);

            assert!(nft::name(&nftToken) == &string::utf8(b"Artfi"), 1);
            assert!(nft::url(&nftToken) == &url::new_unsafe_from_bytes(url), 1);
            let royalty_instance = nft::new_royalty(4, 3, 3);

            let nft_info = test_scenario::take_shared<nft::NFTInfo>(&scenario);
            assert!(nft::royalty(&nftToken, &nft_info) == royalty_instance, 1);

            test_utils::destroy<nft::ArtfiNFT>(nftToken);
            test_utils::destroy<nft::Royalty>(royalty_instance);
            test_scenario::return_shared<nft::NFTInfo>(nft_info);
            
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_mint_batch_nft() {

        let url = vector[b" "];
        let fraction_id = vector[12];

        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            nft::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {

            let minter_cap = test_scenario::take_from_sender<nft::MinterCap>(&scenario);
            let nft_info = test_scenario::take_shared<nft::NFTInfo>(&scenario);

            nft::mint_nft_batch(
                &minter_cap, 
                &mut nft_info,
                &url, 
                &vector[final_owner], 
                &fraction_id, 
                test_scenario::ctx(&mut scenario)
            );

            test_utils::destroy<nft::MinterCap>(minter_cap);
            test_scenario::return_shared<nft::NFTInfo>(nft_info);
        };

        test_scenario::next_tx(&mut scenario,final_owner);
        {
            let nftToken = test_scenario::take_from_sender<nft::ArtfiNFT>(&scenario);

            assert!(nft::name(&nftToken) == &string::utf8(b"Artfi"), 1);
            assert!(nft::url(&nftToken) == &url::new_unsafe_from_bytes(b" "), 1);

            let royalty_instance = nft::new_royalty(4, 3, 3);

            let nft_info = test_scenario::take_shared<nft::NFTInfo>(&scenario);
            assert!(nft::royalty(&nftToken, &nft_info) == royalty_instance, 1);
            test_utils::destroy<nft::ArtfiNFT>(nftToken);
            test_utils::destroy<nft::Royalty>(royalty_instance);
            test_scenario::return_shared<nft::NFTInfo>(nft_info);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_transfer_nft() {

        let url = b" ";
        let fraction_id = 12;

        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;
        let user = @0xEAFF;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            nft::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {

            let minter_cap = test_scenario::take_from_sender<nft::MinterCap>(&scenario);
            let nft_info = test_scenario::take_shared<nft::NFTInfo>(&scenario);

            nft::mint_nft(
                &minter_cap, 
                &mut nft_info,
                url, 
                final_owner, 
                fraction_id, 
                test_scenario::ctx(&mut scenario)
            );

            test_utils::destroy<nft::MinterCap>(minter_cap);
            test_scenario::return_shared<nft::NFTInfo>(nft_info);
        };

        test_scenario::next_tx(&mut scenario,final_owner);
        {
            let nftToken = test_scenario::take_from_sender<nft::ArtfiNFT>(&scenario);

            base_nft::transfer_object<nft::ArtfiNFT>(nftToken, user, test_scenario::ctx(&mut scenario));
            
        };

        test_scenario::next_tx(&mut scenario, user);
        {
            let nftToken = test_scenario::take_from_sender<nft::ArtfiNFT>(&scenario);

            assert!(nft::name(&nftToken) == &string::utf8(b"Artfi"), 1);
            assert!(nft::url(&nftToken) == &url::new_unsafe_from_bytes(url), 1);
            let royalty_instance = nft::new_royalty(4, 3, 3);

            let nft_info = test_scenario::take_shared<nft::NFTInfo>(&scenario);
            assert!(nft::royalty(&nftToken, &nft_info) == royalty_instance, 1);

            test_utils::destroy<nft::ArtfiNFT>(nftToken);
            test_utils::destroy<nft::Royalty>(royalty_instance);
            test_scenario::return_shared<nft::NFTInfo>(nft_info);
        };

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = test_scenario::EEmptyInventory)] 
    fun test_burn_nft() {
        let url = b" ";
        let fraction_id = 12;

        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            nft::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {

            let minter_cap = test_scenario::take_from_sender<nft::MinterCap>(&scenario);
            let display_object = test_scenario::take_from_sender<display::Display<nft::ArtfiNFT>>(&scenario);
            let nft_info = test_scenario::take_shared<nft::NFTInfo>(&scenario);

            nft::mint_nft(
                &minter_cap, 
                &mut nft_info,
                url, 
                final_owner, 
                fraction_id, 
                test_scenario::ctx(&mut scenario)
            );

            test_utils::destroy<nft::MinterCap>(minter_cap);
            test_utils::destroy<display::Display<nft::ArtfiNFT>>(display_object);
            test_scenario::return_shared<nft::NFTInfo>(nft_info);
            
        };

        test_scenario::next_tx(&mut scenario,final_owner);
        let nftToken;
        {
            nftToken = test_scenario::take_from_sender<nft::ArtfiNFT>(&scenario);
        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {   
            let admin_cap = test_scenario::take_from_sender<nft::AdminCap>(&scenario);
            let nft_info = test_scenario::take_shared<nft::NFTInfo>(&scenario);

            nft::burn(nftToken, &mut nft_info, test_scenario::ctx(&mut scenario));

            test_utils::destroy<nft::AdminCap>(admin_cap); 
            test_scenario::return_shared<nft::NFTInfo>(nft_info);
        };

        test_scenario::next_tx(&mut scenario, final_owner);
        {
            let nftToken = test_scenario::take_from_sender<nft::ArtfiNFT>(&scenario);

            test_utils::destroy<nft::ArtfiNFT>(nftToken);            
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_update_royalty() {

        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            nft::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {   
            let mintCap = test_scenario::take_from_sender<nft::MinterCap>(&scenario);
            let nft_info = test_scenario::take_shared<nft::NFTInfo>(&scenario);

            nft::update_royalty(&mintCap, &mut nft_info, 5, 4 , 3, test_scenario::ctx(&mut scenario));

            test_utils::destroy<nft::MinterCap>(mintCap); 
            test_scenario::return_shared<nft::NFTInfo>(nft_info);
        };

        test_scenario::next_tx(&mut scenario, final_owner);
        {
            let nft_info = test_scenario::take_shared<nft::NFTInfo>(&scenario);
            let (artfi, artist, staking_contract) = nft::get_default_royalty_fields(&nft_info);
            assert!(artfi == 5, 1);
            assert!(artist == 4, 1);
            assert!(staking_contract == 3, 1);

            test_scenario::return_shared<nft::NFTInfo>(nft_info);           
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_update_nft_royalty() {

        let url = b" ";
        let fraction_id = 12;
        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            nft::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {

            let minter_cap = test_scenario::take_from_sender<nft::MinterCap>(&scenario);
            let nft_info = test_scenario::take_shared<nft::NFTInfo>(&scenario);

            nft::mint_nft(
                &minter_cap, 
                &mut nft_info,
                url, 
                final_owner, 
                fraction_id, 
                test_scenario::ctx(&mut scenario)
            );

            test_scenario::return_to_sender<nft::MinterCap>(&scenario, minter_cap);
            test_scenario::return_shared<nft::NFTInfo>(nft_info);
            
        };

        let nft_id;
        test_scenario::next_tx(&mut scenario, final_owner);
        {   
            let nft_object = test_scenario::take_from_sender<nft::ArtfiNFT>(&scenario);
            nft_id = object::id(&nft_object);

            test_scenario::return_to_sender<nft::ArtfiNFT>(&scenario, nft_object);
        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {
            let mintCap = test_scenario::take_from_sender<nft::MinterCap>(&scenario);
            let nft_info = test_scenario::take_shared<nft::NFTInfo>(&scenario);

            nft::update_nft_royalty(&mintCap, &mut nft_info, nft_id, 5, 4 , 3, test_scenario::ctx(&mut scenario));

            test_utils::destroy<nft::MinterCap>(mintCap); 
            test_scenario::return_shared<nft::NFTInfo>(nft_info);         
        };

        test_scenario::next_tx(&mut scenario, final_owner);
        {
            let nft_info = test_scenario::take_shared<nft::NFTInfo>(&scenario);
            let nft_object = test_scenario::take_from_sender<nft::ArtfiNFT>(&scenario);

            assert!(nft_id == object::id(&nft_object), 1);
            assert!(nft::artfi_royalty(&nft_object, &nft_info) == 5, 1);
            assert!(nft::artist_royalty(&nft_object, &nft_info) == 4, 1);
            assert!(nft::staking_contract_royalty(&nft_object, &nft_info) == 3, 1);

            test_scenario::return_shared<nft::NFTInfo>(nft_info);  
            test_scenario::return_to_sender<nft::ArtfiNFT>(&scenario, nft_object);         
        };

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = test_scenario::EEmptyInventory)] 
    fun test_will_error_on_transfer_minter_cap_by_other_address() {

        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            nft::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, final_owner);
        {
            let admin_cap = test_scenario::take_from_sender<nft::AdminCap>(&scenario);

            nft::transfer_minter_cap(&admin_cap, final_owner, test_scenario::ctx(&mut scenario));

            test_utils::destroy<nft::AdminCap>(admin_cap);
        };
        
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = test_scenario::EEmptyInventory)] 
    fun test_will_error_on_transfer_admin_cap_by_other_address() {

        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            nft::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, final_owner);
        {
            let admin_cap = test_scenario::take_from_sender<nft::AdminCap>(&scenario);

            nft::transfer_admin_cap(admin_cap, final_owner, test_scenario::ctx(&mut scenario));

        };
        
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = test_scenario::EEmptyInventory)]
    fun test_will_error_on_transfer_nft_by_other_address() {

        let url = b" ";
        let fraction_id = 12;

        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;
        let user = @0xEAFF;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            nft::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {

            let minter_cap = test_scenario::take_from_sender<nft::MinterCap>(&scenario);
            let display_object = test_scenario::take_from_sender<display::Display<nft::ArtfiNFT>>(&scenario);
            let royalty_object = test_scenario::take_shared<nft::NFTInfo>(&scenario);

            nft::mint_nft(
                &minter_cap, 
                &mut royalty_object,
                url, 
                final_owner, 
                fraction_id, 
                test_scenario::ctx(&mut scenario)
            );

            test_utils::destroy<nft::MinterCap>(minter_cap);
            test_utils::destroy<display::Display<nft::ArtfiNFT>>(display_object);
            test_scenario::return_shared<nft::NFTInfo>(royalty_object);
        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {
            let nftToken = test_scenario::take_from_sender<nft::ArtfiNFT>(&scenario);

            base_nft::transfer_object<nft::ArtfiNFT>(nftToken, user, test_scenario::ctx(&mut scenario));
            
        };

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = collection::nft::ELengthNotEqual)] 
    fun test_will_error_on_batch_mint_for_unequal_length_vector() {

        let url = vector[b" ", b"Artfi_NFT"];
        let fraction_id = vector[12];

        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            nft::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {

            let minter_cap = test_scenario::take_from_sender<nft::MinterCap>(&scenario);
            let royalty_object = test_scenario::take_shared<nft::NFTInfo>(&scenario);

            nft::mint_nft_batch(
                &minter_cap, 
                &mut royalty_object,
                &url, 
                &vector[final_owner], 
                &fraction_id, 
                test_scenario::ctx(&mut scenario)
            );

            test_utils::destroy<nft::MinterCap>(minter_cap);
            test_scenario::return_shared<nft::NFTInfo>(royalty_object);
        };

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = test_scenario::EEmptyInventory)] 
    fun test_will_error_on_update_of_royalty_by_other_user() {

        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            nft::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, final_owner);
        {
            let nft_info = test_scenario::take_shared<nft::NFTInfo>(&scenario);
            let minter_cap = test_scenario::take_from_sender<nft::MinterCap>(&scenario);

            nft::update_royalty(&minter_cap, &mut nft_info, 4 , 3, 3, test_scenario::ctx(&mut scenario));

            test_scenario::return_shared<nft::NFTInfo>(nft_info);
            test_utils::destroy<nft::MinterCap>(minter_cap);
        };

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = test_scenario::EEmptyInventory)] 
    fun test_will_error_on_update_of_nft_royalty_by_other_user() {

        let url = b" ";
        let fraction_id = 12;

        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            nft::test_init(test_scenario::ctx(&mut scenario));

        };

        let nft_object;

        test_scenario::next_tx(&mut scenario, initial_owner);
        {

            let minter_cap = test_scenario::take_from_sender<nft::MinterCap>(&scenario);
            let display_object = test_scenario::take_from_sender<display::Display<nft::ArtfiNFT>>(&scenario);
            let nft_info = test_scenario::take_shared<nft::NFTInfo>(&scenario);

            nft::mint_nft(
                &minter_cap, 
                &mut nft_info,
                url, 
                final_owner, 
                fraction_id, 
                test_scenario::ctx(&mut scenario)
            );

            nft_object = test_scenario::take_from_sender<nft::ArtfiNFT>(&scenario);

            test_utils::destroy<nft::MinterCap>(minter_cap);
            test_utils::destroy<display::Display<nft::ArtfiNFT>>(display_object);
            test_scenario::return_shared<nft::NFTInfo>(nft_info);
            
        };

        test_scenario::next_tx(&mut scenario, final_owner);
        {
            let nft_info = test_scenario::take_shared<nft::NFTInfo>(&scenario);
            let minter_cap = test_scenario::take_from_sender<nft::MinterCap>(&scenario);

            nft::update_nft_royalty(&minter_cap, &mut nft_info, object::id(&nft_object), 4, 3, 3, test_scenario::ctx(&mut scenario));

            test_scenario::return_shared<nft::NFTInfo>(nft_info);
            test_utils::destroy<nft::MinterCap>(minter_cap);
        };

        test_scenario::end(scenario);
        test_utils::destroy<nft::ArtfiNFT>(nft_object);
    }
        
}
