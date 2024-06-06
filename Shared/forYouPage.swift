//
//  forYouPage.swift
//  Soundlytude
//
//  Created by DJ bon26 on 9/6/22.
//

import SwiftUI

var FYPFetchingCompleted: Bool = false
var currentHour = Calendar.current.component(.hour, from: Date())
var localLang = Locale.current.languageCode!

let letterCodes:[String:Array<String>] = [
    "en": ["Please go to bed", "Good Morning", "Good Afternoon", "Good Evening :)"],
    "fr": ["Salut, va te coucher s'il te plait", "Bonjour", "Bon après-midi", "Bonsoir"],
    "es": ["Hora de dormir", "Buenos dias", "Buenas tardes", "Buenas noches"]
]

func greeting() -> String {
    if(currentHour < 07){ //7am
        return (letterCodes[localLang]![0])
    }
    else if(currentHour < 12){//12am
        return (letterCodes[localLang]![1])
    }
    else if( currentHour < 21){ //3pm
        return (letterCodes[localLang]![2])
    }
    else if(currentHour < 24){ //9pm
        return (letterCodes[localLang]![3])
    }
    else{
        return "Hi"
    }
}

struct forYouPage: View {
    @EnvironmentObject var globalVariable: globalVariables
    var body: some View {
        GeometryReader { proxy in
            forYouPageBody()
                .environmentObject(globalVariable)
                .preference(key: InnerContentSize.self, value: [proxy.frame(in: CoordinateSpace.global)])
        }
    }
}

struct forYouPage_Previews: PreviewProvider {
    static var previews: some View {
        forYouPage()
    }
}

struct forYouPageBody: View{
    @EnvironmentObject var globalVariable: globalVariables
    @StateObject var FYPFetch = FYPFetchData()
    @State private var isDoneLoading: Bool = false
    
    var body: some View{
        NavigationView{
            if isDoneLoading {
                ScrollView{
                    bodyTitle(text: "Made For You")
                        .padding([.top, .leading, .trailing], 20.0)
                        .padding(.bottom, -20)
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack{
                            Spacer(minLength: 10)
                            ForEach(FYPFetch.FYPAlbumFields, id: \._id) {i in
                                albumRepeater2(
                                    title: i.title,
                                    subTitle: i.artistDetails
                                    .artistName,
                                    imageUrl: i.coverArt,
                                    _id: i._id,
                                    artistId: i.artistDetails._id
                                )
                            }
                            Spacer(minLength: 10)
                        }
                    }
                    bodyTitle(text: "Recommended")
                        .padding([.top, .leading, .trailing], 20.0)
                        .padding(.bottom, -20)
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack{
                            Spacer(minLength: 10)
                            ForEach(FYPFetch.FYPAlbumFields, id: \._id) {i in
                                albumRepeater2(
                                    title: i.title,
                                    subTitle: i.artistDetails
                                    .artistName,
                                    imageUrl: i.coverArt,
                                    _id: i._id,
                                    artistId: i.artistDetails._id
                                )
                            }
                            Spacer(minLength: 10)
                        }
                    }
                    bodyTitle(text: "Trending")
                        .padding([.top, .leading, .trailing], 20.0)
                        .padding(.bottom, -20)
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack{
                            Spacer(minLength: 10)
                            ForEach(FYPFetch.FYPAlbumFields, id: \._id) {i in
                                albumRepeater2(
                                    title: i.title,
                                    subTitle: i.artistDetails
                                    .artistName,
                                    imageUrl: i.coverArt,
                                    _id: i._id,
                                    artistId: i.artistDetails._id
                                )
                            }
                            Spacer(minLength: 10)
                        }
                    }
                    bottomSpace()
                }
                .navigationTitle(greeting() + "")
            }else{
                VStack{
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.accentColor))
                        .onAppear{
                            FYPFetch.fetch()
                            progresser()
                        }
                }
                .navigationTitle(greeting() + "")
            }
        }
    }
    
    //TO fix the issue of broken navigation link
    @State var title2: String = ""
    @State var subTitle2: String = ""
    @State var imageUrl2: String = ""
    @State var _id2: String = ""
    @State var artistId2: String = ""
    
    
    @ViewBuilder
    func albumRepeater2(title: String, subTitle: String, imageUrl: String, _id: String, artistId: String) -> some View {
        ZStack{
            Button {
                title2 = title
                subTitle2 = subTitle
                imageUrl2 = imageUrl
                _id2 = _id
                artistId2 = artistId
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    globalVariable.homeExited = true
                }
            } label: {
                VStack{
                    squareImage160by160(urlString: imageUrl)
                        .padding([.top, .leading, .trailing], 0.5)
                        .padding(.top, 20)
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("BlackWhite"))
                        .multilineTextAlignment(.leading)
                        .padding(.all, 0.0)
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            alignment: .topLeading
                        )
                        .frame(width: 170)
                        .lineLimit(2)
                    Text(subTitle)
                        .font(.body)
                        .fontWeight(.regular)
                        .foregroundColor(Color.gray)
                        .multilineTextAlignment(.leading)
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            alignment: .topLeading
                        )
                        .frame(width: 170)
                        .lineLimit(1)
                    Spacer()
                }
            }
            NavigationLink(destination: albumPage(albumId: _id2, artistId: artistId2), isActive: $globalVariable.homeExited, label: {EmptyView() }).isDetailLink(false)
        }
    }
    
    func progresser() {
        if(FYPFetchingCompleted){
            print("done")
            isDoneLoading = true
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                progresser()
                if (FYPFetchingCompleted == false){
                    isDoneLoading = false
                }
            }
        }
    }
}

struct FYP_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}

struct albumRepeater: View {
    var title: String
    var subTitle: String
    var imageUrl: String
    var _id: String
    var artistId: String
    
    var body: some View {
        NavigationLink(destination: albumPage(albumId: _id, artistId: artistId), label: {
            VStack{
                squareImage160by160(urlString: imageUrl)
                    .padding([.top, .leading, .trailing], 0.5)
                    .padding(.top, 20)
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("BlackWhite"))
                    .multilineTextAlignment(.leading)
                    .padding(.all, 0.0)
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        alignment: .topLeading
                    )
                    .frame(width: 170)
                    .lineLimit(2)
                Text(subTitle)
                    .font(.body)
                    .fontWeight(.regular)
                    .foregroundColor(Color.gray)
                    .multilineTextAlignment(.leading)
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        alignment: .topLeading
                    )
                    .frame(width: 170)
                    .lineLimit(1)
                Spacer()
            }
        })
    }
}

struct bodyTitle: View{
    let text: String
    var body: some View {
        Text(text)
            .font(.title3)
            .fontWeight(.bold)
            .multilineTextAlignment(.leading)
            .frame(
                minWidth: 0,
                maxWidth: .infinity,
                alignment: .topLeading
            )
        
    }
}

struct URLAlbumImage: View {
    let urlString: String
    @State var data: Data?
    var body: some View {
        if let data = data, let uiimage = UIImage(data: data) {
            Image(uiImage: uiimage)
                .resizable()
                .background (Color.gray)
                .scaledToFit()
                .cornerRadius(5)
                .padding([.top, .leading, .trailing], 2.5)
                .frame(width: 160, height: 160)
                .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y:5)
        }
        else {
            Image("Soundlytude empty placeHolder")
                .resizable()
                .opacity(0.1)
                .background (Color.gray)
                .scaledToFit()
                .cornerRadius(5)
                .padding([.top, .leading, .trailing], 2.5)
                .frame(width: 170, height: 170)
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

struct FYPArtistDetails: Hashable, Codable {
    let artistName: String
    let _id: String
}

struct FYPAlbumField: Hashable, Codable {
    let _id: String
    let title: String
    let coverArt: String
    let artistDetails: FYPArtistDetails
}

class FYPFetchData: ObservableObject {
    @Published var FYPAlbumFields: [FYPAlbumField] = []
    func fetch() {
        FYPFetchingCompleted = false
        guard let url = URL(string: HttpBaseUrl() + "/_functions/albums?password=wNyLKt1V6357sVCZLJlH&noItems=true") else {
            return}
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _,
            error in
            guard let data = data, error == nil else {
                return
            }
            // Convert to JSON
            do
            {
                let data = try JSONDecoder().decode ([FYPAlbumField].self,
                                                     from: data)
                DispatchQueue.main.async{
                    self?.FYPAlbumFields = data
                    FYPFetchingCompleted = true
                }
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }
}
