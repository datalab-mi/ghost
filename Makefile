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

export DATA_DIR ?= data
export DATA_DB_DIR ?= data_sql

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

clean-data:
	@sudo rm -rf ${DATA_DIR}

clean-data-sql:
	@sudo rm -rf ${DATA_DB_DIR}

clean: clean-data clean-data-sql

${DATA_DIR}:
	mkdir -p ${DATA_DIR}

${DATA_DB_DIR}:
	mkdir -p ${DATA_DB_DIR}

backup-settings:
	tar -zcvf settings.tar.gz data/settings/
	rclone copy settings.tar.gz swift:app-images
	rm -rf settings.tar.gz
	
backup-data:
	tar -zcvf data.tar.gz data/data/
	rclone copy data.tar.gz swift:app-images
	rm -rf data.tar.gz

backup: backup-images backup-settings backup-data

restore-images:
	rclone copy -q --progress swift:app-images/images.tar.gz images.tar.gz
