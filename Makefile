DB_SOURCE ?= db
export DB_PASSWORD ?= 1234
export DB_USER ?= postgres
export DB_NAME ?= postgres
.DEFAULT_GOAL := all

db:
	docker stop test_db || true
	pip3 install -r requirements.txt
	docker run -d --rm -p 5432:5432 -e POSTGRES_PASSWORD=$(DB_PASSWORD) --log-driver=journald --name test_db postgres:alpine
	sleep 3
	rm -rf ../$(DB_SOURCE)/alembic/versions/* #  This is because we are not in prod and things WILL change!
	cd ../$(DB_SOURCE) && alembic revision --autogenerate -m "first"
	cd ../$(DB_SOURCE) && alembic upgrade head

serv:
	docker-compose down 2> /dev/null
	docker-compose pull
	docker-compose up -d

logs:
	docker-compose logs -f


all: db serv logs
