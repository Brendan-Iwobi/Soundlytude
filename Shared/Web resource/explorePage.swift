//
//  explorePage.swift
//  Soundlytude
//
//  Created by DJ bon26 on 4/17/24.
//

import SwiftUI
import Combine
import SwiftUISnappingScrollView
import Introspect
//import Modals

struct explorePage2: View { // not using
    var colors = [Color.blue, Color.orange, Color.green, Color.secondarySystemFill, Color.systemPink]
    var body: some View {
        SnappingScrollView(.vertical, decelerationRate: .fast, showsIndicators: false) {
            VStack(spacing: 0) {
                ForEach(0 ..< 5){ post in
                    //                    VStack(spacing: 0){
                    //                        explorePageLayout(likeCount: post)
                    //                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    //                            .background(colors[post])
                    //                            .edgesIgnoringSafeArea(.all)
                    //                            .scrollSnappingAnchor(.bounds)
                    //                    }.frame(height: UIScreen.main.bounds.height)
                }
            }
        }
        .ignoresSafeArea()
    }
}

struct explorePage: View {
    @EnvironmentObject var globalVariables: globalVariables
    
    let detector: CurrentValueSubject<CGFloat, Never>
    let publisher: AnyPublisher<CGFloat, Never>
    
    init() {
        let detector = CurrentValueSubject<CGFloat, Never>(0)
        self.publisher = detector
            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .dropFirst()
            .eraseToAnyPublisher()
        self.detector = detector
    }
    
    
    
    @State private var scrollPosition: CGPoint = .zero
    @State private var currentIndex: Int = 0
    @State var loading: Bool = true
    @State var limit: Int = 3
    @State var noMore: Bool = false
    
    @State var loadStatus: String = "loading"
    @State var openComment: Bool = false
    @State var fetchedFirstTime: Bool = false
    
    @StateObject var GetExplore = getMoreExplore()
    @State var openSettings: Bool = false
    
    var colors = [Color.blue, Color.orange, Color.yellow, Color.secondarySystemFill, Color.systemPink]
    var body: some View {
        if !loading {
            NavigationView{
                GeometryReader { gr in
                    ScrollView(.vertical, showsIndicators: false) {
                        if openComment {
                            Spacer()
                                .frame(width: 0, height: 0)
                                .onAppear{
                                    UIScrollView.appearance().isPagingEnabled = false
                                }
                        }else{
                            Spacer()
                                .frame(width: 0, height: 0)
                                .onAppear{
                                    UIScrollView.appearance().isPagingEnabled = true
                                }
                        }
                        VStack(spacing: 0){
                            //                        ForEach(0 ..< 5){ post in
                            //                            VStack(spacing: 0){
                            //                                explorePageLayout(likeCount: post)
                            //                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                            //                                    .background(colors[post])
                            //                                    .edgesIgnoringSafeArea(.all)
                            //                                    .scrollSnappingAnchor(.bounds)
                            //                            }.frame(height: gr.size.height)
                            //                        }
                            ForEach(GetExplore.getMoreExploreFields, id: \._id){ explore in
                                let itemIndex = GetExplore.getMoreExploreFields.firstIndex(of: explore)
                                VStack(spacing: 0){
                                    explorePageLayout(
                                        id: explore._id,
                                        imageUrl: explore.albumReference.coverArt,
                                        imageTitle: explore.albumReference.title,
                                        title: explore.tracktitle,
                                        genre: explore.genre,
                                        audioUrl: explore.audio,
                                        themeColor: explore.albumReference.themeColor,
                                        captionTitle: explore.albumReference.title,
                                        artistName: explore.artistDetails.artistName,
                                        artistPfp: explore.artistDetails.pimage,
                                        verified: explore.artistDetails.verification ?? false,
                                        captionDescription: explore.albumReference.description ?? "",
                                        likeCount: explore.likes.count,
                                        commentCount: explore.albumReference.commentCount,
                                        itemIndex: itemIndex ?? -1,
                                        albumId: explore.albumReference._id,
                                        albumOwner: explore.artistDetails._id,
                                        currentIndex: $currentIndex,
                                        geoReader: gr,
                                        openComment: $openComment
                                    )
                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                                    .background(Color(hexStringToUIColor(hex: "#\(explore.albumReference.themeColor)")))
                                    .edgesIgnoringSafeArea(.all)
                                    .scrollSnappingAnchor(.bounds)
                                    .environmentObject(globalVariables)
                                }.frame(height: gr.size.height)
                            }
                            if loadStatus == "loading"{
                                ProgressView()
                                    .padding()
                            }
                            if loadStatus == "noMore"{
                                Text("You've reached the end")
                                    .padding()
                            }
                        }.introspectScrollView { scrollView in
                            if openComment {
                                scrollView.isScrollEnabled = false
                            }else{
                                scrollView.isScrollEnabled = true
                            }
                        }
                        .background(GeometryReader { geometry in
                            Color.clear
                                .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).origin)
                        })
                        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                            //                    self.scrollPosition = value
                            //                    currentIndex = value.y/gr.size.heigh
                            //                    if value =
                            //                    if (value.y/gr.size.height)
                            //                    print(value)
                        }
                        .background(GeometryReader {
                            Color.clear.preference(key: ViewOffsetKey1.self,
                                                   value: -$0.frame(in: .named("scroll")).origin.y)
                        })
                        .onPreferenceChange(ViewOffsetKey1.self) { detector.send($0) }
                    }
//                    .modal($openSettings, size: .medium){
//                        Text("Modal")
//                    }
                    .toolbar{
                        ToolbarItem(placement: .navigationBarTrailing){
                            Button {
                                //
                            } label: {
                                Image(systemName: "slider.horizontal.3")
                            }.foregroundColor(.white)
                        }
                    }
                    .coordinateSpace(name: "scroll")
                    .onReceive(publisher) {
                        _ = "\($0 / gr.size.height)"
                        if CGFloat(currentIndex - 1) == ($0 / gr.size.height) || CGFloat(currentIndex + 1) == ($0 / gr.size.height){ //whole number and see if scrolled up or down
                            currentIndex = Int($0 / gr.size.height)
                            print(currentIndex)
                            if GetExplore.getMoreExploreFields.count > 2 {
                                if currentIndex == GetExplore.getMoreExploreFields.count - 2{
                                    Task{
                                        do {
                                            loadStatus = "loading"
                                            try await GetExplore.getMoreExploreMusic(limit: limit, action: "load", previouslyFetched: GetExplore.getMoreExploreFields)
                                            if exploreLoadMoreCount < limit {
                                                noMore = true
                                                loadStatus = "noMore"
                                            }else{
                                                noMore = false
                                                loadStatus = "loading"
                                            }
                                            loading = false
                                        }catch{
                                            loading = false
                                            print("error bro", error)
                                        }
                                    }
                                    
                                }
                            }else{
                                if currentIndex == GetExplore.getMoreExploreFields.count - 1{
                                    Task{
                                        do {
                                            loadStatus = "loading"
                                            try await GetExplore.getMoreExploreMusic(limit: limit, action: "load", previouslyFetched: GetExplore.getMoreExploreFields)
                                            if exploreLoadMoreCount < limit {
                                                noMore = true
                                                loadStatus = "noMore"
                                            }else{
                                                noMore = false
                                                loadStatus = "loading"
                                            }
                                            loading = false
                                        }catch{
                                            loading = false
                                            print("error bro", error)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .ignoresSafeArea()
            }
        }else{
            ZStack{
                Color("AccentColorSchemedBlack").ignoresSafeArea()
                ProgressView()
            }
            .onAppear{
                if !fetchedFirstTime {
                    Task{
                        do {
                            try await GetExplore.getMoreExploreMusic(limit: limit, action: "load", previouslyFetched: GetExplore.getMoreExploreFields)
                            fetchedFirstTime = true
                            if exploreLoadMoreCount < limit {
                                noMore = true
                                loadStatus = "noMore"
                            }else{
                                noMore = false
                                loadStatus = "loading"
                            }
                            loading = false
                            print("done")
                        }catch{
                            loading = false
                            print("error bro", error)
                        }
                    }
                }
            }
        }
    }
}

struct explorePage_Previews: PreviewProvider {
    static var previews: some View {
        explorePage()
        //        CarouselView()
    }
}


struct explorePageLayout: View {
    @EnvironmentObject var globalVariables: globalVariables
    
    @StateObject var sendTrackLikesFunc = sendTrackLikes()
    @StateObject var vm = LocalWebViewVM(webResource: "explorePlayer")
    
    @State var id: String = "https://i.scdn.co/image/ab67616d0000b273d02311f945cb56a97011a9f7"
    @State var imageUrl: String = "https://i.scdn.co/image/ab67616d0000b273d02311f945cb56a97011a9f7"
    @State var imageTitle: String = ""
    @State var title: String = "Pull up at the mansion"
    @State var genre: String = "HipHop / Rap"
    @State var audioUrl: String = "https://static.wixstatic.com/mp3/0fd70b_a1e4101440f34b7c8d15412258af687e.mp3"
    @State var themeColor: String = "7099ff"
    ///caption
    @State var captionTitle: String = "Please excuse me for being anti social"
    @State var artistName: String = "DJ bon26"
    @State var artistPfp: String = "DJ bon26"
    @State var verified: Bool = true
    @State var captionDescription: String = "Talking Talking Talking Talking Talking Talking Talking Talking Talking TalkingTalking TalkingTalking"
    
    @State var likeCount: Int = 0
    @State var liked: Bool = false
    @State var heartScaleEffect: CGFloat = 1
    @State var liking: Bool = true
    @State var commentCount: Int = 0
    @State var itemIndex: Int = 0
    @State var albumId: String = ""
    @State var albumOwner: String = ""
    
    @State var isExploreTrackPlaying: Bool = false
    @Binding var currentIndex: Int
    
    @State var likes: [loopingPopups] = []
    @State var restart: [loopingPopups] = []
    @State var showPoppingHeart: Bool = false
    @State var showRestartingHeart: Bool = false
    
    @State var geoReader: GeometryProxy
    
    @State var commentOffset: Double = 0
    @State var openCommentFirstTime: Bool = false
    @Binding var openComment: Bool
    @State var isPresented: Bool = false
    @State var fetchedFirstTime: Bool = false
    
    @State var profileToGoTo: String = ""
    @State var navigationLinkToGoTo: AnyView = AnyView(EmptyView())
    @State var navigationLinkToGoToIsActive: Bool = false
    var tapNOTUSING: some Gesture {
        if #available(iOS 16.0, *) {
            return SimultaneousGesture(SpatialTapGesture(count: 2), SpatialTapGesture(count: 3))
                .onEnded { gestureValue in
                    if gestureValue.second != nil {
                        withAnimation(.spring()){
                            likes.append(loopingPopups(index: (likes.count + 1), location: gestureValue.first?.location ?? CGPoint(x: 0, y: 0)))
                        }
                        like(source: "doubleTap")
                        print(gestureValue.first?.location, "triple tap!")
                        return
                    } else if gestureValue.first != nil {
                        withAnimation(.spring()){
                            restart.append(loopingPopups(index: (restart.count + 1), location: gestureValue.first?.location ?? CGPoint(x: 0, y: 0)))
                        }
                        let messageToSend = webviewExploreField(reason: "restart", audioUrl: audioUrl, themeColor: themeColor) //just sending the restart signal. the audio is already fetched
                        vm.messageToExploreAudio(message: messageToSend)
                        print(gestureValue.first?.location, "double tap!")
                        return
                    }
                }
        }else{
            return SimultaneousGesture(TapGesture(count: 2), TapGesture(count: 3))
                .onEnded { gestureValue in
                    if gestureValue.second != nil {
                        print("triple tap!")
                        like(source: "doubleTap")
                        return
                    } else if gestureValue.first != nil {
                        let messageToSend = webviewExploreField(reason: "restart", audioUrl: audioUrl, themeColor: themeColor) //just sending the restart signal. the audio is already fetched
                        vm.messageToExploreAudio(message: messageToSend)
                    }
                }
        }
    }
    var tap: some Gesture {
        if #available(iOS 16.0, *) {
            return SimultaneousGesture(SpatialTapGesture(count: 1), SpatialTapGesture(count: 2))
                .onEnded { gestureValue in
                    if gestureValue.second != nil { //doubletap
                        withAnimation(.spring()){
                            likes.append(loopingPopups(index: (likes.count + 1), location: gestureValue.first?.location ?? CGPoint(x: 0, y: 0)))
                        }
                        like(source: "doubleTap")
                        return
                    } else if gestureValue.first != nil { //single tap
                        if isExploreTrackPlaying {
                            isExploreTrackPlaying = false
                            let messageToSend = webviewExploreField(reason: "pause", audioUrl: audioUrl, themeColor: themeColor) //just sending the pause signal. the audio is already fetched
                            vm.messageToExploreAudio(message: messageToSend)
                        }else{
                            isExploreTrackPlaying = true
                            let messageToSend = webviewExploreField(reason: "play", audioUrl: audioUrl, themeColor: themeColor) //just sending the play signal. the audio is already fetched
                            vm.messageToExploreAudio(message: messageToSend)
                        }
                        return
                    }
                }
        }else{
            return SimultaneousGesture(TapGesture(count: 1), TapGesture(count: 2))
                .onEnded { gestureValue in
                    if gestureValue.second != nil {//Double Tap
                        like(source: "doubleTap")
                        return
                    } else if gestureValue.first != nil { // Triple Tap
                        if isExploreTrackPlaying {
                            isExploreTrackPlaying = false
                            let messageToSend = webviewExploreField(reason: "pause", audioUrl: audioUrl, themeColor: themeColor) //just sending the pause signal. the audio is already fetched
                            vm.messageToExploreAudio(message: messageToSend)
                        }else{
                            isExploreTrackPlaying = true
                            let messageToSend = webviewExploreField(reason: "play", audioUrl: audioUrl, themeColor: themeColor) //just sending the play signal. the audio is already fetched
                            vm.messageToExploreAudio(message: messageToSend)
                        }
                    }
                }
        }
    }
    
    var body: some View {
        ZStack{
            //            AsyncImage(url: URL(string: "\(urlString)/v1/fill/w_64,h_64,al_c/\(imageTitle.replacingOccurrences(of: " ", with: "+")).jpg")) { image in
            //                image
            //                    .resizable()
            //                    .aspectRatio(contentMode: .fill)
            //                    .background (Color.gray)
            //                    .scaledToFit()
            //
            //            } placeholder: {
            //                Image("Soundlytude empty placeHolder")
            //                    .resizable()
            //                    .aspectRatio(contentMode: .fill)
            //                    .opacity(0.5)
            //            }.blur(radius: 10)
            ZStack {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .background (Color.gray)
                        .opacity(0.5)
                } placeholder: {
                    Image("Soundlytude empty placeHolder")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .opacity(0.5)
                }.blur(radius: 20)
                VStack{
                    Spacer()
                    Color.black.opacity(0.75) //OG: 0.9 (/1.5)
                        .mask(
                            LinearGradient(colors:[
                                .clear,
                                Color.black], startPoint: .top, endPoint: .bottom))
                }
                VStack{
                    if iphoneXandUp {
                        Spacer()
                    }else{
                        Spacer().frame(height: 50)
                    }
                    ZStack{
                        AsyncImage(url: URL(string: imageUrl)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .background (Color.gray)
                                .scaledToFit()
                        } placeholder: {
                            Image("Soundlytude empty placeHolder")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .opacity(0.5)
                                .scaledToFit()
                        }
                        .frame(width: geoReader.size.height / 3.75)
                        .cornerRadius(10)
                        .shadow(radius: 10)
                        .shadow(radius: 10)
                        Group {
                            Circle()
                                .strokeBorder((isExploreTrackPlaying) ? Color.accentColor : Color.white,lineWidth: 2.5)
                                .frame(width: 75, height: 75)
                                .scaleEffect((isExploreTrackPlaying) ? 2 : 1)
                                .opacity((isExploreTrackPlaying) ? 0 : 1)
                            Image(systemName: "play.fill")
                                .foregroundColor((isExploreTrackPlaying) ? nil : Color.white)
                                .frame(width: 100, height: 100)
                                .scaleEffect((isExploreTrackPlaying) ? 2 : 1)
                                .opacity((isExploreTrackPlaying) ? 0 : 1)
                                .font(.system(size: 25))
                        }
                        .opacity(0.9)
                        .shadow(color: Color.black.opacity(0.5), radius: 5, x: 0, y:0)
                        .animation(.interpolatingSpring(stiffness: 100, damping: 10), value: isExploreTrackPlaying)
                    }
                    Text(title)
                        .font(.title3)
                        .foregroundColor(.white)
                    Text(genre)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                    Text("2020")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                    if iphoneXandUp {
                        Spacer().frame(height: 50)
                    }
                    WebView(vm: vm)
                        .frame(height: 45)
                    //                Image(systemName: "play")
                    //                    .font(.title)
                    //                    .foregroundColor(.white)
                    Spacer()
                    Spacer()
                    Spacer()
                }
                .padding()
                .frame(maxWidth: geoReader.size.width)
                VStack{
                    Spacer()
                    HStack(alignment: .bottom){
                        caption()
                        Spacer()
                        actionButtons()
                    }
                    .foregroundColor(.white)
                    .padding()
                    //                    .padding(.bottom, 40)
                    bottomSpace()
                    //                        .padding()
                }
                .frame(maxWidth: geoReader.size.width)
                ForEach(likes, id: \.index){i in
                    loopingPopupsView(image: "heart.fill", foregroundColor: .red, position: i.location)
                    //                    .onAppear{
                    //                        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    //                            likes.remove(at: likes.firstIndex(of: i)!)
                    //                        }
                    //                    }
                }
                ForEach(restart, id: \.index){r in
                    loopingPopupsView(image: "backward.fill", foregroundColor: .white, position: r.location)
                    //                    .onAppear{
                    //                        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    //                            restart.remove(at: restart.firstIndex(of: r)!)
                    //                        }
                    //                    }
                }
            }
            .gesture(tap)
            ZStack{
                Color.black
                    .opacity(openComment ? 0.25 : 0)
                    .frame(height: geoReader.size.height)
                    .onTapGesture {
                        print("tapping")
                        withAnimation(.spring()){
                            openComment = false
                            globalVariables.hideTabBar = false
                            commentOffset = 0
                        }
                    }
                VStack{
                    Spacer()
                    VStack{
                        if openCommentFirstTime {
                            ExploreComments(albumId: albumId, albumOwner: albumOwner, trackId: id, trackName: title, commentCount: $commentCount, profileLink: $profileToGoTo.onChange(isProfileChanged), openComments: $openComment)
                                .environmentObject(globalVariables)
                        }
                    }
                    .frame(width: geoReader.size.width, height: geoReader.size.height * 3/4)
                    .background(Color("WhiteBlack"))
                    .cornerRadius(10, corners: [.topLeft, .topRight])
                    .offset(y: openComment ? commentOffset : Double(geoReader.size.height * 3/4))
                }.frame(maxWidth: geoReader.size.width, maxHeight: geoReader.size.height)
            }
        }
        .onAppear{
            if !fetchedFirstTime {
                checkIfLiked(trackId: id)
                fetchedFirstTime = true
            }
        }
        .onChange(of: currentIndex) { output in
            if output == itemIndex {
                print(title)
                isExploreTrackPlaying = true
                let messageToSend = webviewExploreField(reason: "play", audioUrl: audioUrl, themeColor: themeColor) //just sending the play signal. the audio is already fetched
                vm.messageToExploreAudio(message: messageToSend)
                restart = []
                likes = []
            }
        }
        .onReceive(vm.$messageFromWV, perform: {x in
            if x.reason == "ready"{
                let messageToSend = webviewExploreField(reason: "load", audioUrl: audioUrl, themeColor: themeColor)
                vm.messageToExploreAudio(message: messageToSend)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if itemIndex == 0 {
                        isExploreTrackPlaying = true
                        let messageToSend = webviewExploreField(reason: "play", audioUrl: audioUrl, themeColor: themeColor) //just sending the play signal. the audio is already fetched
                        vm.messageToExploreAudio(message: messageToSend)
                    }
                }
            }
            
            if x.reason == "pause"{
                isExploreTrackPlaying = false
            }
            if x.reason == "play"{
                isExploreTrackPlaying = true
            }
        })
        .background(
            NavigationLink(destination: navigationLinkToGoTo, isActive: $navigationLinkToGoToIsActive) {
                EmptyView()
            }
                .hidden()
        )
    }
    
    @ViewBuilder
    func caption() -> some View {
        VStack(alignment: .leading, spacing: 5){
            Button {
                //
            } label: {
                HStack(spacing: 5){
                    (Text("\(artistName)") + Text(verified ? " \(Image(systemName: "checkmark.seal.fill"))" : ""))
                        .font(.callout)
                        .fontWeight(.bold)
                    Image(systemName: "chevron.forward")
                        .font(.caption)
                }
            }
            Text(captionTitle)
                .font(.title3)
                .fontWeight(.black)
            Text(captionDescription)
                .font(.caption)
                .multilineTextAlignment(.leading)
        }
    }
    
    @ViewBuilder
    func actionButtons() -> some View {
        VStack(spacing: 20){
            circleImage40by40(urlString: artistPfp)
            Button {
                like(source: "direct")
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
                withAnimation(.spring()){
                    openComment = true
                    globalVariables.hideTabBar = true
                    if !openCommentFirstTime {
                        openCommentFirstTime = true
                        //fetch
                        print("Fetch right here")
                    }
                }
            } label: {
                VStack{
                    Image(systemName: "bubble.right.fill")
                        .font(.system(size: 25))
                    Text("\(commentCount)")
                        .font(.caption)
                }
            }
        }
    }
    
    func like(source: String)  {
        Task{
            do {
                if liking {
                    //Don't do nothing is stil sending request
                }else{
                    liking = true
                    heartScaleEffect = 0.5
                    if liked {
                        if source == "doubleTap"{ //already liked no need to like twice
                            liking = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                heartScaleEffect = 1
                            }
                        }else{
                            liked = false
                            try await self.sendTrackLikesFunc.sendLike(type: "Track", action: "remove", trackId: id, albumId: albumId, albumOwner: albumOwner)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                liking = false
                                likeCount = likeCount - 1
                                heartScaleEffect = 1
                            }
                        }
                    }else{
                        liked = true
                        try await self.sendTrackLikesFunc.sendLike(type: "Track", action: "insert", trackId: id, albumId: albumId, albumOwner: albumOwner)
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
    }
    
    func checkIfLiked(trackId: String) {
        let urlParam:String = "/_functions/ifTrackLiked?password=7ZelhZTZAHy8hXnXyr1Y&trackId=\(trackId)&currentUserId=\(soundlytudeUserId())"
        
        guard let url = URL(string: HttpBaseUrl() + urlParam) else {
            print("Error: cannot create URL")
            return
        }
        // Create model
        struct checkIfLikedData: Codable {
            let trackId: String
            let currentUserId: String
        }
        
        // Add data to the model
        let checkIfLikedDataModel = checkIfLikedData(trackId: albumId, currentUserId: soundlytudeUserId())
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
    
    func isProfileChanged(to value: String) {
        withAnimation(.spring()){
            openComment = false
            globalVariables.hideTabBar = false
            if profileToGoTo == "" {
                
            }else{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    navigationLinkToGoTo = AnyView(profilePage(artistId: profileToGoTo))
                    navigationLinkToGoToIsActive = true
                }
            }
        }
    }
}

struct loopingPopups: Codable, Equatable {
    let index: Int
    let location: CGPoint
}

struct loopingPopupsView: View { // not using
    @State var image: String
    @State var foregroundColor: Color
    @State var position: CGPoint
    @State var leave: Bool = false
    @State var offset: CGFloat = 5
    @State var opacity: CGFloat = 1
    @State var scale: CGFloat = 1
    @State var rotation: Double = Double.random(in: -5..<5)
    var body: some View {
        Image(systemName: image)
            .foregroundColor(foregroundColor)
            .font(.system(size: 60))
            .scaleEffect(scale)
            .position(position)
            .offset(y: offset)
            .opacity(opacity)
            .rotationEffect(Angle(degrees: rotation))
            .animation(.easeIn(duration: 1.25), value: opacity)
            .animation(.easeIn(duration: 1.25), value: scale)
            .animation(.easeIn(duration: 1.25), value: offset)
            .animation(.interpolatingSpring(stiffness: 100, damping: 10), value: rotation)
            .onAppear{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    rotation = Double.random(in: -75..<75)
                    offset = -300
                    opacity = 0
                    scale = 5
                }
            }
    }
}
//
//  ContentView.swift
//  Carousel
//
//  Created by Prahlad Dhungana on 2024-04-06.
//
//
//struct CarouselView: View {
//    let Card2s: [Card2] = [
//        Card2(emoji: "😀"),
//        Card2(emoji: "❤️"),
//        Card2(emoji: "🎵"),
//        Card2(emoji: "☕️"),
//        Card2(emoji: "📚"),
//        Card2(emoji: "💖"),
//        Card2(emoji: "⚽️"),
//    ]
//
//    var body: some View {
//        GeometryReader { reader in
//            SnapperView(size: reader.size, Card2s: Card2s)
//        }
//    }
//}
//
//struct SnapperView: View {
//    let size: CGSize
//    let Card2s: [Card2]
//    private let padding: CGFloat
//    private let Card2Width: CGFloat
//    private let spacing: CGFloat = 15.0
//    private let maxSwipeDistance: CGFloat
//
//    @State private var currentCard2Index: Int = 1
//    @State private var isDragging: Bool = false
//    @State private var totalDrag: CGFloat = 0.0
//
//    init(size: CGSize, Card2s: [Card2]) {
//        self.size = size
//        self.Card2s = Card2s
//        self.Card2Width = size.width * 0.85
//        self.padding = (size.width - Card2Width) / 2.0
//        self.maxSwipeDistance = Card2Width + spacing
//    }
//
//    var body: some View {
//        let offset: CGFloat = maxSwipeDistance - (maxSwipeDistance * CGFloat(currentCard2Index))
//        LazyHStack(spacing: spacing) {
//            ForEach(Card2s, id: \.id) { Card2 in
//                Card2View(Card2: Card2, width: Card2Width)
//                    .offset(x: isDragging ? totalDrag : 0)
//                    .animation(.spring(blendDuration: 0.5), value: isDragging)
////                    .animation(.snappy(duration: 0.4, extraBounce: 0.2), value: isDragging)
//            }
//        }
//        .padding(.horizontal, padding)
//        .offset(x: offset, y: 0)
//        .gesture(
//            DragGesture()
//                .onChanged { value in
//                    isDragging = true
//                    totalDrag = value.translation.width
//                }
//                .onEnded { value in
//                    totalDrag = 0.0
//                    isDragging = false
//
//                    if (value.translation.width < -(Card2Width / 2.0) && self.currentCard2Index < Card2s.count) {
//                        self.currentCard2Index = self.currentCard2Index + 1
//                    }
//                    if (value.translation.width > (Card2Width / 2.0) && self.currentCard2Index > 1) {
//                        self.currentCard2Index = self.currentCard2Index - 1
//                    }
//            }
//        )
//    }
//}
//
//struct Card2: Identifiable {
//    var id: UUID = UUID()
//    let emoji: String
//    let color: Color = Color.color
//}
//
//public extension Color {
//    static var color: Color {
//        Color(
//            red: .random(in: 0...1),
//            green: .random(in: 0...1),
//            blue: .random(in: 0...1)
//        )
//    }
//}
//
//struct Card2View: View {
//    let Card2: Card2
//    let width: CGFloat
//    var body: some View {
//        ZStack {
//            Rectangle()
//                .foregroundColor(Color.color)
//                .cornerRadius(20)
//            Text(Card2.emoji)
//                .font(.system(size: 200, weight: .bold))
//        }
//        .frame(width: width)
//    }
//}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
    }
}

struct ViewOffsetKey1: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

struct getMoreExploreField: Hashable, Codable {
    //    var id: String? = UUID().uuidString
    let _id: String
    let tracktitle: String
    let audio: String
    let userId: String
    let genre: String
    let explicit: Bool?
    let likes: [String]
    let artistDetails: playerArtistDetails
    let albumReference: playerAlbumField
}

class getMoreExplore: ObservableObject {
    @Published var getMoreExploreFields: [getMoreExploreField] = []
    
    func getMoreExploreMusic(limit: Int, action: String, previouslyFetched: [getMoreExploreField]) async throws {
        guard let url = URL(string: HttpBaseUrl() + "/_functions/getExplorePage?password=6YSh78OlH1uccdrL5EcO&action=\(action)&limit=\(limit)") else { fatalError("Missing URL") }
        //        if previouslyFetched.count > 0{
        //        }
        
        struct exploreGetData: Codable {
            let currentUserId: String
            let previouslyFetched: [getMoreExploreField]
        }
        
        // Add data to the model
        let exploreGetDataModel = exploreGetData(currentUserId: soundlytudeUserId(), previouslyFetched: previouslyFetched)
        
        // Convert model to JSON data
        guard let jsonData = try? JSONEncoder().encode(exploreGetDataModel) else {
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
        let decodedData = try JSONDecoder().decode([getMoreExploreField].self, from: data)
        print("Checkpoint4")
        DispatchQueue.main.async{
            print("Checkpoint5")
            if action == "refresh" {
                self.getMoreExploreFields = decodedData
            }else{
                self.getMoreExploreFields = self.getMoreExploreFields + decodedData
                exploreLoadMoreCount = decodedData.count
            }
        }
    }
}


class sendTrackLikes: ObservableObject {
    @Published var sendTrackLikesFields: [sendAlbumLikesField] = []
    
    func sendLike(type: String, action: String, trackId: String, albumId: String, albumOwner: String) async throws {
        guard let url = URL(string: HttpBaseUrl() + "/_functions/trackLikes?password=4d5qFvJnQ86yEI4CeWcw") else { fatalError("Missing URL") }
        print(url)
        
        struct likeData: Codable {
            let type: String
            let trackId: String
            let albumId: String
            let currentUserId: String
            let albumOwner: String
        }
        
        // Add data to the model
        let likesDataModel = likeData(type: type, trackId: trackId, albumId: albumId, currentUserId: soundlytudeUserId(), albumOwner: albumOwner)
        
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
            self.sendTrackLikesFields = decodedData
            if decodedData[0].message == "Success" {
                print("Done interaction")
                print(decodedData[0].scenario ?? "")
            }
        }
    }
}
