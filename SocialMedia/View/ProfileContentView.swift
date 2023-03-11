//
//  ProfileContentView.swift
//  SocialMedia
//
//  Created by Manuchim Oliver on 10/03/2023.
//

import SwiftUI
import SDWebImageSwiftUI

struct ProfileContentView: View {
    var user: User
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack {
                HStack (spacing: 12) {
                    WebImage(url: user.userProfileURL).placeholder{
                        Image("DefaultProfile")
                            .resizable()
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(user.username)
                            .textCase(.lowercase)
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text(user.userBio)
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        //Display portfolio link if it exists
                        if let portfolioLink = URL(string: user.portfolioLink){
                            Link(user.portfolioLink, destination: portfolioLink)
                                .font(.caption)
                                .tint(.blue)
                                .lineLimit(1)
                        }
                    }
                    .hAlign(.leading)
                }
                
                Text("Posts")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.darkBlue)
                    .hAlign(.leading)
                    .padding(.vertical, 15)
            }
            .padding(15)
        }
    }
}
