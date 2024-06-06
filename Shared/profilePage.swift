//
//  profilePage.swift
//  Soundlytude (iOS)
//
//  Created by DJ bon26 on 7/26/23.
//

import SwiftUI

struct profilePage: View {
    @EnvironmentObject var globalVariable: globalVariables
    
    @StateObject var getArtistPage = artistPageFetchData()
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var ColorScheme
    
    @State var isDoneLoading: Bool = false
    @State var isDoneRefreshing: Bool = false
    @State var initArtistPageLoadError: Bool = false
    
    @State private var presentAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    
    @State var artistId: String = soundlytudeUserId()
    @State var currentArtistId: String = soundlytudeUserId()
    @State var navigatedTo: Bool = false
    @State var artistName: String = "-"
    @State var themeColor: String = "7099ff"
    
    @State var settingsLinkActivated: Bool = false
    @State var reloadingCompleted: Bool = false
    @State var showLoading: Bool = false
    
    @State var firstTime: Bool = true
    @State var refreshing: Int = 0
    @State var isStillRefreshing: Bool = false
    
    var accentColorMix: Color {
        return Color(UIColor.blend(color1: UIColor(Color(hexStringToUIColor(hex: "#\(themeColor.replacingOccurrences(of: "#", with: ""))"))), intensity1: 0.8, color2: UIColor(ColorScheme == .dark ? Color.white : Color.black), intensity2: 0.2))
    }
    
    var body: some View {
        let profilePageView =
        ZStack(alignment: .top){
            VStack(){
                Spacer()
                    .frame(height: 40)
                if isDoneLoading {
                    if initArtistPageLoadError {
                        tapToRetryView(title: "Could not load this profile page at the moment")
                            .onTapGesture {
                                Task{
                                    do{
                                        try await getArtistPage.fetch2(limit: 1, action: "load", artistId: artistId, previouslyFetched: getArtistPage.artistPageFields)
                                        isDoneLoading = true
                                        print(getArtistPage)
                                        initArtistPageLoadError = false
                                    }catch{
                                        isDoneLoading = true
                                        initArtistPageLoadError = true
                                        print(error._code)
                                    }
                                }
                            }
                    }else {
                        ScrollView{
                            Spacer()
                                .frame(height: 25)
                            ForEach(getArtistPage.artistPageFields, id: \._id){ artist in
                                if getArtistPage.artistPageFields.count > 0 && getArtistPage.artistPageFields[0] == artist{
                                    profileView(
                                        refresh: $refreshing,
                                        artistId: artist._id,
                                        pfp: artist.pimage,
                                        artistName: artist.artistName,
                                        verification: artist.verification ?? false,
                                        slug: artist.slug,
                                        miniBio: artist.miniBiography,
                                        followerCount: artist.followerCount,
                                        followingCount: artist.followingCount,
                                        themeColor: artist.themeColor ?? "7099ff",
                                        createdDate: artist._createdDate,
                                        label: artist.label ?? "None",
                                        genre: artist.genre ?? "None",
                                        age: artist.age ?? "None",
                                        biography: artist.about ?? "None",
                                        isFollowing: artist.verified,
                                        link: artist.pimage
                                    ).environmentObject(globalVariable)
                                        .onAppear{
                                            if !firstTime{
                                                Task{
                                                    do{
                                                        refreshing = refreshing + 1
                                                        try await getArtistPage.fetch2(limit: 1, action: "refresh", artistId: artistId, previouslyFetched: getArtistPage.artistPageFields)
                                                        let artist = getArtistPage.artistPageFields[0]
                                                        artistName = artist.artistName
                                                        themeColor = artist.themeColor ?? "7099ff"
                                                        currentArtistId = artist._id
                                                    }catch{
                                                    }
                                                }
                                            }else{
                                                artistName = artist.artistName
                                                themeColor = artist.themeColor ?? "7099ff"
                                                currentArtistId = artist._id
                                            }
                                        }
                                }
                            }
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .listStyle(PlainListStyle())
                        .refreshable {
                            Task{
                                do{
                                    refreshing = refreshing + 1
                                    try await getArtistPage.fetch2(limit: 1, action: "refresh", artistId: artistId, previouslyFetched: getArtistPage.artistPageFields)
                                    let artist = getArtistPage.artistPageFields[0]
                                    artistName = artist.artistName
                                    themeColor = artist.themeColor ?? "7099ff"
                                    currentArtistId = artist._id
                                }catch{
                                }
                            }
                        }
                        .onAppear{
                            UIRefreshControl.appearance().tintColor = UIColor(Color("RefresherTint"))
                        }
                    }
                }else{
                    ZStack(alignment: .center){
                        profileView(refresh: $refreshing)
                        ProgressView()
                    }
                    .onAppear{
                        ArtistPageFetchingCompleted = false
                        Task{
                            do{
                                try await getArtistPage.fetch2(limit: 1, action: "load", artistId: artistId, previouslyFetched: getArtistPage.artistPageFields)
                                print(getArtistPage)
                                isDoneLoading = true
                                initArtistPageLoadError = false
                            }catch{
                                isDoneLoading = true
                                initArtistPageLoadError = true
                                print(error)
                            }
                        }
                    }
                    .onDisappear{
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            firstTime = false
                        }
                    }
                }
            }
            .background(Color("WhiteBlack"))
            .background(
                NavigationLink(destination: settings(), isActive: $settingsLinkActivated) {
                    EmptyView()
                }
                    .hidden()
            )
            VStack(spacing: 0){//heading
                VStack(spacing: 0){
                    ZStack{
                        Text("\(artistName)")
                            .font(.body)
                            .fontWeight(.bold)
                            .lineLimit(1)
                        HStack(spacing: 10){
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 23))
                                //                                        .font(.body)
                                    .padding(.top, 10.5)
                                    .padding(.horizontal, 12)
                                    .padding(.bottom, 10)
                                    .shadow(color: accentColorMix, radius: 0.1)
                                    .foregroundColor(accentColorMix)
                            }
                            .opacity(navigatedTo ? 1 : 0)
                            Spacer()
                            Button {
                                opener()
                            } label: {
                                Image(systemName: "line.3.horizontal")
                                //                                        .font(.body)
                                    .font(.system(size: 23))
                                    .padding(.top, 10.5)
                                    .padding(.horizontal, 12)
                                    .padding(.bottom, 10)
                                    .shadow(color: accentColorMix, radius: 0.1)
                                    .foregroundColor(accentColorMix)
                            }
                            .opacity(navigatedTo ? 0 : (currentArtistId == soundlytudeUserId() ? 1 : 0))
                        }
                    }
                    Divider()
                }
                .transition(AnyTransition.move(edge: .top))
                .frame(maxWidth: .infinity)
                .background(
                    ZStack{
                        Color(hexStringToUIColor(hex: "#\((themeColor).replacingOccurrences(of: "#", with: ""))")).opacity(0.25)
                        BlurView()
                    }
                        .ignoresSafeArea()
                )
                Spacer()
            }
        }
        if !navigatedTo {
            NavigationView{
                profilePageView
            }
        }else{
            profilePageView
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

struct profilePage_Previews: PreviewProvider {
    static var previews: some View {
        profilePage(artistId: "0fd70b92-e4cf-4e21-b522-4ec5a22b35f1")
            .ignoresSafeArea()
    }
}


struct profileView: View {
    @EnvironmentObject var globalVariable: globalVariables
    
    @Namespace var animation
    @Environment(\.colorScheme) var ColorScheme
    @StateObject var followUnfollow = postFollowUnfollow()
    @StateObject var artistPageFetchPlaylist = artistPageFetchPlaylistData()
    @StateObject var GetPlaylists = getMorePlaylists()
    @StateObject var GetPLD = getMorePLD()
    @StateObject var artistPageFetchPLD = artistPageFetchPLDData()
    
    @Binding var refresh: Int
    
    var artistId: String = ""
    var pfp: String = ""
    var artistName: String = "-"
    var verification: Bool = false
    var slug: String = "-"
    var miniBio: String = ""
    var followerCount: Int = 0
    var followingCount: Int = 0
    var postsCount: Int = 666
    var themeColor: String = "000000"
    var createdDate: String = ""
    var label: String = "Recordlytude"
    var genre: String = "000000"
    var age: String = ""
    var biography: String = ""
    @State var isFollowing: Bool = false
    var link: String = "-"
    
    @State var navigateToFollowers: Bool = false
    @State var toOpen: String = "Followers"
    @State private var presentAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    @State var loading: Bool = false
    
    @State var fetchedData: Bool = false
    
    
    @State var currentType: String = "heart"
    @State var editProfilePageLinkActivated: Bool = false
    @State var showLoading: Bool = false
    @State var disablePlaylistLoadMore: Bool = false
    @State var disablePLDLoadMore: Bool = false
    @State var initPlaylistLoadError: Bool = false
    @State var initPLDLoadError: Bool = false
    @State var showingChildView: Bool = false
    
    @State var playlistLimit: Int = 2
    @State var PLDLimit: Int = 2
    
    var accentColorMix: Color {
        return Color(UIColor.blend(color1: UIColor(Color(hexStringToUIColor(hex: "#\(themeColor.replacingOccurrences(of: "#", with: ""))"))), intensity1: 0.8, color2: UIColor(ColorScheme == .dark ? Color.white : Color.black), intensity2: 0.2))
    }
    
    var body: some View {
        VStack{
            Group {
                circleImageCustomSize(urlString: pfp, resolution: 96, multiply: Int(1.5))
                HStack(spacing: 5){
                    Text("@\(slug)")
                        .fontWeight(.semibold)
                    if verification {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(accentColorMix)
                            .font(.callout)
                    }
                }
                Spacer()
                    .frame(height: 10)
                HStack(spacing: 20){
                    countsView(count: postsCount, description: "Posts")
                    Capsule()
                        .foregroundColor(.gray)
                        .frame(width: 1, height: 15)
                    countsView(count: followerCount, description: "Followers")
                    Capsule()
                        .foregroundColor(.gray)
                        .frame(width: 1, height: 15)
                    countsView(count: followingCount, description: "Following")
                }
                Spacer()
                    .frame(height: 10)
                HStack(spacing: 5){
                    
                    if soundlytudeUserId() == artistId {
                        Button {
                            opener()
                        } label: {
                            ZStack{
                                buttonView(label: "Edit Profile")
                                if showLoading{
                                    ProgressView()
                                }
                            }
                        }
                    }else{
                        Button {
                            Task{
                                do {
                                    loading = true
                                    print((isFollowing) ? "Unfollowing" : "Following")
                                    try await followUnfollow.followUnfollow(type: (isFollowing) ? "unfollow" : "follow", artistId: artistId)
                                    print("Done \((isFollowing) ? "Unfollowing" : "Following")")
                                    refresh = refresh + 1
                                    loading = false
                                    isFollowing.toggle()
                                    
                                }catch{
                                    loading = false
                                    alertTitle = "An error occurred"
                                    alertMessage = "There was an error \((isFollowing) ? "unfollowing" : "following")"
                                    presentAlert = true
                                }
                            }
                        } label: {
                            ZStack{
                                buttonView(label: (isFollowing ? "Unfollow" : "Follow"))
                                if loading{
                                    ProgressView()
                                }
                            }
                        }
                        .disabled(loading)
                    }
                    if 1 == 2{
                        Button {
                            //
                        } label: {
                            buttonView(label: "instagram")
                        }
                        Button {
                            //
                        } label: {
                            buttonView(label: "youtube")
                        }
                    }
                }
                
                Spacer()
                    .frame(height: 10)
                Text("\(miniBio)")
                //            Text("\(miniBio)")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .lineLimit(5)
                Spacer()
                    .frame(height: 5)
                if 1 == 2{
                    Link(destination: URL(string: "\(link)")!) {
                        HStack(spacing: 5){
                            Image(systemName: "link")
                                .font(.footnote)
                            Text("\(link)")
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                        }
                        .foregroundColor(accentColorMix)
                    }
                }
            }
            .padding(.horizontal, 40)
            LazyVStack(spacing:0, pinnedViews: [.sectionHeaders]) {
                Section {
                    ScrollView{
                        VStack{/* dummy VStack */}.frame(height: 5)
                        if currentType == "heart"{ //Likes
                            if GetPLD.artistPageFetchPLDFields.count < 1 && !initPLDLoadError{
                                noItemsView(
                                    title: "No Favorites yet",
                                    message: "Musics and playlists liked by \(artistName) will appear here").padding(.bottom, 40)
                            }
                            if initPLDLoadError {
                                tapToRetryView(title: "Couldn't fetch Likes")
                                    .onTapGesture {
                                        fetchPLD()
                                    }
                            }
                            ForEach(GetPLD.artistPageFetchPLDFields, id: \._id){ PLD in
                                verticalPLDView(data: PLD)
                            }
                            .transition(AnyTransition.opacity.combined(with: .move(edge: .top)))
                            if !disablePLDLoadMore {
                                Button {
                                    Task{
                                        do {
                                            disablePLDLoadMore = true
                                            try await GetPLD.getPLD(limit: PLDLimit, action: "load", artistId: artistId, previouslyFetched: GetPLD.artistPageFetchPLDFields)
                                            if PLDLoadMoreCount == 0 || PLDLoadMoreCount < PLDLimit {
                                                disablePLDLoadMore = true
                                            }else{
                                                disablePLDLoadMore = false
                                            }
                                        }catch{
                                            print(error)
                                            disablePLDLoadMore = false
                                        }
                                    }
                                } label: {
                                    Text("Load more")
                                }
                                .foregroundColor(accentColorMix)
                                .disabled(disablePLDLoadMore)
                            }
                        }
                        if currentType == "music.note.list" { //Playlist
                            if GetPlaylists.artistPageFetchPlaylistFields.count < 1 && !initPlaylistLoadError{
                                noItemsView(
                                    title: "No playlists yet",
                                    message: "Playlists created by \(artistName) will appear here").padding(.bottom, 40)
                            }
                            if initPlaylistLoadError {
                                tapToRetryView(title: "Couldn't fetch Playlist")
                                    .onTapGesture {
                                        fetchPlaylist()
                                    }
                            }
                            ForEach(GetPlaylists.artistPageFetchPlaylistFields, id: \._id){ playlist in
                                verticalPlaylistView(playlistId: playlist._id, creatorId: playlist.artistDetails._id, title: playlist.title, genre: playlist.genre, wallpaper: playlist.wallpaper)
                            }
                            .transition(AnyTransition.opacity.combined(with: .move(edge: .top)))
                            if !disablePlaylistLoadMore {
                                Button {
                                    Task{
                                        do {
                                            disablePlaylistLoadMore = true
                                            try await GetPlaylists.getPlaylists(limit: playlistLimit, action: "load", creatorId: artistId, previouslyFetched: GetPlaylists.artistPageFetchPlaylistFields)
                                            if playlistLoadMoreCount == 0 || playlistLoadMoreCount < playlistLimit {
                                                disablePlaylistLoadMore = true
                                            }else{
                                                disablePlaylistLoadMore = false
                                            }
                                        }catch{
                                            disablePlaylistLoadMore = false
                                        }
                                    }
                                } label: {
                                    Text("Load more")
                                }
                                .foregroundColor(accentColorMix)
                                .disabled(disablePlaylistLoadMore)
                            }
                        }
                        if currentType == "info.square" {
                            verticalInfoView(
                                label: label,
                                genre: genre,
                                age: age,
                                biography: biography)
                            .transition(AnyTransition.opacity.combined(with: .move(edge: .top)))
                        }
                        Spacer()
                    }
                } header: {
                    VStack{
                        HStack{
                            Text("Date joined:")
                                .font(.caption)
                            Text("\(formatToFullDateStyle(time: createdDate))")
                                .font(.caption)
                                .fontWeight(.bold)
                        }
                        .frame(height: 20)
                        PinnedHeaderView()
                            .padding(.top, 15)
                            .background(BlurView())
                            .cornerRadius(10, corners: [.topLeft, .topRight])
                            .padding(.top, 10)
                            .zIndex(1)
                    }
                    //                    .padding(.top, 10)
                }
            }
            bottomSpace()
        }
        .onChange(of: refresh, perform: { value in
            Task{
                do {
                    try await GetPlaylists.getPlaylists(limit: -1,action: "refresh", creatorId: artistId, previouslyFetched: GetPlaylists.artistPageFetchPlaylistFields)
                    if playlistLoadMoreCount < playlistLimit {
                        disablePlaylistLoadMore = true
                    }else{
                        disablePlaylistLoadMore = false
                    }
                }catch{
                    print("REASON: ", error)
                }
                
                do {
                    try await GetPLD.getPLD(limit: -1, action: "refresh", artistId: artistId, previouslyFetched: GetPLD.artistPageFetchPLDFields)
                    if PLDLoadMoreCount < PLDLimit {
                        disablePLDLoadMore = true
                    }else{
                        disablePLDLoadMore = false
                    }
                }catch{
                    print("REASON: ", error)
                }
            }
        })
        .alert(alertTitle, isPresented: $presentAlert, actions: {
            // actions
        }, message: {
            Text(alertMessage)
        })
        .onAppear{
            if !fetchedData {
                //                artistPageFetchPlaylist.fetchUpdate(artistId: artistId, itemId: "x")
                artistPageFetchPLD.fetchUpdate(artistId: artistId, itemId: "x")
                fetchedData = true
                fetchPLD()
                fetchPlaylist()
            }
        }
        .background(
            NavigationLink(destination: editProfilePage(), isActive: $editProfilePageLinkActivated) {
                EmptyView()
            }
                .hidden()
        )
        .background(
            NavigationLink(destination: followersFollowingView(artistId: artistId, artistName: artistName, currentType: toOpen, themeColor: themeColor), isActive: $navigateToFollowers) {
                EmptyView()
            }
                .hidden()
        )
        //        .tint(Color(hexStringToUIColor(hex: "#\(themeColor.replacingOccurrences(of: "#", with: ""))")))
    }
    
    func fetchPlaylist() {
        Task {
            do {
                try await GetPlaylists.getPlaylists(limit: playlistLimit,action: "load", creatorId: artistId, previouslyFetched: GetPlaylists.artistPageFetchPlaylistFields)
                if playlistLoadMoreCount < playlistLimit {
                    disablePlaylistLoadMore = true
                }else{
                    disablePlaylistLoadMore = false
                }
                initPlaylistLoadError = false
            }catch{
                initPlaylistLoadError = true
                print("REASON: ", error)
            }
        }
    }
    
    func fetchPLD() {
        Task {
            do {//best to tdo it in different Do's because one can fail
                try await GetPLD.getPLD(limit: PLDLimit, action: "load", artistId: artistId, previouslyFetched: GetPLD.artistPageFetchPLDFields)
                if PLDLoadMoreCount < PLDLimit {
                    disablePLDLoadMore = true
                }else{
                    disablePLDLoadMore = false
                }
                initPLDLoadError = false
            }catch{
                initPLDLoadError = true
                print("REASON: ", error)
            }
        }
    }
    @ViewBuilder
    func countsView(count: Int, description: String) -> some View {
        Button {
            navigateToFollowers = true
            toOpen = description
        } label: {
            VStack{
                Text("\(count)")
                    .font(.callout)
                    .fontWeight(.bold)
                Text("\(description)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .foregroundColor(Color("BlackWhite"))
    }
    
    @ViewBuilder
    func buttonView(label: String) -> some View {
        VStack{
            if label == "instagram"{
                Image(systemName: "circle.fill")
                    .font(.callout)
                    .foregroundColor(Color("BlackWhite").opacity(0))
                    .background(Color("BlackWhite"))
                    .clipShape(instagramIconShape())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                    .scaleEffect(1.1)
            }
            if label == "youtube"{
                Image(systemName: "circle.fill")
                    .font(.callout)
                    .foregroundColor(Color("BlackWhite").opacity(0))
                    .background(Color("BlackWhite"))
                    .clipShape(youtubeIconShape())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                    .scaleEffect(1.1)
            }
            if label != "instagram" && label != "youtube"{
                Text("\(label)")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(label == "Follow" ? .white : Color("BlackWhite") )
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)
            }
        }
        .overlay(
            ZStack{
                if label == "Unfollow"{
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(accentColorMix, lineWidth: 2.5)
                }
            }
        )
        .background(
            VStack{
                if label == "Follow"{
                    mixThemeColor(colorScheme: .dark, color: Color(hexStringToUIColor(hex: "#\(themeColor.replacingOccurrences(of: "#", with: ""))")))
                }else if label == "Unfollow" {
                    
                }else{
                    Color("BlackWhite").opacity(0.1)
                }
            }
        )
        .cornerRadius(10)
    }
    
    @ViewBuilder
    func PinnedHeaderView() -> some View{
        let types: [String] = ["heart", "music.note.list", "info.square"]
        //        ScrollView(.horizontal, showsIndicators: false){
        HStack(spacing: 0) {
            ForEach(types, id: \.self){type in
                VStack{
                    Image(systemName: type)
                        .font(.system(size: 20))
                        .frame(width: 25, height: 25)
                        .foregroundColor((currentType == type) ? Color("BlackWhite") : .gray)
                    
                    ZStack{
                        if type == currentType {
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(accentColorMix)
                                .matchedGeometryEffect(id: "TAB", in: animation)
                            //                                RoundedRectangle(cornerRadius: 4, style: .continuous)
                            //                                    .fill(Color("BlackWhite").opacity(0.25))
                            //                                    .matchedGeometryEffect(id: "TAB", in: animation)
                        }else{
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(.clear)
                        }
                    }
                    .frame(height: 2)
                }
                .contentShape(Rectangle())
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    withAnimation(.easeInOut){
                        currentType = type
                    }
                }
            }
        }
        
        //        }
    }
    
    func destination(data: artistPageFetchPLDField) -> AnyView{
        if data.type == "Album"{
            return AnyView(albumPage(albumId: data.albumDetails?._id ?? "").environmentObject(globalVariable))
        }
        if data.type == "Track"{
            return AnyView(albumPage(albumId: data.albumDetails?._id ?? "").environmentObject(globalVariable))
        }
        if data.type == "Playlist"{
            return AnyView(playlistPage(playlistId: data.playlistDetails?._id ?? "", creatorId: data.ownerDetails?._id ?? "").environmentObject(globalVariable))
        }
        return AnyView(EmptyView())
    }
    
    @ViewBuilder
    func verticalPLDView(data: artistPageFetchPLDField) -> some View {
        
        //        NavigationLink(destination: destination(data: data).environmentObject(globalVariable), isActive: $showingChildView)
        //        { EmptyView() }
        //            .frame(width: 0, height: 0)
        //            .disabled(true)
        //            .hidden()
        NavigationLink(destination: destination(data: data), label: {
            HStack{
                if data.type == "Album"{
                    if data.albumDetails?.title == "deleted"{
                    }else{
                        verticalFavoriteExternalView(
                            imageUrl: data.albumDetails?.coverArt ?? "",
                            title: data.albumDetails?.title ?? "",
                            description: data.ownerDetails?.artistName ?? "",
                            featuringArtists: data.albumDetails?.featuringArtists ?? "",
                            type: data.type,
                            createdDate: data._createdDate)
                    }
                }
                if data.type == "Track"{
                    if data.albumDetails?.title == "deleted"{
                    }else{
                        verticalFavoriteExternalView(
                            imageUrl: data.albumDetails?.coverArt ?? "",
                            title: data.musicDetails?.tracktitle ?? "",
                            description: data.ownerDetails?.artistName ?? "",
                            featuringArtists: data.albumDetails?.featuringArtists ?? "",
                            type: data.type,
                            createdDate: data._createdDate)
                    }
                }
                if data.type == "Playlist"{
                    if data.playlistDetails?.title == "deleted"{
                    }else{
                        verticalFavoriteExternalView(
                            imageUrl: data.playlistDetails?.wallpaper ?? "",
                            title: data.playlistDetails?.title ?? "",
                            description: data.ownerDetails?.artistName ?? "",
                            featuringArtists: data.albumDetails?.featuringArtists ?? "",
                            type: data.type,
                            createdDate: data._createdDate)
                    }
                }
            }
        }).padding(.horizontal, 10)
    }
    
    @ViewBuilder
    func verticalPlaylistView(playlistId: String, creatorId: String, title: String, genre: String, wallpaper: String) -> some View {
        HStack{
            NavigationLink(destination: playlistPage(playlistId: playlistId, creatorId: creatorId).environmentObject(globalVariable),
                           isActive: $showingChildView)
            { EmptyView() }
                .frame(width: 0, height: 0)
                .disabled(true)
                .hidden()
            squareImage64by64(urlString: wallpaper, borderWidth: 1, borderColor: Color("SecondaryColor"))
            HStack{
                VStack(alignment: .leading){
                    Text(title)
                        .fontWeight(.bold)
                        .foregroundColor(Color("BlackWhite"))
                        .lineLimit(1)
                    Text(genre)
                        .font(.caption)
                        .fontWeight(.regular)
                        .foregroundColor(Color.gray)
                        .lineLimit(1)
                }
                Spacer()
                Circle()
                    .frame(width: 5, height: 5)
                    .foregroundColor(Color.accentColor)
            }
        }
        .onTapGesture(perform: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showingChildView = true
            }
        })
        .padding(.bottom, 5)
        .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y:5)
        .padding(.horizontal, 20)
    }
    
    func opener() {
        if(ArtistPageFetchingCompleted){
            editProfilePageLinkActivated = true
            showLoading = false
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                opener()
                if (ArtistPageFetchingCompleted == false){
                    editProfilePageLinkActivated = false
                    showLoading = true
                }
            }
        }
    }
}


struct instagramIconShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.5*width, y: 0.09009*height))
        path.addCurve(to: CGPoint(x: 0.70204*width, y: 0.09301*height), control1: CGPoint(x: 0.63351*width, y: 0.09009*height), control2: CGPoint(x: 0.64932*width, y: 0.0906*height))
        path.addCurve(to: CGPoint(x: 0.79489*width, y: 0.11022*height), control1: CGPoint(x: 0.75079*width, y: 0.09523*height), control2: CGPoint(x: 0.77727*width, y: 0.10338*height))
        path.addCurve(to: CGPoint(x: 0.85238*width, y: 0.14762*height), control1: CGPoint(x: 0.81822*width, y: 0.11929*height), control2: CGPoint(x: 0.83488*width, y: 0.13013*height))
        path.addCurve(to: CGPoint(x: 0.88978*width, y: 0.20511*height), control1: CGPoint(x: 0.86987*width, y: 0.16512*height), control2: CGPoint(x: 0.88071*width, y: 0.18178*height))
        path.addCurve(to: CGPoint(x: 0.90699*width, y: 0.29796*height), control1: CGPoint(x: 0.89662*width, y: 0.22273*height), control2: CGPoint(x: 0.90477*width, y: 0.24921*height))
        path.addCurve(to: CGPoint(x: 0.90991*width, y: 0.5*height), control1: CGPoint(x: 0.9094*width, y: 0.35068*height), control2: CGPoint(x: 0.90991*width, y: 0.36649*height))
        path.addCurve(to: CGPoint(x: 0.90699*width, y: 0.70204*height), control1: CGPoint(x: 0.90991*width, y: 0.63351*height), control2: CGPoint(x: 0.9094*width, y: 0.64932*height))
        path.addCurve(to: CGPoint(x: 0.88978*width, y: 0.79489*height), control1: CGPoint(x: 0.90477*width, y: 0.75079*height), control2: CGPoint(x: 0.89662*width, y: 0.77727*height))
        path.addCurve(to: CGPoint(x: 0.85238*width, y: 0.85238*height), control1: CGPoint(x: 0.88071*width, y: 0.81822*height), control2: CGPoint(x: 0.86987*width, y: 0.83488*height))
        path.addCurve(to: CGPoint(x: 0.79489*width, y: 0.88978*height), control1: CGPoint(x: 0.83488*width, y: 0.86987*height), control2: CGPoint(x: 0.81822*width, y: 0.88071*height))
        path.addCurve(to: CGPoint(x: 0.70204*width, y: 0.907*height), control1: CGPoint(x: 0.77727*width, y: 0.89663*height), control2: CGPoint(x: 0.75079*width, y: 0.90477*height))
        path.addCurve(to: CGPoint(x: 0.5*width, y: 0.90991*height), control1: CGPoint(x: 0.64933*width, y: 0.9094*height), control2: CGPoint(x: 0.63351*width, y: 0.90991*height))
        path.addCurve(to: CGPoint(x: 0.29796*width, y: 0.907*height), control1: CGPoint(x: 0.36648*width, y: 0.90991*height), control2: CGPoint(x: 0.35067*width, y: 0.9094*height))
        path.addCurve(to: CGPoint(x: 0.20511*width, y: 0.88978*height), control1: CGPoint(x: 0.24921*width, y: 0.90477*height), control2: CGPoint(x: 0.22273*width, y: 0.89663*height))
        path.addCurve(to: CGPoint(x: 0.14762*width, y: 0.85238*height), control1: CGPoint(x: 0.18178*width, y: 0.88071*height), control2: CGPoint(x: 0.16512*width, y: 0.86987*height))
        path.addCurve(to: CGPoint(x: 0.11022*width, y: 0.79489*height), control1: CGPoint(x: 0.13013*width, y: 0.83488*height), control2: CGPoint(x: 0.11929*width, y: 0.81822*height))
        path.addCurve(to: CGPoint(x: 0.093*width, y: 0.70204*height), control1: CGPoint(x: 0.10337*width, y: 0.77727*height), control2: CGPoint(x: 0.09523*width, y: 0.75079*height))
        path.addCurve(to: CGPoint(x: 0.09009*width, y: 0.5*height), control1: CGPoint(x: 0.0906*width, y: 0.64932*height), control2: CGPoint(x: 0.09009*width, y: 0.63351*height))
        path.addCurve(to: CGPoint(x: 0.093*width, y: 0.29796*height), control1: CGPoint(x: 0.09009*width, y: 0.36649*height), control2: CGPoint(x: 0.0906*width, y: 0.35068*height))
        path.addCurve(to: CGPoint(x: 0.11022*width, y: 0.20511*height), control1: CGPoint(x: 0.09523*width, y: 0.24921*height), control2: CGPoint(x: 0.10337*width, y: 0.22273*height))
        path.addCurve(to: CGPoint(x: 0.14762*width, y: 0.14762*height), control1: CGPoint(x: 0.11929*width, y: 0.18178*height), control2: CGPoint(x: 0.13013*width, y: 0.16512*height))
        path.addCurve(to: CGPoint(x: 0.20511*width, y: 0.11022*height), control1: CGPoint(x: 0.16512*width, y: 0.13013*height), control2: CGPoint(x: 0.18178*width, y: 0.11929*height))
        path.addCurve(to: CGPoint(x: 0.29796*width, y: 0.09301*height), control1: CGPoint(x: 0.22273*width, y: 0.10338*height), control2: CGPoint(x: 0.24921*width, y: 0.09523*height))
        path.addCurve(to: CGPoint(x: 0.5*width, y: 0.09009*height), control1: CGPoint(x: 0.35068*width, y: 0.0906*height), control2: CGPoint(x: 0.36649*width, y: 0.09009*height))
        path.move(to: CGPoint(x: 0.5*width, y: 0))
        path.addCurve(to: CGPoint(x: 0.29385*width, y: 0.00301*height), control1: CGPoint(x: 0.36421*width, y: 0), control2: CGPoint(x: 0.34718*width, y: 0.00058*height))
        path.addCurve(to: CGPoint(x: 0.17248*width, y: 0.02625*height), control1: CGPoint(x: 0.24063*width, y: 0.00544*height), control2: CGPoint(x: 0.20428*width, y: 0.01389*height))
        path.addCurve(to: CGPoint(x: 0.08392*width, y: 0.08392*height), control1: CGPoint(x: 0.1396*width, y: 0.03903*height), control2: CGPoint(x: 0.11172*width, y: 0.05612*height))
        path.addCurve(to: CGPoint(x: 0.02625*width, y: 0.17248*height), control1: CGPoint(x: 0.05612*width, y: 0.11172*height), control2: CGPoint(x: 0.03903*width, y: 0.1396*height))
        path.addCurve(to: CGPoint(x: 0.00301*width, y: 0.29385*height), control1: CGPoint(x: 0.01389*width, y: 0.20429*height), control2: CGPoint(x: 0.00544*width, y: 0.24063*height))
        path.addCurve(to: CGPoint(x: 0, y: 0.5*height), control1: CGPoint(x: 0.00057*width, y: 0.34718*height), control2: CGPoint(x: 0, y: 0.36421*height))
        path.addCurve(to: CGPoint(x: 0.00301*width, y: 0.70615*height), control1: CGPoint(x: 0, y: 0.63579*height), control2: CGPoint(x: 0.00057*width, y: 0.65282*height))
        path.addCurve(to: CGPoint(x: 0.02625*width, y: 0.82752*height), control1: CGPoint(x: 0.00544*width, y: 0.75937*height), control2: CGPoint(x: 0.01389*width, y: 0.79572*height))
        path.addCurve(to: CGPoint(x: 0.08392*width, y: 0.91608*height), control1: CGPoint(x: 0.03903*width, y: 0.8604*height), control2: CGPoint(x: 0.05612*width, y: 0.88828*height))
        path.addCurve(to: CGPoint(x: 0.17248*width, y: 0.97375*height), control1: CGPoint(x: 0.11172*width, y: 0.94388*height), control2: CGPoint(x: 0.1396*width, y: 0.96097*height))
        path.addCurve(to: CGPoint(x: 0.29385*width, y: 0.99699*height), control1: CGPoint(x: 0.20428*width, y: 0.98611*height), control2: CGPoint(x: 0.24063*width, y: 0.99456*height))
        path.addCurve(to: CGPoint(x: 0.5*width, y: height), control1: CGPoint(x: 0.34718*width, y: 0.99943*height), control2: CGPoint(x: 0.36421*width, y: height))
        path.addCurve(to: CGPoint(x: 0.70615*width, y: 0.99699*height), control1: CGPoint(x: 0.63579*width, y: height), control2: CGPoint(x: 0.65282*width, y: 0.99943*height))
        path.addCurve(to: CGPoint(x: 0.82752*width, y: 0.97375*height), control1: CGPoint(x: 0.75937*width, y: 0.99456*height), control2: CGPoint(x: 0.79571*width, y: 0.98611*height))
        path.addCurve(to: CGPoint(x: 0.91608*width, y: 0.91608*height), control1: CGPoint(x: 0.8604*width, y: 0.96097*height), control2: CGPoint(x: 0.88828*width, y: 0.94388*height))
        path.addCurve(to: CGPoint(x: 0.97375*width, y: 0.82752*height), control1: CGPoint(x: 0.94388*width, y: 0.88828*height), control2: CGPoint(x: 0.96097*width, y: 0.8604*height))
        path.addCurve(to: CGPoint(x: 0.99699*width, y: 0.70615*height), control1: CGPoint(x: 0.98611*width, y: 0.79572*height), control2: CGPoint(x: 0.99456*width, y: 0.75937*height))
        path.addCurve(to: CGPoint(x: width, y: 0.5*height), control1: CGPoint(x: 0.99942*width, y: 0.65282*height), control2: CGPoint(x: width, y: 0.63579*height))
        path.addCurve(to: CGPoint(x: 0.99699*width, y: 0.29385*height), control1: CGPoint(x: width, y: 0.36421*height), control2: CGPoint(x: 0.99942*width, y: 0.34718*height))
        path.addCurve(to: CGPoint(x: 0.97375*width, y: 0.17248*height), control1: CGPoint(x: 0.99456*width, y: 0.24063*height), control2: CGPoint(x: 0.98611*width, y: 0.20429*height))
        path.addCurve(to: CGPoint(x: 0.91608*width, y: 0.08392*height), control1: CGPoint(x: 0.96097*width, y: 0.1396*height), control2: CGPoint(x: 0.94388*width, y: 0.11172*height))
        path.addCurve(to: CGPoint(x: 0.82752*width, y: 0.02625*height), control1: CGPoint(x: 0.88828*width, y: 0.05612*height), control2: CGPoint(x: 0.8604*width, y: 0.03903*height))
        path.addCurve(to: CGPoint(x: 0.70615*width, y: 0.00301*height), control1: CGPoint(x: 0.79571*width, y: 0.01389*height), control2: CGPoint(x: 0.75937*width, y: 0.00544*height))
        path.addCurve(to: CGPoint(x: 0.5*width, y: 0), control1: CGPoint(x: 0.65282*width, y: 0.00058*height), control2: CGPoint(x: 0.63579*width, y: 0))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.5*width, y: 0.24324*height))
        path.addCurve(to: CGPoint(x: 0.24324*width, y: 0.5*height), control1: CGPoint(x: 0.3582*width, y: 0.24324*height), control2: CGPoint(x: 0.24324*width, y: 0.3582*height))
        path.addCurve(to: CGPoint(x: 0.5*width, y: 0.75676*height), control1: CGPoint(x: 0.24324*width, y: 0.6418*height), control2: CGPoint(x: 0.3582*width, y: 0.75676*height))
        path.addCurve(to: CGPoint(x: 0.75676*width, y: 0.5*height), control1: CGPoint(x: 0.6418*width, y: 0.75676*height), control2: CGPoint(x: 0.75676*width, y: 0.6418*height))
        path.addCurve(to: CGPoint(x: 0.5*width, y: 0.24324*height), control1: CGPoint(x: 0.75676*width, y: 0.3582*height), control2: CGPoint(x: 0.6418*width, y: 0.24324*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.5*width, y: 0.66667*height))
        path.addCurve(to: CGPoint(x: 0.33333*width, y: 0.5*height), control1: CGPoint(x: 0.40795*width, y: 0.66667*height), control2: CGPoint(x: 0.33333*width, y: 0.59205*height))
        path.addCurve(to: CGPoint(x: 0.5*width, y: 0.33333*height), control1: CGPoint(x: 0.33333*width, y: 0.40795*height), control2: CGPoint(x: 0.40795*width, y: 0.33333*height))
        path.addCurve(to: CGPoint(x: 0.66667*width, y: 0.5*height), control1: CGPoint(x: 0.59205*width, y: 0.33333*height), control2: CGPoint(x: 0.66667*width, y: 0.40795*height))
        path.addCurve(to: CGPoint(x: 0.5*width, y: 0.66667*height), control1: CGPoint(x: 0.66667*width, y: 0.59205*height), control2: CGPoint(x: 0.59205*width, y: 0.66667*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.8269*width, y: 0.2331*height))
        path.addCurve(to: CGPoint(x: 0.7669*width, y: 0.2931*height), control1: CGPoint(x: 0.8269*width, y: 0.26624*height), control2: CGPoint(x: 0.80004*width, y: 0.2931*height))
        path.addCurve(to: CGPoint(x: 0.7069*width, y: 0.2331*height), control1: CGPoint(x: 0.73376*width, y: 0.2931*height), control2: CGPoint(x: 0.7069*width, y: 0.26624*height))
        path.addCurve(to: CGPoint(x: 0.7669*width, y: 0.1731*height), control1: CGPoint(x: 0.7069*width, y: 0.19996*height), control2: CGPoint(x: 0.73376*width, y: 0.1731*height))
        path.addCurve(to: CGPoint(x: 0.8269*width, y: 0.2331*height), control1: CGPoint(x: 0.80004*width, y: 0.1731*height), control2: CGPoint(x: 0.8269*width, y: 0.19996*height))
        path.closeSubpath()
        return path
    }
}

struct youtubeIconShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.79231*width, y: 0.14619*height))
        path.addLine(to: CGPoint(x: 0.20769*width, y: 0.14619*height))
        path.addCurve(to: CGPoint(x: 0, y: 0.35388*height), control1: CGPoint(x: 0.09298*width, y: 0.14619*height), control2: CGPoint(x: 0, y: 0.23917*height))
        path.addLine(to: CGPoint(x: 0, y: 0.64613*height))
        path.addCurve(to: CGPoint(x: 0.20769*width, y: 0.85381*height), control1: CGPoint(x: 0, y: 0.76083*height), control2: CGPoint(x: 0.09298*width, y: 0.85381*height))
        path.addLine(to: CGPoint(x: 0.79231*width, y: 0.85381*height))
        path.addCurve(to: CGPoint(x: width, y: 0.64613*height), control1: CGPoint(x: 0.90702*width, y: 0.85381*height), control2: CGPoint(x: width, y: 0.76083*height))
        path.addLine(to: CGPoint(x: width, y: 0.35388*height))
        path.addCurve(to: CGPoint(x: 0.79231*width, y: 0.14619*height), control1: CGPoint(x: width, y: 0.23917*height), control2: CGPoint(x: 0.90702*width, y: 0.14619*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.65186*width, y: 0.51422*height))
        path.addLine(to: CGPoint(x: 0.37841*width, y: 0.64464*height))
        path.addCurve(to: CGPoint(x: 0.3627*width, y: 0.63473*height), control1: CGPoint(x: 0.37112*width, y: 0.64811*height), control2: CGPoint(x: 0.3627*width, y: 0.6428*height))
        path.addLine(to: CGPoint(x: 0.3627*width, y: 0.36574*height))
        path.addCurve(to: CGPoint(x: 0.37864*width, y: 0.35595*height), control1: CGPoint(x: 0.3627*width, y: 0.35755*height), control2: CGPoint(x: 0.37134*width, y: 0.35225*height))
        path.addLine(to: CGPoint(x: 0.65209*width, y: 0.49452*height))
        path.addCurve(to: CGPoint(x: 0.65186*width, y: 0.51422*height), control1: CGPoint(x: 0.66022*width, y: 0.49864*height), control2: CGPoint(x: 0.66008*width, y: 0.5103*height))
        path.closeSubpath()
        return path
    }
}


struct mixThemeColor: View {
    @State var colorScheme: ColorScheme? = .dark
    @State var color: Color = .white
    @Environment(\.colorScheme) var ColorScheme
    
    var body: some View{
        ZStack{
            color
            BlurView()
                .opacity(0.25)
            BlurView()
                .opacity(0.5)
                .mask(
                    LinearGradient(colors:[
                        .clear,
                        Color.black.opacity(1)], startPoint: .top, endPoint: .bottom))
        }
        .preferredColorScheme(colorScheme)
        .environment(\.colorScheme, colorScheme ?? ColorScheme)
    }
}

extension UIColor {
    static func blend(color1: UIColor, intensity1: CGFloat = 0.5, color2: UIColor, intensity2: CGFloat = 0.5) -> UIColor {
        let total = intensity1 + intensity2
        let l1 = intensity1/total
        let l2 = intensity2/total
        guard l1 > 0 else { return color2}
        guard l2 > 0 else { return color1}
        var (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        var (r2, g2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        
        color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        return UIColor(red: l1*r1 + l2*r2, green: l1*g1 + l2*g2, blue: l1*b1 + l2*b2, alpha: l1*a1 + l2*a2)
    }
}
