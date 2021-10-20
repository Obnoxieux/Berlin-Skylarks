//
//  TabBarView.swift
//  Berlin Skylarks
//
//  Created by David Battefeld on 23.12.20.
//

import SwiftUI


let ItemBackgroundColor = Color(UIColor.tertiarySystemFill)
//let PageBackgroundColor = Color(UIColor.secondarySystemBackground) //using standard backgrounds for now
let NewsItemSpacing: CGFloat = 10
let NewsItemCornerRadius: CGFloat = 20.0
let NewsItemPadding: CGFloat = 15

//right now all news items lead to the same page

struct NewsView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(
                    destination: NewsDetailView()) {
                        NewsItem()
                }
                NavigationLink(
                    
                    //here a hardcoded link to a WebView is used for testing
                    
                    destination: WebArticleView()) {
                        VStack(
                            alignment: .leading,
                            spacing: NewsItemSpacing
                        ) {
                            Image("dummy_kids")
                                .resizable()
                                .scaledToFit()
                            Text("Eventbericht")
                                .font(.title3)
                                .padding(10)
                            Text("Kinder hatten ganz viel Spaß")
                                .font(.headline)
                                .lineLimit(nil)
                                .padding(10)
                        }
                        .background(ItemBackgroundColor)
                        .cornerRadius(NewsItemCornerRadius)
                        .padding(NewsItemPadding)
                        .foregroundColor(.primary)
                }
            } .navigationBarTitle("News")
            .listStyle(InsetListStyle())
        }
    }
}


//DEBUG

struct NewsView_Previews: PreviewProvider {
    static var previews: some View {
        NewsView()
    }
}

struct NewsItem: View {
    var body: some View {
        VStack(
            alignment: .leading,
            spacing: NewsItemSpacing
        ) {
            Image("dummy_field")
                .resizable()
                .scaledToFit()
            Text("Spielbericht")
                .font(.title2)
                .bold()
                .padding(.horizontal, 10)
            Text("Skylarks gewinnen durch Homerun im 9. Inning nach heroischer Performance")
                .lineLimit(nil)
                .padding(10)
        }
        .background(ItemBackgroundColor)
        .cornerRadius(NewsItemCornerRadius)
        .padding(NewsItemPadding)
        .foregroundColor(.primary)
        .frame(maxWidth: 330)
    }
}
