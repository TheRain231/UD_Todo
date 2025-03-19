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
	counterCollection := r.client.Database(r.dbName).Collection("counters")

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

	itemDoc := bson.M{
		"id":          counter.SequenceValue,
		"list_id":     listId,
		"title":       item.Title,
		"description": item.Description,
		"done":        item.Done,
	}

	_, err = itemsCollection.InsertOne(ctx, itemDoc)
	if err != nil {
		return 0, fmt.Errorf("failed to create todo item: %w", err)
	}

	return counter.SequenceValue, nil
}

func (r *TodoItemMongoDB) GetAll(userId, listId int) ([]todo.TodoItem, error) {
	ctx := context.TODO()
	pipeline := []bson.M{
		{"$match": bson.M{"list_id": listId}},
		{"$lookup": bson.M{
			"from":         usersListsTable,
			"localField":   "list_id",
			"foreignField": "list_id",
			"as":           "user_list",
		}},
		{"$match": bson.M{"user_list.user_id": userId}},
	}

	cursor, err := r.client.Database(r.dbName).Collection(todoItemsTable).Aggregate(ctx, pipeline)
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
	var item todo.TodoItem
	err := r.client.Database(r.dbName).Collection(todoItemsTable).FindOne(
		ctx,
		bson.M{"id": itemId},
	).Decode(&item)
	if err != nil {
		return todo.TodoItem{}, fmt.Errorf("item not found: %w", err)
	}
	return item, nil
}

func (r *TodoItemMongoDB) Delete(userId, itemId int) error {
	ctx := context.TODO()
	var item todo.TodoItem
	err := r.client.Database(r.dbName).Collection(todoItemsTable).FindOne(
		ctx,
		bson.M{"id": itemId},
	).Decode(&item)
	if err != nil {
		return fmt.Errorf("item not found: %w", err)
	}

	_, err = r.client.Database(r.dbName).Collection(todoItemsTable).DeleteOne(ctx, bson.M{"id": itemId})
	if err != nil {
		return fmt.Errorf("failed to delete item: %w", err)
	}

	return nil
}

func (r *TodoItemMongoDB) Update(userId, itemId int, input todo.UpdateItemInput) error {
	ctx := context.TODO()

	var item todo.TodoItem
	err := r.client.Database(r.dbName).Collection(todoItemsTable).FindOne(
		ctx,
		bson.M{"id": itemId},
	).Decode(&item)
	if err != nil {
		return fmt.Errorf("item not found: %w", err)
	}

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

	if len(update) == 0 {
		return fmt.Errorf("no update fields provided")
	}

	_, err = r.client.Database(r.dbName).Collection(todoItemsTable).UpdateOne(
		ctx,
		bson.M{"id": itemId},
		bson.M{"$set": update},
	)

	return err
}