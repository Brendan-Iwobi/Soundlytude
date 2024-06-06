//
//  messegesView.swift
//  Soundlytude
//
//  Created by DJ bon26 on 11/1/22.
//

import SwiftUI

var messagePageFetchingCompleted: Bool = false
var pauseFetchingChats: Bool = false

struct messagesView: View {
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @EnvironmentObject var GlobalVariables: globalVariables
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var MessengerData = messagesPageFetchChatsData()
    @State private var searchText = ""
    @State private var searchNewChat = ""
    @State var isDoneLoading: Bool = false
    @State private var isFiltering: Bool = false
    @State private var showCreateChatView: Bool = false
    
    @State var showChatView: Bool = false
    @State var linkChatView: AnyView = AnyView(EmptyView())
    
    @State var backgroundHighlight: Double = 1
    
    @State private var selectedChat: messagesPageFetchChatsField?
    
    var filteredMessenger: [messagesPageFetchChatsField] {
        if searchText ==
            "" {return MessengerData.messagesPageFetchChatsFields}
        return MessengerData.messagesPageFetchChatsFields.filter {
            $0.otherMemberDetails.artistName.localizedCaseInsensitiveContains(searchText.localizedLowercase)
        }
    }
    
    @GestureState var press = false
    
    //"verified" replaces if there's a new chat
    var body: some View {
        NavigationView {
            ZStack{
                if isDoneLoading {
                    List{
                        if MessengerData.messagesPageFetchChatsFields.count > 0{
                            if isFiltering{
                                ProgressView()
                                    .listRowSeparator(.hidden)
                            }else{
                                listView()
                            }
                            if filteredMessenger.count < 1 && searchText != ""{
                                noItemsView(title: "No Messages found", message: "Try searching with a different keyword")
                            }
                        } else {
                            noItemsView(title: "No chats", message: "When you have a conversation, they'll appear here")
                        }
                        bottomSpace()
                            .listRowSeparator(.hidden)
                    }
                    .listStyle(PlainListStyle())
                    .onAppear{
                        Task {
                            do {
                                await refreshLiveChats()
                            }catch{
                                //
                            }
                        }
                    }
                } else {
                    VStack{
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.accentColor))
                            .onAppear{
                                messagePageFetchingCompleted = false
                                progresser()
                                MessengerData.fetch()
                            }
                    }
                }
            }
//            .alert(presentAlertTitle, isPresented: $presentAlert, actions: {
//                Button("OK", role: .cancel, action: {})
//            }, message: {
//                Text(presentAlertMessage)
//            })
            .fullScreenCover(isPresented: $showCreateChatView, onDismiss: onDismissFullscreenCover) {
                createChatView()
                    .alert(presentAlertTitle, isPresented: $presentAlert, actions: {
                        Button("OK", role: .cancel, action: {})
                    }, message: {
                        Text(presentAlertMessage)
                    })
            }
            .searchable(text: $searchText.onChange(onSearchChange), placement: .navigationBarDrawer(displayMode: .automatic), prompt: "Search Messages")
            .navigationTitle("Chats")
            .toolbar {
                Button {
                    pauseFetchingChats = true
                    showCreateChatView = true
                } label: {
                    Image(systemName: "square.and.pencil")
                    Text("Create chat")
                }
            }
        }
    }
    
    func onDismissFullscreenCover() {
        pauseFetchingChats = false
    }
    
    var selectableMembersLimit = 10
    
    @State var createChatGroupName: String = ""
    
    @State private var presentAlert = false
    @State private var presentAlertTitle = ""
    @State private var presentAlertMessage = ""
    @State private var showImage = true
    
    @State private var createChatSelectedMembers: [createChatSelectedMembersField] = []
    @State private var createChatSelectedMembersId: Array<String> = []
    
    @State var disableAllButtons: Bool = false
    var createChatDisableButton: Bool {
        if createChatSelectedMembers.count < 1 || createChatSelectedMembers.count > selectableMembersLimit || disableAllButtons{
            return true
        }else {
            return false
        }
    }
    @State var createChatPage: Int = 1
    @State var createChatFinishView: AnyView = AnyView(VStack{Spacer();ProgressView();Spacer()})
    @State var createChatNavigationHeight: Double = 0.0
    @FocusState var searchBarFocus: Bool
    var searchBar: some View {
        HStack {
            HStack{
                Image(systemName: "magnifyingglass").foregroundColor(.gray)
                TextField("Search by nickname and username", text: $searchNewChat)
                    .focused($searchBarFocus)
                    .submitLabel(.search)
                    .onSubmit(of: .text, runSearch)
                    .font(Font.system(size: 18))
            }
            .padding(7)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            if searchBarFocus {
                Spacer()
                Button {
                    searchNewChat = ""
                    searchBarFocus = false
                } label: {
                    Text("Cancel")
                }
                .transition(AnyTransition.opacity.combined(with: .move(edge: .trailing)))
            }
        }
        .animation(.spring(), value: searchBarFocus)
    }
    
    @ViewBuilder
    func listView() -> some View {
        ForEach(0..<filteredMessenger.count, id: \.self){ i in
            let x = filteredMessenger[i].otherMemberDetails
            let y = filteredMessenger[i]
            
            let filteredReadBy = y.readBy.filter { word in
                return word._id == soundlytudeUserId()
            }
//            let filteredReadBy = []
            
            let themeColorMix: Color = Color(UIColor.blend(color1: UIColor(Color(hexStringToUIColor(hex: "#\(x.themeColor?.replacingOccurrences(of: "#", with: "") ?? "")"))), intensity1: 0.8, color2: UIColor(colorScheme == .dark ? Color.white : Color.black), intensity2: 0.2))
            let designView = HStack{
                SBlueDot(scale: 10, color: (filteredReadBy.count > 0) ? Color.clear : y.lastSentAction ?? "" == "" ? Color.red : Color.accentColor)
                    .padding(0)
                circleImage40by40(urlString: x.pimage)
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y:0)
                VStack(alignment: .leading){
                    HStack(spacing: 2.5){
                        Text(x.artistName)
                            .fontWeight(.bold)
                            .foregroundColor((x.verification ?? false) ? themeColorMix : nil)
                        if x.verification ?? false {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption)
                                .foregroundColor(themeColorMix)
                        }
                        Spacer()
                        Text(formatToDateStyle2(time: y.lastSentTime))
                            .foregroundColor(.gray)
                            .font(.system(size: 15))
                        Text("\(Image(systemName: "chevron.right"))")
                            .fontWeight(.bold)
                            .font(.system(size: 14))
                            .foregroundColor(Color.gray)
                            .padding(.trailing, 15)
                    }
                    if y.lastSentAction! != "" {
                        Text(y.lastSentAction ?? "Say hello")
                            .foregroundColor(.gray)
                            .font(.footnote)
                            .lineLimit(2)
                            .padding(.trailing, 15)
                        Spacer()
                    }
                }
            }
                .padding(.horizontal,5)
            
            let deleteAction = UIAction(
                title: "Remove rating",
                image: UIImage(systemName: "delete.left"),
                identifier: nil,
                attributes: UIMenuElement.Attributes.destructive, handler: {_ in print("Foo")})
            HStack{
                //                                            self.selectedChat = y
                if #available(iOS 16.0, *) {
                    designView
                        .contextMenu{
                            //ContextMenu stuff here
                            //Such as buttons
                            Button {
                                //
                            } label: {
                                HStack{
                                    Text(filteredReadBy.count > 0 ? "Open Messages" : "Read Messages")
                                    Image(systemName: (filteredReadBy.count > 0) ? "envelope.open" : "book")
                                }
                            }
                            
                            Button {
                            } label: {
                                HStack{
                                    Text(filteredReadBy.count > 0 ? "Hide alert" : "Show alert")
                                    Image(systemName: filteredReadBy.count > 0 ? "bell.slash" : "bell")
                                }
                            }
                            Button(role: .destructive) {
                            } label: {
                                HStack{
                                    Text("Delete")
                                    Image(systemName: "trash")
                                }
                            }
                        } preview: {
                            NavigationStack{
                                chatView2(chatId: y._id, artistId: x._id, artistPfp: x.pimage, artistName: x.artistName, artistVerification: x.verification ?? false, chatOnly: true, chatDetails: [y])
                                    .environmentObject(GlobalVariables)
                                    .navigationBarBackButtonHidden(true)
                            }
                        }
                }else{
                    designView
                        .contextMenu(PreviewContextMenu(destination: chatView2(chatId: y._id, artistId: x._id, artistPfp: x.pimage, artistName: x.artistName, artistVerification: x.verification ?? false, chatOnly: true, chatDetails: [y])
                            .environmentObject(GlobalVariables)
                            .navigationBarBackButtonHidden(true), actionProvider: { items in
                                return UIMenu(title: "My Menu", children: [deleteAction])
                            }))
                }
            }
//            .fullScreenCover(isPresented: $showChatView, onDismiss: onDismissFullscreenCover) {
//                GlobalVariables.chatView
//            }
            .frame(width: viewableWidth)
            .background(
                NavigationLink(destination: GlobalVariables.chatView, isActive: $showChatView) {
                    EmptyView()
                }
                    .hidden()
            )
            .background(
                
                Button{
                    GlobalVariables.chatView = AnyView(chatView2(chatId: y._id, artistId: x._id, artistPfp: x.pimage, artistName: x.artistName, artistVerification: x.verification ?? false, chatDetails: [y]).environmentObject(GlobalVariables).navigationBarBackButtonHidden(true))
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                        showChatView = true
                    }
                } label: {
                    EmptyView()
                }
            )
        }
    }
    func createChatView() -> some View {
        ZStack(alignment: .top){
            VStack{
                VStack(spacing: 0){
                    createChatViewToolbarButtons()
                    searchBar.padding([.horizontal, .bottom])
                    createChatViewSelectedMembers()
                }
                .overlay(
                    GeometryReader { geo in
                        Text("")
                            .onAppear{
                                withAnimation(.spring()){
                                    createChatNavigationHeight = geo.size.height
                                }
                            }
                            .onChange(of: geo.size) { newSize in
                                withAnimation(.spring()){
                                    createChatNavigationHeight = geo.size.height
                                    print(geo.size.height, newSize)
                                }
                                
                            }
                    }
                )
                .background(.ultraThinMaterial)
            }.zIndex(1)
            if createChatPage == 1 {
                ScrollView{
                    Spacer().frame(height: createChatNavigationHeight)
                    createChatViewSearchedMembers()
                }
            }
            if createChatPage == 2 {
                createChatFinishView
            }
        }.animation(.spring(), value: createChatPage)
    }
    
//    @ViewBuilder
//    func createChatView() -> some View {
////        ScrollView{
//            VStack(spacing: 0){
//                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]){
//                    Section {
//                        if createChatPage == 1 {
//                            createChatViewSearchedMembers()
//                        }
//                        if createChatPage == 2 {
//                            VStack{
//                                createChatFinishView
//                                    .frame(height: UIScreen.main.bounds.height)
////                                    .ignoresSafeArea(edges: .bottom)
//                            }
//                        }
//                    } header: {
//                        VStack(spacing: 0){
//                            createChatViewToolbarButtons()
//                            searchBar.padding([.horizontal, .bottom])
//                            createChatViewSelectedMembers()
//                        }
//                        .background(.ultraThinMaterial)
//                    }
//                }
//            }
////        }
//    }
    
    @ViewBuilder
    func createChatViewSelectedMembers() -> some View {
        VStack(alignment: .leading, spacing: 0){
            if createChatSelectedMembers.count > 0{
                ScrollView(.horizontal){
                    HStack(spacing: 0){
                        ForEach(0..<createChatSelectedMembers.count, id: \.self){ i in
                            let x = createChatSelectedMembers[i]
                            VStack{
                                ZStack(alignment: .topTrailing){
//                                    if showImage {
//                                        circleImageCustomSize(urlString: x.pimage, resolution: 50, multiply: 2)
//                                    }else{
//                                        circleImageCustomSize(urlString: x.pimage, resolution: 50, multiply: 2)
//                                    }
                                    circleImageCustomSize(urlString: x.pimage, resolution: 50, multiply: 2)
                                    if createChatPage == 1{
                                        Button {
                                            createChatRemoveSelectedMember(id: x._id)
                                        } label: {
                                            Image(systemName: "xmark")
                                                .font(.caption)
                                                .foregroundColor(.white)
                                                .padding(5)
                                        }
                                        .background(Color.gray)
                                        .cornerRadius(10)
                                        .offset(x: 5, y: -5)
                                    }
                                }
                                Text(x.artistName)
                                    .font(.caption)
                                    .lineLimit(1)
                            }
                            .padding(1)
                            .frame(width: 75)
                        }
                        Spacer()
                    }
                    .padding()
                }
            }
            HStack{
                Image(systemName: "exclamationmark.bubble")
                Text("You can only create a chat your friends")
            }
            .font(.footnote)
            .padding([.horizontal, .bottom])
            Capsule()
                .frame(height: 0.75)
                .foregroundColor(Color.gray.opacity(0.5))
        }
    }
    
    @State var createChatTimeout: Int = 0
    @ViewBuilder
    func createChatViewToolbarButtons() -> some View {
        let title = VStack{
            Text("Add participant(s)")
                .fontWeight(.bold)
            Text("\(createChatSelectedMembers.count) of \(selectableMembersLimit)")
                .font(.footnote)
                .foregroundColor((createChatSelectedMembers.count < selectableMembersLimit + 1) ? Color("BlackWhite") : Color.red)
        }.padding(.vertical)
        VStack(spacing: 0){
            if createChatPage == 1 {
                HStack{
                    Button(role: .destructive) {
                        createChatSelectedMembers = []
                        CreateChatFetchData.createChatFetchDataFields = []
                        showCreateChatView = false
                        pauseFetchingChats = false
                    } label: {
                        Text("Cancel")
                            .fontWeight(.bold)
                    }
                    .padding([.horizontal, .top])
                    Spacer()
                    title
                    Spacer()
                    Button {
                        if createChatTimeout < 1{
                            createChatPage = 2
                            getChatId()
                        }
                    } label: {
                        ZStack{
                            Text("Next")
                                .fontWeight(.bold)
                            if createChatTimeout > 0{
                                ProgressView()
                            }
                        }
                    }
                    .disabled(createChatDisableButton)
                    .padding([.horizontal, .top])
                }
            }
            if createChatPage == 2 {
                HStack{
                    Button(role: .cancel) {
                        createChatPage = 1
                        createChatFinishView = AnyView(VStack{Spacer();ProgressView();Spacer()})
                    } label: {
                        Text("Back")
                            .fontWeight(.bold)
                    }
                    .disabled(createChatDisableButton)
                    .padding([.horizontal, .top])
                    Spacer()
                    title
                    Spacer()
                    Button {
                        createChat()
                    } label: {
                        Text("Finish")
                            .fontWeight(.bold)
                    }
                    .disabled(createChatDisableButton)
                    .padding([.horizontal, .top])
                }
            }
        }
    }
    
    @ViewBuilder
    func createChatViewSearchedMembers() -> some View {
        if CreateChatFetchData.createChatFetchDataFields.count > 0{
            VStack(spacing: 0){
                ForEach(0..<CreateChatFetchData.createChatFetchDataFields.count, id: \.self){ i in
                    let x = CreateChatFetchData.createChatFetchDataFields[i]
                    let friends: Bool = x.following.contains(soundlytudeUserId()) && x.Members.contains(soundlytudeUserId())
//                    let friends: Bool = true
                    let youFollowThem: Bool = x.Members.contains(soundlytudeUserId())
                    let theyFollowYou: Bool = x.following.contains(soundlytudeUserId())
                    
                    let themeColorMix: Color = Color(UIColor.blend(color1: UIColor(Color(hexStringToUIColor(hex: "#\(x.themeColor?.replacingOccurrences(of: "#", with: "") ?? "")"))), intensity1: 0.8, color2: UIColor(colorScheme == .dark ? Color.white : Color.black), intensity2: 0.2))
                    
                    Button {
                        if ifContainsSelected(id: x._id){
                            createChatRemoveSelectedMember(id: x._id)
                        }else{
                            withAnimation(.easeIn(duration: 0.1)){
                                createChatSelectedMembers.append(createChatSelectedMembersField(_id: x._id, artistName: x.artistName, pimage: x.pimage))
                                createChatSelectedMembersId.append(x._id)
                                showImage.toggle()
                            }
                        }
                    } label: {
                        HStack{
                            if showImage {
                                circleImage40by40(urlString: x.pimage)
                            }else{
                                //                                    Color.clear.frame(width: 40, height: 40)
                                circleImage40by40(urlString: x.pimage)
                            }
                            VStack(alignment: .leading){
                                HStack{
                                    Text(x.artistName)
                                        .fontWeight(.bold)
                                        .foregroundColor(x.verification ?? false ? themeColorMix : nil)
                                    if (x.verification ?? false) {
                                        Image(systemName: "checkmark.seal.fill")
                                            .font(.caption)
                                            .foregroundColor(themeColorMix)
                                    }
                                }
                                Text("@\(x.slug)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            HStack{
                                Sticker(text: friends ? "Friends" : youFollowThem ? "You follow them" : theyFollowYou ? "Follows you" : "")
                                Image(systemName: ifContainsSelected(id: x._id) ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(Color.accentColor)
                            }
                        }
                        .padding([.horizontal, .vertical])
                        .foregroundColor(Color("BlackWhite"))
                    }
                    .padding(0)
                    .opacity(friends ? 1 : 0.5)
                    .background(friends ? Color.clear : Color.gray.opacity(0.075))
                    .disabled(friends ? false : true)
                    //                .cornerRadius(5)
                }
            }
        }else{
            VStack{
                Spacer().frame(height: 100)
                noItemsView(title: "Nothing...", message: "Make a smart search")
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    func createChatInputView() -> some View {
        VStack{//chatInput
            Spacer()
            VStack(spacing: 0){
                Divider().padding(0)
                HStack(alignment: .bottom) {
                    Text("Message")
                }
                .padding(10)
            }
            .transition(AnyTransition.move(edge: .bottom))
            .background((colorScheme == .dark) ? .thinMaterial : .regular)
            Spacer().frame(height: 0)
        }
        .frame(width: viewableWidth)
    }
    
    @StateObject var CreateChatFetchData = createChatFetchData()
    func runSearch() {
        Task{
            do {
                try await CreateChatFetchData.search(value: searchNewChat.replacingOccurrences(of: "’", with: "").replacingOccurrences(of: " ", with: "-").replacingOccurrences(of: "'", with: "").lowercased())
                withAnimation(.easeInOut(duration: 0.1)){
                    showImage.toggle()
                }
            }catch{
                print("error")
            }
        }
    }
    
    func setTimeout(){
        createChatTimeout = createChatTimeout - 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if createChatTimeout > 0{
                setTimeout()
            }
        }
    }
    
    func ifContainsSelected(id: String) -> Bool {
        let filtered = createChatSelectedMembers.filter { member in
            return member._id == id
        }
        if filtered.count > 0 {
            return true
        }else{
            return false
        }
    }
    
    func createChatRemoveSelectedMember(id: String){
        let filtered = createChatSelectedMembers.filter { member in
            return member._id == id
        }
        withAnimation(.easeInOut(duration: 0.1)){
            let indexToRemove = createChatSelectedMembers.firstIndex(of: filtered[0])
            let indexToRemoveId = createChatSelectedMembersId.firstIndex(of: id)
            createChatSelectedMembers.remove(at: indexToRemove ?? 0)
            createChatSelectedMembersId.remove(at: indexToRemoveId ?? 0)
            showImage.toggle()
        }
    }
    
    func getChatId(){
        let id = "\(createChatSelectedMembersId.joined(separator: ",")),\(soundlytudeUserId())"
        guard let url = URL(string: HttpBaseUrl() + "/_functions/ifChatExists?password=wc41jsrt7OAaSNH1QqE3&id=\(id)&currentUserId=\(soundlytudeUserId())") else {
            print("Error: cannot create URL")
            return
        }
        // Create the url request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                presentAlert = true
                presentAlertTitle = "WARNING"
                presentAlertMessage = "There was an error proceeding. Failed to send a request"
//                createChatPage = 1
                print(error!)
                return
            }
            guard let data = data else {
                presentAlert = true
                presentAlertTitle = "WARNING"
                presentAlertMessage = "There was an error proceeding. Did not recieve a response from server"
//                createChatPage = 1
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                presentAlert = true
                presentAlertTitle = "WARNING"
                presentAlertMessage = "There was an error proceeding. Request failed"
//                createChatPage = 1
                print("Error: HTTP request failed")
                return
            }
            do {
                let data = try JSONDecoder().decode (ifChatExistsField.self, from: data)
                print(data)
                if data.existingChat {
                    createChatFinishView = AnyView(
                        ZStack(alignment: .bottom){
                            chatView2(gapBeforeMessages: createChatNavigationHeight - 30, chatId: data.chatId, artistId: "", artistPfp: "", artistName: "", artistVerification: false, chatOnly: true, chatDetails: [data.chatDetails!])
                            createChatInputView()
                                .transition(AnyTransition.move(edge: .bottom))
                        }
                        )
                }else{
                    if createChatSelectedMembers.count > 1 {
                        createChatFinishView = AnyView(
                            VStack(alignment: .leading) {
                                Spacer().frame(height: createChatNavigationHeight)
                                HStack{
                                    Text("Group name:").foregroundColor(.gray)
                                    TextField("Eg. Messi vs. Ronaldo war", text: $createChatGroupName)
                                        .submitLabel(.done)
                                        .font(Font.system(size: 18))
                                }
                                .padding(7)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                                Spacer()
                            }.padding()
                        )
                    }else{
                        createChatFinishView = AnyView(
                            VStack(alignment: .leading) {
                                Spacer().frame(height: createChatNavigationHeight)
                                Button {
                                    showCreateChatView = false
                                } label: {
                                    Text("Confirm")
                                }
                                Spacer()
                            }.padding()
                        )
                    }
                }
                createChatTimeout = 6
                setTimeout()
            } catch {
                print(url)
                print(error)
                presentAlert = true
                presentAlertTitle = "WARNING"
                presentAlertMessage = "There was an error proceeding"
                createChatPage = 1
                return
            }
        }.resume()
    }
    
    func createChat(){
        disableAllButtons = true
        var membersId = createChatSelectedMembersId
        membersId.append(soundlytudeUserId())
        guard let url = URL(string: HttpBaseUrl() + "/_functions/newChat?password=rowMn8Kjj6E7OP88CUNW") else {
            print("Error: cannot create URL")
            return
        }
        struct UploadData: Codable {
            let sender: String
            let type: String
            let membersId: Array<String>
        }
        
        // Add data to the model
        let uploadDataModel = UploadData(sender: soundlytudeUserId(), type: createChatSelectedMembersId.count > 1 ? "Group" : "Direct", membersId: membersId)
        
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
                presentAlert = true
                presentAlertTitle = "WARNING"
                presentAlertMessage = "There was an error proceeding. Failed to send a request"
                createChatPage = 1
                print(error!)
                return
            }
            guard let data = data else {
                presentAlert = true
                presentAlertTitle = "WARNING"
                presentAlertMessage = "There was an error proceeding. Did not recieve a response from server"
                createChatPage = 1
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                presentAlert = true
                presentAlertTitle = "WARNING"
                presentAlertMessage = "There was an error proceeding. Request failed"
                createChatPage = 1
                print("Error: HTTP request failed")
                return
            }
            do {
                let data = try JSONDecoder().decode (createChatField.self, from: data)
                print(data.chatId)
                disableAllButtons = false
                showCreateChatView = false
            } catch {
                presentAlert = true
                presentAlertTitle = "WARNING"
                presentAlertMessage = "There was an error proceeding"
                createChatPage = 1
                return
            }
        }.resume()
    }
//    func createChatSendMessage(type: String, receiver:String, text: String, imageURI: String, chatId: String, localMsgId: String) {
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
//                MessengerData.fetchLiveUpdate(chatId: chatId, artistId: artistId, currentChats: MessengerData.messengerPageFetchMessagesFields)
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
    
    func progresser() {
        if(messagePageFetchingCompleted){
            isDoneLoading = true
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                progresser()
                if (messagePageFetchingCompleted == false){
                    isDoneLoading = false
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
    
    func refreshLiveChats() async {
        try? await Task.sleep(nanoseconds: 7_500_000_000)
        print("refreshing")
        Task {
            do {
                if !pauseFetchingChats {
                    MessengerData.fetchUpdate(currentChats: MessengerData.messagesPageFetchChatsFields)
                }
                await refreshLiveChats()
            }catch{
                await refreshLiveChats()
            }
        }
    }
}

struct messagesView_Previews: PreviewProvider {
    static var previews: some View {
        messagesView()
    }
}

struct ifChatExistsField: Hashable, Codable {
    let existingChat: Bool
    let chatId: String
    let chatDetails: messagesPageFetchChatsField?
}

struct createChatField: Hashable, Codable {
    let chatId: String
}

func formatAMPM(time: String) -> String { //03:32 PM
    let date = Date(timeIntervalSince1970: ((Double(time) ?? 0.0) / 1000.0))
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en-US")
    formatter.dateFormat = "hh:mm a"
    let time12 = formatter.string(from: date)
    return time12
}

func formatToDateStyle2(time: String) -> String { //Yesterday or Thursday or 05/16/05
    let date = Date(timeIntervalSince1970: ((Double(time) ?? 0.0) / 1000.0))
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en-US")
    var prefix = ""
    if Calendar.current.isDateInToday(date){
        prefix = formatAMPM(time: time)
    }else{
        if Calendar.current.isDateInYesterday(date){
            prefix = "Yesterday"
        }else{
            if Calendar.current.isDate(date, equalTo: .now, toGranularity: .weekdayOrdinal){
                formatter.dateFormat = "EEEE"
                prefix = "\(formatter.string(from: date))"
            }else{
                formatter.dateFormat = "MM/dd/yy"
                prefix = "\(formatter.string(from: date))"
            }
        }
    }
    return "\(prefix)"
}

func formatToFullDateStyle(time: String) -> String { //Thursday, June 20, 2022
    let date = Date(timeIntervalSince1970: ((Double(time) ?? 0.0) / 1000.0))
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en-US")
    var prefix = ""
    
    formatter.dateFormat = "EEEE, MMMM d, YYYY" //thursday,
    prefix = "\(formatter.string(from: date))"
    return "\(prefix)"
}

struct creatorReferenceArtist: Hashable, Codable {
    let _id: String
    let artistName: String
    let slug: String
    let pimage: String
    let verification: Bool?
}

struct readByReferenceArtist: Hashable, Codable {
    let _id: String
    let artistName: String
    let slug: String
    let pimage: String
    let verification: Bool?
}
struct readByReferenceInfo: Hashable, Codable {
    let _id: String
    let time: String
}

struct membersReferenceArtist: Hashable, Codable {
    let _id: String
    let artistName: String
    let slug: String
    let pimage: String
    let verification: Bool?
}

struct isTypingArtist: Hashable, Codable {
    let _id: String
    let artistName: String
    let slug: String
    let pimage: String
    let verification: Bool?
}

struct otherMemberDetailsArtist: Hashable, Codable {
    let _id: String
    let artistName: String
    let slug: String
    let pimage: String
    let verification: Bool?
    let themeColor: String?
}

struct messagesPageFetchChatsField: Hashable, Codable {
    let _id: String
    let creator: String?
    let creatorReference: creatorReferenceArtist?
    let lastSentAction: String?
    let type: String
    let readBy: [readByReferenceInfo]
    let readByReference: [readByReferenceArtist]?
    let membersId: [String]
    let membersReference: [membersReferenceArtist]
    let isTyping: isTypingArtist?
    let lastSentTime: String
    let otherMemberDetails: otherMemberDetailsArtist
}

struct messagesPageFetchChatsUpdate: Hashable, Codable {
    let noChanges: Bool
    let data: [messagesPageFetchChatsField]
}

//struct messagesPageFetchChatsField: Hashable, Codable {
//    let _id: String
//    let artistName: String
//    let slug: String
//    let email: String?
//    let age: String?
//    let pimage: String
//    let label: String?
//    let genre: String?
//    let verification: Bool?
//    let verified: Bool
//}


//class messagesPageFetchMesssengerData: ObservableObject {
//    @Published var messagesPageFetchChatsFields: [messagesPageFetchChatsField] = []
//    @Published var count = 0
//
//    func fetchUpdate() {
//        messagePageFetchingCompleted = false
//        guard let url = URL(string: HttpBaseUrl() + "/_functions/messenger?password=VLRpufzJLNs6GLth64LH&currentUserId=\(soundlytudeUserId())&continueFrom=\(count)") else {
//            return}
//        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _,
//            error in
//            guard let data = data, error == nil else {
//                return
//            }
//            // Convert to JSON
//            do
//            {
//                let data = try JSONDecoder().decode ([messagesPageFetchChatsField].self, from: data)
//                DispatchQueue.main.async{
//                    self?.messagesPageFetchChatsFields = self!.messagesPageFetchChatsFields + data
//                    self?.count += 10
//                    messagePageFetchingCompleted = true
//                }
//            }
//            catch {
//                print(error)
//            }
//        }
//        task.resume()
//    }
//}

//    .contextMenu(navigate: {
//                                            chatView(artistId: x._id, artistPfp: x.pimage, artistName: x.artistName, artistVerification: x.verification ?? false).navigationBarBackButtonHidden(true).opacity(0) //User tapped the preview
//                                        }) {
//                                            chatView(artistId: x._id, artistPfp: x.pimage, artistName: x.artistName, artistVerification: x.verification ?? false, chatOnly: true)
//                                                .navigationBarBackButtonHidden(true)
//                                                .onAppear{
//                                                    print("hange color back")
//                                                }//Preview
//                                        }menu: {
//                                            let openUrl = UIAction(title: "Delete", image: UIImage(systemName: "trash")) { _ in
//                                                withAnimation() {
//                                                    print("Open")
//                                                }
//                                            }
//                                            let menu = UIMenu(title: "Menu", image: nil, identifier: nil, options: .displayInline, children: [openUrl]) //Menu
//                                            return menu
//                                        }

class messagesPageFetchChatsData: ObservableObject {
    @Published var messagesPageFetchChatsFields: [messagesPageFetchChatsField] = []
    
    func fetch() {
        messagePageFetchingCompleted = false
        guard let url = URL(string: HttpBaseUrl() + "/_functions/chats?password=p35lccba0QuWyH4IT51w&currentUserId=\(soundlytudeUserId())&sort=sortDescending&columnSortId=lastSentTime") else {
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
                let data = try JSONDecoder().decode ([messagesPageFetchChatsField].self, from: data)
                DispatchQueue.main.async{
                    self?.messagesPageFetchChatsFields = data
                    messagePageFetchingCompleted = true
                }
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }
    
    func fetchUpdate(currentChats: [messagesPageFetchChatsField]) {
        pauseFetchingChats = true
        guard let url = URL(string: HttpBaseUrl() + "/_functions/updateChats?password=obMcr9M81guH7XZST24N&currentUserId=\(soundlytudeUserId())&sort=sortDescending&columnSortId=lastSentTime") else {
            print("Error: cannot create URL")
            return
        }
        
        // Create model
        struct UploadData: Codable {
            let currentChats: [messagesPageFetchChatsField]
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
                let data = try JSONDecoder().decode (messagesPageFetchChatsUpdate.self, from: data)
                DispatchQueue.main.async{
                    if !data.noChanges { //if there was a change
                        self.messagesPageFetchChatsFields = data.data
                    }
                    messagePageFetchingCompleted = true
                    pauseFetchingChats = false
//                    refreshLiveChats()
                }
            }
            catch {
                print(error)
            }
        }.resume()
    }
}




// MARK: - Custom Menu Context Implementation
struct PreviewContextMenu<Content: View> {
    let destination: Content
    let actionProvider: UIContextMenuActionProvider?
    
    init(destination: Content, actionProvider: UIContextMenuActionProvider? = nil) {
        self.destination = destination
        self.actionProvider = actionProvider
    }
}

// UIView wrapper with UIContextMenuInteraction
struct PreviewContextView<Content: View>: UIViewRepresentable {
    
    let menu: PreviewContextMenu<Content>
    let didCommitView: () -> Void
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        let menuInteraction = UIContextMenuInteraction(delegate: context.coordinator)
        view.addInteraction(menuInteraction)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(menu: self.menu, didCommitView: self.didCommitView)
    }
    
    class Coordinator: NSObject, UIContextMenuInteractionDelegate {
        
        let menu: PreviewContextMenu<Content>
        let didCommitView: () -> Void
        
        init(menu: PreviewContextMenu<Content>, didCommitView: @escaping () -> Void) {
            self.menu = menu
            self.didCommitView = didCommitView
        }
        
        func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
            return UIContextMenuConfiguration(identifier: nil, previewProvider: { () -> UIViewController? in
                UIHostingController(rootView: self.menu.destination)
            }, actionProvider: self.menu.actionProvider)
        }
        
        func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
            animator.addCompletion(self.didCommitView)
        }
        
    }
}

// Add context menu modifier
extension View {
    func contextMenu<Content: View>(_ menu: PreviewContextMenu<Content>) -> some View {
        self.modifier(PreviewContextViewModifier(menu: menu))
    }
}

struct PreviewContextViewModifier<V: View>: ViewModifier {
    
    let menu: PreviewContextMenu<V>
    @Environment(\.presentationMode) var mode
    
    @State var isActive: Bool = false
    
    func body(content: Content) -> some View {
        Group {
            if isActive {
                menu.destination
            } else {
                content.overlay(PreviewContextView(menu: menu, didCommitView: { self.isActive = true }))
            }
        }
    }
}

struct createChatFetchDataField: Hashable, Codable {
    let _id: String
    let artistName: String
    let slug: String
    let pimage: String
    let verification: Bool?
    let themeColor: String?
    let following: [String]
    let Members: [String]
}

struct createChatSelectedMembersField: Hashable, Codable {
    let _id: String
    let artistName: String
    let pimage: String
}

class createChatFetchData: ObservableObject {
    @Published var createChatFetchDataFields: [createChatFetchDataField] = []
    
    func search(value: String) async throws  {
        FYPFetchingCompleted = false
        guard let url = URL(string: HttpBaseUrl() + "/_functions/friendsArtist?password=p35lccba0QuWyH4IT51w&type=filterEqNot&value=\(value)&limit=20&currentUserId=\(soundlytudeUserId())") else {
            return}
        print(url)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { print(response); return}
        let decodedData = try JSONDecoder().decode ([createChatFetchDataField].self,
                                             from: data)
        DispatchQueue.main.async{
            self.createChatFetchDataFields = decodedData
            print("done searching")
        }
    
    }
}
