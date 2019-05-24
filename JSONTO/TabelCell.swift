//
//  TabelCell.swift
//  JSONTO
//
//  Created by Brijesh Patel on 24/05/19.
//  Copyright © 2019 Brijesh Patel. All rights reserved.
//

import UIKit

class TabelCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!    
    @IBOutlet weak var cityLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
