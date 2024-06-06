//
//  searchPage.swift
//  Soundlytude
//
//  Created by DJ bon26 on 9/5/22.
//

import SwiftUI

struct searchPage: View {
    var body: some View {
        searchFunctionView()
            .environmentObject(globalVariables())
    }
}

struct searchPage_Previews: PreviewProvider {
    static var previews: some View {
        searchPage()
    }
}

struct searchFunctionView: View {
    @EnvironmentObject var globalVariables: globalVariables
    @StateObject var genreFetch = GenreFetchData()
    @ObservedObject var SAFetchData = SearchArrayFetchData2()
    @State private var searchText = ""
    
    var discover = ["Nigerian songs", "Soundlytude", "Hip Hop", "Tik tok Sounds", "Slowed beats", "DJ bon26", "Unpopular releases", "New releases", "Afro pop"]
    
    var filteredPeople: [Search] {
        if searchText ==
            "" {return []}
        return SAFetchData.searchFields.filter {
            $0.search.localizedCaseInsensitiveContains(searchText.localizedLowercase)
        }
    }
    
    var isTypingSearch: Bool {
        if searchText == "" {
            return false
        }else{
            return true
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView{
                ZStack{
                    VStack{
                        bodyTitle(text: "Discover")
                            .padding([.top, .leading, .trailing], 20.0)
                        Divider()
                        ForEach(discover, id: \.self) {i in
                            Button {
                                searchText = i
                            } label: {
                                VStack{
                                    HStack{
                                        Text(i)
                                        Spacer()
                                    }.padding(.horizontal)
                                    Divider()
                                }.padding(.horizontal)
                            }
                        }
                        bodyTitle(text: "Top genres")
                            .padding([.top, .leading, .trailing], 20.0)
                        Divider()
                        ForEach(genreFetch.genreFields, id: \._id) {i in
                            genresView(image: i.coverArt, genre: i.genre, id: i._id)
                        }
                        Spacer()
                            .frame(height: 78)
                    }
                    .frame(maxHeight: (isTypingSearch) ? 0 : .infinity)
                    .opacity((isTypingSearch) ? 0 : 1)
                    VStack{
                            ForEach(filteredPeople, id: \.self){search in
                                suggestionView(
                                    label: search.search
                                )
                            }
                        Spacer()
                    }
                    .opacity((isTypingSearch) ? 1 : 0)
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Soundlytude")
            .navigationTitle("Search")
            .onAppear{
                genreFetch.fetch()
                SAFetchData.fetch()
            }
        }
    }
    
    @ViewBuilder
    func suggestionView(label: String) -> some View {
        VStack{
            HStack{
                Image(systemName: "magnifyingglass")
                Text(label)
                Spacer()
                VStack{
                    Image(systemName: "arrow.up.backward")
                }
                .frame(width: 37.5, height: 37.5)
                .onTapGesture {
                    searchText = label
                }
            }
        }.padding(.horizontal)
    }
}

struct genresView: View{
    var image: String
    var genre: String
    var id: String
    var body: some View {
        NavigationLink(destination: albumPage(), label: {
            ZStack{
                URLSearchGenreAlbumImage(urlString: image)
                VStack{
                    Spacer().frame(height:20)
                    Text(genre)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.leading)
                        .padding([.leading, .trailing], 40.0)
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            alignment: .topLeading
                        )
                    Spacer()
                }
            }
        })
        .frame(width: viewableWidth, height: 150, alignment: .leading)
        .padding(.vertical, 5)
        .shadow(color: Color.black.opacity(0.5), radius: 10, x: 0, y:10)
    }
}


struct URLSearchGenreAlbumImage: View {
    let urlString: String
    @State var data: Data?
    var body: some View {
        if let data = data, let uiimage = UIImage(data: data) {
            Image(uiImage: uiimage)
                .resizable()
                .background (Color.gray)
                .scaledToFill()
                .frame(width: viewableWidth - 40, height: 150)
                .cornerRadius(20)
            Blur(style: .dark)
                .frame(width: viewableWidth - 40, height: 150)
                .cornerRadius(20)
                .mask(
                    LinearGradient(gradient: Gradient(stops:[
                        .init(color: Color.black, location: 0),
                        .init(color: Color.white, location: -0.5),
                        .init(color: Color.black.opacity(0), location: 1.0)]), startPoint: .top, endPoint: .bottom))
        }
        else {
            Image("Soundlytude empty placeHolder")
                .resizable()
                .background (Color.gray)
                .scaledToFill()
                .frame(width: viewableWidth - 40, height: 150)
                .cornerRadius(20)
                .opacity(0.1)
            Blur(style: .dark)
                .frame(width: viewableWidth - 40, height: 150)
                .cornerRadius(20)
                .mask(
                    LinearGradient(gradient: Gradient(stops:[
                        .init(color: Color.black, location: 0),
                        .init(color: Color.white, location: -0.5),
                        .init(color: Color.black.opacity(0), location: 1.0)]), startPoint: .top, endPoint: .bottom))
                .onAppear {
                    fetchData()
                }
        }
    }
    private func fetchData(){
        guard let url = URL(string: urlString) else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, _, _
            in
            self.data = data
        }
        task.resume( )
    }
}

struct genreField: Hashable, Decodable {
    let _id: String
    let coverArt: String
    let genre: String
}

class GenreFetchData: ObservableObject {
    @Published var genreFields: [genreField] = []
    func fetch() {
        guard let url = URL(string:"https://www.soundlytude.com/_functions/genre?password=8H91zL0uJbH6RTL26vR7") else {
            return}
        let task = URLSession.shared.dataTask(with: url) {[weak self]data, _,
            error in
            guard let data = data, error == nil else {
                return
            }
            // Convert to JSON
            do
            {
                let data = try JSONDecoder().decode([genreField].self,
                                                    from: data)
                DispatchQueue.main.async{
                    self?.genreFields = data
                }
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }
}

struct Search: Hashable, Codable{
    var search: String
}

struct searchField: Hashable, Codable{
    var items: [Search]
}

class SearchArrayFetchData2: ObservableObject {
    @Published var searchFields: [Search] = []
    
    func fetch() {
        guard let url = URL(string: HttpBaseUrl() + "/_functions/searchArray?password=e8oFp2q3D87OFL3L844U&allArrayArray=false") else {
            return}
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _,
            error in
            guard let data = data, error == nil else {
                return
            }
            // Convert to JSON
            print("SEARCH ARRAY", data)
            do
            {
                let data = try JSONDecoder().decode ([Search].self,
                                                     from: data)
                DispatchQueue.main.async{
                    self?.searchFields = data
                }
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }
}
