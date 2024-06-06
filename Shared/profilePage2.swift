//
//  profilePage2.swift
//  Soundlytude (iOS)
//
//  Created by DJ bon26 on 11/26/22.
//

import SwiftUI

struct profilePage2: View {
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var artistPageFetch = artistPageFetchData()
    @StateObject var artistPageFetchUpload = artistPageFetchUploadData()
    @StateObject var artistPageFetchPlaylist = artistPageFetchPlaylistData()
    @StateObject var artistPageFetchPLD = artistPageFetchPLDData()
    
    @State var currentType: String = "square.and.arrow.up"
    @Namespace var animation
    @State var headerOffsets: (CGFloat, CGFloat) = (0,0)
    @State private var showingAlert = false
    @State var artistId: String = soundlytudeUserId() /*"0fd70b92-e4cf-4e21-b522-4ec5a22b35f1"*/
    @State var isDoneLoading: Bool = false
    @State private var presentAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    
    @State var settingsLinkActivated: Bool = false
    @State var reloadingCompleted: Bool = false
    @State var showLoading: Bool = false
    
    @StateObject var CurrentUserAccInfo = currentUserAccInfo()
    var body: some View {
        if isDoneLoading {
            NavigationView{
                ForEach(artistPageFetch.artistPageFields, id: \._id){ artist in
                    ZStack{
                        Color(hexStringToUIColor(hex: "#\(artist.themeColor ?? "000000")")).opacity(0.25)
                        VStack{
                            ScrollView {
                                bannerImage(
                                    artistId: artist._id,
                                    artistName: artist.artistName,
                                    verification: artist.verification ?? false,
                                    slug: artist.slug,
                                    miniBio: artist.miniBiography,
                                    followerCount: artist.followerCount,
                                    followingCount: artist.followingCount,
//                                    followerCount: artist.followers?.count ?? 0,
//                                    followingCount: artist.following?.count ?? 0,
                                    themeColor: artist.themeColor ?? "000000",
                                    isFollowing: artist.verified,
                                    urlString: artist.pimage
                                )
                                .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y:5)
                                LazyVStack(pinnedViews: [.sectionHeaders]){
                                    Section {
                                        ScrollView{
                                            VStack{/* dummy VStack */}.frame(height: 10)
                                            if currentType == "square.and.arrow.up" {
                                                if artistPageFetchUpload.artistPageFetchUploadFields.count < 1 {
                                                    noItemsView(
                                                        title: "No uploads yet",
                                                        message: "Musics uploaded by \(artist.artistName) will appear here").padding(.bottom, 40)
                                                }
                                                ForEach(0..<artistPageFetchUpload.artistPageFetchUploadFields.count, id: \.self){i in
                                                    if i == (self.artistPageFetchUpload.artistPageFetchUploadFields.count - 1){
                                                        verticalUploadView(
                                                            artistId: artistId,
                                                            data: self.artistPageFetchUpload.artistPageFetchUploadFields[i],
                                                            isLast: true,
                                                            listData: self.artistPageFetchUpload
                                                        )
                                                    }else{
                                                        verticalUploadView(
                                                            artistId: artistId,
                                                            data: self.artistPageFetchUpload.artistPageFetchUploadFields[i],
                                                            isLast: false,
                                                            listData: self.artistPageFetchUpload
                                                        )
                                                    }
                                                }
                                            }
                                            if currentType == "heart" {
                                                if artistPageFetchPLD.artistPageFetchPLDFields.count < 1 {
                                                    noItemsView(
                                                        title: "No Favorites yet",
                                                        message: "Musics and playlists liked by \(artist.artistName) will appear here").padding(.bottom, 40)
                                                }
                                                ForEach(0..<artistPageFetchPLD.artistPageFetchPLDFields.count, id: \.self){i in
                                                    if i == (self.artistPageFetchPLD.artistPageFetchPLDFields.count - 1){
                                                        verticalFavoriteView(
                                                            artistId: artistId,
                                                            data: self.artistPageFetchPLD.artistPageFetchPLDFields[i],
                                                            isLast: true,
                                                            listData: self.artistPageFetchPLD
                                                        )
                                                    }else{
                                                        verticalFavoriteView(
                                                            artistId: artistId,
                                                            data: self.artistPageFetchPLD.artistPageFetchPLDFields[i],
                                                            isLast: false,
                                                            listData: self.artistPageFetchPLD
                                                        )
                                                    }
                                                }
                                            }
                                            if currentType == "music.note.list" {
                                                if artistPageFetchPlaylist.artistPageFetchPlaylistFields.count < 1 {
                                                    noItemsView(
                                                        title: "No playlists yet",
                                                        message: "Playlists created by \(artist.artistName) will appear here").padding(.bottom, 40)
                                                }
                                                ForEach(0..<artistPageFetchPlaylist.artistPageFetchPlaylistFields.count, id: \.self){i in
                                                    if i == (self.artistPageFetchPlaylist.artistPageFetchPlaylistFields.count - 1){
                                                        verticalPlaylistView(
                                                            artistId: artistId,
                                                            data: self.artistPageFetchPlaylist.artistPageFetchPlaylistFields[i],
                                                            isLast: true,
                                                            listData: self.artistPageFetchPlaylist
                                                        )
                                                    }else{
                                                        verticalPlaylistView(
                                                            artistId: artistId,
                                                            data: self.artistPageFetchPlaylist.artistPageFetchPlaylistFields[i],
                                                            isLast: false,
                                                            listData: self.artistPageFetchPlaylist
                                                        )
                                                    }
                                                }
                                            }
                                            if currentType == "info.square" {
                                                verticalInfoView(
                                                    label: artist.label ?? "None",
                                                    genre: artist.genre ?? "None",
                                                    age: artist.age ?? "None",
                                                    biography: artist.about ?? "None")
                                            }
                                            VStack{/* dummy VStack */}.frame(height: 40)
                                        }
                                    } header: {
                                        ZStack{
                                            Blur(style: (colorScheme == .dark) ? .dark : .light)
                                                .frame(width: viewableWidth)
                                            VStack{
                                                PinnedHeaderView()
                                            }
                                        }
                                        .frame(width: viewableWidth - 40)
                                        .cornerRadius(20)
                                        .zIndex(1)
                                        .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y:5)
                                        .padding(.top, 10)
                                    }
                                }
                                bottomSpace()
                            }
                        }.toolbar{
                            ToolbarItem(placement: .navigation){
                                Button {
                                    opener()
                                } label: {
                                    if showLoading {
                                        ProgressView()
                                    }else{
                                        Text(Image(systemName: "line.3.horizontal")).fontWeight(.bold)
                                            .shadow(radius: 10)
                                    }
                                }
                                .background(
                                    NavigationLink(destination: settings(), isActive: $settingsLinkActivated) {
                                        EmptyView()
                                    }
                                        .hidden()
                                ).padding(.vertical)
                            }
                        }
                    }
                    .onAppear{
                        artistPageFetch.fetch(artistId: artistId)
                        artistPageFetchUpload.fetchUpdate(artistId: artistId)
                        artistPageFetchPlaylist.fetchUpdate(artistId: artistId, itemId: "x")
                        artistPageFetchPLD.fetchUpdate(artistId: artistId, itemId: "x")
                    }
                    .tint(Color(hexStringToUIColor(hex: "#\(artist.themeColor ?? "000000")")))
                    .accentColor(Color(hexStringToUIColor(hex: "#\(artist.themeColor ?? "000000")")))
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle(artist.artistName)
                }
            }
        } else {
            VStack{
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.accentColor))
                    .onAppear{
                        ArtistPageFetchingCompleted = false
                        progresser()
                        artistPageFetch.fetch(artistId: artistId)
                        artistPageFetchUpload.fetchUpdate(artistId: artistId)
                        artistPageFetchPlaylist.fetchUpdate(artistId: artistId, itemId: "x")
                        artistPageFetchPLD.fetchUpdate(artistId: artistId, itemId: "x")
                    }
            }
            .alert(alertTitle, isPresented: $presentAlert, actions: {
                // actions
            }, message: {
                Text(alertMessage)
            })
            .toolbar{
                ToolbarItem(placement: .navigation){
                    Text("Artist")
                        .font(.headline)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .frame(width: viewableWidth - 40)
                }
            }
        }
    }
    
    @ViewBuilder
    func PinnedHeaderView() -> some View{
        let types: [String] = ["square.and.arrow.up", "heart", "music.note.list", "info.square"]
        ScrollView(.horizontal, showsIndicators: false){
            HStack(spacing: 0) {
                ForEach(types, id: \.self){type in
                    VStack(){
                        Spacer()
                        Image(systemName: type)
                            .font(.system(size: 20))
                            .frame(width: 40, height: 30)
                            .foregroundColor((currentType == type) ? (colorScheme == .dark) ? .white : .black : .gray)
                        
                        ZStack{
                            if type == currentType {
                                RoundedRectangle(cornerRadius: 4, style: .continuous)
                                    .fill(Color.accentColor)
                                    .frame(width: 75)
                                    .matchedGeometryEffect(id: "TAB", in: animation)
                            }else{
                                RoundedRectangle(cornerRadius: 4, style: .continuous)
                                    .fill(.clear)
                                    .frame(width: 75)
                            }
                        }.frame(height: 3)
                    }
                    .contentShape(Rectangle())
                    .frame(height: 50)
                    .onTapGesture {
                        withAnimation(.easeInOut){
                            currentType = type
                        }
                    }
                }
            }
        }
        .frame(maxWidth: 300)
    }
    
    func progresser() {
        if(ArtistPageFetchingCompleted){
            print("done")
            isDoneLoading = true
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                progresser()
                if (ArtistPageFetchingCompleted == false){
                    isDoneLoading = false
                }
            }
        }
    }
    
    func opener() {
        if(ArtistPageFetchingCompleted){
            settingsLinkActivated = true
            showLoading = false
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                opener()
                if (ArtistPageFetchingCompleted == false){
                    settingsLinkActivated = false
                    showLoading = true
                }
            }
        }
    }
}

struct profilePage2_Previews: PreviewProvider {
    static var previews: some View {
        profilePage2()
    }
}
