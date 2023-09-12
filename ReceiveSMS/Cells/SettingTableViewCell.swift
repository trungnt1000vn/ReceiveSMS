//
//  SettingTableViewCell.swift
//  ReceiveSMS
//
//  Created by Trung on 31/08/2023.
//

import UIKit

class SettingTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var arrow: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    static let identifier = "SettingTableViewCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        iconImage.contentMode = .scaleAspectFit
        selectionStyle = .default
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
