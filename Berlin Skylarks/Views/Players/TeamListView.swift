//
//  TeamListView.swift
//  Berlin Skylarks
//
//  Created by David Battefeld on 25.12.20.
//

import SwiftUI

struct TeamDetailListHeader: View {
    var body: some View {
        Text("Team data")
    }
}

struct TeamListView: View {
    
    @State var teams = [BSMTeam]()
    
    @State private var loadingInProgress = false
    
    @AppStorage("selectedSeason") var selectedSeason = Calendar(identifier: .gregorian).dateComponents([.year], from: .now).year!
    
    func loadTeamData() async {
        
        let teamURL = URL(string:"https://bsm.baseball-softball.de/clubs/485/teams.json?filters[seasons][]=" + "\(selectedSeason)" + "&sort[league_sort]=asc&api_key=" + apiKey)!
        
        loadingInProgress = true
        
        do {
            teams = try await fetchBSMData(url: teamURL, dataType: [BSMTeam].self)
        } catch {
            print("Request failed with error: \(error)")
        }
        loadingInProgress = false
    }
    
    var body: some View {
        List {
            Section(header: TeamDetailListHeader()) {
                HStack {
                    Image(systemName: "person.3.fill")
                        .padding(.trailing)
                    Text("Team")
                    Spacer()
                    Text("League")
                        .frame(maxWidth: 110, alignment: .leading)
                        .padding(.trailing)
                }
                //.padding(.horizontal)
                .font(.headline)
                .listRowBackground(ColorStandingsTableHeadline)
                
                if loadingInProgress == true {
                    LoadingView()
                }
                
                ForEach(teams, id: \.self) { team in
                    NavigationLink(
                        destination: TeamDetailView(team: team)){
                            HStack {
                                Image(systemName: "person.3")
                                    .foregroundColor(.skylarksRed)
                                    .padding(.trailing)
                                Text(team.name)
                                Spacer()
                                if !team.league_entries.isEmpty {
                                    Text(team.league_entries[0].league.name)
                                        .frame(maxWidth: 110, alignment: .leading)
                                        .allowsTightening(true)
                                }
                            }
                    }
                }
                
                if teams.isEmpty && loadingInProgress == false {
                    Text("No team data.")
                }
                //.padding(.horizontal)
                //Text(teams.debugDescription)
            }
            
        }
        .navigationBarTitle("Teams" + " \(selectedSeason)")
        .listStyle( {
          #if os(watchOS)
            .automatic
          #else
            .insetGrouped
          #endif
        } () )
        .refreshable {
            teams = []
            await loadTeamData()
        }
    
        .onAppear(perform: {
            if teams == [] {
                Task {
                    await loadTeamData()
                }
            }
        })
        
        .onChange(of: selectedSeason, perform: { value in
            teams = []
        })
    }
}

struct TeamListView_Previews: PreviewProvider {
    static var previews: some View {
        TeamListView()
            //.preferredColorScheme(.dark)
    }
}
