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
    enum GameState: Codable {
        case planned, played, cancelled
    }
    
    var id: Int
    var match_id: String
    var time: String // gets converted by DateFormatter()
    var league_id: Int
    var home_runs: Int? //those really should be Ints
    var away_runs: Int?
    var home_team_name: String
    var away_team_name: String
    var planned_innings: Int
    var human_state: String
    var scoresheet_url: String?
    var field: BSMField?
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
    var isExternalGame: Bool?
    var homeTeamWin: Bool?
    var gameState: GameState?
    
    struct LeagueEntry: Hashable, Codable {
        var team: Team
        //var league: League?
    }
    
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
        var clubs: [BSMClub]
    }
    
    mutating func determineGameStatus() {
        
        //default values so they are never nil
        skylarksWin = false
        skylarksAreHomeTeam = false
        isDerby = false
        //new value since we now support non-Skylarks games
        isExternalGame = false
        //necessary for some calculations
        homeTeamWin = false
        
        switch human_state {
        case "gespielt":
            gameState = .played
        case "geplant":
            gameState = .planned
        default:
            gameState = .planned
        }
        
        //we are the home team
        if home_team_name.contains("Skylarks") && !away_team_name.contains("Skylarks") {
            skylarksAreHomeTeam = true
            isDerby = false
        // we are the road team
        } else if away_team_name.contains("Skylarks") && !home_team_name.contains("Skylarks") {
            skylarksAreHomeTeam = false
            isDerby = false
        }
        //the game consists of two Skylarks teams
        if away_team_name.contains("Skylarks") && home_team_name.contains("Skylarks") {
            isDerby = true
        }
        //neither team is Skylarks - external game
        if !away_team_name.contains("Skylarks") && !home_team_name.contains("Skylarks") {
            isExternalGame = true
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
        
        if let awayScore = away_runs, let homeScore = home_runs {
            if homeScore > awayScore {
                homeTeamWin = true
                gameState = .played
            } else if homeScore < awayScore {
                homeTeamWin = false
                gameState = .played
            }
        } else {
            gameState = .planned
        }
    }
    
    mutating func addDates() {
        gameDate = getDatefromBSMString(gamescore: self)
    }
}
