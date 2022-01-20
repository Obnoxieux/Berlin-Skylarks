//
//  GlobalScoresFunctions.swift
//  Berlin Skylarks
//
//  Created by David Battefeld on 19.10.21.
//

import Foundation
import EventKit
import SwiftUI

var away_team_logo = Image("App_road_team_logo")
var home_team_logo = Image("App_home_team_logo")

let teamLogos = [
    "Skylarks": Image("Bird_whiteoutline"),
    "Roosters": Image("Roosters_Logo"),
    "Sluggers": Image("Sluggers_Logo"),
    "Eagles": Image("Mahlow-Eagles_Logo"),
    "Ravens": Image("ravens_logo"),
    "Porcupines": Image("potsdam_logo"),
    "Sliders": Image("Sliders_Rund_2021"),
    "Flamingos": Image("Berlin_Flamingos_Logo_3D"),
    "Challengers": Image("challengers_Logo"),
    "Rams": Image("Rams-Logo"),
    "Wizards": Image("Wizards_Logo"),
    "Poor Pigs": Image("Poorpigs_Logo"),
    "Dukes": Image("Dukes_Logo"),
    "Roadrunners": Image("Roadrunners_Logo"),
    "Dragons": Image("Dragons_Logo"),
]

var skylarksAreHomeTeam = false
var skylarksWin = false
var isDerby = false

var gameDate: Date?

func determineGameStatus(gamescore: GameScore) {
    if gamescore.home_team_name.contains("Skylarks") && !gamescore.away_team_name.contains("Skylarks") {
        skylarksAreHomeTeam = true
        isDerby = false
    } else if gamescore.away_team_name.contains("Skylarks") && !gamescore.home_team_name.contains("Skylarks") {
        skylarksAreHomeTeam = false
        isDerby = false
    }
    if gamescore.away_team_name.contains("Skylarks") && gamescore.home_team_name.contains("Skylarks") {
        isDerby = true
    }
    if skylarksAreHomeTeam && !isDerby {
        if let awayScore = gamescore.away_runs, let homeScore = gamescore.home_runs {
            if homeScore > awayScore {
                skylarksWin = true
            }
            if homeScore < awayScore {
                skylarksWin = false
            }
        }
    } else if !skylarksAreHomeTeam && !isDerby {
        if let awayScore = gamescore.away_runs, let homeScore = gamescore.home_runs {
            if homeScore > awayScore {
                skylarksWin = false
            }
            if homeScore < awayScore {
                skylarksWin = true
            }
        }
    }
}

//TODO: this is the old func with global variables, gradually replace with func below that works with locals!

func setCorrectLogo(gamescore: GameScore) {
    for (name, image) in teamLogos {
        if gamescore.away_team_name.contains(name) {
            away_team_logo = image
        }
    }
    
    for (name, image) in teamLogos {
        if gamescore.home_team_name.contains(name) {
            home_team_logo = image
        }
    }
}

//NEW

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

//func addGameDatesToGamescores(gamescore: GameScore) -> GameScore {
//
//    return gamescore.gameDate = getDatefromBSMString(gamescore: gamescore)
//}

//-------------------------------CALENDAR EVENTS---------------------------------//

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

//-------------------------load Scores---------------------------------//

//MARK: first try to get this functionality reusable
//added completion handler on Jan 20, must be tested

func loadGameScoreData(url: URL, completion: @escaping (([GameScore]) -> Void)) {
    var gamescores = [GameScore]()
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let data = data {
                if let response_obj = try? JSONDecoder().decode([GameScore].self, from: data) {
                    
                    DispatchQueue.main.async {
                        gamescores = response_obj
                        completion(gamescores)
                    }
                }
            }
        }.resume()
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
          
          event.title = gamescore.league.name + ": " + gamescore.away_team_name + " @ " + gamescore.home_team_name
          event.startDate = gameDate
          event.endDate = gameDate.addingTimeInterval(2 * 60 * 60)
          event.notes = gamescore.match_id
          //add more info
          
          for calendar in calendars {
              if calendar.title == calendarString {
                  event.calendar = calendar
              }
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
