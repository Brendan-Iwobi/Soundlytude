//
//  uploadImage.swift
//  Soundlytude
//
//  Created by DJ bon26 on 10/23/22.
//

import SwiftUI
import Photos


struct uploadImage: View {
    @StateObject var uploadImageUpload = uploadImageClass()
    
    @State var showImagePicker:Bool = false
    @State var selectedImage: Image? = Image("")
    @State var buffer: String = ""
    var body: some View {
        ScrollView{
            VStack{
                Button {
                    self.showImagePicker.toggle()
                } label: {
                    Text("Select Image")
                }
                self.selectedImage?.resizable().scaledToFit()
                Image(base64String: buffer)?.resizable().scaledToFit()
                Button {
                    print("Converting to base64...")
                    let uiImage: UIImage = self.selectedImage.asUIImage()
                    let imageData: Data = uiImage.jpegData(compressionQuality: 0.1) ?? Data()
                    let imageStr: String = imageData.base64EncodedString()
                    buffer = "data:image/jpeg;base64,\(imageStr)"
                    postMethod()
                    UIPasteboard.general.string = buffer
                } label: {
                    Text("Upload Image")
                }
                Spacer()
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage)
            }
        }
    }
    func postMethod2 (){
        guard let url = URL(string: HttpBaseUrl() + "/_functions/upload?password=fqYR5iS5ZM74KydLc14p") else {
            print("Error: cannot create URL")
            return
        }
        let paramStr: String = buffer
        let paramData: Data = paramStr.data(using: .utf8) ?? Data()
        
        var urlRequest: URLRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = paramData
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        print(paramData)
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard let data = data else{
                print("Invalid data")
                return
            }
            let responseStr: String = String(data: data, encoding: .utf8) ?? ""
            print(responseStr)
        }
    }
    
    func postMethod() {
        guard let url = URL(string: HttpBaseUrl() + "/_functions/upload?password=fqYR5iS5ZM74KydLc14p") else {
            print("Error: cannot create URL")
            return
        }
        
        // Create model
        struct UploadData: Codable {
            let imageURI: String
            let userId: String
            let artistName: String
        }
        
        // Add data to the model
        let uploadDataModel = UploadData(imageURI: buffer, userId: soundlytudeUserId(), artistName: local.string(forKey: "currentUserArtistName") ?? "")
        
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
            do {
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
}

struct uploadImage_Previews: PreviewProvider {
    static var previews: some View {
        uploadImage()
    }
}

struct uploadField: Hashable, Codable {
    let message: String
}

class uploadImageClass: ObservableObject {
    @Published var uploadFields: [uploadField] = []
    
    func upload(buffer:String) {
        guard let url = URL(string: HttpBaseUrl() + "/_functions/upload?password=fqYR5iS5ZM74KydLc14p&dataURI=\(buffer)") else {
            return}
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _,
            error in
            guard let data = data, error == nil else {
                return
            }
            // Convert to JSON
            do
            {
                let data = try JSONDecoder().decode ([uploadField].self, from: data)
                DispatchQueue.main.async{
                    self?.uploadFields = data
                    print(data[0].message)
                }
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }
}
