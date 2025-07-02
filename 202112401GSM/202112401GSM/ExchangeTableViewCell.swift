//
//  ExchangeTableViewCell.swift
//  202112401GSM
//
//  Created by ss on 6/4/25.
//

import UIKit

class ExchangeTableViewCell: UITableViewCell {

    @IBOutlet weak var ctrCode: UILabel!
    @IBOutlet weak var ctrExc: UILabel!
    @IBOutlet weak var ctrBuy: UILabel!
    @IBOutlet weak var ctrSell: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
