//
//  HomeView.swift
//  SocialMedia
//
//  Created by Manuchim Oliver on 10/03/2023.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        TabView {
            PostsView()
                .tabItem{
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            ProfileView()
                .tabItem{
                    Image(systemName: "gear.circle")
                    Text("Me")
                }
        }
        .tint(.darkBlue)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
