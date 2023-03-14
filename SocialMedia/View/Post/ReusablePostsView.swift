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
    var basedOnUID: Bool = false
    var uid: String = ""
    @Binding var posts: [Post]
    @State var isLoading: Bool = true
    
    /// - For Pagination
    @State private var paginationDoc: QueryDocumentSnapshot?
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
            LazyVStack {
                if isLoading {
                    ProgressView()
                        .padding(.top, 30)
                } else {
                    if posts.isEmpty{
                        /// - No posts found from db
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
            /// - Disabling refresh functionality for UID based fetches
            guard !basedOnUID else {return}
            isLoading = true
            posts = []
            paginationDoc = nil
            await getPosts()
        }
        .task{
            guard posts.isEmpty else{return}
            await getPosts()
        }
    }
    
    /// - Rendering fetched posts
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
                /// - Removing post form array
                withAnimation(.easeIn(duration: 0.25)){
                    posts.removeAll{post.id == $0.id}
                }
            }
            .onAppear{
              // - fetch new posts when last post appears
                if post.id == posts.last?.id && paginationDoc != nil {
                    Task{await getPosts()}
                }
            }
            
            Divider()
                .padding(.horizontal, -15)
        }
    }
    
    func getPosts() async {
        do{
            var query: Query!
            if let paginationDoc {
                query = Firestore.firestore().collection("Posts")
                    .order(by: "createdAt", descending: true)
                    .start(afterDocument: paginationDoc)
                    .limit(to: 25)
            } else {
                query = Firestore.firestore().collection("Posts")
                    .order(by: "createdAt", descending: true)
                    .limit(to: 25)
            }
            
            /// - Query based on user UID
            if basedOnUID {
                query = query.whereField("userUID", isEqualTo: uid)
            }
            
            let docs = try await query.getDocuments()
            let fetchedPosts = docs.documents.compactMap{doc -> Post? in
                try? doc.data(as: Post.self)
            }
            await MainActor.run(body: {
                posts.append(contentsOf: fetchedPosts)
                paginationDoc = docs.documents.last
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
