// Создаем базу данных
db = db.getSiblingDB('todo_db');

// Создаем нового пользователя
db.createUser({
    user: "admin",
    pwd: "qwerty",
    roles: [
        { role: "readWrite", db: "todo_db" },
        { role: "userAdminAnyDatabase", db: "admin" }
    ]
});

print("User 'admin' created with readWrite access to 'todo_db'");