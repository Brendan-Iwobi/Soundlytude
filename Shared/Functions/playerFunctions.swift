//
//  playerFunctions.swift
//  Soundlytude
//
//  Created by DJ bon26 on 10/1/22.
//

import Foundation
import SwiftUI
import MediaPlayer

class globalVariable: ObservableObject {
    @Published var isTrackPlaying:Bool = false
}

class player: ObservableObject {
    var soundManager = SoundManager1()
    @State var set = false
    let commandCenter = MPRemoteCommandCenter.shared()
    
    func playSound(url: String, title: String, albumArtwork: String, artist: String, isExplicit: Bool, rate: Float) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options:
                    .init(rawValue: 0))
            try AVAudioSession.sharedInstance().setActive(true)
            if set{
            }else{
                self.soundManager.playSound(sound: url)
                set.toggle()
            }
            globalVariable().isTrackPlaying.toggle()
            
            if globalVariable().isTrackPlaying {
                soundManager.audioPlayer?.play()
                setupNowPlaying(
                    title: title,
                    albumArtwork: albumArtwork,
                    artist: artist,
                    isExplicit: isExplicit,
                    rate: rate,
                    duration: CMTimeGetSeconds(soundManager.audioPlayer?.currentItem?.asset.duration ?? CMTime(seconds: 0, preferredTimescale: 0))
                )
                UIApplication.shared.beginReceivingRemoteControlEvents()
                MPNowPlayingInfoCenter.default().playbackState = .playing
            } else {
                soundManager.audioPlayer?.pause()
            }
        }catch{
            print("Someting came up")
        }
    }
    
    func setupNowPlaying(title: String, albumArtwork: String, artist:String, isExplicit: Bool, rate: Float, duration: Any) {
        let url = URL.init(string: albumArtwork)!
        let mpic = MPNowPlayingInfoCenter.default()
        func setup(){
            DispatchQueue.global().async {
                if let data = try? Data.init(contentsOf: url), let image = UIImage(data: data) {
                    let artwork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { (_ size : CGSize) -> UIImage in
                        return image
                    })
                    DispatchQueue.main.async {
                        mpic.nowPlayingInfo = [
                            MPMediaItemPropertyTitle: title,
                            MPMediaItemPropertyArtist: artist,
                            MPMediaItemPropertyArtwork:artwork,
                            MPMediaItemPropertyIsExplicit: isExplicit,
                            MPNowPlayingInfoPropertyElapsedPlaybackTime: self.soundManager.audioPlayer?.currentTime().seconds ?? 0,
                            MPNowPlayingInfoPropertyPlaybackRate: self.soundManager.audioPlayer?.rate ?? 0,
                            MPMediaItemPropertyPlaybackDuration: CMTimeGetSeconds(self.soundManager.audioPlayer?.currentItem?.asset.duration ?? CMTime(seconds: 0, preferredTimescale: 0))
                        ]
                    }
                }
            }
        }
        setup()
        commandCenter.pauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.soundManager.audioPlayer?.pause()
            globalVariable().isTrackPlaying.toggle()
            setup()
            return .success
        }
        commandCenter.playCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.soundManager.audioPlayer?.play()
            globalVariable().isTrackPlaying.toggle()
            setup()
            return .success
        }
        commandCenter.togglePlayPauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            if globalVariable().isTrackPlaying {
                self.soundManager.audioPlayer?.play()
                setup()
                globalVariable().isTrackPlaying.toggle()
            } else {
                self.soundManager.audioPlayer?.pause()
                setup()
                globalVariable().isTrackPlaying.toggle()
            }
            return .success
        }
        
        commandCenter.changePlaybackPositionCommand.addTarget(handler: {
            (event) in
            let event = event as! MPChangePlaybackPositionCommandEvent
            self.soundManager.audioPlayer?.seek(to: CMTimeMakeWithSeconds(event.positionTime, preferredTimescale: 1000000))
            setup()
            return MPRemoteCommandHandlerStatus.success
        })
        
    }
}
