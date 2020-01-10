//
//  LocalLibraryTableViewCell.swift
//  ELLAPP2017
//
//  Created by Nick Ponce on 3/6/18.
//  Copyright © 2018 Ellokids. All rights reserved.
//

import UIKit
import Parse

class LocalLibraryTableViewCell: UITableViewCell {

    @IBOutlet weak var localBookTitleLabel: UILabel!
    @IBOutlet weak var localAuthorLabel: UILabel!
    @IBOutlet weak var localCoverPictureImageView: PFImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
