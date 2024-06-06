//
//  Explore Comments.swift
//  Soundlytude
//
//  Created by DJ bon26 on 5/13/24.
//

import SwiftUI

private var likedComments: [String] = []
private var disLikedComments: [String] = []

private var commentItemToAdd: [explorePageCommentField] = []

struct ExploreComments: View {
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var globalVariables: globalVariables
    
    @StateObject var GetComments = getExplorePageComments()
    @StateObject var Comment = comment()
    @StateObject var postCommentFunc = postComment()
    
    @FocusState private var commentInputFocused: Bool
    
    @State var loading: Bool = true
    @State var limit: Int = 5
    @State var noMore: Bool = false
    @State var albumId: String = "647e10bd-206d-4b07-8e6f-bbfb02667407"
    @State var albumOwner: String = "soundlytude-user-h16k4qbka913" //Mayrit
    @State var trackId: String = ""
    @State var trackName: String = ""
    
    @Binding var commentCount: Int
    
    @State var disableCommentLoadMore: Bool = false
    
    @Binding var profileLink: String
    @Binding var openComments: Bool
    
    @State var textEditorHeight : CGFloat = 20
    var emojis: Array<String> = ["🔥","🥰","🎵","💓","😮","💨","😮‍💨","⛽"]
    
    var disableSubmit: Bool {
        if Comment.commentText.replacingOccurrences(of: " ", with: "") == "" {
            return true
        }else {
            return false
        }
    }
    
    var body: some View {
        VStack (spacing: 0){
            if !loading {
                //                NavigationView(){
                ZStack(alignment: .top){
                    ScrollView{
                        Spacer()
                            .frame(height: 45)
                        VStack{
                            ForEach(GetComments.getExplorePageCommentsFields, id: \._id){ explore in
                                ExploreCommentItem(itemData: explore, replyCount: explore.replyCount, profileLink: $profileLink).environmentObject(Comment)
                                    .onChange(of: newCommentUpdatedId) { output in
                                        if let row = self.GetComments.getExplorePageCommentsFields.firstIndex(where: {$0._id == "toBeUpdated"}) {
                                            GetComments.getExplorePageCommentsFields[row]._id = output
                                            GetComments.getExplorePageCommentsFields[row].createdTime = Int(Date().millisecondsSince1970)
                                        }
                                    }
                            }
                        }
                        Button {
                            Task{
                                do {
                                    disableCommentLoadMore = true
                                    try await GetComments.getMoreExploreComment(limit: limit, action: "load", albumId: albumId, type: "comment", repliedCommentId: "", previouslyFetched: GetComments.getExplorePageCommentsFields)
                                    if exploreCommentsLoadMoreCount == 0 || exploreCommentsLoadMoreCount < limit {
                                        disableCommentLoadMore = true
                                    }else{
                                        disableCommentLoadMore = false
                                    }
                                }catch{
                                    print(error)
                                    disableCommentLoadMore = false
                                }
                            }
                        } label: {
                            Text("Load more")
                        }
                        .disabled(disableCommentLoadMore)
                        bottomSpace(height: 50 + textEditorHeight)
                            .padding()
                    }
                    HStack(alignment: .center){
                        Image(systemName: "multiply")
                            .opacity(0.01)
                        Spacer()
                        Text("\(commentCount) comments")
                        Spacer()
                        Button {
                            withAnimation(.spring()){
                                openComments = false
                                globalVariables.hideTabBar = false
                                Comment.commentFocused = false
                                commentInputFocused = false
                            }
                        } label: {
                            Image(systemName: "multiply")
                                .padding()
                        }
                    }
                    .padding(.leading)
                    .frame(height: 40)
                    .background(BlurView())
                    VStack(spacing: 0){
                        ZStack{
                            if Comment.commentFocused {
                                Color.black.opacity(0.25)
                                    .onAppear{
                                        commentInputFocused = true
                                    }
                                    .onDisappear{
                                        commentInputFocused = false
                                    }
                            }else{
                                Spacer()
                            }
                            if commentInputFocused {
                                Text("")
                                    .onAppear{
                                        Comment.commentFocused = true
                                    }
                            }
                        }
                        .onTapGesture {
                            commentInputFocused = false
                            Comment.commentFocused = false
                            if Comment.commentText == "" {
                                Comment.commentPlaceholder = "Comment \(trackName == "" ? "" : "on \(trackName)")"
                                Comment.commentType = "Comment"
                                Comment.replyingCommentId = ""
                                Comment.repliedCommentText = ""
                                Comment.repliedReplyCommentId = ""
                            }else{
                                
                            }
                        }
                        if openComments {
                            VStack(spacing: 0){
                                Divider()
                                HStack{
                                    ForEach(emojis, id: \.self){i in
                                        Spacer()
                                        Text(i)
                                            .font(.system(size: 30))
                                            .padding(.vertical, 5)
                                            .onTapGesture {
                                                Comment.commentText = Comment.commentText + i
                                            }
                                        Spacer()
                                    }
                                }.padding(0)
                                //////
                                HStack(alignment: .bottom, spacing: 0){
                                    circleImage40by40(urlString: local.string(forKey: "currentUserArtistPfp") ?? "")
                                        .padding(.horizontal, 2.5)
                                    ZStack(alignment: .leading) {
                                        Text(Comment.commentText + "​")//there's a character here
                                            .font(.body)
                                            .foregroundColor(.clear)
                                            .padding(.horizontal, 2.5)
                                            .padding(.vertical, 7.5) //7.5
                                            .offset(y: -0.5)
                                            .background(GeometryReader {
                                                Color.clear.preference(key: ViewHeightKey5.self,
                                                                       value: $0.frame(in: .local).size.height)
                                            })
                                            .lineLimit(5)
                                        ZStack(alignment: .leading){
                                            if #available(iOS 16.0, *) {
                                                TextEditor(text:$Comment.commentText)
                                                    .font(.body)
                                                    .frame(maxHeight: max(20, textEditorHeight))
                                                //                                                        .customTextField(color: .accentColor, padding: 5, lineWidth: 1)
                                                    .focused($commentInputFocused)
                                                    .scrollContentBackground(Visibility.hidden)    // new technique for iOS 16
                                                    .introspectTextView { textView in
                                                        textView.showsVerticalScrollIndicator = false
                                                    }
                                            } else {
                                                // Fallback on earlier versions
                                                TextEditor(text:$Comment.commentText)
                                                    .font(.body)
                                                    .frame(maxHeight: max(20, textEditorHeight))
                                                //                                                        .customTextField(color: .accentColor, padding: 5, lineWidth: 1)
                                                    .focused($commentInputFocused)
                                                    .introspectTextView { textView in
                                                        textView.showsVerticalScrollIndicator = false
                                                    }
                                            }
                                            Text((Comment.commentText == "") ? " \(Comment.commentPlaceholder)" : "")
                                                .opacity(0.25)
                                                .offset(y: -1)
                                                .onTapGesture {
                                                    withAnimation(.easeInOut(duration: 0.25)) {
                                                        Comment.commentFocused = true
                                                    }
                                                }
                                        }
                                    }
                                    .padding(.leading, 2.5)
                                    .onPreferenceChange(ViewHeightKey5.self) {
                                        textEditorHeight = $0
                                    }
                                    Button {
                                        _ = "toBeDeleted" + String(Float.random(in: 1..<3))
                                        if commentItemToAdd.count < 1 {
                                            Task {
                                                do {
                                                    commentCount = commentCount + 1
                                                    let toAdd = explorePageCommentField(
                                                        _id: "toBeUpdated",
                                                        richComment: Comment.commentText,
                                                        title: Comment.repliedCommentText,
                                                        reliedCommentId: "",
                                                        repliedReplyCommentId: Comment.repliedReplyCommentId,
                                                        ownerId: albumOwner,
                                                        type: Comment.commentType,
                                                        albumId: albumId,
                                                        artistId: soundlytudeUserId(),
                                                        trackId: trackId,
                                                        replyCount: 0,
                                                        likes: [],
                                                        createdTime: 0,
                                                        artistDetails: commentsPageArtistDetails(_id: soundlytudeUserId(), artistName: currentUser.artistName, slug: currentUser.slug, pimage: newlyUpdatedPfpUrl, verification: true, themeColor: ""),
                                                        trackDetails: explorePageCommentTrackDetailsField(tracktitle: trackName))
                                                    
                                                    if Comment.commentType == "Comment" {
                                                        GetComments.getExplorePageCommentsFields = [toAdd] + GetComments.getExplorePageCommentsFields
                                                    }else {
                                                        commentItemToAdd = [toAdd]
                                                    }
                                                    try await self.postCommentFunc.sendComment(comment: Comment.commentText, commentType: Comment.commentType, itemId: albumId, trackId: trackId, itemOwnerId: albumOwner, repliedToComment: Comment.repliedCommentText, repliedCommentId: Comment.replyingCommentId, repliedReplyCommentId: Comment.repliedReplyCommentId)
                                                    Comment.commentText = ""
                                                    Comment.commentFocused = false
                                                } catch {
                                                    commentCount = commentCount - 1
                                                    print(error)
                                                }
                                            }
                                        }else{
                                            //alert: Please wait fot your other comment to post
                                        }
                                    } label: {
                                        if !disableSubmit {
                                            IconButton(icon: "arrow.up", size: 30, background: Color.accentColor, foregroundColor: Color.white)
                                        }else{
                                            IconButton(icon: "arrow.up", size: 30, background: Color.gray.opacity(0.25))
                                        }
                                    }
                                    .padding(.trailing, 5)
                                    .padding(.bottom, 5)
                                    .scaleEffect((disableSubmit) ? 0.9 : 1)
                                    .disabled(disableSubmit)
                                    .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.95, blendDuration: 0.5), value: disableSubmit)
                                }
                                .padding(.vertical, 2.5)
                                .overlay( /// apply a rounded border
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(.blue, lineWidth: 1.6)
                                )
                                .cornerRadius(20)
                                .padding(10)
                            }
                            .transition(.move(edge: .bottom))
                            .padding(.bottom, iphoneXandUp ? 20 : 0)
                            .background((colorScheme == .dark) ? .thinMaterial : .regular)
                            //                        .opacity((Comment.commentFocused) ? 1 : 0)
                            .onAppear{
                                if Comment.commentFocused {
                                    commentInputFocused = true
                                }
                                if Comment.commentText == "" {
                                    Comment.commentPlaceholder = "Comment \(trackName == "" ? "" : "on \(trackName)")"
                                    Comment.commentType = "Comment"
                                    Comment.replyingCommentId = ""
                                    Comment.repliedReplyCommentId = ""
                                }
                            }
                            .onDisappear{
                                Comment.commentFocused = false
                                commentInputFocused = false
                            }
                            Spacer().frame(height: 0)
                        }
                    }
                }
                //                }
            } else {
                VStack{
                    ProgressView()
                        .onAppear{
                            Task{
                                do {
                                    try await GetComments.getMoreExploreComment(limit: limit, action: "load", albumId: albumId, type: "comment", repliedCommentId: "", previouslyFetched: GetComments.getExplorePageCommentsFields)
                                    if exploreCommentsLoadMoreCount < limit {
                                        noMore = true
                                    }else{
                                        noMore = false
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
        //        .background(Color("WhiteBlack"))
    }
}

struct ExploreCommentItem: View {
    @EnvironmentObject var Comment: comment
    
    @StateObject var GetReplies = getExplorePageComments()
    
    @State var itemData: explorePageCommentField
    
    @State var repliesLoaded: [explorePageCommentField] = []//Save it, no fetching new data
    
    @State var limit: Int = 1
    @State var replyCount: Int = 0
    @State var repliesAddedCount: Int = 0
    @State var loading: Bool = false
    
    @State var noMore: Bool = false
    @Binding var profileLink: String
    
    var body: some View {
        VStack (spacing: 10){
            ExploreCommentView(commentId: itemData._id,
                               likes: itemData.likes,
                               pfpUrl: itemData.artistDetails.pimage,
                               artistId: itemData.artistDetails._id,
                               artistName: itemData.artistDetails.artistName,
                               verified: itemData.artistDetails.verification ?? false,
                               sticker: (itemData.trackId == "") ? false : true ,
                               stickerText: itemData.trackDetails?.tracktitle ?? "",
                               comment: itemData.richComment,
                               date: itemData.createdTime,
                               repliedReplyCommentId: itemData.repliedReplyCommentId ?? "",
                               reliedCommentId: itemData.reliedCommentId ?? "",
                               title: itemData.title ?? "",
                               profileLink: $profileLink).environmentObject(Comment)
            ForEach(GetReplies.getExplorePageCommentsFields, id: \._id){ explore in
                ExploreCommentView(commentId: explore._id,
                                   type: explore.type,
                                   likes: explore.likes,
                                   pfpUrl: explore.artistDetails.pimage,
                                   artistId: itemData.artistDetails._id,
                                   artistName: explore.artistDetails.artistName,
                                   verified: explore.artistDetails.verification ?? false,
                                   sticker: (itemData.trackId == "") ? false : true ,
                                   stickerText: itemData.trackDetails?.tracktitle ?? "",
                                   comment: explore.richComment,
                                   date: explore.createdTime,
                                   repliedReplyCommentId: explore.repliedReplyCommentId ?? "",
                                   reliedCommentId: explore.reliedCommentId ?? "",
                                   title: explore.title ?? "", profileLink: $profileLink).environmentObject(Comment)
                    .padding(.leading, 50)
            }
            
            if itemData.replyCount > 0 {
                HStack(spacing: 0){
                    if !noMore {
                        Color.secondary
                            .padding(.leading, 65)
                            .frame(width: 95, height: 1)
                        Button {
                            Task{
                                do {
                                    loading = true
                                    withAnimation(.easeIn(duration: 0.25)) {
                                        GetReplies.getExplorePageCommentsFields = repliesLoaded + GetReplies.getExplorePageCommentsFields
                                    }
                                    if repliesLoaded == [] {
                                        try await GetReplies.getMoreExploreComment(limit: limit, action: "load", albumId: itemData.albumId, type: "reply", repliedCommentId: itemData._id, previouslyFetched: GetReplies.getExplorePageCommentsFields)
                                    }
                                    repliesLoaded = []
                                    print(itemData.replyCount - GetReplies.getExplorePageCommentsFields.count)
                                    replyCount = (itemData.replyCount + repliesAddedCount) - GetReplies.getExplorePageCommentsFields.count
                                    if replyCount == 0{
                                        noMore = true
                                    }else{
                                        noMore = false
                                    }
                                    loading = false
                                    print("done")
                                }catch{
                                    loading = false
                                    print("error bro", error)
                                }
                            }
                        } label: {
                            if loading {
                                ProgressView()
                            }else{
                                Text("View \(replyCount) replies")
                                    .font(.footnote)
                                    .fontWeight(.bold)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .disabled(loading)
                        .padding(.horizontal, 10)
                    }
                    Spacer()
                    if GetReplies.getExplorePageCommentsFields != [] {
                        Button {
                            withAnimation(.easeIn(duration: 0.25)) {
                                repliesLoaded = GetReplies.getExplorePageCommentsFields
                                GetReplies.getExplorePageCommentsFields = []
                                replyCount = itemData.replyCount + repliesAddedCount
                                noMore = false
                            }
                        } label: {
                            if loading {
                                //
                            }else{
                                Text("Hide")
                                    .font(.footnote)
                                    .fontWeight(.bold)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .onChange(of: commentItemToAdd) { output in
            if Comment.replyingCommentId == itemData._id {
                repliesAddedCount = repliesAddedCount + 1
                if Comment.commentType == "Replying to reply" {
                    let filtered = GetReplies.getExplorePageCommentsFields.filter { word in
                        return word._id == Comment.repliedReplyCommentId
                    }
                    guard let index: Int = GetReplies.getExplorePageCommentsFields.firstIndex(of: filtered[0]) else {
                        return }
                    GetReplies.getExplorePageCommentsFields.insert(output[0], at: (index + 1))
                }else{
                    GetReplies.getExplorePageCommentsFields = output + GetReplies.getExplorePageCommentsFields
                }
            }
        }
        .onChange(of: newCommentUpdatedId) { output in
            if let row = self.GetReplies.getExplorePageCommentsFields.firstIndex(where: {$0._id == "toBeUpdated"}) {
                GetReplies.getExplorePageCommentsFields[row]._id = output
                GetReplies.getExplorePageCommentsFields[row].createdTime = Int(Date().millisecondsSince1970)
            }
        }
    }
}

struct ExploreCommentView: View {
    @EnvironmentObject var Comment: comment
    
    @State var commentId: String = ""
    @State var type: String = "Comment"
    @State var likes: [String] = []
    @State var liked: Bool = false
    @State var heartScaleEffect: CGFloat = 1
    @State var liking: Bool = false
    
    @State var pfpUrl: String = ""
    @State var artistId: String = "DJ bon26"
    @State var artistName: String = "DJ bon26"
    @State var verified: Bool = false
    @State var sticker: Bool = false
    @State var stickerText: String = "Pull up at the mansion"
    @State var comment: String = "commentcommentcom men tcomme ntcom ment c ommentcomment comme ntcomm comment commen tcommment ent"
    @State var date: Int = 0
    @State var repliedReplyCommentId: String = ""
    @State var reliedCommentId: String = ""
    @State var title: String
    @State var commentWidth: Double = 0.0
    
    @State var profilePageActivated: Bool = false
    @Binding var profileLink: String
    
    @StateObject var sendCommentLikesFunc = sendCommentLikes()
    
    var commentType: String {
        if type == "Comment" {
            return "Reply"
        }else {
            return "Replying to reply"
        }
    }
    
    var body: some View {
        HStack(alignment: .top){
            Button {
                profileLink = artistId
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    profileLink = ""
                }
            } label: {
                if type == "Comment" {
                    circleImage40by40(urlString: pfpUrl)
                }else{
                    circleImageCustomSize(urlString: pfpUrl, resolution: 30)
                }
            }
            VStack(alignment: .leading, spacing: 5){
                HStack{
                    Button {
                        profileLink = artistId
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            profileLink = ""
                        }
                    } label: {
                        (Text("\(artistName)") + Text(verified ? " \(Image(systemName: "checkmark.seal.fill"))" : ""))
                            .font(.footnote)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                    }
                    if repliedReplyCommentId != "" {
                        Image(systemName: "arrowtriangle.right.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(title)
                            .font(.footnote)
                            .fontWeight(.bold)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                    }
                }
                if sticker {
                    Sticker(text: stickerText)
                }
                Text(comment)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                //                HStack{
                //                    Text(comment)
                //                        .font(.body)
                ////                        .frame(width: commentWidth, alignment: .leading)
                //                    Color.red
                //                }
                //                .background(
                //                    GeometryReader { geo in
                //                        Text("")
                //                            .onAppear{
                //                                commentWidth = geo.size.width
                //                            }
                //                    })
                HStack{
                    if date != 0 {
                        Text(formatToDateStyle2(time: "\(date)"))
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }else{
                        Text("Posting...")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    if date != 0 {
                        Button {
                            Comment.commentFocused = true
                            Comment.commentPlaceholder = "Reply to \(artistName)"
                            Comment.commentType = commentType
                            Comment.commentText = ""
                            if commentType == "Reply" {
                                Comment.replyingCommentId = commentId
                                Comment.repliedCommentText = ""
                                Comment.repliedReplyCommentId = ""
                            }
                            if commentType == "Replying to reply" {
                                Comment.replyingCommentId = reliedCommentId
                                Comment.repliedCommentText = comment
                                Comment.repliedReplyCommentId = commentId
                            }
                            //come back
                        } label: {
                            Text("Reply")
                                .font(.footnote)
                                .fontWeight(.bold)
                        }
                        Spacer()
                        Button {
                            like(source: "direct")
                        } label: {
                            HStack(spacing: 2.5){
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
                                .font(.system(size: 20))
                                .animation(.interpolatingSpring(stiffness: 250, damping: 20), value: heartScaleEffect)
                                Text("\(likes.count)")
                                    .font(.caption)
                                    .if(liked) {view in
                                        view.foregroundColor(.red)
                                    }
                            }
                        }.disabled(liking)
                    }
                }
            }
            .onTapGesture(count: 2) {
                like(source: "doubleTap")
            }
            .onTapGesture(count: 1) {
                Comment.commentFocused = true
                Comment.commentPlaceholder = "Reply to \(artistName)"
                Comment.commentType = commentType
                Comment.commentText = ""
                if commentType == "Reply" {
                    Comment.replyingCommentId = commentId
                    Comment.repliedCommentText = ""
                    Comment.repliedReplyCommentId = ""
                }
                if commentType == "Replying to reply" {
                    Comment.replyingCommentId = reliedCommentId
                    Comment.repliedCommentText = comment
                    Comment.repliedReplyCommentId = commentId
                }
            }
        }.padding(.horizontal)
            .onAppear{
                if likedComments.contains(commentId) {
                    likes.append(soundlytudeUserId())
                }else{
                    if disLikedComments.contains(commentId) {
                        if let i = likes.firstIndex(of: soundlytudeUserId()) {
                            likes.remove(at: i)
                        }
                    }
                }
                if likes.contains(soundlytudeUserId()) {
                    liked = true
                }else{
                    liked = false
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
                            try await self.sendCommentLikesFunc.sendLike(type: "remove", commentId: commentId)
                            disLikedComments.append(commentId)
                            if let i = likedComments.firstIndex(of: commentId) {
                                likedComments.remove(at: i)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                liking = false
                                likes.remove(at: likes.firstIndex(of: soundlytudeUserId()) ?? -1)
                                heartScaleEffect = 1
                            }
                        }
                    }else{
                        liked = true
                        try await self.sendCommentLikesFunc.sendLike(type: "insert", commentId: commentId)
                        likedComments.append(commentId)
                        if let i = disLikedComments.firstIndex(of: commentId) {
                            disLikedComments.remove(at: i)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            liking = false
                            likes.append(soundlytudeUserId())
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
}

struct Explore_Comments_Previews: PreviewProvider {
    static var previews: some View {
        ExploreComments(commentCount: .constant(0), profileLink: .constant(""), openComments: .constant(true))
    }
}

struct explorePageCommentTrackDetailsField: Hashable, Codable {
    let tracktitle: String
}

struct explorePageCommentField: Hashable, Codable {
    var _id: String
    let richComment: String
    let title: String?
    let reliedCommentId: String?
    let repliedReplyCommentId: String?
    let ownerId: String
    let type: String
    let albumId: String
    let artistId: String
    let trackId: String?
    let replyCount: Int
    let likes: Array<String>
    var createdTime: Int
    let artistDetails: commentsPageArtistDetails
    let trackDetails: explorePageCommentTrackDetailsField?
}

class getExplorePageComments: ObservableObject {
    @Published var getExplorePageCommentsFields: [explorePageCommentField] = []
    
    func getMoreExploreComment(limit: Int, action: String, albumId: String, type: String, repliedCommentId: String, previouslyFetched: [explorePageCommentField]) async throws {
        guard let url = URL(string: HttpBaseUrl() + "/_functions/getExploreComment?password=z4Q2XL5gtvd8pL97p6tS&action=\(action)&limit=\(limit)") else { fatalError("Missing URL") }
        //        if previouslyFetched.count > 0{
        //        }
        
        struct exploreGetCommentsData: Codable {
            let albumId: String
            let type: String
            let repliedCommentId: String
            let previouslyFetched: [explorePageCommentField]
        }
        
        // Add data to the model
        let exploreGetCommentsDataModel = exploreGetCommentsData(albumId: albumId, type: type, repliedCommentId: repliedCommentId, previouslyFetched: previouslyFetched)
        
        // Convert model to JSON data
        guard let jsonData = try? JSONEncoder().encode(exploreGetCommentsDataModel) else {
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
        let decodedData = try JSONDecoder().decode([explorePageCommentField].self, from: data)
        print("Checkpoint4")
        DispatchQueue.main.async{
            print("Checkpoint5")
            withAnimation(.easeIn(duration: 0.25)) {
                print(decodedData)
                if action == "refresh" {
                    self.getExplorePageCommentsFields = decodedData
                }else{
                    self.getExplorePageCommentsFields = self.getExplorePageCommentsFields + decodedData
                    exploreCommentsLoadMoreCount = decodedData.count
                }
            }
        }
    }
}


struct ViewHeightKey5: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value + nextValue()
    }
}
