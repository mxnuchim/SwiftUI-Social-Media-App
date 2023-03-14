//
//  SearchView.swift
//  SocialMedia
//
//  Created by Manuchim Oliver on 14/03/2023.
//

import SwiftUI
import FirebaseFirestore

struct SearchView: View {
    @State private var fetchedUsers: [User] = []
    @State private var searchQuery: String = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            ForEach(fetchedUsers){user in
                NavigationLink {
                    ProfileContentView(user: user)
                } label: {
                    Text(user.username)
                        .font(.callout)
                        .hAlign(.leading)
                }
            }
        }
        .listStyle(.plain)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Search")
        .searchable(text: $searchQuery)
        .onSubmit(of: .search, {
            Task{await searchUsers()}
        })
        .onChange(of: searchQuery, perform: {newValue in
            if newValue.isEmpty{
                fetchedUsers = []
            }
        })
        
        
    }
    
    func searchUsers () async {
        do{
            
            let documents = try await Firestore.firestore().collection("Users")
                .whereField("username", isGreaterThanOrEqualTo: searchQuery)
                .whereField("username", isLessThanOrEqualTo: "\(searchQuery)\u{f8ff}")
                .getDocuments()
            
            let users = try documents.documents.compactMap {doc -> User? in
                try doc.data(as: User.self)
            }
            
            await MainActor.run(body: {
                fetchedUsers = users
            })
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
