const fs = require('fs');
const path = require('path');

function isValidJSON(obj) {
    if (obj === undefined || obj === null) {
        return false;
    }

    if (Object.keys(obj).length === 0 && obj.constructor === Object) {
        return false;
    }

    return true;
}

function getSignedTx(filePath) {
    const signedTx = {};

    try {
        // Read the content of the file
        const data = getFileData(filePath);

        if (data) {
            const jsonData = JSON.parse(data);

            if (!isValidJSON(jsonData)) {
                return signedTx;
            }

            return jsonData;
        }

        return signedTx;
    } catch (error) {
        printError(`Failed to get all signers data from the file ${filePath}`, error);
        throw error;
    }
}

function getFileData(filePath) {
    try {
        createFileIfNotExists(filePath);
        // Read the content of the file

        const data = fs.readFileSync(filePath, 'utf-8');
        return data;
    } catch (error) {
        printError(`Failed to get data from the file ${filePath}`, error);
        throw error;
    }
}

function createFileIfNotExists(filePath) {
    const directoryPath = path.dirname(filePath);

    // Check if the directory and file exists, create it if it doesn't
    if (!fs.existsSync(directoryPath)) {
        fs.mkdirSync(directoryPath, { recursive: true }); // Added { recursive: true } to create parent directories if needed
    }

    if (!fs.existsSync(filePath)) {
        // File does not exist, create it
        fs.writeFileSync(filePath, JSON.stringify({}, null, 2));
    }
}

function loadConfig(env) {
    return require(`${__dirname}/../info/${env}.json`);
}

module.exports = {
    loadConfig,
    getSignedTx,
    createFileIfNotExists,
    getFileData,
    isValidJSON
};