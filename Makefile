AB=/usr/bin/env ab
NODE=/usr/bin/env node
NPM=/usr/bin/env npm

DATE=$$(/usr/bin/env date +%Y%m%d_%H%M%S)
OUT_DIR="out_${DATE}"

HTTP_SERVER=http/server.js
HTTP_SERVER_PORT=8001
HTTP_SERVER_PIDFILE=./http_server.pid

node_modules:
	$(NPM) install

start-http: node_modules
	$(NODE) ${HTTP_SERVER} ${HTTP_SERVER_PORT} & echo "$$!" > "${HTTP_SERVER_PIDFILE}"
	while ! lsof -i :${HTTP_SERVER_PORT} | grep -q LISTEN; do sleep 10; done

ab-http: 
	mkdir -p ${OUT_DIR}
	$(AB) -n 10000 -c 100 -e "${OUT_DIR}/http_server_data.csv" http://localhost:${HTTP_SERVER_PORT}/ > "${OUT_DIR}/http_server_summary.txt"

stop-http:
	if [ -f "${HTTP_SERVER_PIDFILE}" ]; \
	then pkill -F "${HTTP_SERVER_PIDFILE}"; rm -f "${HTTP_SERVER_PIDFILE}"; \
	fi

bench-http: start-http ab-http stop-http

bench-all: bench-http

.PHONY: node_modules start-http ab-http stop-http bench-http bench-all
