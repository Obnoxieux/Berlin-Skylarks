//
//  TestView.swift
//  Berlin Skylarks
//
//  Created by David Battefeld on 30.09.21.
//

import SwiftUI
import MapKit

struct TestView: View {

    var gamescore: GameScore
    
    var body: some View {
        List {
            VStack {
                HStack {
                    home_team_logo
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 30, alignment: .center)
                    //Text(gamescore.home_league_entry.team.short_name)
                        .font(.caption)
                        .padding(.leading)
                    Spacer()
                }
            }
            .padding(.vertical)
        }
        //.font(.footnote)
        //.padding()
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView(gamescore: dummyGameScores[60])
    }
}
