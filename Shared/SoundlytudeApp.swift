//
//  SoundlytudeApp.swift
//  Shared
//
//  Created by DJ bon26 on 9/2/22.
//

import SwiftUI

@main
struct SoundlytudeApp: App {
    @StateObject var appState = AppState.shared
    @Environment(\.colorScheme) var colorScheme
    @StateObject var customColorScheme = CustomColorScheme()
    
    var customColorSchemeConverted: ColorScheme? {
        if customColorScheme.customColorScheme == "0"{
            return nil
        }else{
            if customColorScheme.customColorScheme == "1"{
                return .light
            }
            if customColorScheme.customColorScheme == "2"{
                return .dark
            }
        }
        return nil
    }
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .navigationViewStyle(StackNavigationViewStyle())
                .environmentObject(customColorScheme)
                .preferredColorScheme(customColorSchemeConverted)
                .id(appState.soundlytudeId)
        }
    }
}

class AppState: ObservableObject {
    static let shared = AppState()

    @Published var soundlytudeId = UUID()
}
