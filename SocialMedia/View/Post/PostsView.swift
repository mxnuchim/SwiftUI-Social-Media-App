//
//  PostsView.swift
//  SocialMedia
//
//  Created by Manuchim Oliver on 11/03/2023.
//

import SwiftUI

struct PostsView: View {
    @State private var recentPosts: [Post] = []
    @State private var createNewPost: Bool = false
    var body: some View {
        NavigationStack{
            ReusablePostsView(posts: $recentPosts)
                .hAlign(.center).vAlign(.center)
                .overlay(alignment: .bottomTrailing) {
                    Button {
                        createNewPost.toggle()
                    } label: {
                        Image(systemName: "pencil")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(13)
                            .background(Color.darkBlue, in: Circle())
                    }
                    .padding(15)
                }
                .toolbar(content: {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink{
                            SearchView()
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .tint(.gray)
                                .scaleEffect(0.9)
                        }
                    }
                })
                .navigationTitle("Your feed")
        }
            .fullScreenCover(isPresented: $createNewPost) {
                CreateNewPostView{ post in
                    recentPosts.insert(post, at: 0)
                }
            }
    }
}

struct PostsView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
