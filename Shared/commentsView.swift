//
//  commentsView.swift
//  Soundlytude (iOS)
//
//  Created by DJ bon26 on 11/18/22.
//

import SwiftUI

private var commentsPageFetchingCompleted: Bool = false
var commentsPageRepliesFetchingCompleted: Bool = true

var newCommentUpdatedId: String = ""

class comment: ObservableObject {
    @Published var commentText: String = ""
    @Published var replyingCommentId: String = ""
    @Published var commentPlaceholder: String = "Add comment..."
    @Published var commentType: String = ""
    @Published var repliedCommentText: String = ""
    @Published var repliedReplyCommentId: String = ""
    @Published var commentFocused: Bool = false
}

struct commentsView: View {
    @Binding var albumRootIsActive : Bool
    @EnvironmentObject var globalVariables: globalVariables
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.rootPresentationMode) private var rootPresentationMode: Binding<RootPresentationMode>
    
    @StateObject var commentsPageFetch = commentsPageFetchComments()
    @StateObject var Comment = comment()
    @StateObject var postCommentFunc = postComment()
    
    var albumId: String = "f162c63e-526b-45f8-b400-7352e32e6dd5"
    var albumOwner: String = ""
    var commentCount: Int = 0
    
    @FocusState private var commentInputFocused: Bool
    
    @State var isDoneLoading: Bool = false
    @State private var presentAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    @State var profilePageIsActive: Bool = false
    
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
//        NavigationView{
        if isDoneLoading {
            ZStack{
                ScrollView{
                    Button {
                        albumRootIsActive = false
                    } label: {
                        commentDetailAlbumView()
                    }
                    ForEach(commentsPageFetch.commentPageFields, id: \._id) { i in
                        commentView(
                            albumRootIsActive: $albumRootIsActive,
                            type: i.type,
                            commentId: i._id,
                            artistName: i.artistDetails.artistName,
                            slug: i.artistDetails.slug,
                            pfp: i.artistDetails.pimage,
                            verification: i.artistDetails.verification ?? false,
                            comment: i.richComment,
                            date: i._createdDate,
                            createdTime: i.createdTime,
                            artistId: i.artistDetails._id,
                            artistThemeColor: i.artistDetails.themeColor ?? "000000",
                            replyCount: i.replyCount,
                            likes: i.likes ?? [],
                            albumId: i.albumId,
                            ownerId: i.ownerId
                        ).environmentObject(Comment)
                            .environmentObject(globalVariables)
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    bottomSpace()
                        .listRowSeparator(.hidden)
                }.listStyle(PlainListStyle())
                if Comment.commentFocused {
                    Text("")
                        .onAppear{
                            commentInputFocused = true
                        }
                }
                VStack{
                    Spacer()
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
                        }
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
                                        Color.clear.preference(key: ViewHeightKey2.self,
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
                            .onPreferenceChange(ViewHeightKey2.self) {
                                textEditorHeight = $0
                            }
                            Button {
                                let id2 = "toBeDeleted" + String(Float.random(in: 1..<3))
                                if Comment.commentType == "Comment"{
                                    Task {
                                        do {
                                            let toAdd = commentPageField(
                                                _id: id2,
                                                richComment: Comment.commentText,
                                                ownerId: soundlytudeUserId(),
                                                type: Comment.commentType,
                                                albumId: albumId,
                                                artistId: soundlytudeUserId(),
                                                replyCount: 0,
                                                likes: [],
                                                _createdDate: "Just now", createdTime: "201202",
                                                artistDetails: commentsPageArtistDetails(_id: soundlytudeUserId(), artistName: currentUser.artistName, slug: currentUser.slug, pimage: newlyUpdatedPfpUrl, verification: true, themeColor: ""))
                                            commentsPageFetch.commentPageFields = [toAdd] + commentsPageFetch.commentPageFields
                                            try await self.postCommentFunc.sendComment(comment: Comment.commentText, commentType: Comment.commentType, itemId: albumId, trackId: "", itemOwnerId: albumOwner, repliedToComment: "", repliedCommentId: "", repliedReplyCommentId: "")
                                            Comment.commentText = ""
                                        } catch {
                                            print(error)
                                        }
                                    }
                                }
                                Comment.commentFocused = false
                                globalVariables.hideTabBar = false
                                commentInputFocused = false
                                print("id: ", id2)
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
                        /////
                        
//                        HStack(alignment: .bottom) {
//                            circleImage40by40(urlString: local.string(forKey: "currentUserArtistPfp") ?? "")
//                            ZStack(alignment: .leading) {
//                                Text(Comment.commentText)
//                                    .foregroundColor(.clear)
//                                    .padding(10)
//                                    .background(GeometryReader {
//                                        Color.clear.preference(key: ViewHeightKey2.self,
//                                                               value: $0.frame(in: .local).size.height)
//                                    })
//                                    .lineLimit(5)
//                                ZStack(alignment: .leading){
//                                    if #available(iOS 16.0, *) {
//                                        TextEditor(text:$Comment.commentText)
//                                            .frame(maxHeight: max(40,textEditorHeight))
//                                            .customTextField(color: .accentColor, padding: 5, lineWidth: 1)
//                                            .focused($commentInputFocused)
//                                            .scrollContentBackground(Visibility.hidden)    // new technique for iOS 16
//                                    } else {
//                                        // Fallback on earlier versions
//                                        TextEditor(text:$Comment.commentText)
//                                            .frame(maxHeight: max(40,textEditorHeight))
//                                            .customTextField(color: .accentColor, padding: 5, lineWidth: 1)
//                                            .focused($commentInputFocused)
//                                    }
//                                    Text((Comment.commentText == "") ? "  \(Comment.commentPlaceholder)" : "")
//                                        .opacity(0.25)
//                                        .offset(y: -0.5)
//                                        .onTapGesture {
//                                            Comment.commentFocused = true
//                                        }
//                                }
//                            }
//                            .onPreferenceChange(ViewHeightKey2.self) {
//                                textEditorHeight = $0
//                            }
//                            Button {
//                                let id2 = "toBeDeleted" + String(Float.random(in: 1..<3))
//                                if Comment.commentType == "Comment"{
//                                    Task {
//                                        do {
//                                            let toAdd = commentPageField(
//                                                _id: id2,
//                                                richComment: Comment.commentText,
//                                                ownerId: soundlytudeUserId(),
//                                                type: Comment.commentType,
//                                                albumId: albumId,
//                                                artistId: soundlytudeUserId(),
//                                                replyCount: 0,
//                                                likes: [],
//                                                _createdDate: "Just now", createdTime: "201202",
//                                                artistDetails: commentsPageArtistDetails(_id: soundlytudeUserId(), artistName: currentUser.artistName, slug: currentUser.slug, pimage: newlyUpdatedPfpUrl, verification: true, themeColor: ""))
//                                            commentsPageFetch.commentPageFields = [toAdd] + commentsPageFetch.commentPageFields
//                                            try await self.postCommentFunc.sendComment(comment: Comment.commentText, commentType: Comment.commentType, itemId: albumId, itemOwnerId: albumOwner)
//                                            Comment.commentText = ""
//                                        } catch {
//                                            print(error)
//                                        }
//                                    }
//                                }
//                                if Comment.commentType == "Reply"{
//                                    let toAdd = replyCommentPageField(
//                                        _id: id2,
//                                        richComment: Comment.commentText,
//                                        ownerId: soundlytudeUserId(),
//                                        type: Comment.commentType,
//                                        albumId: albumId,
//                                        artistId: soundlytudeUserId(),
//                                        _createdDate: "Just now", createdTime: "2932", replyCount: 0 ,
//                                        likes: [],
//                                        title: Comment.commentType,
//                                        artistDetails: commentsPageArtistDetails(_id: soundlytudeUserId(), artistName: currentUser.artistName, slug: currentUser.slug, pimage: newlyUpdatedPfpUrl, verification: true, themeColor: ""))
//                                    Comment.commentText = ""
//                                }
//                                Comment.commentFocused = false
//                                commentInputFocused = false
//                                print("id: ", id2)
//                            } label: {
//                                if disableSubmit {
//                                    IconButton(icon: "arrow.up", background: Color.gray.opacity(0.25))
//                                }else{
//                                    IconButton(icon: "arrow.up", background: Color.accentColor, foregroundColor: Color.white)
//                                }
//                            }
//                            .disabled(disableSubmit)
//                            
//                        }
//                        .padding(10)
                    }
                    .background((colorScheme == .dark) ? .thinMaterial : .regular)
                    .opacity((Comment.commentFocused) ? 1 : 0)
                    .onAppear{
                        if Comment.commentFocused {
                            commentInputFocused = true
                        }
                    }
                    Spacer().frame(height: 0)
                }
            }
            .background(
                VStack{
                    Color(hexStringToUIColor(hex: "#\((currentViewingAlbum.themeColor ?? "000000").replacingOccurrences(of: "#", with: ""))"))
                        .opacity(0.25)
                        .frame(height: (viewableHeight + viewableHeight))
                        .mask(LinearGradient(colors:[
                            .black,
                            .black,
                            .clear], startPoint: .top, endPoint: .bottom))
                        .offset(y: -(viewableHeight))
                    Spacer()
                }
            )
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("\(commentCount) comments")
            .toolbar{
                ToolbarItem(placement: .navigation){
                    Button {
                        if commentInputFocused {
                            Comment.commentFocused = false
                            commentInputFocused = false
                            globalVariables.hideTabBar = false
                            parentCommentId = ""
                        }else{
                            Comment.commentPlaceholder = "Add comment..."
                            Comment.commentType = "Comment"
                            Comment.commentFocused = true
                            globalVariables.hideTabBar = true
                        }
                    } label: {
                        if commentInputFocused {
                            HStack{
                                Image(systemName: "keyboard.chevron.compact.down")
                                Text("Cancel")
                            }.foregroundColor(.red)
                        }else{
                            HStack{
                                Image(systemName: "square.and.pencil")
                                Text("Comment")
                            }
                        }
                    }
                }
            }
        }else{
            VStack{
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.accentColor))
                    .onAppear{
                        commentsPageFetchingCompleted = false
                        progresser()
                        commentsPageFetch.fetch(albumId: albumId)
                    }
            }
            .alert(alertTitle, isPresented: $presentAlert, actions: {
                // actions
            }, message: {
                Text(alertMessage)
            })
            .toolbar{
                ToolbarItem(placement: .navigation){
                    Text("Comments")
                        .font(.headline)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .frame(width: viewableWidth - 40)
                }
            }
        }
//    }
    }
    
    func progresser() {
        if(commentsPageFetchingCompleted){
            print("done")
            isDoneLoading = true
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                progresser()
                if (commentsPageFetchingCompleted == false){
                    isDoneLoading = false
                }
            }
        }
    }
}

struct commentView: View {
//    @StateObject var replyCommentsPageFetch = replyCommentsPageFetchReplies()
    @Environment(\.colorScheme) var colorScheme
    @StateObject var sendCommentLikesFunc = sendCommentLikes()
    @EnvironmentObject var Comment : comment
    @EnvironmentObject var globalVariables: globalVariables
    
    @Binding var albumRootIsActive : Bool
    
    @State var type: String = ""
    @State var commentId: String = ""
    @State var artistName: String = "Artist name"
    @State var slug: String = "editorium"
    @State var pfp: String = ""
    @State var verification: Bool = false
    @State var comment: String = "This is a comment"
    @State var date: String = "Date"
    @State var createdTime: String = "Time"
    @State var artistId: String = "_id"
    @State var artistThemeColor: String = "000000"
    @State var replyCount: Int = 0
    @State var likes: Array<String> = []
    @State var albumId: String = ""
    @State var ownerId: String = ""
    
    @State var profilePageIsActive: Bool = false
    @State var commentDetailsViewIsActive: Bool = false
    
    @State var liked: Bool = false
    @State var repliesLeftCount = 0
    @State var hideReplies: Bool = false
    @State var maxReplies: Bool = false
    @State var repliesDoneLoading: Bool = true
    @State var heartScaleEffect: CGFloat = 1
    @State var liking: Bool = false
    @State var likesCount: Int = 0
    
    @State var checkedLiked: Bool = false
    
    var themeColorMix: Color {
        return Color(UIColor.blend(color1: UIColor(Color(hexStringToUIColor(hex: "#\(artistThemeColor.replacingOccurrences(of: "#", with: ""))"))), intensity1: 0.8, color2: UIColor(colorScheme == .dark ? Color.white : Color.black), intensity2: 0.2))
    }
    
    var body: some View{
        HStack(alignment: .top, spacing:10){
            circleImage40by40(urlString: pfp)
                .onTapGesture {
                    profilePageIsActive = true
                }
            VStack(alignment: .leading, spacing: 5){
                HStack(spacing: 2.5){
                    Group {
                        Text(artistName)
                            .font(.callout)
                            .fontWeight(.bold)
                            .lineLimit(1)
                            .foregroundColor(verification ? themeColorMix : nil)
                        if verification {
                            Text("@\(slug)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .lineLimit(1)
                                .foregroundColor(Color.gray)
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption)
                                .foregroundColor(verification ? themeColorMix : nil)
                        }
                        if artistId == ownerId {
                            Text("• Creator")
                                .fontWeight(.bold)
                                .font(.caption)
                                .foregroundColor(Color.accentColor)
                        }
                    }
                    .onTapGesture {
                        profilePageIsActive = true
                    }
                    Spacer()
                    Button {
                        //
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                    
                }
                Button {
                    currentViewingCommentId = commentId
                    parentCommentId = commentId
                    Comment.commentFocused = false
                    parentCommentId = ""
                    globalVariables.hideTabBar = false
                    let filtered = commentsHistory.filter { word in
                        return word.commentDetails._id == commentId
                    }
                    if filtered.count < 1 {
                        commentsHistory.append(commentsHistoryField(commentDetails: commentPageField(
                            _id: commentId,
                            richComment: comment,
                            ownerId: ownerId,
                            type: type,
                            albumId: "",
                            artistId: artistId,
                            replyCount: replyCount,
                            likes: likes,
                            _createdDate: date,
                            createdTime: createdTime,
                            artistDetails: commentsPageArtistDetails(
                                _id: artistId,
                                artistName: artistName,
                                slug: slug,
                                pimage: pfp,
                                verification: verification,
                                themeColor: artistThemeColor
                            )
                        ), baseCommentId: commentId))
                    }
                    commentDetailsViewIsActive = true
                } label: {
                    Text(comment)
                        .padding(.vertical, 5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                if likes.contains(ownerId){
                    Sticker(text: "Liked by creator")
                }
                Divider()
                HStack{
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
                        }.animation(.interpolatingSpring(stiffness: 250, damping: 20), value: heartScaleEffect)
                        Text("\(likesCount)")
                            .font(.caption)
                            .lineLimit(1)
                    }
                    .foregroundColor(.gray)
                    .onTapGesture {
                        Task{
                            do {
                                if liking {
                                    //Don't do nothing is stil sending request
                                }else{
                                    liking = true
                                    heartScaleEffect = 0.5
                                    if liked {
                                        liked = false
                                        try await self.sendCommentLikesFunc.sendLike(type: "remove", commentId: commentId)
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                            liking = false
                                            likesCount = likesCount - 1
                                            heartScaleEffect = 1
                                            if localLikedComments.contains(commentId) {
                                                localLikedComments.remove(at: localLikedComments.firstIndex(of: commentId)!)
                                            }
                                            if !localDislikedComments.contains(commentId) {
                                                localDislikedComments.append(commentId)
                                            }
                                        }
                                    }else{
                                        liked = true
                                        try await self.sendCommentLikesFunc.sendLike(type: "insert", commentId: commentId)
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                            liking = false
                                            likesCount = likesCount + 1
                                            heartScaleEffect = 1
                                            if !localLikedComments.contains(commentId) {
                                                localLikedComments.append(commentId)
                                            }
                                            if localDislikedComments.contains(commentId) {
                                                localDislikedComments.remove(at: localDislikedComments.firstIndex(of: commentId)!)
                                            }
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
                    .onAppear{
                        if likes.contains(soundlytudeUserId()) {
                            localLikedComments.append(commentId)
                            checkedLiked = true
                        }
                        if localLikedComments.contains(commentId){
                            liked = true
                        }else{
                            liked = false
                        }
//                        likesCount = likes.count + (localLikedComments.contains(commentId) ? 1 : 0)
                        likesCount = likes.count
                        if !likes.contains(soundlytudeUserId()) {
                            likesCount = likesCount + (localLikedComments.contains(commentId) ? 1 : 0)
                        }
                    }
                    .padding(.trailing, 7.5)
                    Spacer()
                    HStack(spacing: 5){
                        Image(systemName: "bubble.right")
                        Text("\(replyCount)")
                            .font(.caption)
                            .lineLimit(1)
                    }
                    .foregroundColor(.gray)
                    .padding(.trailing, 7.5)
                    Spacer()
                    HStack(spacing: 5){
                        Image(systemName: "calendar")
                        Text(date)
                            .font(.caption)
                            .lineLimit(1)
                    }
                    .foregroundColor(.gray)
                    .padding(.trailing, 7.5)
                    Spacer()
                    Button {
                        //
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .foregroundColor(.gray)
                }
            }
        }
        .background(
            NavigationLink(destination: commentDetailsView(albumRootIsActive: $albumRootIsActive, type: type, commentId: commentId, artistName: artistName, slug: slug, pfp: pfp, verification: verification, comment: comment, date: date, createdTime: createdTime, artistId: artistId, artistThemeColor: artistThemeColor, replyCount: replyCount, likes: likes, albumId: albumId, ownerId: ownerId).environmentObject(Comment).environmentObject(globalVariables), isActive: $commentDetailsViewIsActive) {
                    EmptyView()
                }.hidden()
        )
        .background(
            NavigationLink(destination: navProfilePage(artistId: artistId), isActive: $profilePageIsActive) {
                EmptyView()
            }.hidden()
        )
        .padding(.horizontal, 15)
        .padding(.vertical, 5)
        .listRowBackground(Color.clear)
        .frame(maxWidth: .infinity)
        //
//        VStack(spacing: 0){
//            HStack(alignment: .top){
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
//                    HStack{
//                        Text(comment)
//                            .font(.body)
//                            .fontWeight(.regular)
//                        Spacer()
//                    }
//                    .contentShape(Rectangle())
//                    .onTapGesture {
//                        Comment.commentType = "Reply"
//                        Comment.commentFocused = true
//                        Comment.commentPlaceholder = "Reply to \(slug)..."
//                    }
//                    HStack(spacing: 10){
//                        Text(date)
//                            .font(.footnote)
//                            .foregroundColor(Color.gray)
//                        Text("Reply")
//                            .font(.footnote)
//                            .fontWeight(.bold)
//                            .onTapGesture {
//                                Comment.commentType = "Reply"
//                                Comment.commentFocused = true
//                                Comment.commentPlaceholder = "Reply to \(slug)..."
//                            }
//                        if likes.contains(ownerId){
//                            Sticker(text: "Liked by creator")
//                        }
//                    }.padding(.vertical, 5)
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
//                .padding()
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
//                                    try await self.sendCommentLikesFunc.sendLike(type: "remove", commentId: commentId)
//                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                                        liking = false
//                                        likesCount = likesCount - 1
//                                        heartScaleEffect = 1
//                                    }
//                                }else{
//                                    liked = true
//                                    try await self.sendCommentLikesFunc.sendLike(type: "insert", commentId: commentId)
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
//            }
//            .contextMenu {
//                Button {
//                    //
//                } label: {
//                    Label("Reply", systemImage: "arrowshape.turn.up.left.fill")
//                }
//                Button {
//                    profilePageIsActive = true
//                } label: {
//                    Label("View profile", systemImage: "person.fill")
//                }
//                Button {
//                    print("Report")
//                } label: {
//                    Label("Report comment", systemImage: "flag.fill")
//                }
//            }
//            VStack{
//                Spacer().frame(height: (hideReplies) ? 10 : 0)
//                ForEach(self.replyCommentsPageFetch.replyCommentPageFields, id: \._id) { i in
//                    replyCommentView(
//                        _id: i._id,
//                        slug: i.artistDetails.artistName,
//                        pfp: i.artistDetails.pimage,
//                        verification: i.artistDetails.verification ?? false,
//                        comment: i.richComment,
//                        date: i._createdDate,
//                        artistId: i.artistDetails._id,
//                        title: i.title,
//                        likes: i.likes ?? [],
//                        albumId: i.albumId,
//                        ownerId: i.ownerId
//                    ).padding(0)
//                        .environmentObject(Comment)
//                }
//                if replyCount > 0 {
//                    HStack{
//                        Spacer().frame(width: 50)
//                        HStack(spacing: 5){
//                            Text((replyCount > 1) ? "View \(repliesLeftCount) more replies" : "View 1 reply")
//                                .fontWeight(.bold)
//                                .padding(.vertical, 5)
//                                .font(.footnote)
//                                .onAppear{
//                                    repliesLeftCount = replyCount
//                                }
//                            if repliesDoneLoading {
//                                Image(systemName: "chevron.down")
//                            }else{
//                                ProgressView()
//                            }
//                        }
//                        .opacity(maxReplies ? 0 : 1)
//                        .onTapGesture {
//                            Task {
//                                if repliesDoneLoading {
//                                    do {
//                                        repliesDoneLoading = false
//                                        try await self.replyCommentsPageFetch.getMoreReplies(commentId: commentId)
//                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                                            repliesDoneLoading = true
//                                            repliesLeftCount = repliesLeftCount - 3
//                                            if repliesLeftCount < 1 {
//                                                maxReplies = true
//                                            }
//                                            hideReplies = true
//                                        }
//                                    } catch {
//                                        print("Error", error)
//                                    }
//                                }
//                            }
//                        }
//                        Spacer()
//                        Text((hideReplies) ? "Hide replies" : "")
//                            .fontWeight(.bold)
//                            .padding(.vertical, 5)
//                            .font(.footnote)
//                            .onTapGesture {
//                                withAnimation(.easeIn(duration: 0.1)) {
//                                    self.replyCommentsPageFetch.count = 0
//                                    hideReplies = false
//                                    maxReplies = false
//                                    repliesLeftCount = replyCount
//                                    self.replyCommentsPageFetch.replyCommentPageFields = []
//                                }
//                            }
//                    }
//                }
//            }
//        }
    }
    func repliesProgresser(){
        if(commentsPageRepliesFetchingCompleted){
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                repliesProgresser()
            }
        }
    }
}
//struct commentsView_Previews: PreviewProvider {
//    @State var albumRootIsActive: Bool = true
//    static var previews: some View {
//        commentView(albumRootIsActive: $albumRootIsActive)
//    }
//}

struct ViewHeightKey2: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value + nextValue()
    }
}

struct commentsPageArtistDetails: Hashable, Codable {
    let _id: String
    let artistName: String
    let slug: String
    let pimage: String
    let verification: Bool?
    let themeColor: String?
}

struct commentPageField: Hashable, Codable {
    let _id: String
    let richComment: String
    let ownerId: String
    let type: String
    let albumId: String
    let artistId: String
    let replyCount: Int
    let likes: Array<String>?
    let _createdDate: String
    let createdTime: String
    let artistDetails: commentsPageArtistDetails
}

class commentsPageFetchComments: ObservableObject {
    @Published var commentPageFields: [commentPageField] = []
    var totalFetch = 50
    @Published var count = 0
    
    func fetch(albumId:String) {
        guard let url = URL(string: HttpBaseUrl() + "/_functions/comments?password=z4Q2XL5gtvd8pL97p6tS&type=filterEq&columnId=albumId&value=\(albumId)&noItems=true&continueFrom=\(count)&totalFetch=\(totalFetch)") else {
            return}
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _,
            error in
            guard let data = data, error == nil else {
                return
            }
            // Convert to JSON
            do
            {
                let data = try JSONDecoder().decode ([commentPageField].self, from: data)
                DispatchQueue.main.async{
                    self?.commentPageFields = self!.commentPageFields + data
                    self?.count += self?.totalFetch ?? 50
                    commentsPageFetchingCompleted = true
                }
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }
}

struct sendCommentLikesField: Hashable, Codable {
    let message: String
}

class sendCommentLikes: ObservableObject {
    @Published var sendCommentLikesFields: [sendCommentLikesField] = []
    
    func sendLike(type: String, commentId: String) async throws {
        guard let url = URL(string: HttpBaseUrl() + "/_functions/commentLikes?password=JDsau1h5voCond5CB69Y") else { fatalError("Missing URL") }
        print(url)
        
        struct likeData: Codable {
            let _id: String
            let type: String
            let artistId: String
        }
        
        // Add data to the model
        let likesDataModel = likeData(_id: commentId, type: type, artistId: soundlytudeUserId())
        
        // Convert model to JSON data
        guard let jsonData = try? JSONEncoder().encode(likesDataModel) else {
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
        let decodedData = try JSONDecoder().decode([sendCommentLikesField].self, from: data)
        print("Checkpoint4")
        DispatchQueue.main.async{
            print("Checkpoint5")
            self.sendCommentLikesFields = decodedData
            if decodedData[0].message == "Success" {
                print("Done interaction")
            }
        }
    }
}

struct postCommentMessageField: Hashable, Codable {
    let scenario: String
    let message: String
}
class postComment: ObservableObject {
    @Published var postCommentMessageFields: [postCommentMessageField] = []
    
    func sendComment(comment: String, commentType: String, itemId: String, trackId: String, itemOwnerId: String, repliedToComment: String?, repliedCommentId: String?,  repliedReplyCommentId: String?) async throws {
        guard let url = URL(string: HttpBaseUrl() + "/_functions/comment?password=AbdQU69Yd7Z0qO5eRfCr") else { fatalError("Missing URL") }
        print(url)
        
        struct commentData: Codable {
            let comment: String
            let commentType: String
            let itemId: String
            let trackId: String
            let itemOwnerId: String
            let currentUserId: String
            let repliedToComment: String?
            let repliedCommentId: String?
            let repliedReplyCommentId: String?
        }
        
        // Add data to the model
        let commentDataModel = commentData(comment: comment, commentType: commentType, itemId: itemId, trackId: trackId, itemOwnerId: itemOwnerId, currentUserId: soundlytudeUserId(), repliedToComment: comment, repliedCommentId: repliedCommentId, repliedReplyCommentId: repliedReplyCommentId)
        
        // Convert model to JSON data
        guard let jsonData = try? JSONEncoder().encode(commentDataModel) else {
            print("Error: Trying to convert model to JSON data")
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type") // the request is JSON
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept") // the response expected to be in JSON format
        urlRequest.httpBody = jsonData
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        print("Checkpoint2")
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { print(response); return}
        print("Checkpoint3")
        let decodedData = try JSONDecoder().decode([postCommentMessageField].self, from: data)
        print("Checkpoint4")
        DispatchQueue.main.async{
            print("Checkpoint5")
            self.postCommentMessageFields = decodedData
            if decodedData[0].scenario == "Success" {
                print("Done commenting")
                print(decodedData[0].message)
                newCommentUpdatedId = decodedData[0].message
            }
        }
    }
}

var commentsHistory: [commentsHistoryField] = []

struct commentsHistoryField: Hashable, Codable {
    let commentDetails: commentPageField
    let baseCommentId: String
}
