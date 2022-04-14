//
//  GlobalFunctions.swift
//  Berlin Skylarks
//
//  Created by David Battefeld on 19.10.21.
//

import Foundation
import EventKit
import SwiftUI

//these are deprecated for actual use, but it's nevertheless helpful to have some fallback images defined

var away_team_logo = Image("App_road_team_logo")
var home_team_logo = Image("App_home_team_logo")

let flamingosLogo = Image("Berlin_Flamingos_Logo_3D")
let sluggersLogo = Image("Sluggers_Logo")

let teamLogos = [
    "Skylarks": skylarksSecondaryLogo,
    "Roosters": Image("Roosters_Logo"),
    "Sluggers": sluggersLogo,
    "Eagles": Image("Mahlow-Eagles_Logo"),
    "Ravens": Image("ravens_logo"),
    "R´s": Image("ravens_logo"),
    "Porcupines": Image("potsdam_logo"),
    "Sliders": Image("Sliders_Rund_2021"),
    "Flamingos": flamingosLogo,
    "Challengers": Image("challengers_Logo"),
    "Rams": Image("Rams-Logo"),
    "Wizards": Image("Wizards_Logo"),
    "Poor Pigs": Image("Poorpigs_Logo"),
    "Dukes": Image("Dukes_Logo"),
    "Roadrunners": Image("Roadrunners_Logo"),
    "Dragons": Image("Dragons_Logo"),
]

func fetchCorrectLogos(gamescore: GameScore) -> (road: Image, home: Image) {
    
    var road = away_team_logo
    var home = home_team_logo
    
    for (name, image) in teamLogos {
        if gamescore.away_team_name.contains(name) {
            road = image
        }
    }
    
    for (name, image) in teamLogos {
        if gamescore.home_team_name.contains(name) {
            home = image
        }
    }
    return (road, home)
}

func getDatefromBSMString(gamescore: GameScore) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "y-M-dd HH:mm:ss Z"
    
    return dateFormatter.date(from: gamescore.time)!
    //force unwrapping alert: gametime really should be a required field in BSM DB - let's see if there are crashes
    //gameDate = dateFormatter.date(from: gamescore.time)!
}

func processGameDates(gamescores: [GameScore]) -> (next: GameScore?, last: GameScore?) {
    // processing
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMdd"
    
    //for testing purposes this can be set to some date in the season, normally it's just the current date
    let now = Date()
    //let now = formatter.date(from: "20210928") ?? Date.now // September 27th, 2021 UTC
    
    var nextGames = [GameScore]()
    var previousGames = [GameScore]()

    //add game dates to all games to allow for ordering | outsourced below
    var gameList = gamescores
    
    for (index, _) in gameList.enumerated() {
        gameList[index].addDates()
    }
    
    //collect nextGames and add to array
    for gamescore in gameList where gamescore.gameDate! > now {
        nextGames.append(gamescore)
    }
    
    //Add last games to separate array and set it to be displayed
    for gamescore in gameList where gamescore.gameDate! < now {
        previousGames.append(gamescore)
    }
    
    //case: there is both a last and next game (e.g. middle of the season)
    if nextGames != [] && previousGames != [] {
        return (nextGames.first!, previousGames.last!)
    }
    
    //case: there is a previous game and no next game (e.g. season over for selected team)
    if nextGames == [] && previousGames != [] {
        return (nil, previousGames.last!)
    }
    
    //case: there is a next game and no previous game (e.g. season has not yet started for selected team)
    if nextGames != [] && previousGames == [] {
        return (nextGames.first!, nil)
    }
    
    //case: there is no game at all (error loading data, problems with async?)
    else {
        print("nothing to return, gamescores is empty")
        return (nil, nil)
    }
}

//MARK: Deprecated - use mutating func on struct

//func addDatesToGames(gamescores: [GameScore]) -> [GameScore] {
//
//    //this is used because the passed gamescores element cannot be mutated
//    var gameList = gamescores
//
//    for (index, _) in gameList.enumerated() {
//        gameList[index].gameDate = getDatefromBSMString(gamescore: gameList[index])
//        gameList[index].determineGameStatus()
//    }
//    return gameList
//}

func determineTableRow(team: BSMTeam, table: LeagueTable) -> LeagueTable.Row {
    var correctRow = emptyRow
    
    for row in table.rows where row.team_name.contains("Skylarks") {
        //we might have two teams for BZL, so the function needs to account for the correct one
        
        if team.name.contains("3") {
            if row.team_name == "Skylarks 3" {
                correctRow = row
            }
        } else if team.name.contains("4") {
            if row.team_name == "Skylarks 4" {
                correctRow = row
            }
        } else if !team.name.contains("3") && !team.name.contains("4") {
            correctRow = row
        }
    }
    return correctRow
}

//-------------------------------------------------------------------------------//
//-----------------------------------LOAD DATA-----------------------------------//
//-------------------------------------------------------------------------------//

//MARK: Generic load function that accepts any codable type

func loadBSMData<T: Codable>(url: URL, dataType: T.Type, completion: @escaping ((T) -> Void)) {
    
    let request = URLRequest(url: url)
    URLSession.shared.dataTask(with: request) { data, response, error in

        if let data = data {
            if let response_obj = try? JSONDecoder().decode(T.self, from: data) {

                DispatchQueue.main.async {
                    let loadedData = response_obj
                    completion(loadedData)
                }
            }
        }
    }.resume()
}

// new version with async/await

func fetchBSMData<T: Codable>(url: URL, dataType: T.Type) async throws -> T {
    
    let (data, _) = try await URLSession.shared.data(from: url)
    
    let responseObj = try JSONDecoder().decode(T.self, from: data)
    return responseObj
}

func loadSkylarksTeams(season: Int) async throws -> [BSMTeam] {
    
    let teamURL = URL(string:"https://bsm.baseball-softball.de/clubs/485/teams.json?filters[seasons][]=" + "\(season)" + "&sort[league_sort]=asc&api_key=" + apiKey)!
    let teams = try await fetchBSMData(url: teamURL, dataType: [BSMTeam].self)
    return teams
}

func loadLeagueGroups(season: Int) async -> [LeagueGroup] {
    
    let leagueGroupsURL = URL(string:"https://bsm.baseball-softball.de/league_groups.json?filters[seasons][]=" + "\(season)" + "&api_key=" + apiKey)!
    var loadedLeagues = [LeagueGroup]()
    
    //load all leagueGroups
    do {
       loadedLeagues = try await fetchBSMData(url: leagueGroupsURL, dataType: [LeagueGroup].self)
    } catch {
        print("Request failed with error: \(error)")
    }
    return loadedLeagues
}

func loadTableForTeam(team: BSMTeam, leagueGroups: [LeagueGroup]) async -> LeagueTable {
    var correctTable = emptyTable
    
    for leagueGroup in leagueGroups where team.league_entries[0].league.name == leagueGroup.name {
        let url = URL(string: "https://bsm.baseball-softball.de/leagues/" + "\(leagueGroup.id)" + "/table.json")!
        
        do {
            let table = try await fetchBSMData(url: url, dataType: LeagueTable.self)
            
            correctTable = table
        } catch {
            print("Request failed with error: \(error)")
        }
    }
    return correctTable
}

//-------------------------------------------------------------------------------//
//-------------------------------CALENDAR EVENTS---------------------------------//
//-------------------------------------------------------------------------------//

var calendarStrings = [String]()

func getAvailableCalendars() {
    
    let eventStore = EKEventStore()
    //var calendars = [EKCalendar]()
         
    eventStore.requestAccess(to: .event) { (granted, error) in
      
      if (granted) && (error == nil) {
          print("granted \(granted)")
          print("error \(String(describing: error))")
          
          //let event:EKEvent = EKEvent(eventStore: eventStore)
          let calendars = eventStore.calendars(for: .event)
          
          //clear the array before loading new
          calendarStrings = []
          
          for calendar in calendars {
              calendarStrings.append(calendar.title)
          }
          //print(calendars)
      }
      else {
          print("Access not granted")
      }
    }
}

#if !os(watchOS)
func addGameToCalendar(gameDate: Date, gamescore: GameScore, calendarString: String) {
    let eventStore = EKEventStore()
         
    eventStore.requestAccess(to: .event) { (granted, error) in
      
      if (granted) && (error == nil) {
          print("granted \(granted)")
          print("error \(String(describing: error))")
          
          let event:EKEvent = EKEvent(eventStore: eventStore)
          let calendars = eventStore.calendars(for: .event)
          
          event.title = "\(gamescore.league.name): \(gamescore.away_team_name) @ \(gamescore.home_team_name)"
          event.startDate = gameDate
          event.endDate = gameDate.addingTimeInterval(2 * 60 * 60)
          
          //add game location if there is data
          
          if let field = gamescore.field, let latitude = gamescore.field?.latitude, let longitude = gamescore.field?.longitude {
              
              let location = CLLocation(latitude: latitude, longitude: longitude)
              let structuredLocation = EKStructuredLocation(title: "\(field.name) - \(field.street ?? ""), \(field.postal_code ?? "") \(field.city ?? "")")
              structuredLocation.geoLocation = location
              event.structuredLocation = structuredLocation
          }
          
          event.notes = """
                League: \(gamescore.league.name)
                Match Number: \(gamescore.match_id)
                
                Field: \(gamescore.field?.name ?? "No data")
                Address: \(gamescore.field?.street ?? ""), \(gamescore.field?.postal_code ?? "") \(gamescore.field?.city ?? "")
            """
          
          for calendar in calendars where calendar.title == calendarString {
                event.calendar = calendar
          }
          //event.calendar = eventStore.defaultCalendarForNewEvents
          do {
              try eventStore.save(event, span: .thisEvent)
          } catch let error as NSError {
              print("failed to save event with error : \(error)")
          }
          print("Saved Event successfully")
      }
      else {
          print("failed to save event with error : \(String(describing: error)) or access not granted")
      }
    }
}
#endif