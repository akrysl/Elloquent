//
//  UseDatabase.swift
//  ELLAPP2017
//
//  Created by Christopher Peterson on 2/14/18.
//  Copyright © 2018 Ellokids. All rights reserved.
//

import Foundation
import Hydra
import Parse

class Database{
    
    // Gets the intermediate object associated with the query, if it exists
    func getIntermediate(intermediateQuery: PFQuery<PFObject>) -> Promise<PFObject> {
        return Promise<PFObject>(in: .background, { resolve, reject, _ in
            self.simpleQuery(query: intermediateQuery).then{ res in
                // If there isn't an intermediate, return an error
                if (res.count == 0){
                    let err = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Intermediate not found"])
                    reject(err)
                }
                
                resolve(res[0])
            }
        })
    }
    
    // Activates the intermediate associated with this query
    func activateIntermediate(intermediateQuery: PFQuery<PFObject>, newIntermediate: PFObject) -> Promise<Bool> {
        return Promise<Bool>(in: .background, { resolve, reject, _ in
            self.simpleQuery(query: intermediateQuery).then{ res in
                // If there isn't an intermediate, save the new one
                if (res.count == 0){
                    
                    newIntermediate["isActive"] = true
                    self.updateToDatabase(object: newIntermediate).then { result in
                        resolve(result)
                    }
                }
                
                // Otherwise, just activate the old one
                let intermediate = res[0]
                intermediate["isActive"] = true
                
                self.updateToDatabase(object: intermediate).then { result in
                    resolve(result)
                }
            }
        })
    }
    
    // Deactivates all items that match a query
    func deactivateQuery(query: PFQuery<PFObject>) -> Promise<Bool> {
        return Promise<Bool>(in: .background, { resolve, reject, _ in
            // Query and deactivate
            self.simpleQuery(query: query).then(self.deactivateMultiple).then{ res in
                resolve(res)
            }
        })
    }
    
    func deactivateMultiple(objects: [PFObject]) -> Promise<Bool> {
        return Promise<Bool>(in: .background, { resolve, reject, _ in
            var total = 0
            
            // If there isn't anything to fetch, return an empty array
            if objects.count == 0 {
                resolve(true)
            }
            
            // TODO this should use a semaphore
            for object in objects {
                self.deactivateObject(object: object).then { result in
                    total += 1
                    if total >= objects.count {
                        resolve(true)
                    }
                }
            }
        })
    }
    
    func deactivateObject(object: PFObject) -> Promise<Bool> {
        return Promise<Bool>(in: .background, { resolve, reject, _ in
            object["isActive"] = false
                
            self.updateToDatabase(object: object).then { result in
                resolve(result)
            }
        })
    }
    
    // Attempts to remove object from the database
    func removeFromDatabase(object: PFObject) -> Promise<Bool> {
        return Promise<Bool>(in: .background, { resolve, reject, _ in
            object.deleteInBackground(block: { (result: Bool, error: Error?) -> Void in
                // If the database call is successful, return the result
                if error == nil {
                    resolve(result)
                }
                // Otherwise return the error
                else {
                    reject(error!)
                }
            })
        })
    }
    
    // Attempts to update the database with object
    func updateToDatabase(object: PFObject) -> Promise<Bool> {
        return Promise<Bool>(in: .background, { resolve, reject, _ in
            object.saveInBackground(block: { (result: Bool, error: Error?) -> Void in
                // If the database call is successful, return the result
                if error == nil {
                    resolve(result)
                }
                // Otherwise return the error
                else {
                    reject(error!)
                }
            })
        })
    }
    
    // Calls a query on an intermediate in the database, and collects the resulting objects in an
    // array of PFObjects
    //
    // Query - The query object for the intermediates we want
    // Key - The key that corresponds to the field we want out of the intermediate
    func queryIntermediate(query: PFQuery<PFObject>, key: String) -> Promise<[PFObject]> {
        return Promise<[PFObject]>(in: .background, { resolve, reject, _ in
            query.findObjectsInBackground(block: { (queryResult: [PFObject]?, error: Error?) -> Void in
                // If the query is successful, get the data from the correct field and return it
                if let queryResult = queryResult {
                    var results = [PFObject]()
                    
                    for item in queryResult {
                        let object = item[key] as! PFObject
                        results.append(object)
                    }
                
                    resolve(results)
                }
                // Otherwise return the error
                else {
                    reject(error!)
                }
            })
        })
    }
    
    // Does a query on the database in promise format
    func simpleQuery(query: PFQuery<PFObject>) -> Promise<[PFObject]> {
        return Promise<[PFObject]>(in: .background, { resolve, reject, _ in
            query.findObjectsInBackground(block: { (queryResult: [PFObject]?, error: Error?) -> Void in
                // If the query is successful, return the result
                if let queryResult = queryResult {
                    resolve(queryResult)
                }
                // Otherwise return the error
                else {
                    reject(error!)
                }
            })
        })
    }
    
    // Fetches an arry of PFObjects from the database
    // Todo err and semaphores
    func fetchAll(objects: [PFObject]) -> Promise<[PFObject]> {
        return Promise<[PFObject]>(in: .background, { resolve, reject, _ in
            var results = [PFObject]()
            var total = 0
            
            // If there isn't anything to fetch, return an empty array
            if objects.count == 0 {
                resolve(results)
            }
            
            // TODO this should use a semaphore
            for object in objects {
                object.fetchInBackground(block: { (result: PFObject?, error: Error?) -> Void in
                    results.append(result!)
                    total += 1
                    if total >= objects.count {
                        resolve(results)
                    }
                })
            }
        })
    }
}
