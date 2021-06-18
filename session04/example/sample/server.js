'use strict';
const ip = require('ip');
const http = require('http');
const Vault = require('hashi-vault-js');

const vault = new Vault( {
    https: false,
    baseUrl: `http://101.101.216.84:8200/v1`,
    rootPath: 'kv',
    timeout: 2000,
    proxy: false
});

let token = ""
// Start function
const start = async () => {
    try {
        const status = await vault.healthCheck();
        console.log(status)
        const login_result = await new Vault( {
            https: false,
            baseUrl: `http://101.101.216.84:8200/v1`,
            timeout: 2000,
            proxy: false
        }).loginWithUserpass("admin", "password");
        console.log(login_result)
        token = login_result.client_token
    }
    catch (err) {
        if(err.isVaultError) {
            console.log(err.vaultHelpMessage);
        }
        else {
            throw err;
        }
    }
}
start()

const server = http.createServer(async (req, res) => {
    try {
        console.log(token)
        const secret_data = await vault.readKVSecret(token, 'ncp/secret_value');
        const mysql_password_data = await vault.readKVSecret(token, 'ncp/mysql_password');
        const static_data = await vault.readKVSecret(token, 'ncp/static_data');
        const secret_number = secret_data.data.number
        const mysql_password = mysql_password_data.data.password
        const body_color = static_data.data.color
        res.statusCode = 200;
        res.setHeader('Content-Type', 'text/html');    
        res.write(`
        <html>
            <head>
                <title>NCP x HashiCorp</title>
                <style>
                h2 {text-align: center; color: white;}
                h3 {text-align: center; color: white;}
                h1 {
                    padding: 60px;
                    text-align: center;
                    color: white;
                    font-size: 60px;
                }
                </style>
            </head>
            <body style="background-color: ${body_color};">
                <h1>Welcome to NCP X Hashicorp</h1>
                <h2>NaverCloud Platform CI/CD X HashiCorp Vault</h2>
                <hr>
                <h3>My IP is ${ip.address()}</h3>
                <h3>secret_value is ${secret_number}</h3>
                <h3>mysql_password is ${mysql_password}</h3>
            </body>
        </html>
`);
        res.end()
    }
    catch (err) {
        if(err.isVaultError) {
            console.log(err.vaultHelpMessage);
        }
        else {
            throw err;
        }
    }
});

server.listen(3000, '0.0.0.0', () => {
    console.log('listeing for requests on port 3000')
});
