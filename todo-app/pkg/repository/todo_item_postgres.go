package repository

import (
	"context"
	"fmt"
	"github.com/zhashkevych/todo-app"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

type TodoItemMongoDB struct {
	client *mongo.Client
	dbName string
}

func NewTodoItemMongoDB(client *mongo.Client, dbName string) *TodoItemMongoDB {
	return &TodoItemMongoDB{client: client, dbName: dbName}
}

func (r *TodoItemMongoDB) Create(listId int, item todo.TodoItem) (int, error) {
	ctx := context.TODO()
	itemsCollection := r.client.Database(r.dbName).Collection(todoItemsTable)
	listItemsCollection := r.client.Database(r.dbName).Collection(listsItemsTable)
	counterCollection := r.client.Database(r.dbName).Collection("counters")

	// Генерация ID через коллекцию счетчиков
	counterFilter := bson.M{"_id": todoItemsTable}
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
		return 0, fmt.Errorf("failed to generate item ID: %w", err)
	}

	// Создаем документ для MongoDB
	itemDoc := bson.M{
		"id":          counter.SequenceValue,
		"title":       item.Title,
		"description": item.Description,
		"done":        item.Done,
	}

	// Вставка элемента
	_, err = itemsCollection.InsertOne(ctx, itemDoc)
	if err != nil {
		return 0, fmt.Errorf("failed to create todo item: %w", err)
	}

	// Создаем связь между списком и элементом
	listItemDoc := bson.M{
		"list_id": listId,
		"item_id": counter.SequenceValue,
	}
	_, err = listItemsCollection.InsertOne(ctx, listItemDoc)
	if err != nil {
		return 0, fmt.Errorf("failed to create list-item relation: %w", err)
	}

	return counter.SequenceValue, nil
}

func (r *TodoItemMongoDB) GetAll(userId, listId int) ([]todo.TodoItem, error) {
	ctx := context.TODO()
	pipeline := []bson.M{
		{
			"$match": bson.M{
				"list_id": listId,
			},
		},
		{
			"$lookup": bson.M{
				"from":         usersListsTable,
				"localField":   "list_id",
				"foreignField": "list_id",
				"as":           "user_list",
			},
		},
		{
			"$match": bson.M{
				"user_list.user_id": userId,
			},
		},
		{
			"$lookup": bson.M{
				"from":         todoItemsTable,
				"localField":   "item_id",
				"foreignField": "id",
				"as":           "item",
			},
		},
		{
			"$unwind": "$item",
		},
		{
			"$replaceRoot": bson.M{
				"newRoot": "$item",
			},
		},
	}

	cursor, err := r.client.Database(r.dbName).Collection(listsItemsTable).Aggregate(ctx, pipeline)
	if err != nil {
		return nil, fmt.Errorf("aggregation failed: %w", err)
	}

	var items []todo.TodoItem
	if err = cursor.All(ctx, &items); err != nil {
		return nil, fmt.Errorf("failed to decode items: %w", err)
	}

	return items, nil
}

func (r *TodoItemMongoDB) GetById(userId, itemId int) (todo.TodoItem, error) {
	ctx := context.TODO()
	pipeline := []bson.M{
		{
			"$match": bson.M{
				"item_id": itemId,
			},
		},
		{
			"$lookup": bson.M{
				"from":         usersListsTable,
				"localField":   "list_id",
				"foreignField": "list_id",
				"as":           "user_list",
			},
		},
		{
			"$match": bson.M{
				"user_list.user_id": userId,
			},
		},
		{
			"$lookup": bson.M{
				"from":         todoItemsTable,
				"localField":   "item_id",
				"foreignField": "id",
				"as":           "item",
			},
		},
		{
			"$unwind": "$item",
		},
		{
			"$replaceRoot": bson.M{
				"newRoot": "$item",
			},
		},
	}

	cursor, err := r.client.Database(r.dbName).Collection(listsItemsTable).Aggregate(ctx, pipeline)
	if err != nil {
		return todo.TodoItem{}, fmt.Errorf("aggregation failed: %w", err)
	}

	if !cursor.Next(ctx) {
		return todo.TodoItem{}, fmt.Errorf("item not found")
	}

	var item todo.TodoItem
	if err := cursor.Decode(&item); err != nil {
		return todo.TodoItem{}, fmt.Errorf("failed to decode item: %w", err)
	}

	return item, nil
}

func (r *TodoItemMongoDB) Delete(userId, itemId int) error {
	ctx := context.TODO()

	// Находим список, к которому принадлежит элемент
	var listItem struct {
		ListID int `bson:"list_id"`
	}
	err := r.client.Database(r.dbName).Collection(listsItemsTable).FindOne(
		ctx,
		bson.M{"item_id": itemId},
	).Decode(&listItem)
	if err != nil {
		return fmt.Errorf("failed to find list for item: %w", err)
	}

	// Проверяем права пользователя на список
	count, _ := r.client.Database(r.dbName).Collection(usersListsTable).CountDocuments(
		ctx,
		bson.M{
			"list_id": listItem.ListID,
			"user_id": userId,
		},
	)
	if count == 0 {
		return fmt.Errorf("access denied")
	}

	// Удаляем элемент и связь
	_, err = r.client.Database(r.dbName).Collection(todoItemsTable).DeleteOne(ctx, bson.M{"id": itemId})
	if err != nil {
		return fmt.Errorf("failed to delete item: %w", err)
	}

	_, err = r.client.Database(r.dbName).Collection(listsItemsTable).DeleteMany(ctx, bson.M{"item_id": itemId})
	return err
}

func (r *TodoItemMongoDB) Update(userId, itemId int, input todo.UpdateItemInput) error {
	ctx := context.TODO()

	// Находим список, к которому принадлежит элемент
	var listItem struct {
		ListID int `bson:"list_id"`
	}
	err := r.client.Database(r.dbName).Collection(listsItemsTable).FindOne(
		ctx,
		bson.M{"item_id": itemId},
	).Decode(&listItem)
	if err != nil {
		return fmt.Errorf("failed to find list for item: %w", err)
	}

	// Проверяем права пользователя на список
	count, _ := r.client.Database(r.dbName).Collection(usersListsTable).CountDocuments(
		ctx,
		bson.M{
			"list_id": listItem.ListID,
			"user_id": userId,
		},
	)
	if count == 0 {
		return fmt.Errorf("access denied")
	}

	// Формируем обновление
	update := bson.M{}
	if input.Title != nil {
		update["title"] = *input.Title
	}
	if input.Description != nil {
		update["description"] = *input.Description
	}
	if input.Done != nil {
		update["done"] = *input.Done
	}

	// Проверка, что есть что обновлять
	if len(update) == 0 {
		return fmt.Errorf("update structure has no values")
	}

	// Обновление документа
	_, err = r.client.Database(r.dbName).Collection(todoItemsTable).UpdateOne(
		ctx,
		bson.M{"id": itemId},
		bson.M{"$set": update},
	)
	return err
}
