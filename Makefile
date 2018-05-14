PROJECT = nginx-proxy

.PHONY: start
start:
	docker-compose -p $(PROJECT) up -d --build && \
	docker logs -f nginx-proxy

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
