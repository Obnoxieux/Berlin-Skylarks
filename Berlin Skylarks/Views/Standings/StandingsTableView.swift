//
//  StandingsTableView.swift
//  Berlin Skylarks
//
//  Created by David Battefeld on 10.08.21.
//

import SwiftUI

//this View is a single table with ONE league. it can be accessed by tapping the corresponding league in StandingsView

struct StandingsTableView: View {
    
//    let headlineHeight: CGFloat = 20
//
//    let winWidthHeadline: CGFloat = 24
//    let lossWidthHeadline: CGFloat = 21
//    let percentageWidthHeadline: CGFloat = 38
//    let gamesBehindWidthHeadline: CGFloat = 28
//    let streakWidthHeadline: CGFloat = 37
    
    @State var leagueTable: LeagueTable
    
    var body: some View {
        
        #if os(watchOS)
        
        //the table for Apple Watch removes the columns for streak and games behind and changes the team display name to the short name (acronym with number)
        
        List {
            Section {
                HStack {
                    Text("#")
                        .bold()
                    Text("Team")
                        .bold()
                    Spacer()
                    HStack {
                        Text("W")
                            .bold()
                            .frame(width: 24, height: 20, alignment: .center)
                        Text("L ")
                            .bold()
                            .frame(width: 21, height: 20, alignment: .center)
                        Text("%")
                            .bold()
                            .frame(width: 38, height: 20, alignment: .center)
                    }.padding(.horizontal, -5)
                }
                .font(.title3)
                
                ForEach(leagueTable.rows, id: \.rank) { tableRow in
                    HStack {
                        Text(tableRow.rank)
                        Text(tableRow.short_team_name)
                            //.padding(.horizontal, teamPadding)
                        Spacer()
                        HStack {
                            Text(String(tableRow.wins_count))
                                .frame(width: 21, height: 20, alignment: .center)
                            Text(String(tableRow.losses_count))
                                .frame(width: 21, height: 20, alignment: .center)
                            Text(tableRow.quota)
                                .frame(width: 42, height: 20, alignment: .center)
                        }.padding(.horizontal, -8)
                    }
                    .foregroundColor(tableRow.team_name.contains("Skylarks") ? Color.accentColor : Color.primary)
                }
                //more rows here
            }
        }
        .navigationTitle(leagueTable.league_name)
        
        #else
        ZStack {
            List {
                Section {
                    HStack {
                        Text("#")
                            .bold()
                        Text("Team")
                            .bold()
                        Spacer()
                        HStack {
                            Text("W")
                                .bold()
                                .frame(width: 24, height: 20, alignment: .center)
                            Text("L ")
                                .bold()
                                .frame(width: 21, height: 20, alignment: .center)
                            Text("%")
                                .bold()
                                .frame(width: 38, height: 20, alignment: .center)
                            Text("GB")
                                .bold()
                                .frame(width: 28, height: 20, alignment: .center)
                            Text("Srk")
                                .bold()
                                .frame(width: 37, height: 20, alignment: .center)
                        }.padding(.horizontal, -10)
                    }
                    .font(.title3)
                    //.foregroundColor(.white)
                    .listRowBackground(ColorStandingsTableHeadline)
                    
                    ForEach(leagueTable.rows, id: \.rank) { tableRow in
                        HStack {
                            Text(tableRow.rank)
                            Text(tableRow.team_name)
                                .padding(.horizontal, teamPadding)
                            Spacer()
                            HStack {
                                Text(String(tableRow.wins_count))
                                    .frame(width: 21, height: 20, alignment: .center)
                                Text(String(tableRow.losses_count))
                                    .frame(width: 21, height: 20, alignment: .center)
                                Text(tableRow.quota)
                                    .frame(width: 42, height: 20, alignment: .center)
                                Text(String(tableRow.games_behind))
                                    .frame(width: 26, height: 20, alignment: .center)
                                Text(tableRow.streak)
                                    .frame(width: 37, height: 20, alignment: .center)
                                    
                            }.padding(.horizontal, -8)
                        }
                        .foregroundColor(tableRow.team_name.contains("Skylarks") ? Color.accentColor : Color.primary)
                    }
                    //more rows here
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(leagueTable.league_name + " " + String(leagueTable.season))
            //.padding(.horizontal, padding)
            
            
            //this is sort of needed for dashboard, but breaks all other occurrences
            //.frame(width: 500, height: 500)
        }
        .iOS { $0.background(colorStandingsBackground) }
        #endif
    }
}



struct StandingsTableView_Previews: PreviewProvider {
    static var previews: some View {
        StandingsTableView(leagueTable: dummyLeagueTable)
            .preferredColorScheme(.dark)
    }
}
