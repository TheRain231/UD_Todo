package repository

import (
	"context"
	"fmt"
	"github.com/zhashkevych/todo-app"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

type AuthMongoDB struct {
	client *mongo.Client
	dbName string
}

func NewAuthMongoDB(client *mongo.Client, dbName string) *AuthMongoDB {
	return &AuthMongoDB{client: client, dbName: dbName}
}

func (r *AuthMongoDB) CreateUser(user todo.User) (int, error) {
	ctx := context.TODO()
	collection := r.client.Database(r.dbName).Collection(usersTable)
	counterCollection := r.client.Database(r.dbName).Collection("counters")

	// Генерация ID через коллекцию счетчиков
	counterFilter := bson.M{"_id": usersTable}
	counterUpdate := bson.M{"$inc": bson.M{"sequence_value": 1}}

	var counter struct {
		SequenceValue int `bson:"sequence_value"`
	}
	err := counterCollection.FindOneAndUpdate(
		ctx,
		counterFilter,
		counterUpdate,
		options.FindOneAndUpdate().SetUpsert(true).SetReturnDocument(options.After),
	).Decode(&counter)
	if err != nil {
		return 0, fmt.Errorf("failed to generate user ID: %w", err)
	}

	// Создаем документ для MongoDB
	userDoc := bson.M{
		"id":            counter.SequenceValue,
		"name":          user.Name,
		"username":      user.Username,
		"password_hash": user.Password, // Предполагается, что пароль уже хэширован
	}

	// Вставка пользователя
	_, err = collection.InsertOne(ctx, userDoc)
	if err != nil {
		return 0, fmt.Errorf("failed to create user: %w", err)
	}

	return counter.SequenceValue, nil
}

func (r *AuthMongoDB) GetUser(username, password string) (todo.User, error) {
	ctx := context.TODO()
	var user todo.User
	collection := r.client.Database(r.dbName).Collection(usersTable)

	// Поиск пользователя по username и password_hash
	filter := bson.M{
		"username":      username,
		"password_hash": password,
	}

	// Находим документ
	var result bson.M
	err := collection.FindOne(ctx, filter).Decode(&result)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			return user, fmt.Errorf("user not found: %w", err)
		}
		return user, fmt.Errorf("failed to get user: %w", err)
	}

	// Преобразуем BSON-документ обратно в структуру User
	if id, ok := result["id"].(int32); ok {
		user.Id = int(id)
	}
	if name, ok := result["name"].(string); ok {
		user.Name = name
	}
	if username, ok := result["username"].(string); ok {
		user.Username = username
	}
	if passwordHash, ok := result["password_hash"].(string); ok {
		user.Password = passwordHash
	}

	return user, nil
}
