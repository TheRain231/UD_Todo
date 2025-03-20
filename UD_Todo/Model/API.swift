//
//  API.swift
//  UD_Todo
//
//  Created by Андрей Степанов on 19.03.2025.
//


import Foundation
import KeychainSwift

struct API {
    static let baseURL = "http://localhost:8000"
}

struct AuthResponse: Codable {
    let token: String
}

struct SignResponse: Codable {
    let id: Int
}

struct ListsResponse: Decodable {
    let data: [TodoListResponse]?
    let error: String?
}

class JSONNull: Decodable {
    required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected null"))
        }
    }
}

struct TodoListResponse: Codable {
    let id: Int?
    let title: String
    let description: String?
}

struct TodoListItemResponse: Codable {
    let id: Int?
    let title: String
    let description: String?
    let done: Bool
}

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isAuthenticated: Bool = false
    private var token: String
    private let keychain = KeychainSwift()
    
    init() {
        token = keychain.get("token") ?? ""
    }
    
    // MARK: - Fetch All Lists
    func getAllLists(completion: @escaping (Result<[TodoListResponse], Error>) -> Void) {
        let url = URL(string: "\(API.baseURL)/api/lists")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let sessionConfiguration = URLSessionConfiguration.default

        sessionConfiguration.httpAdditionalHeaders = [
            "Authorization": "Bearer \(token)"
        ]

        let session = URLSession(configuration: sessionConfiguration)

        session.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error!))
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                
                if let dict = json as? [String: Any] {
                    if let errorMessage = dict["error"] as? String {
                        completion(.failure(NSError(domain: "APIError", code: 400, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                        return
                    }
                    
                    if let listArray = dict["data"] as? [[String: Any]] {
                        let jsonData = try JSONSerialization.data(withJSONObject: listArray)
                        let lists = try JSONDecoder().decode([TodoListResponse].self, from: jsonData)
                        completion(.success(lists))
                        return
                    }
                    
                    if dict["data"] is NSNull {
                        completion(.success([]))
                        return
                    }
                    
                    if let message = dict["message"] as? String {
                        completion(.failure(NSError(domain: "APIError", code: 400, userInfo: [NSLocalizedDescriptionKey: message])))
                        return
                    }
                }
                
                completion(.failure(NSError(domain: "APIError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Unexpected response format"])))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: - Fetch List by ID
    func getListById(listId: Int, completion: @escaping (Result<TodoListResponse, Error>) -> Void) {
        let url = URL(string: "\(API.baseURL)/api/lists/\(listId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let sessionConfiguration = URLSessionConfiguration.default

        sessionConfiguration.httpAdditionalHeaders = [
            "Authorization": "Bearer \(token)"
        ]

        let session = URLSession(configuration: sessionConfiguration)

        session.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error!))
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                
                if let dict = json as? [String: Any] {
                    if let errorMessage = dict["error"] as? String {
                        completion(.failure(NSError(domain: "APIError", code: 400, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                        return
                    }
                    
                    if let message = dict["message"] as? String {
                        completion(.failure(NSError(domain: "APIError", code: 400, userInfo: [NSLocalizedDescriptionKey: message])))
                        return
                    }
                    
                    let list = try JSONDecoder().decode(TodoListResponse.self, from: data)
                    completion(.success(list))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: - Create List
    func createList(title: String, description: String?, completion: @escaping (Result<Int, Error>) -> Void) {
        let url = URL(string: "\(API.baseURL)/api/lists")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let newList = TodoListResponse(id: nil, title: title, description: description)
        request.httpBody = try? JSONEncoder().encode(newList)
        
        let sessionConfiguration = URLSessionConfiguration.default

        sessionConfiguration.httpAdditionalHeaders = [
            "Authorization": "Bearer \(token)"
        ]

        let session = URLSession(configuration: sessionConfiguration)

        session.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error!))
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])

                if let dict = json as? [String: Any] {
                    if let listID = dict["id"] as? Int {
                        completion(.success(listID))
                        return
                    }
                    
                    if let message = dict["message"] as? String {
                        completion(.failure(NSError(domain: "APIError", code: 400, userInfo: [NSLocalizedDescriptionKey: message])))
                        return
                    }
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: - Update List
    func updateList(listId: Int, title: String, description: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = URL(string: "\(API.baseURL)/api/lists/\(listId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let updatedList = TodoListResponse(id: listId, title: title, description: description)
        request.httpBody = try? JSONEncoder().encode(updatedList)
        
        let sessionConfiguration = URLSessionConfiguration.default

        sessionConfiguration.httpAdditionalHeaders = [
            "Authorization": "Bearer \(token)"
        ]

        let session = URLSession(configuration: sessionConfiguration)

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }.resume()
    }

    // MARK: - Delete List
    func deleteList(listId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = URL(string: "\(API.baseURL)/api/lists/\(listId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let sessionConfiguration = URLSessionConfiguration.default

        sessionConfiguration.httpAdditionalHeaders = [
            "Authorization": "Bearer \(token)"
        ]

        let session = URLSession(configuration: sessionConfiguration)

        session.dataTask(with: request) { _, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }.resume()
    }

    // MARK: - Add Item to List
    func addItemToList(listId: Int, itemTitle: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = URL(string: "\(API.baseURL)/api/lists/\(listId)/items")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let newItem = ["title": itemTitle]
        request.httpBody = try? JSONEncoder().encode(newItem)
        
        let sessionConfiguration = URLSessionConfiguration.default

        sessionConfiguration.httpAdditionalHeaders = [
            "Authorization": "Bearer \(token)"
        ]

        let session = URLSession(configuration: sessionConfiguration)

        session.dataTask(with: request) { _, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }.resume()
    }
    
    // MARK: - Get All Items for List
    func getItemsForList(listId: Int, completion: @escaping (Result<[TodoListItemResponse], Error>) -> Void) {
        let url = URL(string: "\(API.baseURL)/api/lists/\(listId)/items")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let sessionConfiguration = URLSessionConfiguration.default

        sessionConfiguration.httpAdditionalHeaders = [
            "Authorization": "Bearer \(token)"
        ]

        let session = URLSession(configuration: sessionConfiguration)

        session.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error!))
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])

                if let dict = json as? [String: Any] {
                    if let message = dict["message"] as? String {
                        completion(.failure(NSError(domain: "APIError", code: 400, userInfo: [NSLocalizedDescriptionKey: message])))
                        return
                    }
                }
                
                let items = try JSONDecoder().decode([TodoListItemResponse].self, from: data)
                completion(.success(items))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: - Get Item by ID (Check list_id)
    func getItemById(itemId: Int, completion: @escaping (Result<TodoListItemResponse, Error>) -> Void) {
        let url = URL(string: "\(API.baseURL)/api/items/\(itemId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let sessionConfiguration = URLSessionConfiguration.default

        sessionConfiguration.httpAdditionalHeaders = [
            "Authorization": "Bearer \(token)"
        ]

        let session = URLSession(configuration: sessionConfiguration)

        session.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error!))
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])

                if let dict = json as? [String: Any] {
                    if let message = dict["message"] as? String {
                        completion(.failure(NSError(domain: "APIError", code: 400, userInfo: [NSLocalizedDescriptionKey: message])))
                        return
                    }
                }
                
                let item = try JSONDecoder().decode(TodoListItemResponse.self, from: data)
                completion(.success(item))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: - Sign In
    func signIn(username: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: "\(API.baseURL)/auth/sign-in")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let credentials = ["username": username, "password": password]
        request.httpBody = try? JSONEncoder().encode(credentials)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error!))
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])

                if let dict = json as? [String: Any] {
                    if let message = dict["message"] as? String {
                        completion(.failure(NSError(domain: "APIError", code: 400, userInfo: [NSLocalizedDescriptionKey: message])))
                        return
                    }
                }
                
                let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                self.token = authResponse.token
                self.keychain.set(self.token, forKey: "token")
                print("Token - \(self.token)")
                
                DispatchQueue.main.async {
                    self.isAuthenticated = true
                    NotificationCenter.default.post(name: .login, object: nil)
                }
                
                completion(.success(authResponse.token))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }


    // MARK: - Sign Up
    func signUp(name: String, username: String, password: String, completion: @escaping (Result<Int, Error>) -> Void) {
        let url = URL(string: "\(API.baseURL)/auth/sign-up")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let credentials = ["name": name, "password": password, "username": username]
        request.httpBody = try? JSONEncoder().encode(credentials)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error!))
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])

                if let dict = json as? [String: Any] {
                    if let message = dict["message"] as? String {
                        completion(.failure(NSError(domain: "APIError", code: 400, userInfo: [NSLocalizedDescriptionKey: message])))
                        return
                    }
                }
                
                let signResponse = try JSONDecoder().decode(SignResponse.self, from: data)
                completion(.success(signResponse.id))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
