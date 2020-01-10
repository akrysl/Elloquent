//
//  LoginViewController.swift
//  ELLAPP2017
// 
//  Created by Nick Ponce on 11/16/17.
//  Copyright © 2017 Ellokids. All rights reserved.
//

import UIKit
import Parse
import Hydra

class LoginViewController: UIViewController {
    

    @IBOutlet weak var loginErrorLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var currentUserGlobal = PFUser.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginbuttonAction(_ sender: UIButton) {
        Users().login(user: usernameTextField.text!, pass: passwordTextField.text!).then{ userObj in
            // If the login was successful, clear the password and navigate to the dashboard
            self.passwordTextField.text = ""
            
            self.navigateToDashboard(userObj: userObj)
        }.catch { err in
            // TODO: Consider reimplementing pop-ups for errors and notifications
            self.loginErrorLabel.isHidden = false
            self.loginErrorLabel.text = "Login failed. Try checking your password again"
            self.passwordTextField.text = ""
        }
    }
    
    // Navigates to userObj's dashboard
    func navigateToDashboard(userObj: PFUser) {
        // Get the roles this user is a part of
        Users().getUserRoles(user: userObj).then { userRoles in
            // Naviagate to the appropriate screen
            self.currentUserGlobal = userObj
            if userRoles.contains("teacher") || userRoles.contains("admin") {
                self.performSegue(withIdentifier: "sw_teacher_dashboard", sender: nil)
            }
            else if userRoles.contains("student") {
                self.performSegue(withIdentifier: "sw_student_mybooks", sender: nil)
            }
            else {
                //TODO: user belongs to no roles...? (or an error getting roles)
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "sw_teacher_dashboard" {
            let destVC = segue.destination as? TeacherDashboardViewController
            destVC?.username = self.currentUserGlobal!.username!
        }
        if segue.identifier == "sw_student_mybooks" {
            let destVC = segue.destination as? BooksViewController
            destVC?.username = self.currentUserGlobal!.username!
        }
    }

}
