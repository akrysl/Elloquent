//
//  BookInfoViewController.swift
//  ELLAPP2017
//
//  Created by Grant Holstein on 3/1/18.
//  Copyright © 2018 Ellokids. All rights reserved.
//

import UIKit
import Parse

class BookInfoViewController: UIViewController {

    
    var currBook = PFObject(className: "Book")
    var VocabArray: [PFObject] = []
    @IBOutlet weak var vocabTableView: UITableView!
    @IBOutlet weak var bookTitle: UILabel!
    @IBOutlet weak var bookAuthor: UILabel!
    @IBOutlet weak var bookLevel: UILabel!
    var allWordsArray = [String]()
    var allDefinitionsArray = [String]()
    
    var author = String()
    var grade = String()
    
    @IBOutlet weak var bookImage: PFImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        author = currBook["author"] as! String
        grade = currBook["gradeLevel"] as! String
        
        bookTitle.text! = currBook["name"] as! String//make call for book title
        bookAuthor.text = "Author: \(author)"//make call for book author
        bookLevel.text = "Grade Level: \(grade)"//make call for book grade level
        bookImage.file = currBook["coverPicture"] as! PFFile!//make call for book image
        
        Books().getVocabWords(book: currBook).then{vocabWords in
            for currWord in vocabWords {
                self.allWordsArray.append(currWord["name"] as! String)
                self.allDefinitionsArray.append(currWord["definition"] as! String)
            }
            self.VocabArray = vocabWords
            self.vocabTableView.reloadData()
        }
        
        
        // Make image circular
        //bookImage.layer.cornerRadius = bookImage.frame.size.width / 2
        bookImage.clipsToBounds = true
        bookImage.layer.borderWidth = 3
        bookImage.layer.borderColor = UIColor.white.cgColor
        
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

extension BookInfoViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("allWordsArray count: \(allWordsArray.count)")
        return allWordsArray.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = vocabTableView.dequeueReusableCell(withIdentifier: "book_vocab_cell", for: indexPath) as? VocabTableViewCell
        
        // Add cell initialization
        cell?.vocabName.text = allWordsArray[indexPath.row]
        cell?.vocabDefinition.text = allDefinitionsArray[indexPath.row]
        
        return cell!
    }
    
}
