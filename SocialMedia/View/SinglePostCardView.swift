//
//  SinglePostCardView.swift
//  SocialMedia
//
//  Created by Manuchim Oliver on 13/03/2023.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

struct SinglePostCardView: View {
    var post: Post
    
    var onUpdate: (Post)->()
    var onDelete: ()->()
    
    @AppStorage("user_UID") private var userUID: String = ""
    @State private var doclistener: ListenerRegistration?
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            WebImage(url: post.userProfileURL)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 35, height: 35)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 6) {
                Text(post.username)
                    .font(.callout)
                    .fontWeight(.semibold)
                Text(post.text)
                    .textSelection(.enabled)
                    .padding(.vertical, 8)
                
                if let postImageUrl = post.imageURL {
                    GeometryReader{
                        let size = $0.size
                        WebImage(url: postImageUrl)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .frame(height: 200)
                }
                HStack{
                    interactWithPost()
                    
                    Text(post.createdAt.formatted(date: .numeric, time: .shortened))
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .hAlign(.trailing)
                }
            }
        }
        .hAlign(.leading)
        .overlay(alignment: .topTrailing, content: {
            //if author,make delete post button vivible
            if post.userUID == userUID{
                Menu {
                    Button("Delete Post", role: .destructive, action: {})
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.caption)
                        .foregroundColor(.black)
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .offset(x: 8)
            }
        })
        .onAppear{
            if doclistener == nil {
                guard let postID = post.id else{return}
                doclistener = Firestore.firestore().collection("Posts").document(postID).addSnapshotListener({ snapshot, error in
                    if let snapshot {
                        if snapshot.exists{
                            if let updatedPost = try? snapshot.data(as: Post.self){
                                onUpdate(updatedPost)
                            }
                        } else {
                            onDelete()
                        }
                    }
                })
            }
        }
    }
    
    func interactWithPost()-> some View {
        HStack(spacing: 6) {
            Button (action: likePost){
                            Image(systemName: post.likedIDs.contains(userUID) ? "suit.heart.fill" : "suit.heart")
                        }
            
                        Text("\(post.likedIDs.count)")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.trailing, 7)
            
            Button (action: dislikePost){
                Image(systemName: post.dislikedIDs.contains(userUID) ? "heart.slash.fill" : "heart.slash")
            }
            
            Text("\(post.dislikedIDs.count)")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.trailing, 7)
        }
        .foregroundColor(.lightGreen)
        .padding(.vertical, 8)
    }
    
    func likePost() {
        Task {
            guard let postID = post.id else {return}
            if post.likedIDs.contains(userUID){
                //Removing user ID from array
                try await Firestore.firestore().collection("Posts").document(postID).updateData([
                    "likedIDs": FieldValue.arrayRemove([userUID])
                ])
            } else {
                //Add user UID to array and update
                try await Firestore.firestore().collection("Posts").document(postID).updateData([
                    "likedIDs": FieldValue.arrayUnion([userUID]),
                    "dislikedIDs": FieldValue.arrayRemove([userUID])
                ])
            }
            
        }
    }
    
    func dislikePost() {
        Task {
            guard let postID = post.id else {return}
            if post.dislikedIDs.contains(userUID){
                //Removing user ID from array
                try await Firestore.firestore().collection("Posts").document(postID).updateData([
                    "dislikedIDs": FieldValue.arrayRemove([userUID])
                ])
            } else {
                //Add user UID to array and update
                try await Firestore.firestore().collection("Posts").document(postID).updateData([
                    "likedIDs": FieldValue.arrayRemove([userUID]),
                    "dislikedIDs": FieldValue.arrayUnion([userUID])
                ])
            }
            
        }
    }
}

