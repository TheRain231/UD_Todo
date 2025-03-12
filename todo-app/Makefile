build:
    docker-compose build todo-app

run:
    docker-compose up


test:
    go test -v ./...


swag:
    swag init -g cmd/main.go


clean:
    docker-compose down -v
    docker rmi $(docker images -q)

start-db:
    docker-compose up -d mongodb

stop-db:
    docker-compose stop mongodb