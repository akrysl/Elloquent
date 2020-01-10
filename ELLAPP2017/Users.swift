//
//  Users.swift
//  ELLAPP2017
//
//  Created by Christopher Peterson on 3/13/18.
//  Copyright © 2018 Ellokids. All rights reserved.
//

import Foundation
import Hydra
import Parse

class Users{
    

    // Creates a new user, with a role given by a string
    // NOTE THAT THIS FUNCTION WILL SIGN IN TO THE USER WE JUST CREATED
    // DO NOT CALL THIS WHILE SOMEONE ELSE IS LOGGED IN OR WEIRD STUFF WILL HAPPEN WITH SESSIONS
    func createUserWithRole(username: String, password: String, role: String) -> Promise<PFUser> {
        return Promise<PFUser>(in: .background, { resolve, reject, _ in
            self.createUser(username: username, password: password).then { newUser in
                
                // Now get the requested role and add it
                self.getRoleFromName(role: role).then { roleObject in
                    self.addRole(user: newUser, role: roleObject).then { res in
                        resolve(newUser)
                    }
                }
            }
        })
    }
    
    // Creates a new user with no roles
    // NOTE THAT THIS FUNCTION WILL SIGN IN TO THE USER WE JUST CREATED
    // DO NOT CALL THIS WHILE SOMEONE ELSE IS LOGGED IN OR WEIRD STUFF WILL HAPPEN WITH SESSIONS
    func createUser(username: String, password: String) -> Promise<PFUser> {
        return Promise<PFUser>(in: .background, { resolve, reject, _ in
            let newUser = PFUser(className: "_User")
            newUser["username"] = username
            newUser["password"] = password
            newUser["isActive"] = true
            
            // New users should have public read/write permissions
            let acl = PFACL()
            acl.getPublicReadAccess = true
            acl.getPublicWriteAccess = true
            newUser.acl = acl
            
            // Add to the database
            self.signupUser(user: newUser).then { result in
                Database().updateToDatabase(object: newUser).then{ res in
                    resolve(newUser)
                }
            }
        })
    }
    
    // 1. Mark as not active
    // 2. Mark all ClassroomUserIntermediates as inactive
    func deleteUser(user: PFUser) -> Promise<Bool> {
        return Promise<Bool>(in: .background, { resolve, reject, _ in
            // Deactivate the user
            Database().deactivateObject(object: user).then { res in
                // Query all of the classroomUserIntermediates this user is a part of, and deactivate those
                let intermediateQuery = PFQuery(className: "ClassroomUserIntermediate")
                intermediateQuery.whereKey("user", equalTo: user)
                
                // Deactivate all of the intermediates
                Database().deactivateQuery(query: intermediateQuery).then{ result in
                    resolve(result)
                }
            }
        })
    }
    
    // Signs up a user, which is needed to add them to the database
    func signupUser(user: PFUser) -> Promise<Bool> {
        return Promise<Bool>(in: .background, { resolve, reject, _ in
            user.signUpInBackground(block: { (success: Bool?, error: Error?) -> Void in
                // If the query is successful, return the result
                if let success = success {
                    resolve(success)
                }
                    // Otherwise return the error
                else {
                    reject(error!)
                }
            })
        })
    }
    
    // Removes a role from a user
    func removeRole(user: PFUser, role: PFRole) -> Promise<Bool> {
        return Promise<Bool>(in: .background, { resolve, reject, _ in
            // Remove user from role
            role.users.remove(user)
            
            // Update it in the database
            Database().updateToDatabase(object: role).then { res in
                resolve(res)
            }
        })
    }
    
    // Adds a role to a user
    func addRole(user: PFUser, role: PFRole) -> Promise<Bool> {
        return Promise<Bool>(in: .background, { resolve, reject, _ in
            // Add user to role
            role.users.add(user)
            
            // Update it in the database
            Database().updateToDatabase(object: role).then { res in
                resolve(res)
            }
        })
    }
    
    // Gets the roles of user, as a list of strings
    func getUserRoles(user: PFUser) -> Promise<[String]> {
        return Promise<[String]>(in: .background, { resolve, reject, _ in
            self.getAllRoles().then{ allRoles in
                var userRoles = [String]()
                var rolesChecked = 0
                
                // If there aren't any roles, return an empty array
                if allRoles.count == 0 {
                    resolve(userRoles)
                }
                
                // Search through each role to find the ones the user belongs to
                for role in allRoles {
                    // Check to see if they belong
                    self.doesUserBelongToRole(user: user, role: role).then{ belongs in
                        // If they do, add this role the the list of the user's roles
                        if belongs {
                            userRoles.append(role["name"] as! String)
                        }
                        
                        // If this is the last role to check, send back the result
                        // TODO: It's likely this might need/want semaphores
                        rolesChecked += 1
                        if rolesChecked >= allRoles.count {
                            resolve(userRoles)
                        }
                    }
                }
            }
        })
    }
    
    // Checks whether a user belongs to a role
    func doesUserBelongToRole(user: PFUser, role: PFRole) -> Promise<Bool> {
        return Promise<Bool>(in: .background, { resolve, reject, _ in
            // Find everyone who belongs to this role
            //let userRelations = role["users"] as! PFRelation<PFUser>
            //let userQuery = userRelations.query()
            let userQuery = role.users.query()
            
            // Query it and check to see if this role contains our user
            Database().simpleQuery(query: userQuery as! PFQuery<PFObject>).then{ res in
                let users = res as! [PFUser]
                resolve(users.contains(user))
            }
        })
    }
    
    // Returns a list containing all available roles registered in the database
    func getAllRoles() -> Promise<[PFRole]> {
        return Promise<[PFRole]>(in: .background, { resolve, reject, _ in
            // Create the query
            let roleQuery = PFQuery(className: "_Role")
            roleQuery.whereKey("isActive", equalTo: true)
            
            // Query it
            Database().simpleQuery(query: roleQuery).then{ res in
                resolve(res as! [PFRole])
            }
        })
    }
    
    // Returns a PFRole object, given the name of a role. Can be used to add/remove users from a role
    func getRoleFromName(role: String) -> Promise<PFRole> {
        return Promise<PFRole>(in: .background, { resolve, reject, _ in
            // Create the query
            let roleQuery = PFQuery(className: "_Role")
            roleQuery.whereKey("name", contains: role)
            roleQuery.whereKey("isActive", equalTo: true)
            
            // Query it
            Database().simpleQuery(query: roleQuery).then{ res in
                // If there isn't a role, return an error
                if (res.count == 0){
                    let err = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Role not found"])
                    reject(err)
                }
                
                resolve(res[0] as! PFRole)
            }
        })
    }
    
    // Returns a PFUser object, given the username of a user.
    func getUserFromName(username: String) -> Promise<PFUser> {
        return Promise<PFUser>(in: .background, { resolve, reject, _ in
            // Create the query
            let userQuery = PFQuery(className: "_User")
            userQuery.whereKey("username", equalTo: username)
            userQuery.whereKey("isActive", equalTo: true)
            
            // Query it
            Database().simpleQuery(query: userQuery).then{ res in
                // If there isn't a user, return an error
                if (res.count == 0){
                    let err = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "User not found"])
                    reject(err)
                }
                
                resolve(res[0] as! PFUser)
            }
        })
    }
    
    
    
    
    // Logs in with a username and password
    // Returns the user who logged in
    func login(user: String, pass: String) -> Promise<PFUser> {
        return Promise<PFUser>(in: .background, { resolve, reject, _ in
            // Just call Parse's login function and handle any errors
            PFUser.logInWithUsername(inBackground: user, password: pass, block: {
                (result : PFUser?, error: Error?) -> Void in
                
                if let result = result {
                    resolve(result)
                }
                else {
                    reject(error!)
                }
            })
        })
    }
    
    // This function is used to change the password of a user that is not currently logged in
    // Don't use this function on a user that is logged in!
    func changePasswordOfOtherUser(user: PFUser, newPassword: String) -> Promise<Bool> {
        return Promise<Bool>(in: .background, { resolve, reject, _ in
            user.password = newPassword
            
            // Update the user in the database
            Database().updateToDatabase(object: user).then{ result in
                resolve(result)
            }
        })
    }
    
    // Changes the password of the current user and attempts to relog
    // Not tested too much, might be better to use the 'become' method
    func changePasswordOfCurrentUser(newPassword: String) -> Promise<Bool> {
        return Promise<Bool>(in: .background, { resolve, reject, _ in
            // Set new password
            let currentUser = PFUser.current()!
            let myUsername = currentUser.username!
            currentUser.password = newPassword
            
            // Update the user in the database
            Database().updateToDatabase(object: currentUser).then{ result in
                // Logout and log back in
                PFUser.logOutInBackground(block: { (error: Error?) -> Void in
                    if error == nil {
                        self.login(user: myUsername, pass: newPassword).then{ result in
                            resolve(true)
                        }
                    }
                    else {
                        reject(error!)
                    }
                })
            }
        })
    }
    
    
}
