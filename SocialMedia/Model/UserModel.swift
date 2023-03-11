//
//  UserModel.swift
//  SocialMedia
//
//  Created by Manuchim Oliver on 09/03/2023.
//

import SwiftUI
import FirebaseFirestoreSwift

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var username: String
    var userBio: String
    var portfolioLink: String
    var userUID: String
    var email: String
    var userProfileURL: URL
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case userBio
        case portfolioLink
        case userUID
        case email
        case userProfileURL
    }
}
