//
//  commentDetailAlbumView.swift
//  Soundlytude (iOS)
//
//  Created by DJ bon26 on 7/17/23.
//

import SwiftUI

struct commentDetailAlbumView: View {
    @State var _id: String = currentViewingAlbum._id
    @State var title: String = currentViewingAlbum.title
    @State var artistName: String = currentViewingAlbum.artistDetails.artistName
    @State var artistId: String = currentViewingAlbum.artistDetails._id
    @State var coverArt: String = currentViewingAlbum.coverArt ?? ""
    @State var themeColor: String = currentViewingAlbum.themeColor ?? "000000"
    
    @State var albumPageIsActive: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing:10){
            VStack{
                AsyncImage(url: URL(string: "\(coverArt)/v1/fill/w_64,h_64,al_c/Soundlytude.jpg")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .background (Color.gray)
                        .scaledToFit()
                    
                } placeholder: {
                    Image("Soundlytude empty placeHolder")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .opacity(0.5)
                }
                .frame(width: 40, height: 40)
                .cornerRadius(10)
                Capsule()
                    .foregroundColor(Color.secondarySystemFill)
                    .frame(maxWidth: 2, maxHeight: .infinity)
                    .cornerRadius(5)
            }
            VStack(alignment: .leading){
                Text(title)
                    .fontWeight(.bold)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(artistName)
                    .foregroundColor(Color.gray)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }.padding(.bottom, 10)
        }
        .padding(.horizontal, 15)
        .padding(.top, 10)
//        .onTapGesture {
//            albumPageIsActive = true
//        }
//        .background(
//            Color(hexStringToUIColor(hex: "#\(themeColor.replacingOccurrences(of: "#", with: ""))")).opacity(0.1)
//                .mask(
//                    LinearGradient(colors:[
//                        .black,
//                        .clear], startPoint: .top, endPoint: .bottom))
//        )
//        .background(
//            NavigationLink(destination: albumPage(albumId: _id, artistId: artistId), isActive: $albumPageIsActive) {
//                EmptyView()
//            }.hidden()
//        )
            
    }
}

struct commentDetailAlbumView_Previews: PreviewProvider {
    static var previews: some View {
        commentDetailAlbumView()
    }
}
