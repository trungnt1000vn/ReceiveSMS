//
//  TableCell.swift
//  ReceiveSMS
//
//  Created by Trung on 22/08/2023.
//

import UIKit

class TableCell: UITableViewCell {
    @IBOutlet weak var iconImage: UIImageView!
    
    @IBOutlet weak var countryLabel: UILabel!
    static let identifier = "TableCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        iconImage.contentMode = .scaleAspectFit
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
