export CURRENT_PATH := $(shell pwd)
export CUSTOM_THEME_PATH=${CURRENT_PATH}/custom-theme

export MYSQL_VERSION ?= 5.7
export GHOST_VERSION ?= 4.8
export PORT ?= 8080
export SQL_PASSWORD ?= example
export URL ?= http://localhost:8080

export SMTP_MAIL_FROM ?= 'web <web@mydomain.com>'
export SMTP_MAIL_USER ?= user@example.com
export SMTP_MAIL_PASS ?= 1234
export SMTP_MAIL_HOST ?= smtp.mail.com
export SMTP_MAIL_PORT ?= 25

# if defined, use curl instead of git
export USE_CURL :=

dummy		    := $(shell touch artifacts)
include ./artifacts

${CUSTOM_THEME_PATH}:
	if [ -n "${USE_CURL}" ]; then \
          mkdir ${CUSTOM_THEME_PATH} && \
          curl -kL -s https://github.com/datalab-mi/Casper/archive/refs/heads/master.tar.gz | \
            tar -zxvf - -C ${CUSTOM_THEME_PATH} --strip 1 ; \
        else \
          git clone https://github.com/datalab-mi/Casper.git custom-theme ; \
        fi

dev: ${CUSTOM_THEME_PATH}
	docker-compose up

up: ${CUSTOM_THEME_PATH}
	docker-compose up -d
# up-db or up-ghost
up-%: ${CUSTOM_THEME_PATH}
	docker-compose up -d $*

down:
	docker-compose down

stop:
	docker-compose stop
stop-%:
	docker-compose stop $*

logs:
	docker-compose logs  -f ghost

clean:
	@sudo rm -rf data data_sql
