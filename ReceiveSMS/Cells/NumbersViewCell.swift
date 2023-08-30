//
//  NumbersViewCell.swift
//  ReceiveSMS
//
//  Created by Trung on 22/08/2023.
//

import UIKit

class NumbersViewCell: UITableViewCell {

    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var rightArrow: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    static let identifier = "NumbersViewCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        iconImage.contentMode = .scaleAspectFit
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
