SHELL = /bin/bash

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

# rclone backup
export RCLONE_PATH := $(shell which rclone)

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

install-rclone:
	@echo "# install rclone"
	@if [ -x "${RCLONE_PATH}" ]; then echo "${RCLONE_PATH} exists" ; \
         else curl -kL -s https://rclone.org/install.sh | sudo -E bash ; \
         fi

check-rclone:
	@if ! which ${RCLONE_PATH} > /dev/null ; then echo "# rclone not found. Use 'make install-rclone'" ; false ; fi

backup-%: check-rclone
	@tar -zcvf $*.tar.gz data/$*/
	@${RCLONE_PATH} -q --progress copy $*.tar.gz swift:app-images
	@rm -rf $*.tar.gz

backup-mysql: check-rclone down
	@echo taring ${DATA_DB_DIR} to data-sql.tar
	cd $$(dirname ${DATA_DB_DIR}) && sudo tar --create --file=${CURRENT_PATH}/data-sql.tar --listed-incremental=${CURRENT_PATH}/data-sql.snar ${DATA_DB_DIR}
	@${RCLONE_PATH} -q --progress copy data-sql.tar swift:app-images
	@rm -rf data-sql.tar

backup: backup-images backup-settings backup-data backup-mysql

restore-%: check-rclone
	@${RCLONE_PATH} copy -q --progress swift:app-images/$*.tar.gz .
	@sudo tar xzvf $*.tar.gz  
	@rm -rf ${DATA_DIR}/$*.tar.gz

restore-mysql: check-rclone down
	@${RCLONE_PATH} copy -q --progress swift:app-images/data-sql.tar .
	@if [ -d "$(DATA_DB_DIR)" ] ; then (echo purging ${DATA_DB_DIR} && sudo rm -rf ${DATA_DB_DIR} && echo purge done) ; fi
	@\
	if [ ! -f "data-sql.tar" ];then\
		(echo no such archive "data-sql.tar" && exit 1);\
	else\
		echo restoring from data-sql.tar to ${DATA_DB_DIR} && \
		sudo tar xf data-sql.tar -C $$(dirname ${DATA_DB_DIR}) && \
		echo backup restored;\
	fi;

restore: ${DATA_DIR} restore-images restore-settings restore-data restore-mysql
