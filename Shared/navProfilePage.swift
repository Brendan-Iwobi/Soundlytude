//
//  navProfilePage.swift
//  Soundlytude
//
//  Created by DJ bon26 on 9/15/22.
//

import SwiftUI

var ArtistPageFetchingCompleted: Bool = false

class globalReloader: ObservableObject {
    @Published var refresher: Bool = true
}

class globalReloader2: ObservableObject {
    @Published var refresher: Bool = false
}

struct navProfilePage: View {
    @StateObject var artistPageFetch = artistPageFetchData()
    @StateObject var artistPageFetchUpload = artistPageFetchUploadData()
    @StateObject var artistPageFetchPlaylist = artistPageFetchPlaylistData()
    @StateObject var artistPageFetchPLD = artistPageFetchPLDData()
    
    @State var currentType: String = "square.and.arrow.up"
    @Namespace var animation
    @Environment(\.colorScheme) var colorScheme
    @State var headerOffsets: (CGFloat, CGFloat) = (0,0)
    @State private var showingAlert = false
    @State var artistId: String = /* soundlytudeUserId() */ "0fd70b92-e4cf-4e21-b522-4ec5a22b35f1"
    @State var isDoneLoading: Bool = false
    @State private var presentAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    
    @StateObject var GlobalReloader = globalReloader()
    
    var body: some View {
        if isDoneLoading {
            ForEach(artistPageFetch.artistPageFields, id: \._id){ artist in
                ZStack{
                    Color(hexStringToUIColor(hex: "#\(artist.themeColor ?? "000000")")).opacity(0.25)
                        .ignoresSafeArea()
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
                                //                                followerCount: artist.followers?.count ?? 0,
                                //                                followingCount: artist.following?.count ?? 0,
                                themeColor: artist.themeColor ?? "000000",
                                isFollowing: artist.verified,
                                urlString: artist.pimage
                            ).environmentObject(GlobalReloader)
                                .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y:5)
                            if GlobalReloader.refresher {
                                Rectangle()
                                    .hidden()
                                    .onAppear{
                                        artistPageFetch.fetch(artistId: artistId)
                                        print("Abundalakaka")
                                        GlobalReloader.refresher = false
                                    }
                            }
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
                    }
                }
                .tint(Color(hexStringToUIColor(hex: "#\(artist.themeColor ?? "000000")")))
                .accentColor(Color(hexStringToUIColor(hex: "#\(artist.themeColor ?? "000000")")))
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle(artist.artistName)
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
                                ZStack{
                                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                                        .fill(Color.accentColor)
                                        .frame(width: 75)
                                        .matchedGeometryEffect(id: "TAB", in: animation)
                                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                                        .fill(Color("BlackWhite").opacity(0.25))
                                        .frame(width: 75)
                                        .matchedGeometryEffect(id: "TAB", in: animation)
                                }
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
}

struct navProfilePage_Previews: PreviewProvider {
    static var previews: some View {
        navProfilePage()
    }
}

struct navPageInfo: View {
    var artistId: String
    var artistName: String
    var verification: Bool
    var slug: String
    var miniBio: String
    var followerCount: Int
    var followingCount: Int
    @State var isFollowing: Bool
    
    @StateObject var followUnfollow = postFollowUnfollow()
    
    @EnvironmentObject var GlobalReloader2: globalReloader2
    
    @State var navigateToFollowers: Bool = false
    @State var toOpen: String = "Followers"
    @State private var presentAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    @State var loading: Bool = false
    
    @State var editProfilePageLinkActivated: Bool = false
    @State var reloadingCompleted: Bool = false
    @State var showLoading: Bool = false
    var body: some View{
        VStack{
            HStack(alignment: .center){
                (Text(artistName)
                    .foregroundColor(Color.white)
                 +
                 Text((verification) ? " \(Image(systemName: "checkmark.seal.fill"))" : "")
                    .foregroundColor(Color.accentColor)
                )
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        alignment: .topLeading
                    )
                    .lineLimit(3)
                if soundlytudeUserId() == artistId {
                    Button {
                        opener()
                    } label: {
                        if showLoading {
                            ProgressView()
                        }else{
                            VStack{
                                Text("Edit profile")
                                    .font(.footnote)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .frame(width: 100, height:30.0)
                    .background(Color.gray)
                    .cornerRadius(5)
                    .background(
                        NavigationLink(destination: editProfilePage(), isActive: $editProfilePageLinkActivated) {
                            EmptyView()
                        }
                            .hidden()
                    )
//                    NavigationLink(destination: editProfilePage()) {
//                        VStack{
//                            Text("Edit profile")
//                                .font(.footnote)
//                                .fontWeight(.bold)
//                                .foregroundColor(.white)
//                        }
//                        .frame(width: 100, height:30.0)
//                        .background(Color.gray)
//                        .cornerRadius(5)
//                    }
                }else{
                    ZStack{
                        Button {
                            Task{
                                do {
                                    loading = true
                                    print((isFollowing) ? "Unfollowing" : "Following")
                                    try await followUnfollow.followUnfollow(type: (isFollowing) ? "unfollow" : "follow", artistId: artistId)
                                    print("Done \((isFollowing) ? "Unfollowing" : "Following")")
                                    GlobalReloader2.refresher = true
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
                            if isFollowing{
                                Text("Unfollow")
                                    .font(.footnote)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .overlay(
                                        ZStack{
                                            RoundedRectangle(cornerRadius: 5)
                                                .stroke(Color.accentColor, lineWidth: 2.5)
                                            RoundedRectangle(cornerRadius: 5)
                                                .stroke(Color.black.opacity(0.25), lineWidth: 2.5)
                                        }
                                            .frame(width: 100, height:30.0)
                                    )
                            }else{
                                ZStack{
                                    Color.accentColor
                                    Color.black.opacity(0.25)
                                    Text("Follow")
                                        .font(.footnote)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .disabled(loading)
                        .frame(width: 100, height:30.0)
                        .cornerRadius(5)
                        ZStack{
                            Color("WhiteBlack")
                                .opacity(0.5)
                                .frame(width: 100, height:30.0)
                                .cornerRadius(5)
                            ProgressView()
                        }.opacity(loading ? 1 : 0)
                    }
                }
            }
            .padding(.bottom, 5.0)
            Text("@\(slug)")
                .font(.footnote)
                .fontWeight(.bold)
                .foregroundColor(Color.gray)
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    alignment: .topLeading
                )
            Text("\(miniBio)")
                .font(.footnote)
                .fontWeight(.regular)
                .foregroundColor(Color.white)
                .padding(.bottom, 5.0)
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    alignment: .topLeading
                )
            HStack(spacing: 20){
                Button {
                    navigateToFollowers = true
                    toOpen = "Followers"
                } label: {
                    Text(String(followerCount))
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)
                    Text("Followers")
                        .font(.footnote)
                        .foregroundColor(Color.gray)
                }
                Button {
                    navigateToFollowers = true
                    toOpen = "Following"
                } label: {
                    Text(String(followingCount))
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)
                    Text("Following")
                        .font(.footnote)
                        .foregroundColor(Color.gray)
                }
            }
            .background(
                NavigationLink(destination: followersFollowingView(artistId: artistId, artistName: artistName, currentType: toOpen), isActive: $navigateToFollowers) {
                    EmptyView()
                }
                    .hidden()
            )
            .frame(
                minWidth: 0,
                maxWidth: .infinity,
                alignment: .topLeading
            )
        }
        .padding()
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

struct bannerImage: View {
    var artistId: String
    var artistName: String
    var verification: Bool
    var slug: String
    var miniBio: String
    var followerCount: Int
    var followingCount: Int
    var themeColor: String
    var isFollowing: Bool
    
    let urlString: String
    @State var data: Data?
    
    @EnvironmentObject var GlobalReloader: globalReloader
    @StateObject var GlobalReloader2 = globalReloader2()
    var body: some View{
        GeometryReader{proxy in
            let minY = proxy.frame(in: .named("")).minY
            let size = proxy.size
            let height = (size.height + minY)
            let halfHeight = height/100 - 2
            VStack{
                profileBannerImage(urlString: urlString, proxy: proxy, artistId: artistId)
                if GlobalReloader2.refresher {
                    Rectangle()
                        .hidden()
                        .onAppear{
                            GlobalReloader.refresher = true
                            GlobalReloader2.refresher = false
                        }
                }
            }
            .frame(width: abs(size.width), height: (height < 0) ? 0 : height)
            .overlay(content:{
                ZStack{
                    //                    VStack{
                    //                        Spacer()
                    //                        Blur(style: .dark)
                    //                            .cornerRadius(20)
                    //                            .mask(
                    //                                LinearGradient(colors:[
                    //                                    .clear,
                    //                                    Color(hexStringToUIColor(hex: "#\(themeColor)")).opacity(1)], startPoint: .top, endPoint: .bottom))
                    //                            .frame(width: size.width, height: (height/1.25) < 0 ? 0 : height/1.25)
                    //                            .opacity(halfHeight)
                    //                    }
                    VStack{
                        Spacer()
                        Color(hexStringToUIColor(hex: "#\(themeColor)")).opacity(0.25)
                            .cornerRadius(20)
                            .mask(
                                LinearGradient(colors:[
                                    .clear,
                                    Color.black.opacity(1)], startPoint: .top, endPoint: .bottom))
                            .frame(width: size.width, height: (height/1.25) < 0 ? 0 : height/1.25)
                            .opacity(halfHeight)
                    }
                    VStack{
                        Spacer()
                        Color.black.opacity(0.5)
                            .cornerRadius(20)
                            .mask(
                                LinearGradient(colors:[
                                    .clear,
                                    Color.black.opacity(1)], startPoint: .top, endPoint: .bottom))
                            .frame(width: size.width, height: (height/1.25) < 0 ? 0 : height/1.25)
                            .opacity(halfHeight)
                    }
                    VStack{
                        Spacer()
                        navPageInfo(
                            artistId: artistId,
                            artistName: artistName,
                            verification: verification,
                            slug: slug,
                            miniBio: miniBio,
                            followerCount: followerCount,
                            followingCount: followingCount,
                            isFollowing: isFollowing
                        ).environmentObject(GlobalReloader2)
                    }
                    .opacity(halfHeight)
                }
            })
            .offset(y: -minY)
        }
        .frame(height: 500)
    }
}


struct profileBannerImage: View {
    let urlString: String
    let proxy: GeometryProxy
    let artistId: String
    @State var data: Data?
    var body: some View {
        let minY = proxy.frame(in: .named("")).minY
        let size = proxy.size
        let height = (size.height + minY)
        let halfHeight = height/100 - 2
        if let data = data, let uiimage = UIImage(data: data) {
            Image(uiImage: uiimage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: abs(size.width), height: (height < 0) ? 0 : height, alignment:.center)
                .opacity(((halfHeight + 1.25) < 0.1) ? 0.1 : halfHeight + 1.25)
                .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
                .onAppear{
                    if artistId == soundlytudeUserId(){
                        fetchData()
                    }
                }
        }
        else {
            Image("Soundlytude empty placeHolder")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: abs(size.width), height: (height < 0) ? 0 : height, alignment:.center)
                .opacity(0.1)
                .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
                .onAppear {
                    fetchData()
                }
        }
    }
    
    private func fetchData(){
        if artistId == soundlytudeUserId(){
            guard let url = URL(string: "\(newlyUpdatedPfpUrl)/v1/fill/w_512,h_512,al_c/Soundlytude-Image.png") else {
                return
            }
            let task = URLSession.shared.dataTask(with: url) { data, _, _
                in
                self.data = data
            }
            task.resume( )
        }else{
            guard let url = URL(string: "\(urlString)/v1/fill/w_512,h_512,al_c/Soundlytude-Image.png") else {
                return
            }
            let task = URLSession.shared.dataTask(with: url) { data, _, _
                in
                self.data = data
            }
            task.resume( )
        }
    }
}

struct verticalUploadView: View{
    var artistId: String
    var data: artistPageFetchUploadField
    var isLast: Bool
    @ObservedObject var listData: artistPageFetchUploadData
    
    var body: some View{
        NavigationLink(destination: albumPage(albumId: data._id), label: {
            HStack{
                squareImage48by48(urlString: data.coverArt)
                HStack{
                    VStack(alignment: .leading){
                        Text(data.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color("BlackWhite"))
                            .lineLimit(1)
                        Text(data.artistDetails.artistName)
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
            .padding(.bottom, 5)
            .onAppear{
                if self.isLast {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                        self.listData.fetchUpdate(artistId: artistId)
                    }
                }
            }
            .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y:5)
        }).padding(.horizontal, 20)
    }
}

struct verticalPlaylistView: View{
    @EnvironmentObject var globalVariable: globalVariables
    
    var artistId: String
    var data: artistPageFetchPlaylistField
    var isLast: Bool
    @State private var showingChildView = false
    @ObservedObject var listData: artistPageFetchPlaylistData
    
    var body: some View{
        HStack{
            NavigationLink(destination: playlistPage(playlistId: self.data._id, creatorId: self.data.artistDetails._id).environmentObject(globalVariable),
                           isActive: self.$showingChildView)
            { EmptyView() }
                .frame(width: 0, height: 0)
                .disabled(true)
                .hidden()
            squareImage64by64(urlString: data.wallpaper, borderWidth: 1, borderColor: Color("SecondaryColor"))
            HStack{
                VStack(alignment: .leading){
                    Text(data.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color("BlackWhite"))
                        .lineLimit(1)
                    Text(data._createdDate)
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
        .onAppear{
            if self.isLast {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.listData.fetchUpdate(artistId: artistId, itemId: data._id)
                }
            }
        }.padding(.horizontal, 20)
    }
}

struct verticalFavoriteView: View {
    @EnvironmentObject var globalVariable: globalVariables
    
    var artistId: String
    var data: artistPageFetchPLDField
    var isLast: Bool
    @ObservedObject var listData: artistPageFetchPLDData
    
    var destination: AnyView {
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
    
    var body: some View{
        NavigationLink(destination: destination, label: {
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
            .onAppear{
                if self.isLast {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                        self.listData.fetchUpdate(artistId: artistId, itemId: data._id)
                    }
                }
            }
        }).padding(.horizontal, 10)
    }
}

struct verticalFavoriteExternalView: View{
    var imageUrl: String
    var title: String
    var description: String
    var featuringArtists: String
    var type: String
    var createdDate: String
    
    var borderColor: Color {
        if type == "Album" {
            return Color.accentColor
        }
        if type == "Playlist" {
            return Color("SecondaryColor")
        }
        if type == "Track" {
            return Color.red
        }
        return .clear
    }
    var body: some View{
        HStack{
            squareImage64by64(urlString: imageUrl, borderWidth: 1, borderColor: borderColor)
            VStack(alignment: .leading, spacing: 0){
                VStack(alignment: .leading){
                    Text(title)
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundColor(Color("BlackWhite"))
                        .lineLimit(1)
                    Text("\(description)\((featuringArtists == "Solo" || featuringArtists == "") ? "" : "Ft. \(featuringArtists)")")
                        .font(.caption)
                        .fontWeight(.regular)
                        .foregroundColor(Color.gray)
                        .lineLimit(1)
                }
                Spacer()
                HStack{
                    Text(formatToDateStyle2(time: createdDate))
                        .font(.caption)
                        .foregroundColor(Color.gray)
                    Spacer()
                    Sticker(text: type)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical, 5)
        }
        .padding(.bottom, 5)
//        .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y:5)
    }
}
struct verticalInfoView: View{
    var label: String
    var genre: String
    var age: String
    var biography: String
    var body: some View{
        VStack(alignment: .leading){
            verticalInfoExternalView(title: "Label", description: label)
            verticalInfoExternalView(title: "Genre interest", description: genre)
            verticalInfoExternalView(title: "Age", description: age)
            verticalInfoExternalView(title: "Biography", description: biography)
        }
    }
}

struct verticalInfoExternalView: View {
    var title: String
    var description: String
    var body: some View{
        VStack(alignment: .center){
            Section{
                Text(description)
                    .font(.footnote)
                    .frame(minWidth: 0,maxWidth: .infinity, alignment: .topLeading)
                    .padding(.bottom)
            }header: {
                Text(title)
                    .font(.callout)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        alignment: .topLeading
                    )
            }
            .padding(.horizontal, 10)
        }
    }
}

struct artistPageField: Hashable, Codable {
    let _id: String
    let artistName: String
    let slug: String
    let email: String?
    let miniBiography: String
    let age: String?
    let pimage: String
    let label: String?
    let genre: String?
    let verification: Bool?
    let verified: Bool
    //    let following: [artistFollowing]?
    //    let followers: [artistFollower]?
    let followerCount: Int
    let followingCount: Int
    let totalPlays: Int
    let totalUploads: Int
    let totalLikes: Int
    let about: String?
    let likesPrivacy: Bool?
    let followerFollweesPrivacy: Bool?
    let followEmail: Bool?
    let likeEmail: Bool?
    let commentEmail: Bool?
    let followNotification: Bool?
    let likeNotification: Bool?
    let commentNotification: Bool?
    let themeColor: String?
    let _createdDate: String
    let phone: String?
    let firstName: String?
    let lastName: String?
}

struct artistFollower: Hashable, Codable {
    let _id: String
    let artistName: String
    let password: String
    let slug: String
    let email: String
    let pimage: String
}
struct artistFollowing: Hashable, Codable {
    let _id: String
    let artistName: String
    let password: String
    let slug: String
    let email: String
    let pimage: String
}

class artistPageFetchData: ObservableObject {
    @Published var artistPageFields: [artistPageField] = []
    
    func fetch(artistId:String) {
        ArtistPageFetchingCompleted = false
        guard let url = URL(string: HttpBaseUrl() + "/_functions/artists?password=G62zOR9ZTlA0Tbcd2TX8&type=filterEq&columnId=_id&value=\(artistId)&currentArtistId=\(soundlytudeUserId())&noItems=true") else {
            return}
        print(url)
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _,
            error in
            guard let data = data, error == nil else {
                return
            }
            // Convert to JSON
            do
            {
                let data = try JSONDecoder().decode ([artistPageField].self, from: data)
                DispatchQueue.main.async{
                    self?.artistPageFields = data
                    if data[0]._id == soundlytudeUserId() {
                        let artist = data[0]
                        partistName = artist.artistName
                        pusername = artist.slug
                        pbio = artist.miniBiography
                        pgenre = artist.genre ?? ""
                        pbiography = artist.about ?? ""
                        pdateOfBirth = artist.age ?? "None"
                        pthemeColor = artist.themeColor ?? ""
                        pfirstName = artist.firstName ?? ""
                        plastName = artist.lastName ?? ""
                        pemail = artist.email ?? "None"
                        pphone = artist.phone ?? ""
                        pEmailCommentNotif = artist.commentEmail ?? false
                        pEmailLikesNotif = artist.likeEmail ?? false
                        pEmailFollowNotif = artist.followEmail ?? false
                        pAccountFollowNotif = artist.followNotification ?? false
                        pAccountLikesNotif = artist.likeNotification ?? false
                        pAccountCommentNotif = artist.commentNotification ?? false
                        pHideFollowerFollowing = artist.followerFollweesPrivacy ?? false
                        pHideLikes = artist.likesPrivacy ?? false
                    }
                    ArtistPageFetchingCompleted = true
                }
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }
    
    func fetch2(limit: Int, action: String, artistId: String, previouslyFetched: [artistPageField]) async throws {
        ArtistPageFetchingCompleted = false
        guard let url = URL(string: HttpBaseUrl() + "/_functions/getArtist?password=G62zOR9ZTlA0Tbcd2TX8&action=\(action)&limit=\(limit)") else { fatalError("Missing URL") }
        print(url)
        
        struct artistGetData: Codable {
            let artistId: String
            let previouslyFetched: [artistPageField]
            let propertyName: String
            let value: String
        }
        
        // Add data to the model
        let artistGetDataModel = artistGetData(artistId: artistId, previouslyFetched: previouslyFetched, propertyName: "_id", value: artistId)
        
        // Convert model to JSON data
        guard let jsonData = try? JSONEncoder().encode(artistGetDataModel) else {
            print("Error: Trying to convert model to JSON data")
            return
        }
        
        print("Checkpoint1artist")
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type") // the request is JSON
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept") // the response expected to be in JSON format
        urlRequest.httpBody = jsonData
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        print("Checkpoint2artist")
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { print(response); return}
        let decodedData = try JSONDecoder().decode([artistPageField].self, from: data)
        DispatchQueue.main.async{
            print("Checkpoint3artist")
            if action == "refresh" {
                self.artistPageFields = decodedData
            }else{
                self.artistPageFields = self.artistPageFields + decodedData
                PLDLoadMoreCount = decodedData.count
            }
            if decodedData[0]._id == soundlytudeUserId() {
                let artist = decodedData[0]
                partistName = artist.artistName
                pusername = artist.slug
                pbio = artist.miniBiography
                pgenre = artist.genre ?? ""
                pbiography = artist.about ?? ""
                pdateOfBirth = artist.age ?? "None"
                pthemeColor = artist.themeColor ?? ""
                pfirstName = artist.firstName ?? ""
                plastName = artist.lastName ?? ""
                pemail = artist.email ?? "None"
                pphone = artist.phone ?? ""
                pEmailCommentNotif = artist.commentEmail ?? false
                pEmailLikesNotif = artist.likeEmail ?? false
                pEmailFollowNotif = artist.followEmail ?? false
                pAccountFollowNotif = artist.followNotification ?? false
                pAccountLikesNotif = artist.likeNotification ?? false
                pAccountCommentNotif = artist.commentNotification ?? false
                pHideFollowerFollowing = artist.followerFollweesPrivacy ?? false
                pHideLikes = artist.likesPrivacy ?? false
            }else{
                print("IT IS NOT MINE :(", decodedData[0])
            }
            ArtistPageFetchingCompleted = true
        }
    }
}

struct uArtistDetails: Hashable, Codable {
    let _id: String
    let artistName: String
    let pimage: String
}
struct artistPageFetchUploadField: Hashable, Codable {
    let _id: String
    let title: String
    let coverArt: String
    let artistDetails: uArtistDetails
}

class artistPageFetchUploadData: ObservableObject {
    @Published var artistPageFetchUploadFields: [artistPageFetchUploadField] = []
    @Published var count = 0
    
    func fetchUpdate(artistId:String) {
        guard let url = URL(string: HttpBaseUrl() + "/_functions/albums?password=wNyLKt1V6357sVCZLJlH&type=filterEq&columnId=userId&value=\(artistId)&continueFrom=\(count)&noItems=true") else {
            return}
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _,
            error in
            guard let data = data, error == nil else {
                return
            }
            // Convert to JSON
            do
            {
                let data = try JSONDecoder().decode ([artistPageFetchUploadField].self, from: data)
                DispatchQueue.main.async{
                    self?.artistPageFetchUploadFields = self!.artistPageFetchUploadFields + data
                    self?.count += 10
                }
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }
}


struct pArtistDetails: Hashable, Codable {
    let _id: String
    let artistName: String
    let pimage: String
}

struct playlistContents: Hashable, Codable {
    let _id: String
    let type: String
}

struct artistPageFetchPlaylistField: Hashable, Codable {
    let _id: String
    let title: String
    let wallpaper: String
    let genre: String
    let _createdDate: String
    let createdTime: Int
    let contents: [playlistContents]
    let artistDetails: pArtistDetails
}
class artistPageFetchPlaylistData: ObservableObject {
    @Published var artistPageFetchPlaylistFields: [artistPageFetchPlaylistField] = []
    @Published var count = 0
    
    func fetchUpdate(artistId: String, itemId: String) {
        guard let url = URL(string: HttpBaseUrl() + "/_functions/playlists?password=Ycm1Wqxyfwz3y12OR9IQ&type=filterEq&columnId=creatorId&value=\(artistId)&continueFrom=\(itemId)&noItems=true&totalFetch=50") else {
            return}
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _,
            error in
            guard let data = data, error == nil else {
                return
            }
            // Convert to JSON
            do
            {
                let data = try JSONDecoder().decode ([artistPageFetchPlaylistField].self, from: data)
                DispatchQueue.main.async{
                    self?.artistPageFetchPlaylistFields = self!.artistPageFetchPlaylistFields + data
                    self?.count += 10
                }
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }
}

class getMorePLD: ObservableObject {
    @Published var artistPageFetchPLDFields: [artistPageFetchPLDField] = []
    
    func getPLD(limit: Int, action: String, artistId: String, previouslyFetched: [artistPageFetchPLDField]) async throws {
        guard let url = URL(string: HttpBaseUrl() + "/_functions/getPLD?password=yH5ln1dvzTjqzNW6heNK&action=\(action)&limit=\(limit)") else { fatalError("Missing URL") }
        
        struct PLDGetData: Codable {
            let artistId: String
            let previouslyFetched: [artistPageFetchPLDField]
        }
        
        // Add data to the model
        let PLDGetDataModel = PLDGetData(artistId: artistId, previouslyFetched: previouslyFetched)
        
        // Convert model to JSON data
        guard let jsonData = try? JSONEncoder().encode(PLDGetDataModel) else {
            print("Error: Trying to convert model to JSON data")
            return
        }
        print(PLDGetDataModel)
        print("Checkpoint1p")
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type") // the request is JSON
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept") // the response expected to be in JSON format
        urlRequest.httpBody = jsonData
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        print("Checkpoint2p")
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { print(response); return}
        print("Checkpoint3p")
        let decodedData = try JSONDecoder().decode([artistPageFetchPLDField].self, from: data)
        print("Checkpoint4p")
        DispatchQueue.main.async{
            print("Checkpoint5p")
            if action == "refresh" {
                self.artistPageFetchPLDFields = decodedData
            }else{
                self.artistPageFetchPLDFields = self.artistPageFetchPLDFields + decodedData
                PLDLoadMoreCount = decodedData.count
            }
        }
    }
}

struct PLDMusicDetails: Hashable, Codable {
    let _id: String
    let tracktitle: String
}

struct PLDOwnerDetails: Hashable, Codable {
    let _id: String
    let artistName: String
}
struct PLDAlbumDetails: Hashable, Codable {
    let _id: String
    let title: String
    let featuringArtists: String
    let coverArt: String
}
struct PLDPlaylistDetails: Hashable, Codable {
    let _id: String
    let title: String
    let wallpaper: String
}

struct artistPageFetchPLDField: Hashable, Codable {
    let _id: String
    let type: String
    let _createdDate: String
    let createdTime: Int
    let musicDetails: PLDMusicDetails?
    let ownerDetails: PLDOwnerDetails?
    let playlistDetails: PLDPlaylistDetails?
    let albumDetails: PLDAlbumDetails?
}

class artistPageFetchPLDData: ObservableObject {
    @Published var artistPageFetchPLDFields: [artistPageFetchPLDField] = []
    
    func fetchUpdate(artistId:String, itemId: String) {
        guard let url = URL(string: HttpBaseUrl() + "/_functions/postLikeData?password=yH5ln1dvzTjqzNW6heNK&type=filterEq&columnId=userId&value=\(artistId)&continueFrom=\(itemId)&noItems=true&totalFetch=50") else {
            return}
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _,
            error in
            guard let data = data, error == nil else {
                return
            }
            // Convert to JSON
            do
            {
                let data = try JSONDecoder().decode ([artistPageFetchPLDField].self, from: data)
                DispatchQueue.main.async{
                    self?.artistPageFetchPLDFields = self!.artistPageFetchPLDFields + data
                }
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }
}

struct toProfilePage: View{
    @State var isPresented: Bool = false
    var body: some View{
        if isPresented {
            navProfilePage()
        }else{
            VStack{
                Text("")
            }
            .onAppear{
                isPresented = true
            }
        }
    }
}

class postFollowUnfollow: ObservableObject {
    
    func followUnfollow(type: String, artistId: String) async throws {
        guard let url = URL(string: HttpBaseUrl() + "/_functions/followUnfollow?password=0IephR2hl1H33yg4Iyvl") else { fatalError("Missing URL") }
        struct UploadData: Codable {
            let type: String
            let artistId: String
            let currentArtistId: String
        }
        let uploadDataModel = UploadData(type: type, artistId: artistId, currentArtistId: soundlytudeUserId())
        
        guard let jsonData = try? JSONEncoder().encode(uploadDataModel) else {
            print("Error: Trying to convert model to JSON data")
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type") // the request is JSON
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept") // the response expected to be in JSON format
        urlRequest.httpBody = jsonData
        
        var (_, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { print(response); return}
    }
}
