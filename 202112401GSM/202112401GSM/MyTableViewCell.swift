//
//  MyTableViewCell.swift
//  202112401GSM
//
//  Created by Induk cs5 on 2025/05/28.
//

import UIKit

class MyTableViewCell: UITableViewCell {
    
    @IBOutlet weak var reportTitle: UILabel!
    @IBOutlet weak var reportDate: UILabel!
    @IBOutlet weak var reportOverview: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
