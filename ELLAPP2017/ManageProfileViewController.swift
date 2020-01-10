//
//  ManageProfileViewController.swift
//  ELLAPP2017
//
//  Created by Nick Ponce on 1/25/18.
//  Copyright © 2018 Ellokids. All rights reserved.
//

import UIKit
import Parse

class ManageProfileViewController: UIViewController {

    var currentUser = PFUser.current()!

    @IBOutlet weak var userImage: PFImageView!
    var userImageFile = PFFile(data: Data())
    var imagePicker = UIImagePickerController()
    
    @IBOutlet weak var userNameField: UILabel!

    @IBOutlet weak var oldPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var confirmNewPassword: UITextField!
    @IBOutlet weak var passwordMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self

        userNameField.text = currentUser.username
        
        userImageFile = currentUser["ProfilePic"] as? PFFile
        userImageFile?.getDataInBackground(block: { (imageData: Data?, error: Error?) -> Void in
            if error == nil {
                self.userImage.image = UIImage(data: imageData!)
            }
            
        })
        
        userImage.layer.cornerRadius = userImage.frame.size.width / 2
        userImage.clipsToBounds = true
        userImage.layer.borderWidth = 3
        userImage.layer.borderColor = UIColor.white.cgColor
    }

    @IBAction func buttonChooseImageOnClick(_ sender: UIButton) {
        
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
            imagePicker.delegate = self
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
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func submitPasswordButton(_ sender: UIButton) {
        if newPassword.text! == confirmNewPassword.text! {
            Users().login(user: currentUser.username!, pass: oldPassword.text!).then { result in
                Users().changePasswordOfCurrentUser(newPassword: self.newPassword.text!).then { result in
                    self.passwordMessage.isHidden = false
                    self.passwordMessage.text = "Password successfully changed"
                }
            }.catch { result in
                self.passwordMessage.isHidden = false
                  self.passwordMessage.text = "Incorrect password"
            }
        }
        else{
            self.passwordMessage.isHidden = false
            self.passwordMessage.text = "Passwords don't match"
        }
        

    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ManageProfileViewController:  UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        /*
         Get the image from the info dictionary.
         If no need to edit the photo, use `UIImagePickerControllerOriginalImage`
         instead of `UIImagePickerControllerEditedImage`
         */
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage
        {
            let dataImage = UIImagePNGRepresentation(editedImage)
            print(dataImage == nil)


            
            
            //print("pixels: \(dataImage.)")
            if let pfEditedImageFile = PFFile(name: "image.png", data: dataImage!)
            {
                currentUser["ProfilePic"] = pfEditedImageFile
                Database().updateToDatabase(object: currentUser).then{result in
                    print(result)
                }
                self.userImage.image = editedImage
            }
        }
        
        //Dismiss the UIImagePicker after selection
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

extension ManageProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
