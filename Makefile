PROJECT = nginx-proxy

.PHONY: start
start:
	docker-compose -p $(PROJECT) up -d --build && \
	docker logs -f nginx-proxy

.PHONY: network
network:
	@if docker network inspect nginxproxy_default >/dev/null 2>/dev/null ; then echo network nginxproxy_default exists; else docker network -d bridge create nginxproxy_default; fi

.PHONY: restart
restart:
	docker-compose -p $(PROJECT) kill && \
	docker-compose -p $(PROJECT) rm -f && \
	docker-compose -p $(PROJECT) up -d --build && \
	docker logs -f nginx-proxy

.PHONY: logs
logs:
	docker-compose -p $(PROJECT) logs

.PHONY: kill
kill:
	docker-compose -p $(PROJECT) kill

.PHONY: ps
ps:
	docker-compose -p $(PROJECT) ps
