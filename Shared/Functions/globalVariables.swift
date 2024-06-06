//
//  AudioplayerVariables.swift
//  Soundlytude
//
//  Created by DJ bon26 on 9/20/22.
//

import Foundation
import SwiftUI
import AVKit

public struct User: Hashable, Codable {
    let _id: String
    let artistName: String
    let password: String
    let slug: String
    let email: String
    let pimage: String
}

var newlyUpdatedPfpUrl: String = ""

public var loggedInUsers: [User] = []
private let _id = local.string(forKey: "soundlytudeUserId") ?? ""
private let artistName = local.string(forKey: "currentUserArtistName") ?? ""
private let password = local.string(forKey: "currentUserPassword") ?? ""
private let slug = local.string(forKey: "currentUsername") ?? ""
private let email = local.string(forKey: "currentUserEmail") ?? ""
private let pimage = local.string(forKey: "currentUserArtistPfp") ?? ""
public var currentUser: User = User(
    _id: _id,
    artistName: artistName,
    password: password,
    slug: slug,
    email: email,
    pimage: pimage
)
//[loginUserSoundlytudeId, loginArtistName, loginPassword, loginUsername, loginUserEmail, loginArtistPfp]

//MARK: Audioplayer variables
var expandPlayer = false
var changingTrack = false
var stopPlaying = false
var changedTrack = false
var playingType: String = ""
var playingTypeTitle: String = ""
var playingId: String = ""
var songs: [playerField] = []
var currentSong: playerField = songs[0]

//MARK: Storage variable
let local = UserDefaults.standard

//MARK: Login functions
func soundlytudeUserIsLoggedIn() -> Bool {
    let soundlytudeUserId = local.string(forKey: "soundlytudeUserId")
    if (soundlytudeUserId == nil || soundlytudeUserId == "") {
        return false
    } else {
        return true
    }
}
func soundlytudeUserId() -> String {
    let soundlytudeUserId = local.string(forKey: "soundlytudeUserId")
    if (soundlytudeUserId == nil || soundlytudeUserId == "") {
        return ""
    } else {
        return soundlytudeUserId ?? ""
    }
}

class globalVariables: ObservableObject {
    @Published var isTrackPlaying: Bool = false
    @Published public var time = 0.0
    @Published public var duration = 0.0
    @Published var hideMiniPlayerView: Bool = false
    @Published var offset = viewableWidth
    @Published var hideTabBar = false
    @Published var chatView: AnyView = AnyView(EmptyView())
    @Published var goBack: goBackField = goBackField(goBack: false, page: "")
    
    @Published var homeExited: Bool = false
    @Published var profilePageExited: Bool = false
}

public struct goBackField: Hashable, Codable {
    let goBack: Bool
    let page: String
}
///Webview global variables
public class webviewVariables: ObservableObject {
    static var isFullscreen: Bool = false
    @Published var isMaximized = false
    @Published var useMaximized = false
    @Published var url: URL = URL(string: "https://lytudeyt2url.netlify.app/player.html?url=9F53UQ_2L_I&poster=https://i.ytimg.com/vi/jY784EZ_XDk/sddefault.jpg")!
}

var globalPaddingBottom = 70.0

class SoundManager1 : ObservableObject {
    var audioPlayer: AVPlayer?
    
    func playSound(sound: String){
        if let url = URL(string: sound) {
            self.audioPlayer?.automaticallyWaitsToMinimizeStalling = false
            self.audioPlayer = AVPlayer(url: url)
//            self.audioPlayer?.playImmediately(atRate: 2)
        }
    }
}

class SoundManager2 : ObservableObject {
    var audioPlayer: AVPlayer?
    
    func playSound(sound: String){
        if let url = URL(string: sound) {
            self.audioPlayer = AVPlayer(url: url)
        }
    }
}
class SoundManager0 : ObservableObject {
    var audioPlayer: AVPlayer?
    
    func playSound(sound: String){
        if let url = URL(string: sound) {
            self.audioPlayer = AVPlayer(url: url)
        }
    }
}

class CustomColorScheme: ObservableObject {
    @Published var customColorScheme: String = local.string(forKey: "colorScheme") ?? "0"
}





var initialized = false
var audioPlayerCurrentIndex = 0
//
//  AudioPlayer.swift
//
//  Created by MDobekidis
//
