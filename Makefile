default: help

env ?= local

cnf ?= $(PWD)/deployment/config/$(env)/.env
include $(cnf)
export $(shell sed 's/=.*//' $(cnf))


DEPLOYMENT_DIR := deployment
DEPLOYMENT_CONFIG_DIR := $(DEPLOYMENT_DIR)/config

BLACK        := $(shell tput -Txterm setaf 0)
RED          := $(shell tput -Txterm setaf 1)
GREEN        := $(shell tput -Txterm setaf 2)
YELLOW       := $(shell tput -Txterm setaf 3)
LIGHTPURPLE  := $(shell tput -Txterm setaf 4)
PURPLE       := $(shell tput -Txterm setaf 5)
BLUE         := $(shell tput -Txterm setaf 6)
WHITE        := $(shell tput -Txterm setaf 7)

RESET := $(shell tput -Txterm sgr0)
TARGET_COLOR := $(BLUE)


.PHONY: help
help: ## - Show help message
	@printf "${TARGET_COLOR} usage: make [target]\n${RESET}"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s${RESET} %s\n", $$1, $$2}'
.DEFAULT_GOAL := help

$(info ${YELLOW}Deployment Information${RESET})
$(info ${GREEN}- DEPLOYMENT_DIR                     : $(DEPLOYMENT_DIR) ${RESET})
$(info ${GREEN}- DEPLOYMENT_CONFIG_DIR              : $(DEPLOYMENT_CONFIG_DIR) ${RESET})
$(info ${GREEN}- DEPLOYMENT_DOCKER_COMPOSE          : $(DEPLOYMENT_DOCKER_COMPOSE) ${RESET})
$(info ${GREEN}- DEPLOYMENT_DOCKER_COMPOSE_OVERRIDE : $(DEPLOYMENT_DOCKER_COMPOSE_OVERRIDE) ${RESET})


#======================= Commands =======================#
create-network: # Create network overlay
	docker network create --driver=overlay $(PUBLIC_NETWORK) 2>/dev/null || true

deploy-service: # Deploy service to stack
	docker stack deploy -c ${DEPLOYMENT_DIR}/stack-$(service).yml $(env)
	docker service ps --no-trunc $(env)_traefik

log-service:
	docker service logs -f $(env)_$(service)
