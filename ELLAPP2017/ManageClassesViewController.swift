
//
//  ManageClassesViewController.swift
//
//
//  Created by Nick Ponce on 1/18/18.
//

import UIKit
import Parse

class ManageClassesViewController: UIViewController {
    
    var groups: [PFObject] = []
    var students: [PFObject] = []
    
    @IBOutlet weak var classTableView: UITableView!
    @IBOutlet weak var studentTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        let backButton = UIBarButtonItem(barButtonSystemItem: .bak, target: <#T##Any?#>, action: <#T##Selector?#>)
        //        self.navigationItem.backBarButtonItem
        //        self.navigationItem.rightBarButtonItem
        //        self.navigationItem.leftBarButtonItem
        // Do any additional setup after loading the view.
        
        self.classTableView.dataSource = self
        self.classTableView.delegate = self
        
        self.studentTableView.dataSource = self
        self.studentTableView.delegate = self
        
        // Populate array of available Classrooms for a user
        Classrooms().getClassrooms(user: PFUser.current()!).then{ classrooms in
            self.groups = classrooms
            self.classTableView.reloadData()
            self.updateClassStudents(classroom: self.groups[0]); // Assumes no one will not have groups
            self.studentTableView.reloadData()
            print("Fetched the classrooms")
            }.catch{ error in
                print("Experiencing errors in fetching the classrooms")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateClassStudents(classroom: PFObject) -> Void {
        Classrooms().getStudentsInClassroom(classroom: classroom).then { classgroup in
            print("Number of students in database class: \(classgroup.count)")
            self.students = classgroup
            self.studentTableView.reloadData()
            print("Number of students in classroom: \(self.students.count)")
            }.catch { error in
                //
        }
    }
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "sw_manage_to_student") {
            let destVC = segue.destination as? StudentInfoViewController
            destVC?.currStudent = self.students[self.studentTableView.indexPathForSelectedRow!.row]
        }
     }
}

extension ManageClassesViewController: UITableViewDataSource {
    
    // Defines number of sections for the table
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count: Int = 0
        
        if(tableView == self.classTableView) {
            count = groups.count
        }
        if(tableView == self.studentTableView) {
            // Might need to reload
            count = students.count
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(tableView == self.classTableView) {
            let classCell = tableView.dequeueReusableCell(withIdentifier: "manage_classes_cell", for: indexPath) as? ManageClassesTableViewCell
            
            //            classCell?.gradeLabel.text = groups[indexPath.row]["gradeLevel"] as? String
            
            if let groupName = groups[indexPath.row]["name"] as? String {
                print("This is the group name: \(groupName)")
                classCell?.classNameLabel.text = "Classroom: \(groupName)"
            }
            
            if let groupGradeLevel = groups[indexPath.row]["gradeLevel"] as? String {
                classCell?.gradeLevelLabel.text = "Grade: \(groupGradeLevel)"
            }
            
            return classCell!
        }
        if(tableView == self.studentTableView) {
            let studentCell = tableView.dequeueReusableCell(withIdentifier: "student_cell", for: indexPath) as? StudentTableViewCell
            
            print("Student amount should be \(self.students.count) and row \(indexPath.row)")
            print("Student name should be \(self.students[indexPath.row]["username"] as! String)")
            studentCell?.studentNameLabel.text = self.students[indexPath.row]["username"] as? String
            studentCell?.studentProfilePic.file = self.students[indexPath.row]["ProfilePic"] as? PFFile
            studentCell?.studentProfilePic.loadInBackground()
            
            return studentCell!
        }
        
        return UITableViewCell(style: .default, reuseIdentifier: "Cell")
    }
}

extension ManageClassesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(tableView == self.classTableView) {
            self.updateClassStudents(classroom: self.groups[indexPath.row])
        }
        if(tableView == self.studentTableView) {
            performSegue(withIdentifier: "sw_manage_to_student", sender: nil)
        }
    }
}

