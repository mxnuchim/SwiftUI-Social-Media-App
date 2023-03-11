//
//  ContentView.swift
//  SocialMedia
//
//  Created by Manuchim Oliver on 09/03/2023.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("loggedIn_status") var loggedInStatus: Bool = false
    
    var body: some View {
        if loggedInStatus{
            HomeView()
        } else {
            LoginView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
