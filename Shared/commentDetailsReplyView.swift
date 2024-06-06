//
//  commentDetailsReplyView.swift
//  Soundlytude (iOS)
//
//  Created by DJ bon26 on 7/15/23.
//

import SwiftUI

struct commentDetailsReplyView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var sendCommentLikesFunc = sendCommentLikes()
    
    @Binding var albumRootIsActive : Bool
    @EnvironmentObject var Comment : comment
    @EnvironmentObject var globalVariables: globalVariables
    
    @State var type: String = ""
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
    
    @State var showLikes: Bool = true
    
    @State var profilePageIsActive: Bool = false
    @State var commentDetailsViewIsActive: Bool = false
    
    @State var liked: Bool = false
    @State var repliesLeftCount = 0
    @State var hideReplies: Bool = false
    @State var maxReplies: Bool = false
    @State var repliesDoneLoading: Bool = true
    @State var heartScaleEffect: CGFloat = 1
    @State var liking: Bool = false
    @State var likesCount: Int = 10
    
    var themeColorMix: Color {
        return Color(UIColor.blend(color1: UIColor(Color(hexStringToUIColor(hex: "#\(artistThemeColor.replacingOccurrences(of: "#", with: ""))"))), intensity1: 0.8, color2: UIColor(colorScheme == .dark ? Color.white : Color.black), intensity2: 0.2))
    }
    
    var body: some View {
            HStack(alignment: .top, spacing:10){
                VStack(spacing: 0){
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
                    .onTapGesture {
                        profilePageIsActive = true
                    }
                    Capsule()
                        .foregroundColor(Color.secondarySystemFill)
                        .frame(maxWidth: 2, maxHeight: .infinity)
                        .cornerRadius(5)
                }
                VStack(alignment: .leading, spacing: 7.5){
                    HStack(spacing: 2.5){
                        Group{
                            Text("\(artistName)")
                                .fontWeight(.bold)
                                .lineLimit(1)
                                .foregroundColor(verification ? themeColorMix : nil)
                            if verification {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.caption)
                                    .foregroundColor(themeColorMix)
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
                                    themeColor: ""
                                )
                            ), baseCommentId: ""))
                        }
                        commentDetailsViewIsActive = true
                        Comment.commentFocused = false
                        globalVariables.hideTabBar = false
                        parentCommentId = ""
                        print("SHOULD NAVIGATE: ", commentDetailsViewIsActive)
                    } label: {
                        Text(comment)
                            .foregroundColor(Color("BlackWhite"))
                            .padding(.vertical, 5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    if likes.contains(ownerId){
                        Sticker(text: "Liked by creator")
                            .padding(.trailing, 7.5)
                    }
                    Divider()
                    HStack(spacing: 0){
                        if showLikes{
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
                            }
                            .foregroundColor(.gray)
                            .padding(.trailing, 7.5)
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
                        }
                        HStack(spacing: 5){
                            Image(systemName: "bubble.right")
                            Text("\(replyCount)")
                                .font(.caption)
                        }
                        .foregroundColor(.gray)
                        .padding(.trailing, 7.5)
                        Spacer()
                        HStack(spacing: 5){
                            Image(systemName: "calendar")
                            Text("\(date)")
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
                        Spacer()
                        Button {
                            //
                        } label: {
                            Image(systemName: "flag")
                        }
                        .foregroundColor(.gray)
                    }
                }
                .padding(.bottom, 10)
            }
            .padding(.horizontal, 15)
            .background(
                NavigationLink(destination: navProfilePage(artistId: artistId), isActive: $profilePageIsActive) {
                    EmptyView()
                }.hidden()
            )
            .background(
                NavigationLink(destination: commentDetailsView(albumRootIsActive: $albumRootIsActive, type: type, commentId: commentId, artistName: artistName, slug: slug, pfp: pfp, verification: verification, comment: comment, date: date, createdTime: createdTime, artistId: artistId, artistThemeColor: artistThemeColor, replyCount: replyCount, likes: likes, albumId: albumId, ownerId: ownerId).environmentObject(Comment), isActive: $commentDetailsViewIsActive) {
                    EmptyView()
                }.hidden()
            )
    }
}

//struct commentDetailsReplyView_Previews: PreviewProvider {
//    static var previews: some View {
//        commentDetailsReplyView()
//    }
//}
