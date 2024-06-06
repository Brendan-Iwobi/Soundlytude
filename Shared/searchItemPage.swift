//
//  searchItemPage.swift
//  Soundlytude (iOS)
//
//  Created by DJ bon26 on 1/16/23.
//

import SwiftUI

struct searchItemPage: View {
    @StateObject var FetchSearchClass = fetchSearchClass()
    @State var search: String = ""
    @State var videoPlayerIsActivated: Bool = false
    @EnvironmentObject var webviewVariable : webviewVariables
    
    var body: some View {
        NavigationView {
            VStack{
                List(){
                    ForEach(FetchSearchClass.SIPitemsFields, id: \.self){search in
                        let Snippet = search.snippet
                        let videoId = search.id.videoId
                        let thumbnail = "https://i.ytimg.com/vi/\(search.id.videoId)/default.jpg"
                        let poster = "https://i.ytimg.com/vi/\(search.id.videoId)/sddefault.jpg"
                        let url = "https://lytudeyt2url.netlify.app/player.html?url=\(videoId)&poster=\(poster)"
//                        NavigationLink(destination: PlayerView(id: url)) {
//                            HStack(){
//                                squareImage64by64(urlString: thumbnail, imageTitle: Snippet.title ?? "")
//                                    .padding(.horizontal, 5)
//                                VStack{
//                                    HStack{
//                                        Text(Snippet.title?.replacingOccurrences(of: "&#39;", with: "'").replacingOccurrences(of: "&quot;", with: "\"") ?? " - No title")
//                                            .multilineTextAlignment(.leading)
//                                        Spacer()
//                                    }
//                                    HStack{
//                                        Text(Snippet.channelTitle?.replacingOccurrences(of: "&#39;", with: "'").replacingOccurrences(of: "&quot;", with: "\"") ?? " - No title")
//                                            .font(.caption)
//                                            .foregroundColor(.gray)
//                                            .padding(.vertical, 0.5)
//                                            .multilineTextAlignment(.leading)
//                                        Spacer()
//                                    }
//                                }
//                                Spacer()
//                            }
//                        }
                        Button {
                            print("url: ", url)
                            let incaseFailUrl = "https://lytudeyt2url.netlify.app/player.html?url=\(videoId)&album=Soundlytude".replacingOccurrences(of: " ", with: "%20")
                            let url = URL(string: "https://lytudeyt2url.netlify.app/player.html?url=\(videoId)&album=\(Snippet.title ?? "Soundlytude")".replacingOccurrences(of: " ", with: "%20")) ?? URL(string: incaseFailUrl)
                            videoPlayerIsActivated = true
                            withAnimation(.spring()) {
                                webviewVariable.isMaximized = true
                                webviewVariable.useMaximized = true
                                webviewVariable.url = url!
                            }
                        } label: {
                            HStack(){
                                squareImage64by64(urlString: thumbnail, imageTitle: Snippet.title ?? "")
                                    .padding(.horizontal, 5)
                                VStack{
                                    HStack{
                                        Text(Snippet.title?.replacingOccurrences(of: "&#39;", with: "'").replacingOccurrences(of: "&amp;", with: "&").replacingOccurrences(of: "&lt;", with: "<").replacingOccurrences(of: "&gt;", with: ">").replacingOccurrences(of: "&quot;", with: "\"") ?? " - No title")
                                            .multilineTextAlignment(.leading)
                                        Spacer()
                                    }
                                    HStack{
                                        Text(Snippet.channelTitle?.replacingOccurrences(of: "&#39;", with: "'").replacingOccurrences(of: "&amp;", with: "&").replacingOccurrences(of: "&lt;", with: "<").replacingOccurrences(of: "&gt;", with: ">").replacingOccurrences(of: "&quot;", with: "\"") ?? "-")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                            .padding(.vertical, 0.5)
                                            .multilineTextAlignment(.leading)
                                        Spacer()
                                    }
                                }
                                Spacer()
                            }
                        }
//                        .background(
//                            NavigationLink(destination: PlayerView(id: url), isActive: $videoPlayerIsActivated) {
//                                EmptyView()
//                            }
//                                .hidden()
//                        )
                    }
                    Spacer()
                        .listRowSeparator(.hidden)
                    .frame(height: globalPaddingBottom)
                }
                .listStyle(PlainListStyle())
            }
            .searchable(text: $search)
            .onSubmit(of: .search, runSearch)
            .navigationTitle("Search")
        }
    }
    
    func runSearch() {
        Task{
            do {
                try await FetchSearchClass.search(query: search.replacingOccurrences(of: "’", with: "").replacingOccurrences(of: "'", with: ""))
            }catch{
                print("error")
            }
        }
    }
    
    func runSearch2() {
        print(search)
//        getMethod(query: search)
    }
}

struct searchItemPage_Previews: PreviewProvider {
    static var previews: some View {
        searchItemPage()
    }
}

struct SIPFetchedDataField: Hashable, Codable {
    var items: [SIPitems]
}

struct SIPitems: Hashable, Codable {
    let id: VideoId
    let snippet: Snippet
}
struct VideoId: Hashable, Codable {
    let videoId: String
}
struct Snippet: Hashable, Codable {
    let channelId: String
    let channelTitle: String?
    let description: String?
    let title: String?
    let thumbnails: ImgSize
}
struct ImgSize: Hashable, Codable {
    let high: ImgSrc
    let medium: ImgSrc
}
struct ImgSrc: Hashable, Codable {
    let url: String
    let width: Int
    let height: Int
}

class fetchSearchClass: ObservableObject {
    @Published var SIPitemsFields: [SIPitems] = []
    
    func search(query: String) async throws {
        guard let url = URL(string: "https://www.googleapis.com/youtube/v3/search?part=snippet&key=\(APIKey())&q=\(query.replacingOccurrences(of: " ", with: "+").replacingOccurrences(of: "'", with: ""))&maxResults=25&videoCategoryId=10&type=video") else { return print("https://www.googleapis.com/youtube/v3/search?part=snippet&key=\(APIKey())&q=\(query.replacingOccurrences(of: " ", with: "+"))&maxResults=25&videoCategoryId=10&type=video") }
        print("checkpoint 1: ", url)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        print("checkpoint 2: ", data)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { print(response); return}
        print("checkpoint 3: ", response)
        let decodedData = try JSONDecoder().decode(SIPFetchedDataField.self, from: data)
        DispatchQueue.main.async{
            self.SIPitemsFields = decodedData.items
        }
    }
}

func getMethod(query: String) {
    guard let url = URL(string: "https://www.googleapis.com/youtube/v3/search?part=snippet&key=\(APIKey())&q=\(query.replacingOccurrences(of: " ", with: "+"))&maxResults=50") else {
        print("Error: cannot create URL")
        return
    }
    // Create the url request
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    URLSession.shared.dataTask(with: request) { data, response, error in
        guard error == nil else {
            print("Error: error calling GET")
            print(error!)
            return
        }
        guard let data = data else {
            print("Error: Did not receive data")
            return
        }
        guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
            print("Error: HTTP request failed")
            return
        }
        do {
            guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                print("Error: Cannot convert data to JSON object")
                return
            }
            guard let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) else {
                print("Error: Cannot convert JSON object to Pretty JSON data")
                return
            }
            guard let prettyPrintedJson = String(data: prettyJsonData, encoding: .utf8) else {
                print("Error: Could print JSON in String")
                return
            }
            
            print(prettyPrintedJson)
        } catch {
            print("Error: Trying to convert JSON data to string")
            return
        }
    }.resume()
}
