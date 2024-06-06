//
//  playlistPage.swift
//  Soundlytude
//
//  Created by DJ bon26 on 10/28/22.
//

import SwiftUI
import Foundation

var playlistPageFetchingCompleted: Bool = false

struct playlistPage: View {
    @StateObject var playlistPageFetch = playlistPageFetchData()
    @StateObject var playlistPageFetchTrack = playlistPageFetchTracks()
    @State var count: Int = 0
    @State var liked: Bool = true
    @State var playlistId: String = "14f96913-f2aa-4da6-9798-a7b7c8086a72"
    @State var creatorId: String = "0fd70b92-e4cf-4e21-b522-4ec5a22b35f1"
    @State var isDoneLoading: Bool = false
    @State private var presentAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    @State private var spacer: CGFloat = 0
    
    var body: some View {
        if isDoneLoading {
            ForEach(playlistPageFetch.playlistPageFields, id: \._id){ playlist in
                ScrollView{
                    GeometryReader{ geometry in
                        VStack(alignment: .center){
                            squareImageMaxDisplay(urlString: playlist.wallpaper ?? "")
                                .frame(width: geometry.size.width - 160, height: geometry.size.width - 160)
                        }
                        .frame(maxWidth: .infinity)
                        .onAppear{
                            spacer = geometry.size.width - 160
                        }
                    }
                    Spacer().frame(height: spacer)
                    playlistHeaderInfos(
                        playlistId: playlistId,
                        title: playlist.title,
                        artistName: playlist.artistDetails.artistName,
                        type: playlist.genre)
                    Group{
                        VStack{/* dummy Vstack */}.frame(width: 1, height: 10)
                        playlistHorizontalMenuIcons(playlistId: playlistId, playlistOwner: creatorId, likes: playlist.likes.count, liked: playlist.likes.contains(playlistPageLikesDetails(_id: soundlytudeUserId())))
                        Divider()
                    }
                    ForEach(0..<playlistPageFetchTrack.playlistPageTrackFields.count, id:\.self){i in
                        songsRepeater(
                            trackNumber: String(i+1),
                            title: playlistPageFetchTrack.playlistPageTrackFields[i].musicDetails.tracktitle,
                            explicit: playlistPageFetchTrack.playlistPageTrackFields[i].musicDetails.explicit,
                            artistName: playlistPageFetchTrack.playlistPageTrackFields[i].artistDetails.artistName,
                            artWork: playlistPageFetchTrack.playlistPageTrackFields[i].albumReference.coverArt ?? ""
                        )
                    }
                    VStack(alignment: .leading){
                        Text("\(playlist.description ?? "")")
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
                    bodyTitle(text: "More from  \(playlist.artistDetails.artistName)")
                        .padding([.top, .leading, .trailing], 20.0)
                        .padding(.bottom, -20)
                    
//                    ScrollView(.horizontal, showsIndicators: false){
//                        HStack{
//                            HStack(){/*dummy HStack */}.frame(width:5)
//                            HStack(){/*dummy HStack */}.frame(width:5)
//                        }
//                    }
                    bottomSpace()
                }
                .tint(Color("SecondaryColor"))
                .toolbar{
                    ToolbarItem(placement: .navigation){
                        Text(playlist.title)
                            .font(.headline)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .frame(width: viewableWidth - 40)
                    }
                }
            }
        }else{
            VStack{
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color("SecondaryColor")))
                    .onAppear{
                        playlistPageFetchingCompleted = false
                        progresser()
                        playlistPageFetch.fetch(playlistId: playlistId)
                    }
            }
            .alert(alertTitle, isPresented: $presentAlert, actions: {
                // actions
            }, message: {
                Text(alertMessage)
            })
            .toolbar{
                ToolbarItem(placement: .navigation){
                    Text("Playlist")
                        .font(.headline)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .frame(width: viewableWidth - 40)
                }
            }
        }
    }
    
    func progresser() {
        if(playlistPageFetchingCompleted){
            print("done")
            isDoneLoading = true
            playlistPageFetchTrack.fetch(playlist: playlistId)
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                progresser()
                if (playlistPageFetchingCompleted == false){
                    isDoneLoading = false
                }
            }
        }
    }
}

struct playlistPage_Previews: PreviewProvider {
    static var previews: some View {
        playlistPage()
    }
}

struct playlistHorizontalMenuIcons: View {
    @State var isPresented: Bool = false
    @Environment(\.colorScheme) var colorScheme
    var playlistId: String
    var playlistOwner: String
    
    @StateObject var sendPlaylistLikesFunc = sendPlaylistLikes()
    
    @State var likes: Int = 0
    @State var liked: Bool = false
    @State var heartScaleEffect: CGFloat = 1
    @State var liking: Bool = false
    
    var body: some View{
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
                            try await self.sendPlaylistLikesFunc.sendLike(type: "Playlist", action: "remove", playlistId: playlistId, playlistOwner: playlistOwner)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                liking = false
                                likes = likes - 1
                                heartScaleEffect = 1
                            }
                        }else{
                            liked = true
                            try await self.sendPlaylistLikesFunc.sendLike(type: "Playlist", action: "insert", playlistId: playlistId, playlistOwner: playlistOwner)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                liking = false
                                likes = likes + 1
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
                Text("\(likes)")
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
                    Text("Comments")
                        .font(.caption)
                }
            }
            .sheet(isPresented: $isPresented) {
                ZStack{
                    VStack{
                        colorScheme == .dark ? Color.black : Color.white
                    }.opacity(0.75)
                    Text("Comments section")
                }
                .background(BackgroundBlurView())
            }
            Button {
                guard let urlShare = URL(string: "\(HttpBaseUrl())/playlist/\(playlistId)") else { return }
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
    }
}
struct playlistHeaderInfos: View {
    var playlistId: String
    var title: String
    var artistName: String
    var type: String
    
    var body: some View{
        Text(title)
            .font(.title2)
            .fontWeight(.semibold)
            .multilineTextAlignment(.center)
            .frame(width: viewableWidth - 40)
        Text(artistName)
            .font(.title2)
            .fontWeight(.regular)
            .foregroundColor(Color("SecondaryColor"))
            .frame(width: viewableWidth - 40)
        Text(type)
            .font(.caption)
            .fontWeight(.regular)
            .foregroundColor(Color.gray)
            .frame(width: viewableWidth - 40)
            .padding(.bottom, 5)
        HStack(spacing: 20){
            Button {
                play(id: playlistId, title: title, shuffle: false, type: "Playlist")
            } label: {
                Text("\(Image(systemName: "play.fill"))  Play")
                    .foregroundColor(Color("SecondaryColor"))
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color("GrayWhite").opacity(0.1))
                    .cornerRadius(12)
            }
            Button {
                play(id: playlistId, title: title, shuffle: true, type: "Playlist")
            } label: {
                Text("\(Image(systemName: "shuffle"))  Shuffle")
                    .foregroundColor(Color("SecondaryColor"))
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color("GrayWhite").opacity(0.1))
                    .cornerRadius(12)
            }
        }.padding(.horizontal, 20)
    }
}

struct songsRepeater: View {
    var trackNumber: String
    var title: String
    var explicit: Bool
    var artistName: String
    var artWork: String
    var body: some View {
        VStack(alignment: .leading, spacing: 5){
            HStack(spacing: 0){
                squareImage48by48(urlString: artWork)
                    .padding(.leading, 17)
                    .padding(.trailing, 10)
//                Text(trackNumber)
//                    .frame(minWidth: 10)
//                    .foregroundColor(.gray)
                VStack(alignment: .leading){
                    HStack(spacing: 3){
                        Text(title)
                        (explicit) ?
                        Image(systemName: "e.square.fill")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        :
                        nil
                    }
                    Text(artistName)
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                Spacer()
                Menu {
                    Button {} label: {
                        Label(title: {Text("Add to Playlist")},
                              icon: {Image(systemName: "plus")})
                    }
                    Button {} label: {
                        Label(title: {Text("Report")},
                              icon: {Image(systemName: "exclamationmark.triangle.fill")})
                    }
                    
                } label: {
                    Label(title: {},
                          icon: {Image(systemName: "ellipsis")
                            .frame(width: 40, height: 40)
                    })
                }
                .padding(.horizontal)
            }
            Divider()
                .padding(.leading, 75)
        }
    }
}

struct playlistPageArtistDetails: Hashable, Codable {
    let _id: String
    let artistName: String
    let pimage: String
}

struct playlistPageLikesDetails: Hashable, Codable {
    let _id: String
}

struct playlistPageField: Hashable, Codable {
    let _id: String
    let title: String
    let wallpaper: String?
    let likes: [playlistPageLikesDetails]
    let description: String?
    let creatorId: String?
    let genre: String
    let _createdDate: String
    let artistDetails: playlistPageArtistDetails
}

class playlistPageFetchData: ObservableObject {
    @Published var playlistPageFields: [playlistPageField] = []
    
    func fetch(playlistId:String) {
        guard let url = URL(string: HttpBaseUrl() + "/_functions/playlists?password=Ycm1Wqxyfwz3y12OR9IQ&type=filterEq&columnId=_id&value=\(playlistId)&noItems=true") else {
            return}
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _,
            error in
            guard let data = data, error == nil else {
                return
            }
            // Convert to JSON
            do
            {
                let data = try JSONDecoder().decode ([playlistPageField].self, from: data)
                DispatchQueue.main.async{
                    self?.playlistPageFields = data
                    print(data)
                    playlistPageFetchingCompleted = true
                }
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }
}


struct playlistPageField2: Hashable, Codable {
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

struct playlistTrackField: Hashable, Codable {
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
}

struct playlistPageTrackField: Hashable, Codable {
    let _id: String
    let musicDetails: playlistTrackField
    let artistDetails: playlistPageArtistDetails
    let albumReference: playlistPageField2
}

class playlistPageFetchTracks: ObservableObject {
    @Published var playlistPageTrackFields: [playlistPageTrackField] = []
    
    func fetch(playlist:String) {
        guard let url = URL(string: HttpBaseUrl() + "/_functions/musicTracks?password=J39yOjtOqoaipm5d5oG5&type=filterEq&columnId=filterId&value=\(playlist)&noItems=true") else {
            return}
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _,
            error in
            guard let data = data, error == nil else {
                return
            }
            // Convert to JSON
            do
            {
                let data = try JSONDecoder().decode ([playlistPageTrackField].self, from: data)
                DispatchQueue.main.async{
                    self?.playlistPageTrackFields = data
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

class sendPlaylistLikes: ObservableObject {
    @Published var sendAlbumLikesFields: [sendAlbumLikesField] = []
    
    func sendLike(type: String, action: String, playlistId: String, playlistOwner: String) async throws {
        guard let url = URL(string: HttpBaseUrl() + "/_functions/playlistLikes?password=7n3WFAH39XEgJD4hEDyB") else { fatalError("Missing URL") }
        print(url)
        
        struct likeData: Codable {
            let type: String
            let playlistId: String
            let currentUserId: String
            let playlistOwner: String
        }
        
        // Add data to the model
        let likesDataModel = likeData(type: type, playlistId: playlistId, currentUserId: soundlytudeUserId(), playlistOwner: playlistOwner)
        
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
