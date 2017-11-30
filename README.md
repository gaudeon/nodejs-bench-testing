# nodejs benchmarking

Just a repo containing my personal efforts to test benchmarking of http servers in various configurations.

## Environment

All benchmarks are running against node js servers (whatever verion you are currently running). I recommend using NVM so you can also change your version of node if you wish for testing across node versions. Of course, some module support may impacted based on the version you use.

I am using apache benchmark (ab) for the benchmarking. I am making 10k requests at 100 concurrent requests.

All servers are setup to simply respond with 'Hello\r\n' and the close the connection.

## Commands

```make bench-all```

Run all benchmark tests. Note: It seems running them consequetively like this does impact the performance of servers so even though this is here I would just use the individual benchmark commands instead.

```make bench-http```

Run a benchmark on a node.js server using the http module

```make bench-socket```

Run a benchmark on a node.js server using the net module

```make bench-http-pm2```

Run a benchmark on node.js server using the http module with pm2 for clustering (pm2 required - npm install -g pm2)

```make bench-socket-pm2```

Run a benchmark on node.js server using the net module with pm2 for clustering (pm2 required - npm install -g pm2)

```make bench-http-cluster```

Run a benchmark on node.js server using the http module with the cluster module for clustering

```make bench-socket-cluster```

Run a benchmark on node.js server using the net module with the cluster module for clustering
