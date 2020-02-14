//
//  PostSubmitTestViewController.swift --> changed to "Add Student" Screen 2/5/2020
//  ELLAPP2017
//
//  Created by Andy Tran Nguyen on 2/11/19.
//  Copyright © 2019 Ellokids. All rights reserved.
//

import UIKit
import Foundation
import Parse
import Hydra

class PostSubmitTestViewController: UIViewController {
    
    
    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var gradeLevel: UITextField!
    
    @IBOutlet weak var classroom: UITextField!
    
    @IBOutlet weak var englishLevel: UITextField!
    
    var userImageFile = PFFile(data: Data())
    var imagePicker = UIImagePickerController()
    
    var currentUser = PFUser.current()!

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate

        // Do any additional setup after loading the view.

        
        print("add student view controller screen")

        
    }
    
    @IBAction func submitNewStudent(_ sender: Any) {
        
        //createUserWithRole(<#T##Users#>, username, password, "student")
        //let c = getClassroom(name: classroom.text!)
        print(username.text!)
        print(password.text!)
        print(classroom.text!)
        print(englishLevel.text!)
        print(gradeLevel.text!)
        //createStudent(profilePic: userImageFile!, username: username.text!, password: password.text!, gradeLevel: gradeLevel.text!, englishLevel: englishLevel.text!, Classroom: classroom.text!)
        _ = Users().createUserWithRole(username: username.text!, password: password.text!, role: "student")
        //Classrooms().addUserToClassroom(user: newStudent, classroom: c.result)
        self.performSegue(withIdentifier: "backToManageClassroom", sender: self)
    }

    @IBAction func addProfilePic(_ sender: UIButton) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { _ in
            self.openPhotos()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        //If you want work actionsheet on ipad then you have to use popoverPresentationController to present the actionsheet, otherwise app will crash in iPad
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alert.popoverPresentationController?.sourceView = sender
            alert.popoverPresentationController?.sourceRect = sender.bounds
            alert.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
        {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            //If you dont want to edit the photo then you can set allowsEditing to false
            imagePicker.allowsEditing = true
            imagePicker.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openPhotos()
    {
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        //If you dont want to edit the photo then you can set allowsEditing to false
        imagePicker.allowsEditing = true
        imagePicker.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createStudent(profilePic: PFFile, username: String, password: String, gradeLevel: String, englishLevel: String, Classroom: String) {
        print("in createStudent function")
        let newUser = PFUser(className: "_User")
        newUser["username"] = username
        //newUser.username = username
        newUser["password"] = password
        //newUser.password = password
        newUser["isActive"] = true
        newUser["profilePic"] = profilePic
        newUser["gradeLvl"] = gradeLevel
        newUser["englishLvl"] = englishLevel
        // New users should have public read/write permissions
        let acl = PFACL()
        acl.getPublicReadAccess = true
        acl.getPublicWriteAccess = true
        newUser.acl = acl
        //newUser.signUpInBackground()
        //newUser.saveInBackground()
        // Other fields can be set just like any other PFObject,
        // like this: user["attribute"] = "its value"
        // If this field does not exists, it will be automatically created
        //Users().signupUser(user: newUser).then { result in
        //    Database().updateToDatabase(object: newUser).then{res in
        //        print("add new user to database")
                
        //    }
        //Database().updateToDatabase(object: newUser).then{result in
        //    print("result update to database new student",result)
                
   //     }
 //       })
 //  }
        //newUser.signUpInBackgroundWithBlock //{
        //    (succeeded: Bool, error: NSError?) -> Void in
        //    if let error = error {
        //    let errorString = error.userInfo["error"] as? NSString
            // Show the errorString somewhere and let the user try again.
        //    } else {
            // Hooray! Let them use the app now.
        //    }
        //    } as! PFBooleanResultBlock as! PFBooleanResultBlock
        // Add to the database
        //Users().signupUser(user: newUser).then { result in
        //    Database().updateToDatabase(object: newUser).then{ res in
        //        resolve(newUser)
            // Add to the classroom
        //Classrooms().addUserToClassroom(user: newUser, classroom: c)
        //_ = getClassroomFromName(user: newUser, name: Classroom)
        //        }
        //    }
        //})
    }
    
    func getClassroomFromName(user: PFUser, name: String) -> Promise<PFObject> {
        print("in getClassroomFromName function")
        return Promise<PFObject>(in: .background, { resolve, reject, _ in
            // Create the query
        let userQuery = PFQuery(className: "_Classroom")
        userQuery.whereKey("name", equalTo: name)
        userQuery.whereKey("isActive", equalTo: true)
        
        // Query it
        Database().simpleQuery(query: userQuery).then{ res in
            // If there isn't a user, return an error
            print("queried database")
            if (res.count == 0){
                _ = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Classroom not found"])
                return
                }
                resolve(res[0] as! PFUser)
            print("found classroom")
            _ = Classrooms().addUserToClassroom(user: user, classroom: res[0])
            }
        })
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
}
