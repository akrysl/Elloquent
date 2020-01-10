//
//  ManageClassesTableViewCell.swift
//  ELLAPP2017
//
//  Created by Nick Ponce on 1/18/18.
//  Copyright © 2018 Ellokids. All rights reserved.
//

import UIKit

class ManageClassesTableViewCell: UITableViewCell {

    @IBOutlet weak var classNameLabel: UILabel!
    @IBOutlet weak var gradeLevelLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
