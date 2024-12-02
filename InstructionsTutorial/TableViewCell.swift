//
//  TableViewCell.swift
//  InstructionsTutorial
//
//  Created by HT-Mac-08 on 02/12/24.
//  Copyright © 2024 Henry Chukwu. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var button: UIButton!
    override func awakeFromNib() {
            super.awakeFromNib()
            print("Button is connected: \(button != nil)")
        }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
