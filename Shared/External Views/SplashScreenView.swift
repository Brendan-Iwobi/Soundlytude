//
//  SplashScreenView.swift
//  SplashScreen
//
//  Created by Federico on 20/01/2022.
//
import SwiftUI

var viewableHeight: Double = 0
var viewableWidth: Double = 0

struct SplashScreenView: View {
    @State var isActive : Bool = false
    @State private var size = 1.0
    @State private var opacity = 0.0
    
    // Customise your SplashScreen here
    var body: some View {
        if isActive {
            if soundlytudeUserIsLoggedIn() {
                ContentView()
            }else{
                loginPage()
            }
        } else {
            ZStack{
                Background(backgroundColor: "AccentColorSchemedBlack", type: "Accent")
                VStack {
                    VStack {
                        Image("Soundlytude favicon")
                            .resizable()
                            .aspectRatio(1.0, contentMode: .fit)
                            .frame(width: 96, height: 96)
                    }
                    .scaleEffect(size)
                    .opacity(opacity)
                    .onAppear {
                        if let data = local.data(forKey: "LoggedInUsers") {
                            let array = try! PropertyListDecoder().decode([User].self, from: data)
                            DispatchQueue.main.async{
                                loggedInUsers = array
                                print("loggedIusers", loggedInUsers)
                                newlyUpdatedPfpUrl = local.string(forKey: "currentUserArtistPfp") ?? ""
                            }
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                            withAnimation(.easeIn(duration: 0.1)) {
                                self.opacity = 1.0
                            }
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation(.easeIn(duration: 0.6)) {
                                self.size = 50
                            }
                            withAnimation(.easeIn(duration: 0.3)) {
                                self.opacity = 0.0
                            }
                        }
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.easeIn(duration: 1)) {
                            self.isActive = true
                        }
                    }
                }
            }
            .overlay(
                GeometryReader { geo in
                    Text("")
                        .onAppear{
                            withAnimation(.spring()){
                                viewableHeight = geo.size.height
                                viewableWidth = geo.size.width
                            }
                        }
                        .onChange(of: geo.size) { newSize in
//                                print
                        }
                }
            )
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}
