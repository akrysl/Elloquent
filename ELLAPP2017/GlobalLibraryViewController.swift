//
//  GlobalLibraryViewController.swift
//  ELLAPP2017
//
//  Created by Nick Ponce on 1/23/18.
//  Copyright © 2018 Ellokids. All rights reserved.
//

import UIKit
import Parse


class GlobalLibraryViewController: UIViewController {

    @IBOutlet weak var globalLibraryTableView: UITableView!
    
    var BooksArray: [PFObject] = []
    var titles = [String]()
    var authors = [String]()
    var coverPictures = [PFFile]()
    var selectedTitle = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Get all book objects and extract their data into arrays
        Books().getGlobalBooks().then{ books in
            for book in books {
                self.titles.append(book["name"] as! String)
                self.authors.append(book["author"] as! String)
                self.coverPictures.append(book["coverPicture"] as! PFFile)
//                self.globalLibraryTableView.reloadData()
            }
            self.BooksArray = books
            self.globalLibraryTableView.reloadData()
        }.catch { error in
            // Error handling
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "sw_global_to_book")
        {
            let destVC = segue.destination as? BookInfoViewController
            destVC?.currBook = self.BooksArray[globalLibraryTableView.indexPathForSelectedRow!.row]
        }
    }

}

extension GlobalLibraryViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = globalLibraryTableView.dequeueReusableCell(withIdentifier: "global_library_cell", for: indexPath) as? GlobalLibraryTableViewCell
        
        // Add cell initialization
        cell?.globalBookTitleLabel.text = titles[indexPath.row]
        cell?.globalAuthorLabel.text = authors[indexPath.row]
        
        cell?.globalCoverPictureImageView.image = UIImage(named: "placeholder.jpg")
        cell?.globalCoverPictureImageView.file = coverPictures[indexPath.row]
        cell?.globalCoverPictureImageView.loadInBackground()
        
        return cell!
    }
    
}
extension GlobalLibraryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "sw_global_to_book", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete (Admin Only)"
    }
    
    // For enabling slide left deletions
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        //
    }
}
