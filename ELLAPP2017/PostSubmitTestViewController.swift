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
    
    var classrooms = [PFObject]()
    
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
        createStudent(profilePic: userImageFile!, username: username.text!, password: password.text!, gradeLevel: gradeLevel.text!, englishLevel: englishLevel.text!, Classroom: classroom.text!)
        //self.performSegue(withIdentifier: "backToLogin", sender: self)
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
        newUser["password"] = password
        newUser["isActive"] = true
        ///newUser["profilePic"] = profilePic
        newUser["gradeLvl"] = gradeLevel
        newUser["englishLvl"] = englishLevel
        // New users should have public read/write permissions
        let acl = PFACL()
        acl.getPublicReadAccess = true
        acl.getPublicWriteAccess = true
        newUser.acl = acl

        do{
            try(newUser.signUp())
            getClassroomFromName(user: newUser, name: Classroom)
            //try(newUser.signUp())
        }
        catch{
            print("failed to sign up user")
        }
    }
    
    
    func addToClassroom(u: PFUser, c: PFObject){
        print("in addToClassroom function")
        let newEntry = PFObject(className: "ClassroomUserIntermediate")
        newEntry["user"] = PFObject(withoutDataWithClassName: "_User", objectId: u.objectId)
        newEntry["classroom"] = PFObject(withoutDataWithClassName: "Classroom", objectId: c.objectId)
        let acl = PFACL()
        acl.getPublicReadAccess = true
        acl.getPublicWriteAccess = true
        newEntry.acl = acl
        newEntry["isTeacher"] = false
        newEntry["isActive"] = true
        Database().updateToDatabase(object: newEntry).then{ _ in
            print("added to intermediate database")
            }.catch{_ in
                print("could not add to intermediate table")
        }
    }
    
    func getClassroomFromName(user: PFUser, name: String) {
        print("in getClassroomFromName function")
        var i = 0
        while(i < classrooms.count)
        {
            let str = classrooms[i]["name"] as!String
            print("classroom comparison: ", str)
            print("classroom object id: ", classrooms[i].objectId!)
            if(str == name)
            {
                print("found classroom")
                addToClassroom(u: user, c: classrooms[i])
                user["Classroom"] = PFObject(withoutDataWithClassName: "Classroom", objectId: classrooms[i].objectId)
                Database().updateToDatabase(object: user).then{_ in
                    print("successfully updated student's classroom attribute")
                    }.catch{_ in 
                        print("failed to update student's classroom")
                }
                //Users().getRoleFromName(role: "student").then { role in
                //    Users().addRole(user: user, role: role).then{ _ in
                //        print("added student role to user")
                //    }}
                return
            }
            i += 1
        }
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
