const http = require('http');

const server = http.createServer((req, res) => {
    res.statusCode = 200;
    res.setHeader('Content-Type', 'text/html');    
    res.write('<h1>Welcome to NCP X Hashicorp</h1>');
    res.write('<p>NaverCloud Platform CI/CD X vault !!!</p>');
    res.end()
});

server.listen(3000, '0.0.0.0', () => {
    console.log('listeing for requests on port 3000')
});
