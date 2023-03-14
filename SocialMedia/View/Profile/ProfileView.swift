//
//  ProfileView.swift
//  SocialMedia
//
//  Created by Manuchim Oliver on 10/03/2023.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore

struct ProfileView: View {
    @State private var userProfile: User?
    @AppStorage("loggedIn_status") var loggedInStatus: Bool = false
    
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    @State var isLoading: Bool = false
    
    var body: some View {
        NavigationStack{
            VStack {
                if let userProfile {
                    ProfileContentView(user: userProfile)
                        .refreshable {
                            self.userProfile = nil
                            await getUserData()
                        }
                } else {
                    ProgressView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu{
                        Button("Logout", action: logoutUser)
                        
                        Button("Delete account", role: .destructive, action: deleteAccount)
                    } label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.init(degrees: 90))
                            .tint(.gray)
                            .scaleEffect(0.8)
                    }
                    
                }
            }
        }
        .overlay(content: {
            LoadingView(show: $isLoading)
        })
        .alert(errorMessage, isPresented: $showError, actions: {})
        .task {
            //.task acts like an onAppear function and gets user data when screen loads
            if userProfile != nil {return}
            await getUserData()
        }
    }
    
    
    func getUserData() async {
        guard let userUID = Auth.auth().currentUser?.uid else {return}
        guard let user = try? await Firestore.firestore().collection("Users").document(userUID).getDocument(as: User.self) else {return}
        await MainActor.run(body: {
            userProfile = user
        })
    }
    
    //Logs a user out
    func logoutUser() {
        try? Auth.auth().signOut()
        loggedInStatus = false
    }
    
    //Deletes a users account
    func deleteAccount() {
        isLoading = true
        Task {
            do{
                guard let userUID = Auth.auth().currentUser?.uid else {return}
                //Deleting the user's profile image from Firebase storage
                let ref = Storage.storage().reference().child("Profile_Images").child(userUID)
                try await ref.delete()
                //Deleting Firestore user document/object
                try await Firestore.firestore().collection("Users").document(userUID).delete()
                // Deleting Auth document and setting loggedIn Status to false
                try await Auth.auth().currentUser?.delete()
                loggedInStatus = false
            } catch {
               await handleError(error)
            }
        }
    }
    
    @Sendable func handleError(_ error: Error) async {
        //perform this task on main thread
        
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
            isLoading = false
        })
    }
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
