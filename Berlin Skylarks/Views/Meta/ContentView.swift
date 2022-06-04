//
//  ContentView.swift
//  Berlin Skylarks
//
//  Created by David Battefeld on 23.12.20.
//

import SwiftUI
import CoreData

#if !os(watchOS)
import WidgetKit
#endif

struct ContentView: View {
    
    @State private var showingSheetOnboarding = false
    
    @AppStorage("didLaunchBefore") var didLaunchBefore = false
    
    @AppStorage("selectedSeason") var selectedSeason = Calendar(identifier: .gregorian).dateComponents([.year], from: .now).year!
    
//    @Environment(\.managedObjectContext) private var viewContext
//
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
//        animation: .default)
//    private var items: FetchedResults<Item>
    
    func checkForOnboarding() {
        if didLaunchBefore == false {
            showingSheetOnboarding = true
            //didLaunchBefore = true
        }
    }
    
    var body: some View {
        
        //iPhone/iPad/Mac
        
        #if !os(watchOS)
        //the interface on iPhone uses a tab bar at the bottom
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            TabView {
                NavigationView {
                    UserHomeView()
                }
                //TODO: check appearance for iPhone Pro Max
                .navigationViewStyle(.automatic)
                    .tabItem {
                        Image(systemName: "star.square.fill")
                        Text("Home")
                    }
                //since News is non-functional right now, let's rather have the settings back in the tab bar
//                NavigationView {
//                    NewsView()
//                }
//                    .tabItem {
//                        Image(systemName: "newspaper.fill")
//                        Text("News")
//                    }
                NavigationView {
                    ScoresView()
                }
                    .tabItem {
                        Image(systemName: "42.square.fill")
                        Text("Scores")
                    }
                NavigationView {
                    StandingsView()
                }
                    .tabItem {
                        Image(systemName: "tablecells.fill")
                        Text("Standings")
                    }
                NavigationView {
                    TeamListView()
                }
                    .tabItem {
                        Image(systemName: "person.3.fill")
                        Text("Teams")
                    }
                NavigationView {
                    SettingsListView()
                }
                    .tabItem {
                        Image(systemName: "gearshape.fill")
                        Text("Settings")
                    }
            }
            .onAppear(perform: {
                checkForOnboarding()
                WidgetCenter.shared.reloadAllTimelines()
            })
            .sheet( isPresented: $showingSheetOnboarding, onDismiss: {
                didLaunchBefore = true
            }) {
                UserOnboardingView()
            }
        }
            
        //on iPad and macOS we use a sidebar navigation to make better use of the ample space
        
        if UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac {
            SidebarNavigationView()
                .onAppear(perform: {
                    checkForOnboarding()
                    WidgetCenter.shared.reloadAllTimelines()
                })
                .sheet( isPresented: $showingSheetOnboarding, onDismiss: {
                    didLaunchBefore = true
                }) {
                    UserOnboardingView()
                }
        }
        
        #endif
        
        //Apple Watch
        
        #if os(watchOS)
        NavigationView {
            List {
                NavigationLink(
                    destination: UserHomeView()){
                        HStack {
                            Image(systemName: "star")
                                .foregroundColor(Color.accentColor)
                            Text("Favorite Team")
                        }
                    }
//                HStack {
//                    Image(systemName: "newspaper")
//                        .foregroundColor(Color.accentColor)
//                    Text("News")
//                }
                NavigationLink(
                    destination: ScoresView()) {
                        HStack {
                            Image(systemName: "42.square")
                                .foregroundColor(Color.accentColor)
                            Text("Scores")
                        }
                    }
                NavigationLink(
                    destination: StandingsView()) {
                        HStack {
                            Image(systemName: "tablecells")
                                .foregroundColor(Color.accentColor)
                            Text("Standings")
                        }
                    }
                
//                HStack {
//                    Image(systemName: "person.3")
//                        .foregroundColor(Color.accentColor)
//                    Text("Players")
//                }
                NavigationLink(
                    destination: SettingsListView()) {
                        HStack {
                            Image(systemName: "gearshape")
                                .foregroundColor(Color.accentColor)
                            Text("Settings")
                        }
                    }
                    
            }
            .navigationTitle("Home")
            //TODO: needs to get favorite team info as well, either from parent app or via own view
            .onAppear(perform: {
                checkForOnboarding()
            })
            .sheet( isPresented: $showingSheetOnboarding, onDismiss: {
                didLaunchBefore = true
            }) {
                UserOnboardingView()
                    .navigationBarHidden(true)
            }
        }
        #endif
    }
}

//preview settings

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
//                .padding(0.0).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                //.previewInterfaceOrientation(.landscapeLeft)
        }
    }
}