const { TransactionBlock } = require('@mysten/sui.js/transactions');
const { Command, Option } = require('commander');
const { addBaseOptions } =  require('./cli-utils.js');
const { getWallet, printWalletInfo } = require('./sign-utils.js');

async function processCommand(options) {
    const [keypair, client] = getWallet(options);
    await printWalletInfo(keypair, client);
    const recipient = options.recipient;

    const tx = new TransactionBlock();
    tx.transferObjects([`${options.objectId}`], tx.pure(recipient));

    const result = await client.signAndExecuteTransactionBlock({
        transactionBlock: tx,
        signer: keypair,
        options: {
            showObjectChanges: true,
            showBalanceChanges: true,
            showEvents: true,
        },
    });

    printInfo('Transaction result', JSON.stringify(result));
}

async function mainProcessor(options, processor) {
    await processor(options);
}

if (require.main === module) {
    const program = new Command();

    program.name('transfer-object').description('Transfer object to recipient address');

    addBaseOptions(program);

    program.addOption(new Option('--objectId <objectId>', 'object id to be transferred').makeOptionMandatory(true));
    program.addOption(new Option('--recipient <recipient>', 'recipient to transfer object to').makeOptionMandatory(true));

    program.action(async (options) => {
        mainProcessor(options, processCommand);
    });

    program.parse();
}
