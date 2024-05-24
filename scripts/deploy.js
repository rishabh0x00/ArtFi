import "dotenv/config"

import { Ed25519Keypair  } from "@mysten/sui.js/keypairs/ed25519";
import { fromB64 } from "@mysten/sui.js/utils";

import { execSync } from "child_process";
import path, { dirname } from "path";
import { fileURLToPath } from "url";
import { TransactionBlock } from "@mysten/sui.js/transactions";
import { SuiClient } from "@mysten/sui.js/client";
import { writeFileSync } from "fs";

const privkey = process.env.DEPLOYER_B64_PRIVKEY
const network_url = process.env.NETWORK_URL;
if (!privkey) {
    console.log("Error: DEPLOYER_B64_PRIVKEY not set as env variable.")
    process.exit(1)
}
const keypair = Ed25519Keypair.fromSecretKey(fromB64(privkey).slice(1))
const path_to_contracts = path.join(dirname(fileURLToPath(import.meta.url)), "../")

const client = new SuiClient({ url: `${network_url}`})

console.log("Building move code...")
const { modules, dependencies } = JSON.parse(execSync(
    `sui move build --dump-bytecode-as-base64 --path ${path_to_contracts}`,
    { encoding: "utf-8" }
))

console.log("Deploying from address:", keypair.toSuiAddress())
const deploy_trx = new TransactionBlock()
const [upgradeCap] = deploy_trx.publish({
    modules,
    dependencies,
});

deploy_trx.transferObjects([upgradeCap], deploy_trx.pure(keypair.toSuiAddress()));
const { objectChanges, balanceChanges } = await client.signAndExecuteTransactionBlock({
    signer: keypair, transactionBlock: deploy_trx, options: {
        showBalanceChanges: true,
        showEffects: true,
        showEvents: true,
        showInput: false,
        showObjectChanges: true,
        showRawInput: false
    }
})

const parse_cost = (amount) => Math.abs(parseInt(amount)) / 1_000_000_000

if (balanceChanges) {
    console.log("Cost to deploy:", parse_cost(balanceChanges[0].amount), "SUI")
}

if (!objectChanges) {
    console.log("Error: RPC did not return objectChanges")
    process.exit(1)
}
const published_event = objectChanges.find(obj => obj.type == "published")
if (published_event?.type != "published") {
    process.exit(1)
}

const find_one_by_type = (changes, types) => {
    const object_change = types.find(type => changes.objectType == type)
    if ((object_change && changes.objectType == object_change) && changes.type == 'created') {
        return [changes.objectId, object_change]
    }
}

const check_find_one_by_type = (changes, type) => {
    let place_id = [];
    let object_type = [];
    for(let i = 0; i < changes.length; i++) {
        let returns_object = find_one_by_type(changes[i], type);
        if (returns_object) {
            place_id.push(returns_object[0]);
            object_type.push(returns_object[1]);
        }
    }
    return [place_id, object_type];
}

const package_id = published_event.packageId;
const place_type = [
                `${package_id}::base_nft::AdminCap`,  
                `${package_id}::nft::AdminCap`, 
                `${package_id}::gop::AdminCap`, 
                `${package_id}::gap::AdminCap`, 
                `${package_id}::trophy::AdminCap`, 
                `${package_id}::nft::MinterCap`,
                `${package_id}::nft::NFTInfo`, 
                `${package_id}::gop::NFTInfo`,  
                `${package_id}::gap::NFTInfo`, 
                `${package_id}::trophy::NFTInfo`, 
                `0x2::display::Display<${package_id}::nft::ArtfiNFT>`, 
                `0x2::display::Display<${package_id}::gop::GOPNFT>`,
                `0x2::display::Display<${package_id}::gap::GAPNFT>`,
                `0x2::display::Display<${package_id}::trophy::TrophyNFT>`,
                `0x2::package::Publisher`, `0x2::package::UpgradeCap`
            ]


const objects_id_types = check_find_one_by_type(objectChanges, place_type);

let placy_type = objects_id_types[1];
let place_id = objects_id_types[0];

let deployed_addresses = {
    types: {
        placy_type
    },
    PACKAGE_ID: package_id,
    types_id: place_id
}

console.log("Writing addresses to json...")
const path_to_address_file = path.join(dirname(fileURLToPath(import.meta.url)), "./deployed_addresses.json")
writeFileSync(path_to_address_file, JSON.stringify(deployed_addresses, null, 4))