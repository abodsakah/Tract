"use strict"

const {Sequelize, QueryTypes} = require('sequelize');
const dotenv = require('dotenv').config({ path:  __dirname + '/../../.env' });


// init db
const db = new Sequelize(dotenv.parsed.DB_NAME, dotenv.parsed.DB_LOGIN, dotenv.parsed.DB_PASSWORD, {
    host: dotenv.parsed.DB_HOST,
    dialect: 'mysql',
});

/**
 *
 * @param {*} key The API key to be used to get the users information
 * @returns Gets the API key that matches the specified key
 */
async function getApiKeys(key) {
    const result = await db.query("SELECT * FROM `api_keys` WHERE `key` = ?", {type: QueryTypes.SELECT, replacements: [key]})
    return result;
}

/**
 *
 * @param {*} key The API key to be used to get the users information
 * @returns Returns true if the key is valid, false otherwise
 */
async function validateAPIKey(key) {
    let keys = await getApiKeys(key);
    if (keys.length > 0) {
        return true;
    }
    return false;
}

/**
 *
 * @param {*} id The user id that is to be used to get the users information
 * @returns The user that matches the specified id
 */
async function getUserById(id) {
    const result = await db.query("SELECT * FROM `user_login` WHERE `id` = ?", {type: QueryTypes.SELECT, replacements: [id]});
    return result;
}

/**
 * 
 * @param {*} email User email
 * @param {*} password bcrypted password
 * @param {*} first_name User first name
 * @param {*} last_name User last name
 * @param {*} nickname Username
 * @param {*} role 0 = High admin, 1 = Company admin, 2 = User
 * @param {*} company_id The company id that the user belongs to
 * @returns The user id that was created
 */
async function createUser(email, password, first_name, last_name, nickname, role, company_id) {
    const result = await db.query("INSERT INTO `user_login` (`email`, `password`, `first_name`, `last_name`, `nickname`, `role`, `company_id`) VALUES (?, ?, ?, ?, ?, ?, ?)", {type: QueryTypes.INSERT, replacements: [email, password, first_name, last_name, nickname, role, company_id]});
    return result;
}

/**
 * 
 * @param {*} name Company name
 * @param {*} email Support mail
 * @param {*} phone Support phone
 * @returns 
 */
async function createCompany(name, email, phone) {
    const result = await db.query("INSERT INTO `companies` (`name`, `support_email`, `support_phone`) VALUES (?, ?, ?)", {type: QueryTypes.INSERT, replacements: [name, email, phone]});
    return result;
}

/**
 * 
 * @returns All the nodes in the preloaded databases
 */
async function getPreloadedNodes() {
    const result = await db.query("SELECT * FROM `node_preloaded`", {type: QueryTypes.SELECT});
    return result;
}

/**
 * @param {int} deviceId 
 * @param {int} deviceType 
 * @param {int} companyId 
 * @returns {} 
 */
async function addPreloadedNode(deviceId, deviceType, companyId) {
    const result = await db.query("INSERT INTO `node_preloaded` (`uid`, `type`, `company_id`) VALUES (?, ?, ?)", {type: QueryTypes.INSERT, replacements: [deviceId, deviceType, companyId]});
    return result;
}

/**
 * 
 * @returns All companies
 */
async function getCompanies() {
    const result = await db.query("SELECT * FROM `companies`", {type: QueryTypes.SELECT});
    return result;
}

/**
 *  Used to add a new logical device to the database
 * @param {*} uid The unique id of the device
 * @param {*} name The display name of the logical device
 * @param {*}    The action that triggers a warning from the devices data
 * @param {*} install_date The install date of the device
 * @param {*} is_part_of What asset the device is part of
 * @param {*} status The status of the device
 * @returns the id of the logical device that was created
 */
async function addLogicalDevice(uid, name, trigger_action, is_part_of, type, status) {
    const result = await db.query("CALL add_node(?, ?, ?, ?, ?, ?)", {type: QueryTypes.INSERT, replacements: [uid, name, trigger_action, type, is_part_of, status]});
    return result;
}

/**
 * 
 * @param {*} companyId The id of the company
 * @returns A JSON object with the companies color, logo, id and company name
 */
async function getCompanySetting(companyId) {
    const result = await db.query("CALL get_company_settings(?)", {type: QueryTypes.SELECT, replacements: [companyId]});
    return result;
}

async function updateStyling(companyId, color, logo) {
    const result = await db.query("CALL update_company_settings(?, ?, ?)", {type: QueryTypes.UPDATE, replacements: [companyId, color, logo]});
    return result;
}

/**
 * 
 * @param {*} nodeId The id of the device
 * @param {*} companyId The id of the company that owns the device
 * @returns all info for the node
 */
async function getNodeInfo(nodeId, companyId) {
    // TODO: fix this function and sql procedure to also take company_id, (view exists that has company_id already)
    const result = await db.query("CALL get_logical_device_all(?,?)", {type: QueryTypes.SELECT, replacements: [nodeId, companyId]});
    return result[0][0];
}

/**
 * 
 * @param {*} uid The unique id of the node
 * @returns The status of the node
 */
async function getNodeFromUid(uid) {
    // TODO: fix this function and sql procedure to also take company_id, (view exists that has company_id already)
    const result = await db.query("CALL get_node_from_uid(?)", {type: QueryTypes.SELECT, replacements: [uid]});
    return result[0][0];
}

/**
 * 
 * @param {*} nodeId The id of the device
 * @param {*} companyId The id of the company that owns the device
 * @returns The status of the node
 */
async function getNodeStatus(nodeId, companyId) {
    // TODO: fix this function and sql procedure to also take company_id, (view exists that has company_id already)
    const result = await db.query("CALL get_logical_device_status(?,?)", {type: QueryTypes.SELECT, replacements: [nodeId, companyId]});
    return result[0][0];
}

/**
 * 
 * @param {*} nodeId The node id of the device
 * @param {*} companyId The id of the company that owns the device
 */
async function setNodeASDeleted(nodeId, companyId) {
    const result = await db.query("CALL set_device_as_deleted(?,?)", {type: QueryTypes.UPDATE, replacements: [nodeId, companyId]});
    return result;
}

/**
 * 
 * @param {*} companyId The id of the company which to find users for 
 * @returns a object with all users
 */
async function getUsersForCompany(companyId) {
    const result = await db.query("CALL get_users_for_company(?)", {type: QueryTypes.SELECT, replacements: [companyId]});
    return result[0];
}

/**
 * 
 * @param {*} companyId 
 * @returns A list with all the logical devices for a company
 */
async function getLogicalDeviceForCompany(companyId) {
    const result = await db.query("CALL logical_devices_for_company(?)", {type: QueryTypes.SELECT, replacements: [companyId]});
    return result[0];
}

async function getAmountOfSensorTypes(sensorType, companyId) {
    const result = await db.query("CALL get_amount_type_of_sensor(?, ?)", {type: QueryTypes.SELECT, replacements: [sensorType, companyId]});
    return result[0][0];
}
    
/**
 * Gets all the building, finds all spaces with a NULL as "is_part_of"
 * @param {*} companyId The company id for the space
 * @returns A list with all the spaces available for a company
 */
async function getBuildingsForCompany(companyId) {
    const result = await db.query("CALL get_all_buildings(?)", {type: QueryTypes.SELECT, replacements: [companyId]});
    return result[0];
}

/**
 * Gets all the spaces that has the "is_part_of" set to the space_id
 * @param {*} space_id the space id for the space
 * @returns A list with all the spaces available for a company
 */
async function getSpacesForBuilding(space_id) {
    const result = await db.query("CALL get_spaces_for_building(?)", {type: QueryTypes.SELECT, replacements: [space_id]});
    return result[0];
}

/**
 * 
 * @param {*} space_id The space id where the assets are in
 * @returns a list of the assets in the space
 */
async function getAssetsInSpace(space_id) {
    const result = await db.query("CALL get_assets_in_space(?)", {type: QueryTypes.SELECT, replacements: [space_id]});
    return result[0];
}   

module.exports = {
    getApiKeys,
    validateAPIKey,
    getUserById,
    createUser,
    createCompany,
    getCompanies,
    getPreloadedNodes,
    addPreloadedNode,
    addLogicalDevice,
    getCompanySetting,
    updateStyling,
    setNodeASDeleted,
    getNodeStatus,
    getUsersForCompany,
    getLogicalDeviceForCompany,
    getAmountOfSensorTypes,
    getNodeInfo,
    getNodeFromUid,
    getBuildingsForCompany,
    getSpacesForBuilding,
    getAssetsInSpace
}

