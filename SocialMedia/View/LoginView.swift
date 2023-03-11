//
//  LoginView.swift
//  SocialMedia
//
//  Created by Manuchim Oliver on 09/03/2023.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

struct LoginView: View {
    @State var email: String = ""
    @State var password: String = ""
    
    @State var createAccount: Bool = false
    
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    @State var isLoading: Bool = false
    
    //User default data
    @AppStorage("loggedIn_status") var loggedInStatus: Bool = false
    @AppStorage("user_profile_url") var profileUrl: URL?
    @AppStorage("user_name") var storedUserName: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    
    var body: some View {
        
        VStack(spacing: 10) {
            Text("Welcome back techie👋")
                .font(.title.bold())
                .hAlign(.leading)
            
            Text("Please sign in to continue")
                .font(.title3)
                .hAlign(.leading)
            
            
            VStack(spacing: 15) {
                TextField("Enter your email", text: $email)
                    .textContentType(.emailAddress)
                    .border(1, .gray.opacity(0.7))
                    .padding(.top, 25)
                
                SecureField("Enter your password", text: $password)
                    .textContentType(.password)
                    .border(1, .gray.opacity(0.7))
                
                Button("Forgot your password?", action: forgotPassword)
                    .font(.callout)
                    .fontWeight(.medium)
                    .tint(.lightGreen)
                    .hAlign(.trailing)
                //Sign in Button
                Button (action: loginUser) {
                    Text("Sign in")
                        .foregroundColor(.white)
                        .hAlign(.center)
                        .fillView(.darkBlue)
                }
                .padding(.top, 10)
            }
            //Register button
            HStack {
                Text("Don't have an account?")
                    .foregroundColor(.gray)
                
                Button("Sign Up Now", action: {
                    createAccount.toggle()
                })
                .fontWeight(.bold)
                .foregroundColor(.lightGreen)
            }
            .font(.callout)
            .vAlign(.bottom)
        }
        .vAlign(.top)
        .padding(15)
        .overlay(content: {
            LoadingView(show: $isLoading)
        })
        // show register view as a bottom sheet when createAccount  == true
        .sheet(isPresented: $createAccount) {
            RegisterView()
        }
        .alert(errorMessage, isPresented: $showError, actions: {})
        
    }
    
    func loginUser(){
        isLoading = true
        closeActiveKeyboard()
        Task {
            do {
                try await Auth.auth().signIn(withEmail: email, password: password)
                print("User logged in")
                try await getUser()
            } catch {
                await handleError(error)
            }
        }
    }
    
    //Fetches user data from Firestore if user is found successfully
    func getUser() async throws {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        let user = try await Firestore.firestore().collection("Users").document(userID).getDocument(as: User.self)
        
        //MainActor.run ensures that UI is updated in main thread
        await MainActor.run(body: {
            //Passing values to user default variables and updating app's auth status
            userUID = userID
            storedUserName = user.username
            profileUrl = user.userProfileURL
            loggedInStatus = true
        })
    }
    
    func forgotPassword (){
        Task {
            do {
                try await Auth.auth().sendPasswordReset(withEmail: email)
                print("Reset password Link Sent")
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
    
    struct LoginView_Previews: PreviewProvider {
        static var previews: some View {
            LoginView()
        }
    }
}
