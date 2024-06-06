//
//  justIncaseDraftFile.swift
//  Soundlytude
//
//  Created by DJ bon26 on 9/16/22.
//

import SwiftUI

struct justIncaseDraftFile: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct justIncaseDraftFile_Previews: PreviewProvider {
    static var previews: some View {
        justIncaseDraftFile()
    }
}

struct navProfileBannerImage: View {
    private func getScrollOffset(_ geometry: GeometryProxy) -> CGFloat {
        geometry.frame(in: .global).minY
    }
    
    // 2
    private func getOffsetForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getScrollOffset(geometry)
        
        // Image was pulled down
        if offset > 0 {
            return -offset
        }
        
        return 0
    }
    private func getHeightForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getScrollOffset(geometry)
        let imageHeight = geometry.size.height
        
        if offset > 0 {
            return imageHeight + offset
        }
        
        return imageHeight
    }
    
    private func getBlurRadiusForImage(_ geometry: GeometryProxy) -> CGFloat {
        // 2
        let offset = geometry.frame(in: .global).maxY
        
        let height = geometry.size.height
        let blur = (height - max(offset, 0)) / height // 3 (values will range from 0 - 1)
        return blur * 6 // Values will range from 0 - 6
    }
    var body: some View{
        // 1
        GeometryReader { geometry in
            ZStack{
                Image("Pull up at the mansion by DJ bon26")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: self.getHeightForHeaderImage(geometry))                    .clipped()
                    .offset(x: 0, y: self.getOffsetForHeaderImage(geometry))
                Blur(style: .dark)
                    .offset(x: 0, y: self.getOffsetForHeaderImage(geometry))
                    .frame(width: geometry.size.width, height: self.getHeightForHeaderImage(geometry))
                Image("Pull up at the mansion by DJ bon26")
                    .resizable()
                    .scaledToFill()
                    .mask(
                        LinearGradient(gradient: Gradient(stops:[
                            .init(color: Color.black, location: 0),
                            .init(color: Color.white, location: 0.25),
                            .init(color: Color.black.opacity(0), location: 1.0)]), startPoint: .top, endPoint: .bottom))
                    .frame(width: geometry.size.width, height: self.getHeightForHeaderImage(geometry))                    .clipped()
                    .offset(x: 0, y: self.getOffsetForHeaderImage(geometry))
                VStack{
                    Spacer()
                    Text("DJ bon26 and Cardi B \(Image(systemName: "checkmark.seal.fill"))")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.leading)
                        .padding([.top, .leading, .trailing], 20.0)
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            alignment: .topLeading
                        )
                        .lineLimit(3)
                    VStack{/* dummy Vstack */}.frame(width: 1, height: 5)
                }
                .offset(x: 0, y: self.getOffsetForHeaderImage(geometry))
                .frame(width: geometry.size.width, height: self.getHeightForHeaderImage(geometry))
            }
        }
        .frame(height: 425)
    }
}



//struct playerView: View {
//    @State var nextEnabled = false
//    @State var previousEnabled = false
//    @State var fullScreenView: Bool = false
//    @State var set = false
//    @State var percentage: Float = 50
//    @State var siderHeight: CGFloat = 2.5
//    @State var STWidth: CGFloat = 16
//    @State var nextButtonScale: Double = 1
//    @State var previousButtonScale: Double = 1
//    @State var listButtonScale: Double = 1
//    @State var repeatButtonScale: Double = 1
//    @State private var isEditing: Bool = false
//    @State var data: Data?
//    @State var navigateTo: AnyView?
//    @State var isNavigationActive = false
//    @State var isLoading: Bool = false
//    @State var isTrackPlaying: Bool = false
//    @State var repeating: Bool = false
//    @State var listView: Bool = false
//    @State var repeated: Int = 0
//    @State var trackHasEnded: Bool = false
//
//    @State var title: String = ""
//    @State var artistName: String = ""
//    @State var coverArt: String = "artwork"
//    @State var albumTitle: String = ""
//    @State var isExplicit: Bool = false
//
//    @State var isFullscreen: Bool = false
//    @State var isMaximized: Bool = false
//    @State var useMaximized: Bool = false
//    @State var height = 50.0
//
//    @State private var offset = CGSize.zero
//    var animation: Namespace.ID
//
//    @StateObject var soundManager = SoundManager1()
//
//    @Environment(\.colorScheme) var colorScheme
//
//    @EnvironmentObject var globalVariables: globalVariables
//
//    let commandCenter = MPRemoteCommandCenter.shared()
//
//    var playerOffset: CGFloat = 0.0
//    let playerTimer = Timer
//        .publish(every: 0.5, on: .main, in: .common)
//        .autoconnect()
//
//    var body: some View{
//        GeometryReader { geometry in
//            VStack{
//                Spacer()
//                HStack(spacing: 0){
//                    Button{
//                        fullScreenView = true
//                    }label: {
//                        HStack{
//                            if let data = data, let uiimage = UIImage(data: data) {
//                                Image(uiImage: uiimage)
//                                    .resizable()
//                                    .background (Color.gray)
//                                    .scaledToFit()
//                                    .cornerRadius(5)
//                                    .frame(width: isMaximized ? 100 : 40, height: isMaximized ? 100 : 40)
//                                //                                    .frame(width: 40, height: 40)
//                            }
//                            else {
//                                Image("Soundlytude empty placeHolder")
//                                    .resizable()
//                                    .background (Color.gray)
//                                    .scaledToFit()
//                                    .cornerRadius(5)
//                                    .frame(width: isMaximized ? 100 : 40, height: isMaximized ? 100 : 40)
//                                    .opacity(0.1)
//                                    .onAppear {
//                                        fetchData()
//                                    }
//                            }
//                            HStack {
//                                Text(title)
//                                    .foregroundColor(Color("BlackWhite"))
//                                    .multilineTextAlignment(.leading)
//                                    .lineLimit(2)
//                                    .font(.callout)
//                                Spacer()
//                            }
//                            .frame(width: geometry.size.width - 300)
//                            Spacer()
//                        }
//                    }
//                    .frame(width: geometry.size.width - 240)
//                    .padding(.leading, 10)
//                    .sheet(isPresented: $fullScreenView) {
//                        ZStack{
//                            VStack{
//                                colorScheme == .dark ? Color.black : Color.white
//                            }.opacity(0.75)
//                            NavigationView {
//                                playerControlsView()
//                                    .toolbar{
//                                        ToolbarItem(){
//                                            HStack(spacing: 20){
//                                                VStack{}.frame(width: 40)
//                                                Button{
//                                                    fullScreenView = false
//                                                }label: {
//                                                    Text("\(Image(systemName: "chevron.down"))")
//                                                        .frame(width: 50, height: 50)
//                                                }
//
//                                                Text((playingType == "") ? "Nothing playing" : "\(playingType) • \(playingTypeTitle)")
//                                                    .font(.headline)
//                                                    .fontWeight(.semibold)
//                                                    .multilineTextAlignment(.center)
//                                                    .frame(width: UIScreen.main.bounds.width - 160)
//
//                                                Menu {
//                                                    Button {
//                                                        guard let urlShare = URL(string: (playingType == "Album") ? "\(HttpBaseUrl())/album/\(playingId)" : "\(HttpBaseUrl())/playlist/\(playingId)") else { return }
//                                                        let activityVC = UIActivityViewController(activityItems: [urlShare], applicationActivities: nil)
//                                                        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
//                                                    } label: {
//                                                        Label("Share Album", systemImage: "square.and.arrow.up")
//                                                    }
//
//                                                } label: {
//                                                    Label("Share Album", systemImage: "ellipsis")
//                                                        .frame(width: 50, height: 50)
//                                                }.background(
//                                                    NavigationLink(destination: navigateTo, isActive: $isNavigationActive) {
//                                                        EmptyView()
//                                                    })
//                                                Spacer().frame(width: 40)
//                                            }.frame(maxWidth: .infinity)
//                                        }
//                                    }
//                            }
//                        }
//                        .background(BackgroundBlurView())
//                    }
//                    .onAppear{
//                        checkSongs()
//                    }
//                    .environmentObject(globalVariables)
//
//                    HStack(spacing: 0){
//                        Spacer()
//                        Button {
//                            if songs != []{
//                                if isTrackPlaying {
//                                    soundManager.audioPlayer?.pause()
//                                    isTrackPlaying.toggle()
//                                } else {
//                                    soundManager.audioPlayer?.play()
//                                    isTrackPlaying.toggle()
//                                }
//                            } else{
//                                isTrackPlaying.toggle()
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                                    if ((soundManager.audioPlayer?.isPlaying) != nil) {
//                                        isTrackPlaying = true
//                                    }else{
//                                        isTrackPlaying = false
//                                    }
//                                }
//                            }
//                        } label: {
//                            ZStack{
//                                if isLoading {
//                                    ProgressView()
//                                }else{
//                                    Image(systemName: "play.fill")
//                                        .foregroundColor((isTrackPlaying) ? nil : Color("BlackWhite"))
//                                        .scaleEffect((isTrackPlaying) ? 0 : 1)
//                                        .opacity((isTrackPlaying) ? 0 : 1)
//                                        .font(.system(size: 25))
//                                    Image(systemName: "pause.fill")
//                                        .foregroundColor((isTrackPlaying) ? nil : Color("BlackWhite"))
//                                        .scaleEffect((isTrackPlaying) ? 1 : 0)
//                                        .opacity((isTrackPlaying) ? 1 : 0)
//                                        .font(.system(size: 25))
//                                }
//                            }.animation(.interpolatingSpring(stiffness: 250, damping: 20), value: isTrackPlaying)
//                        }
//                        .padding([.top, .bottom, .leading])
//                        Button {
//                            nextSong()
//                        } label: {
//                            Image(systemName: "forward.fill")
//                                .font(.system(size: 25))
//                                .foregroundColor((nextEnabled) ? Color("BlackWhite") : Color.gray)
//                                .opacity((nextEnabled) ? 1 : 0.5)
//                                .scaleEffect(nextButtonScale)
//                                .animation(.interpolatingSpring(stiffness: 250, damping: 20), value: nextButtonScale)
//                        }
//                        .padding([.top, .bottom, .leading, .trailing])
//                        .disabled((nextEnabled) ? false : true)
//                        //                        VStack {
//                        //                            Image(systemName: "line.3.horizontal")
//                        //                                .font(.system(size: 20))
//                        //                                .foregroundColor(Color.gray)
//                        //                        }
//                        //                        .padding([.top, .bottom, .trailing])
//                        //                        .padding([.leading], 10)
//                        //                        .gesture(
//                        //                            DragGesture()
//                        //                                .onChanged { gesture in
//                        //                                    withAnimation(.spring()) {
//                        //                                        offset = gesture.translation
//                        //                                    }
//                        //                                    print(offset)
//                        //                                }
//                        //                                .onEnded { _ in
//                        //                                    if abs(offset.height) > 700 {
//                        //                                        withAnimation(.spring()) {
//                        //                                            offset = .zero
//                        //                                        }
//                        //                                        fullScreenView = true
//                        //                                    }else{
//                        //                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                        //                                            withAnimation(.spring()) {
//                        //                                                offset = .zero
//                        //                                            }
//                        //                                        }
//                        //                                    }
//                        //                                }
//                        //                        )
//                    }
//                }
//                .frame(maxHeight: (useMaximized) ? geometry.size.height - 20 : height)
//                .frame(width: geometry.size.width)
//                .background((colorScheme == .dark) ? .thinMaterial : .regular)
//                .opacity((globalVariables.hideMiniPlayerView) ? 0 : 1)
//                .gesture(
//                    DragGesture()
//                        .onChanged { gesture in
//                            offset = gesture.translation
//                            if isMaximized{
//                                useMaximized = false
//                                height = min(max(50, height - offset.height), geometry.size.height)
//                            }else{
//                                height = min(max(50, height - offset.height), geometry.size.height)
//                            }
//                        }
//                        .onEnded { gesture in
//                            if height > ((75/100) * geometry.size.height) {
//                                if(abs(gesture.velocity.height) > 150){
//                                    miniscreen()
//                                }else{
//                                    withAnimation(.easeInOut(duration: 0.25)) {
//                                        isMaximized = true
//                                        useMaximized = true
//                                        height = geometry.size.height
//                                    }
//                                }
//                            }else if height < 200 {
//                                miniscreen()
//                            }else if(abs(gesture.velocity.height) > 150){
//                                if(isMaximized){
//                                    miniscreen()
//                                }else{
//                                    withAnimation(.easeInOut(duration: 0.25)) {
//                                        isMaximized = true
//                                        useMaximized = true
//                                        height = geometry.size.height
//                                    }
//                                }
//                            }else{
//                                if(isMaximized){
//                                    withAnimation(.easeInOut(duration: 0.25)) {
//                                        isMaximized = true
//                                        useMaximized = true
//                                        height = geometry.size.height
//                                    }
//                                }else{
//                                    miniscreen()
//                                }
//                            }
//                            offset = .zero
//                        }
//                )
//            }
//            .offset(x: 0, y: -playerOffset)
//            .onReceive(playerTimer) { _ in
//                guard let player = soundManager.audioPlayer, !isEditing else { return }
//                globalVariables.time = Double(Float(CMTimeGetSeconds(player.currentTime())))
//                audioOnEnded()
//            }
//        }
//        .frame(maxHeight: .infinity)
//    }
//
//    func miniscreen(){
//        withAnimation(.easeInOut(duration: 0.25)) {
//            isMaximized = false
//            height = 50.0
//            useMaximized = false
//        }
//    }
//    //MARK: controls view
//    @ViewBuilder
//    func playerControlsView() -> some View {
//        VStack{
//            Spacer()
//            ZStack{
//                VStack{
//                    List(){
//                        ForEach(songs, id: \._id){ i in
//                            HStack{
//                                squareImage48by48(urlString: i.albumReference.coverArt)
//                                HStack{
//                                    VStack(alignment: .leading){
//                                        Text(i.tracktitle)
//                                            .fontWeight(.bold)
//                                            .foregroundColor(Color("BlackWhite"))
//                                            .lineLimit(3)
//                                        Text(i.artistDetails.artistName)
//                                            .font(.caption)
//                                            .fontWeight(.regular)
//                                            .foregroundColor(Color.gray)
//                                            .lineLimit(1)
//                                    }
//                                    Spacer()
//                                    Image(systemName: "line.3.horizontal")
//                                        .foregroundColor(Color.gray)
//                                        .padding()
//                                }
//                            }
//                            .listRowBackground((i._id == currentSong._id) ? Color.accentColor.opacity(0.25) : nil)
//                        }
//                        .onMove( perform: { IndexSet, Int in
//                            songs.move(fromOffsets: IndexSet, toOffset: Int)
//                            checkNextPrevious()
//                        })
//                        Text("Hold and drag to rearrange")
//                            .font(.caption)
//                            .foregroundColor(Color.gray)
//                            .frame(maxWidth: .infinity, alignment: .center)
//                            .listRowBackground(Color.accentColor.opacity(0))
//                    }
//                }
//                .opacity((listView) ? 1 : 0)
//                GeometryReader{ geometry in
//                    VStack{
//                        squareImageMaxDisplay(urlString: coverArt)
//                            .frame(width: geometry.size.width - 80, height: geometry.size.width - 80)
//                            .scaleEffect((isTrackPlaying) ? 1 : 0.9)
//                            .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y:5)
//                            .opacity((listView) ? 0 : 1)
//                            .animation(.interpolatingSpring(stiffness: 250, damping: 20), value: isTrackPlaying)
//                    }
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                }
//            }
//            Spacer()
//            HStack{
//                VStack(alignment: .leading){
//                    Text(title)
//                        .font(.title)
//                        .lineLimit(1)
//                    Text(artistName)
//                        .font(.headline)
//                        .foregroundColor(Color.gray)
//                        .lineLimit(1)
//                }
//                .padding(.horizontal)
//                Spacer()
//            }
//            let num = (set == true) ? Double(CMTimeGetSeconds(soundManager.audioPlayer?.currentItem?.asset.duration ?? CMTime(seconds: 0, preferredTimescale: 0))) : 0
//            ValueSlider(value: $globalVariables.time, in: 0...num){editing in
//                if !editing {
//                    isEditing = editing
//                    soundManager.audioPlayer?.seek(to: CMTimeMakeWithSeconds(globalVariables.time, preferredTimescale: 1000000))
//                }
//            }
//            .frame(height: 40.0)
//            .valueSliderStyle(
//                HorizontalValueSliderStyle(
//                    track: HorizontalValueTrack(
//                        view: Capsule().foregroundColor(Color("BlackWhite"))
//                            .cornerRadius(0)
//                    )
//                    .background(Capsule().foregroundColor(Color.gray.opacity(0.25)))
//                    .frame(height: siderHeight),
//                    thumb: Circle().foregroundColor(Color("BlackWhite")),
//                    thumbSize: CGSize(width: STWidth, height: STWidth),
//                    options: .defaultOptions
//                )
//            ).simultaneousGesture(
//                DragGesture(minimumDistance: 0)
//                    .onChanged({ _ in
//                        withAnimation(.easeInOut(duration: 0.25)){
//                            siderHeight = 32
//                            STWidth = 0
//                        }
//                    })
//                    .onEnded({ _ in
//                        withAnimation(.easeInOut(duration: 0.25)){
//                            siderHeight = 2.5
//                            STWidth = 16
//                        }
//                    })
//            )
//            .padding(.horizontal)
//            HStack{
//                Text(FormatMinutes(time: Double(globalVariables.time)))
//                    .foregroundColor(Color.gray)
//                    .font(.caption)
//                Spacer()
//                Text(FormatMinutes(time: num))
//                    .font(.caption)
//                    .foregroundColor(Color.gray)
//                    .lineLimit(1)
//            }
//            .padding(.horizontal)
//            HStack(spacing:20){
//                Button {
//                    repeating.toggle()
//                    repeatButtonScale = 0.5
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                        repeatButtonScale = 1
//                    }
//                } label: {
//                    Image(systemName: (repeating) ? "repeat.1.circle.fill" : "repeat")
//                        .frame(width: 50, height: 50)
//                        .font(.system(size: (repeating) ? 40 : 30))
//                        .foregroundColor((repeating) ? Color.accentColor: Color("BlackWhite"))
//                        .scaleEffect(repeatButtonScale)
//                        .animation(.interpolatingSpring(stiffness: 250, damping: 20), value: repeatButtonScale)
//                }
//                Button {
//                    previousSong()
//                } label: {
//                    Image(systemName: "backward.fill")
//                        .frame(width: 50, height: 50)
//                        .font(.system(size: 30))
//                        .foregroundColor((previousEnabled) ? Color("BlackWhite") : Color.gray)
//                        .opacity((previousEnabled) ? 1 : 0.5)
//                        .scaleEffect(previousButtonScale)
//                        .animation(.interpolatingSpring(stiffness: 250, damping: 20), value: previousButtonScale)
//                }
//                .disabled((previousEnabled) ? false : true)
//                ZStack{
//                    Circle()
//                        .strokeBorder((isTrackPlaying) ? Color.accentColor : Color("BlackWhite"),lineWidth: 2.5)
//                        .frame(width: 75, height: 75)
//
//                    //MARK: Play button controls view
//                    Button {
//                        if songs != []{
//                            if isTrackPlaying {
//                                soundManager.audioPlayer?.pause()
//                                isTrackPlaying.toggle()
//                            } else {
//                                soundManager.audioPlayer?.play()
//                                isTrackPlaying.toggle()
//                            }
//                        } else{
//                            isTrackPlaying.toggle()
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                                if ((soundManager.audioPlayer?.isPlaying) != nil) {
//                                    isTrackPlaying = true
//                                }else{
//                                    isTrackPlaying = false
//                                }
//                            }
//                        }
//                    } label: {
//                        ZStack{
//                            if isLoading {
//                                ProgressView()
//                            }else{
//                                Image(systemName: "play.fill")
//                                    .foregroundColor((isTrackPlaying) ? nil : Color("BlackWhite"))
//                                    .frame(width: 100, height: 100)
//                                    .scaleEffect((isTrackPlaying) ? 0 : 1)
//                                    .opacity((isTrackPlaying) ? 0 : 1)
//                                    .font(.system(size: 25))
//                                Image(systemName: "pause.fill")
//                                    .foregroundColor((isTrackPlaying) ? nil : Color("BlackWhite"))
//                                    .frame(width: 100, height: 100)
//                                    .scaleEffect((isTrackPlaying) ? 1 : 0)
//                                    .opacity((isTrackPlaying) ? 1 : 0)
//                                    .font(.system(size: 25))
//                            }
//                        }.animation(.interpolatingSpring(stiffness: 250, damping: 20), value: isTrackPlaying)
//                    }
//                }
//
//                Button {
//                    nextSong()
//                } label: {
//                    Image(systemName: "forward.fill")
//                        .frame(width: 50, height: 50)
//                        .foregroundColor((nextEnabled) ? Color("BlackWhite") : Color.gray)
//                        .opacity((nextEnabled) ? 1 : 0.5)
//                        .font(.system(size: 30))
//                        .scaleEffect(nextButtonScale)
//                        .animation(.interpolatingSpring(stiffness: 250, damping: 20), value: nextButtonScale)
//                }
//                .disabled((nextEnabled) ? false : true)
//
//                Button {
//                    withAnimation(.easeInOut(duration: 0.25)){
//                        listView.toggle()
//                    }
//                    listButtonScale = 0.5
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                        listButtonScale = 1
//                    }
//                } label: {
//                    Image(systemName: (listView) ? "list.bullet.circle.fill" : "list.bullet")
//                        .frame(width: 50, height: 50)
//                        .font(.system(size: (listView) ? 40 : 30))
//                        .foregroundColor((listView) ? Color.accentColor : Color("BlackWhite"))
//                        .scaleEffect(listButtonScale)
//                        .animation(.interpolatingSpring(stiffness: 250, damping: 20), value: listButtonScale)
//                }
//            }
//            Spacer()
//                .frame(height: 25)
//        }
//    }
//
//    func playSound(url: String, title: String, albumArtwork: String, albumTitle: String, artist: String, isExplicit: Bool, rate: Float) {
//        do {
//            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options:
//                    .init(rawValue: 0))
//            try AVAudioSession.sharedInstance().setActive(true)
//            if set{
//            }else{
//                repeated = 0
//                soundManager.playSound(sound: url)
//                trackHasEnded = false
//                set.toggle()
//            }
//            isTrackPlaying.toggle()
//
//            if isTrackPlaying {
//                soundManager.audioPlayer?.play()
//                checkNextPrevious()
//                setupNowPlaying()
//                UIApplication.shared.beginReceivingRemoteControlEvents()
//                MPNowPlayingInfoCenter.default().playbackState = .playing
//            } else {
//                soundManager.audioPlayer?.pause()
//            }
//        }catch{
//            print("Something came up")
//        }
//    }
//
//    func setupNowPlaying() {
//        func setup(){
//            let url = URL.init(string: coverArt)!
//            let mpic = MPNowPlayingInfoCenter.default()
//            DispatchQueue.global().async {
//                if let data = try? Data.init(contentsOf: url), let image = UIImage(data: data) {
//                    let artwork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { (_ size : CGSize) -> UIImage in
//                        return image
//                    })
//                    DispatchQueue.main.async {
//                        mpic.nowPlayingInfo = [
//                            MPMediaItemPropertyTitle: title,
//                            MPMediaItemPropertyArtist: artistName,
//                            MPMediaItemPropertyArtwork: artwork,
//                            MPMediaItemPropertyAlbumTitle: albumTitle,
//                            MPMediaItemPropertyIsExplicit: isExplicit,
//                            MPNowPlayingInfoPropertyElapsedPlaybackTime: soundManager.audioPlayer?.currentTime().seconds ?? 0,
//                            MPNowPlayingInfoPropertyPlaybackRate: soundManager.audioPlayer?.rate ?? 0,
//                            MPMediaItemPropertyPlaybackDuration: CMTimeGetSeconds(soundManager.audioPlayer?.currentItem?.asset.duration ?? CMTime(seconds: 0, preferredTimescale: 0))
//                        ]
//                    }
//                }
//                setup()
//            }
//        }
//        setup()
//        commandCenter.pauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
//            soundManager.audioPlayer?.pause()
//            isTrackPlaying.toggle()
//            setup()
//            return .success
//        }
//        commandCenter.playCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
//            soundManager.audioPlayer?.play()
//            isTrackPlaying.toggle()
//            setup()
//            return .success
//        }
//        commandCenter.togglePlayPauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
//            if isTrackPlaying {
//                soundManager.audioPlayer?.play()
//                isTrackPlaying.toggle()
//            } else {
//                isTrackPlaying.toggle()
//            }
//            setup()
//            return .success
//        }
//        commandCenter.changePlaybackPositionCommand.addTarget(handler: {
//            (event) in
//            let event = event as! MPChangePlaybackPositionCommandEvent
//            self.soundManager.audioPlayer?.seek(to: CMTimeMakeWithSeconds(event.positionTime, preferredTimescale: 1000000))
//            setup()
//            return MPRemoteCommandHandlerStatus.success
//        })
//        commandCenter.nextTrackCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
//            nextSong()
//            return .success
//        }
//        commandCenter.previousTrackCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
//            nextSong()
//            return .success
//        }
//        commandCenter.nextTrackCommand.isEnabled = nextEnabled
//        commandCenter.previousTrackCommand.isEnabled = previousEnabled
//    }
//
//    func audioOnEnded() {
//        let num = (set == true) ? Double(CMTimeGetSeconds(soundManager.audioPlayer?.currentItem?.asset.duration ?? CMTime(seconds: 0, preferredTimescale: 0))) : 0
//        if set {
//            if (num - 0.5) < globalVariables.time{ //0.5 seconds away from end
//                trackHasEnded = true
//                if repeated == 1 || repeating == false { //if track shouldn't repeat or has repeated
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                        if trackHasEnded {
//                            nextSong()
//                            repeated = 0
//                            trackHasEnded = false
//                        }
//                    }
//                }else{
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                        if trackHasEnded {
//                            self.soundManager.audioPlayer?.seek(to: CMTimeMakeWithSeconds(0, preferredTimescale: 10))
//                            globalVariables.time = 0
//                            repeated = 1
//                            soundManager.audioPlayer?.play()
//                            trackHasEnded = false
//
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//    func nextSong(){
//        guard let currentIndex = songs.firstIndex(of: currentSong) else { return }
//        var nextSong = 0
//        isLoading = true
//        nextButtonScale = 0.5
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            nextButtonScale = 1
//        }
//        if songs.count > 0{
//            nextSong = (currentIndex + 1 + songs.count) % songs.count;
//            set = false
//            let track = songs[nextSong]
//            currentSong = track
//            title = track.tracktitle
//            artistName = track.artistDetails.artistName
//            coverArt = track.albumReference.coverArt
//            albumTitle = track.albumReference.title
//            isExplicit = track.explicit ?? false
//            setupNowPlaying()
//            if isTrackPlaying{
//                soundManager.audioPlayer?.pause()
//                isTrackPlaying = false
//            }
//            fetchData()
//            playSound(
//                url: track.audio,
//                title: track.tracktitle,
//                albumArtwork: track.albumReference.coverArt,
//                albumTitle: track.albumReference.title,
//                artist: track.artistDetails.artistName,
//                isExplicit: track.explicit ?? false,
//                rate: soundManager.audioPlayer?.rate ?? 0
//            )
//        }
//        isLoading = false
//    }
//
//    func previousSong(){
//        guard let currentIndex = songs.firstIndex(of: currentSong) else { return }
//        var previousSong = 0
//        isLoading = true
//        previousButtonScale = 0.5
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            previousButtonScale = 1
//        }
//        if songs.count > 0{
//            previousSong = (currentIndex - 1 + songs.count) % songs.count;
//            set = false
//            let track = songs[previousSong]
//            currentSong = track
//            title = track.tracktitle
//            artistName = track.artistDetails.artistName
//            coverArt = track.albumReference.coverArt
//            albumTitle = track.albumReference.title
//            isExplicit = track.explicit ?? false
//            setupNowPlaying()
//            if ((soundManager.audioPlayer?.isPlaying) != nil) {
//                soundManager.audioPlayer?.pause()
//                isTrackPlaying = false
//            }
//            fetchData()
//            playSound(
//                url: track.audio,
//                title: track.tracktitle,
//                albumArtwork: track.albumReference.coverArt,
//                albumTitle: track.albumReference.title,
//                artist: track.artistDetails.artistName,
//                isExplicit: track.explicit ?? false,
//                rate: soundManager.audioPlayer?.rate ?? 0
//            )
//        }
//        isLoading = false
//    }
//
//    func checkNextPrevious(){
//        let song = (songs.count) - 2
//        guard let currentIndex = songs.firstIndex(of: currentSong) else { return }
//        print("currentIndex: IUD:", currentIndex)
//        if currentIndex > song {
//            nextEnabled = false
//        }else{
//            nextEnabled = true
//        }
//
//        if currentIndex == 0{
//            previousEnabled = false
//        }else{
//            previousEnabled = true
//        }
//    }
//
//    func checkSongs(){
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
//            if changingTrack{
//                if ((soundManager.audioPlayer?.isPlaying) != nil) {
//                    soundManager.audioPlayer?.pause()
//                    isTrackPlaying = false
//                    changedTrack = false
//                }
//                if stopPlaying{
//                    return
//                }
//                checkSongs()
//            }else{
//                if changedTrack{
//                    print("should play")
//                    set = false
//                    let track = songs[0]
//                    changedTrack = false
//                    changingTrack = false
//                    playSound(
//                        url: track.audio,
//                        title: track.tracktitle,
//                        albumArtwork: track.albumReference.coverArt,
//                        albumTitle: track.albumReference.title,
//                        artist: track.artistDetails.artistName,
//                        isExplicit: track.explicit ?? false,
//                        rate: soundManager.audioPlayer?.rate ?? 0
//                    )
//                    title = track.tracktitle
//                    artistName = track.artistDetails.artistName
//                    coverArt = track.albumReference.coverArt
//                    albumTitle = track.albumReference.title
//                    isExplicit = track.explicit ?? false
//                    fetchData()
//                }
//                checkSongs()
//            }
//        }
//    }
//
//    private func fetchData(){
//        guard let url = URL(string: "\(coverArt)/v1/fill/w_64,h_64,al_c/Soundlytude.jpg") else {
//            return
//        }
//        let task = URLSession.shared.dataTask(with: url) { data, _, _
//            in
//            self.data = data
//        }
//        task.resume( )
//    }
//    //
//    //    private func setUpKeyboardHiding(){
//    //        NotificationCenter.default.addObserver(self, selector: (keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//    //        NotificationCenter.default.addObserver(self, selector: (keyboardWillHide), name: UIResponder.keyboardDidHideNotification, object: nil)
//    //    }
//    //    func keyboardWillShow(sender: NSNotification){
//    //
//    //    }
//    //    func keyboardWillHide(sender: NSNotification){
//    //
//    //    }
//}
