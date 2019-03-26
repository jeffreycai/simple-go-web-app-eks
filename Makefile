COMPOSE_RUN_AWS=docker-compose run --rm aws

# check if the current account is the target account we want the pipeline to run against
ifdef CI
is_it_my_turn: dotenv whoami
	bash make/is_it_my_turn.sh init
endif

# provision eks cfn stacks
stack-up: dotenv whoami
	$(COMPOSE_RUN_AWS) make _stack-up
.PHONY: stackup

# decommision cfn stacks
stack-down: dotenv whoami
	$(COMPOSE_RUN_AWS) make _stack-down
.PHONY: stackdown

# HELPERS
shell: dotenv whoami
	$(COMPOSE_RUN_AWS) make _shell
.PHONY: shell

# replaces .env with DOTENV if the variable is specified
dotenv: init
ifdef CI
	@mkdir -p ~/.docker
	@echo '${DOCKER_AUTH_CONFIG}' > ~/.docker/config.json
endif
ifdef DOTENV
	cp -f $(DOTENV) .env
else
	$(MAKE) .env
endif

# init env vars
init:
	@echo "Pre-Make initializing .."
	@bash make/init.sh

# makeup the runner's name and set in .env file
whoami: dotenv
	@bash make/whoami.sh
.PHONY: whoami

# creates .env with .env.template if it doesn't exist already
.env:
	cp -f .env.template .env
	env >> .env

# INTERNAL TARGETS
_shell: _assumeRole
	bash make/shell.sh
	bash
.PHONY: _shell

_stack-up: _assumeRole
	bash make/stackup.sh
.PHONY: _stackup

_stack-down: _assumeRole
	bash make/stackdown.sh
.PHONY: _stackdown

# assume a role
_assumeRole:
ifndef AWS_SESSION_TOKEN
ifdef AWS_ACCESS_KEY_ID
		$(eval export AWS_ROLE_TO_ASSUME = $(shell cat stage_output.aws_role_to_assume))
		@echo "No existing AWS_SESSION_TOKEN. Assuming into role: $(AWS_ROLE_TO_ASSUME)"
		$(call assumeRole)
else
		@echo "No existing AWS_ACCESS_KEY_ID. Using the IAM Role attached to the instance"
endif
endif
	$(eval export AWS_ACCOUNT_ID = $(shell cat stage_output.aws_account_id))

define assumeRole
	$(eval KST = $(shell aws sts assume-role --role-arn $(AWS_ROLE_TO_ASSUME) --role-session-name cd | jp -u "Credentials.[AccessKeyId, SecretAccessKey, SessionToken] | join(' ', @)"))
	$(eval export AWS_ACCESS_KEY_ID = $(shell echo $(KST) | cut -d' ' -f1))
	$(eval export AWS_SECRET_ACCESS_KEY = $(shell echo $(KST) | cut -d' ' -f2))
	$(eval export AWS_SESSION_TOKEN = $(shell echo $(KST) | cut -d' ' -f3))
endef

