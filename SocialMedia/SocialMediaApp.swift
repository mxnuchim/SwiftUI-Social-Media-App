//
//  SocialMediaApp.swift
//  SocialMedia
//
//  Created by Manuchim Oliver on 09/03/2023.
//

import SwiftUI
import Firebase

@main
struct SocialMediaApp: App {
    init(){
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
