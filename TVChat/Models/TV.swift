//
//  TV.swift
//  TVChat
//
//  Created by Satoshi Yokokawa on 2021/06/12.
//  Copyright © 2021 Satoshi Yokokawa. All rights reserved.
//

import Foundation
import Firebase

class Tv {
    
    let id: String
    let name: String
    let image: String
    let tvName: String
    let latestMessageId: String
    let createdAt: Timestamp
    
    var latestMessage: Message?
    var documentId: String?
    var tv: Tv?
    
    init(dic: [String: Any]){
        self.id = dic["id"] as? String ?? ""
        self.name = dic["name"] as? String ?? ""
        self.image = dic["image"] as? String ?? ""
        self.tvName = dic["tvName"] as? String ?? ""
        self.latestMessageId = dic["latestMessageId"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
    }
    
}
