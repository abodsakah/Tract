'use strict'
const express = require('express');
const dbConnection = require('./src/dbConnection'); // gets information from the database
const gatewayMqtt = require('./src/gatewayMqttConnect'); //
const neoNodeMsgSender = require('./src/neoNodeMsgSender'); // Sends messages to the gateway
const neoNodeMsgParser = require('./src/neoNodeMsgParser'); // Parses messages from the gateway
const bcrypt = require('bcrypt'); // for hashing passwords


const app = express();


const port = process.env.PORT || 9000;



app.use((req, res, next) => {
    res.header("Access-Control-Allow-Origin", "*");
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
    console.log(`${req.method} request for '${req.url}'`);

    next();
});

app.get("/", (req, res) => {
    res.send("Hello World");
});

app.get("/api/user", async (req, res) => {
    let apiKey = req.query.key;
    let keyValid = await dbConnection.validateAPIKey(apiKey);
    let userId = req.query.id;
    let user;
    if (keyValid) {
        user = await dbConnection.getUserById(userId);

    } else {
        res.status(401).send("Invalid API key");
    }
    if(user) {
        res.send(user[0]);
    } else {
        res.status(404).send("User not found");
    }
});

app.get("/api/createUser", async (req, res) => {
    let apiKey = req.query.key;
    let email = req.query.email;
    let password = req.query.password;
    let firstName = req.query.firstname;
    let lastName = req.query.lastname;
    let nickname = req.query.nickname;
    let role = req.query.role;
    let companyId = req.query.companyid;

    let keyValid = await dbConnection.validateAPIKey(apiKey);

    if (keyValid) {
        let passHash = await bcrypt.hash(password, 12);
        try {
            let user = await dbConnection.createUser(email, passHash, firstName, lastName, nickname, role, companyId);
            res.send(user);
        } catch (e) {
            res.status(500).send("Error creating user");
        }

    } else {
        res.status(401).send("Invalid API key");
    }
});

app.get("/api/createCompany", async (req, res) => {
    let apiKey = req.query.key;
    let name = req.query.name;
    let phone = req.query.phone;
    let email = req.query.email;
    let adminMail = req.query.adminmail;
    let adminFirstName = req.query.adminfirstname;
    let adminLastName = req.query.adminlastname;
    let adminNickname = req.query.adminusername;
    let keyValid = await dbConnection.validateAPIKey(apiKey);

    if (keyValid) {
        try {
            let company = await dbConnection.createCompany(name,email, phone);
            let companyJson = {
                companyId: company[0]
            }

            let companyId = company[0];
            // generate random password
            let password = Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
            let passHash = await bcrypt.hash(password, 12);
            let user = await dbConnection.createUser(adminMail, passHash, adminFirstName, adminLastName, adminNickname, 1, companyId);
            console.log(req);
            // send success message
            let status = {
                status: "success",
                message: "Company created",
                email: adminMail,
                password: passwords
            }
            res.status(200).send(JSON.stringify(status));
        } catch (e) {
            console.log(e);
            res.status(500).send("Error creating company");
        }

    } else {
        res.status(401).send("Invalid API key");
    }
});

app.get("/api/getCompnies", async (req, res) => {
    let apiKey = req.query.key;
    let keyValid = await dbConnection.validateAPIKey(apiKey);

    if (keyValid) {
        try {
            let companies = await dbConnection.getCompanies();
            res.send(companies);
        } catch (e) {
            res.status(500).send("Error getting companies");
        }

    } else {
        res.status(401).send("Invalid API key");
    }
});

app.get("/api/nodes/neighborreq", async (req, res) => {
    let companyId = req.query.companyId;
    console.log(companyId);
    let data = await  neoNodeMsgSender.sendNeighborListRequest(companyId);
    let nodes = await neoNodeMsgParser.getNodes();
    console.log(await neoNodeMsgParser.nodes);
    res.send(await neoNodeMsgParser.nodes);
});

app.get("/api/nodes/nodeinfo", async (req, res) => {
    let companyId = req.query.companyId;
    let nodeId = req.query.nodeId;

    let data = await neoNodeMsgSender.sendNodeInfoRequest(companyId, nodeId);
    let nodeInfo = await neoNodeMsgParser.getNodesInfo();
    res.send(nodeInfo);
})

app.get("*", (req, res) => {
    res.status(404).send("Not found");
});

const server = app.listen(port, () => {
    console.log(`Server listening on port ${port}`);
});

// gracefully shutdown

process.on('SIGTERM', shutDown);
process.on('SIGINT', shutDown);

let connections = [];
server.on('connection', connection => {
    connections.push(connection);
    connection.on('close', () => {
        connections = connections.filter(curr => curr !== connection);
    });
});

/**
 * Shut down server by closing all connections
 */
function shutDown() {
    console.log('Received kill signal, shutting down gracefully');
    server.close(() => {
        console.log('Closed out remaining connections');
        process.exit(0);
    });

    // force close connections
    setTimeout(() => {
        console.error('Could not close connections in time, forcefully shutting down');
        process.exit(1);
    }, 10000);

    // force close connections after 10 seconds
    setTimeout(() => {
        console.error('Could not close connections in time, forcefully shutting down');
        process.exit(1);
    }, 30000);
    
    // close all connections
    connections.forEach(curr => curr.end());
    setTimeout(() => connections.forEach(curr => curr.destroy()), 5000);
}