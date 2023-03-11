//
//  RegisterView.swift
//  SocialMedia
//
//  Created by Manuchim Oliver on 09/03/2023.
//

import SwiftUI
import PhotosUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

struct RegisterView: View {
    @State var email: String = ""
    @State var password: String = ""
    @State var username: String = ""
    @State var userBio: String = ""
    @State var portfolioLink: String = ""
    @State var userProfilePicture: Data?
    
    @Environment(\.dismiss) var dismiss
    
    @State var showImagePicker: Bool = false
    @State var photo: PhotosPickerItem?
    
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
            Text("Welcome to DevConnect🧑‍💻")
                .font(.title.bold())
                .hAlign(.leading)
            
            Text("Create an account to connect with techies, network and learn")
                .font(.title3)
                .hAlign(.leading)
            
            
            //Accounting for smaller screens
            
            ViewThatFits {
                ScrollView(.vertical, showsIndicators: false){
                    HelperView()
                }
                
                HelperView()
            }
            //Log In button
            HStack {
                Text("Already have an account?")
                    .foregroundColor(.gray)
                
                Button("Log in", action: {
                    dismiss()
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
        .photosPicker(isPresented: $showImagePicker, selection: $photo)
        .onChange(of: photo) {newValue in
            //Extracting the UIImage from photo variable
            if let newValue {
                Task{
                    do{
                        guard let imageData = try await newValue.loadTransferable(type: Data.self)
                        else {return}
                        //Update UI on main thread only
                        await MainActor.run(body: {
                            userProfilePicture = imageData
                        })
                    } catch{}
                }
            }
        }
        .alert(errorMessage, isPresented: $showError, actions: {})
    }
    
    @ViewBuilder
    func HelperView()-> some View{
        VStack(spacing: 15) {
            ZStack{
                if let userProfilePicture, let image = UIImage(data: userProfilePicture){
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Image("DefaultProfile")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            }
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            .contentShape(Circle())
            .padding(.top, 10)
            .onTapGesture {
                showImagePicker.toggle()
            }
            
            
            TextField("Enter a username", text: $username)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.7))
                .padding(.top, 10)
            
            TextField("Enter your email", text: $email)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.7))
            
            
            SecureField("Enter your password", text: $password)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.7))
            
            TextField("Something nice about yourself", text: $userBio, axis: .vertical)
                .frame(minHeight: 100, alignment: .top)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.7))
            
            TextField("Link to your portfolio/works (Optional)", text: $portfolioLink)
                .textContentType(.URL)
                .border(1, .gray.opacity(0.7))
            
            //Sign in Button
            Button (action: registerUser){
                Text("Sign up")
                    .foregroundColor(.white)
                    .hAlign(.center)
                    .fillView(.darkBlue)
            }
            .disableWithOpacity(username == "" || userBio == "" || email == "" || password == "" || userProfilePicture == nil)
            .padding(.top, 10)
        }
    }
    
    func registerUser(){
        isLoading = true
        closeActiveKeyboard()
        Task {
            do {
                //Create account in firebase
                try await Auth.auth().createUser(withEmail: email, password: password)
                
                //Upload profile picture to firebase storage
                guard let userUID = Auth.auth().currentUser?.uid else {return}
                guard let imageData = userProfilePicture else {return}
                let storageRef = Storage.storage().reference().child("Profile_Images").child(userUID)
                let _ = try await storageRef.putDataAsync(imageData)
                //Get the photo URL back
                let photoURL = try await storageRef.downloadURL()
                //Create User Object in Firestore
                let user = User(username: username, userBio: userBio, portfolioLink: portfolioLink, userUID: userUID, email: email, userProfileURL: photoURL)
                // Save User Object to firestore
                let _ = try Firestore.firestore().collection("Users").document(userUID).setData(from: user, completion: {error in
                    if error == nil {
                    print("Saved Successfully")
                        storedUserName = username
                        self.userUID = userUID
                        profileUrl = photoURL
                        loggedInStatus = true
                }})
            } catch {
                try await Auth.auth().currentUser?.delete()
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

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
