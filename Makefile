# ==============================================================================
# Orchestration Lifecycle
# ==============================================================================
setup:
	@echo "Configuring the host..."
	sudo bash setup-host.sh

up: _check-env _db-up _db-wait _apps-up _jenkins-wait
	@echo "Servidor no ar!"
	@echo "   Portainer: https://IP:9443"
	@echo "   NPM:       http://IP:81"
	@echo "   Jenkins:   http://IP:8080"

_check-env:
	@if [ ! -f .env ]; then \
		echo "File .env not found."; \
		echo "Copy the .env.example, rename to .env, and edit the copy with your secrets."; \
		exit 1; \
	fi

_db-up:
	@echo "[1/4] Docker raising PostgreSQL..."
	@docker compose -f docker-compose-postgres.yml up -d

_db-wait:
	@echo "[2/4] Waiting for PostgreSQL get ready..."
	@until docker exec postgres pg_isready -U dbadmin >/dev/null 2>&1; do sleep 1; done
	@echo "=> PostgreSQL is ready!"

_apps-up:
	@echo "[3/4] Raising applications (NPM, Portainer, Jenkins)..."
	@docker compose -f docker-compose-nginx-proxy-manager.yml up -d
	@docker compose -f docker-compose-portainer.yml up -d
	@docker compose -f jenkins/docker-compose.yml up -d --build

_jenkins-wait:
	@echo "[4/4] Waiting Jenkins..."
	@for i in $$(seq 1 30); do \
		if docker exec jenkins-controller curl -fsS http://localhost:8080/login >/dev/null 2>&1; then \
			echo "=> Jenkins is ready!"; \
			break; \
		fi; \
		sleep 3; \
	done

down:
	@echo " Stopping containers..."
	@docker compose -f jenkins/docker-compose.yml down
	@docker compose -f docker-compose-portainer.yml down
	@docker compose -f docker-compose-nginx-proxy-manager.yml down
	@docker compose -f docker-compose-postgres.yml down
	@echo "Tudo parado."

restart: down up

status:
	@docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

logs:
	@docker logs jenkins-controller -f

# ==============================================================================
# Maintenance
# ==============================================================================
backup:
	@sudo -u srvuser bash backup-postgres.sh