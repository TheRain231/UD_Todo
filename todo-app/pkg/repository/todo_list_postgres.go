package repository

import (
	"context"
	"fmt"
	"github.com/zhashkevych/todo-app"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

type TodoListMongoDB struct {
	client *mongo.Client
	dbName string
}

func NewTodoListMongoDB(client *mongo.Client, dbName string) *TodoListMongoDB {
	return &TodoListMongoDB{client: client, dbName: dbName}
}

func (r *TodoListMongoDB) Create(userId int, list todo.TodoList) (int, error) {
	ctx := context.TODO()
	collection := r.client.Database(r.dbName).Collection(todoListsTable)
	counterCollection := r.client.Database(r.dbName).Collection("counters")

	// Генерация ID через коллекцию счетчиков
	counterFilter := bson.M{"_id": todoListsTable}
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
		return 0, fmt.Errorf("failed to generate list ID: %w", err)
	}

	// Создаем документ для MongoDB
	listDoc := bson.M{
		"id":          counter.SequenceValue,
		"title":       list.Title,
		"description": list.Description,
		"user_id":     userId,
	}

	// Вставка списка
	_, err = collection.InsertOne(ctx, listDoc)
	if err != nil {
		return 0, fmt.Errorf("failed to create todo list: %w", err)
	}

	return counter.SequenceValue, nil
}

func (r *TodoListMongoDB) GetAll(userId int) ([]todo.TodoList, error) {
	ctx := context.TODO()
	collection := r.client.Database(r.dbName).Collection(todoListsTable)

	// Фильтр по user_id
	filter := bson.M{"user_id": userId}

	// Выборка всех списков
	cursor, err := collection.Find(ctx, filter)
	if err != nil {
		return nil, fmt.Errorf("failed to get todo lists: %w", err)
	}
	defer cursor.Close(ctx)

	var lists []todo.TodoList
	for cursor.Next(ctx) {
		var result bson.M
		if err := cursor.Decode(&result); err != nil {
			return nil, fmt.Errorf("failed to decode todo list: %w", err)
		}

		// Преобразуем BSON-документ в структуру TodoList
		var list todo.TodoList
		if id, ok := result["id"].(int32); ok {
			list.Id = int(id)
		}
		if title, ok := result["title"].(string); ok {
			list.Title = title
		}
		if description, ok := result["description"].(string); ok {
			list.Description = description
		}

		lists = append(lists, list)
	}

	return lists, nil
}

func (r *TodoListMongoDB) GetById(userId, listId int) (todo.TodoList, error) {
	ctx := context.TODO()
	var list todo.TodoList
	collection := r.client.Database(r.dbName).Collection(todoListsTable)

	// Фильтр по user_id и id
	filter := bson.M{
		"id":      listId,
		"user_id": userId,
	}

	// Находим документ
	var result bson.M
	err := collection.FindOne(ctx, filter).Decode(&result)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			return list, fmt.Errorf("todo list not found: %w", err)
		}
		return list, fmt.Errorf("failed to get todo list: %w", err)
	}

	// Преобразуем BSON-документ в структуру TodoList
	if id, ok := result["id"].(int32); ok {
		list.Id = int(id)
	}
	if title, ok := result["title"].(string); ok {
		list.Title = title
	}
	if description, ok := result["description"].(string); ok {
		list.Description = description
	}

	return list, nil
}

func (r *TodoListMongoDB) Delete(userId, listId int) error {
	ctx := context.TODO()
	collection := r.client.Database(r.dbName).Collection(todoListsTable)

	// Фильтр по user_id и id
	filter := bson.M{
		"id":      listId,
		"user_id": userId,
	}

	// Удаление документа
	_, err := collection.DeleteOne(ctx, filter)
	if err != nil {
		return fmt.Errorf("failed to delete todo list: %w", err)
	}

	return nil
}

func (r *TodoListMongoDB) Update(userId, listId int, input todo.UpdateListInput) error {
	ctx := context.TODO()
	collection := r.client.Database(r.dbName).Collection(todoListsTable)

	// Фильтр по user_id и id
	filter := bson.M{
		"id":      listId,
		"user_id": userId,
	}

	// Подготовка обновления
	update := bson.M{}
	if input.Title != nil {
		update["title"] = *input.Title
	}
	if input.Description != nil {
		update["description"] = *input.Description
	}

	// Проверка, что есть что обновлять
	if len(update) == 0 {
		return fmt.Errorf("update structure has no values")
	}

	// Обновление документа
	_, err := collection.UpdateOne(ctx, filter, bson.M{"$set": update})
	if err != nil {
		return fmt.Errorf("failed to update todo list: %w", err)
	}

	return nil
}
