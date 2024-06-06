//
//  editProfilePage.swift
//  Soundlytude (iOS)
//
//  Created by DJ bon26 on 1/5/23.
//

import SwiftUI

struct editProfilePage: View {
    @StateObject var CurrentUserAccInfo = currentUserAccInfo()
    @StateObject var alert = AlertClass()
    @Environment(\.colorScheme) var colorScheme
    
    @Environment(\.dismiss) var dismiss
    
    var accentColorMix: Color {
        return Color(UIColor.blend(color1: UIColor(Color(hexStringToUIColor(hex: "#\(CurrentUserAccInfo.themeColor.replacingOccurrences(of: "#", with: ""))"))), intensity1: 0.8, color2: UIColor(colorScheme == .dark ? Color.white : Color.black), intensity2: 0.2))
    }
    
    var body: some View {
//       NavigationView {
            List {
                Group{
                    NavigationLink{
                        editProfileImageView()
                    }label: {
                        HStack{
                            listLabel(title: "Profile picture", label: /*CurrentUserAccInfo.username*/ "")
                            Spacer()
                            PFPcircleImageCustomSize(resolution: 32, multiply: 2)
                        }
                    }
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
                        listLabel(title: "Profile information", label: /*CurrentUserAccInfo.username*/ "...")
                    }
                }
                .alert(alert.alertTitle, isPresented: $alert.presentAlert, actions: {
                    Button("OK", role: .cancel, action: {dismiss()})
                }, message: {
                    Text(alert.alertMessage)
                })
                .listRowSeparator(.hidden)
            }
            .tint(accentColorMix)
            .accentColor(accentColorMix)
            .navigationTitle("Edit profile")
//        }
    }
}

struct editProfilePage_Previews: PreviewProvider {
    static var previews: some View {
        editProfilePage()
    }
}

struct editProfileImage: View {
    @State var showImagePicker:Bool = false
    @State var selectedImage: Image? = Image("")
    
    var body: some View {
        VStack{
            HStack(spacing: 10){
                    Button {
                        showImagePicker.toggle()
                    } label: {
                        ZStack{
                            circleImageCustomSize(urlString: local.string(forKey: "currentUserArtistPfp") ?? "", resolution: 128)
                            Color.black.opacity(0.5)
                                .cornerRadius(128)
                            Image(systemName: "camera")
                                .foregroundColor(.white)
                        }
                    }
                    .frame(width: 128, height: 128)
                    .sheet(isPresented: $showImagePicker) {
                        ImagePicker(image: $selectedImage)
                    }
                self.selectedImage?
                    .resizable()
                    .frame(maxWidth: 128, maxHeight: 128)
                    .scaledToFit()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
                    .cornerRadius(128)
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y:0)
            }
            Spacer()
        }
            .navigationTitle("Edit profile")
    }
}

struct UpdatePFPResponse: Hashable, Codable {
    let pimage: String
    let status: String
}

struct editProfileImageView: View {
    
    let response: [UpdatePFPResponse] = []
    @State private var isShowingPhotoSelectionSheet = false
    
    @State private var finalImage: UIImage?
    @State private var inputImage: UIImage?
    @State var oldImage: Bool = true
    
    @State var buffer: String = ""
    @State var loading: Bool = false
    @State private var presentAlert = false
    @State private var presentAlertTitle = ""
    @State private var presentAlertMessage = ""
    
    var disableSave: Bool {
        if (loading) {
            return true
        }else{
            if (oldImage) {
                return true
            }else {
                return false
            }
        }
    }
    
    var body: some View {
        VStack {
            if finalImage != nil {
                Image(uiImage: finalImage!)
                    .resizable()
                    .frame(width: 256, height: 256)
                    .scaledToFill()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            } else {
                circleImageCustomSize(urlString: local.string(forKey: "currentUserArtistPfp") ?? "", resolution: 256, multiply: Int(1.5))
            }
            Button (action: {
                self.isShowingPhotoSelectionSheet = true
            }, label: {
                Text("Change photo")
            })
        }
        .background(Color.systemBackground)
        .statusBar(hidden: isShowingPhotoSelectionSheet)
        .fullScreenCover(isPresented: $isShowingPhotoSelectionSheet, onDismiss: loadImage) {
            ImageMoveAndScaleSheet(croppedImage: $finalImage.onChange(onImageChanged))
        }
        .toolbar{
            ToolbarItem(placement: .navigation){
                Button {
                    saveImage()
                } label: {
                    Text((loading) ? "Saving" : "Save")
                }
                .disabled(disableSave)
                .onAppear{
                    print("IMAGELOADING:", oldImage, loading)
                }
            }
        }
        .alert(presentAlertTitle, isPresented: $presentAlert, actions: {
            Button("OK", role: .cancel, action: {})
        }, message: {
            Text(presentAlertMessage)
        })
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        if finalImage == inputImage{
            print("Same image")
        }
        finalImage = inputImage
    }
    
    
    func saveImage() {
        loading = true
        guard let profileImage = finalImage else { return }
        let uiImage: UIImage = profileImage
        let imageData: Data = uiImage.jpegData(compressionQuality: 0.1) ?? Data()
        let imageStr: String = imageData.base64EncodedString()
        buffer = "data:image/jpeg;base64,\(imageStr)"
        postMethod()
    }
    
    func postMethod() {
        guard let url = URL(string: HttpBaseUrl() + "/_functions/savePfp?password=fqYR5iS5ZM74KydLc14p&artistId=\(soundlytudeUserId())") else {
            print("Error: cannot create URL")
            return
        }
        
        // Create model
        struct UploadData: Codable {
            let dataURI: String
            let userId: String
            let artistName: String
        }
        
        // Add data to the model
        let uploadDataModel = UploadData(dataURI: buffer, userId: soundlytudeUserId(), artistName: local.string(forKey: "currentUserArtistName") ?? "")
        
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
                presentAlertMessage = "Error accessing data, check your internet connection"
                return
            }
            guard let data = data else {
                print("Error: Did not receive data")
                presentAlert = true
                presentAlertTitle = "WARNING"
                presentAlertMessage = "Error receiving data"
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                print("Error: HTTP request failed", response)
                presentAlert = true
                presentAlertTitle = "WARNING"
                presentAlertMessage = "Failed to change your profile picture"
                return
            }
            do {
                let data2 = try JSONDecoder().decode ([UpdatePFPResponse].self, from: data)
                let imageUrl = data2[0].pimage
                DispatchQueue.main.async{
                    print("url: ", imageUrl)
                }
                local.set(imageUrl, forKey: "currentUserArtistPfp")
                newlyUpdatedPfpUrl = imageUrl
                loading = false
                oldImage = true
                presentAlert = true
                presentAlertTitle = "Account updated"
                presentAlertMessage = "Your profile picture has been successfully updated.  Others will now see your changes, you may need to restart the app to see your changes"
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
                return
            }
        }.resume()
    }
    
    func onImageChanged(to value: UIImage?) {
        oldImage = false
    }
}
