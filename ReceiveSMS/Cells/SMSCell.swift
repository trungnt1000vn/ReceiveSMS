//
//  SMSCell.swift
//  ReceiveSMS
//
//  Created by Trung on 22/08/2023.
//

import UIKit
import Toast
class SMSCell: UITableViewCell {

    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var senderLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var copyButton: UIButton!
    
    static let identifier = "SMSCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func copyTapped(_ sender: Any) {
        let content = contentLabel.text
        let pasteBoard = UIPasteboard.general
        pasteBoard.string = content
        showToast(message: "Message Content Copied To Clipboard")
    }
}
extension SMSCell{
    private func showToast(message: String){
        if let window = UIApplication.shared.windows.first {
            window.makeToast(message)
        }
    }
}
