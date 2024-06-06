//
//  followersFollowingView.swift
//  Soundlytude (iOS)
//
//  Created by DJ bon26 on 12/3/22.
//

import SwiftUI

private var followersFetchedAll: Bool = false
private var followingFetchedAll: Bool = false

struct followersFollowingView: View {
    @StateObject var followers = fetchFollowersFollowing()
    @StateObject var following = fetchFollowersFollowing()
    
    @Environment(\.colorScheme) var colorScheme
    
    var artistId: String = ""
    var artistName: String = "DJ bon26"
    
    
    @State var currentType: String = "Followers"
    @State var fetched: Array<String> = []
    @State var followersIsFetching: Bool = false
    @State var followingIsFetching: Bool = false
    @State private var followersSearchText = ""
    @State private var followingSearchText = ""
    @State private var isFiltering: Bool = false
    
    @Namespace var animation
    
    var filteredFollowersArtists: [followersFollowingField] {
        if followersSearchText ==
            "" {return followers.followersFollowingFields}
        return followers.followersFollowingFields.filter {
            $0.artistName.localizedCaseInsensitiveContains(followersSearchText.localizedLowercase)
        }
    }
    var filteredFollowingArtists: [followersFollowingField] {
        if followingSearchText ==
            "" {return following.followersFollowingFields}
        return following.followersFollowingFields.filter {
            $0.artistName.localizedCaseInsensitiveContains(followingSearchText.localizedLowercase)
        }
    }
    
    @Environment(\.dismiss) var dismiss
    
    var themeColor: String = "DJ bon26"
    var accentColorMix: Color {
        return Color(UIColor.blend(color1: UIColor(Color(hexStringToUIColor(hex: "#\(themeColor.replacingOccurrences(of: "#", with: ""))"))), intensity1: 0.8, color2: UIColor(colorScheme == .dark ? Color.white : Color.black), intensity2: 0.2))
    }
    
    var body: some View {
        ScrollView{
            LazyVStack(pinnedViews: [.sectionHeaders]){
                Section {
                    ScrollView{
                        Spacer().frame(height: 50)
                        if currentType == "Followers" {
                            VStack{
                                if followers.followersFollowingFields.count > 0 {
                                    if isFiltering == false{
                                        ForEach(0..<filteredFollowersArtists.count, id:\.self){i in
                                            let x = filteredFollowersArtists[i]
                                            NavigationLink(destination: profilePage(artistId: x._id, navigatedTo: true).navigationBarBackButtonHidden(true)) {
                                                inlineProfileLink(artistId: x._id, artistName: x.artistName, pimage: x.pimage, slug: x.slug, verification: x.verification ?? false, themeColor: x.themeColor ?? "000000")
                                                    .padding(.horizontal)
                                                    .onAppear{
                                                        Task{
                                                            do {
                                                                if (i == (self.followers.followersFollowingFields.count - 1) && followersFetchedAll == false){
                                                                    followersIsFetching = true
                                                                    try await self.followers.fetchMoreFollowersFollowing(continueFromId: x._id, artistId: artistId, tab: "Followers")
                                                                    followersIsFetching = false
                                                                }
                                                            } catch {
                                                                print("Couldn't complete fetch")
                                                            }
                                                        }
                                                    }
                                            }
                                        }
                                    }else{
                                        ProgressView()
                                    }
                                    if filteredFollowersArtists.count < 1 && followersSearchText != ""{
                                        noItemsView(title: "No users found", message: "This might be inaccurate as it only filters the loaded artists but try searching for another artist")
                                    }
                                } else {
                                    if (followersIsFetching == false){
                                        noItemsView(title: "No followers", message: "When \(artistName) have followers, They'll appear here")
                                    }
                                }
                                ProgressView()
                                    .opacity((followersIsFetching) ? 1 : 0)
                            }.onAppear{
                                Task{
                                    do {
                                        if fetched.contains("Followers"){ }else{
                                            followersFetchedAll = false
                                            followersIsFetching = true
                                            fetched.append("Followers")
                                            try await self.followers.fetchMoreFollowersFollowing(continueFromId: "x", artistId: artistId, tab: "Followers")
                                            followersIsFetching = false
                                        }
                                    } catch {
                                        print("Couldn't complete fetch")
                                    }
                                }
                            }
                            .searchable(text: $followersSearchText.onChange(onSearchChange), placement: .navigationBarDrawer(displayMode: .automatic), prompt: "Search Followers")
                        }
                        if currentType == "Following" {
                            VStack{
                                if following.followersFollowingFields.count > 0{
                                    if isFiltering == false {
                                        ForEach(0..<filteredFollowingArtists.count, id:\.self){i in
                                            let x = filteredFollowingArtists[i]
                                            NavigationLink(destination: profilePage(artistId: x._id, navigatedTo: true).navigationBarBackButtonHidden(true)) {
                                                inlineProfileLink(artistId: x._id, artistName: x.artistName, pimage: x.pimage, slug: x.slug, verification: x.verification ?? false, themeColor: x.themeColor ?? "000000")
                                                    .padding(.horizontal)
                                                    .onAppear{
                                                        Task{
                                                            do {
                                                                if (i == (self.following.followersFollowingFields.count - 1) && followingFetchedAll == false){
                                                                    followingIsFetching = true
                                                                    try await self.following.fetchMoreFollowersFollowing(continueFromId: x._id, artistId: artistId, tab: "Following")
                                                                    followingIsFetching = false
                                                                }
                                                            } catch {
                                                                print("Couldn't complete fetch")
                                                            }
                                                        }
                                                    }
                                            }
                                        }}else{
                                            ProgressView()
                                        }
                                    if filteredFollowingArtists.count < 1 && followingSearchText != ""{
                                        noItemsView(title: "No users found", message: "This might be inaccurate as it only filters the loaded artists but try searching for another artist")
                                    }
                                }else{
                                    if (followingIsFetching == false){
                                        noItemsView(title: "Not following anyone", message: "When \(artistName) follow artists, They'll appear here")
                                    }
                                }
                                ProgressView()
                                    .opacity((followingIsFetching) ? 1 : 0)
                            }.onAppear{
                                Task{
                                    do {
                                        if fetched.contains("Following"){ }else{
                                            followingFetchedAll = false
                                            fetched.append("Following")
                                            followingIsFetching = true
                                            try await self.following.fetchMoreFollowersFollowing(continueFromId: "x", artistId: artistId, tab: "Following")
                                            followingIsFetching = false
                                        }
                                    } catch {
                                        print("Couldn't complete fetch")
                                    }
                                }
                            }
                            .searchable(text: $followingSearchText.onChange(onSearchChange), placement: .navigationBarDrawer(displayMode: .automatic), prompt: "Search Following")
                        }
                        bottomSpace()
                    }
                } header: {
                    PinnedHeaderView()
                }
            }
        }
        .tint(accentColorMix)
        .accentColor(accentColorMix)
        .navigationTitle(artistName)
    }
    
    @ViewBuilder
    func PinnedHeaderView() -> some View{
        let types: [String] = ["Followers", "Following"]
        GeometryReader{ geo in
            let width = (geo.size.width)/2
            ZStack{
                Blur(style: (colorScheme == .dark) ? .dark : .light)
                    .frame(maxWidth: .infinity)
                HStack() {
                    ForEach(types, id: \.self){type in
                        VStack(){
                            Spacer()
                            Text(type)
                                .frame(width: width)
                                .font(.callout)
                                .foregroundColor((currentType == type) ? (colorScheme == .dark) ? .white : .black : .gray)
                            
                            ZStack{
                                if type == currentType {
                                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                                        .fill(accentColorMix)
                                        .frame(width: width, height: 2.5)
                                        .matchedGeometryEffect(id: "TAB", in: animation)
                                }else{
                                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                                        .fill(.clear)
                                        .frame(width: width, height: 2.5)
                                }
                            }
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
        }
    }
    
    func onSearchChange(to value: String) {
        isFiltering = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isFiltering = false
        }
    }
}

struct followersFollowingView_Previews: PreviewProvider {
    static var previews: some View {
        followersFollowingView()
    }
}

struct inlineProfileLink: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State var artistId: String
    @State var artistName: String
    @State var pimage: String
    @State var slug: String
    @State var verification: Bool
    
    @State var themeColor: String = "000000"
    var body: some View {
        HStack{
            circleImage40by40(urlString: pimage)
            VStack(alignment: .leading){
                HStack{
                    Text(artistName)
                        .font(.body)
                        .fontWeight(.bold)
                    if verification {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.callout)
                    }
                }
                .foregroundColor(verification ? Color(UIColor.blend(color1: UIColor(Color(hexStringToUIColor(hex: "#\(themeColor.replacingOccurrences(of: "#", with: ""))"))), intensity1: 0.8, color2: UIColor(colorScheme == .dark ? Color.white : Color.black), intensity2: 0.2)) : nil)
                Text(slug)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
    }
}

struct followersFollowingField: Hashable, Codable {
    let _id: String
    let artistName: String
    let password: String
    let slug: String
    let email: String
    let pimage: String
    let verification: Bool?
    let themeColor: String?
}

class fetchFollowersFollowing: ObservableObject {
    @Published var followersFollowingFields: [followersFollowingField] = []
    
    func fetchMoreFollowersFollowing(continueFromId: String, artistId: String, tab: String) async throws {
        guard let url = URL(string: HttpBaseUrl() + "/_functions/followersFollowing?password=yJjmML4N28ut0TEX93VY&type=filterEq&columnId=_id&value=\(artistId)&continueFrom=\(continueFromId)&tab=\(tab)&totalFetch=50") else { fatalError("Missing URL") }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { print(response); return}
        let decodedData = try JSONDecoder().decode([followersFollowingField].self, from: data)
        DispatchQueue.main.async{
            self.followersFollowingFields = self.followersFollowingFields + decodedData
            if decodedData == [] {
                if tab == "Followers"{
                    followersFetchedAll = true
                }
                if tab == "Following"{
                    followingFetchedAll = true
                }
            }
        }
    }
}

public struct SearchBar: View {
    @Binding var searchText: String
    @State var placeholder: String
    
    public var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color("LightGray"))
            HStack {
                Image(systemName: "magnifyingglass")
                TextField(placeholder, text: $searchText)
            }
            .foregroundColor(.gray)
            .padding(.leading, 13)
        }
        .frame(height: 40)
        .cornerRadius(13)
        .padding()
    }
}
