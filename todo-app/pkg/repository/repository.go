package repository

import (
	"github.com/zhashkevych/todo-app"
	"go.mongodb.org/mongo-driver/mongo"
)

type Authorization interface {
	CreateUser(user todo.User) (int, error)
	GetUser(username, password string) (todo.User, error)
}

type TodoList interface {
	Create(userId int, list todo.TodoList) (int, error)
	GetAll(userId int) ([]todo.TodoList, error)
	GetById(userId, listId int) (todo.TodoList, error)
	Delete(userId, listId int) error
	Update(userId, listId int, input todo.UpdateListInput) error
}

type TodoItem interface {
	Create(listId int, item todo.TodoItem) (int, error)
	GetAll(userId, listId int) ([]todo.TodoItem, error)
	GetById(userId, itemId int) (todo.TodoItem, error)
	Delete(userId, itemId int) error
	Update(userId, itemId int, input todo.UpdateItemInput) error
}

type Repository struct {
	Authorization
	TodoList
	TodoItem
}

func NewRepository(client *mongo.Client, dbName string) *Repository {
	return &Repository{
		Authorization: NewAuthMongoDB(client, dbName),
		TodoList:      NewTodoListMongoDB(client, dbName),
		TodoItem:      NewTodoItemMongoDB(client, dbName),
	}
}
