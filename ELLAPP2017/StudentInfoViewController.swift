//
//  StudentInfoViewController.swift
//  ELLAPP2017
//
//  Created by Grant Holstein on 2/14/18.
//  Copyright © 2018 Ellokids. All rights reserved.
//

import UIKit
import Parse

class StudentInfoViewController: UIViewController {


    

    @IBOutlet weak var englishLevel: UILabel!
    @IBOutlet weak var studentName: UILabel!
    @IBOutlet weak var gradeLevel: UILabel!
    
    var currStudent: PFObject = PFObject(className: "User") // "_User"
    var englishLev = String()
    var gradeLev = String()
    @IBOutlet weak var studentImage: PFImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        englishLev = currStudent["englishLvl"] as! String
        gradeLev = currStudent["gradeLvl"] as! String

        studentName.text! = currStudent["username"] as! String//make call for students name
        englishLevel.text = "English Level: \(englishLev)"//make call for student's english level
        gradeLevel.text = "Grade: \(gradeLev)"//make call for student's grade level
        studentImage.file = currStudent["ProfilePic"] as! PFFile!//make call for student image
        
        
        // Make image circular
        studentImage.layer.cornerRadius = studentImage.frame.size.width / 2
        studentImage.clipsToBounds = true
        studentImage.layer.borderWidth = 3
        studentImage.layer.borderColor = UIColor.white.cgColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
