//
//  AddToPlaylistView.swift
//  Soundlytude (iOS)
//
//  Created by DJ bon26 on 3/20/24.
//

import SwiftUI
var exploreLoadMoreCount:Int = 0
var exploreCommentsLoadMoreCount:Int = 0
var playlistLoadMoreCount:Int = 0
var PLDLoadMoreCount:Int = 0
var notifLoadMoreCount:Int = 0

struct AddToPlaylistView: View {
    @StateObject var GetPlaylists = getMorePlaylists()
    
    @Binding var openView: Bool
    @State var contentType: String = ""
    @State var contentId: String = ""
    @State var contentArtistId: String = ""
    @State var contentAlbum: String = ""
    
    @State private var selectedPlaylistsId: [String] = []
    
    @State var disableLoadMore: Bool = false
    @State var disableAddToPlaylist: Bool = false
    
    @State private var presentAlert = false
    @State private var presentAlertTitle = ""
    @State private var presentAlertMessage = ""
    let limit = 3
    
    var body: some View {
        VStack{
            ForEach(GetPlaylists.artistPageFetchPlaylistFields, id: \._id){ playlist in
                Button{
                    if selectedPlaylistsId.contains(playlist._id) {
                        selectedPlaylistsId.remove(at: selectedPlaylistsId.firstIndex(of: playlist._id)!)
                    }else{
                        selectedPlaylistsId.append(playlist._id)
                    }
                }label: {
                    HStack{
                        Image(systemName: selectedPlaylistsId.contains(playlist._id) ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(Color.accentColor)
                        playlistsView(title: playlist.title, genre: playlist.genre, wallpaper: playlist.wallpaper)
                            .padding(.horizontal, 2.5)
                    }
                }
                .opacity(playlist.contents.contains(playlistContents(_id: contentId, type: contentType)) ? 0.5 : 1)
                .disabled(playlist.contents.contains(playlistContents(_id: contentId, type: contentType)))
                .padding(.horizontal)
            }
            if !disableLoadMore{
                Button {
                    Task{
                        do {
                            disableLoadMore = true
                            try await GetPlaylists.getPlaylists(limit: limit, action: "load", creatorId: soundlytudeUserId(), previouslyFetched: GetPlaylists.artistPageFetchPlaylistFields)
                            if playlistLoadMoreCount < limit {
                                disableLoadMore = true
                            }else{
                                disableLoadMore = false
                            }
                        }catch{
                            
                        }
                    }
                } label: {
                    Text("Load more")
                }.disabled(disableLoadMore)
            }
            Spacer()
            Button {
                disableAddToPlaylist = true
                postAddPlaylist()
            } label: {
                Text("Add to playlist")
            }.disabled(selectedPlaylistsId.count < 1 ? true : disableAddToPlaylist)
        }
        .onAppear{
            Task{
                do {
                    try await GetPlaylists.getPlaylists(limit: limit, action: "load", creatorId: soundlytudeUserId(), previouslyFetched: GetPlaylists.artistPageFetchPlaylistFields)
                    if playlistLoadMoreCount < limit {
                        disableLoadMore = true
                    }else{
                        disableLoadMore = false
                    }
                }catch{
                    
                }
            }
        }
        .alert(presentAlertTitle, isPresented: $presentAlert, actions: {
            Button("OK", role: .cancel, action: {openView = false})
        }, message: {
            Text(presentAlertMessage)
        })
        
        //        func ifContainsSelected(id: String) -> Bool {
        //            let filtered = selectedPlaylistsId.filter { member in
        //                return member._id == id
        //            }
        //            if filtered.count > 0 {
        //                return true
        //            }else{
        //                return false
        //            }
        //        }
    }
    
    @ViewBuilder
    func playlistsView(title: String, genre: String, wallpaper: String) -> some View {
        HStack{
            squareImage48by48(urlString: wallpaper, borderWidth: 1, borderColor: Color("SecondaryColor"))
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
    }
    
    //    @ViewBuilder
    //    func playlistsViewSelectedPlaylist() -> some View {
    //        Button {
    //            if ifContainsSelected(id: x._id){
    //                createChatRemoveSelectedMember(id: x._id)
    //            }else{
    //                withAnimation(.easeIn(duration: 0.1)){
    //                    createChatSelectedMembers.append(createChatSelectedMembersField(_id: x._id, artistName: x.artistName, pimage: x.pimage))
    //                    createChatSelectedMembersId.append(x._id)
    //                    showImage.toggle()
    //                }
    //            }
    //        } label: {
    //            HStack{
    //                if showImage {
    //                    circleImage40by40(urlString: x.pimage)
    //                }else{
    //                    //                                    Color.clear.frame(width: 40, height: 40)
    //                    circleImage40by40(urlString: x.pimage)
    //                }
    //                VStack(alignment: .leading){
    //                    HStack{
    //                        Text(x.artistName)
    //                            .fontWeight(.bold)
    //                            .foregroundColor(x.verification ?? false ? themeColorMix : nil)
    //                        if (x.verification ?? false) {
    //                            Image(systemName: "checkmark.seal.fill")
    //                                .font(.caption)
    //                                .foregroundColor(themeColorMix)
    //                        }
    //                    }
    //                    Text("@\(x.slug)")
    //                        .font(.caption)
    //                        .fontWeight(.bold)
    //                        .foregroundColor(.gray)
    //                }
    //                Spacer()
    //                HStack{
    //                    Sticker(text: friends ? "Friends" : youFollowThem ? "You follow them" : theyFollowYou ? "Follows you" : "")
    //                    Image(systemName: ifContainsSelected(id: x._id) ? "checkmark.circle.fill" : "circle")
    //                        .foregroundColor(Color.accentColor)
    //                }
    //            }
    //            .padding([.horizontal, .vertical])
    //            .foregroundColor(Color("BlackWhite"))
    //        }
    //        .padding(0)
    //        .opacity(friends ? 1 : 0.5)
    //        .background(friends ? Color.clear : Color.gray.opacity(0.075))
    //        .disabled(friends ? false : true)
    //    }
    
    
    func postAddPlaylist() {
        guard let url = URL(string: HttpBaseUrl() + "/_functions/playlists?password=kv7Tbih4HoDv6pdPW88T") else {
            print("Error: cannot create URL")
            return
        }
        
        struct playlistAddData: Codable {
            let contentId: String
            let contentArtistId: String
            let contentAlbum: String
            let selectedPlaylistsId: [String]
        }
        
        // Add data to the model
        let playlistAddDataModel = playlistAddData(contentId: contentId, contentArtistId: contentArtistId, contentAlbum: contentAlbum, selectedPlaylistsId: selectedPlaylistsId)
        
        // Convert model to JSON data
        guard let jsonData = try? JSONEncoder().encode(playlistAddDataModel) else {
            print("Error: Trying to convert model to JSON data")
            return
        }
        // Create the url request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                presentAlert = true
                presentAlertTitle = "WARNING"
                presentAlertMessage = "There was an error proceeding. Failed to send a request"
                print(error!)
                return
            }
            guard let data = data else {
                presentAlert = true
                presentAlertTitle = "WARNING"
                presentAlertMessage = "There was an error proceeding. Did not recieve a response from server"
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                print("Error: HTTP request failed", response)
                openView = false
                return
            }
            do
            {
                let data = try JSONDecoder().decode ([standardBasicResponse].self, from: data)
                DispatchQueue.main.async{
                    openView = false
                    print(data[0].scenario)
                    print(data[0].message)
                }
            }
            catch {
                presentAlert = true
                presentAlertTitle = "WARNING"
                presentAlertMessage = "There was an error proceeding. \(error)"
                print(error)
            }
        }.resume()
    }
}

//struct AddToPlaylistView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddToPlaylistView()
//    }
//}

class getMorePlaylists: ObservableObject {
    @Published var artistPageFetchPlaylistFields: [artistPageFetchPlaylistField] = []
    
    func getPlaylists(limit: Int, action: String, creatorId: String, previouslyFetched: [artistPageFetchPlaylistField]) async throws {
        guard let url = URL(string: HttpBaseUrl() + "/_functions/getPlaylists?password=x3J40Mnd37y31oVjPY2k&action=\(action)&limit=\(limit)") else { fatalError("Missing URL") }
        //        if previouslyFetched.count > 0{
        print(creatorId)
        //        }
        
        struct playlistGetData: Codable {
            let creatorId: String
            let previouslyFetched: [artistPageFetchPlaylistField]
        }
        
        // Add data to the model
        let playlistGetDataModel = playlistGetData(creatorId: creatorId, previouslyFetched: previouslyFetched)
        
        // Convert model to JSON data
        guard let jsonData = try? JSONEncoder().encode(playlistGetDataModel) else {
            print("Error: Trying to convert model to JSON data")
            return
        }
        print("Checkpoint1")
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type") // the request is JSON
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept") // the response expected to be in JSON format
        urlRequest.httpBody = jsonData
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        print("Checkpoint2")
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { print(response); return}
        print("Checkpoint3")
        let decodedData = try JSONDecoder().decode([artistPageFetchPlaylistField].self, from: data)
        print("Checkpoint4")
        DispatchQueue.main.async{
            print("Checkpoint5")
            if action == "refresh" {
                self.artistPageFetchPlaylistFields = decodedData
            }else{
                self.artistPageFetchPlaylistFields = self.artistPageFetchPlaylistFields + decodedData
                playlistLoadMoreCount = decodedData.count
            }
        }
    }
}
