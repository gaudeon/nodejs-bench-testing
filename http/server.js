const http = require('http');

const port = process.argv[2].match(/^\d+$/) && process.argv[2] * 1 > 1024 ? process.argv[2] : 8080;

const requestHandler = (request, response) => {
  //console.log(request.url);
  response.end('Hello');
};

const server = http.createServer(requestHandler);

server.listen(port, (err) => {
  if (err) {
    return console.log('something bad happened', err);
  }

  //console.log(`server is listening on ${port}`);
});
