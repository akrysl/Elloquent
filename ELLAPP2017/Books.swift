//
//  Books.swift
//  ELLAPP2017
//
//  Created by Christopher Peterson on 3/13/18.
//  Copyright © 2018 Ellokids. All rights reserved.
//

import Foundation
import Hydra
import Parse

class Books{
    
    // Creates a book with no vocab words
    func createBook(coverPicture: PFFile, author: String, name: String, gradeLevel: String, isGlobal: Bool, owner: PFUser, difficulty: String, subject: String) -> Promise<PFObject> {
        return Promise<PFObject>(in: .background, { resolve, reject, _ in
            let newBook = PFObject(className: "Book")
            newBook["coverPicture"] = coverPicture
            newBook["author"] = author
            newBook["name"] = name
            newBook["gradeLevel"] = gradeLevel
            newBook["isPublic"] = isGlobal
            newBook["owner"] = owner
            newBook["difficulty"] = difficulty
            newBook["subject"] = subject
            newBook["isActive"] = true
            
            // Add to the database
            Database().updateToDatabase(object: newBook).then{ result in
                resolve(newBook)
            }
        })
    }
    
    // 1. Mark the book as inactive
    // 2. Mark the BookVocabIntermediates as inactive
    // 3. Mark the ClassroomBookIntermediates as inactive
    func deleteBook(book: PFObject) -> Promise<Bool> {
        return Promise<Bool>(in: .background, { resolve, reject, _ in
            // Deactivate the book
            Database().deactivateObject(object: book).then { res in
                // Query all of the classroomBookIntermediates this user is a part of, and deactivate those
                let intermediateQuery = PFQuery(className: "ClassroomBookIntermediate")
                intermediateQuery.whereKey("Book", equalTo: book)
                
                // Deactivate all of the intermediates
                Database().deactivateQuery(query: intermediateQuery).then{ result in
                }
                
                // Query all of the bookVocabIntermediates this user is a part of, and deactivate those
                let intermediateQuery2 = PFQuery(className: "BookVocabIntermediate")
                intermediateQuery2.whereKey("Book", equalTo: book)
                
                // Deactivate all of the intermediates
                Database().deactivateQuery(query: intermediateQuery2).then{ result in
                    resolve(result)
                }
            }
        })
    }
    
    // Creates a new vocab object and returns it
    func createVocab(name: String, definition: String, image: PFFile) -> Promise<PFObject> {
        return Promise<PFObject>(in: .background, { resolve, reject, _ in
            // Create the new vocab word
            let newVocab = PFObject(className: "Vocab")
            newVocab["name"] = name
            newVocab["definition"] = definition
            newVocab["image"] = image
            newVocab["isActive"] = true
            
            // Add it to the database
            Database().updateToDatabase(object: newVocab).then { result in
                resolve(newVocab)
            }
        })
    }
    
    // 1. Mark the vocab as inactive
    // 2. Mark the bookVocabIntermediates as inactive
    func deleteVocab(vocab: PFObject) -> Promise<Bool> {
        return Promise<Bool>(in: .background, { resolve, reject, _ in
            // Deactivate the vocab
            Database().deactivateObject(object: vocab).then { res in
                // Query all of the bookVocabIntermediates this user is a part of, and deactivate those
                let intermediateQuery = PFQuery(className: "BookVocabIntermediate")
                intermediateQuery.whereKey("Vocab", equalTo: vocab)
                
                // Deactivate all of the intermediates
                Database().deactivateQuery(query: intermediateQuery).then{ result in
                    resolve(result)
                }
            }
        })
    }
    
    // Adds a vocab to a book
    func addVocabToBook(vocab: PFObject, book: PFObject) -> Promise<Bool> {
        return Promise<Bool>(in: .background, { resolve, reject, _ in
            let intermediateQuery = PFQuery(className: "BookVocabIntermediate")
            intermediateQuery.whereKey("Vocab", equalTo: vocab)
            intermediateQuery.whereKey("Book", equalTo: book)
            
            let newIntermediate = PFObject(className: "BookVocabIntermediate")
            newIntermediate["Book"] = book
            newIntermediate["Vocab"] = vocab
            
            Database().activateIntermediate(intermediateQuery: intermediateQuery, newIntermediate: newIntermediate).then { result in
                resolve(result)
            }
        })
    }
    
    // Removes a vocab from a book
    func removeVocabFromBook(vocab: PFObject, book: PFObject) -> Promise<Bool> {
        return Promise<Bool>(in: .background, { resolve, reject, _ in
            let intermediateQuery = PFQuery(className: "BookVocabIntermediate")
            intermediateQuery.whereKey("Vocab", equalTo: vocab)
            intermediateQuery.whereKey("Book", equalTo: book)
            
            Database().deactivateQuery(query: intermediateQuery).then { result in
                resolve(result)
            }
        })
    }
    
    // Returns the books in the global library, isPublic = true
    func getGlobalBooks() -> Promise<[PFObject]> {
        return Promise<[PFObject]>(in: .background, { resolve, reject, _ in
            // Create the query
            let globalBookQuery = PFQuery(className: "Book")
            globalBookQuery.whereKey("isPublic", equalTo: true)
            globalBookQuery.whereKey("isActive", equalTo: true)
            
            // Query it
            Database().simpleQuery(query: globalBookQuery).then{ res in
                resolve(res)
            }
        })
    }
    
    // Returns the books in a teacher's personal library:
    // isPublic = false, owner = this teacher
    func getLocalBooks(teacher: PFUser) -> Promise<[PFObject]> {
        return Promise<[PFObject]>(in: .background, { resolve, reject, _ in
            // Create the query
            let teacherBookQuery = PFQuery(className: "Book")
            teacherBookQuery.whereKey("isPublic", equalTo: false)
            teacherBookQuery.whereKey("owner", equalTo: teacher)
            teacherBookQuery.whereKey("isActive", equalTo: true)
            
            // Query it
            Database().simpleQuery(query: teacherBookQuery).then{ res in
                resolve(res)
            }
        })
    }
    
    // Returns the vocab words associated with a book
    func getVocabWords(book: PFObject) -> Promise<[PFObject]> {
        return Promise<[PFObject]>(in: .background, { resolve, reject, _ in
            // Create the query
            let vocabQuery = PFQuery(className: "BookVocabIntermediate")
            vocabQuery.whereKey("Book", equalTo: book)
            vocabQuery.whereKey("isActive", equalTo: true)
            
            // Query it and fetch the results
            Database().queryIntermediate(query: vocabQuery, key: "Vocab").then(Database().fetchAll).then{ res in
                resolve(res)
            }
        })
    }
    
    func downloadBookFromGlobal(book: PFObject, newOwner: PFUser) -> Promise<PFObject> {
        return Promise<PFObject>(in: .background, { resolve, reject, _ in
            // Copy the book and change the owner and set it to private
            self.deepCopyBook(oldBook: book).then{ newBook in
                newBook["isPublic"] = false
                newBook["owner"] = newOwner
                
                // Upload the new book
                Database().updateToDatabase(object: newBook).then{ result in
                    resolve(newBook)
                }
            }
        })
    }
    
    // Uploads a book to the global library
    //
    // Creates a copy of the book and changes isPublic to true
    //
    // Return Value: The new book object
    func uploadBookToGlobal(book: PFObject) -> Promise<PFObject> {
        return Promise<PFObject>(in: .background, { resolve, reject, _ in
            // Copy the book and make it public
            self.deepCopyBook(oldBook: book).then{ newBook in
                newBook["isPublic"] = true
                
                // Upload the new book
                Database().updateToDatabase(object: newBook).then{ result in
                    resolve(newBook)
                }
            }
        })
    }
    
    // Copies a book and its vocab words in the database
    func deepCopyBook(oldBook: PFObject) -> Promise<PFObject> {
        return Promise<PFObject>(in: .background, { resolve, reject, _ in
            // Copy the book object
            let newBook = PFObject(className: "Book", dictionary: oldBook.dictionaryWithValues(forKeys: oldBook.allKeys))
            
            // Also need copy vocab, query and copy
            self.getVocabWords(book: oldBook).then{ result in
                for vocab in result {
                    // Copy the vocab word
                    let newVocab = PFObject(className: "Vocab", dictionary: vocab.dictionaryWithValues(forKeys: oldBook.allKeys))
                    
                    // It's the same except pointing to a different book
                    self.addVocabToBook(vocab: newVocab, book: newBook).then{ result in
                    }
                    
                    // Save the new vocab word
                    Database().updateToDatabase(object: newVocab).then{ result in
                        
                    }
                }
            }
            
            // Upload the new book
            Database().updateToDatabase(object: newBook).then{ result in
                resolve(newBook)
            }
        })
    }
}
