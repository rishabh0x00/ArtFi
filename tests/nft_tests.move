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
        let testNetNFt = nft::new_testNetNFT(name, description, url, &mut tx_context::dummy());

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
        let testNetNFt = nft::new_testNetNFT(name, description, url, &mut tx_context::dummy());

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
        let testNetNFt = nft::new_testNetNFT(name, description, url, &mut tx_context::dummy());

        assert!(nft::url(&testNetNFt) ==  &url::new_unsafe_from_bytes(url), 1);

        test_utils::destroy<nft::TestNetNFT>(testNetNFt);
        
    }

    #[test]
    fun update_description_test() {
        let name = b"ARTI";
        let description = b"ARTI_NFT";
        let url = b" ";

        let testNetNFt = nft::new_testNetNFT(name, description, url, &mut tx_context::dummy());
        let new_description = b"NEW_ARTI_NFT";
        nft::update_description(&mut testNetNFt, new_description, &mut tx_context::dummy());

        assert!(nft::description(&testNetNFt) ==  &string::utf8(b"NEW_ARTI_NFT"), 1);

        test_utils::destroy<nft::TestNetNFT>(testNetNFt);
        
    }
        
}
