export CURRENT_PATH := $(shell pwd)
export CUSTOM_THEME_PATH=${CURRENT_PATH}/Casper

export PORT=8080
export SQL_PASSWORD=example
export URL=http://localhost:8080

export SMTP_MAIL_USER=user@example.com
export SMTP_MAIL_PASS=1234
export SMTP_MAIL_HOST=smtp.mail.com
export SMTP_MAIL_PORT=25

dummy		    := $(shell touch artifacts)
include ./artifacts

dev:
	docker-compose up

up:
	docker-compose up -d

down:
	docker-compose down

logs:
	docker-compose logs  -f ghost
