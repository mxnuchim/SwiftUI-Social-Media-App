//
//  CreateNewPostView.swift
//  SocialMedia
//
//  Created by Manuchim Oliver on 11/03/2023.
//

import SwiftUI
import PhotosUI
import Firebase
import FirebaseFirestore
import FirebaseStorage


struct CreateNewPostView: View {
    var onPost:(_ post: Post) ->()
    
    @State private var postText: String = ""
    @State private var postImageData: Data?
    
    //User variables from Appstorage
    @AppStorage("user_profile_url") private var profileUrl: URL?
    @AppStorage("user_name") private var storedUserName: String = ""
    @AppStorage("user_UID") private var userUID: String = ""
    
    //View Props and others
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    @State private var showImagePicker: Bool = false
    @State private var photo: PhotosPickerItem?
    @FocusState private var showKeyboard: Bool
    
    var body: some View {
        VStack{
            HStack {
                Menu {
                    Button("Cancel", role: .destructive){
                        dismiss()
                    }
                } label: {
                    Text("Cancel")
                        .font(.callout)
                        .foregroundColor(.darkBlue)
                }
                .hAlign(.leading)
                
                Button(action: createNewPost){
                    Text("Post")
                        .font(.callout)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 6)
                        .background(Color.darkBlue, in: Capsule())
                }
                .disableWithOpacity(postText == "")
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background{
                Rectangle()
                    .fill(.gray.opacity(0.05))
                    .ignoresSafeArea()
            }
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 15) {
                    TextField("What's happening?", text: $postText, axis: .vertical)
                        .focused($showKeyboard)
                    if let postImageData, let image = UIImage(data: postImageData){
                        GeometryReader{
                            let size = $0.size
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: size.width, height: size.height)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .overlay(alignment: .topTrailing){
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.3)){
                                            self.postImageData = nil
                                        }
                                    } label: {
                                        Image(systemName: "trash")
                                            .fontWeight(.bold)
                                            .tint(.red)
                                    }
                                    .padding(10)
                                }
                        }
                        .clipped()
                        .frame(height: 220)
                    }
                }
                .padding(15)
            }
            
            Divider()
            
            HStack{
                Button{
                    showImagePicker.toggle()
                } label: {
                    Image(systemName: "photo.on.rectangle")
                        .font(.title3)
                }
                .hAlign(.leading)
                
                Button("Done"){
                    showKeyboard = false
                }
            }
            .foregroundColor(.darkBlue)
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
        }
        .vAlign(.top)
        .photosPicker(isPresented: $showImagePicker, selection: $photo)
        .onChange(of: photo) { newValue in
            Task {
                if let rawImage = try? await newValue?.loadTransferable(type: Data.self),
                   let image = UIImage(data: rawImage),
                   let compressedImage = image.jpegData(compressionQuality: 0.5){
                    await MainActor.run(body: {
                        postImageData = compressedImage
                        photo = nil
                    })
                }}
        }
        .alert(errorMessage, isPresented: $showError, actions: {})
        .overlay{
            LoadingView(show: $isLoading)
        }
    }
    
    func createNewPost () {
        isLoading = true
        showKeyboard = false
        Task {
            do {
                guard let profileUrl else {return}
                //Uploading image if it exists
                //imagerefID will be used when deleting post
                let imageRefID = "\(userUID)\(Date())"
                let storageRef = Storage.storage().reference().child("Post_Images").child(imageRefID)
                if let postImageData {
                    let _ = try await storageRef.putDataAsync(postImageData )
                    let photoURL = try await storageRef.downloadURL()
                    
                    //Creating a post object
                    let post = Post(text: postText, imageURL: photoURL, imageRefID: imageRefID, username: storedUserName, userUID: userUID, userProfileURL: profileUrl)
                    
                    try await createDocumentAtFirebase(from: post)
                } else {
                    // Creates normal post without image on Firebase
                    let post = Post(text: postText, username: storedUserName, userUID: userUID, userProfileURL: profileUrl)
                    try await createDocumentAtFirebase(from: post)
                }
            } catch {
                await handleError(error)
            }
        }
    }
    
    func createDocumentAtFirebase (from post: Post) async throws {
        let document = Firestore.firestore().collection("Posts").document()
        let _ = try document.setData(from: post, completion: { error in
            if error == nil {
                //Post successfully created and stored in Firebase
                isLoading = false
                var updatedPost = post
                updatedPost.id = document.documentID
                onPost(updatedPost)
                dismiss()
            }
        })
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

struct CreateNewPostView_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewPostView{_ in
            
        }
    }
}
