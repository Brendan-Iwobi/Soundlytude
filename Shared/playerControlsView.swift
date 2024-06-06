//
//  PlayerControlsView.swift
//  Soundlytude
//
//  Created by DJ bon26 on 9/22/22.
//

import SwiftUI
import Introspect
import Sliders
import MediaPlayer
import AVKit


//struct PlayerControlsView_Previews: PreviewProvider {
//    @Namespace var animation
//    static var previews: some View {
//        playerView(animation: animation)
//            .environmentObject(globalVariables())
//    }
//}

func stop() {
    changingTrack = true
    stopPlaying = true
}

struct miniplayer: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var globalVariables: globalVariables
    
    @StateObject var volumeViewModel = VolumeViewModel()
    @StateObject var vm = LocalWebViewVM(webResource: "index")
    
    @State var nextEnabled = false
    @State var previousEnabled = false
    @State var fullScreenView: Bool = false
    @State var setCoverArt = false
    @State var setDo = false
    @State var percentage: Float = 50
    @State var STHeight: CGFloat = 5
    @State var STThumbWidth: CGFloat = 20
    @State var SVHeight: CGFloat = 5
    @State var SVThumbWidth: CGFloat = 20
    @State var nextButtonScale: Double = 1
    @State var previousButtonScale: Double = 1
    @State var listButtonScale: Double = 1
    @State var repeatButtonScale: Double = 1
    @State private var isEditing: Bool = false
    @State var data: Data?
    @State var dataSmall: Data?
    @State var navigateTo: AnyView?
    @State var isNavigationActive = false
    
    @State var funcIsLoading = false
    @State var isLoading: Bool = false
    @State var isTrackPlaying: Bool = false
    @State var repeating: Bool = false
    @State var listView: Bool = false
    @State var repeated: Int = 0
    @State var trackHasEnded: Bool = false
    
    @State var title: String = "Not Playing"
    @State var artistName: String = ""
    @State var coverArt: String = "artwork"
    @State var albumTitle: String = ""
    @State var isExplicit: Bool = false
    
    @State var coverArtLarge: String = ""
    @State var coverArtSmall: String = ""
    
    @State var playerRotate: Double = 0
    @State var playerRotateMiddle: Double = 0
    @State var previousUrl: String = ""
    
    @State var onRearrangedSongsQueue: Bool = false
    @State var tappedSong: playerField =  playerField(_id: "", tracktitle: "", audio: "", userId: "", explicit: false, artistDetails: playerArtistDetails(artistName: "", _id: "", pimage: "", verification: false), albumReference: playerAlbumField(_id: "", title: "", coverArt: "", themeColor: "", description: "", commentCount: 0))
    
    @State private var location: CGPoint = CGPoint(x: 0, y: 0)
    @State private var allowReordering = true
    @State private var songSelectedChange = false
    //    @State var height = 50.0
    
//    let commandCenter = MPRemoteCommandCenter.shared()
    
    var playerOffset: CGFloat = 0.0
//    let playerTimer = Timer
//        .publish(every: 0.5, on: .main, in: .common)
//        .autoconnect()
    var animation: Namespace.ID
    @Binding var expand : Bool
    @Binding var wasExpanded: Bool
    @State var wasExpanded2: Bool = false
    @Binding var isDragging: Bool
    @Binding var draggingOffset: Double
    @State var expanding = false
    
//    var height = viewableWidth - 50
    var height = viewableHeight / 3
    
    // safearea...
    
    //    var safeArea = UIWindowScene.windows.first?.safeAreaInsets
    var safeArea = UIApplication.shared.windows.first?.safeAreaInsets
    
    // Volume Slider...
    
    @State var volume : CGFloat = 0
    
    // gesture Offset...
    @State var screenHeight: Double = 0.0
    @State var offset : CGFloat = 0
    
    var imageSaturation: Double {
        if isTrackPlaying {
            if colorScheme == .dark {
                return 2.9
            }else{
                return 3.5
            }
        }else{
            if colorScheme == .dark {
                return 1.9
            }else{
                return 2.5
            }
        }
    }
    
    var imageListViewSize: Double {
        if listView {
            return 55
        }else{
            return 45
        }
    }
    var body: some View {
        ZStack{
            WebView(vm: vm)
                .frame(height: 0)
//            Spacer()
            VStack(spacing: 0){
                ZStack{
                    AsyncImage(url: URL(string: coverArtSmall)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .saturation(imageSaturation)
                            .opacity(0.9)
                        
                    } placeholder: {
                        Image("Soundlytude empty placeHolder")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .opacity(0.9)
                    }
                    .frame(width: expand ? viewableWidth : 0, height: expand ? UIScreen.main.bounds.height : 0)
                    .blur(radius: 60)
                    .rotationEffect(.degrees(playerRotate))
                    .scaleEffect(isTrackPlaying ? 1.5 : 1.25)
                    .offset(y: isTrackPlaying ? -50 : 0)
                    .animation(.interactiveSpring(response: 2, dampingFraction: 0.5, blendDuration: 0.5), value: isTrackPlaying)
                    Color("BlackWhite")
                        .opacity(expanding ? 0.15 : 0)
                    BlurView()
                        .environment(\.colorScheme, .dark)
                        .opacity(expand ? 1 : 0)
                    BlurView()
                        .environment(\.colorScheme, colorScheme)
                        .opacity(expand ? 0.25 : 0.001)
                    Color.black.opacity(isTrackPlaying ? 0.5 : 0.75) //OG: 0.9 (/1.5)
                        .mask(
                            LinearGradient(colors:[
                                .clear,
                                .clear,
                                Color.black], startPoint: .top, endPoint: .bottom))
                        .opacity(expand ? 1 : 0)
                        .animation(.easeIn(duration: 1), value: isTrackPlaying)
                    Color.accentColor.opacity(0.25) //OG: 0.5 (/1.5)
                        .mask(
                            LinearGradient(colors:[
                                Color.black,
                                .clear], startPoint: .top, endPoint: .bottom))
                        .opacity(expand ? 1 : 0)
                    //                        BlurView()
                    //                            .opacity(expand && !backgroudCoverArtVisible ? (colorScheme == .dark ? 1 : 0.85) : 0)
                    //                            .blur(radius: (colorScheme == .dark ? 50 : 0))
                }
                Divider()
            }
            .onTapGesture(perform: {
                withAnimation(.easeIn(duration: 0.1)){
                    expanding = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.775, blendDuration: 0.5)){
                        expand = true
                        wasExpanded = true
                        wasExpanded2 = true
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation(.easeIn(duration: 0.1)){
                        expanding = false
                    }
                }
            })
            VStack{
                Spacer()
                Capsule()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: expand ? 40 : 0, height: expand ? 5 : 0)
                    .opacity(expand ? 1 : 0)
                    .padding(.top,expand ? safeArea?.top : 0)
                    .padding(.bottom, expand ? 30 : 0)
                
                HStack(spacing: 0){
                    
                    // centering Image...
                    
                    if expand{Spacer(minLength: 0)}
                    VStack(spacing: 0){// LARGE / SMALL Image (They shrink and grow)
                        HStack{
                            AsyncImage(url: URL(string: coverArtLarge)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .background (Color.gray)
                                    .saturation(isTrackPlaying ? 1.0 : 0.75)
                                
                            } placeholder: {
                                Image("Soundlytude empty placeHolder")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .opacity(0.5)
                            }
                            .frame(width: expand && !listView ? height : imageListViewSize, height: expand && !listView ? height : imageListViewSize)
                            .cornerRadius(10)
                            .scaleEffect((isTrackPlaying || listView) ? 1 : (expand ? 0.75 : 0.9))
                            .shadow(color: Color.black.opacity(expand ? (isTrackPlaying ? 0.6 : 0.75) : 0), radius: isTrackPlaying ? 20 : 4, x: 0, y: isTrackPlaying ? 10 : 2.5)
                            .animation(.interactiveSpring(response: 0.55, dampingFraction: 0.5, blendDuration: 1.0), value: isTrackPlaying)
                            .padding(.leading, (listView ? 20 : 0))
                            .padding(.trailing, (!expand || (expand && listView) ? 10 : 0))
                            if listView{
                                VStack(alignment: .leading, spacing: 0){
                                    Text(title) //LARGE List title
                                        .font(.body)
                                        .foregroundColor(.white)
                                        .fontWeight(.bold)
                                        .frame(
                                            minWidth: 0,
                                            maxWidth: .infinity,
                                            alignment: .topLeading
                                        )
                                        .lineLimit(1)
                                        .matchedGeometryEffect(id: "ListTitle", in: animation)
                                    Text(artistName) //LARGE list artist name
                                        .font(.callout)
                                        .foregroundColor(Color.white.opacity(0.5))
                                        .frame(
                                            minWidth: 0,
                                            maxWidth: .infinity,
                                            alignment: .topLeading
                                        )
                                        .matchedGeometryEffect(id: "ListArtistName", in: animation)
                                }
                                Spacer()
                                Button(action: {}) { //SMALL more Button
                                    
                                    Image(systemName: "ellipsis.circle")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                }
                                .padding(.leading)
                                .padding(.trailing, 20)
                                .matchedGeometryEffect(id: "songMenu", in: animation)
                            }
                        }
                        if expand {
                            playerQueue(onTap: $tappedSong.onChange(onTappedSong), onMove: $onRearrangedSongsQueue.onChange(onMoved))
//                                .frame(maxHeight: listView ? .infinity : 0)
                                .mask( LinearGradient(gradient: Gradient(stops: [
                                    Gradient.Stop(color: .clear, location: 0.01),
                                    Gradient.Stop(color: .black, location: 0.15),
                                    Gradient.Stop(color: .black, location: 0.9),
                                    Gradient.Stop(color: .clear, location: 1),
                                ]), startPoint: .top, endPoint: .bottom))
                                .opacity(!listView ? 0 : 1)
                                .transition(AnyTransition.opacity.combined(with: .move(edge: .bottom)))
                        }
                    }
                    if !expand{
                        
                        Text(title) //SMALL title
                            .font(.body)
                            .lineLimit(2)
                            .foregroundColor(.primary)
                            .frame(
                                minWidth: 0,
                                maxWidth: .infinity,
                                alignment: .topLeading
                            )
                            .matchedGeometryEffect(id: "Label", in: animation)
                    }
                    
                    Spacer(minLength: 0)
                    
                    if !expand{
                        
                        Button { //SMALL play Button
                            togglePlay()
                        } label: {
                            ZStack{
                                if isLoading {
                                    ProgressView()
                                }else{
                                    Image(systemName: "play.fill")
                                        .foregroundColor((isTrackPlaying) ? nil : Color("BlackWhite"))
                                        .scaleEffect((isTrackPlaying) ? 0 : 1)
                                        .opacity((isTrackPlaying) ? 0 : 1)
                                        .font(.system(size: 25))
                                    Image(systemName: "pause.fill")
                                        .foregroundColor((isTrackPlaying) ? nil : Color("BlackWhite"))
                                        .scaleEffect((isTrackPlaying) ? 1 : 0)
                                        .opacity((isTrackPlaying) ? 1 : 0)
                                        .font(.system(size: 25))
                                }
                            }.animation(.interpolatingSpring(stiffness: 250, damping: 20), value: isTrackPlaying)
                        }
                        .frame(width: 40, height: 40)
                        .transition(AnyTransition.opacity.combined(with: .move(edge: .top)))
                        .padding(.trailing)
                        Button { //SMALL forward Button
                            nextSong()
                        } label: {
                            Image(systemName: "forward.fill")
                                .font(.system(size: 25))
                                .foregroundColor((nextEnabled) ? Color("BlackWhite") : Color.gray)
                                .opacity((nextEnabled) ? 1 : 0.5)
                                .scaleEffect(nextButtonScale)
                                .animation(.interpolatingSpring(stiffness: 250, damping: 20), value: nextButtonScale)
                        }
                        .frame(width: 40, height: 40)
                        .disabled((nextEnabled) ? false : true)
                        .transition(AnyTransition.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(!expand ? [.horizontal] : [])
                
                VStack(spacing: 5){
                    
//                    Spacer(minLength: 0)
                    
                    HStack{
                        
                        if expand && !listView{
                            VStack(alignment: .leading){
                                Text(title) //LARGE title
                                    .font(listView ? .body : .title2)
                                    .foregroundColor(.primary)
                                    .fontWeight(.bold)
                                    .lineLimit(2)
                                    .frame(
                                        minWidth: 0,
                                        maxWidth: .infinity,
                                        alignment: .topLeading
                                    )
                                    .matchedGeometryEffect(id: "Label", in: animation)
                                    .matchedGeometryEffect(id: "ListTitle", in: animation)
                                Text(artistName) //LARGE artist name
                                    .font(listView ? .callout : .body)
                                    .foregroundColor(Color.white.opacity(0.5))
                                    .lineLimit(1)
                                    .frame(
                                        minWidth: 0,
                                        maxWidth: .infinity,
                                        alignment: .topLeading
                                    )
                                    .matchedGeometryEffect(id: "ListArtistName", in: animation)
                            }
                            Spacer(minLength: 0)
                            
                            Button(action: {}) { //LARGE more Button
                                
                                Image(systemName: "ellipsis.circle")
                                    .font(.title2)
                                    .foregroundColor(.primary)
                            }
                            .matchedGeometryEffect(id: "songMenu", in: animation)
                        }
                    }
                    .padding(.vertical, listView ? 0 : 20)
                    .padding(.horizontal, 35)
                    
//                    if !listView{
                    if true {
                        Group {
                            // Range String...
                            valueSlider()
                                .frame(height: 25.0)
                                .valueSliderStyle(
                                    HorizontalValueSliderStyle(
                                        track: HorizontalValueTrack(
                                            view: Capsule().foregroundColor(Color("BlackWhite"))
                                                .cornerRadius(0)
                                        )
                                        .background(Capsule().foregroundColor(Color.white.opacity(0.25)))
                                        .frame(height: STHeight),
                                        thumb: Circle().foregroundColor(Color("BlackWhite")),
                                        thumbSize: CGSize(width: STThumbWidth, height: STThumbWidth),
                                        options: .defaultOptions
                                    )
                                ).simultaneousGesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged({ _ in
                                            withAnimation(.easeInOut(duration: 0.3)){
                                                STHeight = 15
                                            }
                                            withAnimation(.easeInOut(duration: 0.1)){
                                                STThumbWidth = 0
                                            }
                                        })
                                        .onEnded({ _ in
                                            withAnimation(.easeInOut(duration: 0.25)){
                                                STHeight = 5
                                                STThumbWidth = 20
                                            }
                                        })
                                )
                                .padding(.horizontal, 35)
                            HStack{
                                Text(FormatMinutes(time: Double(globalVariables.time)))
                                    .foregroundColor(Color.white.opacity(0.5))
                                    .font(.caption)
                                Spacer()
                                Text(FormatMinutes(time: Double(globalVariables.duration)))
                                    .font(.caption)
                                    .foregroundColor(Color.white.opacity(0.5))
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, 35)
                        }
                        .transition(AnyTransition.opacity.combined(with: .move(edge: .top)))
                    }
                    
                    // Skip Rewind Pause Buttons...
                    
                    HStack(spacing:20){
                        Button {
                            previousSong()
                        } label: {
                            Image(systemName: "backward.fill")
                                .frame(width: 50, height: 50)
                                .font(.system(size: 30))
                                .foregroundColor((previousEnabled) ? Color("BlackWhite") : Color.gray)
                                .opacity((previousEnabled) ? 1 : 0.5)
                                .scaleEffect(previousButtonScale)
                                .animation(.interpolatingSpring(stiffness: 250, damping: 20), value: previousButtonScale)
                        }
                        .disabled((previousEnabled) ? false : true)
                        ZStack{
                            Circle()
                                .strokeBorder((isTrackPlaying) ? Color.accentColor : Color("BlackWhite"),lineWidth: 2.5)
                                .frame(width: 75, height: 75)
                            
                            //MARK: Play button controls view
                            Button { //LARGE play Button
                                togglePlay()
                            } label: {
                                ZStack{
                                    if isLoading {
                                        ProgressView()
                                            .font(.system(size: 25))
                                    }else{
                                        Image(systemName: "play.fill")
                                            .foregroundColor((isTrackPlaying) ? nil : Color("BlackWhite"))
                                            .frame(width: 100, height: 100)
                                            .scaleEffect((isTrackPlaying) ? 0 : 1)
                                            .opacity((isTrackPlaying) ? 0 : 1)
                                            .font(.system(size: 25))
                                        Image(systemName: "pause.fill")
                                            .foregroundColor((isTrackPlaying) ? nil : Color("BlackWhite"))
                                            .frame(width: 100, height: 100)
                                            .scaleEffect((isTrackPlaying) ? 1 : 0)
                                            .opacity((isTrackPlaying) ? 1 : 0)
                                            .font(.system(size: 25))
                                    }
                                }.animation(.interpolatingSpring(stiffness: 250, damping: 20), value: isTrackPlaying)
                            }
                        }
                        
                        Button {
                            nextSong()
                        } label: {
                            Image(systemName: "forward.fill")
                                .frame(width: 50, height: 50)
                                .foregroundColor((nextEnabled) ? Color("BlackWhite") : Color.gray)
                                .opacity((nextEnabled) ? 1 : 0.5)
                                .font(.system(size: 30))
                                .scaleEffect(nextButtonScale)
                                .animation(.interpolatingSpring(stiffness: 250, damping: 20), value: nextButtonScale)
                        }
                        .disabled((nextEnabled) ? false : true)
                        
                    }
                    .padding(.top)
                    
                    Spacer()
                        .frame(height: 20)
                    
                    HStack(spacing: 15){
                        
                        Image(systemName: "speaker.fill")
                        
                        ValueSlider(value: $volumeViewModel.volume, in: 0...1){editing in
                            volumeViewModel.setVolume()
                            //                        if !editing {
                            //                            isEditing = editing
                            //                            MPVolumeView.setVolume(Float(volume))
                            //                        }
                        }
                        .frame(height: 25.0)
                        .valueSliderStyle(
                            HorizontalValueSliderStyle(
                                track: HorizontalValueTrack(
                                    view: Capsule().foregroundColor(Color("BlackWhite"))
                                        .cornerRadius(0)
                                )
                                .background(Capsule().foregroundColor(Color.white.opacity(0.25)))
                                .frame(height: SVHeight),
                                thumb: Circle().foregroundColor(Color("BlackWhite")),
                                thumbSize: CGSize(width: SVThumbWidth, height: SVThumbWidth),
                                options: .defaultOptions
                            )
                        ).simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged({ _ in
                                    withAnimation(.easeInOut(duration: 0.3)){
                                        SVHeight = 15
                                    }
                                    withAnimation(.easeInOut(duration: 0.1)){
                                        SVThumbWidth = 0
                                    }
                                })
                                .onEnded({ _ in
                                    withAnimation(.easeInOut(duration: 0.25)){
                                        SVHeight = 5
                                        SVThumbWidth = 20
                                    }
                                })
                        )
                        .padding(.horizontal, 5)
                        
                        Image(systemName: "speaker.wave.2.fill")
                    }
                    .padding(.bottom)
                    .padding(.horizontal, 35)
                    HStack(spacing: 50){
                        
                        Button {
                            repeating.toggle()
                            repeatButtonScale = 0.5
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                repeatButtonScale = 1
                            }
                        } label: {
                            Image(systemName: (repeating) ? "repeat.1.circle.fill" : "repeat")
                                .frame(width: 40, height: 40)
                                .font(.system(size: (repeating) ? 30 : 20))
                                .foregroundColor((repeating) ? Color.accentColor: Color("BlackWhite"))
                                .scaleEffect(repeatButtonScale)
                                .animation(.interpolatingSpring(stiffness: 250, damping: 20), value: repeatButtonScale)
                        }
                        
                        Button(action: {}) {
                            
                            Image(systemName: "airplayaudio")
                                .font(.title2)
                                .foregroundColor(.primary)
                        }
                        
                        Button {
                            withAnimation(.easeOut(duration: 0.25)){
                                listView.toggle()
                            }
                            listButtonScale = 0.5
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                listButtonScale = 1
                            }
                        } label: {
                            Image(systemName: (listView) ? "list.bullet.circle.fill" : "list.bullet")
                                .frame(width: 40, height: 40)
                                .font(.system(size: (listView) ? 30 : 20))
                                .foregroundColor((listView) ? Color.accentColor : Color("BlackWhite"))
                                .scaleEffect(listButtonScale)
                                .animation(.interpolatingSpring(stiffness: 250, damping: 20), value: listButtonScale)
                        }
                    }
//                    .padding(.bottom, safeArea?.bottom == 0 ? 15 : ((safeArea?.bottom ?? 0) + 15.0))
                    .padding(.horizontal, 35)
                    Spacer()
                        .frame(height: safeArea?.bottom == 0 ? 20 : ((safeArea?.bottom ?? 0) + 20.0))
                }
                // this will give strech effect...
                .frame(height: expand ? nil : 0)
                .opacity(expand ? 1 : 0)
                .environment(\.colorScheme, .dark)
            }
        }
        .frame(minHeight: expand ? UIScreen.main.bounds.height + 20 : nil)
        .animation(.interpolatingSpring(stiffness: 250, damping: 20), value: isLoading)
        .onReceive(vm.$messageFromWV, perform: {x in
            
            if x.reason == "playerCurrentTime" {
                if !isEditing {
                    globalVariables.time = Double(x.messageDouble)
                    withAnimation(.easeIn(duration: 1)){
                        playerRotate = playerRotate - 1
                    }
                }
            }
            if x.reason == "currentPlayingItem" {
                currentSong = songs[Int(x.messageDouble)]
                title = currentSong.tracktitle
                artistName = currentSong.artistDetails.artistName
                coverArt = currentSong.albumReference.coverArt
                albumTitle = currentSong.albumReference.title
                isExplicit = currentSong.explicit ?? false
                if playingType == "Playlist" || !setCoverArt {
                    setCoverArt = true
                    fetchData()
                }
            }
            if x.reason == "thirdPartyPlay" {
                isTrackPlaying = true
                isLoading = false
                funcIsLoading = false
            }
            if x.reason == "playSuccess" {
                isTrackPlaying = true
                isLoading = false
                previousEnabled = true
                nextEnabled = true
                globalVariables.duration = Double(x.messageDouble)
                funcIsLoading = false
            }
            if x.reason == "pauseSuccess" {
                isTrackPlaying = false
                isLoading = false
                funcIsLoading = false
            }
            if x.reason == "currentPlayingItemLoading" {
                currentSong = songs[Int(x.messageDouble)]
                globalVariables.duration = Double(x.messageString) ?? 0.0
                title = currentSong.tracktitle
                artistName = currentSong.artistDetails.artistName
                coverArt = currentSong.albumReference.coverArt
                albumTitle = currentSong.albumReference.title
                isExplicit = currentSong.explicit ?? false
                if playingType == "Playlist" || !setCoverArt {
                    setCoverArt = true
                    fetchData()
                }
                isLoading = true
                previousEnabled = false
                nextEnabled = false
                playerRotate = 0
            }
            
        })
        .onAppear{
            checkSongs()
        }
        .environmentObject(globalVariables)
        // expanding to full screen when clicked...
        .frame(maxHeight: expand ? .infinity : 65)
        // moving the miniplayer above the tabbar...
        // approz tab bar height is 49
        
        // Divider Line For Separting Miniplayer And Tab Bar....
        .cornerRadius(iphoneXandUp ? (expand ? 50 : 0) : 0)
        .offset(y: offset)
        .offset(y: expand ? 0 : -playerOffset)
        .gesture(DragGesture(minimumDistance: listView ? 40 : 10).onEnded(onended(value:)).onChanged(onchanged(value:)))
        .ignoresSafeArea()
    }
    
    func onchanged(value: DragGesture.Value){
        
        // only allowing when its expanded...
        if value.translation.height > (listView ? 0 : 0) && expand {
            
            //            withAnimation(.easeIn(duration: 0.05)) {
            isDragging = true
            offset = value.translation.height + (!wasExpanded2 ? 30 : -30)
            draggingOffset = value.translation.height + (!wasExpanded2 ? 30 : -30)
            //            }
        }
        if value.translation.height < 0 && !expand{
            //            withAnimation(.easeIn(duration: 0.15)) {
            expand = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                wasExpanded = true
            }
            //            }
        }
    }
    
    func onended(value: DragGesture.Value){
        withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 0.75, blendDuration: 1)){
            
            // if value is > than height / 3 then closing view...
            print("velo:" , value.velocity.height)
            print("Was expanded?: ", wasExpanded)
            if abs(value.velocity.height) > 150{
                if wasExpanded {
                    expand = false
                    wasExpanded = false
                    wasExpanded2 = false
                    listView = false
                }else{
                    expand = true
                    wasExpanded = true
                }
            }else{
                if value.translation.height > (UIScreen.main.bounds.height / (wasExpanded2 ? 1.75 : 1.75)){
                    expand = false
                    wasExpanded = false
                    wasExpanded2 = false
                    listView = false
                }else{
                    expand = true
                    wasExpanded = true
                    wasExpanded2 = true
                }
            }
            offset = 0
        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            isDragging = false
//        }
    }
    
    func onTappedSong(to value: playerField){
        if !funcIsLoading {
            var selectedIndex = 0
            let filtered = songs.filter { word in
                return word._id == tappedSong._id
            }
            selectedIndex = songs.firstIndex(of: filtered[0]) ?? 0
            if currentSong != songs[selectedIndex] {
                funcIsLoading = true
                isLoading = true
                previousEnabled = false
                nextEnabled = false
                currentSong = songs[selectedIndex]
                title = currentSong.tracktitle
                artistName = currentSong.artistDetails.artistName
                coverArt = currentSong.albumReference.coverArt
                albumTitle = currentSong.albumReference.title
                isExplicit = currentSong.explicit ?? false
                if playingType == "Playlist" || !setCoverArt {
                    setCoverArt = true
                    fetchData()
                }
                let messageToSend = webviewPlayerField(reason: "playDemand", album: "\(selectedIndex)", songs: songs, repeat: repeating)
                vm.messageTo(message: messageToSend)
            }else{
                withAnimation(.easeInOut(duration: 0.25)){
                    listView.toggle()
                }
            }
        }
    }
    
    func onMoved(to value: Bool){
        let messageToSend = webviewPlayerField(reason: "rearrange", album: "", songs: songs, repeat: repeating)
        vm.messageTo(message: messageToSend)
    }
    
    private func fetchData(){
        coverArtLarge = "\(coverArt)/v1/fill/w_512,h_512,al_c/Soundlytude.jpg"
        coverArtSmall = "\(coverArt)/v1/fill/w_48,h_48,al_c/Soundlytude.jpg"
    }
    
        @State var skip = true
    @State var seekingIncrement: Bool = true
    @ViewBuilder
    func valueSlider() -> some View {
        let num = globalVariables.duration
        ValueSlider(value: $globalVariables.time, in: 0...(num <= 0 ? 0.001 : num)){editing in
                if !editing {
                    isEditing = false
                    let messageToSend = webviewPlayerField(reason: "seek", album: "\(globalVariables.time)", songs: [], repeat: repeating)
                    vm.messageTo(message: messageToSend)
                    playerRotateMiddle = globalVariables.time
                }else{
                    isEditing = true
                    if skip {
                        seekingIncrement = (playerRotateMiddle < globalVariables.time)
                        skip = false
                    }else{
                        playerRotateMiddle = globalVariables.time
                        skip = true
                    }
                    playerRotate = playerRotate + (seekingIncrement ? 10 : -10)
                }
            }
    }
    
    func togglePlay() {
        if songs != []{
            if !funcIsLoading {
                funcIsLoading = true
                if isTrackPlaying {
                    let messageToSend = webviewPlayerField(reason: "pause", album: playingTypeTitle, songs: [], repeat: repeating)
                    vm.messageTo(message: messageToSend)
                } else {
                    let messageToSend = webviewPlayerField(reason: "play", album: playingTypeTitle, songs: [], repeat: repeating)
                    vm.messageTo(message: messageToSend)
                }
            }
        } else{
            isTrackPlaying = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTrackPlaying = false
            }
        }
    }
    
    func nextSong(){
        if !funcIsLoading {
            funcIsLoading = true
            isLoading = true
            previousEnabled = false
            nextEnabled = false
            let messageToSend = webviewPlayerField(reason: "nextTrack", album: playingTypeTitle, songs: [], repeat: repeating)
            vm.messageTo(message: messageToSend)
        }
    }
    
    func previousSong(){
        if !funcIsLoading {
            funcIsLoading = true
            isLoading = true
            previousEnabled = false
            nextEnabled = false
            let messageToSend = webviewPlayerField(reason: "previousTrack", album: playingTypeTitle, songs: [], repeat: repeating)
            vm.messageTo(message: messageToSend)
        }
    }
    
    func checkSongs(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            if changingTrack{ //changes at fetch album / playlist
                isLoading = true
                previousEnabled = false
                nextEnabled = false
                isTrackPlaying = false
                changedTrack = false
                if stopPlaying{
                    return
                }
                checkSongs()
            }else{
                if changedTrack{
                    let messageToSend = webviewPlayerField(reason: "newQueue", album: playingTypeTitle, songs: songs, repeat: repeating)
                    vm.messageTo(message: messageToSend)
                    changedTrack = false
                    setCoverArt = false
                }
                if expandPlayer {
                    if !isTrackPlaying {
                        let messageToSend = webviewPlayerField(reason: "play", album: playingTypeTitle, songs: [], repeat: repeating)
                        vm.messageTo(message: messageToSend)
                    }
                    withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.775, blendDuration: 0.5)){
                        expand = true
                        expandPlayer = false
                    }
                }
                checkSongs()
            }
        }
    }
}

struct BlurView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
        
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        
        
    }
}

//Update system volume
extension MPVolumeView {
    static func setVolume(_ volume: Float) {
        let volumeView = MPVolumeView()
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            slider?.value = volume
        }
    }
}

class VolumeViewModel: ObservableObject {
    
    @Published var volume: Float = 0.5
    
    init() {
        setInitialVolume()
    }
    
    private func setInitialVolume() {
        volume = AVAudioSession().outputVolume
    }
    
    func setVolume() {
        
        let volumeView = MPVolumeView()
        
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.03)     {
            slider?.setValue(self.volume, animated: false)
        }
    }
}

extension UIViewController {
  func screen() -> UIScreen? {
    var parent = self.parent
    var lastParent = parent
    
    while parent != nil {
      lastParent = parent
      parent = parent!.parent
    }
    
    return lastParent?.view.window?.windowScene?.screen
  }
}

struct playerQueue: View {
    
    @Binding var onTap: playerField
    @Binding var onMove: Bool
    @State var height: Double = 0.0
    init(onTap: Binding<playerField>, onMove: Binding<Bool>) {
        UITableView.appearance().backgroundColor = .clear
        _onTap = onTap
        _onMove = onMove
    }
    
    
    var body: some View {
        VStack(spacing:0){
            List(){ // Arrageable list
                Spacer()
                    .frame(height: 5)
                    .listRowBackground(Color.clear)
                    ForEach(songs, id: \._id){ i in
                        Button {
                            onTap = i
                        } label: {
                            HStack{
                                if playingType == "Playlist"{
                                    squareImage48by48(urlString: i.albumReference.coverArt)
                                }
                                HStack{
                                    VStack(alignment: .leading){
                                        Text(i.tracktitle)
                                            .fontWeight(.bold)
                                            .foregroundColor(Color("BlackWhite"))
                                            .lineLimit(3)
                                        Text(i.artistDetails.artistName)
                                            .font(.caption)
                                            .fontWeight(.regular)
                                            .foregroundColor(Color.white.opacity(0.5))
                                            .lineLimit(1)
                                    }
                                    Spacer()
                                    Image(systemName: "line.3.horizontal")
                                        .foregroundColor(Color.white.opacity(0.5))
                                }
                            }
                        }
                        .listRowBackground((i._id == currentSong._id) ? Color.accentColor.opacity(0.4) : Color.accentColor.opacity(0.1))
                        .listRowInsets(EdgeInsets())
                        .padding(10)
                        .padding(.horizontal)
                        .listRowSeparator(.hidden)
                    }
                    .onMove( perform: { IndexSet, Int in
                        songs.move(fromOffsets: IndexSet, toOffset: Int)
                        onMove = true
                    })
                Text("Hold and drag to rearrange")
                    .font(.caption)
                    .foregroundColor(Color.white.opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color.accentColor.opacity(0))
                    .listRowSeparator(.hidden)
            }
            .listRowInsets(EdgeInsets())
            .listStyle(PlainListStyle())
        }
        .environment(\.colorScheme, .dark)
    }
}
