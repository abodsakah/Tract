'use strict'
// Module with functions for sending
// JSON string data to the
// NeoCortec gateway

const mqttGateway = require('./gatewayMqttConnect');
const dataBase = require('./dbConnection');
// TODO: import database module functions needed.

module.exports = {
  sendNodeInfoRequest: sendNodeInfoRequest,
  sendNeighborListRequest: sendNeighborListRequest,
  sendWesServerStart: sendWesServerStart,
  sendWesServerStop: sendWesServerStop,
  sendWesServerStatus: sendWesServerStatus,
  sendForceWesMode: sendForceWesMode,
  sendWesSetupResponse: sendWesSetupResponse,
  deleteNode: deleteNode,
};

/* Base helper functions */

/**
 * Message type: nodeInfoRequest
 * Function for sending a nodeInfoRequest.
 * Makes a JSON string and sends it to the gateway.
 * @param companyId String the companyId the message should be sent too.
 * @returns BOOLEAN
 */
async function sendNodeInfoRequest(companyId) {
  // Create message
  var objectType = 'nodeInfoRequest';
  var jsonObject = {};
  jsonObject.objectType = objectType;
  var message = JSON.stringify(jsonObject);

  // Send message
  let isConnected = await mqttGateway.isConnected();
  if (isConnected) {
    console.log(message)
    return await mqttGateway.publishMsg(message, companyId);
  } else {
    return false;
  }
}

/**
 * Message type: neighborListRequest
 * Function for sending a neighborListRequest.
 * Makes a JSON string and sends it to the gateway.
 * @param companyId String the companyId the message should be sent too.
 * @returns BOOLEAN
 */
async function sendNeighborListRequest(companyId) {
  // Create message
  var objectType = 'neighborListRequest';
  var jsonObject = {};
  jsonObject.objectType = objectType;
  var message = JSON.stringify(jsonObject);

  // Send message
  if (await mqttGateway.isConnected()) {
    console.log(message)
    return await mqttGateway.publishMsg(message, companyId);
  } else {
    return false;
  }
}

/**
 * Message type: wesCmd
 * Function for starting the gateway WES server.
 * Makes a JSON string and sends it to the gateway.
 * @param companyId String the companyId the message should be sent too.
 * @returns BOOLEAN
 */
async function sendWesServerStart(companyId) {
  // Create message
  var message = '{"objectType": "wesCmd","cmd": 1}';

  // Send message
  if (await mqttGateway.isConnected()) {
    console.log(message)
    return await mqttGateway.publishMsg(message, companyId);
  } else {
    return false;
  }
}

/**
 * Message type: wesCmd
 * Function for stopping the gateway WES server.
 * Makes a JSON string and sends it to the gateway.
 * @param companyId String the companyId the message should be sent too.
 * @returns BOOLEAN
 */
async function sendWesServerStop(companyId) {
  // Create message
  var message = '{"objectType": "wesCmd","cmd": 0}';

  // Send message
  if (await mqttGateway.isConnected()) {
    console.log(message)
    return await mqttGateway.publishMsg(message, companyId);
  } else {
    return false;
  }
}

/**
 * Message type: wesCmd
 * Function for getting the status of the gateway WES server.
 * Makes a JSON string and sends it to the gateway.
 * Status: 0 for OFF, 1 for ON (will be returned as a outgoing packet from the
 * gateway and handled by the message reciever and parser).
 * @param companyId String the companyId the message should be sent too.
 * @returns BOOLEAN
 */
async function sendWesServerStatus(companyId) {
  // Create message
  var message = '{"objectType": "wesCmd","cmd": 2}';

  // Send message
  if (await mqttGateway.isConnected()) {
    console.log(message)
    return await mqttGateway.publishMsg(message, companyId);
  } else {
    return false;
  }
}

/**
 * Message type: networkCommand
 * Function for forcing a node with {nodeId} into WES mode.
 * Aka setting its nodeId to 0xFFFF temporarily. So it starts sending
 * wesSetupRequests. (changes back if it loses power, or to much time passes
 * before it recives a wesSetupResponse).
 * Makes a JSON string and sends it to the gateway.
 * @param nodeId INT: Id of the node to force into WES mode.
 * @param companyId String the companyId the message should be sent too.
 * @returns BOOLEAN
 */
async function sendForceWesMode(nodeId, companyId) {
  // Create message
  var message = '{"objectType": "networkCommand","nodeId": ' + nodeId +
      ',"cmd": 5,"payload":[2]}';

  // Send message
  if (await mqttGateway.isConnected()) {
    console.log(message)
    return await mqttGateway.publishMsg(message, companyId);
  } else {
    return false;
  }
}

/**
 * Message type: wesResponse
 * Function for setting up a node with {uniqueId}.
 * To have the node id {nodeId} aswell as the app settings {appSettings}
 * Makes a JSON string and sends it to the gateway.
 * @param nodeId INT: Id of the node to setup.
 * @param uniqueId String: uniqueId(HEX) of the node to setup.
 * @param nodeId String: appSettings(HEX) of the node to setup.
 * @param companyId String the companyId the message should be sent too.
 * @returns BOOLEAN
 */
async function sendWesSetupResponse(nodeId, uniqueId, appSettings, companyId) {
  // Create message
  var jsonObject = {};
  jsonObject.objectType = 'wesResponse';
  jsonObject.nodeId = nodeId;
  jsonObject.uidHex = uniqueId;
  jsonObject.appSettings = appSettings;
  var message = JSON.stringify(jsonObject);

  // Send message
  if (await mqttGateway.isConnected()) {
    console.log(message)
    return await mqttGateway.publishMsg(message, companyId);
  } else {
    return false;
  }
}

/* Combo functions */

/**
 * Function for deleting a node with {nodeId},
 * sends a database query to mark the node as "deleted" in the database.
 * Followed by a message to the node mesh network to force the node
 * into WESmode. The system will then handle the incoming setupRequest from this
 * node by setting it to 0xFFFF (deleted/not setup).
 * @param nodeId INT: Id of the node to delete.
 * @param companyId INT: Identifier for the company associated with the node.
 * @returns BOOLEAN
 */
async function deleteNode(nodeId, companyId) {
  // Send delete query to database.
  /* TODO: send query to database */
  dataBase.setNodeASDeleted(nodeId, companyId);
  // Send ForceWesMode to Node.
  if (sendForceWesMode(nodeId, companyId)){
    return true;
  }else{
    return false;
  }
}

