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

    #[test]
    // test `name` function
    fun nft_name_test() {
        let name = b"ARTI";
        let description = b"ARTI_NFT";
        let url = b"ARTI_NFT";
        let fractionId = 12;
        let artist = 3;
        let atfi = 4;
        let stakecontract = 5;
        let testNetNFt = nft::new_artFi_nft(name, description, url, fractionId, atfi, artist, stakecontract, &mut tx_context::dummy());

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
        let artist = 3;
        let atfi = 4;
        let stakecontract = 5;
        let testNetNFt = nft::new_artFi_nft(name, description, url, fractionId, atfi, artist, stakecontract, &mut tx_context::dummy());

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
        let artist = 3;
        let atfi = 4;
        let stakecontract = 5;
        let testNetNFt = nft::new_artFi_nft(name, description, url, fractionId, atfi, artist, stakecontract, &mut tx_context::dummy());

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
        let artist = 3;
        let atfi = 4;
        let stakecontract = 5;
        let testNetNFt = nft::new_artFi_nft(name, description, url, fractionId, atfi, artist, stakecontract, &mut tx_context::dummy());

        let royalty_instance = nft::new_royalty(atfi, artist, stakecontract); 
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
        let artist = 3;
        let atfi = 4;
        let stakecontract = 5;
        let testNetNFt = nft::new_artFi_nft(name, description, url, fractionId, atfi, artist, stakecontract, &mut tx_context::dummy());

        assert!(nft::artfi_royalty(&testNetNFt) ==  atfi, 1);

        test_utils::destroy<nft::ArtFiNFT>(testNetNFt);
        
    }

    #[test]
    // test `url` function
    fun nft_artist_royalty_test() {
        let name = b"ARTI";
        let description = b"ARTI_NFT";
        let url = b" ";
        let fractionId = 12;
        let artist = 3;
        let atfi = 4;
        let stakecontract = 5;
        let testNetNFt = nft::new_artFi_nft(name, description, url, fractionId, atfi, artist, stakecontract, &mut tx_context::dummy());

        assert!(nft::artist_royalty(&testNetNFt) ==  artist, 1);

        test_utils::destroy<nft::ArtFiNFT>(testNetNFt);
        
    }

    #[test]
    // test `url` function
    fun nft_stakingContract_royalty_test() {
        let name = b"ARTI";
        let description = b"ARTI_NFT";
        let url = b" ";
        let fractionId = 12;
        let artist = 3;
        let atfi = 4;
        let stakecontract = 5;
        let testNetNFt = nft::new_artFi_nft(name, description, url, fractionId, atfi, artist, stakecontract, &mut tx_context::dummy());

        assert!(nft::stakingContract_royalty(&testNetNFt) ==  stakecontract, 1);

        test_utils::destroy<nft::ArtFiNFT>(testNetNFt);
        
    }

    #[test]
    fun update_description_test() {
        let name = b"ARTI";
        let description = b"ARTI_NFT";
        let url = b" ";
        let fractionId = 12;
        let artist = 3;
        let atfi = 4;
        let stakecontract = 5;

        let testNetNFt = nft::new_artFi_nft(name, description, url, fractionId, atfi, artist, stakecontract, &mut tx_context::dummy());
        let new_description = b"NEW_ARTI_NFT";
        nft::update_description(&mut testNetNFt, new_description, &mut tx_context::dummy());

        assert!(nft::description(&testNetNFt) ==  &string::utf8(b"NEW_ARTI_NFT"), 1);

        test_utils::destroy<nft::ArtFiNFT>(testNetNFt);
        
    }
        
}
