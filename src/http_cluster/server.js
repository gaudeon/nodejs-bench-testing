const cluster = require('cluster');
const http = require('http');
const numCPUs = require('os').cpus().length;

const port = process.argv.length > 2 && process.argv[2].match(/^\d+$/) && process.argv[2] * 1 > 1024 ? process.argv[2] : 8080;


const requestHandler = (request, response) => {
    //console.log(request.url);
    response.setHeader('Connection', 'close');
    response.end('Hello\r\n');
};

if (cluster.isMaster) {
    for (var i = 0; i < numCPUs; i++) {
        cluster.fork();
    }
}
else {
    const server = http.createServer(requestHandler);

    server.listen(port, (err) => {
        if (err) {
            return console.log('something bad happened', err);
        }

        //console.log(`server is listening on ${port}`);
    });
}
