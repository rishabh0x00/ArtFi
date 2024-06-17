const { TransactionBlock } = require('@mysten/sui.js/transactions');
const { Command, Option } = require('commander');
const { addExtendedOptions } =  require('./cli-utils.js');
const { getWallet, printWalletInfo, getMultisig } = require('./sign-utils.js');
const { getSignedTx } = require('./util.js')
const { verifyTransactionBlock } = require('@mysten/sui.js/verify');
const { toHEX } = require('@mysten/bcs');

async function signMessage(keypair, message) {
    const serializedSignature = (await keypair.signTransactionBlock(message)).signature;
    const publicKey = await verifyTransactionBlock(message, serializedSignature);

    if (publicKey.toSuiAddress() != keypair.toSuiAddress()) {
        throw new Error(`Verification failed for address ${keypair.toSuiAddress()}`);
    }

    console.log("signature", serializedSignature);
    console.log("publicKey", toHEX(publicKey.toRawBytes()));
    console.log("message", toHEX(message));
}

async function combineAndExecuteSingature(messageBytes, multiSigPublicKey, file, client) {

    if (!file) {
        throw new Error('FilePath is not provided');
    }

    const fileData = getSignedTx(file);

    let singatures = fileData?.singatures;

    if (!singatures && singatures.length === 0) {
        throw new Error('Signatures is not provided');
    }

    const combinedSignature = multiSigPublicKey.combinePartialSignatures(singatures);

    const isValid = await multiSigPublicKey.verifyTransactionBlock(messageBytes, combinedSignature);
    if (!isValid) {
        throw new Error(`Verification failed for message: ${toHEX(messageBytes)}`);
    }

    console.log("combined",combinedSignature);

    let result = await client.executeTransactionBlock({
        transactionBlock: messageBytes,
        signature: combinedSignature
    });
    console.log("Transaction result", JSON.stringify(result));
}

async function processCommand(options) {
    const [keypair, client] = getWallet(options);
    await printWalletInfo(keypair, client);
    const recipient = options.recipient;

    let multiSigPublicKey = await getMultisig(options.env, options.multisigKey);

    const tx = new TransactionBlock();
    tx.transferObjects([`${options.objectId}`], tx.pure(recipient));
    tx.setSender(multiSigPublicKey.toSuiAddress());
    const bytes = await tx.build({ client });

    if (options.action == 'sign') {
        await signMessage(keypair, bytes);
    } else if (options.action == 'combine') {
        await combineAndExecuteSingature(bytes, multiSigPublicKey, options.file, client);
    } else {
        throw new Error(`Invalid action provided [${options.action}]`);
    }
}

async function mainProcessor(options, processor) {
    await processor(options);
}

if (require.main === module) {
    const program = new Command();

    program.name('transfer-object').description('Transfer object to recipient address');

    addExtendedOptions(program, { contractName: true, multisigKey: true });

    program.addOption(new Option('--action <action>', 'signing action').choices(['sign', 'combine']).makeOptionMandatory(true));
    program.addOption(new Option('--objectId <objectId>', 'object id to be transferred').makeOptionMandatory(true));
    program.addOption(new Option('--recipient <recipient>', 'recipient to transfer object to').makeOptionMandatory(true));
    program.addOption(new Option('--file <file>', 'The file where the signed tx are stored'));

    program.action(async (options) => {
        mainProcessor(options, processCommand);
    });

    program.parse();
}
