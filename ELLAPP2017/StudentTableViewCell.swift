//
//  StudentTableViewCell.swift
//  ELLAPP2017
//
//  Created by Grant Holstein on 3/15/18.
//  Copyright © 2018 Ellokids. All rights reserved.
//

import UIKit
import Parse

class StudentTableViewCell: UITableViewCell {

    
    @IBOutlet weak var studentProfilePic: PFImageView!
    @IBOutlet weak var studentNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
