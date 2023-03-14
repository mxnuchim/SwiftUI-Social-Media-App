//
//  ReusablePostsView.swift
//  SocialMedia
//
//  Created by Manuchim Oliver on 13/03/2023.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct ReusablePostsView: View {
    @Binding var posts: [Post]
    @State var isLoading: Bool = true
    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
            LazyVStack {
                if isLoading {
                    ProgressView()
                        .padding(.top, 30)
                } else {
                    if posts.isEmpty{
                        //No posts found from db
                        Text("No posts yet")
                            .font(.caption)
                            .foregroundColor(.darkBlue)
                            .padding(.top, 30)
                    } else {
                        Posts()
                    }
                }
            }
            .padding(15)
        }
        .refreshable {
            isLoading = true
            posts = []
            await getPosts()
        }
        .task{
            guard posts.isEmpty else{return}
            await getPosts()
        }
    }
    
    //rendering fetched posts
    @ViewBuilder
    func Posts()-> some View {
        ForEach(posts){post in
            SinglePostCardView(post: post) {updatedPost in
                if let index = posts.firstIndex(where: { post in
                    post.id == updatedPost.id
                }){
                    posts[index].likedIDs = updatedPost.likedIDs
                    posts[index].dislikedIDs = updatedPost.dislikedIDs
                }
            } onDelete: {
                //Removing post form array
                withAnimation(.easeIn(duration: 0.25)){
                    posts.removeAll{post == $0}
                }
            }
            
            Divider()
                .padding(.horizontal, -15)
        }
    }
    
    func getPosts() async {
        do{
            var query: Query!
            query = Firestore.firestore().collection("Posts")
                .order(by: "createdAt", descending: true)
                .limit(to: 30)
            let docs = try await query.getDocuments()
            let fetchedPosts = docs.documents.compactMap{doc -> Post? in
                try? doc.data(as: Post.self)
            }
            await MainActor.run(body: {
                posts = fetchedPosts
                isLoading = false
            })
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct ReusablePostsView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
