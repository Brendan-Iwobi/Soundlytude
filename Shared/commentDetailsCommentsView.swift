////
////  commentDetailsCommentsView.swift
////  Soundlytude (iOS)
////
////  Created by DJ bon26 on 11/19/22.
////
//
//import SwiftUI
//
//private var replyCommentsPageFetchingCompleted = false
//
//struct commentDetailsCommentsView: View {
//    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
//    @Environment(\.colorScheme) var colorScheme
//    
//    @StateObject var replyCommentsPageFetch = replyCommentsPageFetchReplies()
//    
//    var commentId: String = "f162c63e-526b-45f8-b400-7352e32e6dd5"
//    var replyCount: Int = 0
//    var commentSlug: String = ""
//    var commentPfp: String = ""
//    var commentVerification: Bool = false
//    var commentComment: String = ""
//    var commentDate: String = ""
//    var commentArtistId: String = ""
//    var replying: Bool = false
//    
//    @FocusState var commentInputFocused: Bool
//    
//    @State var isDoneLoading: Bool = false
//    @State private var presentAlert = false
//    @State private var alertMessage = ""
//    @State private var alertTitle = ""
//    
//    @State private var commentText:String = ""
//    @State var textEditorHeight : CGFloat = 20
//    var emojis: Array<String> = ["🔥","🥰","🎵","💓","😮","💨","😮‍💨","⛽"]
//    var body: some View {
//        if isDoneLoading {
//            ZStack{
//                VStack{
//                    List(){
//                        ForEach(replyCommentsPageFetch.replyCommentPageFields, id: \._id) { i in
//                            replyCommentView(
//                                _id: i._id,
//                                slug: i.artistDetails.artistName,
//                                pfp: i.artistDetails.pimage,
//                                verification: i.artistDetails.verification ?? false,
//                                comment: i.richComment,
//                                date: i._createdDate,
//                                artistId: i.artistDetails._id, title: "",
//                                likes: i.likes ?? [],
//                                albumId: i.albumId,
//                                ownerId: i.ownerId
//                            )
//                        }
//                        .listRowSeparator(.hidden)
//                        .listRowInsets(EdgeInsets())
//                    }.listStyle(PlainListStyle())
//                }
//                VStack{
//                    Spacer()
//                    VStack(spacing: 0){
//                        Divider().padding(0)
//                        HStack{
//                            ForEach(emojis, id: \.self){i in
//                                Spacer()
//                                Text(i)
//                                    .font(.system(size: 30))
//                                    .padding(.vertical, 5)
//                                    .onTapGesture {
//                                        commentText = commentText + i
//                                    }
//                                Spacer()
//                            }
//                        }
//                        HStack(alignment: .bottom) {
//                            circleImage40by40(urlString: local.string(forKey: "currentUserArtistPfp") ?? "")
//                            ZStack(alignment: .leading) {
//                                Text(commentText)
//                                    .foregroundColor(.clear)
//                                    .padding(10)
//                                    .background(GeometryReader {
//                                        Color.clear.preference(key: ViewHeightKey3.self,
//                                                               value: $0.frame(in: .local).size.height)
//                                    })
//                                    .lineLimit(5)
//                                ZStack(alignment: .leading){
//                                    if #available(iOS 16.0, *) {
//                                        TextEditor(text:$commentText)
//                                            .frame(maxHeight: max(40,textEditorHeight))
//                                            .customTextField(color: .accentColor, padding: 5, lineWidth: 1)
//                                            .focused($commentInputFocused)
//                                            .scrollContentBackground(Visibility.hidden)    // new technique for iOS 16
//                                    } else {
//                                        // Fallback on earlier versions
//                                        TextEditor(text:$commentText)
//                                            .frame(maxHeight: max(40,textEditorHeight))
//                                            .customTextField(color: .accentColor, padding: 5, lineWidth: 1)
//                                            .focused($commentInputFocused)
//                                    }
//                                    Text((commentText == "") ? "  Add comment..." : "")
//                                        .opacity(0.25)
//                                        .offset(y: -0.5)
//                                        .onTapGesture {
//                                            commentInputFocused = true
//                                        }
//                                }
//                            }
//                            .onPreferenceChange(ViewHeightKey3.self) {
//                                textEditorHeight = $0
//                            }
//                            Button {
//                                commentText = ""
//                            } label: {
//                                if commentText == "" {
//                                    IconButton(icon: "arrow.up", background: Color.gray.opacity(0.25))
//                                }else{
//                                    IconButton(icon: "arrow.up", background: Color.accentColor, foregroundColor: Color.white)
//                                }
//                            }
//                            .disabled((commentText == "") ? true : false)
//                        }
//                        .padding(10)
//                    }
//                    .background((colorScheme == .dark) ? .thinMaterial : .regular)
//                    .opacity((commentInputFocused) ? 1 : 0)
//                    Spacer().frame(height: 0)
//                }
//            }
//            .onAppear{
//                if replying == true {
//                    commentInputFocused = true
//                }
//            }
//            .navigationBarTitleDisplayMode(.inline)
//            .navigationTitle("\(replyCount) replies")
//            .toolbar{
//                ToolbarItem(placement: .navigation){
//                    Button {
//                        commentInputFocused = true
//                    } label: {
//                        HStack{
//                            Image(systemName: "square.and.pencil")
//                            Text("Reply")
//                        }
//                    }
//                }
//            }
//        }else{
//            VStack{
//                ProgressView()
//                    .progressViewStyle(CircularProgressViewStyle(tint: Color.accentColor))
//                    .onAppear{
//                        replyCommentsPageFetchingCompleted = false
//                        progresser()
//                        replyCommentsPageFetch.fetch(commentId: commentId)
//                    }
//            }
//            .alert(alertTitle, isPresented: $presentAlert, actions: {
//                // actions
//            }, message: {
//                Text(alertMessage)
//            })
//            .toolbar{
//                ToolbarItem(placement: .navigation){
//                    Text("Replies")
//                        .font(.headline)
//                        .fontWeight(.bold)
//                        .multilineTextAlignment(.center)
//                        .frame(width: UIScreen.main.bounds.width - 40)
//                }
//            }
//        }
//    }
//    //MARK: controls view
//    @ViewBuilder
//    func rCommentView() -> some View {
//        HStack(alignment: .top){
//            circleImage40by40(urlString: commentPfp)
//            VStack(alignment: .leading, spacing: 2.5){
//                (Text(commentSlug) + Text((commentVerification) ? " \(Image(systemName: "checkmark.seal.fill"))" : ""))
//                    .font(.footnote)
//                    .fontWeight(.bold)
//                Text(commentComment)
//                    .font(.body)
//                    .fontWeight(.regular)
//                Text(commentDate)
//                    .font(.footnote)
//                    .foregroundColor(Color.gray)
//            }
//            Spacer()
//        }
//        .contentShape(Rectangle())
//        .onTapGesture{
//            self.presentationMode.wrappedValue.dismiss()
//        }
//        .frame(maxWidth: .infinity)
//        .padding()
//    }
//    func progresser() {
//        if(replyCommentsPageFetchingCompleted){
//            print("done")
//            isDoneLoading = true
//        }else{
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
//                progresser()
//                if (replyCommentsPageFetchingCompleted == false){
//                    isDoneLoading = false
//                }
//            }
//        }
//    }
//}
//
//struct commentDetailsCommentsView_Previews: PreviewProvider {
//    static var previews: some View {
//        commentDetailsCommentsView()
//    }
//}
//
//struct ViewHeightKey3: PreferenceKey {
//    static var defaultValue: CGFloat { 0 }
//    static func reduce(value: inout Value, nextValue: () -> Value) {
//        value = value + nextValue()
//    }
//}
//
//struct replyCommentView: View {
//    @StateObject var sendLikesFunc = sendLikes()
//    
//    let _id: String
//    let slug: String
//    let pfp: String
//    let verification: Bool
//    let comment: String
//    let date: String
//    let artistId: String
//    let title: String
//    let likes: Array<String>
//    let albumId: String
//    let ownerId: String
//    
//    @EnvironmentObject var Comment : comment
//    
//    @State var liked: Bool = false
//    @State var profilePageIsActive: Bool = false
//    @State var heartScaleEffect: CGFloat = 1
//    @State var liking: Bool = false
//    @State var likesCount: Int = 0
//    var body: some View{
//        VStack{
//            HStack(alignment: .top){
//                Spacer().frame(width: 50)
//                ZStack{
//                    circleImage40by40(urlString: pfp)
//                        .onTapGesture {
//                            profilePageIsActive = true
//                        }
//                    NavigationLink(destination: navProfilePage(artistId: artistId), isActive: $profilePageIsActive) {
//                        EmptyView()
//                    }
//                    .disabled((profilePageIsActive) ? false : true)
//                    .opacity(0)
//                    .frame(width: 40, height: 40)
//                }
//                VStack(alignment: .leading, spacing: 2.5){
//                    Text(slug)
//                        .font(.footnote)
//                        .fontWeight(.bold)
//                    + Text((verification) ? " \(Image(systemName: "checkmark.seal.fill"))" : "")
//                        .font(.footnote)
//                    + Text((artistId == ownerId) ? " • Creator" : "")
//                        .font(.footnote)
//                        .fontWeight(.regular)
//                        .foregroundColor(Color.accentColor)
//                    (Text(Image(systemName: "arrowshape.turn.up.left")) + Text(" \(title)"))
//                        .font(.footnote)
//                        .foregroundColor(.gray)
//                    HStack(alignment: .top){
//                        HStack{
//                            Text(comment)
//                                .font(.body)
//                                .fontWeight(.regular)
//                            Spacer()
//                        }
//                        .contentShape(Rectangle())
//                        .onTapGesture {
//                            Comment.commentType = "Replying to reply"
//                            Comment.commentFocused = true
//                            Comment.commentPlaceholder = "Reply to \(slug)..."
//                        }
//                    }
//                    HStack(spacing: 10){
//                        Text(date)
//                            .font(.footnote)
//                            .foregroundColor(Color.gray)
//                        Text("Reply")
//                            .font(.footnote)
//                            .fontWeight(.bold)
//                            .onTapGesture {
//                                Comment.commentType = "Replying to reply"
//                                Comment.commentFocused = true
//                                Comment.commentPlaceholder = "Reply to \(slug)..."
//                            }
//                        if likes.contains(ownerId){
//                            Sticker(text: "Liked by creator")
//                        }
//                    }
//                    .padding(.vertical, 5)
//                }
//                Spacer()
//                VStack{
//                    ZStack{
//                        if liked {
//                            Image(systemName: "heart.fill")
//                                .scaleEffect(heartScaleEffect)
//                                .foregroundColor(.red)
//                        }else{
//                            Image(systemName: "heart")
//                                .scaleEffect(heartScaleEffect)
//                        }
//                        ProgressView().opacity(liking ? 1 : 0)
//                    }.animation(.interpolatingSpring(stiffness: 250, damping: 20), value: heartScaleEffect)
//                    Text("\(likesCount)")
//                        .font(.footnote)
//                        .foregroundColor(.gray)
//                }
//                .onTapGesture {
//                    Task{
//                        do {
//                            if liking {
//                                //Don't do nothing is stil sending request
//                            }else{
//                                liking = true
//                                heartScaleEffect = 0.5
//                                if liked {
//                                    liked = false
//                                    try await self.sendLikesFunc.sendLike(type: "remove", commentId: _id)
//                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                                        liking = false
//                                        likesCount = likesCount - 1
//                                        heartScaleEffect = 1
//                                    }
//                                }else{
//                                    liked = true
//                                    try await self.sendLikesFunc.sendLike(type: "insert", commentId: _id)
////                                    print("insert", comment, commentId, albumId, soundlytudeUserId())
//                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                                        liking = false
//                                        likesCount = likesCount + 1
//                                        heartScaleEffect = 1
//                                    }
//                                }
//                            }
//                        } catch {
//                            //
//                        }
//                    }
//                }
//                .onAppear{
//                    if likes.contains(soundlytudeUserId()){
//                        liked = true
//                    }
//                    likesCount = likes.count
//                }
//                .padding()
//            }
//        }
//        .frame(maxWidth: .infinity)
//        //        .swipeActions(edge: .leading, allowsFullSwipe: true) {
//        //            Button() {
//        //                profilePageIsActive = true
//        //            } label: {
//        //                Text("See profile")
//        //            }.tint(Color.accentColor)
//        //        }
//    }
//}
//struct replyCommentsPageArtistDetails: Hashable, Codable {
//    let _id: String
//    let artistName: String
//    let pimage: String
//    let verification: Bool?
//}
//
//class replyCommentsPageFetchReplies: ObservableObject {
//    @Published var replyCommentPageFields: [replyCommentPageField] = []
//    var totalFetch = 3
//    @Published var count = 0
//    
//    func fetch(commentId:String) {
//        commentsPageRepliesFetchingCompleted = false
//        guard let url = URL(string: HttpBaseUrl() + "/_functions/comments?password=z4Q2XL5gtvd8pL97p6tS&type=filterEqReply&columnId=reliedCommentId&value=\(commentId)&noItems=true&continueFrom=\(count)&totalFetch=\(totalFetch)") else {
//            return}
//        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _,
//            error in
//            guard let data = data, error == nil else {
//                return
//            }
//            // Convert to JSON
//            do
//            {
//                let data = try JSONDecoder().decode ([replyCommentPageField].self, from: data)
//                DispatchQueue.main.async{
//                    withAnimation(.easeIn(duration: 0.1)) {
//                        self?.replyCommentPageFields = self!.replyCommentPageFields + data
//                        commentsPageRepliesFetchingCompleted = true
//                    }
//                    self?.count += self?.totalFetch ?? 1
//                    replyCommentsPageFetchingCompleted = true
//                }
//            }
//            catch {
//                print(error)
//            }
//        }
//        task.resume()
//    }
//    
//    func getMoreReplies(commentId: String) async throws {
//        guard let url = URL(string: HttpBaseUrl() + "/_functions/comments?password=z4Q2XL5gtvd8pL97p6tS&type=filterEqReply&columnId=reliedCommentId&value=\(commentId)&noItems=true&continueFrom=\(count)&totalFetch=\(totalFetch)") else { fatalError("Missing URL") }
//        print(url)
//        let urlRequest = URLRequest(url: url)
//        let (data, response) = try await URLSession.shared.data(for: urlRequest)
//        
//        guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Error while fetching data") }
//        let decodedData = try JSONDecoder().decode([replyCommentPageField].self, from: data)
//        DispatchQueue.main.async{
//            withAnimation(.easeIn(duration: 0.1)) {
//                self.replyCommentPageFields = self.replyCommentPageFields + decodedData
//                commentsPageRepliesFetchingCompleted = true
//            }
//            self.count += self.totalFetch
//            replyCommentsPageFetchingCompleted = true
//        }
//    }
//}
