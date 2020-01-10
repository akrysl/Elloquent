//
//  GlobalLibraryTableViewCell.swift
//  ELLAPP2017
//
//  Created by Nick Ponce on 3/6/18.
//  Copyright © 2018 Ellokids. All rights reserved.
//

import UIKit
import Parse

class GlobalLibraryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var globalBookTitleLabel: UILabel!
    @IBOutlet weak var globalAuthorLabel: UILabel!
    @IBOutlet weak var globalCoverPictureImageView: PFImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
