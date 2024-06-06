//
//  settings.swift
//  Soundlytude (iOS)
//
//  Created by DJ bon26 on 11/26/22.
//

import SwiftUI
import iPhoneNumberField

class currentUserAccInfo: ObservableObject {
    @Published var artistName: String = partistName
    @Published var username: String = pusername
    @Published var bio: String = pbio
    @Published var genre: String = pgenre
    @Published var themeColor: String = pthemeColor
    @Published var dateOfBirth: String = pdateOfBirth
    @Published var biography: String = pbiography
    @Published var firstName: String = pfirstName
    @Published var lastName: String = plastName
    @Published var phone: String = pphone
    @Published var email: String = pemail
    @Published var emailCommentNotif: Bool = pEmailCommentNotif
    @Published var emailLikesNotif: Bool = pEmailLikesNotif
    @Published var emailFollowNotif: Bool = pEmailFollowNotif
    @Published var accountCommentNotif: Bool = pAccountCommentNotif
    @Published var accountLikesNotif: Bool = pAccountLikesNotif
    @Published var accountFollowNotif: Bool = pAccountFollowNotif
    @Published var hideFollowerFollowing: Bool = pHideFollowerFollowing
    @Published var hideLikes: Bool = pHideLikes
}

var partistName: String = ""
var pusername: String = ""
var pbio: String = ""
var pgenre: String = ""
var pthemeColor: String = ""
var pdateOfBirth: String = ""
var pbiography: String = ""
var pfirstName: String = ""
var plastName: String = ""
var pphone: String = ""
var pemail: String = ""
var pEmailCommentNotif: Bool = false
var pEmailLikesNotif: Bool = false
var pEmailFollowNotif: Bool = false
var pAccountCommentNotif: Bool = false
var pAccountLikesNotif: Bool = false
var pAccountFollowNotif: Bool = false
var pHideFollowerFollowing: Bool = false
var pHideLikes: Bool = false

private var value1: Bool = false
private var value2: Bool = false
private var value3: Bool = false
private var value4: Bool = false
private var value5: Bool = false
private var value6: Bool = false

class AlertClass: ObservableObject {
    @Published var presentAlert: Bool = false
    @Published var alertTitle: String = "title"
    @Published var alertMessage: String = "alert"
}

struct settings: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @StateObject var CurrentUserAccInfo = currentUserAccInfo()
    @StateObject var alert = AlertClass()
    
    @EnvironmentObject var customColorScheme : CustomColorScheme
    var previewOptions = ["Always", "When Unlocked", "Never"]
    
    @State var isPrivate: Bool = true
    @State var notificationsEnabled: Bool = false
    @State private var previewIndex = 0
    @State var colorScheme: Int = Int(local.string(forKey: "colorScheme") ?? "0") ?? 0
    @State var viee = 0
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Form {
            Group{
                Section(header: Text("ACCOUNT")) {
                    NavigationLink{
                        profileInformation(
                            artistName: CurrentUserAccInfo.artistName,
                            username: CurrentUserAccInfo.username,
                            bio: CurrentUserAccInfo.bio,
                            genre: CurrentUserAccInfo.genre,
                            biography: CurrentUserAccInfo.biography,
                            dateOfBirth: CurrentUserAccInfo.dateOfBirth,
                            themeColor: CurrentUserAccInfo.themeColor
                        )
                        .environmentObject(CurrentUserAccInfo)
                        .environmentObject(alert)
                    }label: {
                        HStack{
                            Image(systemName: "person.crop.circle")
                                .foregroundColor(.gray)
                            Text("Profile information")
                        }
                    }
                    NavigationLink{
                        personalInformation(
                            firstName: CurrentUserAccInfo.firstName,
                            lastName: CurrentUserAccInfo.lastName,
                            phone: CurrentUserAccInfo.phone,
                            email: CurrentUserAccInfo.email
                        )
                        .environmentObject(CurrentUserAccInfo)
                        .environmentObject(alert)
                    }label: {
                        HStack{
                            Image(systemName: "person.fill")
                                .foregroundColor(.gray)
                            Text("Personal information")
                        }
                    }
                    NavigationLink{
                        accountNotificationSettings(
                            emailCommentNotif: CurrentUserAccInfo.emailCommentNotif,
                            emailLikesNotif: CurrentUserAccInfo.emailLikesNotif,
                            emailFollowNotif: CurrentUserAccInfo.emailFollowNotif,
                            accountCommentNotif: CurrentUserAccInfo.accountCommentNotif,
                            accountLikesNotif: CurrentUserAccInfo.accountLikesNotif,
                            accountFollowNotif: CurrentUserAccInfo.accountFollowNotif
                        )
                        .navigationTitle("Account notification settings")
                        .environmentObject(CurrentUserAccInfo)
                        .environmentObject(alert)
                    }label: {
                        HStack{
                            Image(systemName: "bell.fill")
                                .foregroundColor(.gray)
                            Text("Account notification settings")
                        }
                    }
                    NavigationLink{
                        passwordAndPrivacy(
                            hideFollowerFollowing: CurrentUserAccInfo.hideFollowerFollowing,
                            hideLikes: CurrentUserAccInfo.hideLikes
                        )
                        .navigationTitle("Password and Privacy")
                        .environmentObject(CurrentUserAccInfo)
                    }label: {
                        HStack{
                            Image(systemName: "lock.fill")
                                .foregroundColor(.gray)
                            Text("Password and privacy")
                        }
                    }
                }
                Section(header: Text("CONTENT AND DISPLAY")) {
                    Picker("Appearance", selection: $colorScheme.onChange(saveColorScheme)) {
                        Text("System default").tag(0)
                        Text("Light").tag(1)
                        Text("Dark").tag(2)
                    }
                    Toggle(isOn: $notificationsEnabled) {
                        Text("Enabled")
                    }
                    Picker(selection: $previewIndex, label: Text("Show Previews")) {
                        ForEach(0 ..< previewOptions.count) {
                            Text(self.previewOptions[$0])
                        }
                    }
                }
                Section(header: Text("NOTIFICATIONS")) {
                    Toggle(isOn: $notificationsEnabled) {
                        Text("Enabled")
                    }
                    Picker(selection: $previewIndex, label: Text("Show Previews")) {
                        ForEach(0 ..< previewOptions.count) {
                            Text(self.previewOptions[$0])
                        }
                    }
                }
                
                Section(header: Text("ABOUT")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0")
                    }
                }
                
                Section {
                    NavigationLink {
                        logoutScreen()
                    } label: {
                        HStack{
                            Image(systemName: "door.left.hand.open")
                            Text("Log out")
                        }.foregroundColor(.red)
                    }
                }
                bottomSpace()
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
            .listRowSeparator(.hidden)
            .alert(alert.alertTitle, isPresented: $alert.presentAlert, actions: {
                Button("OK", role: .cancel, action: {dismiss()})
            }, message: {
                Text(alert.alertMessage)
            })
        }
        //        .listStyle(GroupedListStyle())
        .navigationTitle("Settings and privacy")
    }
    
    func saveColorScheme(to value: Int){
        var scheme: String {
            if colorScheme == 0 {
                return "0"
            }
            if colorScheme == 1 {
                return "1"
            }
            if colorScheme == 2 {
                return "2"
            }
            return ""
        }
        customColorScheme.customColorScheme = scheme
        local.set(scheme, forKey: "colorScheme")
        print(colorScheme, scheme)
    }
}

struct logoutScreen: View {
    let _id = local.string(forKey: "soundlytudeUserId") ?? ""
    let artistName = local.string(forKey: "currentUserArtistName") ?? ""
    let password = local.string(forKey: "currentUserPassword") ?? ""
    let slug = local.string(forKey: "currentUsername") ?? ""
    let email = local.string(forKey: "currentUserEmail") ?? ""
    let pimage = local.string(forKey: "currentUserArtistPfp") ?? ""
    var body: some View {
        Form{
            Section(header: Text("SAVE LOGIN INFORMATION")){
                Button(role: .cancel) {
                    stop()
                    //Delete the current user from logged in users
                    deleteCurrentUser()
                    //Re-insert the logged in user to loggedInUsers to update it incase any changes were made
                    loggedInUsers.append(User(
                        _id: soundlytudeUserId(),
                        artistName: currentUser.artistName,
                        password: currentUser.password,
                        slug: currentUser.slug,
                        email: currentUser.email,
                        pimage: currentUser.pimage
                    ))
                    local.set("", forKey: "soundlytudeUserId")
                    local.set("", forKey: "currentUserArtistName")
                    local.set("", forKey: "currentUserPassword")
                    local.set("", forKey: "currentUsername")
                    local.set("", forKey: "currentUserEmail")
                    local.set("", forKey: "currentUserArtistPfp")
                    //Overwrite the loggedInUsers in the local storage (Just incase)
                    if let data = try? PropertyListEncoder().encode(loggedInUsers) {
                        local.set(data, forKey: "LoggedInUsers")
                    }
                    AppState.shared.soundlytudeId = UUID()
                } label: {
                    Text("Log out")
                }
            }
            Section(header: Text("DELETE LOGIN INFORMATION")){
                Button(role: .cancel) {
                    stop()
                    //Delete the current user from logged in users
                    deleteCurrentUser()
                    local.set("", forKey: "soundlytudeUserId")
                    local.set("", forKey: "currentUserArtistName")
                    local.set("", forKey: "currentUserPassword")
                    local.set("", forKey: "currentUsername")
                    local.set("", forKey: "currentUserEmail")
                    local.set("", forKey: "currentUserArtistPfp")
                    //Overwrite the loggedInUsers in the local storage with the newly updated one
                    if let data = try? PropertyListEncoder().encode(loggedInUsers) {
                        local.set(data, forKey: "LoggedInUsers")
                    }
                    AppState.shared.soundlytudeId = UUID()
                } label: {
                    Text("Sign out")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Log out")
    }
    
    func deleteCurrentUser() {
        var index = -1
        var currentUserIndex = 0
        for i in 0 ..< loggedInUsers.count {
            index = index + 1
            if loggedInUsers[i]._id == soundlytudeUserId(){
                currentUserIndex = index
            }
        }
        loggedInUsers.remove(at: currentUserIndex)
        print("loggedInUsers2.0", loggedInUsers)
    }
}

struct accountNotificationSettings: View {
    @EnvironmentObject var CurrentUserAccInfo : currentUserAccInfo
    @EnvironmentObject var alert : AlertClass
    
    @StateObject var saveUpdateAccountClass = SaveUpdateAccountClass()
    
    @State var emailCommentNotif: Bool
    @State var emailLikesNotif: Bool
    @State var emailFollowNotif: Bool
    @State var accountCommentNotif: Bool
    @State var accountLikesNotif: Bool
    @State var accountFollowNotif: Bool
    
    @State var disableSave: Bool = false
    var body: some View{
        List{
            Section(header: Text("EMAIL")) {
                Toggle(isOn: $emailLikesNotif) {
                    Text("Like notifications")
                }
                Toggle(isOn: $emailCommentNotif) {
                    Text("Comment notifications")
                }
                Toggle(isOn: $emailFollowNotif) {
                    Text("Follow notifications")
                }
            }
            .listRowSeparator(.hidden)
            Section(header: Text("NOTIFICATIONS")) {
                Toggle(isOn: $accountLikesNotif) {
                    Text("Like notifications")
                }
                Toggle(isOn: $accountCommentNotif) {
                    Text("Comment notifications")
                }
                Toggle(isOn: $accountFollowNotif) {
                    Text("Follow notifications")
                }
            }
            .listRowSeparator(.hidden)
        }
        .toolbar{
            ToolbarItem(placement: .navigation){
                Button {
                    Task{
                        do {
                            disableSave = true
                            CurrentUserAccInfo.emailLikesNotif = emailLikesNotif
                            CurrentUserAccInfo.emailCommentNotif = emailCommentNotif
                            CurrentUserAccInfo.emailFollowNotif = emailFollowNotif
                            CurrentUserAccInfo.accountLikesNotif = accountLikesNotif
                            CurrentUserAccInfo.accountCommentNotif = accountCommentNotif
                            CurrentUserAccInfo.accountFollowNotif = accountFollowNotif
                            value1 = emailLikesNotif
                            value2 = emailCommentNotif
                            value3 = emailFollowNotif
                            value4 = accountLikesNotif
                            value5 = accountCommentNotif
                            value6 = accountFollowNotif
                            try await saveUpdateAccountClass.saveUpdateAccount(fieldId: "notification", value: "")
                            alert.presentAlert = true
                            alert.alertTitle = "Account updated"
                            alert.alertMessage = "Your changes to your notification settings has been successfully saved"
                            disableSave = false
                        }catch{
                            print("Error")
                        }
                    }
                } label: {
                    Text((disableSave) ? "Saving..." : "Save")
                }.disabled(disableSave)
            }
        }
    }
}

struct passwordAndPrivacy: View {
    @EnvironmentObject var CurrentUserAccInfo : currentUserAccInfo
    
    @State var hideFollowerFollowing: Bool
    @State var hideLikes: Bool
    @State var presentAlertTitle: String = ""
    @State var presentAlert: Bool = false
    @State var presentAlertMessage: String = ""
    @State var disableSave: Bool = false
    var body: some View{
        List{
            Section(header: Text("SOCIAL")) {
                Toggle(isOn: $hideFollowerFollowing) {
                    Text("Hide Followers and following list")
                }
                Toggle(isOn: $hideLikes) {
                    Text("Hide liked music")
                }
            }
            .listRowSeparator(.hidden)
            Section(header: Text("PASSOWRD")) {
                Button {
                    presentAlertTitle = "Confirm email"
                    presentAlertMessage = "Reset your password by following the instructions sent to \(local.string(forKey: "currentUserEmail") ?? "")"
                    presentAlert = true
                } label: {
                    Text("Change password")
                }
                .alert(presentAlertTitle, isPresented: $presentAlert, actions: {
                    Button("OK", role: .cancel, action: {})
                }, message: {
                    Text(presentAlertMessage)
                })
            }
            .listRowSeparator(.hidden)
        }
        .toolbar{
            ToolbarItem(placement: .navigation){
                Button {
                    CurrentUserAccInfo.hideFollowerFollowing = hideFollowerFollowing
                    CurrentUserAccInfo.hideLikes = hideLikes
                } label: {
                    Text("Save")
                }.disabled(disableSave)
            }
        }
    }
}

struct profileInformation: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var CurrentUserAccInfo : currentUserAccInfo
    @EnvironmentObject var alert : AlertClass
    
    @StateObject var saveUpdateAccountClass = SaveUpdateAccountClass()
    
    @State var artistName: String
    @State var username: String
    @State var bio: String
    @State var genre: String
    @State var biography: String
    @State var dateOfBirth: String
    @State var themeColor: String
    
    @State var disableSave: Bool = false
    @State var dateOfBirthDate: Date = Date.now
    
    @State var colorPickerCustom: Bool = false
    @State var fieldEditorIsVisible: Bool = false
    
    var body: some View {
        List {
            Group{
                NavigationLink{
                    let x = "This is the name you go by on Soundlytude. Name something nice"
                    listTextField(title: "Artist name", description: x, text: $artistName)
                        .onAppear{fieldEditorIsVisible = true}
                        .toolbar{
                            ToolbarItem(placement: .navigation){
                                Button {
                                    Task{
                                        do {
                                            disableSave = true
                                            CurrentUserAccInfo.artistName = artistName
                                            local.set(artistName, forKey: "currentUserArtistName")
                                            try await saveUpdateAccountClass.saveUpdateAccount(fieldId: "artistName", value: artistName)
                                            alert.presentAlert = true
                                            alert.alertTitle = "Account updated"
                                            alert.alertMessage = "Your artist name has been successfully updated"
                                            disableSave = false
                                        }catch{
                                            print("Error")
                                            alert.presentAlert = true
                                            alert.alertTitle = "Account not updated"
                                            alert.alertMessage = "Your artist name has not been updated. There was an error"
                                        }
                                    }
                                } label: {
                                    Text((disableSave) ? "Saving..." : "Save")
                                }.disabled(disableSave)
                            }
                        }
                }label: {
                    listLabel(title: "Artist name", label: CurrentUserAccInfo.artistName)
                }
                NavigationLink{
                    let x = "This is your unique username for soundlytude. This will also be your URL slug. Your username should be a minimum of 3 letters and cannot contain Spaces or Uppercase letters"
                    listTextField(title: "Username", description: x, text: $username)
                        .onAppear{fieldEditorIsVisible = true}
                        .toolbar{
                            ToolbarItem(placement: .navigation){
                                Button {
                                    Task{
                                        do {
                                            disableSave = true
                                            CurrentUserAccInfo.username = username
                                            local.set(username, forKey: "currentUsername")
                                            try await saveUpdateAccountClass.saveUpdateAccount(fieldId: "slug", value: username)
                                            alert.presentAlert = true
                                            alert.alertTitle = "Account updated"
                                            alert.alertMessage = "Your username or slug has been successfully updated"
                                            disableSave = false
                                        }catch{
                                            print("Error")
                                            alert.presentAlert = true
                                            alert.alertTitle = "Account was not Updated"
                                            alert.alertMessage = "Your username or slug has been not been updated. There was an error"
                                        }
                                    }
                                } label: {
                                    Text((disableSave) ? "Saving..." : "Save")
                                }.disabled(disableSave)
                            }
                        }
                }label: {
                    listLabel(title: "Username", label: CurrentUserAccInfo.username)
                }
                NavigationLink{
                    let x = "This is your mini biography that a user first sees when they come to your profile"
                    listTextField(title: "Bio", description: x, text: $bio)
                        .onAppear{fieldEditorIsVisible = true}
                        .toolbar{
                            ToolbarItem(placement: .navigation){
                                Button {
                                    Task{
                                        do {
                                            disableSave = true
                                            CurrentUserAccInfo.bio = bio
                                            try await saveUpdateAccountClass.saveUpdateAccount(fieldId: "bio", value: bio)
                                            alert.presentAlert = true
                                            alert.alertTitle = "Account updated"
                                            alert.alertMessage = "Your bio has been successfully updated"
                                            disableSave = false
                                        }catch{
                                            print("Error")
                                            alert.presentAlert = true
                                            alert.alertTitle = "Account not updated"
                                            alert.alertMessage = "Your bio has not been updated. There was an error"
                                        }
                                    }
                                } label: {
                                    Text((disableSave) ? "Saving..." : "Save")
                                }.disabled(disableSave)
                            }
                        }
                }label: {
                    listLabel(title: "Bio", label: CurrentUserAccInfo.bio)
                }
                NavigationLink{
                    let x = "Add the genre you're into to see more music that matches your interest."
                    listTextField(title: "Genre", description: x, text: $genre)
                        .onAppear{fieldEditorIsVisible = true}
                        .toolbar{
                            ToolbarItem(placement: .navigation){
                                Button {
                                    Task{
                                        do {
                                            disableSave = true
                                            CurrentUserAccInfo.genre = genre
                                            try await saveUpdateAccountClass.saveUpdateAccount(fieldId: "genre", value: genre)
                                            alert.presentAlert = true
                                            alert.alertTitle = "Account updated"
                                            alert.alertMessage = "Your genre has been successfully updated to \(genre)"
                                            disableSave = false
                                        }catch{
                                            print("Error")
                                            alert.presentAlert = true
                                            alert.alertTitle = "Account not updated"
                                            alert.alertMessage = "Your genre has been not been updated to \(genre). There was an error"
                                        }
                                    }
                                } label: {
                                    Text((disableSave) ? "Saving..." : "Save")
                                }.disabled(disableSave)
                            }
                        }
                }label: {
                    listLabel(title: "Genre", label: CurrentUserAccInfo.genre)
                }
                NavigationLink{
                    let x = "Add a hex code that gives your profile a unique theme"
                    colorPickerView(title: "Theme color", description: x)
                        .onAppear{fieldEditorIsVisible = true}
                        .toolbar{
                            ToolbarItem(placement: .navigation){
                                Button {
                                    Task{
                                        do {
                                            disableSave = true
                                            CurrentUserAccInfo.themeColor = themeColor
                                            try await saveUpdateAccountClass.saveUpdateAccount(fieldId: "themeColor", value: themeColor)
                                            alert.presentAlert = true
                                            alert.alertTitle = "Account updated"
                                            alert.alertMessage = "The theme color for your profile has been successfully updated"
                                            disableSave = false
                                        }catch{
                                            print("Error")
                                            alert.presentAlert = true
                                            alert.alertTitle = "Account not updated"
                                            alert.alertMessage = "The theme color for your profile has not been updated. There was an error"
                                        }
                                    }
                                } label: {
                                    Text((disableSave) ? "Saving..." : "Save")
                                }.disabled(disableSave)
                            }
                        }
                }label: {
                    HStack{
                        listLabel(title: "Theme color", label: "#\(CurrentUserAccInfo.themeColor)")
                        Circle()
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color(hexStringToUIColor(hex: "#\(CurrentUserAccInfo.themeColor)")))
                    }
                }
                NavigationLink{
                    let x = "Select your date of birth. This will be used to display content appropriate for your age"
                    listDatePicker(
                        title: "Date of birth",
                        description: x,
                        dateOfBirth: CurrentUserAccInfo.dateOfBirth,
                        dateOfBirthDate: $dateOfBirthDate)
                    .onAppear{fieldEditorIsVisible = true}
                    .toolbar{
                        ToolbarItem(placement: .navigation){
                            Button {
                                Task{
                                    do {
                                        disableSave = true
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "YYYY-MM-dd" // Set Date Format
                                        let date = dateFormatter.string(from: dateOfBirthDate)
                                        CurrentUserAccInfo.dateOfBirth = date
                                        try await saveUpdateAccountClass.saveUpdateAccount(fieldId: "dateOfBirth", value: date)
                                        alert.presentAlert = true
                                        alert.alertTitle = "Account updated"
                                        alert.alertMessage = "Your date of birth has been successfully updated"
                                        disableSave = false
                                    }catch{
                                        print("Error")
                                        alert.presentAlert = true
                                        alert.alertTitle = "Account not updated"
                                        alert.alertMessage = "Your date of birth has not been updated. There was an error"
                                    }
                                }
                            } label: {
                                Text((disableSave) ? "Saving..." : "Save")
                            }.disabled(disableSave)
                        }
                    }
                    .navigationTitle("Date of birth")
                }label: {
                    listLabel(title: "Date of birth", label: CurrentUserAccInfo.dateOfBirth)
                }
                NavigationLink{
                    let x = "Add a full biography. This tells people who you fully are and will be displayed in your information tab on your profile"
                    listTextEditor(title: "Biography", description: x, text: $biography)
                        .onAppear{fieldEditorIsVisible = true}
                        .toolbar{
                            ToolbarItem(placement: .navigation){
                                Button {
                                    Task{
                                        do {
                                            disableSave = true
                                            CurrentUserAccInfo.biography = biography
                                            try await saveUpdateAccountClass.saveUpdateAccount(fieldId: "biography", value: biography)
                                            alert.presentAlert = true
                                            alert.alertTitle = "Account updated"
                                            alert.alertMessage = "Your biography has been successfully updated"
                                            disableSave = false
                                        }catch{
                                            print("Error")
                                            alert.presentAlert = true
                                            alert.alertTitle = "Account not updated"
                                            alert.alertMessage = "Your biography has not been updated. There was an error"
                                        }
                                    }
                                } label: {
                                    Text((disableSave) ? "Saving..." : "Save")
                                }.disabled(disableSave)
                            }
                        }
                }label: {
                    listLabel(title: "Biography", label: CurrentUserAccInfo.biography)
                }
            }
            .listRowSeparator(.hidden)
        }
        .onDisappear{
            if fieldEditorIsVisible == false {
                username = CurrentUserAccInfo.username
                genre = CurrentUserAccInfo.genre
                biography = CurrentUserAccInfo.biography
                dateOfBirth = CurrentUserAccInfo.dateOfBirth
                themeColor = CurrentUserAccInfo.themeColor
            }
        }
        .navigationTitle("Profile information")
    }
    
    @ViewBuilder
    func colorPickerView(title: String, description: String) -> some View {
        let colors: Array<String> = ["Cyan", "Red", "Soundlytude blue", "Yellow"]
        let hex: Array<String> = ["00FFFF", "FF0000", "7099FF", "FFF000"]
        VStack(spacing:10){
            Text(description)
                .font(.caption)
                .foregroundColor(.gray)
                .padding()
            List {
                ForEach(0..<colors.count, id:\.self){i in
                    Button {
                        themeColor = hex[i]
                        withAnimation(.easeIn(duration: 0.25)) {
                            colorPickerCustom = false
                        }
                    } label: {
                        HStack{
                            Image(systemName: "checkmark")
                                .foregroundColor(Color.accentColor)
                                .opacity((themeColor.uppercased() == hex[i]) ? 1 : 0)
                            Text(colors[i])
                            Spacer()
                            Circle()
                                .frame(width: 20, height: 20)
                                .foregroundColor(Color(hexStringToUIColor(hex: "#\(hex[i])")))
                        }.foregroundColor(Color("BlackWhite"))
                    }
                }
                Button {
                    withAnimation(.easeIn(duration: 0.25)) {
                        colorPickerCustom = true
                    }
                } label: {
                    HStack{
                        Image(systemName: "checkmark")
                            .foregroundColor(Color.accentColor)
                            .opacity((colorPickerCustom) ? 1 : 0)
                        Text("Custom")
                        Spacer()
                        Image(systemName: "number")
                    }.foregroundColor(Color("BlackWhite"))
                }
                if colorPickerCustom {
                    HStack{
                        Image(systemName: "number")
                            .foregroundColor(.gray)
                        TextField("Hex code", text: $themeColor)
                    }
                }
                HStack{
                    Spacer()
                    Circle()
                        .frame(width: 200, height: 200)
                        .foregroundColor(Color(hexStringToUIColor(hex: themeColor)))
                    Spacer()
                }
            }
            .listRowSeparator(.hidden)
            .listStyle(PlainListStyle())
        }
        .onAppear{
            themeColor = CurrentUserAccInfo.themeColor
            if hex.contains(CurrentUserAccInfo.themeColor.uppercased()) || CurrentUserAccInfo.themeColor.uppercased() == "" {
                colorPickerCustom = false
            }else{
                colorPickerCustom = true
            }
        }
        .navigationTitle(title)
    }
}

struct personalInformation: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var CurrentUserAccInfo : currentUserAccInfo
    @EnvironmentObject var alert : AlertClass
    
    @StateObject var saveUpdateAccountClass = SaveUpdateAccountClass()
    
    @State var firstName: String
    @State var lastName: String
    @State var phone: String
    @State var email: String
    
    @State var disableSave: Bool = false
    @State var fieldEditorIsVisible: Bool = false
    
    var body: some View {
        List {
            Group{
                NavigationLink{
                    let x = "Add a first name"
                    listTextField(title: "First name", description: x, text: $firstName)
                        .onAppear{fieldEditorIsVisible = true}
                        .toolbar{
                            ToolbarItem(placement: .navigation){
                                Button {
                                    Task{
                                        do {
                                            disableSave = true
                                            CurrentUserAccInfo.firstName = firstName
                                            try await saveUpdateAccountClass.saveUpdateAccount(fieldId: "firstName", value: firstName)
                                            alert.presentAlert = true
                                            alert.alertTitle = "Account updated"
                                            alert.alertMessage = "Your first name has been changed to \(firstName)"
                                            disableSave = false
                                        }catch{
                                            print("Error")
                                        }
                                    }
                                } label: {
                                    Text((disableSave) ? "Saving..." : "Save")
                                }.disabled(disableSave)
                            }
                        }
                }label: {
                    listLabel(title: "First name", label: CurrentUserAccInfo.firstName)
                }
                NavigationLink{
                    let x = "Add a last name"
                    listTextField(title: "Last name", description: x, text: $lastName)
                        .onAppear{fieldEditorIsVisible = true}
                        .toolbar{
                            ToolbarItem(placement: .navigation){
                                Button {
                                    Task{
                                        do {
                                            disableSave = true
                                            CurrentUserAccInfo.lastName = lastName
                                            try await saveUpdateAccountClass.saveUpdateAccount(fieldId: "lastName", value: lastName)
                                            alert.presentAlert = true
                                            alert.alertTitle = "Account updated"
                                            alert.alertMessage = "Your last name has been changed to \(lastName)"
                                            disableSave = false
                                        }catch{
                                            print("Error")
                                        }
                                    }
                                    self.presentationMode.wrappedValue.dismiss()
                                } label: {
                                    Text((disableSave) ? "Saving..." : "Save")
                                }.disabled(disableSave)
                            }
                        }
                }label: {
                    listLabel(title: "Last name", label: CurrentUserAccInfo.lastName)
                }
                NavigationLink{
                    let x = "Update your email. "
                    listTextField(title: "Email", description: x, text: $email)
                        .onAppear{fieldEditorIsVisible = true}
                        .toolbar{
                            ToolbarItem(placement: .navigation){
                                Button {
                                    Task{
                                        do {
                                            disableSave = true
                                            CurrentUserAccInfo.email = email
                                            local.set(email, forKey: "currentUserEmail")
                                            try await saveUpdateAccountClass.saveUpdateAccount(fieldId: "email", value: email)
                                            alert.presentAlert = true
                                            alert.alertTitle = "Account updated"
                                            alert.alertMessage = "Your email has been changed to \(email) for now"
                                            disableSave = false
                                        }catch{
                                            print("Error")
                                        }
                                    }
                                } label: {
                                    Text("Confirm")
                                }.disabled(disableSave)
                            }
                        }
                }label: {
                    listLabel(title: "Email", label: CurrentUserAccInfo.email)
                }
                NavigationLink{
                    let x = "Update your phone number"
                    listPhoneField(title: "Phone", description: x, text: $phone)
                        .onAppear{fieldEditorIsVisible = true}
                        .toolbar{
                            ToolbarItem(placement: .navigation){
                                Button {
                                    Task{
                                        do {
                                            disableSave = true
                                            CurrentUserAccInfo.phone = phone
                                            try await saveUpdateAccountClass.saveUpdateAccount(fieldId: "phone", value: phone)
                                            alert.presentAlert = true
                                            alert.alertTitle = "Account updated"
                                            alert.alertMessage = "Your phone number has been changed to \(phone). We won't verify it now because phone number is not yet in effect"
                                            disableSave = false
                                        }catch{
                                            print("Error")
                                        }
                                    }
                                } label: {
                                    Text((disableSave) ? "Saving..." : "Save")
                                }.disabled(disableSave)
                            }
                        }
                }label: {
                    listLabel(title: "Phone", label: CurrentUserAccInfo.phone)
                }
            }
            .listRowSeparator(.hidden)
        }
        .onDisappear{
            if fieldEditorIsVisible == false {
                firstName = CurrentUserAccInfo.firstName
                lastName = CurrentUserAccInfo.lastName
                email = CurrentUserAccInfo.email
                phone = CurrentUserAccInfo.phone
            }
        }
        .navigationTitle("Personal information")
    }
}


struct listLabel: View {
    var title: String
    var label: String
    var body: some View {
        HStack{
            Text(title)
            Spacer()
            Text(label)
                .lineLimit(1)
                .foregroundColor(.gray)
        }
    }
}

struct listTextField: View {
    var title: String
    var description: String
    @Binding var text: String
    var body: some View {
        VStack(spacing:10){
            Text(description)
                .font(.caption)
                .foregroundColor(.gray)
                .padding()
            List {
                TextField(title, text: $text)
            }.listStyle(GroupedListStyle())
        }
        .navigationTitle(title)
    }
}

struct listPhoneField: View {
    var title: String
    var description: String
    @Binding var text: String
    var body: some View {
        VStack(spacing:10){
            Text(description)
                .font(.caption)
                .foregroundColor(.gray)
                .padding()
            List {
                iPhoneNumberField(title, text: $text)
                    .flagHidden(false)
                    .flagSelectable(true)
                bottomSpace()
                    .listRowSeparator(.hidden)
            }.listStyle(GroupedListStyle())
        }
        .navigationTitle(title)
    }
}

struct listTextEditor: View {
    var title: String
    var description: String
    @Binding var text: String
    var body: some View {
        VStack(spacing:10){
            Text(description)
                .font(.caption)
                .foregroundColor(.gray)
                .padding()
//            List {
                ZStack(alignment: .topLeading){
                    if #available(iOS 16.0, *) {
                        TextEditor(text:$text)
                            .font(.body)
                            .frame(maxHeight: .infinity)
                            .scrollContentBackground(Visibility.hidden)
                    } else {
                        // Fallback on earlier versions
                        TextEditor(text:$text)
                            .font(.body)
                            .frame(maxHeight: .infinity)
                    }
                }.padding(.horizontal)
//            }.listStyle(GroupedListStyle())
            Spacer()
                .frame(height: tabBarMiniPlayerHeight)
        }
        .navigationTitle(title)
    }
}

struct listDatePicker: View {
    var title: String
    var description: String
    var dateOfBirth: String
    @Binding var dateOfBirthDate: Date
    var body: some View {
        VStack(spacing:10){
            Text(description)
                .font(.caption)
                .foregroundColor(.gray)
                .padding()
            List {
                DatePicker(title, selection: $dateOfBirthDate, displayedComponents: .date)
                    .onAppear{
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "YYYY-MM-dd"
                        if dateOfBirth == "None" {
                            //
                        }else{
                            guard let date = dateFormatter.date(from: dateOfBirth) else {
                                return
                            }
                            dateOfBirthDate = date
                        }
                    }
            }.listStyle(GroupedListStyle())
        }
        .navigationTitle(title)
    }
}

struct messageReturnedField: Hashable, Codable {
    let message1: String
}

class SaveUpdateAccountClass: ObservableObject {
    @Published var messageReturnedFields: [messageReturnedField] = []
    @State var CurrentUserAccInfo = currentUserAccInfo()
    
    func saveUpdateAccount(fieldId: String, value: String) async throws {
        guard let url = URL(string: HttpBaseUrl() + "/_functions/updateArtist?password=0IephR2hl1H33yg4Iyvl") else { fatalError("Missing URL") }
        struct UploadData: Codable {
            let artistId: String
            let fieldId: String
            let value: String
            let bool1: Bool
            let bool2: Bool
            let bool3: Bool
            let bool4: Bool
            let bool5: Bool
            let bool6: Bool
        }
        let uploadDataModel = UploadData(
            artistId: soundlytudeUserId(),
            fieldId: fieldId,
            value: value,
            bool1: value1,
            bool2: value2,
            bool3: value3,
            bool4: value4,
            bool5: value5,
            bool6: value6
        )
        
        guard let jsonData = try? JSONEncoder().encode(uploadDataModel) else {
            print("Error: Trying to convert model to JSON data")
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type") // the request is JSON
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept") // the response expected to be in JSON format
        urlRequest.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { print(response); return}
        let decodedData = try JSONDecoder().decode([messageReturnedField].self, from: data)
        DispatchQueue.main.async{
            self.messageReturnedFields = decodedData
            if decodedData[0].message1 == "Success" {
                print("Done updating")
            }
        }
    }
}
