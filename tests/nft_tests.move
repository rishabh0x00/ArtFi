#[test_only]
module nft::nft_tests {
    // Test attribute is placed before the `fun` keyword. Can be both above or
    // right before the `fun` keyword: `#[test] fun my_test() { ... }`
    // The name of the test would be `book::testing::simple_test`.
    #[test_only]
    use nft::nft;
    use sui::url;
    use std::string;
    use sui::tx_context;

    #[test_only] use sui::test_utils;
    #[test_only] use sui::test_scenario;

    #[test]
    // test `name` function
    fun nft_name_test() {
        let name = b"ARTI";
        let description = b"ARTI_NFT";
        let url = b"ARTI_NFT";
        let fractionId = 12;
        let testNetNFt = nft::new_artfi_nft(name, description, url, fractionId, &mut tx_context::dummy());

        assert!(nft::name(&testNetNFt) == &string::utf8(b"ARTI"), 1);

        let dummy_address = @0xCAFE;
        sui::transfer::public_transfer(testNetNFt, dummy_address);
        
    }

    // test `description` function
    #[test]
    fun nft_description_test() {
        let name = b"ARTI";
        let description = b"ARTI_NFT";
        let url = b"ARTI_NFT";
        let fractionId = 12;
        let testNetNFt = nft::new_artfi_nft(name, description, url, fractionId, &mut tx_context::dummy());

        assert!(nft::description(&testNetNFt) == &string::utf8(b"ARTI_NFT"), 1);

        let dummy_address = @0xCAFE;
        sui::transfer::public_transfer(testNetNFt, dummy_address);
        
    }

    #[test]
    // test `url` function
    fun nft_url_test() {
        let name = b"ARTI";
        let description = b"ARTI_NFT";
        let url = b" ";
        let fractionId = 12;
        let testNetNFt = nft::new_artfi_nft(name, description, url, fractionId, &mut tx_context::dummy());

        assert!(nft::url(&testNetNFt) ==  &url::new_unsafe_from_bytes(url), 1);

        test_utils::destroy<nft::ArtFiNFT>(testNetNFt);
        
    }

    #[test]
    // test `url` function
    fun nft_royalty_test() {
        let name = b"ARTI";
        let description = b"ARTI_NFT";
        let url = b" ";
        let fractionId = 12;
        let testNetNFt = nft::new_artfi_nft(name, description, url, fractionId, &mut tx_context::dummy());

        let royalty_instance = nft::new_royalty(); 
        assert!(nft::royalty(&testNetNFt) == &royalty_instance, 1);

        test_utils::destroy<nft::ArtFiNFT>(testNetNFt);
        
    }

    #[test]
    // test `url` function
    fun nft_artfi_royalty_test() {
        let name = b"ARTI";
        let description = b"ARTI_NFT";
        let url = b" ";
        let fractionId = 12;
        let testNetNFt = nft::new_artfi_nft(name, description, url, fractionId, &mut tx_context::dummy());

        assert!(nft::artfi_royalty(&testNetNFt) ==  4, 1);

        test_utils::destroy<nft::ArtFiNFT>(testNetNFt);
        
    }

    #[test]
    // test `url` function
    fun nft_artist_royalty_test() {
        let name = b"ARTI";
        let description = b"ARTI_NFT";
        let url = b" ";
        let fractionId = 12;
        let testNetNFt = nft::new_artfi_nft(name, description, url, fractionId, &mut tx_context::dummy());

        assert!(nft::artist_royalty(&testNetNFt) ==  3, 1);

        test_utils::destroy<nft::ArtFiNFT>(testNetNFt);
        
    }

    #[test]
    // test `url` function
    fun nft_stakingContract_royalty_test() {
        let name = b"ARTI";
        let description = b"ARTI_NFT";
        let url = b" ";
        let fractionId = 12;
        let testNetNFt = nft::new_artfi_nft(name, description, url, fractionId, &mut tx_context::dummy());

        assert!(nft::stakingContract_royalty(&testNetNFt) ==  3, 1);

        test_utils::destroy<nft::ArtFiNFT>(testNetNFt);
        
    }

    #[test]
    fun update_description_test() {
        let name = b"ARTI";
        let description = b"ARTI_NFT";
        let url = b" ";
        let fractionId = 12;

        let testNetNFt = nft::new_artfi_nft(name, description, url, fractionId, &mut tx_context::dummy());
        let new_description = b"NEW_ARTI_NFT";
        nft::update_description(&mut testNetNFt, new_description, &mut tx_context::dummy());

        assert!(nft::description(&testNetNFt) ==  &string::utf8(b"NEW_ARTI_NFT"), 1);

        test_utils::destroy<nft::ArtFiNFT>(testNetNFt);
        
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
            let adminCap = test_scenario::take_from_sender<nft::AdminCap>(&scenario);

            nft::transfer_minter_cap(&adminCap, final_owner, test_scenario::ctx(&mut scenario));

             test_utils::destroy<nft::AdminCap>(adminCap);

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
            let adminCap = test_scenario::take_from_sender<nft::AdminCap>(&scenario);

            nft::transfer_minter_cap(&adminCap, final_owner, test_scenario::ctx(&mut scenario));

             test_utils::destroy<nft::AdminCap>(adminCap);

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
            let adminCap = test_scenario::take_from_sender<nft::AdminCap>(&scenario);

            nft::transfer_admin_cap(adminCap, final_owner);

        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_mint_nft() {

        let name = b"ARTI";
        let description = b"ARTI_NFT";
        let url = b" ";
        let fractionId = 12;

        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            nft::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {

            let minterCap = test_scenario::take_from_sender<nft::MinterCap>(&scenario);
            nft::mint_nft(
                &minterCap, 
                name, 
                description, 
                url, 
                final_owner, 
                fractionId, 
                test_scenario::ctx(&mut scenario)
            );

            test_utils::destroy<nft::MinterCap>(minterCap);
        };

        test_scenario::next_tx(&mut scenario,final_owner);
        {
            let nftToken = test_scenario::take_from_sender<nft::ArtFiNFT>(&scenario);

            assert!(nft::name(&nftToken) == &string::utf8(b"ARTI"), 1);
            assert!(nft::description(&nftToken) == &string::utf8(b"ARTI_NFT"), 1);
            assert!(nft::url(&nftToken) == &url::new_unsafe_from_bytes(url), 1);
            assert!(nft::royalty(&nftToken) == &nft::new_royalty(), 1);

            test_utils::destroy<nft::ArtFiNFT>(nftToken);
            
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_mint_batch_nft() {

        let name = vector[b"ARTI"];
        let description = vector[b"ARTI_NFT"];
        let url = vector[b" "];
        let fractionId = vector[12];

        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            nft::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {

            let minterCap = test_scenario::take_from_sender<nft::MinterCap>(&scenario);

            nft::mint_nft_batch(
                &minterCap, 
                &name, 
                &description, 
                &url, 
                final_owner, 
                &fractionId, 
                test_scenario::ctx(&mut scenario)
            );

            test_utils::destroy<nft::MinterCap>(minterCap);
        };

        test_scenario::next_tx(&mut scenario,final_owner);
        {
            let nftToken = test_scenario::take_from_sender<nft::ArtFiNFT>(&scenario);

            assert!(nft::name(&nftToken) == &string::utf8(b"ARTI"), 1);
            assert!(nft::description(&nftToken) == &string::utf8(b"ARTI_NFT"), 1);
            assert!(nft::url(&nftToken) == &url::new_unsafe_from_bytes(b" "), 1);
            assert!(nft::royalty(&nftToken) == &nft::new_royalty(), 1);
            test_utils::destroy<nft::ArtFiNFT>(nftToken);
            
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_transfer_nft() {

        let name = b"ARTI";
        let description = b"ARTI_NFT";
        let url = b" ";
        let fractionId = 12;

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

            let minterCap = test_scenario::take_from_sender<nft::MinterCap>(&scenario);
            nft::mint_nft(
                &minterCap, 
                name, 
                description, 
                url, 
                final_owner, 
                fractionId, 
                test_scenario::ctx(&mut scenario)
            );

            test_utils::destroy<nft::MinterCap>(minterCap);
        };

        test_scenario::next_tx(&mut scenario,final_owner);
        {
            let nftToken = test_scenario::take_from_sender<nft::ArtFiNFT>(&scenario);

            nft::transfer_nft(nftToken, user, test_scenario::ctx(&mut scenario));
            
        };

        test_scenario::next_tx(&mut scenario, user);
        {
            let nftToken = test_scenario::take_from_sender<nft::ArtFiNFT>(&scenario);

            assert!(nft::name(&nftToken) == &string::utf8(b"ARTI"), 1);
            assert!(nft::description(&nftToken) == &string::utf8(b"ARTI_NFT"), 1);
            assert!(nft::url(&nftToken) == &url::new_unsafe_from_bytes(url), 1);
            assert!(nft::royalty(&nftToken) == &nft::new_royalty(), 1);

            test_utils::destroy<nft::ArtFiNFT>(nftToken);
            
        };

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = test_scenario::EEmptyInventory)] 
    fun test_burn_nft() {

        let name = b"ARTI";
        let description = b"ARTI_NFT";
        let url = b" ";
        let fractionId = 12;

        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            nft::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {

            let minterCap = test_scenario::take_from_sender<nft::MinterCap>(&scenario);
            nft::mint_nft(
                &minterCap, 
                name, 
                description, 
                url, 
                final_owner, 
                fractionId, 
                test_scenario::ctx(&mut scenario)
            );

            test_utils::destroy<nft::MinterCap>(minterCap);
        };

        test_scenario::next_tx(&mut scenario,final_owner);
        let nftToken;
        {
            nftToken = test_scenario::take_from_sender<nft::ArtFiNFT>(&scenario);
        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {   
            let adminCap = test_scenario::take_from_sender<nft::AdminCap>(&scenario);
            nft::burn(nftToken, test_scenario::ctx(&mut scenario));
            test_utils::destroy<nft::AdminCap>(adminCap); 
        };

        test_scenario::next_tx(&mut scenario, final_owner);
        {
            let nftToken = test_scenario::take_from_sender<nft::ArtFiNFT>(&scenario);

            test_utils::destroy<nft::ArtFiNFT>(nftToken);            
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
            let adminCap = test_scenario::take_from_sender<nft::AdminCap>(&scenario);

            nft::transfer_minter_cap(&adminCap, final_owner, test_scenario::ctx(&mut scenario));

            test_utils::destroy<nft::AdminCap>(adminCap);
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
            let adminCap = test_scenario::take_from_sender<nft::AdminCap>(&scenario);

            nft::transfer_admin_cap(adminCap, final_owner);

        };
        
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = test_scenario::EEmptyInventory)]
    fun test_will_error_on_transfer_nft_by_other_address() {

        let name = b"ARTI";
        let description = b"ARTI_NFT";
        let url = b" ";
        let fractionId = 12;

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

            let minterCap = test_scenario::take_from_sender<nft::MinterCap>(&scenario);
            nft::mint_nft(
                &minterCap, 
                name, 
                description, 
                url, 
                final_owner, 
                fractionId,
                test_scenario::ctx(&mut scenario)
            );

            test_utils::destroy<nft::MinterCap>(minterCap);
        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {
            let nftToken = test_scenario::take_from_sender<nft::ArtFiNFT>(&scenario);

            nft::transfer_nft(nftToken, user, test_scenario::ctx(&mut scenario));
            
        };

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = nft::nft::ELengthNotEqual)] 
    fun test_will_error_on_batch_mint_for_unequal_length_vector() {

        let name = vector[b"ARTI"];
        let description = vector[b"ARTI_NFT"];
        let url = vector[b" ", b"ARTI_NFT"];
        let fractionId = vector[12];

        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            nft::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {

            let minterCap = test_scenario::take_from_sender<nft::MinterCap>(&scenario);

            nft::mint_nft_batch(
                &minterCap, 
                &name, 
                &description, 
                &url, 
                final_owner, 
                &fractionId,
                test_scenario::ctx(&mut scenario)
            );

            test_utils::destroy<nft::MinterCap>(minterCap);
        };

        test_scenario::end(scenario);
    }
        
}
