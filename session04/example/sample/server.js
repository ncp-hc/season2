const http = require('http');

let vaultoption = {
    apiVersion: "v1",
    endpoint: `http://101.101.216.84:8200`,
};
let VaultSDK = require("node-vault")(vaultoption);
const username = "admin"
const password = "password"

VaultSDK.userpassLogin({ username, password })
.then((result) => {
    console.log(result)
    res.statusCode = 200;
    res.setHeader('Content-Type', 'text/html');    
    res.write('<h1>Welcome to NCP X Hashicorp</h1>');
    res.write('<p>NaverCloud Platform CI/CD X vault !!!</p>');
    res.end()
})
.catch((err) => console.error(err.message));

const server = http.createServer((req, res) => {
    VaultSDK.read('kv/data/ncp/secret_value')
    .then((secret_value) => {
        console.log(secret_value.data.data)
        secret_number = secret_value.data.data.number
        VaultSDK.read('kv/data/ncp/mysql_password')
        .then((mysql_password) => {
            console.log(mysql_password.data.data)
            mysql_password = mysql_password.data.data.password
            res.statusCode = 200;
            res.setHeader('Content-Type', 'text/html');    
            res.write('<h1>Welcome to NCP X Hashicorp</h1>');
            res.write('<hr>');
            res.write('<h2>NaverCloud Platform CI/CD X vault !!!</h2>');
            res.write(`<h2>secret_value is ${secret_number}</h2>`);
            res.write(`<h2>mysql_password is ${mysql_password}</h2>`);
            res.end()
        })
    })
    .catch((err) => console.error(err.message));
});

server.listen(3000, '0.0.0.0', () => {
    console.log('listeing for requests on port 3000')
});
