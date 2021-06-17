//
//  ChatRoom.swift
//  TVChat
//
//  Created by Satoshi Yokokawa on 2021/06/12.
//  Copyright © 2021 Satoshi Yokokawa. All rights reserved.
//

import Foundation
import Firebase

class ChatRoom {
    
    let latestMessageId: String
    let id: String
    let createdAt: Timestamp
    
    var latestMessage: Message?
    var documentId: String?
    var tv: Tv?
    
    init(dic: [String: Any]) {
        self.latestMessageId = dic["latestMessageId"] as? String ?? ""
        self.id = dic["id"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
    }
    
}
