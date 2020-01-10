//
//  Classrooms.swift
//  ELLAPP2017
//
//  Created by Christopher Peterson on 3/13/18.
//  Copyright © 2018 Ellokids. All rights reserved.
//

import Foundation
import Hydra
import Parse

class Classrooms{
    // Creates a new classroom with the given parameters and returns it
    // Use addUser and addBook to populate it
    func createClassroom(name: String, gradeLevel: String) -> Promise<PFObject> {
        return Promise<PFObject>(in: .background, { resolve, reject, _ in
            let newClassroom = PFUser(className: "Classroom")
            newClassroom["name"] = name
            newClassroom["gradeLevel"] = gradeLevel
            newClassroom["isActive"] = true
            
            // Add to the database
            Database().updateToDatabase(object: newClassroom).then{ result in
                resolve(newClassroom)
            }
        })
    }
    
    // 1. Deletes the classroom object
    // 2. Deletes all ClassroomBookIntermediates that were associated with this classroom
    // 3. Deletes all ClassroomUserIntermediates that were associated with this classroom
    // 4. Deletes all ClassroomBookGameIntermediates that were associated with this classroom
    func deleteClassroom(classroom: PFObject) -> Promise<Bool> {
        return Promise<Bool>(in: .background, { resolve, reject, _ in
            // Deactivate the classroom
            Database().deactivateObject(object: classroom).then { res in
                // Query all of the classroomBookIntermediates this user is a part of, and deactivate those
                let intermediateQuery = PFQuery(className: "ClassroomBookIntermediate")
                intermediateQuery.whereKey("Classroom", equalTo: classroom)
                
                Database().simpleQuery(query: intermediateQuery).then { intermediates in
                    for intermediate in intermediates {
                        let intermediateQuery3 = PFQuery(className: "ClassroomBookGameIntermediate")
                        intermediateQuery3.whereKey("ClassroomBookIntermediate", equalTo: intermediate)
                        
                        // Deactivate all of the intermediates
                        Database().deactivateQuery(query: intermediateQuery3).then{ result in
                        }
                    }
                }
                
                // Deactivate all of the intermediates
                Database().deactivateQuery(query: intermediateQuery).then{ result in
                }
                
                // Query all of the classroomUserIntermediates this user is a part of, and deactivate those
                let intermediateQuery2 = PFQuery(className: "ClasroomUserIntermediate")
                intermediateQuery2.whereKey("Classroom", equalTo: classroom)
                // Deactivate all of the intermediates
                Database().deactivateQuery(query: intermediateQuery2).then{ result in
                }
            }
        })
    }
    
    // Returns the books associated with a classroom
    func getBooksInClassroom(classroom: PFObject) -> Promise<[PFObject]> {
        return Promise<[PFObject]>(in: .background, { resolve, reject, _ in
            // Create the query
            let bookQuery = PFQuery(className: "ClassroomBookIntermediate")
            bookQuery.whereKey("Classroom", equalTo: classroom)
            bookQuery.whereKey("isActive", equalTo: true)
            
            // Query it and fetch the results
            Database().queryIntermediate(query: bookQuery, key: "Book").then(Database().fetchAll).then{ res in
                resolve(res)
            }
        })
    }
    
    // Returns the games associated with a book & classroom
    func getGamesInClassroom(classroom: PFObject, book: PFObject) -> Promise<[PFObject]> {
        return Promise<[PFObject]>(in: .background, { resolve, reject, _ in
            // Create the intermediate query
            let intermediateQuery = PFQuery(className: "ClassroomBookIntermediate")
            intermediateQuery.whereKey("Classroom", equalTo: classroom)
            intermediateQuery.whereKey("Book", equalTo: book)
            intermediateQuery.whereKey("isActive", equalTo: true)
            
            // Get the intermediate
            Database().getIntermediate(intermediateQuery: intermediateQuery).then{ intermediate in
                
                // Create the second query
                let gameQuery = PFQuery(className: "ClassroomBookGameIntermediate")
                gameQuery.whereKey("ClassroomBookIntermediate", equalTo: intermediate)
                gameQuery.whereKey("isActive", equalTo: true)
                
                // Query it and fetch the results
                Database().queryIntermediate(query: gameQuery, key: "Game").then(Database().fetchAll).then{ res in
                    resolve(res)
                }
            }
        })
    }
    
    // Creates a link between this book/classroom combo and a game
    func addGameToClassroom(book: PFObject, classroom: PFObject, game: PFObject) -> Promise<Bool> {
        return Promise<Bool>(in: .background, { resolve, reject, _ in
            // Create the intermediate query
            let intermediateQuery = PFQuery(className: "ClassroomBookIntermediate")
            intermediateQuery.whereKey("Classroom", equalTo: classroom)
            intermediateQuery.whereKey("Book", equalTo: book)
            
            // Get the intermediate
            Database().getIntermediate(intermediateQuery: intermediateQuery).then{ intermediate in
                let gameQuery = PFQuery(className: "ClassroomBookGameIntermediate")
                gameQuery.whereKey("ClassroomBookIntermediate", equalTo: intermediate)
                gameQuery.whereKey("Game", equalTo: game)
                
                let newIntermediate = PFObject(className: "ClassroomBookGameIntermediate")
                newIntermediate["ClassroomBookIntermediate"] = intermediate
                newIntermediate["Game"] = game
                
                Database().activateIntermediate(intermediateQuery: gameQuery, newIntermediate: newIntermediate).then { result in
                    resolve(result)
                }
            }
        })
    }
    
    // Removes a link between this book/classroom combo and a game
    func removeGameFromClassroom(book: PFObject, classroom: PFObject, game: PFObject) -> Promise<Bool> {
        return Promise<Bool>(in: .background, { resolve, reject, _ in
            // Create the intermediate query
            let intermediateQuery = PFQuery(className: "ClassroomBookIntermediate")
            intermediateQuery.whereKey("Classroom", equalTo: classroom)
            intermediateQuery.whereKey("Book", equalTo: book)
            
            // Get the intermediate
            Database().getIntermediate(intermediateQuery: intermediateQuery).then{ intermediate in
                let gameQuery = PFQuery(className: "ClassroomBookGameIntermediate")
                gameQuery.whereKey("ClassroomBookIntermediate", equalTo: intermediate)
                gameQuery.whereKey("Game", equalTo: game)
                
                Database().deactivateQuery(query: gameQuery).then { result in
                    resolve(result)
                }
            }
        })
    }
    
    // Adds a user to a classroom
    func addUserToClassroom(user: PFUser, classroom: PFObject) -> Promise<Bool> {
        return Promise<Bool>(in: .background, { resolve, reject, _ in
            let intermediateQuery = PFQuery(className: "ClassroomUserIntermediate")
            intermediateQuery.whereKey("classroom", equalTo: classroom)
            intermediateQuery.whereKey("user", equalTo: user)
            
            let newIntermediate = PFObject(className: "ClassroomUserIntermediate")
            newIntermediate["classroom"] = classroom
            newIntermediate["user"] = user
            
            Database().activateIntermediate(intermediateQuery: intermediateQuery, newIntermediate: newIntermediate).then { result in
                resolve(result)
            }
        })
    }
    
    // Removes a user from a classroom
    func removeUserFromClassroom(user: PFUser, classroom: PFObject) -> Promise<Bool> {
        return Promise<Bool>(in: .background, { resolve, reject, _ in
            let intermediateQuery = PFQuery(className: "ClassroomUserIntermediate")
            intermediateQuery.whereKey("user", equalTo: user)
            intermediateQuery.whereKey("classroom", equalTo: classroom)
            
            Database().deactivateQuery(query: intermediateQuery).then { result in
                resolve(result)
            }
        })
    }
    
    // Adds a book to a classroom
    func addBookToClassroom(book: PFObject, classroom: PFObject) -> Promise<Bool> {
        return Promise<Bool>(in: .background, { resolve, reject, _ in
            let intermediateQuery = PFQuery(className: "ClassroomBookIntermediate")
            intermediateQuery.whereKey("Classroom", equalTo: classroom)
            intermediateQuery.whereKey("Book", equalTo: book)
            
            let newIntermediate = PFObject(className: "ClassroomBookIntermediate")
            newIntermediate["Classroom"] = classroom
            newIntermediate["Book"] = book
            
            Database().activateIntermediate(intermediateQuery: intermediateQuery, newIntermediate: newIntermediate).then { result in
                resolve(result)
            }
        })
    }
    
    // Removes a book from a classroom
    func removeBookFromClassroom(book: PFObject, classroom: PFObject) -> Promise<Bool> {
        return Promise<Bool>(in: .background, { resolve, reject, _ in
            let intermediateQuery = PFQuery(className: "ClassroomBookIntermediate")
            intermediateQuery.whereKey("Book", equalTo: book)
            intermediateQuery.whereKey("Classroom", equalTo: classroom)
            
            Database().deactivateQuery(query: intermediateQuery).then { result in
                resolve(result)
            }
        })
    }
    
    // Returns the classrooms associated with a user
    func getClassrooms(user: PFUser) -> Promise<[PFObject]> {
        return Promise<[PFObject]>(in: .background, { resolve, reject, _ in
            // Create the query
            let classroomQuery = PFQuery(className: "ClassroomUserIntermediate")
            classroomQuery.whereKey("user", equalTo: user)
            classroomQuery.whereKey("isActive", equalTo: true)
            
            // Query it and fetch the results
            Database().queryIntermediate(query: classroomQuery, key: "classroom").then(Database().fetchAll).then{ res in
                resolve(res)
            }
        })
    }
    
    // Returns the student users associated with a classroom
    func getStudentsInClassroom(classroom: PFObject) -> Promise<[PFObject]> {
        return Promise<[PFObject]>(in: .background, { resolve, reject, _ in
            // Create the query
            let studentQuery = PFQuery(className: "ClassroomUserIntermediate")
            studentQuery.whereKey("classroom", equalTo: classroom)
            studentQuery.whereKey("isActive", equalTo: true)
            
            // Query it and fetch the results
            Database().queryIntermediate(query: studentQuery, key: "user").then(Database().fetchAll).then{ res in
                var results = [PFObject]()
                var rolesChecked = 0
                
                for user in res {
                    let user = user as! PFUser
                    Users().getRoleFromName(role: "student").then { role in
                        Users().doesUserBelongToRole(user: user, role: role).then { belongs in
                            if belongs {
                                results.append(user)
                            }
                            
                            // If this is the last user to check, send back the result
                            // TODO: It's likely this might need/want semaphores
                            rolesChecked += 1
                            if rolesChecked >= res.count {
                                resolve(results)
                            }
                        }
                    }
                }
            }
        })
    }
    
    // Returns the teacher users associated with a classroom
    func getTeachersInClassroom(classroom: PFObject) -> Promise<[PFObject]> {
        return Promise<[PFObject]>(in: .background, { resolve, reject, _ in
            // Create the query
            let teacherQuery = PFQuery(className: "ClassroomUserIntermediate")
            teacherQuery.whereKey("classroom", equalTo: classroom)
            teacherQuery.whereKey("isActive", equalTo: true)
            
            // Query it and fetch the results
            Database().queryIntermediate(query: teacherQuery, key: "user").then(Database().fetchAll).then{ res in
                var results = [PFObject]()
                var rolesChecked = 0
                
                for user in res {
                    let user = user as! PFUser
                    Users().getRoleFromName(role: "teacher").then { role in
                        Users().doesUserBelongToRole(user: user, role: role).then { belongs in
                            if belongs {
                                results.append(user)
                            }
                            
                            // If this is the last user to check, send back the result
                            // TODO: It's likely this might need/want semaphores
                            rolesChecked += 1
                            if rolesChecked >= res.count {
                                resolve(results)
                            }
                        }
                    }
                }
            }
        })
    }
}
