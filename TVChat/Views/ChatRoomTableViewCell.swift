//
//  ChatRoomTableViewCell.swift
//  TVChat
//
//  Created by Satoshi Yokokawa on 2021/06/12.
//  Copyright © 2021 Satoshi Yokokawa. All rights reserved.
//

import UIKit

class ChatRoomTableViewCell: UITableViewCell {
    var message: Message? {
        didSet {

            }
        }
    
 
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nameTextView: UILabel!
    
    @IBOutlet weak var messageTextViewWidthConstraint: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        messageTextView.layer.cornerRadius = 15
        messageTextView.backgroundColor = UIColor.white
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        checkWhichUserMessage()
    }
    private func checkWhichUserMessage() {
            
            if let message = message {
                messageTextView.text = message.message
                nameTextView.text = message.name
                let witdh = estimateFrameForTextView(text: message.message).width + 20
                messageTextViewWidthConstraint.constant = witdh
                dateLabel.text = dateFormatterForDateLabel(date: message.createdAt.dateValue())
            }
        
    }
    
    
    private func estimateFrameForTextView(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)], context: nil)
    }
    
    private func dateFormatterForDateLabel(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
}
