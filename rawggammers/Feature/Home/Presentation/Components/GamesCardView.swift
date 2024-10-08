//
//  GamesCardView.swift
//  rawggammers
//
//  Created by Ademola Kolawole on 28/07/2024.
//

import SwiftUI

/// A view that displays a card for a game, showcasing its background image, rating, and name.
///
/// The `GamesCardView` presents a card with a background image of a game and overlays additional information, including platform icons and the game's rating and name. The card features a rounded rectangle shape with a custom bottom overlay.
struct GamesCardView: View {
    /// The data model containing information about the game to be displayed.
    var gameData: ResultData
    
    var body: some View {
        ZStack {
            // Display the background image if available
            if let imageUrl = URL(string: gameData.backgroundImage ?? "") {
                NetworkImageView(imageURL: imageUrl)
                    .aspectRatio(contentMode: .fill)
                    .scaledToFill()
                    .clipShape(.rect(cornerRadius: 20))
                    .overlay(alignment: .bottom) {
                        UnevenRoundedRectangle(bottomLeadingRadius: 20, bottomTrailingRadius: 20)
                            .foregroundColor(.theme.cardColor)
                            .frame(height: 93)
                            .alignmentGuide(.bottom) { d in d[.bottom] }
                            .overlay {
                                VStack(alignment: .leading, spacing: 5) {
                                    HStack {
                                        // Extract unique platform names and limit to the first 5
                                        let uniquePlatformNames = Array(Set(gameData.platforms?.compactMap { $0.platform?.name?.lowercased().split(separator: " ").first } ?? []).prefix(5))
                                        
                                        // Map the platform names to their corresponding images
                                        let platformImages: [String: String] = uniquePlatformNames.reduce(into: [:]) { result, platformName in
                                            if let platform = gameData.platforms?.first(where: { $0.platform?.name?.lowercased().split(separator: " ").first == platformName }) {
                                                if let platformImage = platform.platform?.getImages(platform: String(platformName)) {
                                                    result[String(platformName)] = platformImage
                                                }
                                            }
                                        }
                                        
                                        // Display the platform images in a ForEach loop
                                        ForEach(platformImages.keys.sorted(), id: \.self) { platformName in
                                            if let platformImage = platformImages[platformName] {
                                                Image(platformImage)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 15, height: 15)
                                            }
                                        }
                                        Spacer()
                                        // Display the game's rating in a rounded rectangle
                                        RoundedRectangle(cornerRadius: 5)
                                            .foregroundColor(.clear)
                                            .frame(width: 35, height: 35)
                                            .foregroundColor(.theme.primaryTextColor)
                                            .background(Color.theme.background)
                                            .cornerRadius(5)
                                            .overlay {
                                                Text("\(gameData.rating ?? 0.0, specifier: "%.1f")")
                                                    .customFont(CustomFont.orbitronSemiBold.copyWith(size: 14))
                                                    .foregroundColor(.theme.primaryTextColor)
                                            }
                                    }
                                    .padding(.horizontal, 10)
                                    .frame(maxWidth: 200, alignment: .leading)
                                    
                                    // Display the game's name
                                    Text("\(gameData.name ?? "")")
                                        .customFont(CustomFont.orbitronSemiBold.copyWith(size: 12))
                                        .foregroundColor(.theme.primaryTextColor)
                                        .frame(maxWidth: 180, alignment: .leading)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.leading)
                                        .padding(.horizontal, 10)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                            }
                    }
                    .frame(width: 210, height: 250)
                    .background(Color.theme.cardColor)
                    .cornerRadius(20)
            }
        }
    }
}

struct GamesCardView_Previews: PreviewProvider {
    static var previews: some View {
        GamesCardView(gameData: dev.gamesData.results[0])
    }
}
