# Используем официальный образ Go 1.21 на базе Alpine
FROM golang:1.23-alpine

# Проверяем версию Go
RUN go version

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем зависимости
COPY go.mod .
COPY go.sum .

# Скачиваем зависимости
RUN go mod download

# Копируем исходный код
COPY . .

# Собираем приложение
RUN go build -o todo-app ./cmd/main.go

# Команда для запуска приложения
CMD ["./todo-app"]