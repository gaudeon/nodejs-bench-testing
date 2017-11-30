const cluster = require('cluster');
const net = require('net');
const numCPUs = require('os').cpus().length;

const port = process.argv.length > 2 && process.argv[2].match(/^\d+$/) && process.argv[2] * 1 > 1024 ? process.argv[2] : 8080;

if (cluster.isMaster) {
    for (let i = 0; i < numCPUs; i++) {
        cluster.fork();
    }
}
else {
    const server = net.createServer((c) => {
        // 'connection' listener

        //console.log('client connected');

        /* c.on('end', () => {
            console.log('client disconnected');
        }); */
  
        c.on('data', (data) => {
            //console.log(data.toString('utf8'));

            c.write('Hello\r\n');
            c.destroy();
        });
    });

    server.on('error', (err) => {
        throw err;
    });

    server.listen(port, () => {
    //console.log(`server is listening on ${port}`);
    });
}
