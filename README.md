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

## Benchmarking Results

### 2017-11-30

OS: MacOS Sierra (10.12.6)
CPU: 4 Core (8 Threads) 2.3 GHz Intel Core i7
RAM: 16 GB 1600 MHz DDR3
DISK: 500GB APPLE SSD SM0512F

V8’s max_old_space_size left at default (~1.5G)

HTTP             1,535 RPS
Socket           1,778 RPS
HTTP/PM2         1,407 RPS
Socket/PM2        454 RPS
HTTP/Cluster      767 RPS
Socket/Cluster    685 RPS

---

OS: CentOS release 6.9 (Final)
CPU: 1 Core (1 Thread) Intel(R) Xeon(R) CPU E3-1230 V2 @ 3.30GHz
RAM: 4G DDR3-ECC-Unbuffered Memory
DISK: 40GB WD-RE4 7200 RPM SATA Drives

V8’s max_old_space_size left at default (~1.5G)

HTTP             3,868 RPS
Socket           5,945 RPS

---

OS: CentOS release 6.9 (Final)
CPU: 2 Core (2 Threads) Intel(R) Xeon(R) CPU E3-1265L V2 @ 2.50GHz
RAM: 2G DDR3-ECC-Unbuffered Memory
DISK: 100GB WD-RE4 7200 RPM SATA Drives

V8’s max_old_space_size left at default (~1.5G)

HTTP             3,516 RPS
Socket           6,727 RPS
HTTP/PM2         1,911 RPS
Socket/PM2       2,484 RPS
HTTP/Cluster     2,503 RPS
Socket/Cluster   3,183 RPS

---

OS: CentOS release 6.9 (Final)
CPU: 4 Core (8 Threads) Intel(R) Xeon(R) CPU E3-1230 V2 @ 3.30GHz
RAM: 16G DDR3-ECC-Unbuffered Memory
DISK: 1TB WD-RE4 7200 RPM SATA Drives

V8’s max_old_space_size left at default (~1.5G)

HTTP             6,746 RPS
Socket          13,769 RPS
HTTP/PM2         5,851 RPS
Socket/PM2       6,760 RPS
HTTP/Cluster     7,187 RPS
Socket/Cluster   7,124 RPS

