//
//  Youtube player.swift
//  Soundlytude (iOS)
//
//  Created by DJ bon26 on 1/18/23.
//

import SwiftUI
import Foundation
import SwiftUIYouTubePlayer

struct YouTubeTest: View {
    @State private var action = YouTubePlayerAction.idle
    @State private var state = YouTubePlayerState.empty
    
    private var buttonText: String {
        switch state.status {
        case .playing:
            return "Pause"
        case .unstarted,  .ended, .paused:
            return "Play"
        case .buffering, .queued:
            return "Wait"
        }
    }
    private var infoText: String {
        "Q: \(state.quality)"
    }
    
    var body: some View {
        VStack {
            HStack {
                Button("Load") {
                    action = .loadURL(URL(string:"https://www.youtube.com/embed/0yystgocrw8?modestbranding=1&controls=0&autoplay=1")!)
                }
                Button(buttonText) {
                    if state.status != .playing {
                        action = .play
                    } else {
                        action = .pause
                    }
                }
                Text(infoText)
                Button("Prev") {
                    action = .previous
                }
                Button("Next") {
                    action = .next
                }
            }
            YouTubePlayer(action: $action, state: $state, config: .init(playInline: true))
                .aspectRatio(16/9, contentMode: .fit)
            Spacer()
        }
        .onAppear{
            let videoId = "iRQbqz3nmxo" // your youtube video id here
            extractVideos(from: videoId) { (dic) -> (Void) in
                
                // dic is a Dictionary of available video quality
                // the url of the video with hd720 quality (if available) is : dic["hd720"]
                // to print all available qualities use :
                print(dic.keys)
                
                // use dic here
            }
        }
    }
}

