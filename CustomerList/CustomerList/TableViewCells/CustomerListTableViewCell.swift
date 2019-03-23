//
//  CustomerListTableViewCell.swift
//  CustomerList
//
//  Created by Bharat Mahajan on 22/03/19.
//  Copyright © 2019 BharatMahajan. All rights reserved.
//

import UIKit

class CustomerListTableViewCell: UITableViewCell {
    // MARK: - Variables
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var lblUserId: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var btnUserLocation: UIButton!
    @IBOutlet weak var lblDistance: UILabel!
    
    // MARK: - Cell Methods

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
