//
//  Sticker.swift
//  Soundlytude (iOS)
//
//  Created by DJ bon26 on 11/25/22.
//

import SwiftUI
import UniformTypeIdentifiers

struct Sticker: View {
    var text: String = "Text"
    var body: some View {
        if text != ""{
            VStack{
                Text(text)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                    .padding(2.5)
                    .padding(.horizontal, 2.5)
                    .lineLimit(1)
            }.background(Color.gray.opacity(0.25))
                .cornerRadius(2.5)
        }
        EmptyView()
    }
}


struct playerQueue3: View {
    
    var body: some View {
        VStack(spacing:0){
            List(){ // Arrageable list
                Spacer()
                    .frame(height: 5)
                    .listRowBackground(Color.accentColor.opacity(0))
                    .listRowSeparator(.hidden)
                ForEach(songs, id: \._id){ i in
                    Button {
                        //
                    } label: {
                        HStack{
                            if playingType == "Playlist"{
                                squareImage48by48(urlString: i.albumReference.coverArt)
                            }
                            HStack{
                                VStack(alignment: .leading){
                                    Text(i.tracktitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color("BlackWhite"))
                                        .lineLimit(3)
                                    Text(i.artistDetails.artistName)
                                        .font(.caption)
                                        .fontWeight(.regular)
                                        .foregroundColor(Color.white.opacity(0.5))
                                        .lineLimit(1)
                                }
                                Spacer()
                                Image(systemName: "line.3.horizontal")
                                    .foregroundColor(Color.white.opacity(0.5))
                            }
                        }
                    }
                    .listRowBackground((i._id == currentSong._id) ? Color.accentColor.opacity(0.4) : Color.accentColor.opacity(0.1))
                    .listRowInsets(EdgeInsets())
                    .padding(10)
                    .listRowSeparator(.hidden)
                }
                .onMove( perform: { IndexSet, Int in
                    songs.move(fromOffsets: IndexSet, toOffset: Int)
                })
                Text("Hold and drag to rearrange")
                    .font(.caption)
                    .foregroundColor(Color.white.opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color.accentColor.opacity(0.5))
                    .listRowSeparator(.hidden)
            }
            .listStyle(PlainListStyle())
        }
        .padding(0)
        .environment(\.colorScheme, .dark)
    }
}

struct Sticker_Previews: PreviewProvider {
    static var previews: some View {
        Sticker()
    }
}
