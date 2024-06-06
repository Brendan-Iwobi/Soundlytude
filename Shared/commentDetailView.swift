//
//  commentDetailView.swift
//  Soundlytude (iOS)
//
//  Created by DJ bon26 on 7/15/23.
//

import SwiftUI

var currentViewingCommentId = ""
var parentCommentId = ""
var localLikedComments: Array<String> = []
var localDislikedComments: Array<String> = []

struct commentDetailsView: View {
    @Binding var albumRootIsActive : Bool
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.colorScheme) var colorScheme
    
    
    @EnvironmentObject var globalVariables: globalVariables
    
    @FocusState private var commentInputFocused: Bool
    @EnvironmentObject var Comment : comment
    
    @State var type: String = ""
    @State var commentId: String = ""
    @State var artistName: String = ""
    @State var slug: String = ""
    @State var pfp: String = ""
    @State var verification: Bool = false
    @State var comment: String = ""
    @State var date: String = "Date"
    @State var createdTime: String = "Date"
    @State var artistId: String = "_id"
    @State var artistThemeColor: String = "000000"
    @State var replyCount: Int = 0
    @State var likes: Array<String> = []
    @State var albumId: String = ""
    @State var ownerId: String = ""
    
    @State var replies: [replyCommentPageField] = []
    @State var isFetchingItems: Bool = false
    @State var hasFetchingItems: Bool = false
    
    @State var stopLooping: Bool = false
    @State var hasScrolled: Bool = false
    @State var localCommentHistory: [commentsHistoryField] = []
     
    @State var detailHeight: Double = 0
    @State var repliesHeight: Double = 0
    
    @StateObject var commentsPageFetch = commentsPageFetchComments()
    @StateObject var postCommentFunc = postComment()
    @State var textEditorHeight : CGFloat = 20
    var emojis: Array<String> = ["🔥","🥰","🎵","💓","😮","💨","😮‍💨","⛽"]
    
    var disableSubmit: Bool {
        if Comment.commentText.replacingOccurrences(of: " ", with: "") == "" {
            return true
        }else {
            return false
        }
    }
    
    var body: some View{
        ZStack{
            ScrollViewReader { value in
                ScrollView{
                    VStack{
                        ZStack{
                            VStack(spacing: 0){
                                Button {
                                    print("root is no longer active")
                                    albumRootIsActive = false
                                } label: {
                                    commentDetailAlbumView()
                                }
                                ForEach(0..<localCommentHistory.count, id:\.self){i in
                                    let x = localCommentHistory[i].commentDetails
                                    if x._id == commentId{
                                        //
                                    } else{
                                        commentDetailsReplyView(albumRootIsActive: $albumRootIsActive, type: x.type, commentId: x._id, artistName: x.artistDetails.artistName, slug: x.artistDetails.slug, pfp: x.artistDetails.pimage, verification: x.artistDetails.verification ?? false, comment: x.richComment, date: x._createdDate, createdTime: x.createdTime, artistId: x.artistId, artistThemeColor: x.artistDetails.themeColor ?? "000000", replyCount: x.replyCount, likes: x.likes ?? [], showLikes: true).environmentObject(globalVariables)
                                    }
                                }
                            }.overlay(
                                VStack{
                                    Spacer()
                                    if stopLooping && !isFetchingItems {
                                        Rectangle()
                                            .fill(.clear)
                                            .frame(width: viewableWidth, height: 50)
                                            .id("break")
                                            .onAppear{
                                                if !hasScrolled{
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                        withAnimation(.easeIn(duration: 0.1)){
                                                            value.scrollTo("break", anchor: .top)
                                                            hasScrolled = true
                                                        }
                                                    }
                                                }
                                            }
                                    }
                                }
                            )
                        }
                        commentDetailView(commentId: commentId, artistName: artistName, slug: slug, pfp: pfp, verification: verification, comment: comment, date: date, createdTime: createdTime, artistId: artistId, artistThemeColor: artistThemeColor, replyCount: replyCount, likes: likes, albumId: albumId, ownerId: ownerId)
                            .onTapGesture {
                                print("tapped")
                                //                                self.rootPresentationMode.wrappedValue.dismiss()
                            }
                            .overlay(
                                GeometryReader { geo in
                                    Text("")
                                        .onAppear{
                                            detailHeight = geo.size.height
                                        }
                                }
                            )
                        ForEach(0..<replies.count, id:\.self){i in
                            let x = replies[i]
                            if type == "Comment"{
                                if x.type == "Reply"{
                                    commentDetailsReplyView(albumRootIsActive: $albumRootIsActive, type: x.type, commentId: x._id, artistName: x.artistDetails.artistName, slug: x.artistDetails.slug, pfp: x.artistDetails.pimage, verification: x.artistDetails.verification ?? false, comment: x.richComment, date: x._createdDate, createdTime: x.createdTime, artistId: x.artistId, artistThemeColor: artistThemeColor, replyCount: x.replyCount).environmentObject(globalVariables)
                                }
                            }else{
                                commentDetailsReplyView(albumRootIsActive: $albumRootIsActive, type: x.type, commentId: x._id, artistName: x.artistDetails.artistName, slug: x.artistDetails.slug, pfp: x.artistDetails.pimage, verification: x.artistDetails.verification ?? false, comment: x.richComment, date: x._createdDate, createdTime: x.createdTime, artistId: x.artistId, artistThemeColor: artistThemeColor, replyCount: x.replyCount).environmentObject(globalVariables)
                            }
                        }
                        .overlay(
                            GeometryReader { geo in
                                Text("")
                                    .onAppear{
                                        repliesHeight = geo.size.height
                                    }
                            }
                        )
                        if isFetchingItems {
                            HStack{
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        }
                        Spacer().frame(height: (viewableHeight - (detailHeight + repliesHeight + 60)) < 1 ? 1 : (viewableHeight - (detailHeight + repliesHeight + 60))) //60 for the padding
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
                }
                .onAppear{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                        getReplies(commentId: commentId, type: type)
                        if commentsHistory.count > 0 {
                            if commentsHistory[0].baseCommentId != currentViewingCommentId {
                                commentsHistory = []
                                localLikedComments = []
                            }
                        }
                        var stop = false
                        if !stopLooping {
                            for x in 0..<commentsHistory.count {
                                let y = commentsHistory[x].commentDetails
                                if !stop{
                                    if y._id == commentId{
                                        stop = true
                                        stopLooping = true
                                    } else{
                                        localCommentHistory.append(commentsHistory[x])
                                    }
                                }
                            }
                        }
                        stopLooping = true
                    }
                }
                .toolbar{
                    ToolbarItem(placement: .navigation){
                        Button {
                            if commentInputFocused {
                                Comment.commentFocused = false
                                commentInputFocused = false
                                globalVariables.hideTabBar = false
                            }else{
                                Comment.commentPlaceholder = "Add reply..."
                                Comment.commentType = (type == "Comment") ? "Reply" : "Replying to reply"
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
                                    Text("Reply")
                                }
                            }
                        }
                    }
                }
            }
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
                                    Color.clear.preference(key: ViewHeightKey4.self,
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
                        .onPreferenceChange(ViewHeightKey4.self) {
                            textEditorHeight = $0
                        }
                        Button {
                            let id2 = "toBeDeleted" + String(Float.random(in: 1..<3))
                            if Comment.commentType != "Comment" {
                                Task {
                                    do {
                                        let toAdd = replyCommentPageField(
                                            _id: id2,
                                            richComment: Comment.commentText,
                                            ownerId: soundlytudeUserId(),
                                            type: Comment.commentType,
                                            albumId: albumId,
                                            artistId: soundlytudeUserId(),
                                            _createdDate: "Just now", createdTime: "2932", replyCount: 0 ,
                                            likes: [],
                                            title: Comment.commentType,
                                            artistDetails: commentsPageArtistDetails(_id: soundlytudeUserId(), artistName: currentUser.artistName, slug: currentUser.slug, pimage: newlyUpdatedPfpUrl, verification: true, themeColor: ""))
                                        replies = [toAdd] + replies
                                        
                                        try await self.postCommentFunc.sendComment(comment: Comment.commentText, commentType: Comment.commentType, itemId: albumId, trackId: "", itemOwnerId: currentViewingAlbum.artistDetails._id, repliedToComment: comment, repliedCommentId: (Comment.commentType == "Reply") ? commentId : parentCommentId, repliedReplyCommentId: (Comment.commentType == "Reply") ? "" : commentId)
                                        Comment.commentText = ""
                                    } catch {
                                        print(error)
                                    }
                                }
                            }
                            Comment.commentFocused = false
                            commentInputFocused = false
                            parentCommentId = ""
                            globalVariables.hideTabBar = false
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
    }
    
    func getReplies(commentId: String, type: String) {
        isFetchingItems = true
        let totalFetch = 50
        guard let url = URL(string: HttpBaseUrl() + "/_functions/comments?password=z4Q2XL5gtvd8pL97p6tS&type=filterEqReply&columnId=reliedCommentId&value=\(commentId)&commentType=\(type.replacingOccurrences(of: " ", with: "-"))&noItems=true&totalFetch=\(totalFetch)") else {
                print("Error: cannot create URL")
                return
            }
            // Create the url request
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil else {
                    print("Error: error calling GET")
                    print(error!)
                    return
                }
                guard let data = data else {
                    print("Error: Did not receive data")
                    return
                }
                guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                    print("Error: HTTP request failed")
                    return
                }
                do
                {
                    let data = try JSONDecoder().decode ([replyCommentPageField].self, from: data)
                    DispatchQueue.main.async{
                        replies = data
                        isFetchingItems = false
                    }
                }
                catch {
                    isFetchingItems = false
                    print(error)
                }
            }.resume()
        }
}

struct commentDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var sendCommentLikesFunc = sendCommentLikes()
    
    @State var commentId: String = ""
    @State var artistName: String = "Artist name"
    @State var slug: String = "editorium"
    @State var pfp: String = ""
    @State var verification: Bool = false
    @State var comment: String = "This is a comment!"
    @State var date: String = "Date"
    @State var createdTime: String = "Date"
    @State var artistId: String = "_id"
    @State var artistThemeColor: String = "000000"
    @State var replyCount: Int = 0
    @State var likes: Array<String> = []
    @State var albumId: String = ""
    @State var ownerId: String = ""
    
    @State var liked: Bool = false
    @State var profilePageIsActive: Bool = false
    @State var repliesLeftCount = 0
    @State var hideReplies: Bool = false
    @State var maxReplies: Bool = false
    @State var repliesDoneLoading: Bool = true
    @State var heartScaleEffect: CGFloat = 1
    @State var liking: Bool = false
    @State var likesCount: Int = 35555
    
    var themeColorMix: Color {
        return Color(UIColor.blend(color1: UIColor(Color(hexStringToUIColor(hex: "#\(artistThemeColor.replacingOccurrences(of: "#", with: ""))"))), intensity1: 0.8, color2: UIColor(colorScheme == .dark ? Color.white : Color.black), intensity2: 0.2))
    }
    
    var body: some View {
        VStack(spacing:7.5){
                HStack(spacing: 5){
                    AsyncImage(url: URL(string: "\(pfp)/v1/fill/w_64,h_64,al_c/Soundlytude.jpg")) { image in
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
                    }
                    .frame(width: 40, height: 40)
                    .cornerRadius(50)
                    VStack(alignment: .leading){
                        HStack(spacing: 2.5){
                            Text(artistName)
                                .font(.callout)
                                .fontWeight(.bold)
                                .lineLimit(1)
                                .foregroundColor(verification ? themeColorMix : nil)
                            if verification {
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
                        Text("@\(slug)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .lineLimit(1)
                            .foregroundColor(Color.gray)
                    }
                    Spacer()
                    Button {
                        //
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
                VStack(alignment: .leading, spacing: 7.5){
                    Text(comment)
                        .padding(.vertical, 5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if likes.contains(ownerId) {
                        Sticker(text: "Liked by creator")
                            .padding(.trailing, 7.5)
                    }
                    Divider()
                    HStack(spacing: 5){
                        Text("\(formatAMPM(time: createdTime))")
                        Text("•")
                        Text("\(formatToFullDateStyle(time: createdTime))")
                    }
                    .font(.callout)
                    .foregroundColor(.gray)
                    Divider()
                    HStack(spacing: 20){
                        HStack(spacing: 5){
                            Text("\(likesCount)")
                                .fontWeight(.bold)
                            Text("Likes")
                                .font(.callout)
                                .foregroundColor(.gray)
                        }
                        HStack(spacing: 5){
                            Text("\(replyCount)")
                                .fontWeight(.bold)
                            Text("Replies")
                                .font(.callout)
                                .foregroundColor(.gray)
                        }
                    }
                    Divider()
                    HStack(spacing: 0){
                        Spacer()
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
                            .animation(.interpolatingSpring(stiffness: 250, damping: 20), value: heartScaleEffect)
                            .foregroundColor(.gray)
                            .onAppear{
                                if localLikedComments.contains(commentId){
                                    liked = true
                                }else{
                                    liked = false
                                }
                                
//                                if likes.contains(soundlytudeUserId()) {
//                                    if !localLikedComments.contains(commentId) {
//                                        localLikedComments.append(commentId)
//                                    }
//                                }
//                                if localLikedComments.contains(commentId){
//                                    liked = true
//                                }
////                                likesCount = likes.count + (localLikedComments.contains(commentId) ? 1 : 0)
                                likesCount = likes.count
                                if !likes.contains(soundlytudeUserId()) {
                                    likesCount = likesCount + (localLikedComments.contains(commentId) ? 1 : 0)
                                }
                            }
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
                        Spacer()
                            Image(systemName: "bubble.right")
                            .foregroundColor(.gray)
                        Spacer()
                        Button {
                            //
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                        .foregroundColor(.gray)
                        Spacer()
                        Button {
                            //
                        } label: {
                            Image(systemName: "flag")
                        }
                        .foregroundColor(.gray)
                        Spacer()
                    }
                    Divider()
                }
            }.padding(.horizontal, 15)
    }
    
}

struct commentDetailView_Previews: PreviewProvider {
    static var previews: some View {
        commentDetailView()
    }
}

struct replyCommentPageField: Hashable, Codable {
    let _id: String
    let richComment: String
    let ownerId: String
    let type: String
    let albumId: String
    let artistId: String
    let _createdDate: String
    let createdTime: String
    let replyCount: Int
    let likes: Array<String>?
    let title: String
    let artistDetails: commentsPageArtistDetails
}

struct ViewHeightKey4: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value + nextValue()
    }
}
