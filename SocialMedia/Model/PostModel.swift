//
//  PostModel.swift
//  SocialMedia
//
//  Created by Manuchim Oliver on 11/03/2023.
//

import SwiftUI
import FirebaseFirestoreSwift

struct Post: Identifiable,Codable, Equatable, Hashable{
    @DocumentID var id: String?
    var text: String
    var imageURL: URL?
    var imageRefID: String = ""
    var createdAt: Date = Date()
    var likedIDs: [String] = []
    var dislikedIDs: [String] = []
    //Info about author of post
    var username: String
    var userUID: String
    var userProfileURL: URL
    
    enum CodingKeys: String, CodingKey {
        case id
        case text
        case imageURL
        case imageRefID
        case createdAt
        case likedIDs
        case dislikedIDs
        case username
        case userUID
        case userProfileURL
    }
    
}

