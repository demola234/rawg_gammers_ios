//
//  FancyTabView.swift
//  rawggammers
//
//  Created by Ademola Kolawole on 26/07/2024.
//

import SwiftUI

struct FancyTabView: View {
    @State private var selectedTab = 0
    let tabBarImageNames = ["house.fill", "magnifyingglass", "heart.fill", "person.fill"]
    let tabBarTitles = ["Home", "Search", "Favourites", "Profile"]

    var body: some View {
        VStack {
            ZStack {
                switch selectedTab {
                case 0:
                    HomeView()
                        .environmentObject(HomeViewModel())
                case 1:
                    SearchView()
                case 2:
                    FavoriteScreen()
                case 3:
                    ProfileView()
                default:
                    HomeView()
                }
            }
            Spacer()
            CustomTabBar(selectedTab: $selectedTab, tabBarImageNames: tabBarImageNames, tabBarTitles: tabBarTitles)
                .frame(height: 80)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .gray, radius: 10, x: 0, y: 5)
                .padding()
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    let tabBarImageNames: [String]
    let tabBarTitles: [String]

    var body: some View {
        HStack {
            ForEach(0..<tabBarImageNames.count, id: \.self) { index in
                Spacer()
                Button(action: {
                    withAnimation {
                        selectedTab = index
                    }
                }) {
                    VStack {
                        Image(systemName: tabBarImageNames[index])
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(selectedTab == index ? .blue : .gray)
                            .scaleEffect(selectedTab == index ? 1.2 : 1.0)
                        Text(tabBarTitles[index])
                            .font(.caption)
                            .foregroundColor(selectedTab == index ? .blue : .gray)
                    }
                }
                Spacer()
            }
        }
    }
}

#Preview {
    FancyTabView()
}