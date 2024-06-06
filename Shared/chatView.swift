//
//  messengerView.swift
//  Soundlytude (iOS)
//
//  Created by DJ bon26 on 11/5/22.
//

import SwiftUI
import SwiftUITrackableScrollView
import Combine
import AudioToolbox
import UIKit
import Foundation

 var messangerPageFetchingCompleted = false
 var returnedEmpty = false
var fullScreenImageUrl = ""
var pauseFetchingMessages = false
var stopRefreshing = false
var scrollToBottom = false

//struct chatView: View {
//    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
//    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
//    @Environment(\.colorScheme) var colorScheme
//    
//    @EnvironmentObject var globalVariables: globalVariables
//    
//    @ObservedObject var keyboardHeightHelper = KeyboardHeightHelper()
//    
//    @StateObject var MessengerData = messengerPageFetchMessengerData()
//    @State var LocalMessengerData: [localMessengerPageFetchMessagesField] = []
//    
//    @FocusState var sendAChatInputFocused: Bool
//    @State var wasSendAChatInputFocused: Bool = false
//    
//    @State var gapBeforeMessages = 0.0
//    @State var chatId: String = ""
//    @State var artistId: String = "0fd70b92-e4cf-4e21-b522-4ec5a22b35f1"
//    @State var artistPfp: String = ""
//    @State var artistName: String = "-"
//    @State var artistVerification: Bool = true
//    
//    @State var isDoneLoading: Bool = false
//    @State var loadNewIsDoneLoading: Bool = true
//    @State var disableLoadNew: Bool = false
//    @State var textMessage: String = ""
//    @State var disableAllInputs: Bool = false
//    @State var showImagePicker:Bool = false
//    @State var selectedImage: Image? = Image("")
//    @State var selected : [UIImage] = []
//    @State var displayImages: Array<Image> = []
//    @State var textEditorHeight : CGFloat = 20
//    @State var showMusicSheet: Bool = false
//    @State var x = 0
//    @State var y = 0
//    
//    
//    @State var fullScreenImage: Bool = false
//    @State var fullScreenImageUrl: String = ""
//    @State var scrollingTop: Bool = false
//    @State private var offset = CGSize.zero
//    @State var timeOffset = 0.0
//    @State var chatOnly = false
//    @State var spaceChatBottom = 0.0
//    
//    @State private var scrollViewContentOffset = CGFloat(0)
//    
//    @State private var presentAlert = false
//    @State private var presentAlertTitle = ""
//    @State private var presentAlertMessage = ""
//    
//    @State var presentPopover = false
//    @GestureState var press = false
//    @State var show = false
//    
//    var formatedTextMessage: String {
//        return textMessage.replacingOccurrences(of: " ", with: "")
//    }
//    
//    var sendTextIsValid: Bool {
//        if ((formatedTextMessage == "" && selectedImage != Image("")) || (formatedTextMessage != "" && selectedImage != Image("")) || (formatedTextMessage != "" && selectedImage == Image(""))) && !disableAllInputs{
//            return true
//        }else {
//            return false
//        }
//    }
//    
//    var type: String {
//        if selectedImage != Image(""){
//            return "Image"
//        }else {
//            return "Text"
//        }
//    }
//    
//    //"owner" replaces the type of curvature
//    var body: some View {
//        
//        NavigationView{
//            ScrollViewReader { proxy in
//                ZStack{
//                    if isDoneLoading {
//                        VStack{//heading
//                            if !chatOnly && !showChatMenu {
//                                VStack(spacing: 0){
//                                    HStack(spacing: 20){
//                                        Image(systemName: "chevron.left")
//                                            .font(.system(size: 23))
//                                            .font(Font.headline.weight(.black))
//                                            .padding([.top, .leading, .bottom])
//                                            .shadow(color: Color.accentColor, radius: 0.1)
//                                            .foregroundColor(Color.accentColor)
//                                            .onTapGesture {
//                                                self.presentationMode.wrappedValue.dismiss()
//                                            }
//                                        NavigationLink(destination: navProfilePage(artistId: artistId)) {
//                                            circleImage40by40(urlString: artistPfp)
//                                            (Text("\(artistName)") + Text((artistVerification) ? " \(Image(systemName: "checkmark.seal.fill"))" : ""))
//                                                .font(.headline)
//                                                .fontWeight(.bold)
//                                                .lineLimit(1)
//                                        }
//                                        Spacer()
//                                        
//                                    }
//                                    Divider().padding(0)
//                                }
//                                .transition(AnyTransition.move(edge: .top))
//                                .frame(maxWidth: .infinity)
//                                .background((colorScheme == .dark) ? .thinMaterial : .regular)
//                                Spacer()
//                            }
//                        }
//                        .animation(.easeInOut(duration: 0.25), value: showChatMenu)
//                        .zIndex(1)
//                        VStack{//CHAT
//                            ScrollView(.vertical, showsIndicators: false){
//                                ZStack (alignment: .trailing){
//                                    ScrollViewOffsetReader(onScrollingStarted: {
//                                        offset = .zero
//                                        timeOffset = 0
//                                        print("TIK STARTEDD")
//                                    }, onScrollingFinished: {
//                                        print("TIK FINISHEDD")
//                                    })
//                                    .background(Color.gray.opacity(0.0001))
//                                    .frame(width: viewableWidth - 80)
//                                    .gesture(
//                                        DragGesture()
//                                            .onChanged { gesture in
//                                                offset = gesture.translation
//                                                if offset.width > 0{
//                                                    timeOffset = 0
//                                                }else{
//                                                    if abs(offset.width) > abs(210){
//                                                        timeOffset = -70
//                                                    }else{
//                                                        timeOffset = (offset.width / 3)
//                                                    }
//                                                }
//                                                print("TIK CHANGING: ", gesture.translation)
//                                            }
//                                            .onEnded { gesture in
//                                                timeOffset = 0
//                                                offset = .zero
//                                                print("TIK END: ", gesture.translation)
//                                            }
//                                    )
//                                    VStack{
//                                        Spacer()
//                                            .frame(height: gapBeforeMessages)
//                                        Button{//LEAD PREVIOUS CHAT1
//                                            MessengerData.fetchUpdate(chatId: chatId)
//                                            loadNewProgresser()
//                                            scrollingTop = true
//                                        }label: {
//                                            HStack(spacing: 10){
//                                                Text("Load previous chat")
//                                                    .foregroundColor(Color.accentColor)
//                                                if loadNewIsDoneLoading {
//                                                    Image(systemName: "chevron.down")
//                                                        .foregroundColor(Color.accentColor)
//                                                }else{
//                                                    ProgressView()
//                                                        .padding(.horizontal, 20)
//                                                        .frame(width: 2.5, height: 2.5)
//                                                }
//                                            }.font(.footnote)
//                                        }
//                                        .id("loadPreviousChat")
//                                        .padding(.top, 50)
//                                        .frame(maxWidth: .infinity)
//                                        .listRowSeparator(.hidden)
//                                        .disabled(disableLoadNew)
//                                        ForEach(0..<MessengerData.messengerPageFetchMessagesFields.count, id: \.self){i in
//                                            let x = MessengerData.messengerPageFetchMessagesFields[i]
//                                            VStack(){
//                                                if x.headingMsg ?? "" != ""{
//                                                    let headingMsg = try! AttributedString(markdown: formatToDate(time: x.headingMsg ?? ""))
//                                                    Text(headingMsg)
//                                                        .multilineTextAlignment(.center)
//                                                        .lineLimit(1)
//                                                        .frame(maxWidth: .infinity)
//                                                        .font(.caption2)
//                                                        .foregroundColor(.gray)
//                                                        .padding(.top)
//                                                }
//                                                if x.type == "Deleted" {
//                                                    let deletedMsg = try! AttributedString(markdown: "**\(x.sender.artistName)** deleted a chat")
//                                                    Text(deletedMsg)
//                                                        .multilineTextAlignment(.center)
//                                                        .lineLimit(1)
//                                                        .frame(maxWidth: .infinity)
//                                                        .frame(maxWidth: .infinity)
//                                                        .font(.caption2)
//                                                        .foregroundColor(.gray)
//                                                        .padding(.top)
//                                                }
//                                                HStack{
//                                                    if x.sender._id == soundlytudeUserId() {
//                                                        chatsView(x: x)
//                                                            .gesture(
//                                                                DragGesture()
//                                                                    .onChanged { gesture in
//                                                                        offset = gesture.translation
//                                                                        if offset.width > 0{
//                                                                            timeOffset = 0
//                                                                        }else{
//                                                                            if abs(offset.width) > abs(210){
//                                                                                timeOffset = -70
//                                                                            }else{
//                                                                                timeOffset = (offset.width / 3)
//                                                                            }
//                                                                        }
//                                                                    }
//                                                                    .onEnded { gesture in
//                                                                        timeOffset = 0
//                                                                        offset = .zero
//                                                                    }
//                                                            )
//                                                    }else{
//                                                        chatsView(x: x)
//                                                    }
//                                                    VStack{
//                                                        if x._owner == "last" {
//                                                            Text(x.viewedByReciever == "Yes" ? "Read" : "Delivered")
//                                                                .multilineTextAlignment(.leading)
//                                                                .lineLimit(1)
//                                                                .foregroundColor(.gray)
//                                                        }
//                                                        Text(formatAMPM(time: x.time12hr))
//                                                            .multilineTextAlignment(.leading)
//                                                            .lineLimit(1)
//                                                            .foregroundColor(.gray)
//                                                    }
//                                                    .frame(maxWidth: 60)
//                                                    .font(.caption2)
//                                                    .offset(x: 60)
//                                                    .offset(x: timeOffset)
//                                                }
//                                                .animation(.easeInOut, value: timeOffset)
//                                            }
//                                            .padding(.bottom, (x._owner == "last") ? 10 : 0)
//                                            .padding(.vertical, -3.5)
//                                            .id(x._id)
//                                            .listRowSeparator(.hidden)
//                                            .listRowInsets(EdgeInsets())
//                                        }
//                                        ForEach(0..<LocalMessengerData.count, id: \.self){i in
//                                            let x = LocalMessengerData[i]
//                                            VStack(alignment: .trailing){
//                                                if x.headingMsg ?? "" != "" && x._id == LocalMessengerData[0]._id{
//                                                    let headingMsg = try! AttributedString(markdown: formatAMPM(time: x.headingMsg ?? ""))
//                                                    Text(headingMsg)
//                                                        .multilineTextAlignment(.center)
//                                                        .lineLimit(1)
//                                                        .frame(maxWidth: .infinity)
//                                                        .font(.caption2)
//                                                        .foregroundColor(.gray)
//                                                        .padding(.top)
//                                                }
//                                                HStack{
//                                                    localChatsView(x: x)
//                                                        .gesture(
//                                                            DragGesture()
//                                                                .onChanged { gesture in
//                                                                    offset = gesture.translation
//                                                                    if offset.width > 0{
//                                                                        timeOffset = 0
//                                                                    }else{
//                                                                        if abs(offset.width) > abs(210){
//                                                                            timeOffset = -70
//                                                                        }else{
//                                                                            timeOffset = (offset.width / 3)
//                                                                        }
//                                                                    }
//                                                                }
//                                                                .onEnded { gesture in
//                                                                    timeOffset = 0
//                                                                    offset = .zero
//                                                                }
//                                                        )
//                                                    VStack{
//                                                        Text(formatAMPM(time: x.time12hr))
//                                                            .multilineTextAlignment(.leading)
//                                                            .lineLimit(1)
//                                                            .foregroundColor(.gray)
//                                                    }
//                                                    .frame(maxWidth: 60)
//                                                    .font(.caption2)
//                                                    .offset(x: 60)
//                                                    .offset(x: timeOffset)
//                                                }
//                                                .animation(.easeInOut, value: timeOffset)
//                                                (x._id == LocalMessengerData[LocalMessengerData.count - 1]._id) ?
//                                                Text("Sending...")
//                                                //                                                        .multilineTextAlignment(.trailing)
//                                                    .padding(.horizontal)
//                                                    .font(.caption2)
//                                                    .foregroundColor(.gray)
//                                                : nil
//                                            }
//                                            .padding(.bottom, (x._id == LocalMessengerData[LocalMessengerData.count - 1]._id) ? 10 : 0)
//                                            .padding(.vertical, -3.5)
//                                            .opacity(0.75)
//                                            .id(x._id)
//                                            .listRowSeparator(.hidden)
//                                            .listRowInsets(EdgeInsets())
//                                        }
//                                        Spacer().frame(height: (chatOnly) ? 0 : spaceChatBottom)
//                                            .animation(.spring(), value: spaceChatBottom)
//                                        Text("")
//                                            .id("bottom")
//                                    }
//                                }
//                            }
//                            .onAppear{
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
//                                    withAnimation(Animation.easeInOut) {
//                                        proxy.scrollTo("bottom", anchor: .bottom)
//                                        print("scroll")
//                                    }
//                                }
//                            }
//                            .listStyle(PlainListStyle())
//                            .padding(.vertical, (chatOnly) ? 0 : 10)
//                        }
//                        //                        .offset(y: (sendAChatInputFocused && showChatMenu) ? -keyboardHeightHelper.keyboardHeight : 0)
//                        .onAppear{//POOOOOOO
//                            Task {
//                                do {
//                                    await refreshLiveMessanger()
//                                }catch{
//                                    print("")
//                                }
//                            }
//                        }
//                        .alert(presentAlertTitle, isPresented: $presentAlert, actions: {
//                            Button("OK", role: .cancel, action: {})
//                        }, message: {
//                            Text(presentAlertMessage)
//                        })
//                    }else{
//                        VStack{
//                            ProgressView()
//                                .progressViewStyle(CircularProgressViewStyle(tint: Color.accentColor))
//                                .onAppear{
//                                    messangerPageFetchingCompleted = false
//                                    progresser()
//                                    MessengerData.fetchUpdate(chatId: chatId)
//                                }
//                        }
//                    }
//                    VStack{//chatInput
//                        if (!chatOnly && !showChatMenu) || (sendAChatInputFocused && showChatMenu) {
//                            Spacer()
//                            VStack(alignment: .trailing, spacing: 0){
//                                Divider().padding(0)
//                                if showReplyView {
//                                    //                                    HStack{
//                                    //                                        Button(role: .destructive) {
//                                    //                                            showReplyView = false
//                                    //                                        } label: {
//                                    //                                            Text("Cancel")
//                                    //                                        }
//                                    //                                        Spacer()
//                                    //                                        Text("Replying to:")
//                                    //                                    }.padding()
//                                    replyView.padding(.horizontal)
//                                }
//                                if selected != []{
//                                    ScrollView(.horizontal, showsIndicators: false) {
//                                        HStack(spacing: 10){
//                                            ForEach(self.selected,id: \.self){i in
//                                                ZStack(alignment: .topTrailing){
//                                                    Image(uiImage: i)
//                                                        .resizable()
//                                                        .scaledToFit()
//                                                        .cornerRadius(10)
//                                                        .frame(maxHeight: 256)
//                                                        .frame(minWidth: 10, minHeight:10)
//                                                    
//                                                    Button(role: .destructive) {
//                                                        selected.remove(at: selected.firstIndex(of: i)!)
//                                                    } label: {
//                                                        Image(systemName: "xmark.circle")
//                                                            .foregroundColor(.white)
//                                                            .background(Circle().fill(Color.gray).scaleEffect(1.15))
//                                                    }
//                                                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y:0)
//                                                    .padding(.all, 5)
//                                                }
//                                            }
//                                        }
//                                        .padding(.horizontal, 20)
//                                    }
//                                    .padding(.top)
//                                }
////                                if selectedImage != Image(""){
////                                    VStack(spacing: 0){
////                                        Button(role: .destructive) {
////                                            withAnimation(.spring()) {
////                                                selectedImage = Image("")
////                                            }
////                                        } label: {
////                                            HStack(spacing: 5){
////                                                Text("Remove")
////                                                Image(systemName: "xmark.circle")
////                                            }
////                                        }
////                                        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y:0)
////                                        .padding(.all, 5)
////                                        self.selectedImage?
////                                            .resizable()
////                                            .scaledToFit()
////                                            .cornerRadius(10)
////                                            .frame(maxWidth: viewableWidth - 20, maxHeight: 256)
////                                            .frame(minWidth: 10, minHeight:10)
////                                            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y:0)
////                                            .onAppear{
////                                                //                                                displayImage = selectedImage
////                                            }
////                                    }
////                                    .padding(.horizontal)
////                                }
//                                HStack(alignment: .bottom) {
//                                    Button {
//                                        stopRefreshing = true
//                                        self.showImagePicker.toggle()
//                                    } label: {
//                                        IconButton(icon: "photo.on.rectangle.angled", size: 30)
//                                    }
//                                    .sheet(isPresented: $showImagePicker.onChange(showImagePickerFunction)) {
//                                        MultipleImagePicker(images: $selected, show: $showImagePicker)
//                                            .ignoresSafeArea()
//                                    }
//                                    Button {
//                                        showMusicSheet.toggle()
//                                    } label: {
//                                        IconButton(icon: "music.note", size: 30)
//                                    }
//                                    .sheet(isPresented: $showMusicSheet) {
//                                        Text("Music")
//                                    }
//                                    ZStack(alignment: .leading) {
//                                        Text(textMessage + "​")//there's a haracter here
//                                            .font(.body)
//                                            .foregroundColor(.clear)
//                                            .padding(.horizontal, 10)
//                                            .padding(.vertical, 7.5)
//                                            .background(GeometryReader {
//                                                Color.clear.preference(key: ViewHeightKey.self,
//                                                                       value: $0.frame(in: .local).size.height)
//                                            })
//                                            .lineLimit(5)
//                                        ZStack(alignment: .leading){
//                                            if #available(iOS 16.0, *) {
//                                                TextEditor(text:$textMessage)
//                                                    .font(.body)
//                                                    .frame(maxHeight: max(20, textEditorHeight))
//                                                    .customTextField(color: .accentColor, padding: 5, lineWidth: 1)
//                                                    .focused($sendAChatInputFocused)
//                                                    .scrollContentBackground(Visibility.hidden)    // new technique for iOS 16
//                                            } else {
//                                                // Fallback on earlier versions
//                                                TextEditor(text:$textMessage)
//                                                    .font(.body)
//                                                    .frame(maxHeight: max(20, textEditorHeight))
//                                                    .customTextField(color: .accentColor, padding: 5, lineWidth: 1)
//                                                    .focused($sendAChatInputFocused)
//                                            }
//                                            Text((sendTextIsValid) ? "" : (showReplyView) ? "  Reply" : "  Send a chat") //bla1
//                                                .font(.body)
//                                                .opacity(0.25)
//                                                .offset(y: -0.2)
//                                                .onTapGesture {
//                                                    withAnimation(.easeInOut(duration: 0.25)) {
//                                                        sendAChatInputFocused = true
//                                                    }
//                                                }
//                                        }
//                                    }
//                                    .onPreferenceChange(ViewHeightKey.self) {
//                                        textEditorHeight = $0
//                                    }
//                                    
//                                    Button {
//                                        disableAllInputs = true
//                                        let messageId = UUID().uuidString
//                                        displayImages.append(self.selectedImage ?? Image(""))
//                                        LocalMessengerData.append(localMessengerPageFetchMessagesField(_id: messageId, type: type, text: "\(textMessage)", viewedByReciever: "False", audio: "", video: "", photo: "", _createdDate: "Just now", _owner: "last", time12hr: "\(Date().millisecondsSince1970)", headingMsg: "\(Date().millisecondsSince1970)"))
//                                        
//                                        let uiImage: UIImage = self.selectedImage.asUIImage()
//                                        let imageData: Data = uiImage.jpegData(compressionQuality: 0.1) ?? Data()
//                                        let imageStr: String = imageData.base64EncodedString()
//                                        sendMessage(type: type, receiver: artistId, text: textMessage, imageURI: imageStr, chatId: chatId, localMsgId: messageId)
//                                        textMessage = ""
//                                        withAnimation(.spring()) {
//                                            selectedImage = Image("")
//                                        }
//                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
//                                            withAnimation(Animation.easeInOut) {
//                                                proxy.scrollTo("bottom", anchor: .bottom)
//                                                print("scroll")
//                                            }
//                                        }
//                                    } label: {
//                                        if sendTextIsValid {
//                                            IconButton(icon: "arrow.up", size: 30, background: Color.accentColor, foregroundColor: Color.white)
//                                        }else{
//                                            IconButton(icon: "arrow.up", size: 30, background: Color.gray.opacity(0.25))
//                                        }
//                                    }
//                                    .scaleEffect((sendTextIsValid) ? 1 : 0.9)
//                                    .disabled((sendTextIsValid) ? false : true)
//                                    .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.95, blendDuration: 0.5), value: textMessage)
//                                    
//                                }
//                                .padding(10)
//                            }
//                            .transition(AnyTransition.move(edge: .bottom))
//                            .background((colorScheme == .dark) ? .thinMaterial : .regular)
//                            .animation(.spring(), value: selected)
//                            .overlay(
//                                GeometryReader { geo in
//                                    Text("")
//                                        .onAppear{
//                                            spaceChatBottom = geo.size.height
//                                            print("Height: ", geo.size.height)
//                                        }
//                                        .onChange(of: geo.size) { newSize in
//                                            spaceChatBottom = geo.size.height
//                                            print("Height: ", geo.size.height)
//                                        }
//                                }
//                            )
//                            Spacer().frame(height: 0)
//                        }
//                    }
//                    .animation(.easeInOut(duration: 0.25), value: showChatMenu)
//                    .zIndex((sendAChatInputFocused) ? 0 : 1)
//                    .onAppear{
//                        withAnimation(.easeInOut(duration: 0.25)) {
//                            //                            sendAChatInputFocused = true
//                            showChatMenu = false
//                            chatsViewGrow = 1
//                        }
//                    }
//                    chatMenu()
//                        .opacity(showChatMenu ? 1 : 0)
//                        .animation(.interpolatingSpring(stiffness: 250, damping: 20), value: showChatMenu)
//                }
//                .onAppear{
//                    if !chatOnly{
//                        withAnimation(.easeIn(duration: 0.25)) {
//                            globalVariables.hideTabBar = true
//                        }
//                    }
//                    pauseFetchingMessages = false
//                    pauseFetchingChats = true
//                }
//                .onDisappear{
//                    withAnimation(.easeIn(duration: 0.25)) {
//                        globalVariables.hideTabBar = false
//                        pauseFetchingMessages = true
//                        pauseFetchingChats = false
//                    }
//                }
//                .transition(.move(edge: .leading))
//            }
//            //            }
//            //            .offset(x: exitOffset)
//        }
//    }
//    
//    func showImagePickerFunction(to value: Bool) {
//        print("IMAGE PICKER: ", showImagePicker)
//        if showImagePicker{
//            stopRefreshing = true
//        }else{
//            stopRefreshing = false
//            Task {
//                do {
//                    await refreshLiveMessanger()
//                }catch{
//                    print("")
//                }
//            }
//        }
//    }
//    
//    @State var longPressLocationY = 0.0
//    @State var defaultLocationY = 0.0
//    @State var chatsViewGrow: Double = 1
//    @State var selectedChat: String = ""
//    @State var screenHeight: Double = 0.0
//    @ViewBuilder
//    func chatsView(x: messengerPageFetchMessagesField) -> some View {
//        var lineLimit = false
//        let chatBubble = ChatBubble(arrow: (x._owner == "last") ? true : false, bubble: (x.type != "Deleted") ? true : false, direction: x.sender._id == soundlytudeUserId() ? .right : .left) {
//            if x.type == "Text"{
//                Text("\(x.text ?? "-")")
//                    .lineLimit(lineLimit ? 5 : nil)
//                    .padding(.horizontal, 15)
//                    .padding(.trailing, 2.5)
//                    .padding(.vertical, 7)
//                    .foregroundColor(x.sender._id == soundlytudeUserId() ? Color.white : Color("BlackWhite"))
//                    .background((x.sender._id == soundlytudeUserId()) ? Color.accentColor : Color.secondarySystemFill)
//                    .background((x.sender._id == soundlytudeUserId()) ? Color.black : Color.clear)
//            }
//            if x.type == "Image"{
//                squareImageChat(x: x)
//            }
//        }
//        let reactions =
//        Button {
//            //
//        } label: {
//            HStack(spacing: 0){
//                ForEach(0..<x.reactions.count, id: \.self){i in
//                    Text(x.reactions[i].reaction)
//                        .frame(width: 35, height: 35)
//                        .background(x.reactions[i]._id == soundlytudeUserId() ? Color.red.opacity(0.5) : Color.clear)
//                        .cornerRadius(35)
//                }
//            }
//            .background(.ultraThinMaterial)
//            .cornerRadius(25)
//            .offset(y: 10)
//        }
//        VStack{
//            if x.reactions.count > 0 {
//                HStack{
//                    if x.sender._id == soundlytudeUserId() {
//                        Spacer()
//                        reactions
//                    }else{
//                        reactions
//                        Spacer()
//                    }
//                }
//                .offset(x: x.sender._id == soundlytudeUserId() ? 75 : 0)
//                .offset(x: x.sender._id == soundlytudeUserId() ? timeOffset : 0, y: 0)
//                .padding(.horizontal, 30)
//                .zIndex(1)
//            }
//            ZStack{
//                chatBubble
//                    .scaleEffect(x._id == selectedChat ? chatsViewGrow : 1)
//                    .animation(.easeOut, value: selectedChat)
//                    .opacity(1)
//                    .offset(x: x.sender._id == soundlytudeUserId() ? 75 : 0)
//                    .offset(x: x.sender._id == soundlytudeUserId() ? timeOffset : 0, y: 0)
//                    .overlay(
//                        GeometryReader { geometry in
//                            let frame = geometry.frame(in: CoordinateSpace.global)
//                            Color.red.opacity(0.0001)
//                                .offset(x: x.sender._id == soundlytudeUserId() ? 75 : 0)
//                                .offset(x: x.sender._id == soundlytudeUserId() ? timeOffset : 0, y: 0)
//                                .onTapGesture {  }
//                                .onLongPressGesture(minimumDuration: 0.5, pressing: { (isPressing) in
//                                    selectedChat = x._id
//                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
//                                        if isPressing{
//                                            withAnimation(.spring()){
//                                                chatsViewGrow = 0.95
//                                            }
//                                            longPressLocationY = frame.midY
//                                        }else{
//                                            withAnimation(.spring()){
//                                                chatsViewGrow = 1
//                                            }
//                                        }
//                                    }
//                                }, perform: {
//                                    wasSendAChatInputFocused = sendAChatInputFocused
//                                    sendAChatInputFocused = false
//                                    let cancelButton = Button {
//                                        withAnimation(.spring()){
//                                            showReplyView = false
//                                        }
//                                    } label: {
//                                        Image(systemName: "xmark")
//                                            .padding(5)
//                                    }
//                                        .foregroundColor(.white)
//                                        .background(.gray.opacity(0.5))
//                                        .cornerRadius(15)
//                                    let filtered = x.reactions.filter { reaction in
//                                        return reaction._id == soundlytudeUserId()
//                                    }
//                                    let reactionIndex = (filtered.count < 1) ? -1 : x.reactions.firstIndex(of: filtered[0])!
//                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
//                                        chatsViewGrow = 1.05
//                                        lineLimit = true
//                                        selectedReaction = (reactionIndex < 0) ? "" : x.reactions[reactionIndex].reaction
//                                        chatMenuChat = AnyView(chatBubble.offset(x: x.sender._id == soundlytudeUserId() ? 20 : -20))
//                                        replyView = AnyView(
//                                            HStack{
//                                                if x.sender._id == soundlytudeUserId() {
//                                                    chatBubble.offset(x: 20)
//                                                        .padding(.vertical)
//                                                    cancelButton
//                                                }else{
//                                                    cancelButton
//                                                    chatBubble.offset(x: -20)
//                                                        .padding(.vertical)
//                                                }
//                                            })
//                                    }
//                                    chatMenuOwner = x.sender._id == soundlytudeUserId() ? true : false
//                                    longPressLocationY = frame.midY
//                                    showChatMenu.toggle()
//                                    let tapticFeedback = UINotificationFeedbackGenerator()
//                                    tapticFeedback.notificationOccurred(.success)
//                                })
//                        }
//                    )
//            }
//        }
//    }
//    
//    @ViewBuilder
//    func localChatsView(x: localMessengerPageFetchMessagesField) -> some View {
//        let lastItem: localMessengerPageFetchMessagesField = LocalMessengerData[LocalMessengerData.count - 1]
//        let currentItemIndex = LocalMessengerData.firstIndex(of: x)!
//        ChatBubble(arrow: (x._id == lastItem._id) ? true : false, bubble: (x.type != "Deleted") ? true : false, direction: .right) {
//            if x.type == "Text"{
//                Text(x.text ?? "-")
//                    .padding(.horizontal, 15)
//                    .padding(.trailing, 2.5)
//                    .padding(.vertical, 7)
//                    .foregroundColor(Color.white )
//                    .background(Color.accentColor)
//                    .background(Color.black)
//            }
//            if x.type == "Image"{
//                ZStack(alignment: .bottom){
//                    //                    Image(base64String: "\(x.photo)")?
//                    displayImages[currentItemIndex]
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                        .frame(maxWidth: 256, maxHeight: 480)
//                    if (x.text ?? "") != "" {
//                        Text(x.text ?? "")
//                            .frame(width: 246)
//                            .padding(.all, 5)
//                            .foregroundColor(Color.white)
//                            .background(Color.black.opacity(0.5))
//                            .lineLimit(5)
//                    }
//                }
//            }
//        }
//        .offset(x: 75)
//        .offset(x: timeOffset, y: 0)
//    }
//    
//    @State var showChatMenu: Bool = false
//    @State var chatMenuOwner: Bool = false
//    @State var selectedReaction: String = ""
//    @State var selectedReactionGrow: Double = 1
//    @State var chatMenuChatOffsetY: Double = 0.0
//    @State var unanimatedChatMenuChatOffsetY: Double = 0.0
//    @State var chatMenuChat: AnyView = AnyView(EmptyView())
//    @State var replyView: AnyView = AnyView(EmptyView())
//    @State var showReplyView: Bool = false
//    @ViewBuilder
//    func chatMenu() -> some View {
//        let reactions: Array<String> = ["👍","👎","❤️","😂","😭","😐","😢","😱","🤔","😮","❓","⁉️"]
//        let menu =
//        VStack(alignment: .leading, spacing: 0) {
//            Button {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
//                    withAnimation(.interactiveSpring(response: 1, dampingFraction: 0.75, blendDuration: 1.0)){
//                        closeMenu()
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
//                            sendAChatInputFocused = true
//                            showReplyView = true
//                        }
//                    }
//                }
//            } label: {
//                menuButtonView(label: "Reply", image: "arrowshape.turn.up.left", color: Color("BlackWhite"), last: false)
//            }
//            Button {
//                //
//            } label: {
//                menuButtonView(label: "Copy", image: "doc.on.doc", color: Color("BlackWhite"), last: false)
//            }
//            if chatMenuOwner {
//                Button {
//                    updateMessage(type: "Delete", messageId: selectedChat)
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
//                        closeMenu()
//                        updateLocalMessage(type: "Delete", messageId: selectedChat)
//                    }
//                } label: {
//                    menuButtonView(label: "Delete", image: "trash", color: Color.red, last: true)
//                }
//            }else{
//                Button {
//                    //
//                } label: {
//                    menuButtonView(label: "Report", image: "flag", color: Color.red, last: true)
//                }
//            }
//        }
//        .frame(maxWidth: .infinity)
//        .background(Color("WhiteBlack"))
//        .cornerRadius(20)
//        .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y:5)
//        .scaleEffect(showChatMenu ? 1 : 0.5)
//        
//        ZStack{
//            Color.gray
//                .ignoresSafeArea()
//                .opacity(0.0001)
//                .background(.ultraThinMaterial)
//                .onTapGesture{//Close Menu
//                    closeMenu()
//                }
//            GeometryReader{ geo in
//                Color.red
//                    .opacity(0.0001)
//                    .onTapGesture{//Close Menu
//                        closeMenu()
//                    }
//                    .onAppear{
//                        screenHeight = geo.size.height
//                    }
//            }
//            VStack{
//                if longPressLocationY > (screenHeight - 100) {
//                    Spacer()
//                }
//                if sendAChatInputFocused && longPressLocationY > 400{
//                    menu
//                }
//                ScrollView(.horizontal, showsIndicators: false){
//                    HStack{
//                        ForEach(reactions, id: \.self){i in
//                            let index = reactions.firstIndex(of: i)
//                            Button {
//                                if selectedReaction == i{
//                                    selectedReaction = ""
//                                }else{
//                                    selectedReaction = i
//                                }
//                                updateMessage(type: "Reaction", messageId: selectedChat)
//                                selectedReactionGrow = 1.5
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
//                                    closeMenu()
//                                    updateLocalMessage(type: "Reaction", messageId: selectedChat)
//                                }
//                            } label: {
//                                Text(i)
//                                    .font(.system(size: 20))
//                                    .scaleEffect(selectedReaction == i ? selectedReactionGrow : 1)
//                                    .animation(.interpolatingSpring(stiffness: 170, damping: 10), value: selectedReactionGrow)
//                            }
//                            .offset(x: showChatMenu ? 0 : -10)
//                            .scaleEffect(showChatMenu ? 1 : 0, anchor: .bottomLeading)
//                            .rotationEffect(.degrees(showChatMenu ? 0 : -45))
//                            .frame(width: 35, height: 35)
//                            .background(selectedReaction == i ? Color("BlackWhite").opacity(0.2) : .clear)
//                            .cornerRadius(35)
//                            .padding(.vertical, 5)
//                            .animation(.interpolatingSpring(stiffness: 170, damping: 14).delay((Double(index ?? 0) - 0.1) / 15), value: showChatMenu)
//                        }
//                    }
//                    .padding(.horizontal, 5)
//                }
//                .background(.ultraThinMaterial)
//                .cornerRadius(50)
//                .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y:5)
//                .scaleEffect(showChatMenu ? 1 : 0)
//                .overlay(
//                    VStack{
//                        if showChatMenu {
//                            GeometryReader { geo in
//                                Text("")
//                                    .onAppear{
//                                        let frame = geo.frame(in: CoordinateSpace.global)
//                                        print("POPOSITION:", frame.midY)
//                                    }
//                                    .onChange(of: geo.size) { newSize in
//                                        let frame = geo.frame(in: CoordinateSpace.global)
//                                        print("POPOSITION:", frame.midY)
//                                    }
//                            }
//                        }
//                    }
//                )
//                chatMenuChat
//                    .offset(y: chatMenuChatOffsetY)
//                    .onTapGesture{ //Close Menu
//                        closeMenu()
//                    }
//                    .overlay(
//                        GeometryReader{ geo in
//                            let frame = geo.frame(in: CoordinateSpace.global)
//                            chatMenuChat
//                                .offset(y: chatMenuChatOffsetY)
//                                .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y:5)
//                                .onAppear{
//                                    unanimatedChatMenuChatOffsetY = 0.0
//                                    defaultLocationY = frame.midY
//                                    unanimatedChatMenuChatOffsetY = longPressLocationY - defaultLocationY
////                                    chatMenuChatOffsetY = (longPressLocationY - defaultLocationY) * 0.98
//                                    chatMenuChatOffsetY = 0.0
////                                    withAnimation(.interactiveSpring(response: 1, dampingFraction: 0.75, blendDuration: 1.0)){
////                                        chatMenuChatOffsetY = 0.0
////                                    }
//                                }
//                        }
//                            .opacity(0.1)
////                            .frame(height: 1)
//                    )
//                if !sendAChatInputFocused || longPressLocationY < 400{
//                    menu
//                }
//                if longPressLocationY < 75 {
//                    Spacer()
//                }
//            }
//            .offset(y: (longPressLocationY > 100 && longPressLocationY < (screenHeight - 75)) && showChatMenu ? unanimatedChatMenuChatOffsetY : 0)
//            .padding()
//        }
//    }
//    
//    func closeMenu(){
//        withAnimation(.interactiveSpring(response: 0.55, dampingFraction: 0.75, blendDuration: 1.0)){
//            chatMenuChat = AnyView(EmptyView())
//            chatsViewGrow = 1
//            showChatMenu.toggle()
////                            chatMenuChatOffsetY = longPressLocationY - defaultLocationY
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                unanimatedChatMenuChatOffsetY = 0.0
//            }
//            sendAChatInputFocused = wasSendAChatInputFocused
//        }
//    }
//    
//    func progresser() {
//        if(messangerPageFetchingCompleted){
//            isDoneLoading = true
//        }else{
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
//                progresser()
//                if (messangerPageFetchingCompleted == false){
//                    isDoneLoading = false
//                }
//            }
//        }
//    }
//    
//    func loadNewProgresser() {
//        if(messangerPageFetchingCompleted){
//            loadNewIsDoneLoading = true
//            scrollingTop = false
//            if returnedEmpty {
//                disableLoadNew = true
//            }
//        }else{
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
//                loadNewProgresser()
//                if (messangerPageFetchingCompleted == false){
//                    loadNewIsDoneLoading = false
//                }
//            }
//        }
//    }
//    
//    func sendMessage(type: String, receiver:String, text: String, imageURI: String, chatId: String, localMsgId: String) {
//        pauseFetchingMessages = true
//        var urlParam:String = ""
//        if type == "Text"{
//            urlParam = "/_functions/textMessage?password=9cT8D9T2JUAvPxUeoGf3&localMsgId=\(localMsgId)"
//        }
//        if type == "Image"{
//            urlParam = "/_functions/imageMessage?artistId=\(soundlytudeUserId())&localMsgId=\(localMsgId)"
//        }
//        guard let url = URL(string: HttpBaseUrl() + urlParam) else {
//            print("Error: cannot create URL")
//            return
//        }
//        
//        struct UploadImageData: Codable {
//            let dataURI: String
//            let userId: String
//            let artistName: String
//        }
//        
//        // Create model
//        struct UploadData: Codable {
//            let type: String
//            let receiver: String
//            let text: String
//            let sender: String
//            let chatId: String
//            let uploadImageData: UploadImageData
//            let secPassword: String
//        }
//        
//        // Add data to the model
//        let uploadDataModel = UploadData(type: type, receiver: receiver, text: text, sender: soundlytudeUserId(), chatId: chatId, uploadImageData: UploadImageData(dataURI: imageURI, userId: soundlytudeUserId(), artistName: local.string(forKey: "currentUserArtistName") ?? ""), secPassword: "9cT8D9T2JUAvPxUeoGf3")
//        // Convert model to JSON data
//        guard let jsonData = try? JSONEncoder().encode(uploadDataModel) else {
//            print("Error: Trying to convert model to JSON data")
//            return
//        }
//        // Create the url request
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type") // the request is JSON
//        request.setValue("application/json", forHTTPHeaderField: "Accept") // the response expected to be in JSON format
//        request.httpBody = jsonData
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            guard error == nil else {
//                print("Error: error calling POST")
//                print(error!)
//                presentAlert = true
//                presentAlertTitle = "WARNING"
//                presentAlertMessage = "Error sending message, check your internet connection"
//                removePlaceholderMessage(id: localMsgId)
//                return
//            }
//            guard let data = data else {
//                print("Error: Did not receive data")
//                presentAlert = true
//                presentAlertTitle = "WARNING"
//                presentAlertMessage = "Error receiving authorization"
//                removePlaceholderMessage(id: localMsgId)
//                return
//            }
//            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
//                print("Error: HTTP request failed", response)
//                presentAlert = true
//                presentAlertTitle = "WARNING"
//                presentAlertMessage = "Failed to send that message"
//                removePlaceholderMessage(id: localMsgId)
//                return
//            }
//            do {
//                guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
//                    print("Error: Cannot convert data to JSON object")
//                    return
//                }
//                guard let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) else {
//                    print("Error: Cannot convert JSON object to Pretty JSON data")
//                    return
//                }
//                guard let prettyPrintedJson = String(data: prettyJsonData, encoding: .utf8) else {
//                    print("Error: Couldn't print JSON in String")
//                    return
//                }
//                
//                print(prettyPrintedJson)
//                let dataReturned = try JSONDecoder().decode (SendMessageResponse.self, from: data)
//                let chatToDelete = dataReturned.localMsgId
//                disableAllInputs = false
//                MessengerData.fetchLiveUpdate(chatId: chatId, currentChats: MessengerData.messengerPageFetchMessagesFields)
//                DispatchQueue.main.async{
//                    removePlaceholderMessage(id: chatToDelete)
//                }
//            } catch {
//                print("Error: Trying to convert JSON data to string @")
//                removePlaceholderMessage(id: localMsgId)
//                return
//            }
//        }.resume()
//    }
//    
//    func updateMessage(type: String, messageId: String) {
//        pauseFetchingMessages = true
//        guard let url = URL(string: HttpBaseUrl() + "/_functions/updateMessage?password=9cT8D9T2JUAvPxUeoGf3") else {
//            print("Error: cannot create URL")
//            return
//        }
//        
//        // Create model
//        struct UpdateData: Codable {
//            let type: String
//            let chatId: String
//            let messageId: String
//            let reaction: String
//            let currentUserId: String
//        }
//        
//        // Add data to the model
//        let updateDataModel = UpdateData(type: type, chatId: chatId,  messageId: messageId, reaction: selectedReaction, currentUserId: soundlytudeUserId())
//        
//        // Convert model to JSON data
//        guard let jsonData = try? JSONEncoder().encode(updateDataModel) else {
//            print("Error: Trying to convert model to JSON data")
//            return
//        }
//        
//        // Create the request
//        var request = URLRequest(url: url)
//        request.httpMethod = "PUT"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = jsonData
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            guard error == nil else {
//                print("Error: error calling POST")
//                print(error!)
//                presentAlert = true
//                presentAlertTitle = "WARNING"
//                presentAlertMessage = "Error updating message, check your internet connection"
//                pauseFetchingMessages = false
//                return
//            }
//            guard var data = data else {
//                print("Error: Did not receive data")
//                presentAlert = true
//                presentAlertTitle = "WARNING"
//                presentAlertMessage = "Error receiving authorization"
//                pauseFetchingMessages = false
//                return
//            }
//            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
//                print("Error: HTTP request failed", response)
//                presentAlert = true
//                presentAlertTitle = "WARNING"
//                presentAlertMessage = "Failed to update that message"
//                pauseFetchingMessages = false
//                return
//            }
//            do {
//                MessengerData.fetchLiveUpdate(chatId: chatId, currentChats: MessengerData.messengerPageFetchMessagesFields)
//            } catch {
//                print("Error: Trying to convert JSON data to string")
//                return
//            }
//        }.resume()
//    }
//    
//    func updateLocalMessage(type: String, messageId: String) {
//        let currentItemMessage = MessengerData.messengerPageFetchMessagesFields.filter { item in
//            return item._id == messageId
//        }
//        if currentItemMessage.count > 0{
//            let currentIndex = MessengerData.messengerPageFetchMessagesFields.firstIndex(of: currentItemMessage[0])!
//            if type == "Delete"{
//                MessengerData.messengerPageFetchMessagesFields[currentIndex].type = "Deleted"
//            }
//            if type == "Reaction" {
//                var userReactionRemoved = MessengerData.messengerPageFetchMessagesFields[currentIndex].reactions.filter { item in
//                    return item._id != soundlytudeUserId()
//                }
//                if selectedReaction != "" {
//                    userReactionRemoved.append(reactionsField(_id: soundlytudeUserId(), reaction: selectedReaction))
//                    withAnimation(.spring()){
//                        MessengerData.messengerPageFetchMessagesFields[currentIndex].reactions = userReactionRemoved
//                    }
//                } else {
//                    withAnimation(.spring()){
//                        MessengerData.messengerPageFetchMessagesFields[currentIndex].reactions = userReactionRemoved
//                    }
//                }
//            }
//        }else{
//            print("WHAT THE FUCK")
//        }
//    }
//    
//    func removePlaceholderMessage(id: String){
//        let filtered = LocalMessengerData.filter { word in
//            return word._id == id
//        }
//        let indexToRemove = LocalMessengerData.firstIndex(of: filtered[0])
//        LocalMessengerData.remove(at: indexToRemove ?? 0)
//        displayImages.remove(at: indexToRemove ?? 0)
//    }
//    
//    func refreshLiveMessanger() async {
//        if !stopRefreshing {
//            try? await Task.sleep(nanoseconds: 5_000_000_000)
//            Task {
//                do {
//                    if !pauseFetchingMessages {
//                        print("FETCH")
//                        MessengerData.fetchLiveUpdate(chatId: chatId, currentChats: MessengerData.messengerPageFetchMessagesFields)
//                    }
//                    await refreshLiveMessanger()
//                }catch{
//                    await refreshLiveMessanger()
//                }
//            }
//        }
//    }
//}

struct SendMessageResponse: Hashable, Codable {
    let localMsgId: String
}

struct UploadImageResponse: Hashable, Codable {
    let url: String
}

struct messengerView_Previews: PreviewProvider {
    static var previews: some View {
//        Color.red
//        menuButtonView(label: "Nigga", image: "trash", color: .red, last: false)
        chatView2()
    }
}

struct receiverField: Hashable, Codable {
    let _id: String
    let artistName: String
    let slug: String
    let pimage: String
    let verification: Bool?
}

struct senderField: Hashable, Codable {
    let _id: String
    let artistName: String
    let slug: String
    let pimage: String
    let verification: Bool?
}

struct reactionsField: Hashable, Codable {
    let _id: String
    let reaction: String
}

struct messengerPageFetchMessagesField: Hashable, Codable {
    let _id: String
    var type: String
    let text: String?
    let viewedByReciever: String
    let audio: String?
    let video: String?
    let photo: [String]?
    let _createdDate: String
    let _updatedDate: String
    let _owner: String
    let time12hr: String
    let headingMsg: String?
    let replyType: String?
    let repliedArtistId: String?
    let repliedText: String?
    let repliedTextId: String?
    var reactions: [reactionsField]
    let sender: senderField
    let receiver: receiverField
}

struct localMessengerPageFetchMessagesField: Hashable, Codable {
    let _id: String
    let type: String
    let text: String?
    let viewedByReciever: String
    let audio: String?
    let video: String?
    let photo: String
    let _createdDate: String
    let _owner: String
    let time12hr: String
    let headingMsg: String?
}

class messengerPageFetchMessengerData: ObservableObject {
    @Published var messengerPageFetchMessagesFields: [messengerPageFetchMessagesField] = []
    @Published var count = 0
    @Published var scroll = 0
    
    func fetchUpdate(chatId: String) {
        pauseFetchingMessages = true
        messangerPageFetchingCompleted = false
        guard let url = URL(string: HttpBaseUrl() + "/_functions/fetchMessages?password=Xi4tFVn10qINp56p4Z1q&type=filterEq&currentUserId=\(soundlytudeUserId())&continueFrom=\(count)&chatId=\(chatId)") else {
            return}
        print(url)
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _,
            error in
            guard let data = data, error == nil else {
                return
            }
            // Convert to JSON
            do
            {
                let data = try JSONDecoder().decode ([messengerPageFetchMessagesField].self, from: data)
                DispatchQueue.main.async{
                    self?.messengerPageFetchMessagesFields = data + self!.messengerPageFetchMessagesFields
                    self?.count += 10
                    messangerPageFetchingCompleted = true
                    if data == [] || data.count < 10{
                        returnedEmpty = true
                    }
                    pauseFetchingMessages = false
                }
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }
    
    func fetchLiveUpdate(chatId: String, currentChats: [messengerPageFetchMessagesField], reason: String = "refresh") {
        pauseFetchingMessages = true
        guard let url = URL(string: HttpBaseUrl() + "/_functions/fetchUpdateMessages?password=obMcr9M81guH7XZST24N&type=filterEq&currentUserId=\(soundlytudeUserId())&chatId=\(chatId)") else {
            print("Error: cannot create URL")
            return
        }
        
        // Create model
        struct UploadData: Codable {
            let currentChats: [messengerPageFetchMessagesField]
            let count: Int
        }
        
        // Add data to the model
        let uploadDataModel = UploadData(currentChats: currentChats, count: currentChats.count)
        
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
                print("checkpoint1: ", error!)
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
            do
            {
                let data2 = try JSONDecoder().decode ([messengerPageFetchMessagesField].self, from: data)
                DispatchQueue.main.async{
                    withAnimation(.easeIn(duration: 0.25)) {
                        pauseFetchingMessages = false
                        if !stopRefreshing {
                            self.messengerPageFetchMessagesFields = data2
                            if reason == "post"{
                                scrollToBottom = true
                                self.scroll = self.scroll + 1
                            }
                        }
                    }
                }
            }
            catch {
                print(error)
            }
        }.resume()
    }
}


struct ScrollViewOffsetReader: View {
    private let onScrollingStarted: () -> Void
    private let onScrollingFinished: () -> Void
    
    private let detector: CurrentValueSubject<CGFloat, Never>
    private let publisher: AnyPublisher<CGFloat, Never>
    @State private var scrolling: Bool = false
    
    @State private var lastValue: CGFloat = 0
    
    init() {
        self.init(onScrollingStarted: {}, onScrollingFinished: {})
    }
    
    init(
        onScrollingStarted: @escaping () -> Void,
        onScrollingFinished: @escaping () -> Void
    ) {
        self.onScrollingStarted = onScrollingStarted
        self.onScrollingFinished = onScrollingFinished
        let detector = CurrentValueSubject<CGFloat, Never>(0)
        self.publisher = detector
            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
        self.detector = detector
    }
    
    var body: some View {
        GeometryReader { g in
            Rectangle()
                .frame(width: 0, height: 0)
                .onChange(of: g.frame(in: .global).origin.y) { offset in
                    if !scrolling {
                        scrolling = true
                        onScrollingStarted()
                    }
                    detector.send(offset)
                }
                .onReceive(publisher) {
                    scrolling = false
                    
                    guard lastValue != $0 else { return }
                    lastValue = $0
                    
                    onScrollingFinished()
                }
        }
    }
    
    func onScrollingStarted(_ closure: @escaping () -> Void) -> Self {
        .init(
            onScrollingStarted: closure,
            onScrollingFinished: onScrollingFinished
        )
    }
    
    func onScrollingFinished(_ closure: @escaping () -> Void) -> Self {
        .init(
            onScrollingStarted: onScrollingStarted,
            onScrollingFinished: closure
        )
    }
}

struct menuButtonView: View {
    var label: String
    var image: String
    var color: Color
    var last: Bool
    
    var body: some View {
        VStack(spacing: 5){
            HStack{
                Image(systemName: image)
                    .font(.callout)
                Text(label)
                    .font(.callout)
                    .fontWeight(.semibold)
                Spacer()
            }
            Capsule()
                .padding(0)
                .frame(height: 0.75)
                .frame(maxWidth: .infinity)
                .foregroundColor(last ? Color.clear : Color.gray.opacity(0.5))
        }
        .foregroundColor(color)
        .frame(maxWidth: .infinity)
        .padding(.top, 10)
        .padding(.horizontal)
        .background(Color("BlackWhite").opacity(0.1))
    }
}

class KeyboardHeightHelper: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0
    
    init() {
        self.listenForKeyboardNotifications()
    }
    
    private func listenForKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidShowNotification,
                                               object: nil,
                                               queue: .main) { (notification) in
            guard let userInfo = notification.userInfo,
                  let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            
            self.keyboardHeight = keyboardRect.height
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidHideNotification,
                                               object: nil,
                                               queue: .main) { (notification) in
            self.keyboardHeight = 0
        }
    }
}


func formatToDate(time: String) -> String {
    let date = Date(timeIntervalSince1970: ((Double(time) ?? 0.0) / 1000.0))
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en-US")
    var prefix = ""
    var affix = ""
    var suffix = " "
    if Calendar.current.isDateInToday(date){
        prefix = "**Today**"
        affix = " "
        suffix = formatAMPM(time: time)
    }else{
        if Calendar.current.isDateInYesterday(date){
            prefix = "**Yesterday**"
            affix = " "
            suffix = formatAMPM(time: time)
        }else{
            if Calendar.current.isDate(date, equalTo: .now, toGranularity: .weekdayOrdinal){
                formatter.dateFormat = "EEEE"
                prefix = "**\(formatter.string(from: date))**"
                affix = " "
                suffix = formatAMPM(time: time)
            }else{
                if Calendar.current.isDate(date, equalTo: .now, toGranularity: .year) {
                    formatter.dateFormat = "EE, MMM dd"
                    prefix = "**\(formatter.string(from: date))**"
                    affix = " at "
                    suffix = formatAMPM(time: time)
                }else{
                    formatter.dateFormat = "MMM dd, yyyy"
                    prefix = "**\(formatter.string(from: date))**"
                    affix = " at "
                    suffix = formatAMPM(time: time)
                }
            }
        }
    }
    return "\(prefix)\(affix)\(suffix)"
}
