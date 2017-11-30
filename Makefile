AB = /usr/bin/env ab
NODE = /usr/bin/env node
NPM = /usr/bin/env npm
PM2 = /usr/bin/env pm2

OUT_DIR := ./out_$(shell /usr/bin/env date +%Y%m%d_%H%M%S)

HTTP_SERVER = src/http/server.js
HTTP_SERVER_PORT = 8080
HTTP_SERVER_PIDFILE = ./pids/http_server.pid
HTTP_SERVER_CSVFILE = $(OUT_DIR)/http_server_data.csv
HTTP_SERVER_SUMMARYFILE = $(OUT_DIR)/http_server_summary.txt

SOCKET_SERVER = src/socket/server.js
SOCKET_SERVER_PORT = 8080
SOCKET_SERVER_PIDFILE = ./pids/socket_server.pid
SOCKET_SERVER_CSVFILE = $(OUT_DIR)/socket_server_data.csv
SOCKET_SERVER_SUMMARYFILE = $(OUT_DIR)/socket_server_summary.txt

PM2_INSTANCES = 8
PM2_HTTP_SERVER_CSVFILE = $(OUT_DIR)/pm2_http_server_data.csv
PM2_HTTP_SERVER_SUMMARYFILE = $(OUT_DIR)/pm2_http_server_summary.txt
PM2_SOCKET_SERVER_CSVFILE = $(OUT_DIR)/pm2_socket_server_data.csv
PM2_SOCKET_SERVER_SUMMARYFILE = $(OUT_DIR)/pm2_socket_server_summary.txt

pid-dir:
	mkdir -p ./pids

node-version:
	mkdir -p $(OUT_DIR)
	$(NODE) -v > "$(OUT_DIR)/node_version.txt"

start-http: pid-dir
	$(NODE) ${HTTP_SERVER} ${HTTP_SERVER_PORT} & echo "$$!" > "${HTTP_SERVER_PIDFILE}"
	while ! lsof -i :${HTTP_SERVER_PORT} | grep -q LISTEN; do sleep 10; done

ab-http: node-version
	$(AB) -n 10000 -c 100 -e "${HTTP_SERVER_CSVFILE}" http://localhost:${HTTP_SERVER_PORT}/ > "${HTTP_SERVER_SUMMARYFILE}"

stop-http:
	if [ -f "${HTTP_SERVER_PIDFILE}" ]; \
	then pkill -F "${HTTP_SERVER_PIDFILE}"; rm -f "${HTTP_SERVER_PIDFILE}"; \
	fi

bench-http: start-http ab-http stop-http

start-http-pm2:
	$(PM2) start -i ${PM2_INSTANCES} ${HTTP_SERVER}
	while ! lsof -i :${HTTP_SERVER_PORT} | grep -q LISTEN; do sleep 10; done

ab-http-pm2: node-version
	$(AB) -n 10000 -c 100 -e "${PM2_HTTP_SERVER_CSVFILE}" http://localhost:${HTTP_SERVER_PORT}/ > "${PM2_HTTP_SERVER_SUMMARYFILE}"

stop-http-pm2:
	$(PM2) delete ${HTTP_SERVER}

bench-http-pm2: start-http-pm2 ab-http-pm2 stop-http-pm2

start-socket: pid-dir
	$(NODE) ${SOCKET_SERVER} ${SOCKET_SERVER_PORT} & echo "$$!" > "${SOCKET_SERVER_PIDFILE}"
	while ! lsof -i :${SOCKET_SERVER_PORT} | grep -q LISTEN; do sleep 10; done

ab-socket: node-version
	$(AB) -n 10000 -c 100 -e "${SOCKET_SERVER_CSVFILE}" http://localhost:${SOCKET_SERVER_PORT}/ > "${SOCKET_SERVER_SUMMARYFILE}"

stop-socket:
	if [ -f "${SOCKET_SERVER_PIDFILE}" ]; \
	then pkill -F "${SOCKET_SERVER_PIDFILE}"; rm -f "${SOCKET_SERVER_PIDFILE}"; \
	fi

bench-socket: start-socket ab-socket stop-socket

start-socket-pm2:
	$(PM2) start -i ${PM2_INSTANCES} ${SOCKET_SERVER}
	while ! lsof -i :${SOCKET_SERVER_PORT} | grep -q LISTEN; do sleep 10; done

ab-socket-pm2: node-version
	$(AB) -n 10000 -c 100 -e "${PM2_SOCKET_SERVER_CSVFILE}" http://localhost:${SOCKET_SERVER_PORT}/ > "${PM2_SOCKET_SERVER_SUMMARYFILE}"

stop-socket-pm2:
	$(PM2) delete ${SOCKET_SERVER}

bench-socket-pm2: start-socket-pm2 ab-socket-pm2 stop-socket-pm2

bench-all: bench-http bench-http-pm2 bench-socket bench-http-pm2

.PHONY: pid-dir node-version start-http-pm2 ab-http-pm2 stop-http-pm2 bench-http-pm2 start-http ab-http stop-http bench-http start-socket-pm2 ab-socket-pm2 stop-socket-pm2 bench-socket-pm2 start-socket ab-socket stop-socket bench-socket bench-all
