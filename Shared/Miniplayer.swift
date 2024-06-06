//
//  Miniplayer.swift
//  Soundlytude
//
//  Created by DJ bon26 on 9/20/22.
//

import SwiftUI

struct Miniplayer: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var settings = globalVariables()
    
    var body: some View {
            HStack{
                Image("Pull up at the mansion by DJ bon26")
                    .resizable()
                    .frame(width: 48, height: 48)
                    .scaledToFill()
                    .cornerRadius(5)
                HStack {
                    Text("Pull up at the mansion")
                        .foregroundColor(Color("BlackWhite"))
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .font(.callout)
                    Spacer()
                }
                .frame(width: viewableWidth - 190)
                Spacer()
            }
            .environmentObject(settings)
            .padding(.horizontal, 10)
        .overlay {
            HStack{
                Spacer()
                Button {
                    if settings.isTrackPlaying {
                        settings.isTrackPlaying = false
                    }else{
                        settings.isTrackPlaying = true
                    }
                } label: {
                    Image(systemName: (settings.isTrackPlaying) ? "pause.fill" : "play.fill")
                        .font(.system(size: 25))
                        .foregroundColor((settings.isTrackPlaying) ? Color.accentColor : Color("BlackWhite"))
                }
                .padding([.top, .leading, .bottom])
                Spacer()
                    .frame(width: 20)
                Button {
                    //skip
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 25))
                        .foregroundColor(Color("BlackWhite"))
                }.padding([.top, .bottom])
            }
            .padding(.horizontal)
            .environmentObject(settings)
        }.environmentObject(settings)
    }
}

struct Miniplayer_Previews: PreviewProvider {
    static var previews: some View {
        Miniplayer()
    }
}
