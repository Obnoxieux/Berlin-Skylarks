//
//  BSMGameScore.swift
//  Berlin Skylarks
//
//  Created by David Battefeld on 25.01.21.
//

import Foundation
import SwiftUI
import CoreLocation

struct GameScore: Hashable, Codable, Identifiable {
    var id: Int
    var match_id: String
    var time: String // gets converted by DateFormatter() in view
    var league_id: Int
    var home_runs: Int? //those really should be Ints
    var away_runs: Int?
    var home_team_name: String
    var away_team_name: String
    var human_state: String
    var scoresheet_url: String?
    var field: Field?
    var league: League
    var home_league_entry: LeagueEntry
    var away_league_entry: LeagueEntry
    var umpire_assignments: [Umpire_Assignments]
    var scorer_assignments: [Scorer_Assignments]
    
    //Custom entries not available in BSM API!
    var gameDate: Date?
    var skylarksAreHomeTeam: Bool?
    var skylarksWin: Bool?
    var isDerby: Bool?
    
    struct Field: Hashable, Codable {
        var name: String
        var city: String?
        var street: String?
        var postal_code: String?
        var latitude: Double?
        var longitude: Double?
    }
 
    //now global (used elsewhere as well)
//    struct League: Hashable, Codable {
//        var id: Int
//        var season: Int
//        var name: String
//    }
    
    struct LeagueEntry: Hashable, Codable {
        var team: Team
        //var league: League?
    }
    
//    struct Home_League_Entry: Hashable, Codable {
//        var team: Team
//    }
//
//    struct Away_League_Entry: Hashable, Codable {
//        var team: Team
//    }
    
    struct Umpire_Assignments: Hashable, Codable {
        var license: License
    }
    
    struct Scorer_Assignments: Hashable, Codable {
        var license: License
    }
    
    struct License: Hashable, Codable {
        var person: Person
        var number: String
    }
    
    struct Person: Hashable, Codable {
        var first_name: String
        var last_name: String
    }
    
    //there is another team struct with different entities!
    struct Team: Hashable, Codable {
        var name: String
        var short_name: String
        var clubs: [Club]
    }
    
    struct Club: Hashable, Codable {
        var id: Int
        var name: String
        var short_name: String
        var acronym: String
    }
    
    mutating func determineGameStatus() {
        
        //default values so they are never nil
        skylarksWin = false
        skylarksAreHomeTeam = false
        isDerby = false
        
        if home_team_name.contains("Skylarks") && !away_team_name.contains("Skylarks") {
            skylarksAreHomeTeam = true
            isDerby = false
        } else if away_team_name.contains("Skylarks") && !home_team_name.contains("Skylarks") {
            skylarksAreHomeTeam = false
            isDerby = false
        }
        if away_team_name.contains("Skylarks") && home_team_name.contains("Skylarks") {
            isDerby = true
        }
        if skylarksAreHomeTeam! && !isDerby! {
            if let awayScore = away_runs, let homeScore = home_runs {
                if homeScore > awayScore {
                    skylarksWin = true
                }
                if homeScore < awayScore {
                    skylarksWin = false
                }
            }
        } else if !skylarksAreHomeTeam! && !isDerby! {
            if let awayScore = away_runs, let homeScore = home_runs {
                if homeScore > awayScore {
                    skylarksWin = false
                }
                if homeScore < awayScore {
                    skylarksWin = true
                }
            }
        }
    }
    
    mutating func addDates() {
        gameDate = getDatefromBSMString(gamescore: self)
    }
}

struct Ballpark: Identifiable {
    let id = UUID()
    var name: String
    var coordinate: CLLocationCoordinate2D
}
