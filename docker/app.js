const http = require('http');

const PORT = process.env.PORT || 3000;
const SECRET_FROM_SSM = process.env.DEMO_SECRET || 'not-set';

const server = http.createServer((req, res) => {
  const path = req.url || '/';
  if (path === '/health') {
    res.writeHead(200, {'Content-Type': 'application/json'});
    return res.end(JSON.stringify({status:'ok'}));
  }
  res.writeHead(200, {'Content-Type': 'text/plain'});
  res.end(`Hello World from ECS! Secret:${SECRET_FROM_SSM}\n`);
});

server.listen(PORT, () => {
  console.log(`Server listening on ${PORT}`);
});
