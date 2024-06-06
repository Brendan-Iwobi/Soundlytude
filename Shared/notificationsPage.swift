//
//  notiicationsPage.swift
//  Soundlytude
//
//  Created by DJ bon26 on 9/5/22.
//

import SwiftUI

var NotifFetchingCompleted: Bool = false

struct notificationsPage: View {
    @StateObject var NFetch = NotifFetchData1()
    @State var isDoneLoading: Bool = false
    @State var isDoneRefreshing: Bool = true
    @State var isRefreshingTimeout:Double = 0.0
    @State private var presentAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    
    @State var notifLimit: Int = 2
    @State var disableNotifLoadMore: Bool = false
    @State var initNotifLoadError: Bool = false
    
    @EnvironmentObject var globalVariables: globalVariables
    
    var body: some View {
        NavigationView{
            if isDoneLoading {
                    List(){
                        ForEach(0..<NFetch.NotifFields.count, id: \.self){ i in
                            let x = NFetch.NotifFields[i]
                            VStack{
                                if(x.type == "New like") {
                                    notificationsRepeater2(
                                        data: self.NFetch.NotifFields[i],
                                        displayMessage: "liked your music.",
                                        isLast: true,
                                        listData: self.NFetch
                                    ).environmentObject(globalVariables)
                                }
                                if(x.type == "New comment like") {
                                    notificationsRepeater2(
                                        data: self.NFetch.NotifFields[i],
                                        displayMessage: "liked your comment.",
                                        isLast: true,
                                        listData: self.NFetch
                                    ).environmentObject(globalVariables)
                                }
                                if(x.type == "New follower") {
                                    notificationsFollowRepeater2(
                                        data: self.NFetch.NotifFields[i],
                                        displayMessage: "is now following you.",
                                        isLast: true,
                                        listData: self.NFetch
                                    ).environmentObject(globalVariables)
                                }
                                if(x.type == "New comment") {
                                    notificationsRepeater2(
                                        data: self.NFetch.NotifFields[i],
                                        displayMessage: "commented on your music.",
                                        isLast: true,
                                        listData: self.NFetch
                                    ).environmentObject(globalVariables)
                                }
                                if(x.type == "New reply") {
                                    notificationsRepeater2(
                                        data: self.NFetch.NotifFields[i],
                                        displayMessage: x.message,
                                        isLast: true,
                                        listData: self.NFetch
                                    ).environmentObject(globalVariables)
                                }
                                if(x.type == "Message from soundlytude") {
                                    notificationsMsgRepeater2(
                                        data: self.NFetch.NotifFields[i],
                                        displayMessage: x.message,
                                        isLast: true,
                                        listData: self.NFetch
                                    ).environmentObject(globalVariables)
                                }
                            }
                        }
                        if NFetch.NotifFields.count > 20{
                            Text("Limited to 30 recent notifications")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        if NFetch.NotifFields.count < 1 && !initNotifLoadError{
                            noItemsView(title: "No notifications", message: "When there's an information you need to know, we'll notify you here")
                        }
                        if initNotifLoadError {
                            tapToRetryView(title: "Couldn't load notifications")
                                .onTapGesture {
                                    Task{
                                        do{
                                            try await NFetch.fetch(limit: notifLimit, action: "load", artistId: soundlytudeUserId(), previouslyFetched: NFetch.NotifFields)
                                            isDoneLoading = true
                                            initNotifLoadError = false
                                        }
                                        catch{
                                            alertTitle = "WARNING"
                                            alertMessage = "There was an error loading your notifications"
                                            presentAlert = true
                                            initNotifLoadError = true
                                        }
                                    }
                                }
                        }
                        if !disableNotifLoadMore {
                            Button {
                                Task{
                                    do {
                                        disableNotifLoadMore = true
                                        try await NFetch.fetch(limit: notifLimit, action: "load", artistId: soundlytudeUserId(), previouslyFetched: NFetch.NotifFields)
                                        if notifLoadMoreCount == 0 || notifLoadMoreCount < notifLimit {
                                            disableNotifLoadMore = true
                                        }else{
                                            disableNotifLoadMore = false
                                        }
                                    }catch{
                                        print(error)
                                        disableNotifLoadMore = false
                                    }
                                }
                            } label: {
                                Text("Load more")
                            }
                            .disabled(disableNotifLoadMore)
                        }
                        bottomSpace()
                    }
                    .opacity((isDoneRefreshing) ? 1.0 : 0.5)
                    .disabled((isDoneRefreshing) ? false : true)
                    .refreshable {
                        Task{
                            do {
                                isDoneRefreshing = false
                                try await NFetch.fetch(limit: -1, action: "refresh", artistId: soundlytudeUserId(), previouslyFetched: NFetch.NotifFields)
                                isDoneRefreshing = true
                            }catch{
                                alertTitle = "WARNING"
                                alertMessage = "An error occurred trying to refresh"
                                presentAlert = true
                                isDoneRefreshing = true
                            }
                        }
                    }
                    .onAppear{
                        UIRefreshControl.appearance().tintColor = UIColor(Color("RefresherTint"))
                    }
                    .alert(alertTitle, isPresented: $presentAlert, actions: {
                        // actions
                    }, message: {
                        Text(alertMessage)
                    })
                    .listStyle(PlainListStyle())
                    .navigationTitle("Notifications")
            }else{
                VStack{
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.accentColor))
                        .onAppear{
                            Task{
                                do{
                                    try await NFetch.fetch(limit: notifLimit, action: "load", artistId: soundlytudeUserId(), previouslyFetched: NFetch.NotifFields)
                                    isDoneLoading = true
                                    initNotifLoadError = false
                                }
                                catch{
                                    alertTitle = "WARNING"
                                    alertMessage = "There was an error loading your notifications"
                                    presentAlert = true
                                    initNotifLoadError = true
                                }
                            }
                        }
                }
                .alert(alertTitle, isPresented: $presentAlert, actions: {
                    // actions
                }, message: {
                    Text(alertMessage)
                })
                .navigationTitle("Notifications")
            }
        }
    }
    
    func refresher() {//not using
        if(NotifFetchingCompleted){
            print("done")
            isDoneRefreshing = true
            isRefreshingTimeout = 0
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                refresher()
                if (NotifFetchingCompleted == false){
                    print("Still fetching")
                    isRefreshingTimeout = isRefreshingTimeout + Double(0.25)
                    print(isRefreshingTimeout)
                    isDoneRefreshing = false
                }
                if (isRefreshingTimeout > Double(15)){
                    alertTitle = "Refresh timeout"
                    alertMessage = "Refreshing took too long, Check your internet connection and try again"
                    presentAlert = true
                    isDoneRefreshing = true
                    NotifFetchingCompleted = true
                    print("Time out")
                }
            }
        }
    }
    
    func refreshing() async {
        // demo, assume we update something long here
        try? await Task.sleep(nanoseconds: (isDoneRefreshing) ? 1_000_000_000 : 5_000_000_000)
    }
}

struct listView: View  {
    var NFetch = NotifFetchData()
    var body: some View{
        List(){
            ForEach(NFetch.NotifFields, id: \._id){ i in
                VStack{
                    if(i.type == "New comment like") {
                        notificationsRepeater(
                            artistName: i.artistDetails.artistName,
                            displayMessage: "liked your comment.",
                            pfpUrl: i.artistDetails.pimage,
                            message: i.message,
                            _id: i._id,
                            read: i.readUnread,
                            verification: i.artistDetails.verification ?? false,
                            timeMessage: i._createdDate
                        )
                    }
                    if(i.type == "New comment") {
                        notificationsRepeater(
                            artistName:i.artistDetails.artistName,
                            displayMessage: "commented on your music.",
                            pfpUrl: i.artistDetails.pimage,
                            message: i.message,
                            _id: i._id,
                            read: i.readUnread,
                            verification: i.artistDetails.verification ?? false,
                            timeMessage: i._createdDate
                        )
                    }
                    if(i.type == "New reply") {
                        notificationsRepeater(
                            artistName:i.artistDetails.artistName,
                            displayMessage: "replied to your comment.",
                            pfpUrl: i.artistDetails.pimage,
                            message: i.message,
                            _id: i._id,
                            read: i.readUnread,
                            verification: i.artistDetails.verification ?? false,
                            timeMessage: i._createdDate
                        )
                    }
                    if(i.type == "New like") {
                        notificationsRepeater(
                            artistName:i.artistDetails.artistName,
                            displayMessage: "liked your music.",
                            pfpUrl: i.artistDetails.pimage,
                            message: i.message,
                            _id: i._id,
                            read: i.readUnread,
                            verification: i.artistDetails.verification ?? false,
                            timeMessage: i._createdDate
                        )
                    }
                    if(i.type == "New follower") {
                        notificationsFollowRepeater(
                            artistId: i.artistDetails._id,
                            artistName:i.artistDetails.artistName,
                            displayMessage: "is now following you.",
                            pfpUrl: i.artistDetails.pimage,
                            _id: i._id,
                            read: i.readUnread,
                            verification: i.artistDetails.verification ?? false,
                            timeMessage: i._createdDate
                        )
                    }
                    if(i.type == "Message from soundlytude") {
                        notificationsMsgRepeater(displayMessage: i.message)
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Notifications")
    }
}

struct verfificationBatch: View {
    var body: some View {
        Image("Soundlytude verification icon")
            .resizable()
            .frame(width: 20, height: 20, alignment: .leading)
    }
}

struct notificationsFollowRepeater: View {
    var artistId: String
    var artistName: String
    var displayMessage: String
    var pfpUrl: String
    var _id: String
    var read: String
    var verification: Bool
    var timeMessage: String
    
    @StateObject var NFetch = NotifFetchData()
    @State private var presentAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationLink(destination: profilePage(artistId: artistId, navigatedTo: true).navigationBarBackButtonHidden(true), label: {
            HStack{
                circleImage40by40(urlString: pfpUrl)
                HStack{
                    VStack(alignment: .leading){
                        (Text(artistName) + Text((verification) ? " \(Image(systemName: "checkmark.seal.fill"))" : ""))
                            .font(.body)
                            .fontWeight(.bold)
                            .lineLimit(1)
                        HStack(spacing: 0){
                            Text(displayMessage)
                                .font(.caption)
                                .fontWeight(.medium)
                                .lineLimit(3)
                            Text(" \(timeMessage)")
                                .font(.caption)
                                .foregroundColor(Color.gray)
                                .fontWeight(.regular)
                                .lineLimit(3)
                        }
                    }
                    Spacer()
                    (read == "false") ? SBlueDot(scale: 7.5) : nil
                }
            }
        })
        .swipeActions(edge: .trailing, allowsFullSwipe: true){
            Button(role: .destructive) {
                deleteData(deletedUrl: HttpBaseUrl() + "/_functions/notification?password=fRwi7U7jptHS04iINFH6&itemId=" + _id)
            } label: {
                Text("Delete")
            }
        }.swipeActions(edge: .leading, allowsFullSwipe: true) {
            (read == "false") ?
            Button() {
                presentAlert = true
                alertMessage = "This notification will eventually be marked as read"
            } label: {
                Text("Mark as read")
            }.tint(Color.accentColor)
            : nil
        }
        .alert("Completed", isPresented: $presentAlert, actions: {
            // actions
        }, message: {
            Text(alertMessage)
        })
    }
}

struct notificationsFollowRepeater2: View {
    var data: NotifField
    var displayMessage: String
    var isLast: Bool
    @ObservedObject var listData: NotifFetchData1
    
    @StateObject var NFetch = NotifFetchData()
    @State private var presentAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationLink(destination: profilePage(artistId: data.artistDetails._id, navigatedTo: true).navigationBarBackButtonHidden(true), label: {
            HStack{
                circleImage40by40(urlString: data.artistDetails.pimage)
                HStack{
                    VStack(alignment: .leading){
                        (Text(data.artistDetails.artistName) + Text((data.artistDetails.verification ?? false) ? " \(Image(systemName: "checkmark.seal.fill"))" : ""))
                            .font(.body)
                            .fontWeight(.bold)
                            .lineLimit(1)
                        HStack(spacing: 0){
                            Text(displayMessage)
                                .font(.caption)
                                .fontWeight(.medium)
                                .lineLimit(3)
                            Text(" \(formatToDateStyle2(time: "\(data.createdTime)"))")
                                .font(.caption)
                                .foregroundColor(Color.gray)
                                .fontWeight(.regular)
                                .lineLimit(3)
                        }
                    }
                    Spacer()
                    (data.readUnread == "false") ? SBlueDot(scale: 7.5) : nil
                }
            }
        })
        .swipeActions(edge: .trailing, allowsFullSwipe: true){
            Button(role: .destructive) {
                deleteData(deletedUrl: HttpBaseUrl() + "/_functions/notification?password=fRwi7U7jptHS04iINFH6&itemId=" + data._id)
            } label: {
                Text("Delete")
            }
        }.swipeActions(edge: .leading, allowsFullSwipe: true) {
            (data.readUnread == "false") ?
            Button() {
                presentAlert = true
                alertMessage = "This notification will eventually be marked as read"
            } label: {
                Text("Mark as read")
            }.tint(Color.accentColor)
            : nil
        }
        .alert("Completed", isPresented: $presentAlert, actions: {
            // actions
        }, message: {
            Text(alertMessage)
        })
    }
}

struct notificationsRepeater: View {
    @EnvironmentObject var globalVariables: globalVariables
    
    var artistName: String
    var displayMessage: String
    var pfpUrl: String
    var message: String
    var _id: String
    var read: String
    var verification: Bool
    var timeMessage: String
    
    @StateObject var NFetch = NotifFetchData1()
    @State private var presentAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationLink(destination: albumPage().environmentObject(globalVariables), label: {
            HStack{
                circleImage40by40(urlString: self.pfpUrl)
                HStack{
                    VStack(alignment: .leading){
                        (Text(artistName) + Text((verification) ? " \(Image(systemName: "checkmark.seal.fill"))" : ""))
                            .font(.body)
                            .fontWeight(.bold)
                            .lineLimit(1)
                        HStack(spacing: 0){
                            Text(displayMessage)
                                .font(.caption)
                                .fontWeight(.medium)
                                .lineLimit(3)
                            Text(" \(timeMessage)")
                                .font(.caption)
                                .foregroundColor(Color.gray)
                                .fontWeight(.regular)
                                .lineLimit(3)
                        }
                        Text(message)
                            .font(.caption)
                            .foregroundColor(Color.gray)
                            .lineLimit(3)
                    }
                    Spacer()
                    (read == "false") ? SBlueDot(scale: 7.5) : nil
                }
            }
        })
        .swipeActions(edge: .trailing, allowsFullSwipe: true){
            Button(role: .destructive) {
                deleteData(deletedUrl: HttpBaseUrl() + "/_functions/notification?password=fRwi7U7jptHS04iINFH6&itemId=" + _id)
            } label: {
                Text("Delete")
            }
        }.swipeActions(edge: .leading, allowsFullSwipe: true) {
            (read == "false") ?
            Button() {
                presentAlert = true
                alertMessage = "This notification will eventually be marked as read"
            } label: {
                Text("Mark as read")
            }.tint(.blue)
            : nil
        }
        .alert("Completed", isPresented: $presentAlert, actions: {
            // actions
        }, message: {
            Text(alertMessage)
        })
        
    }
}

struct notificationsRepeater2: View {
    var data: NotifField
    var displayMessage: String
    var isLast: Bool
    @ObservedObject var listData: NotifFetchData1
    
    @EnvironmentObject var globalVariables: globalVariables
    
    @State private var presentAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationLink(destination: albumPage().environmentObject(globalVariables), label: {
            HStack{
                circleImage40by40(urlString: self.data.artistDetails.pimage)
                HStack{
                    VStack(alignment: .leading){
                        (Text(data.artistDetails.artistName) + Text((data.artistDetails.verification ?? false) ? " \(Image(systemName: "checkmark.seal.fill"))" : ""))
                            .font(.body)
                            .fontWeight(.bold)
                            .lineLimit(1)
                        HStack(spacing: 0){
                            Text(displayMessage)
                                .font(.caption)
                                .fontWeight(.medium)
                                .lineLimit(3)
                            Text(" \(formatToDateStyle2(time: "\(data.createdTime)"))")
                                .font(.caption)
                                .foregroundColor(Color.gray)
                                .fontWeight(.regular)
                                .lineLimit(3)
                        }
                        Text(data.message)
                            .font(.caption)
                            .foregroundColor(Color.gray)
                            .lineLimit(3)
                    }
                    Spacer()
                    (data.readUnread == "false") ? SBlueDot(scale: 7.5) : nil
                }
            }
        })
        .swipeActions(edge: .trailing, allowsFullSwipe: true){
            Button(role: .destructive) {
                deleteData(deletedUrl: HttpBaseUrl() + "/_functions/notification?password=fRwi7U7jptHS04iINFH6&itemId=" + data._id)
            } label: {
                Text("Delete")
            }
        }.swipeActions(edge: .leading, allowsFullSwipe: true) {
            (data.readUnread == "false") ?
            Button() {
                presentAlert = true
                alertMessage = "This notification will eventually be marked as read"
            } label: {
                Text("Mark as read")
            }.tint(.blue)
            : nil
        }
        .alert("Completed", isPresented: $presentAlert, actions: {
            // actions
        }, message: {
            Text(alertMessage)
        })
        
    }
}

struct notificationsMsgRepeater: View {
    var displayMessage: String
    
    var body: some View {
        HStack{
            Image(systemName: "info.circle")
                .foregroundColor(.gray)
                .font(.system(size: 30))
                .frame(width: 40, height: 40)
            VStack(alignment: .leading){
                Text("Message from Soundlytude:")
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer().frame(height: 10)
                Text(displayMessage)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct notificationsMsgRepeater2: View {
    var data: NotifField
    var displayMessage: String
    var isLast: Bool
    @ObservedObject var listData: NotifFetchData1
    
    var body: some View {
        HStack{
            Image(systemName: "info.circle")
                .foregroundColor(.gray)
                .font(.system(size: 30))
                .frame(width: 40, height: 40)
            VStack(alignment: .leading){
                Text("Message from Soundlytude:")
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer().frame(height: 10)
                Text(displayMessage)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct notificationsPage_Previews: PreviewProvider {
    static var previews: some View {
        notificationsPage()
    }
}

struct NotifArtistDetails: Hashable, Codable {
    let _id: String
    let artistName: String
    let pimage: String
    let verification: Bool?
}

struct NotifField: Hashable, Codable {
    let _id: String
    let message: String
    let type: String
    let readUnread: String
    let _createdDate: String
    let createdTime: Int
    let artistDetails: NotifArtistDetails
}

class NotifFetchData: ObservableObject {
    @Published var NotifFields: [NotifField] = []
    
    func fetch() {
        NotifFetchingCompleted = false
        guard let url = URL(string: HttpBaseUrl() + "/_functions/notifications?password=yxlnC5325fDZ6x61PcDr&type=filterEq&columnId=recieverId&value=\(soundlytudeUserId())&limit=128&noItems=true") else {
            return}
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _,
            error in
            guard let data = data, error == nil else {
                return
            }
            // Convert to JSON
            do
            {
                let data = try JSONDecoder().decode ([NotifField].self,
                                                     from: data)
                DispatchQueue.main.async{
                    self?.NotifFields = data
                    NotifFetchingCompleted = true
                }
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }
    
    func fetchUpdate() async throws {
        guard let url = URL(string: HttpBaseUrl() + "/_functions/notifications?password=yxlnC5325fDZ6x61PcDr&type=filterEq&columnId=recieverId&value=\(soundlytudeUserId())&limit=128&noItems=true") else {
            return}
        let urlRequest = URLRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { print(response); return}
        let decodedData = try JSONDecoder().decode([NotifField].self, from: data)
        DispatchQueue.main.async{
            self.NotifFields = decodedData
            NotifFetchingCompleted = true
        }
    }
}

class NotifFetchData1: ObservableObject {
    @Published var NotifFields: [NotifField] = []
    
    func fetch(limit: Int, action: String, artistId: String, previouslyFetched: [NotifField]) async throws {
        guard let url = URL(string: HttpBaseUrl() + "/_functions/getNotifications?password=yxlnC5325fDZ6x61PcDr&action=\(action)&limit=\(limit)") else { fatalError("Missing URL") }
        print(url)
        
        struct notifGetData: Codable {
            let artistId: String
            let previouslyFetched: [NotifField]
        }
        
        // Add data to the model
        let notifGetDataModel = notifGetData(artistId: soundlytudeUserId(), previouslyFetched: previouslyFetched)
        
        // Convert model to JSON data
        guard let jsonData = try? JSONEncoder().encode(notifGetDataModel) else {
            print("Error: Trying to convert model to JSON data")
            return
        }
        
        print("Checkpoint1notif-700s")
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type") // the request is JSON
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept") // the response expected to be in JSON format
        urlRequest.httpBody = jsonData
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        print("Checkpoint2notif-700s")
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { print(response); return}
        let decodedData = try JSONDecoder().decode([NotifField].self, from: data)
        DispatchQueue.main.async{
            print("Checkpoint3notif-700s")
            if action == "refresh" {
                self.NotifFields = decodedData
            }else{
                self.NotifFields = self.NotifFields + decodedData
                notifLoadMoreCount = decodedData.count
            }
        }
    }
}
