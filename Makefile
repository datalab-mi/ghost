export CURRENT_PATH := $(shell pwd)
export CUSTOM_THEME_PATH=${CURRENT_PATH}/custom-theme

export PORT=8080
export SQL_PASSWORD=example
export URL=http://localhost:8080

export SMTP_MAIL_USER=user@example.com
export SMTP_MAIL_PASS=1234
export SMTP_MAIL_HOST=smtp.mail.com
export SMTP_MAIL_PORT=25

dummy		    := $(shell touch artifacts)
include ./artifacts

${CUSTOM_THEME_PATH}:
	git clone https://github.com/datalab-mi/Casper.git custom-theme

dev: ${CUSTOM_THEME_PATH}
	docker-compose up

up: ${CUSTOM_THEME_PATH}
	docker-compose up -d

down:
	docker-compose down

logs:
	docker-compose logs  -f ghost

clean:
	@sudo rm -rf data data_sql
