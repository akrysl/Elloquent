//
//  Book.swift
//  test
//
//  Created by Grant Holstein on 1/28/18.
//  Copyright © 2018 Grant Holstein. All rights reserved.
//

import UIKit
import Parse

class Book
{
    var title = ""
    var bookImage: UIImage
    
    init(title: String, bookImage: UIImage) {
        self.title = title
        self.bookImage = bookImage
    }

}

