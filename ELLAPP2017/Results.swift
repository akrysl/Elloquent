//
//  Results.swift
//  ELLAPP2017
//
//  Created by Christopher Peterson on 3/13/18.
//  Copyright © 2018 Ellokids. All rights reserved.
//

import Foundation
import Hydra
import Parse

class Results{
    // Currently no method by which results are deleted
    // Currently no method by which games are added or deleted
    
    // Creates a new result with the given parameters and returns it
    func createResult(data: PFFile, givenGrade: String, book: PFObject, game: PFObject, user: PFUser, classroom: PFObject, vocab: [PFObject]) -> Promise<PFObject> {
        return Promise<PFObject>(in: .background, { resolve, reject, _ in
            let newResult = PFUser(className: "Result")
            newResult["data"] = data
            newResult["givenGrade"] = givenGrade
            newResult["book"] = book
            newResult["game"] = game
            newResult["user"] = user
            newResult["classroom"] = classroom
            
            // Link the vocab to this result
            for vocabWord in vocab {
                self.addVocabToResult(vocab: vocabWord, result: newResult).then { result in
                }
            }
            
            // Add to the database
            Database().updateToDatabase(object: newResult).then{ result in
                resolve(newResult)
            }
        })
    }
    
    // Returns the results associated with a book & classroom & student. These values are optional, and this function will only query on things provided. For examle, to get all of a student's results for ALL books, just leave the book optional as nil
    func getResults(classroom: PFObject?, book: PFObject?, student: PFUser?) -> Promise<[PFObject]> {
        return Promise<[PFObject]>(in: .background, { resolve, reject, _ in
            let resultQuery = PFQuery(className: "Result")
            
            if book != nil {
                resultQuery.whereKey("book", equalTo: book!)
            }
            if student != nil {
                resultQuery.whereKey("user", equalTo: student!)
            }
            if classroom != nil {
                resultQuery.whereKey("classroom", equalTo: classroom!)
            }
            
            // Query it and fetch the results
            Database().simpleQuery(query: resultQuery).then { res in
                resolve(res)
            }
        })
    }
    
    func addVocabToResult(vocab: PFObject, result: PFObject) -> Promise<Bool> {
        return Promise<Bool>(in: .background, { resolve, reject, _ in
            let intermediateQuery = PFQuery(className: "VocabResultIntermediate")
            intermediateQuery.whereKey("vocab", equalTo: vocab)
            intermediateQuery.whereKey("result", equalTo: result)
            
            let newIntermediate = PFObject(className: "VocabResultIntermediate")
            newIntermediate["vocab"] = vocab
            newIntermediate["result"] = result
            
            Database().activateIntermediate(intermediateQuery: intermediateQuery, newIntermediate: newIntermediate).then { result in
                resolve(result)
            }
        })
    }
}
