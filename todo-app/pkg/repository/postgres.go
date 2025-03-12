package repository

import (
	"context"
	"fmt"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"time"
)

const (
	usersTable      = "users"       // Коллекция пользователей
	todoListsTable  = "todo_lists"  // Коллекция списков дел
	usersListsTable = "users_lists" // Коллекция связей пользователей и списков
	todoItemsTable  = "todo_items"  // Коллекция элементов списка
	listsItemsTable = "lists_items" // Коллекция связей списков и элементов
	countersTable   = "counters"    // Коллекция счетчиков для автоинкремента
)

type Config struct {
	Host     string // Хост MongoDB
	Port     string // Порт MongoDB
	Username string // Имя пользователя
	Password string // Пароль
	DBName   string // Имя базы данных
	SSLMode  string // Режим SSL (true/false)
}

func NewMongoDB(cfg Config) (*mongo.Client, error) {
	// Формируем URI для подключения к MongoDB
	time.Sleep(5 * time.Second) // Ждем 5 секунд
	uri := fmt.Sprintf("mongodb://%s:%s@%s:%s/%s?authSource=admin&ssl=%s",
		cfg.Username,
		cfg.Password,
		"mongodb", // Имя сервиса из docker-compose.yml
		cfg.Port,
		cfg.DBName,
		cfg.SSLMode,
	)

	// Настройки клиента
	clientOptions := options.Client().ApplyURI(uri)
	client, err := mongo.Connect(context.TODO(), clientOptions)
	if err != nil {
		return nil, fmt.Errorf("failed to connect to MongoDB: %w", err)
	}

	// Проверка подключения
	err = client.Ping(context.TODO(), nil)
	if err != nil {
		return nil, fmt.Errorf("failed to ping MongoDB: %w", err)
	}

	return client, nil
}
