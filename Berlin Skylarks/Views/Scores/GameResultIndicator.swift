//
//  GameResultIndicator.swift
//  Berlin Skylarks
//
//  Created by David Battefeld on 06.06.22.
//

import SwiftUI

struct GameResultIndicator: View {
    
    var gamescore: GameScore
    
    var body: some View {
        if gamescore.human_state.contains("geplant") {
            Text("TBD")
                .bold()
                .padding()
        }
        if gamescore.human_state.contains("ausgefallen") {
            Text("PPD")
                .bold()
                .padding()
        }
        if let derby = gamescore.isDerby, let win = gamescore.skylarksWin {
            if gamescore.human_state.contains("gespielt") ||
                gamescore.human_state.contains("Forfeit") ||
                gamescore.human_state.contains("Nichtantreten") ||
                gamescore.human_state.contains("Wertung") ||
                gamescore.human_state.contains("Rückzug") ||
                gamescore.human_state.contains("Ausschluss") {
                if !derby {
                    if win {
                        Text("W")
                            .bold()
                            .foregroundColor(.green)
                            .padding()
                    } else {
                        Text("L")
                            .bold()
                            .foregroundColor(.accentColor)
                            .padding()
                    }
                } else {
                    VStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.accentColor)
                        Text("Derby - Skylarks win either way")
                            .padding()
                    }
                    .padding()
                }
            }
        }
    }
}

struct GameResultIndicator_Previews: PreviewProvider {
    static var previews: some View {
        GameResultIndicator(gamescore: testGame)
    }
}