//
//  BookCollectionViewCell.swift
//  test
//
//  Created by Grant Holstein on 1/28/18.
//  Copyright © 2018 Grant Holstein. All rights reserved.
//

import UIKit

class BookCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var bookImageView: UIImageView!

    
    var book: Book? {
        didSet{
            self.updateBook()
        }
    }
    
    private func updateBook()
    {
        if let book = book{
            bookImageView.image = book.bookImage
        }else{
            bookImageView.image = nil
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = 3.0
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.8
        self.clipsToBounds = false
    }
}

