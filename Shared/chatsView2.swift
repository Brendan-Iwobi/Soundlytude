//
//  chatsView2.swift
//  Soundlytude (iOS)
//
//  Created by DJ bon26 on 8/4/23.
//

import SwiftUI
import UniformTypeIdentifiers
import Introspect

private struct CutoutFramePreferenceKey: PreferenceKey {
    typealias Value = [String: CGRect]

    static var defaultValue: [String: CGRect] = [:]

    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

var replyId: String = ""
public struct HighlightOverlay<MaskView: View>: ViewModifier {
    @Binding var highlightedView: String?
    @Binding var selectedReaction: String
    @Binding var selectedReactionGrow: Double
    @Binding var showChatMenu: Bool
    @Binding var highlightedChatsOffset: Double
    @State var visible: Bool = false
    @Binding var menuView: AnyView
    var maskView: MaskView
    var maskPadding: CGFloat = -10
    var maskBlur: CGFloat = 0
    let reactions: Array<String> = ["👍","👎","❤️","😂","😭","😐","😢","😱","🤔","😮","❓","⁉️"]
    
    @State private var overlayFrame: CGRect = .zero
    @State private var maskFrames = [String: CGRect]()
    
    public func body(content: Content) -> some View {
        ZStack {
            content
                .onPreferenceChange(CutoutFramePreferenceKey.self) { value in
                    maskFrames = value
                }
                .onChange(of: maskFrames) { _ in
                    withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.95)){
                        overlayFrame = highlightedView.flatMap { maskFrames[$0] } ?? .zero
                    }
                }
                .onChange(of: highlightedView) { _ in
                    if highlightedView != nil{
                        withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.95)){
                            overlayFrame = highlightedView.flatMap { maskFrames[$0] } ?? .zero
                        }
                    }else{
                        overlayFrame = highlightedView.flatMap { maskFrames[$0] } ?? .zero
                    }
                }
            ZStack {
                BlurView()
                    .opacity(highlightedView != nil ? 1 : 0)
                    .ignoresSafeArea()
                    .onTapGesture {
                        replyId = ""
                        highlightedView = nil
                        showChatMenu = false
                        withAnimation(.spring()){
                            highlightedChatsOffset = 0
                        }
                    }
                    .animation(.easeIn(duration: 0.25).delay(0.1), value: highlightedView)
                if overlayFrame != .zero {
                    maskView
                        .frame(width: overlayFrame.size.width,
                               height: overlayFrame.size.height)
                        .position(x: overlayFrame.midX, y: overlayFrame.midY)
                        .blendMode(.destinationOut)
                        .animation(.easeOut(duration: 0.2), value: overlayFrame)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack{
                            ForEach(reactions, id: \.self){i in
                                let index = reactions.firstIndex(of: i)
                                Button {
                                    if selectedReaction == i{
                                        selectedReaction = ""
                                    }else{
                                        selectedReaction = i
                                    }
                                    withAnimation(.spring()){
                                        highlightedChatsOffset = 0
                                    }
                                } label: {
                                    Text(i)
                                        .font(.system(size: 20))
                                        .scaleEffect(selectedReaction == i ? selectedReactionGrow : 1)
                                        .animation(.interpolatingSpring(stiffness: 170, damping: 10), value: selectedReactionGrow)
                                }
                                .offset(x: showChatMenu ? 0 : -10)
                                .scaleEffect(showChatMenu ? 1 : 0, anchor: .bottomLeading)
                                .rotationEffect(.degrees(showChatMenu ? 0 : -45))
                                .frame(width: 35, height: 35)
                                .background(selectedReaction == i ? Color("BlackWhite").opacity(0.2) : .clear)
                                .cornerRadius(35)
                                .padding(.vertical, 5)
                                .animation(.interpolatingSpring(stiffness: 170, damping: 14).delay((Double(index ?? 0) - 0.1) / 15), value: showChatMenu)
                            }
                        }
                        .padding(.horizontal, 5)
                    }
                    .animation(.interpolatingSpring(stiffness: 170, damping: 10), value: showChatMenu)
                    .background(.ultraThinMaterial)
                    .cornerRadius(50)
                    .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y:5)
                    .scaleEffect(showChatMenu ? 1 : 0)
                    .position(x: (viewableWidth / 2) - 10, y: (overlayFrame.minY < 100 ? 100 : overlayFrame.minY))
                    .offset(y: -75)
                    .padding(.horizontal, 10)
                    .onAppear{
                        if overlayFrame.minY < 110 {
                            withAnimation(.easeIn(duration: 0.2)){
                                highlightedChatsOffset = 110 - overlayFrame.minY
                            }
                        }
                        if overlayFrame.maxY > viewableHeight - 40 {
                            withAnimation(.easeIn(duration: 0.2)){
                                highlightedChatsOffset = ((viewableHeight - 70) - overlayFrame.maxY)
                            }
                        }
                    }
                    VStack(spacing: 0){
                        Spacer()
                        VStack(spacing: 0){
                            Divider()
                            menuView
                                .padding(.top, 5)
                        }
                        .padding(.bottom, 15)
                        .background(BlurView().ignoresSafeArea())
                        .frame(height: 60)
                    }
                }
            }
            .coordinateSpace(name: "HighlightOverlayCoordinateSpace")
            .compositingGroup()
            .opacity(overlayFrame != .zero ? 1 : 0)
        }
        .animation(.easeIn, value: highlightedView)
        .animation(.interpolatingSpring(stiffness: 170, damping: 10), value: showChatMenu)
        .animation(.interpolatingSpring(stiffness: 170, damping: 10), value: visible)
    }
}

struct menuButtonView2: View {
    var label: String
    var image: String
    var color: Color
    
    var body: some View {
        HStack{
            VStack(spacing: 2.5){
                Image(systemName: image)
                    .font(.footnote)
                    .padding(15)
                    .overlay(
                        Circle()
                            .fill(color.opacity(0.05))
                            .frame(maxWidth: .infinity)
                    )
                Text(label)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
        }
        .foregroundColor(color)
        .frame(maxWidth: .infinity)
//        .background(Color("BlackWhite").opacity(0.1))
    }
}

public struct HighlightedItem: ViewModifier {
    var id: String
    
    public func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geo in
                    Color.clear
                        .preference(key: CutoutFramePreferenceKey.self,
                                    value: [id: geo.frame(in: .named("HighlightOverlayCoordinateSpace"))])
                }
            )
    }
}

public extension View {
    func tooltipItem(_ id: String) -> some View {
        modifier(HighlightedItem(id: id))
    }
    
    func withHighlightOverlay(highlighting highlightedView: Binding<String?>,
                              selectedReaction: Binding<String>,
                              selectedReactionGrow: Binding<Double>,
                              showChatMenu: Binding<Bool>,
                              highlightedChatsOffset: Binding<Double>,
                              menuView: Binding<AnyView>,
                              maskView: some View,
                              maskPadding: CGFloat = 24,
                              maskBlur: CGFloat = 4) -> some View {
        modifier(HighlightOverlay(highlightedView: highlightedView,
                                  selectedReaction: selectedReaction,
                                  selectedReactionGrow: selectedReactionGrow,
                                  showChatMenu: showChatMenu,
                                  highlightedChatsOffset: highlightedChatsOffset,
                                  menuView: menuView,
                                  maskView: maskView,
                                  maskPadding: maskPadding,
                                  maskBlur: maskBlur))
    }
}

struct chatView2: View {
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var globalVariables: globalVariables
    
    @ObservedObject var keyboardHeightHelper = KeyboardHeightHelper()
    
    @StateObject var MessengerData = messengerPageFetchMessengerData()
    @State var LocalMessengerData: [localMessengerPageFetchMessagesField] = []
    
    @FocusState var sendAChatInputFocused: Bool
    @State var wasSendAChatInputFocused: Bool = false
    
    @State var gapBeforeMessages = 0.0
    @State var chatId: String = ""
    @State var artistId: String = "0fd70b92-e4cf-4e21-b522-4ec5a22b35f1"
    @State var artistPfp: String = ""
    @State var artistName: String = "-"
    @State var artistVerification: Bool = true
    
    @State var isDoneLoading: Bool = false
    @State var loadNewIsDoneLoading: Bool = true
    @State var disableLoadNew: Bool = false
    @State var textMessage: String = ""
    @State var disableAllInputs: Bool = false
    @State var showImagePicker:Bool = false
    @State var showMoreInputOptions:Bool = false
    @State var selectedImage: Image? = Image("")
    @State var selected : [UIImage] = []
    @State var displayImages: Array<Array<UIImage>> = []
    @State var textEditorHeight : CGFloat = 20
    @State var showMusicSheet: Bool = false
    @State var x = 0
    @State var y = 0
    
    
    @State var fullScreenImage: Bool = false
    @State var fullScreenImageUrl: String = ""
    @State var scrollingTop: Bool = false
    @State private var offset = CGSize.zero
    @State var timeOffset = 0.0
    @State var chatOnly = false
    @State var spaceChatBottom = 0.0
    @State var highlightedChatsOffset = 0.0
    @State var bottomLocation = 0.0
    
    @State private var scrollViewContentOffset = CGFloat(0)
    
    @State private var presentAlert = false
    @State private var presentAlertTitle = ""
    @State private var presentAlertMessage = ""
    
    @State var presentPopover = false
    @GestureState var press = false
    @State var show = false
    @State var scrollDetector = 0
    @State var scrollToId = ""
    
    
    @State var chatDetails: [messagesPageFetchChatsField] = []
    @State var readReceipt = try! AttributedString(markdown: "Read")
    
    var formatedTextMessage: String {
        return textMessage.replacingOccurrences(of: " ", with: "")
    }
    
    var sendTextIsValid: Bool {
        if ((formatedTextMessage == "" && selected.count > 0) || (formatedTextMessage != "" && selected.count > 0) || (formatedTextMessage != "" && selected.count < 1)) && !disableAllInputs{
            return true
        }else {
            return false
        }
    }
    
    var type: String {
        if selected.count > 0{
            return "Image"
        }else {
            return "Text"
        }
    }
    
    @State private var highlightedView: String? = nil
    @State private var maskedView: AnyView = AnyView(EmptyView())
    
    //"owner" replaces the type of curvature
    var body: some View {
        
        NavigationView{
            ScrollViewReader { proxy in
                ZStack{
                    if isDoneLoading {
                        VStack{//heading
                            if !chatOnly && !showChatMenu {
                                VStack(spacing: 0){
                                    HStack(spacing: 20){
                                        Image(systemName: "chevron.left")
                                            .font(.system(size: 23))
                                            .font(Font.headline.weight(.black))
                                            .padding([.top, .leading, .bottom])
                                            .shadow(color: Color.accentColor, radius: 0.1)
                                            .foregroundColor(Color.accentColor)
                                            .onTapGesture {
                                                self.presentationMode.wrappedValue.dismiss()
                                            }
                                        NavigationLink(destination: navProfilePage(artistId: artistId)) {
                                            circleImage40by40(urlString: artistPfp)
                                            (Text("\(artistName)") + Text((artistVerification) ? " \(Image(systemName: "checkmark.seal.fill"))" : ""))
                                                .font(.headline)
                                                .fontWeight(.bold)
                                                .lineLimit(1)
                                        }
                                        Spacer()
                                        
                                    }
                                    Divider().padding(0)
                                }
                                .transition(AnyTransition.move(edge: .top))
                                .frame(maxWidth: .infinity)
                                .background((colorScheme == .dark) ? .thinMaterial : .regular)
                                Spacer()
                            }
                        }
                        .animation(.easeInOut(duration: 0.25), value: showChatMenu)
                        .zIndex(1)
                        VStack{//CHAT
                            ZStack {
                                ScrollView(.vertical, showsIndicators: false){
                                    ZStack (alignment: .trailing){
                                        ScrollViewOffsetReader(onScrollingStarted: {
                                            offset = .zero
                                            timeOffset = 0
                                        }, onScrollingFinished: {
                                        })
                                        .background(Color.gray.opacity(0.0001))
                                        .frame(width: viewableWidth - 80)
                                        .gesture(
                                            DragGesture()
                                                .onChanged { gesture in
                                                    offset = gesture.translation
                                                    if offset.width > 0{
                                                        timeOffset = 0
                                                    }else{
                                                        if abs(offset.width) > abs(210){
                                                            timeOffset = -70
                                                        }else{
                                                            timeOffset = (offset.width / 3)
                                                        }
                                                    }
                                                }
                                                .onEnded { gesture in
                                                    timeOffset = 0
                                                    offset = .zero
                                                }
                                        )
                                        VStack{
                                            Spacer()
                                                .frame(height: gapBeforeMessages)
                                            Button{//LEAD PREVIOUS CHAT1
                                                MessengerData.fetchUpdate(chatId: chatId)
                                                loadNewProgresser()
                                                scrollingTop = true
                                            }label: {
                                                HStack(spacing: 10){
                                                    Text("Load previous chat")
                                                        .foregroundColor(Color.accentColor)
                                                    if loadNewIsDoneLoading {
                                                        Image(systemName: "chevron.down")
                                                            .foregroundColor(Color.accentColor)
                                                    }else{
                                                        ProgressView()
                                                            .padding(.horizontal, 20)
                                                            .frame(width: 2.5, height: 2.5)
                                                    }
                                                }.font(.footnote)
                                            }
                                            .id("loadPreviousChat")
                                            .padding(.top, 50)
                                            .frame(maxWidth: .infinity)
                                            .listRowSeparator(.hidden)
                                            .disabled(disableLoadNew)
                                            ForEach(0..<MessengerData.messengerPageFetchMessagesFields.count, id: \.self){i in
                                                let x = MessengerData.messengerPageFetchMessagesFields[i]
                                                VStack(){
                                                    if x.headingMsg ?? "" != ""{
                                                        let headingMsg = try! AttributedString(markdown: formatToDate(time: x.headingMsg ?? ""))
                                                        Text(headingMsg)
                                                            .multilineTextAlignment(.center)
                                                            .lineLimit(1)
                                                            .frame(maxWidth: .infinity)
                                                            .font(.caption2)
                                                            .foregroundColor(.gray)
                                                            .padding(.top)
                                                    }
                                                    HStack{
                                                        if x.type == "Deleted" {
                                                            let deletedMsg = try! AttributedString(markdown: "**\(x.sender.artistName)** deleted a chat")
                                                            Text(deletedMsg)
                                                                .multilineTextAlignment(.center)
                                                                .lineLimit(1)
                                                                .frame(maxWidth: .infinity)
                                                                .font(.caption2)
                                                                .foregroundColor(.gray)
                                                                .padding(.top)
                                                        }else{
                                                            chatsView(x: x)
                                                                .gesture(
                                                                    DragGesture()
                                                                        .onChanged { gesture in
                                                                            offset = gesture.translation
                                                                            if offset.width > 0{
                                                                                timeOffset = 0
                                                                            }else{
                                                                                if abs(offset.width) > abs(210){
                                                                                    timeOffset = -70
                                                                                }else{
                                                                                    timeOffset = (offset.width / 3)
                                                                                }
                                                                            }
                                                                        }
                                                                        .onEnded { gesture in
                                                                            timeOffset = 0
                                                                            offset = .zero
                                                                        }
                                                                )
                                                        }
                                                        if x.type != "Deleted" {
                                                            VStack{
//                                                                if x._owner == "last" && x.type != "Deleted"{ //last sent text and its not deleted
//                                                                    Text(x.viewedByReciever == "Yes" ? "Read" : "Delivered")
//                                                                        .multilineTextAlignment(.leading)
//                                                                        .lineLimit(1)
//                                                                        .foregroundColor(.gray)
//                                                                }
                                                                Text(formatAMPM(time: x.time12hr))
                                                                    .multilineTextAlignment(.leading)
                                                                    .lineLimit(1)
                                                                    .foregroundColor(.gray)
                                                            }
                                                            .frame(maxWidth: 60)
                                                            .font(.caption2)
                                                            .offset(x: 60)
                                                            .offset(x: timeOffset)
                                                        }
                                                    }
                                                    .padding(.vertical, ((x.photo?.count ?? 0) > 1 ? (Double(x.photo?.count ?? 0) * 3) : 0))
                                                    .animation(.easeInOut, value: timeOffset)
                                                    //                                                    .scaleEffect(highlightedView == x._id ? 1.1 : 1)
                                                    
                                                    ///Read receipt
                                                    let filteredReadBy = chatDetails[0].readBy.filter { word in
                                                        return word._id == artistId
                                                    }
                                                    if x._owner == "last" && x.sender._id == soundlytudeUserId() && "\(i)" == "\(MessengerData.messengerPageFetchMessagesFields.count - 1)" {
                                                        HStack{
                                                            Spacer()
                                                            Text(filteredReadBy.count > 0 ? readReceipt : "Delivered")
                                                                .font(.caption2)
                                                                .padding(.trailing)
                                                                .foregroundColor(.gray)
                                                                .onAppear{
                                                                    if filteredReadBy.count > 0 {
                                                                        readReceipt = try! AttributedString(markdown: "**Read** \(formatAMPM(time: filteredReadBy[0].time))")
                                                                    }
                                                                }
                                                        }
                                                    }
                                                }
                                                .padding(.bottom, (x._owner == "last") ? 10 : 0)
                                                .padding(.vertical, -3.5)
                                                .padding(.top, ((x.replyType ?? "") != "") ? 10 : 0)
                                                .id(x._id)
                                                .listRowSeparator(.hidden)
                                                .listRowInsets(EdgeInsets())
                                                .zIndex(x._id == highlightedView ? 100 : 0)
                                            }
                                            ForEach(0..<LocalMessengerData.count, id: \.self){i in
                                                let x = LocalMessengerData[i]
                                                VStack(alignment: .trailing, spacing: 0){
                                                    if x.headingMsg ?? "" != "" && x._id == LocalMessengerData[0]._id{
                                                        let headingMsg = try! AttributedString(markdown: formatAMPM(time: x.headingMsg ?? ""))
                                                        Text(headingMsg)
                                                            .multilineTextAlignment(.center)
                                                            .lineLimit(1)
                                                            .frame(maxWidth: .infinity)
                                                            .font(.caption2)
                                                            .foregroundColor(.gray)
                                                            .padding(.top)
                                                    }
                                                    HStack{
                                                        localChatsView(x: x)
                                                            .gesture(
                                                                DragGesture()
                                                                    .onChanged { gesture in
                                                                        offset = gesture.translation
                                                                        if offset.width > 0{
                                                                            timeOffset = 0
                                                                        }else{
                                                                            if abs(offset.width) > abs(210){
                                                                                timeOffset = -70
                                                                            }else{
                                                                                timeOffset = (offset.width / 3)
                                                                            }
                                                                        }
                                                                    }
                                                                    .onEnded { gesture in
                                                                        timeOffset = 0
                                                                        offset = .zero
                                                                    }
                                                            )
                                                        VStack{
                                                            Text(formatAMPM(time: x.time12hr))
                                                                .multilineTextAlignment(.leading)
                                                                .lineLimit(1)
                                                                .foregroundColor(.gray)
                                                        }
                                                        .frame(maxWidth: 60)
                                                        .font(.caption2)
                                                        .offset(x: 60)
                                                        .offset(x: timeOffset)
                                                    }
                                                    .animation(.easeInOut, value: timeOffset)
                                                    (x._id == LocalMessengerData[LocalMessengerData.count - 1]._id) ?
                                                    Text("Sending...")
                                                    //                                                        .multilineTextAlignment(.trailing)
                                                        .padding(.horizontal)
                                                        .font(.caption2)
                                                        .foregroundColor(.gray)
                                                    : nil
                                                }
                                                .padding(.bottom, (x._id == LocalMessengerData[LocalMessengerData.count - 1]._id) ? 10 : 0)
                                                .padding(.vertical, -3.5)
                                                .opacity(0.75)
                                                .id(x._id)
                                                .listRowSeparator(.hidden)
                                                .listRowInsets(EdgeInsets())
                                            }
                                            
                                            Spacer().frame(height: (chatOnly) ? 0 : spaceChatBottom)
                                                .animation(.spring(), value: spaceChatBottom)
//                                            Spacer().frame(height: 50)
                                            Text("")
                                                .id("bottom")
                                                .overlay(
                                                    GeometryReader { geo in
                                                        let frame = geo.frame(in: CoordinateSpace.global)
                                                        Text("")
                                                            .onAppear{
                                                                bottomLocation = frame.maxY
                                                            }
                                                            .onChange(of: frame) { newSize in
                                                                bottomLocation = frame.maxY
                                                            }
                                                    }
                                                )
                                        }
                                    }
                                }
                                .onAppear{
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                        withAnimation(Animation.easeInOut) {
                                            proxy.scrollTo("bottom", anchor: .bottom)
                                            print("scroll")
                                        }
                                    }
                                }
                                .listStyle(PlainListStyle())
                                .padding(.vertical, (chatOnly) ? 0 : 10)
                                .withHighlightOverlay(
                                    highlighting: $highlightedView.onChange(highlightedViewChange),
                                    selectedReaction: $selectedReaction.onChange(selectedAReaction),
                                    selectedReactionGrow: $selectedReactionGrow,
                                    showChatMenu: $showChatMenu,
                                    highlightedChatsOffset: $highlightedChatsOffset,
                                    menuView: $menuView,
                                    maskView: maskedView
                                )
                            }
                        }
                        //                        .offset(y: (sendAChatInputFocused && showChatMenu) ? -keyboardHeightHelper.keyboardHeight : 0)
                        .onAppear{//POOOOOOO
                            Task {
                                do {
                                    await refreshLiveMessanger()
                                }catch{
                                    print("")
                                }
                            }
                        }
                        .alert(presentAlertTitle, isPresented: $presentAlert, actions: {
                            Button("OK", role: .cancel, action: {})
                        }, message: {
                            Text(presentAlertMessage)
                        })
                    }else{
                        VStack{
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color.accentColor))
                                .onAppear{
                                    messangerPageFetchingCompleted = false
                                    progresser()
                                    MessengerData.fetchUpdate(chatId: chatId)
                                }
                        }
                    }
                    VStack{//chatInput
                        if (!chatOnly && !showChatMenu) || (sendAChatInputFocused && showChatMenu) {
                            Spacer()
                            VStack(alignment: .trailing, spacing: 0){
                                Divider().padding(0)
                                if showReplyView {
                                    replyView
                                        .padding([.bottom, .horizontal])
                                }
                                if selected != []{
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 10){
                                            ForEach(self.selected,id: \.self){i in
                                                ZStack(alignment: .topTrailing){
                                                    Image(uiImage: i)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .cornerRadius(10)
                                                        .frame(maxHeight: 192)
                                                        .frame(minWidth: 10, minHeight:10)
                                                    
                                                    Button(role: .destructive) {
                                                        if selected.count > 0 {
                                                            selected.remove(at: selected.firstIndex(of: i)!)
                                                        }
                                                    } label: {
                                                        Image(systemName: "xmark.circle")
                                                            .foregroundColor(.white)
                                                            .background(Circle().fill(Color.gray).scaleEffect(1.15))
                                                    }
                                                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y:0)
                                                    .padding(.all, 5)
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                    }
                                    .padding(.top)
                                }
                                HStack(alignment: .bottom) {// inpput plus button
                                    Button {
                                        withAnimation {
                                            self.showMoreInputOptions.toggle()
                                        }
                                    } label: {
                                        if !showMoreInputOptions {
                                            IconButton(icon: "plus", size: 30)
                                        }else{
                                            IconButton(icon: "xmark", size: 30)
                                        }
                                    }
                                    .padding(.bottom, 2.5)
                                    if showMoreInputOptions {
                                        Capsule()
                                            .foregroundColor(Color.secondarySystemFill)
                                            .frame(maxWidth: 2, maxHeight: 30)
                                            .cornerRadius(5)
                                            .padding(.bottom, 2.5)
                                    }
                                    if showMoreInputOptions{
                                        ScrollView(.horizontal){
                                            HStack{
                                                Button {
                                                    stopRefreshing = true
                                                    self.showImagePicker.toggle()
                                                } label: {
                                                    IconButton(icon: "photo.on.rectangle.angled", size: 30)
                                                }
                                                .sheet(isPresented: $showImagePicker.onChange(showImagePickerFunction)) {
                                                    MultipleImagePicker(images: $selected, show: $showImagePicker)
                                                        .ignoresSafeArea()
                                                }
                                                Button {
                                                    showMusicSheet.toggle()
                                                } label: {
                                                    IconButton(icon: "music.note", size: 30)
                                                }
                                                .sheet(isPresented: $showMusicSheet) {
                                                    Text("Music")
                                                }
                                            }
                                        }
                                        .padding(.bottom, 2.5)
                                    }
                                    HStack(alignment: .bottom){
                                        ZStack(alignment: .leading) {
                                            Text(textMessage + "​")//there's a character here
                                                .font(.body)
                                                .foregroundColor(.clear)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 7.5)
                                                .background(GeometryReader {
                                                    Color.clear.preference(key: ViewHeightKey.self,
                                                                           value: $0.frame(in: .local).size.height)
                                                })
                                                .lineLimit(showMoreInputOptions ? 0 : 5)
                                            ZStack(alignment: .leading){
                                                if #available(iOS 16.0, *) {
                                                    TextEditor(text:$textMessage)
                                                        .font(.body)
                                                        .frame(maxHeight: max(20, textEditorHeight))
//                                                        .customTextField(color: .accentColor, padding: 5, lineWidth: 1)
                                                        .focused($sendAChatInputFocused)
                                                        .scrollContentBackground(Visibility.hidden)    // new technique for iOS 16
                                                        .introspectTextView { textView in
                                                            textView.showsVerticalScrollIndicator = false
                                                        }
                                                } else {
                                                    // Fallback on earlier versions
                                                    TextEditor(text:$textMessage)
                                                        .font(.body)
                                                        .frame(maxHeight: max(20, textEditorHeight))
//                                                        .customTextField(color: .accentColor, padding: 5, lineWidth: 1)
                                                        .focused($sendAChatInputFocused)
                                                        .introspectTextView { textView in
                                                            textView.showsVerticalScrollIndicator = false
                                                        }
                                                }
                                                Text((sendTextIsValid || showMoreInputOptions) ? "" : (showReplyView) ? " Reply" : " Send a chat") //bla1
                                                    .font(.body)
                                                    .opacity(0.25)
                                                    .offset(y: -0.2)
                                                    .onTapGesture {
                                                        withAnimation(.easeInOut(duration: 0.25)) {
                                                            sendAChatInputFocused = true
                                                        }
                                                    }
                                            }
                                            .onChange(of: sendAChatInputFocused) { newValue in
                                                if newValue {
                                                    if bottomLocation > viewableHeight && (bottomLocation - 200) < viewableHeight {
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                                            withAnimation(Animation.easeInOut) {
                                                                proxy.scrollTo("bottom", anchor: .bottom)
                                                                print("scroll")
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            .onChange(of: scrollDetector) { newValue in
                                                if bottomLocation > viewableHeight && (bottomLocation - 200) < viewableHeight {
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                                        withAnimation(Animation.easeInOut) {
                                                            proxy.scrollTo("bottom", anchor: .bottom)
                                                            print("scroll")
                                                        }
                                                    }
                                                }
                                            }
                                            .onReceive(MessengerData.$scroll, perform: { newValue in
                                                if scrollToBottom {
                                                    withAnimation(Animation.easeInOut) {
                                                        proxy.scrollTo("bottom", anchor: .bottom)
                                                        print("scroll")
                                                    }
                                                    scrollToBottom = false
                                                }
                                            })
                                            .onChange(of: scrollToId, perform: { newValue in
                                                withAnimation(Animation.easeInOut) {
                                                    selectedHighlight = scrollToId
                                                    withAnimation(.spring()){
                                                        selectedHighlightChatViewGrow = 1.1
                                                    }
                                                    proxy.scrollTo(scrollToId, anchor: .center)
                                                    print("scroll")
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                        withAnimation(.spring()){
                                                            selectedHighlightChatViewGrow = 1
                                                        }
                                                        selectedHighlight = ""
                                                        scrollToId = ""
                                                    }
                                                }
                                            })
                                        }
                                        .padding(.leading, 10)
                                        .onPreferenceChange(ViewHeightKey.self) {
                                                textEditorHeight = $0
                                        }
                                        Button {
                                            disableAllInputs = true
                                            var imageStrs: [String] = []
                                            let messageId = UUID().uuidString
                                            displayImages.append(selected)
                                            LocalMessengerData.append(localMessengerPageFetchMessagesField(_id: messageId, type: type, text: "\(textMessage)", viewedByReciever: "False", audio: "", video: "", photo: "", _createdDate: "Just now", _owner: "last", time12hr: "\(Date().millisecondsSince1970)", headingMsg: "\(Date().millisecondsSince1970)"))
                                            for uiImage in selected {
                                                let imageData: Data = uiImage.jpegData(compressionQuality: 0.1) ?? Data()
                                                let imageStr: String = imageData.base64EncodedString()
                                                imageStrs.append(imageStr)
                                            }
                                            if type == "Image" {
                                                uploadImages(imageURIs: imageStrs, localMsgId: messageId)
                                            }else{
                                                sendMessage(type: type, receiver: artistId, text: textMessage, imageURIs: imageStrs, chatId: chatId, localMsgId: messageId)
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                                withAnimation(Animation.easeInOut) {
                                                    proxy.scrollTo("bottom", anchor: .bottom)
                                                    print("scroll")
                                                }
                                            }
                                        } label: {
                                            if sendTextIsValid {
                                                IconButton(icon: "arrow.up", size: 30, background: Color.accentColor, foregroundColor: Color.white)
                                            }else{
                                                IconButton(icon: "arrow.up", size: 30, background: Color.gray.opacity(0.25))
                                            }
                                        }
                                        .padding(.trailing, 5)
                                        .padding(.bottom, 2.6)
                                        .scaleEffect((sendTextIsValid) ? 1 : 0.9)
                                        .disabled((sendTextIsValid) ? false : true)
                                        .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.95, blendDuration: 0.5), value: textMessage)
                                    }
                                    .overlay( /// apply a rounded border
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(.blue, lineWidth: 1.6)
                                    )
                                    .cornerRadius(20)
                                    .if(showMoreInputOptions){ view in
                                        view.hidden()
                                    }
                                }
                                .if(showReplyView) { view in
                                    view.padding([.trailing, .bottom, .leading], 10)
                                }
                                .if(!showReplyView) { view in
                                    view.padding(10)
                                }
                            }
                            .transition(AnyTransition.move(edge: .bottom))
                            .background((colorScheme == .dark) ? .thinMaterial : .regular)
                            .animation(.spring(), value: selected)
                            .overlay(
                                GeometryReader { geo in
                                    Text("")
                                        .onAppear{
                                            spaceChatBottom = geo.size.height
                                            print("Height: ", geo.size.height)
                                        }
                                        .onChange(of: geo.size) { newSize in
                                            spaceChatBottom = geo.size.height
                                            scrollDetector = scrollDetector + 1
                                        }
                                }
                            )
                            Spacer().frame(height: 0)
                        }
                    }
                    .animation(.easeInOut(duration: 0.25), value: showChatMenu)
                    .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.95, blendDuration: 0.5), value: textEditorHeight)
                    .zIndex((sendAChatInputFocused) ? 0 : 1)
                    .onAppear{
                        withAnimation(.easeInOut(duration: 0.25)) {
                            //                            sendAChatInputFocused = true
                            showChatMenu = false
                            chatsViewGrow = 1
                        }
                    }
                }
                .onAppear{
                    if !chatOnly{
                        withAnimation(.easeIn(duration: 0.25)) {
                            globalVariables.hideTabBar = true
                        }
                    }
                    pauseFetchingMessages = false
                    pauseFetchingChats = true
                }
                .onDisappear{
                    withAnimation(.easeIn(duration: 0.25)) {
                        globalVariables.hideTabBar = false
                        pauseFetchingMessages = true
                        pauseFetchingChats = false
                    }
                }
                .transition(.move(edge: .leading))
            }
            //            }
            //            .offset(x: exitOffset)
        }
    }
    
    func highlightedViewChange(to value: String?) {
        if highlightedView == nil{
            chatsViewGrow = 1
        }
    }
    func selectedAReaction(to value: String) {
        print("SELECTED")
        updateMessage(type: "Reaction", messageId: selectedChat)
        selectedReactionGrow = 1.5
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            selectedReactionGrow = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            highlightedView = nil
            showChatMenu = false
            chatsViewGrow = 1
            updateLocalMessage(type: "Reaction", messageId: selectedChat)
        }
    }
    
    func showImagePickerFunction(to value: Bool) {
        print("IMAGE PICKER: ", showImagePicker)
        if showImagePicker{
            stopRefreshing = true
        }else{
            stopRefreshing = false
            Task {
                do {
                    await refreshLiveMessanger()
                }catch{
                    print("")
                }
            }
        }
    }
    
    @State var menuView: AnyView = AnyView(EmptyView())
    @State var replyType: String = ""
    @State var repliedArtistId: String = ""
    @State var repliedText: String = ""
    @State var repliedTextId: String = ""
    func setMenuView(x: messengerPageFetchMessagesField) {
        menuView = AnyView(HStack(spacing: 0){
            Spacer()
            Spacer()
            Button {
                let cancelButton = Button(role: .destructive) { //for reply
                    withAnimation(.spring()){
                        showReplyView = false
                        replyType = ""
                        repliedArtistId = ""
                        repliedText = ""
                        repliedTextId = ""
                    }
                } label: {
                    Image(systemName: "xmark.circle")
                        .font(.title3)
                        .foregroundColor(.white)
                        .background(Circle().fill(Color.gray).scaleEffect(1.15))
                }
                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y:0)
                .padding(.all, 5)
                replyId = x._id
                replyView = AnyView(
                    HStack(spacing: 2.5){
                        if x.sender._id == soundlytudeUserId() {
                            replyViewView(x: x)
//                                        .offset(x: 40)
                                .padding(.top, ((x.photo?.count ?? 0) > 1 ? (Double(x.photo?.count ?? 0) * 3) : 7.5))
                                .allowsHitTesting(false)
                            cancelButton
                        }else{
                            cancelButton
                            replyViewView(x: x)
//                                        .offset(x: -40)
                                .padding(.top, ((x.photo?.count ?? 0) > 1 ? (Double(x.photo?.count ?? 0) * 4) : 7.5))
                                .allowsHitTesting(false)
                        }
                    })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    withAnimation(.interactiveSpring(response: 1, dampingFraction: 0.75, blendDuration: 1.0)){
                        highlightedView = nil
                        showChatMenu = false
                        withAnimation(.spring()){
                            highlightedChatsOffset = 0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            sendAChatInputFocused = true
                            showReplyView = true
                            replyType = x.type
                            repliedArtistId = x.sender._id
                            repliedText = x.text ?? ""
                            repliedTextId = x._id
                            print(x.type, x.text ?? "")
                        }
                    }
                }
            } label: {
                menuButtonView2(label: "Reply", image: "arrowshape.turn.up.left", color: Color("BlackWhite"))
            }
            Spacer()
            Button {
                UIPasteboard.general.setValue(toCopy,
                    forPasteboardType: UTType.plainText.identifier)
                highlightedView = nil
                showChatMenu = false
                withAnimation(.spring()){
                    highlightedChatsOffset = 0
                }
            } label: {
                menuButtonView2(label: "Copy", image: "doc.on.doc", color: Color("BlackWhite"))
            }
            Spacer()
            if chatMenuOwner {
                Button {
                    updateMessage(type: "Delete", messageId: selectedChat)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        highlightedView = nil
                        showChatMenu = false
                        withAnimation(.spring()){
                            highlightedChatsOffset = 0
                        }
                        updateLocalMessage(type: "Delete", messageId: selectedChat)
                    }
                } label: {
                    menuButtonView2(label: "Delete", image: "trash", color: Color.red)
                }
            }else{
                Button {
                    //
                } label: {
                    menuButtonView2(label: "Report", image: "flag", color: Color.red)
                }
            }
            Spacer()
            Spacer()
        })
    }
    @State var longPressLocationY = 0.0
    @State var defaultLocationY = 0.0
    @State var chatsViewGrow: Double = 1
    @State var selectedHighlightChatViewGrow: Double = 1
    @State var selectedChat: String = ""
    @State var selectedHighlight: String = ""
    @State var toCopy: String = ""
    @State var screenHeight: Double = 0.0
    @ViewBuilder
    func chatsView(x: messengerPageFetchMessagesField) -> some View {
        var showBlack = false
//        let lowRes = false
        let chatBubble =
        ZStack(alignment: .trailing){
            if x.type == "Deleted"{
                ChatBubble(arrow: (x._owner == "last") ? true : false, bubble: (x.type != "Deleted") ? true : false, direction: x.sender._id == soundlytudeUserId() ? .right : .left) {
                }
            }
            if x.type == "Text" {
                ChatBubble(arrow: (x._owner == "last") ? true : false, bubble: (x.type != "Deleted") ? true : false, direction: x.sender._id == soundlytudeUserId() ? .right : .left) {
                    Text(x.text ?? "-")
//                    Text("I hope this **** works on my mama. And I'm not ven kidding. Cultivated who resolution connection motionless did occasional. Journey promise if it colonel. Can all mirth abode nor hills added. Them men does for body pure. Far end not horses remain sister. Mr parish is to he answer roused piqued afford sussex. It abode words began enjoy years no do ﻿no. Tried spoil as heart visit blush or. Boy possible blessing sensible set but margaret interest. Off tears are day blind smile alone had")
//                    .fixedSize(horizontal: false, vertical: true)
                    //                    .lineLimit(lineLimit ? 5 : nil)
                        .padding(.horizontal, 15)
                        .padding(.trailing, 2.5)
                        .padding(.vertical, 7)
                        .foregroundColor(x.sender._id == soundlytudeUserId() ? Color.white : Color("BlackWhite"))
                        .background((x.sender._id == soundlytudeUserId()) ? Color.accentColor : Color.secondarySystemFill)
                        .background((x.sender._id == soundlytudeUserId()) ? Color.black : Color.clear)
                        .overlay(Color.black.opacity(showBlack ? 1 : 0))
                }
                .offset(x: x.sender._id == soundlytudeUserId() ? timeOffset : 0, y: 0)
            }
            if x.type == "Image" {
                ForEach(0..<(x.photo?.count ?? 0), id:\.self){index in
                    let i: Int = ((x.photo?.count ?? 0) - 1) - index
                    let y = x.photo?[i]
                    ChatBubble(arrow: (x._owner == "last" && (x.photo?.count ?? 0) < 1), bubble: (x.type != "Deleted") ? true : false, direction: x.sender._id == soundlytudeUserId() ? .right : .left) {
                        squareImageChat(x: y ?? "", caption: (i == 0 ? (x.text ?? "") : ""), resolution: Int(512 - Double(i) * 15), OGSize: ((x.photo?.count ?? 0) < 1))
                            .blur(radius: CGFloat(0.25 * Double(i)))
                            .opacity(1 - (0.075 * Double(i)))
                    }
                    .offset(x: x.sender._id == soundlytudeUserId() ? timeOffset : 0, y: 0)
                    .shadow(color: Color.black.opacity(0.25), radius: 5, x: 0, y:0)
                    .offset(x: CGFloat( (x.sender._id == soundlytudeUserId() ? -(i * 10) : (i * 10))))
                    .rotationEffect(.degrees((x.sender._id == soundlytudeUserId() ? -(Double(i) * 3) : (Double(i) * 3))))
                    .rotationEffect(.degrees(x.sender._id == soundlytudeUserId() ? normalizeRange(x: -timeOffset, xMin: 0, xMax: 70, yMin: 0, yMax: (Double(i) * 3)) : normalizeRange(x: -timeOffset, xMin: 0, xMax: 70, yMin: 0, yMax: -(Double(i) * 3))))
                    .offset(x: x.sender._id == soundlytudeUserId() ? normalizeRange(x: timeOffset, xMin: 0, xMax: 75, yMin: 0, yMax: -(Double(i) * 10)) : normalizeRange(x: timeOffset, xMin: 0, xMax: 75, yMin: 0, yMax: (Double(i) * 10)))
                }
            }
        }
        .tooltipItem(x._id)
        .animation(.spring(), value: highlightedView)
        let reactions =
        Button {
            //
        } label: {
            HStack(spacing: 0){
                ForEach(0..<x.reactions.count, id: \.self){i in
                    Text(x.reactions[i].reaction)
                        .frame(width: 35, height: 35)
                        .background(x.reactions[i]._id == soundlytudeUserId() ? Color.red.opacity(0.5) : Color.clear)
                        .cornerRadius(35)
                }
            }
            .background(.ultraThinMaterial)
            .cornerRadius(25)
            .offset(y: 10)
        }
        VStack{
            if x.reactions.count > 0 {
                HStack{
                    if x.sender._id == soundlytudeUserId() {
                        Spacer()
                        reactions
                    }else{
                        reactions
                        Spacer()
                    }
                }
                .offset(y: (x._id == highlightedView) ? -5 : 0)
                .offset(x: x.sender._id == soundlytudeUserId() ? 75 : 0)
                .offset(x: x.sender._id == soundlytudeUserId() ? timeOffset : 0, y: 0)
                .padding(.horizontal, 30)
                .zIndex(1)
            }
            if (x.replyType ?? "") != "" {
                HStack {
                    if x.sender._id == soundlytudeUserId() {
                        Spacer()
                        Text(x.repliedText ?? "")
                            .lineLimit(10)
                            .padding(7.5)
                            .background(Color("BlackWhite").opacity(0.1))
                            .cornerRadius(20)
                        Capsule()
                            .frame(maxWidth: 2, maxHeight: .infinity)
                            .cornerRadius(5)
                    }
                    if x.sender._id != soundlytudeUserId() {
                        Capsule()
                            .frame(maxWidth: 2, maxHeight: .infinity)
                            .cornerRadius(5)
                        Text(x.repliedText ?? "")
                            .lineLimit(10)
                            .padding(7.5)
                            .background(Color("BlackWhite").opacity(0.1))
                            .cornerRadius(20)
                        Spacer()
                    }
                }
                .scaleEffect((x._id == selectedChat) ? chatsViewGrow : (x._id == selectedHighlight) ? selectedHighlightChatViewGrow : 1, anchor: x.sender._id == soundlytudeUserId() ? .trailing : .leading)
                .offset(y: (x._id == highlightedView) ? -5 : 0)
                .offset(x: x.sender._id == soundlytudeUserId() ? 55 : 20)
                .offset(x: x.sender._id == soundlytudeUserId() ? timeOffset : 0, y: 0)
                .foregroundColor(Color.gray)
                .onTapGesture {
                    scrollToId = ""
                    print("Go to \(x.repliedTextId)")
                    scrollToId = x.repliedTextId ?? ""
                }
                .onLongPressGesture(minimumDuration: 0.4, pressing: { (isPressing) in
                    selectedChat = x._id
                    toCopy = x.text ?? ""
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        if isPressing {
                            withAnimation(.spring()){
                                chatsViewGrow = 0.95
                            }
//                            longPressLocationY = frame.midY
                        }else{
                            withAnimation(.spring()){
                                chatsViewGrow = 1
                            }
                        }
                    }
                }, perform: {
                    wasSendAChatInputFocused = sendAChatInputFocused
                    sendAChatInputFocused = false
                    let filtered = x.reactions.filter { reaction in
                        return reaction._id == soundlytudeUserId()
                    }
                    let reactionIndex = (filtered.count < 1) ? -1 : x.reactions.firstIndex(of: filtered[0])!
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                        //                                        chatsViewGrow = 1.1
                        showBlack = true
        //                        lowRes = true
                        selectedReaction = (reactionIndex < 0) ? "" : x.reactions[reactionIndex].reaction
                        chatMenuChat = AnyView(chatBubble.offset(x: x.sender._id == soundlytudeUserId() ? 20 : -20))
                    }
                    chatMenuOwner = x.sender._id == soundlytudeUserId() ? true : false
                    setMenuView(x: x)
                    highlightedView = (highlightedView == nil ? x._id : nil)
                    maskedView = AnyView(chatBubble
                        .offset(y: x._id == highlightedView ? highlightedChatsOffset : 0)
                        .offset(x: x.sender._id == soundlytudeUserId() ? timeOffset : 0, y: 0)
                    )
                    showChatMenu = true
                    let tapticFeedback = UINotificationFeedbackGenerator()
                    tapticFeedback.notificationOccurred(.success)
                })
            }
            chatBubble
                .offset(y: x._id == highlightedView ? highlightedChatsOffset : 0)
                .scaleEffect((x._id == selectedChat) ? chatsViewGrow : (x._id == selectedHighlight) ? selectedHighlightChatViewGrow : 1, anchor: x.sender._id == soundlytudeUserId() ? .trailing : .leading)
                .animation(.easeOut, value: selectedChat)
                .opacity(1)
                .offset(x: x.sender._id == soundlytudeUserId() ? 75 : 0)
                .onTapGesture {  }
                .onLongPressGesture(minimumDuration: 0.4, pressing: { (isPressing) in
                    selectedChat = x._id
                    toCopy = x.text ?? ""
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        if isPressing {
                            withAnimation(.spring()){
                                chatsViewGrow = 0.95
                            }
//                            longPressLocationY = frame.midY
                        }else{
                            withAnimation(.spring()){
                                chatsViewGrow = 1
                            }
                        }
                    }
                }, perform: {
                    wasSendAChatInputFocused = sendAChatInputFocused
                    sendAChatInputFocused = false
                    let filtered = x.reactions.filter { reaction in
                        return reaction._id == soundlytudeUserId()
                    }
                    let reactionIndex = (filtered.count < 1) ? -1 : x.reactions.firstIndex(of: filtered[0])!
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                        //                                        chatsViewGrow = 1.1
                        showBlack = true
        //                        lowRes = true
                        selectedReaction = (reactionIndex < 0) ? "" : x.reactions[reactionIndex].reaction
                        chatMenuChat = AnyView(chatBubble.offset(x: x.sender._id == soundlytudeUserId() ? 20 : -20))
                    }
                    chatMenuOwner = x.sender._id == soundlytudeUserId() ? true : false
                    setMenuView(x: x)
                    highlightedView = (highlightedView == nil ? x._id : nil)
                    maskedView = AnyView(chatBubble
                        .offset(y: x._id == highlightedView ? highlightedChatsOffset : 0)
                        .offset(x: x.sender._id == soundlytudeUserId() ? timeOffset : 0, y: 0)
                    )
                    showChatMenu = true
                    let tapticFeedback = UINotificationFeedbackGenerator()
                    tapticFeedback.notificationOccurred(.success)
                })
        
//                .overlay(
//                    GeometryReader { geometry in
//                        let frame = geometry.frame(in: CoordinateSpace.global)
//                        Color.red.opacity(0.0001)
//                            .offset(x: x.sender._id == soundlytudeUserId() ? 75 : 0)
//                            .offset(x: x.sender._id == soundlytudeUserId() ? timeOffset : 0, y: 0)
//                            .onTapGesture {  }
//                            .onLongPressGesture(minimumDuration: 0.5, pressing: { (isPressing) in
//                                selectedChat = x._id
//                                toCopy = x.text ?? ""
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
//                                    if isPressing{
//                                        withAnimation(.spring()){
//                                            chatsViewGrow = 0.95
//                                        }
//                                        longPressLocationY = frame.midY
//                                    }else{
//                                        withAnimation(.spring()){
//                                            chatsViewGrow = 1
//                                        }
//                                    }
//                                }
//                            }, perform: {
//                                wasSendAChatInputFocused = sendAChatInputFocused
//                                sendAChatInputFocused = false
//                                let cancelButton = Button { //For Replyyy
//                                    withAnimation(.spring()){
//                                        showReplyView = false
//                                    }
//                                } label: {
//                                    Image(systemName: "xmark")
//                                        .padding(5)
//                                }
//                                    .foregroundColor(.white)
//                                    .background(.gray.opacity(0.5))
//                                    .cornerRadius(15)
//                                let filtered = x.reactions.filter { reaction in
//                                    return reaction._id == soundlytudeUserId()
//                                }
//                                let reactionIndex = (filtered.count < 1) ? -1 : x.reactions.firstIndex(of: filtered[0])!
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
//                                    //                                        chatsViewGrow = 1.1
//                                    showBlack = true
//                                    lowRes = true
//                                    selectedReaction = (reactionIndex < 0) ? "" : x.reactions[reactionIndex].reaction
//                                    chatMenuChat = AnyView(chatBubble.offset(x: x.sender._id == soundlytudeUserId() ? 20 : -20))
//                                    replyView = AnyView(
//                                        HStack{
//                                            if x.sender._id == soundlytudeUserId() {
//                                                chatBubble.offset(x: 20)
//                                                    .padding(.vertical)
//                                                cancelButton
//                                            }else{
//                                                cancelButton
//                                                chatBubble.offset(x: -20)
//                                                    .padding(.vertical)
//                                            }
//                                        })
//                                }
//                                chatMenuOwner = x.sender._id == soundlytudeUserId() ? true : false
//                                setMenuView()
//                                highlightedView = (highlightedView == nil ? x._id : nil)
//                                maskedView = AnyView(chatBubble
//                                    .offset(y: x._id == highlightedView ? highlightedChatsOffset : 0)
//                                    .offset(x: x.sender._id == soundlytudeUserId() ? timeOffset : 0, y: 0)
//                                )
//                                showChatMenu = true
//                                let tapticFeedback = UINotificationFeedbackGenerator()
//                                tapticFeedback.notificationOccurred(.success)
//                            })
//                    }
//                )
        }
        .fixedSize(horizontal: false, vertical: true)
    }
    
    @ViewBuilder
    func replyViewView(x: messengerPageFetchMessagesField) -> some View {
        ZStack(alignment: .trailing){
            if x.type == "Deleted"{
                ChatBubble(arrow: (x._owner == "last") ? true : false, bubble: (x.type != "Deleted") ? true : false, direction: x.sender._id == soundlytudeUserId() ? .right : .left) {
                }
            }
            if x.type == "Text" {
                ChatBubble(arrow: (x._owner == "last") ? true : false, bubble: (x.type != "Deleted") ? true : false, direction: x.sender._id == soundlytudeUserId() ? .right : .left) {
                    Text("\(x.text ?? "-")")
                        .lineLimit(10)
                        .padding(.horizontal, 15)
                        .padding(.trailing, 2.5)
                        .padding(.vertical, 7)
                        .foregroundColor(x.sender._id == soundlytudeUserId() ? Color.white : Color("BlackWhite"))
                        .background((x.sender._id == soundlytudeUserId()) ? Color.accentColor : Color.secondarySystemFill)
                        .background((x.sender._id == soundlytudeUserId()) ? Color.black : Color.clear)
                }
                .offset(x: x.sender._id == soundlytudeUserId() ? timeOffset : 0, y: 0)
            }
            if x.type == "Image" {
                ForEach(0..<(x.photo?.count ?? 0), id:\.self){index in
                    let i: Int = ((x.photo?.count ?? 0) - 1) - index
                    let y = x.photo?[i]
                    ChatBubble(arrow: (x._owner == "last" && (x.photo?.count ?? 0) < 1), bubble: (x.type != "Deleted") ? true : false, direction: x.sender._id == soundlytudeUserId() ? .right : .left) {
                        squareImageChat(x: y ?? "", caption: (i == 0 ? (x.text ?? "") : ""), resolution: 427 - (i * 10), OGSize: ((x.photo?.count ?? 0) < 1), maxWidth: 170, maxHeight: 256)
                            .blur(radius: CGFloat(0.25 *  Double(i)))
                            .opacity(1 - (0.075 * Double(i)))
                    }
                    .shadow(color: Color.black.opacity(0.25), radius: 5, x: 0, y:0)
                    .offset(x: CGFloat( (x.sender._id == soundlytudeUserId() ? -(i * 5) : (i * 5))))
                    .rotationEffect(.degrees((x.sender._id == soundlytudeUserId() ? -(Double(i) * 2) : (Double(i) * 2))))
                }
            }
        }
    }
    
    @ViewBuilder
    func localChatsView(x: localMessengerPageFetchMessagesField) -> some View {
        let lastItem: localMessengerPageFetchMessagesField = LocalMessengerData[LocalMessengerData.count - 1]
        let currentItemIndex = LocalMessengerData.firstIndex(of: x)!
        if x.type == "Text"{
            ChatBubble(arrow: (x._id == lastItem._id) ? true : false, bubble: (x.type != "Deleted") ? true : false, direction: .right) {
                Text(x.text ?? "-")
                    .padding(.horizontal, 15)
                    .padding(.trailing, 2.5)
                    .padding(.vertical, 7)
                    .foregroundColor(Color.white )
                    .background(Color.accentColor)
                    .background(Color.black)
            }
            .offset(x: 75)
            .offset(x: timeOffset, y: 0)
        }
        if x.type == "Image" {
            ZStack{
                ForEach(0..<displayImages[currentItemIndex].count, id: \.self){index in
                    let i = (displayImages[currentItemIndex].count - 1) - index
                    ChatBubble(arrow: (x._id == lastItem._id) ? true : false, bubble: (x.type != "Deleted") ? true : false, direction: .right) {
                        let displayImage = displayImages[currentItemIndex][i]
                        ZStack(alignment: .bottom){
                            //                    Image(base64String: "\(x.photo)")?
                            Image(uiImage: displayImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: 256, maxHeight: 384)
                            if displayImages[currentItemIndex].firstIndex(of: displayImage) == 0{
                                if (x.text ?? "") != "" {
                                    Text(x.text ?? "")
                                        .frame(width: 246)
                                        .padding(.all, 5)
                                        .foregroundColor(Color.white)
                                        .background(Color.black.opacity(0.5))
                                        .lineLimit(5)
                                }
                            }
                        }
                        .blur(radius: CGFloat(0.25 *  Double(i)))
                        .opacity(1 - (0.075 * Double(i)))
                    }
                    .offset(x: 75)
                    .offset(x: timeOffset, y: 0)
                    .shadow(color: Color.black.opacity(0.25), radius: 5, x: 0, y:0)
                    .offset(x: CGFloat(-(i * 10)))
                    .rotationEffect(.degrees(-(Double(i) * 3)))
                    .rotationEffect(.degrees(normalizeRange(x: -timeOffset, xMin: 0, xMax: 70, yMin: 0, yMax: (Double(i) * 3)) ))
                    .offset(x: normalizeRange(x: timeOffset, xMin: 0, xMax: 75, yMin: 0, yMax: -(Double(i) * 10)))
                }
            }
        }
    }
    
    @State var showChatMenu: Bool = false
    @State var chatMenuOwner: Bool = false
    @State var selectedReaction: String = ""
    @State var selectedReactionGrow: Double = 1
    @State var chatMenuChatOffsetY: Double = 0.0
    @State var unanimatedChatMenuChatOffsetY: Double = 0.0
    @State var chatMenuChat: AnyView = AnyView(EmptyView())
    @State var replyView: AnyView = AnyView(EmptyView())
    @State var showReplyView: Bool = false
    
    func closeMenu(){
        withAnimation(.interactiveSpring(response: 0.55, dampingFraction: 0.75, blendDuration: 1.0)){
            chatMenuChat = AnyView(EmptyView())
            chatsViewGrow = 1
            showChatMenu.toggle()
//                            chatMenuChatOffsetY = longPressLocationY - defaultLocationY
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                unanimatedChatMenuChatOffsetY = 0.0
            }
            sendAChatInputFocused = wasSendAChatInputFocused
        }
    }
    
    func progresser() {
        if(messangerPageFetchingCompleted){
            isDoneLoading = true
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                progresser()
                if (messangerPageFetchingCompleted == false){
                    isDoneLoading = false
                }
            }
        }
    }
    
    func loadNewProgresser() {
        if(messangerPageFetchingCompleted){
            loadNewIsDoneLoading = true
            scrollingTop = false
            if returnedEmpty {
                disableLoadNew = true
            }
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                loadNewProgresser()
                if (messangerPageFetchingCompleted == false){
                    loadNewIsDoneLoading = false
                }
            }
        }
    }
    func uploadImages(imageURIs: [String], localMsgId: String){
        for ImageURI in imageURIs {
            uploadImage(imageURI: ImageURI, totalImages: imageURIs.count, localMsgId: localMsgId)
        }
    }
    func sendMessage(type: String, receiver:String, text: String, imageURIs: [String], chatId: String, localMsgId: String) {
        pauseFetchingMessages = true
        textMessage = ""
        withAnimation(.spring()) {
            selected = []
        }
        let urlParam:String = "/_functions/textMessage?password=9cT8D9T2JUAvPxUeoGf3&localMsgId=\(localMsgId)"
        
        guard let url = URL(string: HttpBaseUrl() + urlParam) else {
            print("Error: cannot create URL")
            return
        }
        // Create model
        struct UploadData: Codable {
            let type: String
            let receiver: String
            let text: String
            let sender: String
            let chatId: String
            let photos: [String]
            let secPassword: String
            let repliedMessageId: String
            let replyType: String
            let repliedArtistId: String
            let repliedText: String
            let repliedTextId: String
        }
        
        // Add data to the model
        let uploadDataModel = UploadData(type: type, receiver: receiver, text: text, sender: soundlytudeUserId(), chatId: chatId, photos: imageURIs, secPassword: "9cT8D9T2JUAvPxUeoGf3", repliedMessageId: replyId, replyType: replyType, repliedArtistId: repliedArtistId, repliedText: repliedText, repliedTextId: repliedTextId)
        // Convert model to JSON data
        guard let jsonData = try? JSONEncoder().encode(uploadDataModel) else {
            print("Error: Trying to convert model to JSON data")
            return
        }
        // Create the url request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type") // the request is JSON
        request.setValue("application/json", forHTTPHeaderField: "Accept") // the response expected to be in JSON format
        request.httpBody = jsonData
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print("Error: error calling POST")
                print(error!)
                presentAlert = true
                presentAlertTitle = "WARNING"
                presentAlertMessage = "Error sending message, check your internet connection"
                removePlaceholderMessage(id: localMsgId)
                return
            }
            guard let data = data else {
                print("Error: Did not receive data")
                presentAlert = true
                presentAlertTitle = "WARNING"
                presentAlertMessage = "Error receiving authorization"
                removePlaceholderMessage(id: localMsgId)
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                print("Error: HTTP request failed", response)
                presentAlert = true
                presentAlertTitle = "WARNING"
                presentAlertMessage = "Failed to send that message"
                removePlaceholderMessage(id: localMsgId)
                return
            }
            do {
                MessengerData.fetchLiveUpdate(chatId: chatId, currentChats: MessengerData.messengerPageFetchMessagesFields, reason: "post")
                let dataReturned = try JSONDecoder().decode (SendMessageResponse.self, from: data)
                let chatToDelete = dataReturned.localMsgId
                disableAllInputs = false
                showReplyView = false
//                replyType = ""
//                repliedArtistId = ""
//                repliedText = ""
                DispatchQueue.main.async{
                    removePlaceholderMessage(id: chatToDelete)
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
                removePlaceholderMessage(id: localMsgId)
                return
            }
        }.resume()
    }
    @State var uploadedImagesUrl: [String] = []
    
    func uploadImage(imageURI: String, totalImages: Int, localMsgId: String) {
        pauseFetchingMessages = true
        let urlParam: String = "/_functions/upload?password=9cT8D9T2JUAvPxUeoGf3"
        guard let url = URL(string: HttpBaseUrl() + urlParam) else {
            print("Error: cannot create URL")
            return
        }
        
        struct UploadImageData: Codable {
            let dataURI: String
            let userId: String
            let artistName: String
        }
        // Create model
        struct UploadData: Codable {
            let uploadImageData: UploadImageData
            let secPassword: String
        }
        // Add data to the model
        let uploadDataModel = UploadData(uploadImageData: UploadImageData(dataURI: imageURI, userId: soundlytudeUserId(), artistName: local.string(forKey: "currentUserArtistName") ?? ""), secPassword: "vHiTpNq4934q4jecgU2a")
        // Convert model to JSON data
        guard let jsonData = try? JSONEncoder().encode(uploadDataModel) else {
            print("Error: Trying to convert model to JSON data")
            return
        }
        // Create the url request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type") // the request is JSON
        request.setValue("application/json", forHTTPHeaderField: "Accept") // the response expected to be in JSON format
        request.httpBody = jsonData
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print("Error: error calling POST")
                print(error!)
                presentAlert = true
                presentAlertTitle = "WARNING"
                presentAlertMessage = "Error sending message, check your internet connection"
                return
            }
            guard let data = data else {
                print("Error: Did not receive data")
                presentAlert = true
                presentAlertTitle = "WARNING"
                presentAlertMessage = "Error receiving authorization"
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                print("Error: HTTP request failed", response)
                presentAlert = true
                presentAlertTitle = "WARNING"
                presentAlertMessage = "Failed to send that message"
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
                    print("Error: Couldn't print JSON in String")
                    return
                }
                
                print(prettyPrintedJson)
                let dataReturned = try JSONDecoder().decode (UploadImageResponse.self, from: data)
                uploadedImagesUrl.append(dataReturned.url)
                if uploadedImagesUrl.count >= totalImages{
                    sendMessage(type: type, receiver: artistId, text: textMessage, imageURIs: uploadedImagesUrl, chatId: chatId, localMsgId: localMsgId)
                }
            } catch {
                print("Error: Trying to convert JSON data to string")
                return
            }
        }.resume()
    }
    
    func updateMessage(type: String, messageId: String) {
        pauseFetchingMessages = true
        guard let url = URL(string: HttpBaseUrl() + "/_functions/updateMessage?password=9cT8D9T2JUAvPxUeoGf3") else {
            print("Error: cannot create URL")
            return
        }
        
        // Create model
        struct UpdateData: Codable {
            let type: String
            let chatId: String
            let messageId: String
            let reaction: String
            let currentUserId: String
        }
        
        // Add data to the model
        let updateDataModel = UpdateData(type: type, chatId: chatId,  messageId: messageId, reaction: selectedReaction, currentUserId: soundlytudeUserId())
        
        // Convert model to JSON data
        guard let jsonData = try? JSONEncoder().encode(updateDataModel) else {
            print("Error: Trying to convert model to JSON data")
            return
        }
        
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print("Error: error calling POST")
                print(error!)
                presentAlert = true
                presentAlertTitle = "WARNING"
                presentAlertMessage = "Error updating message, check your internet connection"
                pauseFetchingMessages = false
                return
            }
            guard data != nil else {
                print("Error: Did not receive data")
                presentAlert = true
                presentAlertTitle = "WARNING"
                presentAlertMessage = "Error receiving authorization"
                pauseFetchingMessages = false
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                print("Error: HTTP request failed", response)
                presentAlert = true
                presentAlertTitle = "WARNING"
                presentAlertMessage = "Failed to update that message"
                pauseFetchingMessages = false
                return
            }
            do {
                MessengerData.fetchLiveUpdate(chatId: chatId, currentChats: MessengerData.messengerPageFetchMessagesFields)
            } catch {
                print("Error: Trying to convert JSON data to string")
                return
            }
        }.resume()
    }
    
    func updateChats() {
        guard let url = URL(string: HttpBaseUrl() + "/_functions/updateChat?password=5FVpahaZGEv7hsjcg93X&chatId=\(chatId)&currentUserId=\(soundlytudeUserId())") else {
            print("Error: cannot create URL")
            return
        }
            // Create the url request
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil else {
                    print("Error: error calling POST")
                    print(error!)
                    presentAlert = true
                    presentAlertTitle = "WARNING"
                    presentAlertMessage = "Error updating message, check your internet connection"
                    pauseFetchingMessages = false
                    return
                }
                guard var data = data else {
                    print("Error: Did not receive data")
                    presentAlert = true
                    presentAlertTitle = "WARNING"
                    presentAlertMessage = "Error receiving authorization"
                    pauseFetchingMessages = false
                    return
                }
                guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                    print("Error: HTTP request failed", response)
                    presentAlert = true
                    presentAlertTitle = "WARNING"
                    presentAlertMessage = "Failed to update chat"
                    pauseFetchingMessages = false
                    return
                }
                do
                {
                    let data = try JSONDecoder().decode ([messagesPageFetchChatsField].self, from: data)
                    DispatchQueue.main.async{
                        chatDetails = data
                        
                        let filteredReadBy = chatDetails[0].readBy.filter { word in
                            return word._id == artistId
                        }
                        if filteredReadBy.count > 0 {
                            readReceipt = try! AttributedString(markdown: "**Read** \(formatAMPM(time: filteredReadBy[0].time))")
                        }
                    }
                }
                catch {
                    print(error)
                }
            }.resume()
        }
    
    func updateLocalMessage(type: String, messageId: String) {
        let currentItemMessage = MessengerData.messengerPageFetchMessagesFields.filter { item in
            return item._id == messageId
        }
        if currentItemMessage.count > 0{
            let currentIndex = MessengerData.messengerPageFetchMessagesFields.firstIndex(of: currentItemMessage[0])!
            if type == "Delete"{
                MessengerData.messengerPageFetchMessagesFields[currentIndex].type = "Deleted"
            }
            if type == "Reaction" {
                var userReactionRemoved = MessengerData.messengerPageFetchMessagesFields[currentIndex].reactions.filter { item in
                    return item._id != soundlytudeUserId()
                }
                if selectedReaction != "" {
                    userReactionRemoved.append(reactionsField(_id: soundlytudeUserId(), reaction: selectedReaction))
                    withAnimation(.spring()){
                        MessengerData.messengerPageFetchMessagesFields[currentIndex].reactions = userReactionRemoved
                    }
                } else {
                    withAnimation(.spring()){
                        MessengerData.messengerPageFetchMessagesFields[currentIndex].reactions = userReactionRemoved
                    }
                }
            }
        }else{
            print("WHAT THE FUCK")
        }
    }
    
    func removePlaceholderMessage(id: String){
        let filtered = LocalMessengerData.filter { word in
            return word._id == id
        }
        let indexToRemove = LocalMessengerData.firstIndex(of: filtered[0])
        LocalMessengerData.remove(at: indexToRemove ?? 0)
        displayImages.remove(at: indexToRemove ?? 0)
    }
    
    func refreshLiveMessanger() async {
        if !stopRefreshing {
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            Task {
                do {
                    if !pauseFetchingMessages {
                        MessengerData.fetchLiveUpdate(chatId: chatId, currentChats: MessengerData.messengerPageFetchMessagesFields)
                        updateChats()
                    }
                    await refreshLiveMessanger()
                }catch{
                    await refreshLiveMessanger()
                }
            }
        }
    }
}
struct chatsView2_Previews: PreviewProvider {
    static var previews: some View {
        chatView2()
    }
}

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value + nextValue()
    }
}
