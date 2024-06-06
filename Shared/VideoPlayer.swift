//
//  VideoPlayer.swift
//  Soundlytude (iOS)
//
//  Created by DJ bon26 on 1/18/23.
//

import SwiftUI
import Foundation
import AVKit
import MediaPlayer 

struct videoPlayerView: View {
    @State var url: String = ""
    var body: some View {
        VStack{
            let url2: URL = URL(string: url)!
            VideoPlayer(player: AVPlayer(url: url2)) {
                VStack {
                    Text("Watermark")
                        .foregroundColor(.black)
                        .background(.white.opacity(0.7))
                    Spacer()
                }
                .frame(width: 400, height: 300)
            }
            .onAppear{
                print("YouTube video: ", url2)
            }
        }
    }
}

struct videoPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        videoPlayerView()
    }
}
