//
//  BooksViewController.swift
//  test
//
//  Created by Grant Holstein on 1/28/18.
//  Copyright © 2018 Grant Holstein. All rights reserved.
//

import UIKit
import Parse

class BooksViewController: UIViewController {
    
    @IBOutlet weak var booksCollectionView: UICollectionView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var ManageProfile: UIButton!
    
    
    /* Array of pulled books */
    var books = [Book]()
    var bookArray = [PFObject]()
    let bookScale: CGFloat = 0.6
    var vocab = [String]()
    
    var username = String()
    var currentUser = PFUser.current()!
    
   /* For the view to load we need to configure the collection view settings */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //nameLabel.text = "\(username)'s Books"
        let name = currentUser["username"] as! String
        nameLabel.text = "\(String(describing: name))'s Books"
        
        /* Setup the collection view's setting fields */
        let screenSize = UIScreen.main.bounds.size
        let bookWidth = floor(screenSize.width * bookScale)
        let bookHeight = floor(screenSize.height * bookScale)
        
        let insetX = (view.bounds.width - bookWidth) / 2.0
        let insetY = (view.bounds.height - bookHeight) / 4.0
        let bookLayout = booksCollectionView!.collectionViewLayout as! UICollectionViewFlowLayout
        bookLayout.itemSize = CGSize(width: bookWidth, height: bookHeight)
        booksCollectionView?.contentInset = UIEdgeInsets(top: insetY, left: insetX, bottom: insetY, right: insetX)
        
        booksCollectionView?.dataSource = self
        booksCollectionView?.delegate = self
        
        booksCollectionView.allowsSelection = true
        
        /* TODO: Look into "UICollectionView's two prefetching techniques" */
        Classrooms().getClassrooms(user: PFUser.current()!).then { classrooms in
            for classroom in classrooms {
                Classrooms().getBooksInClassroom(classroom: classroom).then { result in
                    for book in result {
                        /* Get what you need from each book */
                        let title = book["name"] as! String
                        let cover = book["coverPicture"] as! PFFile
                        //let vocab = book["vocab"] as! [String]
                        
                        /* Get the image from the PFFile */
                        cover.getDataInBackground({ (data, error) -> Void in
                            if let coverImage = UIImage(data: data!) {
                                /* Add the new books to the array and reload the data in the collection view */
                                self.books.append(Book(title: title, bookImage: coverImage))
                                self.bookArray.append(book)
                                self.booksCollectionView.reloadData()
                            }
                            else {
                                print("There was an image error: \(error.debugDescription)")
                            }
                        })
                    }
                }
            }
        }
    }
    
//    /* Temporary fix for Demo before doing a didSelect implementation */
//    @IBAction func tempCellSelect(_ sender: UIButton) {
//        performSegue(withIdentifier: "sw_doodle", sender: nil)
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* This function prepares for the next segue by getting the indexpath for the selected  */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sw_doodle" {
            let destVC = segue.destination as? DoodleGameViewController
            
            print("selected items: \(self.booksCollectionView.indexPathsForSelectedItems!.count)")
            let selectedIndexPath = self.booksCollectionView.indexPathsForSelectedItems![0]
            
            print("Selected item number: \(selectedIndexPath.item) and book count: \(self.books.count)")
//            destVC?.words.append(self.books[selectedIndexPath.item].title)
            destVC?.words = self.vocab
        }
    }
    
    @IBAction func goToManageProfile(_ sender: Any) {
        //self.performSegue(withIdentifier: "sw_teacher_profile", sender: nil)
    }
}

extension BooksViewController : UICollectionViewDataSource
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("4Number of books \(self.books.count)")
        return self.books.count //returns the number of books fetched
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = booksCollectionView.dequeueReusableCell(withReuseIdentifier: "myBook", for: indexPath) as! BookCollectionViewCell
        
        cell.book = self.books[indexPath.item] //creates cell for each book
        
        return cell
    }
}

extension BooksViewController: UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected an item and it registered in the delegate function")
        
        // Empty vocab words from previous games
        vocab.removeAll()
        
        let selectedBook = bookArray[indexPath.item]
        Books().getVocabWords(book: selectedBook).then { vocabs in
            for myVocab in vocabs {
                self.vocab.append(myVocab["name"] as! String)
            }
            self.performSegue(withIdentifier: "sw_doodle", sender: nil)
        }
    }
}

