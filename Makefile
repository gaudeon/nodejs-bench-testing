AB = /usr/bin/env ab
NODE = /usr/bin/env node
NPM = /usr/bin/env npm
PM2 = /usr/bin/env pm2

OUT_DIR := ./out_$(shell /usr/bin/env date +%Y%m%d_%H%M%S)

ALL_SUMMARY_FILES := $(OUT_DIR)/*_summary.txt

HTTP_SERVER = src/http/server.js
HTTP_SERVER_PORT = 8080
HTTP_SERVER_PIDFILE = ./pids/http_server.pid
HTTP_SERVER_CSVFILE = $(OUT_DIR)/http_server_data.csv
HTTP_SERVER_SUMMARYFILE = $(OUT_DIR)/http_server_summary.txt

HTTPS_SERVER = src/https/server.js
HTTPS_SERVER_PORT = 8080
HTTPS_SERVER_PIDFILE = ./pids/https_server.pid
HTTPS_SERVER_CSVFILE = $(OUT_DIR)/https_server_data.csv
HTTPS_SERVER_SUMMARYFILE = $(OUT_DIR)/https_server_summary.txt

HTTP_CLUSTER_SERVER = src/http_cluster/server.js
HTTP_CLUSTER_SERVER_PORT = 8080
HTTP_CLUSTER_SERVER_PIDFILE = ./pids/http_cluster_server.pid
HTTP_CLUSTER_SERVER_CSVFILE = $(OUT_DIR)/http_cluster_server_data.csv
HTTP_CLUSTER_SERVER_SUMMARYFILE = $(OUT_DIR)/http_cluster_server_summary.txt

SOCKET_SERVER = src/socket/server.js
SOCKET_SERVER_PORT = 8080
SOCKET_SERVER_PIDFILE = ./pids/socket_server.pid
SOCKET_SERVER_CSVFILE = $(OUT_DIR)/socket_server_data.csv
SOCKET_SERVER_SUMMARYFILE = $(OUT_DIR)/socket_server_summary.txt

SOCKET_CLUSTER_SERVER = src/socket_cluster/server.js
SOCKET_CLUSTER_SERVER_PORT = 8080
SOCKET_CLUSTER_SERVER_PIDFILE = ./pids/socket_cluster_server.pid
SOCKET_CLUSTER_SERVER_CSVFILE = $(OUT_DIR)/socket_cluster_server_data.csv
SOCKET_CLUSTER_SERVER_SUMMARYFILE = $(OUT_DIR)/socket_cluster_server_summary.txt

PM2_INSTANCES = max

PM2_HTTP_SERVER_CSVFILE = $(OUT_DIR)/pm2_http_server_data.csv
PM2_HTTP_SERVER_SUMMARYFILE = $(OUT_DIR)/pm2_http_server_summary.txt

PM2_SOCKET_SERVER_CSVFILE = $(OUT_DIR)/pm2_socket_server_data.csv
PM2_SOCKET_SERVER_SUMMARYFILE = $(OUT_DIR)/pm2_socket_server_summary.txt

pid-dir:
	mkdir -p ./pids

node-version:
	mkdir -p $(OUT_DIR)
	$(NODE) -v > "$(OUT_DIR)/node_version.txt"

certs-dir:
	mkdir -p ./certs

certs: certs-dir
	./scripts/generate_localhost_cert.sh

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

start-https: pid-dir certs
	$(NODE) ${HTTPS_SERVER} ${HTTPS_SERVER_PORT} & echo "$$!" > "${HTTPS_SERVER_PIDFILE}"
	while ! lsof -i :${HTTPS_SERVER_PORT} | grep -q LISTEN; do sleep 10; done

ab-https: node-version
	$(AB) -n 10000 -c 100 -e "${HTTPS_SERVER_CSVFILE}" http://localhost:${HTTPS_SERVER_PORT}/ > "${HTTPS_SERVER_SUMMARYFILE}"

stop-https:
	if [ -f "${HTTPS_SERVER_PIDFILE}" ]; \
	then pkill -F "${HTTPS_SERVER_PIDFILE}"; rm -f "${HTTPS_SERVER_PIDFILE}"; \
	fi

bench-https: start-https ab-https stop-https

start-http-pm2:
	$(PM2) start -i ${PM2_INSTANCES} ${HTTP_SERVER}
	while ! lsof -i :${HTTP_SERVER_PORT} | grep -q LISTEN; do sleep 10; done

ab-http-pm2: node-version
	$(AB) -n 10000 -c 100 -e "${PM2_HTTP_SERVER_CSVFILE}" http://localhost:${HTTP_SERVER_PORT}/ > "${PM2_HTTP_SERVER_SUMMARYFILE}"

stop-http-pm2:
	$(PM2) delete ${HTTP_SERVER}

bench-http-pm2: start-http-pm2 ab-http-pm2 stop-http-pm2

start-http-cluster: pid-dir
	$(NODE) ${HTTP_CLUSTER_SERVER} ${HTTP_CLUSTER_SERVER_PORT} & echo "$$!" > "${HTTP_CLUSTER_SERVER_PIDFILE}"
	while ! lsof -i :${HTTP_CLUSTER_SERVER_PORT} | grep -q LISTEN; do sleep 10; done

ab-http-cluster: node-version
	$(AB) -n 10000 -c 100 -e "${HTTP_CLUSTER_SERVER_CSVFILE}" http://localhost:${HTTP_CLUSTER_SERVER_PORT}/ > "${HTTP_CLUSTER_SERVER_SUMMARYFILE}"

stop-http-cluster:
	if [ -f "${HTTP_CLUSTER_SERVER_PIDFILE}" ]; \
	then pkill -F "${HTTP_CLUSTER_SERVER_PIDFILE}"; rm -f "${HTTP_CLUSTER_SERVER_PIDFILE}"; \
	fi

bench-http-cluster: start-http-cluster ab-http-cluster stop-http-cluster

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

start-socket-cluster: pid-dir
	$(NODE) ${SOCKET_CLUSTER_SERVER} ${SOCKET_CLUSTER_SERVER_PORT} & echo "$$!" > "${SOCKET_CLUSTER_SERVER_PIDFILE}"
	while ! lsof -i :${SOCKET_CLUSTER_SERVER_PORT} | grep -q LISTEN; do sleep 10; done

ab-socket-cluster: node-version
	$(AB) -n 10000 -c 100 -e "${SOCKET_CLUSTER_SERVER_CSVFILE}" http://localhost:${SOCKET_CLUSTER_SERVER_PORT}/ > "${SOCKET_CLUSTER_SERVER_SUMMARYFILE}"

stop-socket-cluster:
	if [ -f "${SOCKET_CLUSTER_SERVER_PIDFILE}" ]; \
	then pkill -F "${SOCKET_CLUSTER_SERVER_PIDFILE}"; rm -f "${SOCKET_CLUSTER_SERVER_PIDFILE}"; \
	fi

bench-socket-cluster: start-socket-cluster ab-socket-cluster stop-socket-cluster

report-results:
	./scripts/parse_summary.pl ${ALL_SUMMARY_FILES}

bench-all: bench-http bench-https bench-http-pm2 bench-socket bench-http-pm2 bench-socket-cluster report-results

.PHONY: pid-dir node-version certs-dir certsstart-http-pm2 ab-http-pm2 stop-http-pm2 bench-http-pm2 start-http ab-http stop-http bench-http start-https ab-https stop-https bench-https start-http-cluster ab-http-cluster stop-http-cluster bench-http-cluster start-socket-pm2 ab-socket-pm2 stop-socket-pm2 bench-socket-pm2 start-socket ab-socket stop-socket bench-socket start-socket-cluster ab-socket-cluster stop-socket-cluster bench-socket-cluster bench-all report-results
