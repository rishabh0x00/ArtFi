const { decodeSuiPrivateKey } = require('@mysten/sui.js/cryptography');
const { Ed25519Keypair, Ed25519PublicKey } = require('@mysten/sui.js/keypairs/ed25519');
const { Secp256k1Keypair, Secp256k1PublicKey } = require('@mysten/sui.js/keypairs/secp256k1');
const { Secp256r1Keypair, Secp256r1PublicKey } = require('@mysten/sui.js/keypairs/secp256r1');
const { SuiClient, getFullnodeUrl } = require('@mysten/sui.js/client');
const { MultiSigPublicKey } = require('@mysten/sui.js/multisig');
const { fromHEX } = require('@mysten/bcs');
const { loadConfig } = require('./util.js');

function getWallet(options) {
    let keypair;
    let scheme;

    switch (options.signatureScheme) {
        case 'ed25519': {
            scheme = Ed25519Keypair;
            break;
        }

        case 'secp256k1': {
            scheme = Secp256k1Keypair;
            break;
        }

        case 'secp256r1': {
            scheme = Secp256r1Keypair;
            break;
        }

        default: {
            throw new Error(`Unsupported signature scheme: ${options.signatureScheme}`);
        }
    }

    switch (options.privateKeyType) {
        case 'bech32': {
            const decodedKey = decodeSuiPrivateKey(options.privateKey);
            const secretKey = decodedKey.secretKey;
            keypair = scheme.fromSecretKey(secretKey);
            break;
        }

        case 'mnemonic': {
            keypair = scheme.deriveKeypair(options.privateKey);
            break;
        }

        case 'hex': {
            const privKey = Buffer.from(options.privateKey, 'hex');
            keypair = scheme.fromSecretKey(privKey);
            break;
        }

        default: {
            throw new Error(`Unsupported key type: ${options.privateKeyType}`);
        }
    }

    const url = getFullnodeUrl(options.env);
    const client = new SuiClient({ url });

    return [keypair, client];
}

async function printWalletInfo(keypair, client) {
    console.log('Wallet address', keypair.toSuiAddress());
}

async function getWrappedPublicKey(hexPublicKey, schemeType) {
    let publicKey
    switch (schemeType) {
        case 'ed25519': {
            publicKey = new Ed25519PublicKey(fromHEX(hexPublicKey));
            break;
        }

        case 'secp256k1': {
            publicKey = new Secp256k1PublicKey(fromHEX(hexPublicKey));
            break;
        }

        case 'secp256r1': {
            publicKey = new Secp256r1PublicKey(fromHEX(hexPublicKey));
            break;
        }

        default: {
            throw new Error(`Unsupported signature scheme: ${schemeType}`);
        }
    }

    return publicKey;
}

async function getMultisig(chain, multisigKey) {
    let publicKeys = [];
    let multiSigPublicKey;

    if (multisigKey) {
        multiSigPublicKey = new MultiSigPublicKey(fromHEX(multisigKey))
    } else {
        let config = loadConfig(chain);
        let signers = config.multisig?.signers;
        if (!signers || signers.length === 0) {
            throw new Error('Signers not provided in configuration');
        }
        for (const signer of signers) {
            if (!(signer?.publicKey)) {
                throw new Error('PublicKey not found');
            }
            if (!(signer?.schemeType)) {
                throw new Error('schemeType not found');
            }
            publicKeys.push({
                publicKey: await getWrappedPublicKey(signer.publicKey, signer.schemeType),
                weight: signer.weight
            });
        }
    
        multiSigPublicKey = MultiSigPublicKey.fromPublicKeys({
            threshold: config.multisig?.threshold,
            publicKeys: publicKeys
        });
    }

    console.log('Multisig Wallet Address', multiSigPublicKey.toSuiAddress());

    return multiSigPublicKey;
}

module.exports = {
    getWallet,
    printWalletInfo,
    getWrappedPublicKey,
    getMultisig
};
