//
//  albumPage.swift
//  Soundlytude
//
//  Created by DJ bon26 on 9/10/22.
//

import SwiftUI
import Foundation
import AVFoundation

private var AlbumPageFetchingCompleted: Bool = false

struct albumPage: View {
    @StateObject var albumPageFetch = albumPageFetchData()
    @StateObject var albumPageFetchTrack = albumPageFetchTracks()
    @StateObject var albumPageFetchMore = albumPageFetchMores()
    @State var count: Int = 0
    @State var liked: Bool = true
    @State var albumId: String = "f162c63e-526b-45f8-b400-7352e32e6dd5"
    @State var artistId: String = "0fd70b92-e4cf-4e21-b522-4ec5a22b35f1"
    @State var isDoneLoading: Bool = false
    @State private var presentAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    @State private var spacer: CGFloat = 0
    
    var body: some View {
        if isDoneLoading {
            ForEach(albumPageFetch.albumPageFields, id: \._id){ album in
                VStack{
                    ScrollView{
                        GeometryReader{ geometry in
                            VStack(alignment: .center){
                                squareImageMaxDisplay(urlString: album.coverArt ?? "")
                                    .frame(width: geometry.size.width - 160, height: geometry.size.width - 160)
                            }
                            .frame(maxWidth: .infinity)
                            .onAppear{
                                spacer = geometry.size.width - 160
                            }
                        }
                        Spacer().frame(height: spacer)
                        headerInfos(
                            albumId: albumId,
                            title: album.title,
                            artistName: album.artistDetails.artistName,
                            type: album.type)
                        Group{
                            VStack{/* dummy Vstack */}.frame(width: 1, height: 10)
                            horizontalMenuIcons(albumId: albumId, albumOwner: album.artistDetails._id, commentCount: album.commentCount ?? 0, likeCount: album.likeCount ?? 0)
                            //                                .environmentObject(globalVariable)
                            Divider()
                        }
                        ForEach(albumPageFetchTrack.albumPageTrackFields, id:\._id){idx in
                            tracksRepeater(
                                id: idx._id,
                                ownerId: idx.artistDetails?._id ?? "",
                                trackNumber: String(idx.trackNumber ?? 0),
                                title: idx.tracktitle,
                                explicit: idx.explicit,
                                albumId: albumId)
                        }
                        VStack(alignment: .leading){
                            Text("\(album.description ?? "")")
                                .font(.caption)
                                .fontWeight(.regular)
                                .foregroundColor(Color.gray)
                                .multilineTextAlignment(.leading)
                                .frame(
                                    minWidth: 0,
                                    maxWidth: .infinity,
                                    alignment: .topLeading
                                )
                        }
                        .padding(.horizontal)
                        .frame(width:viewableWidth)
                        .cornerRadius(5)
                        bodyTitle(text: "More from  \(album.artistDetails.artistName)")
                            .padding([.top, .leading, .trailing], 20.0)
                            .padding(.bottom, -20)
                        
                        ScrollView(.horizontal, showsIndicators: false){
                            HStack{
                                HStack(){/*dummy HStack */}.frame(width:5)
                                ForEach(albumPageFetchMore.albumPageMoreFields, id: \._id) {i in
                                    albumRepeater(
                                        title: i.title,
                                        subTitle: i.artistDetails
                                            .artistName,
                                        imageUrl: i.coverArt,
                                        _id: i._id,
                                        artistId: artistId
                                    )
                                }
                                HStack(){/*dummy HStack */}.frame(width:5)
                            }
                        }
                        bottomSpace()
                    }.padding(.all, 0)
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("\(album.title) - \(album.artistDetails.artistName)")
                //                .toolbar{
                //                    ToolbarItem(placement: .navigation){
                //                        Text("\(album.title) - \(album.artistDetails.artistName)")
                //                            .font(.headline)
                //                            .fontWeight(.bold)
                //                            .multilineTextAlignment(.center)
                //                            .frame(width: viewableWidth - 40)
                //                    }
                //                }
            }
        }else{
            VStack{
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.accentColor))
                    .onAppear{
                        AlbumPageFetchingCompleted = false
                        progresser()
                        albumPageFetch.fetch(albumId: albumId)
                        print(albumId)
                    }
            }
            .alert(alertTitle, isPresented: $presentAlert, actions: {
                // actions
            }, message: {
                Text(alertMessage)
            })
            .toolbar{
                ToolbarItem(placement: .navigation){
                    Text("Album")
                        .font(.headline)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .frame(width: viewableWidth - 40)
                }
            }
        }
    }
    
    func progresser() {
        if(AlbumPageFetchingCompleted){
            print("done")
            isDoneLoading = true
            albumPageFetchTrack.fetch(albumId: albumId)
            albumPageFetchMore.fetch(albumId: albumId, artistId: artistId)
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                progresser()
                if (AlbumPageFetchingCompleted == false){
                    isDoneLoading = false
                }
            }
        }
    }
}

struct albumPage_Previews: PreviewProvider {
    static var previews: some View {
        albumPage()
    }
}

struct albumImage: View{
    var body: some View {
        Image("Pull up at the mansion by DJ bon26")
            .resizable()
            .cornerRadius(10)
            .frame(width: viewableWidth - 160, height: viewableWidth - 160, alignment: .leading)
    }
}

struct horizontalMenuIcons: View {
    @State var isPresented: Bool = false
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var GlobalVariables: globalVariables
    
    @StateObject var sendAlbumLikesFunc = sendAlbumLikes()
    
    var albumId: String
    var albumOwner: String
    var commentCount: Int
    @State var likeCount: Int
    
    @State var liked: Bool = false
    @State var heartScaleEffect: CGFloat = 1
    @State var liking: Bool = true
    
    var body: some View{
        NavigationLink(destination: commentsView(albumRootIsActive: $isPresented, albumId: albumId, albumOwner: albumOwner, commentCount: commentCount).environmentObject(GlobalVariables), isActive: $isPresented) { EmptyView() }
        HStack(spacing: (viewableWidth/6)){
            Button {
                Task{
                    do {
                        if liking {
                            //Don't do nothing is stil sending request
                        }else{
                            liking = true
                            heartScaleEffect = 0.5
                            if liked {
                                liked = false
                                try await self.sendAlbumLikesFunc.sendLike(type: "Album", action: "remove", albumId: albumId, albumOwner: albumOwner)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                    liking = false
                                    likeCount = likeCount - 1
                                    heartScaleEffect = 1
                                }
                            }else{
                                liked = true
                                try await self.sendAlbumLikesFunc.sendLike(type: "Album", action: "insert", albumId: albumId, albumOwner: albumOwner)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                    liking = false
                                    likeCount = likeCount + 1
                                    heartScaleEffect = 1
                                }
                            }
                        }
                    } catch {
                        if liked {
                            liked = false
                            liking = false
                            heartScaleEffect = 1
                        }else{
                            liked = true
                            liking = false
                            heartScaleEffect = 1
                        }
                    }
                }
            } label: {
                VStack{
                    ZStack{
                        if liked {
                            Image(systemName: "heart.fill")
                                .scaleEffect(heartScaleEffect)
                                .foregroundColor(.red)
                        }else{
                            Image(systemName: "heart")
                                .scaleEffect(heartScaleEffect)
                        }
                        ProgressView().opacity(liking ? 1 : 0)
                    }
                    .font(.system(size: 25))
                    .animation(.interpolatingSpring(stiffness: 250, damping: 20), value: heartScaleEffect)
                    Text("\(likeCount)")
                        .font(.caption)
                        .if(liked) {view in
                            view.foregroundColor(.red)
                        }
                }
            }.disabled(liking)
            Button {
                isPresented = true
            } label: {
                VStack{
                    Image(systemName: "bubble.right")
                        .font(.system(size: 25))
                    Text("\(commentCount) Comments")
                        .font(.caption)
                }
            }
            Button {
                guard let urlShare = URL(string: "\(HttpBaseUrl())/album/\(albumId)") else { return }
                let activityVC = UIActivityViewController(activityItems: [urlShare], applicationActivities: nil)
                UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
            } label: {
                VStack{
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 25))
                    Text("Share")
                        .font(.caption)
                }
            }
            
        }
        .onAppear{
            checkIfLiked(albumId: albumId)
        }
    }
    
    func checkIfLiked(albumId: String) {
        let urlParam:String = "/_functions/ifAlbumLiked?password=m9wKZ4Nl3UZpquT3o8yj&albumId=\(albumId)&currentUserId=\(soundlytudeUserId())"
        
        guard let url = URL(string: HttpBaseUrl() + urlParam) else {
            print("Error: cannot create URL")
            return
        }
        // Create model
        struct checkIfLikedData: Codable {
            let albumId: String
            let currentUserId: String
        }
        
        // Add data to the model
        let checkIfLikedDataModel = checkIfLikedData(albumId: albumId, currentUserId: soundlytudeUserId())
        // Convert model to JSON data
        guard let jsonData = try? JSONEncoder().encode(checkIfLikedDataModel) else {
            print("Error: Trying to convert model to JSON data")
            return
        }
        // Create the url request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type") // the request is JSON
        request.setValue("application/json", forHTTPHeaderField: "Accept") // the response expected to be in JSON format
        //        request.httpBody = jsonData
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print("Error: error calling POST")
                print(error!)
                return
            }
            guard let data = data else {
                print("Error: Did not receive data")
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                print("Error: HTTP request failed", response)
                return
            }
            do {
                let dataReturned = try JSONDecoder().decode (standardBasicResponse.self, from: data)
                print("COMPLETED BLA", dataReturned)
                if dataReturned.message == "Success" {
                    liking = false
                    if dataReturned.scenario == "liked" {
                        liked = true
                    }else{
                        liked = false
                    }
                }
                guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    print("Error: Cannot convert data to JSON object")
                    return
                }
                guard let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) else {
                    print("Error: Cannot convert JSON object to Pretty JSON data")
                    return
                }
                guard let prettyPrintedJson = String(data: prettyJsonData, encoding: .utf8) else {
                    print("Error: Couldn't print JSON in String")
                    return
                }
                
                print(prettyPrintedJson)
            } catch {
                print("Error: Trying to convert JSON data to string")
                return
            }
        }.resume()
    }
}

struct standardBasicResponse: Hashable, Codable {
    let message: String
    let scenario: String
}

struct headerInfos: View {
    var albumId: String
    var title: String
    var artistName: String
    var type: String
    
    var body: some View{
        Text(title)
            .font(.title2)
            .fontWeight(.semibold)
            .frame(width: viewableWidth - 40)
        Text(artistName)
            .font(.title2)
            .fontWeight(.regular)
            .foregroundColor(Color.accentColor)
            .frame(width: viewableWidth - 40)
        Text(type)
            .font(.caption)
            .fontWeight(.regular)
            .foregroundColor(Color.gray)
            .frame(width: viewableWidth - 40)
            .padding(.bottom, 5)
        HStack(spacing: 20){
            Button {
                play(id: albumId, title: title, shuffle: false, type: "Album")
            } label: {
                Text("\(Image(systemName: "play.fill"))  Play")
                    .foregroundColor(Color.accentColor)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color("GrayWhite").opacity(0.1))
                    .cornerRadius(12)
            }
            Button {
                play(id: albumId, title: title, shuffle: true, type: "Album")
            } label: {
                Text("\(Image(systemName: "shuffle"))  Shuffle")
                    .foregroundColor(Color.accentColor)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color("GrayWhite").opacity(0.1))
                    .cornerRadius(12)
            }
        }.padding(.horizontal, 20)
    }
}

struct tracksRepeater: View {
    var id: String
    var ownerId: String
    var trackNumber: String
    var title: String
    var explicit: Bool
    
    var albumId: String
    
    @State var showReportView: Bool = false
    @State var showAddToPlaylistView: Bool = false
    var body: some View {
        VStack(alignment: .leading, spacing: 0.0){
            HStack{
                HStack{
                    Text(trackNumber)
                        .frame(minWidth: 10)
                        .foregroundColor(.gray)
                    Text(title)
                    (explicit) ?
                    Image(systemName: "e.square.fill")
                        .foregroundColor(.gray)
                    :
                    nil
                }
                Spacer()
                Menu {
                    Button {
                        showAddToPlaylistView = true
                    } label: {
                        Label(title: {Text("Add to Playlist")},
                              icon: {Image(systemName: "plus")})
                    }
                    Button {
                        showReportView = true
                    } label: {
                        Label(title: {Text("Report")},
                              icon: {Image(systemName: "exclamationmark.triangle.fill")})
                    }
                    
                } label: {
                    Label(title: {},
                          icon: {Image(systemName: "ellipsis")
                            .frame(width: 40, height: 40)
                    })
                }
                .sheet(isPresented: $showReportView) {
                    NavigationView {
                        ReportView(openView: $showReportView, type: "Track", contentId: id, contentOwnerId: ownerId)
                            .toolbar{
                                ToolbarItem(placement: .navigation){
                                    Text("Report")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .multilineTextAlignment(.center)
                                        .frame(width: viewableWidth - 40)
                                }
                            }
                    }
                }
                .sheet(isPresented: $showAddToPlaylistView) {
                    NavigationView {
                        AddToPlaylistView(openView: $showAddToPlaylistView, contentType: "Track", contentId: id, contentArtistId: ownerId, contentAlbum: albumId)
                            .toolbar{
                                ToolbarItem(placement: .navigation){
                                    Text("Add to Playlist")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .multilineTextAlignment(.center)
                                        .frame(width: viewableWidth - 40)
                                }
                            }
                    }
                }
            }
            Divider()
        }
        .padding(.horizontal)
    }
}

var currentViewingAlbum: albumPageField = albumPageField(_id: "", title: "", coverArt: "", featuringArtists: "", description: "", releaseDate: "", commentsEnable: false, streamCount: 0, earnings: 0, downloads: 0, licensed: false, type: "", themeColor: "", userId: "", commentCount: 0, likeCount: 0, _createdDate: "", artistDetails: albumPageArtistDetails(_id: "", artistName: "", pimage: ""))

struct albumPageArtistDetails: Hashable, Codable {
    let _id: String
    let artistName: String
    let pimage: String
}

struct albumPageField: Hashable, Codable {
    let _id: String
    let title: String
    let coverArt: String?
    let featuringArtists: String
    let description: String?
    let releaseDate: String
    let commentsEnable: Bool?
    let streamCount: Int?
    let earnings: Double?
    let downloads: Int
    let licensed: Bool?
    let type: String
    let themeColor: String?
    let userId: String
    let commentCount: Int?
    let likeCount: Int?
    let _createdDate: String
    let artistDetails: albumPageArtistDetails
}

class albumPageFetchData: ObservableObject {
    @Published var albumPageFields: [albumPageField] = []
    
    func fetch(albumId:String) {
        guard let url = URL(string: HttpBaseUrl() + "/_functions/albums?password=wNyLKt1V6357sVCZLJlH&type=filterEq&columnId=_id&value=\(albumId)&noItems=true") else {
            return}
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _,
            error in
            guard let data = data, error == nil else {
                return
            }
            // Convert to JSON
            do
            {
                let data = try JSONDecoder().decode ([albumPageField].self, from: data)
                DispatchQueue.main.async{
                    let x = data[0]
                    self?.albumPageFields = data
                    print(data)
                    AlbumPageFetchingCompleted = true
                    currentViewingAlbum = albumPageField(
                        _id: x._id,
                        title: x.title,
                        coverArt: x.coverArt ?? "",
                        featuringArtists: x.featuringArtists,
                        description: x.description ?? "",
                        releaseDate: x.releaseDate,
                        commentsEnable: x.commentsEnable ?? true,
                        streamCount: x.streamCount ?? 0,
                        earnings: x.earnings ?? 0,
                        downloads: x.downloads,
                        licensed: x.licensed ?? false,
                        type: x.type,
                        themeColor: x.themeColor ?? "",
                        userId: x.userId,
                        commentCount: x.commentCount ?? 0,
                        likeCount: x.likeCount ?? 0,
                        _createdDate: x._createdDate,
                        artistDetails: x.artistDetails)
                }
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }
}


struct albumPageField2: Hashable, Codable {
    let _id: String
    let title: String
    let coverArt: String?
    let featuringArtists: String
    let description: String?
    let releaseDate: String
    let commentsEnable: Bool?
    let streamCount: Int?
    let earnings: Double?
    let downloads: Int
    let licensed: Bool?
    let type: String
    let themeColor: String?
    let userId: String
}

struct albumPageTrackField: Hashable, Codable {
    let _id: String
    let tracktitle: String
    let audio: String?
    let streamCout: Int?
    let likeCount: Int?
    let userId: String
    let releaseDate: String
    let albumId: String
    let trackNumber: Int?
    let explicit: Bool
    let featuringArtists: String?
    let genre: String?
    let artistDetails: albumPageArtistDetails?
    let albumReference: albumPageField2
}

class albumPageFetchTracks: ObservableObject {
    @Published var albumPageTrackFields: [albumPageTrackField] = []
    
    func fetch(albumId:String) {
        guard let url = URL(string: HttpBaseUrl() + "/_functions/tracks?password=90f510B1JGbfHwNAJ0PU&type=filterEq&columnId=albumId&value=\(albumId)&noItems=true") else {
            return}
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _,
            error in
            guard let data = data, error == nil else {
                return
            }
            // Convert to JSON
            do
            {
                let data = try JSONDecoder().decode ([albumPageTrackField].self, from: data)
                DispatchQueue.main.async{
                    self?.albumPageTrackFields = data
                    print(data)
                }
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }
}

class albumPageFetchMores: ObservableObject {
    @Published var albumPageMoreFields: [FYPAlbumField] = []
    
    func fetch(albumId:String, artistId: String) {
        guard let url = URL(string: HttpBaseUrl() + "/_functions/albums?password=wNyLKt1V6357sVCZLJlH&type=filterEqNot&columnId=userId&value=\(artistId)&columnIdNot=_id&valueNot=\(albumId)&noItems=true") else {
            return }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _,
            error in
            guard let data = data, error == nil else {
                return
            }
            // Convert to JSON
            do
            {
                let data = try JSONDecoder().decode ([FYPAlbumField].self, from: data)
                DispatchQueue.main.async{
                    self?.albumPageMoreFields = data
                    print(data)
                }
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }
}

func play(id: String, title: String, shuffle: Bool, type: String) {
    if !changingTrack && playingId != id {
        let fetchTracks = fetchPlayTracks()
        playingType = type
        playingTypeTitle = title
        playingId = id
        changingTrack = true
        if type == "Album"{
            fetchTracks.fetchAlbum(albumId: id, shuffle: shuffle)
        }
        if type == "Playlist"{
            fetchTracks.fetchPlaylist(playlistId: id, shuffle: shuffle)
        }
    }else{
        if playingId == id {//making sure same Queue is the reason
            expandPlayer = true
        }
    }
}

struct playerArtistDetails: Hashable, Codable {
    let artistName: String
    let _id: String
    let pimage: String
    let verification: Bool?
}

struct playerAlbumField: Hashable, Codable {
    let _id: String
    let title: String
    let coverArt: String
    let themeColor: String
    let description: String?
    let commentCount: Int
}

struct playerField: Identifiable, Hashable, Codable {
    var id: String? = UUID().uuidString
    let _id: String
    let tracktitle: String
    let audio: String
    let userId: String
    let explicit: Bool?
    let artistDetails: playerArtistDetails
    let albumReference: playerAlbumField
}

public var publicTrackArr: Array<String> = []

class fetchPlayTracks: ObservableObject {
    @Published var trackPlayerFields: [playerField] = []
    
    func fetchAlbum(albumId:String, shuffle: Bool) {
        songs = []
        guard let url = URL(string: HttpBaseUrl() + "/_functions/tracks?password=90f510B1JGbfHwNAJ0PU&type=filterEq&columnId=albumId&value=\(albumId)&noItems=true") else {
            return}
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _,
            error in
            guard let data = data, error == nil else {
                return
            }
            // Convert to JSON
            do
            {
                let data = try JSONDecoder().decode ([playerField].self, from: data)
                DispatchQueue.main.async{
                    self?.trackPlayerFields = data
                    print(data[0].tracktitle)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                        changingTrack = false
                        changedTrack = true
                        songs = data
                        if shuffle {
                            songs = data.shuffled()
                        }else{
                            songs = data
                        }
                        currentSong = songs[0]
                    }
                }
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }
    
    func fetchPlaylist(playlistId:String, shuffle: Bool) {
        songs = []
        guard let url = URL(string: HttpBaseUrl() + "/_functions/musicTracks?password=J39yOjtOqoaipm5d5oG5&type=filterEq&columnId=filterId&value=\(playlistId)&returnType=tracksOnly&noItems=true") else {
            return}
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _,
            error in
            guard let data = data, error == nil else {
                return
            }
            // Convert to JSON
            do
            {
                let data = try JSONDecoder().decode ([playerField].self, from: data)
                DispatchQueue.main.async{
                    self?.trackPlayerFields = data
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
                        changingTrack = false
                        changedTrack = true
                        if shuffle {
                            songs = data.shuffled()
                        }else{
                            songs = data
                        }
                        currentSong = songs[0]
                    }
                }
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }
}


struct sendAlbumLikesField: Hashable, Codable {
    let message: String
    let scenario: String?
}

class sendAlbumLikes: ObservableObject {
    @Published var sendAlbumLikesFields: [sendAlbumLikesField] = []
    
    func sendLike(type: String, action: String, albumId: String, albumOwner: String) async throws {
        guard let url = URL(string: HttpBaseUrl() + "/_functions/albumLikes?password=fa7bPBLK5AG72W3sQ8bF") else { fatalError("Missing URL") }
        print(url)
        
        struct likeData: Codable {
            let type: String
            let albumId: String
            let currentUserId: String
            let albumOwner: String
        }
        
        // Add data to the model
        let likesDataModel = likeData(type: type, albumId: albumId, currentUserId: soundlytudeUserId(), albumOwner: albumOwner)
        
        // Convert model to JSON data
        guard let jsonData = try? JSONEncoder().encode(likesDataModel) else {
            print("Error: Trying to convert model to JSON data")
            return
        }
        print("Checkpoint1")
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = (action == "insert" ? "PUT" : "DELETE")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type") // the request is JSON
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept") // the response expected to be in JSON format
        urlRequest.httpBody = jsonData
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        print("Checkpoint2")
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { print(response); return}
        print("Checkpoint3")
        let decodedData = try JSONDecoder().decode([sendAlbumLikesField].self, from: data)
        print("Checkpoint4")
        DispatchQueue.main.async{
            print("Checkpoint5")
            self.sendAlbumLikesFields = decodedData
            if decodedData[0].message == "Success" {
                print("Done interaction")
                print(decodedData[0].scenario ?? "")
            }
        }
    }
}
