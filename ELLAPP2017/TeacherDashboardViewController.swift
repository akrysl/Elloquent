//
//  TeacherDashboardViewController.swift
//  ELLAPP2017
//
//  Created by Nick Ponce on 12/4/17.
//  Copyright © 2017 Ellokids. All rights reserved.
//

import UIKit

class TeacherDashboardViewController: UIViewController {

    @IBOutlet weak var welcomeLabel: UILabel!
    var username = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //welcomeLabel.text = "Welcome \(username)"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Buttons for Dashboard options
    @IBAction func manageClassroomButton(_ sender: UIButton) {
        performSegue(withIdentifier: "sw_teacher_manageclasses", sender: nil)
        //sender.setBackgroundImage(UIImage(named:"blue.png"), for: UIControlState.normal)
    }
    
    @IBAction func viewLocalLibraryButton(_ sender: UIButton) {
        performSegue(withIdentifier: "sw_teacher_locallib", sender: nil)
    }
    
    @IBAction func viewGlobalLibraryButton(_ sender: UIButton) {
        performSegue(withIdentifier: "sw_teacher_global_lib", sender: nil)
    }
    
    @IBAction func manageProfileButton(_ sender: UIButton) {
        performSegue(withIdentifier: "sw_teacher_profile", sender: nil)
    }
    
    // MARK: - Navigation
    /*    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "sw_teacher_manageclasses" {
            let destVC = segue.destination as? ManageClassesViewController
            destVC?.username = self.username
        }
    }
    */

}
