//
//  Report View.swift
//  Soundlytude (iOS)
//
//  Created by DJ bon26 on 3/19/24.
//

import SwiftUI

struct ReportView: View {
    @StateObject var sendReportFunc = sendContentReport()
    @Binding var openView: Bool
    
    @State var type : String = ""
    @State var contentId : String = ""
    @State var contentOwnerId : String = ""

    @State private var username: String = ""
    @State var textEditorHeight : CGFloat = 50
    @State var reportMessage : String = ""
    @State var disableAllInputs : Bool = true
    @FocusState var sendAChatInputFocused: Bool
    
    @State var loading: Bool = true
    @State private var presentAlert = false
    @State private var presentAlertTitle = ""
    @State private var presentAlertMessage = ""
    
    var formatedReportMessage: String {
        return reportMessage.replacingOccurrences(of: " ", with: "")
    }
    
    var sendTextIsValid: Bool {
        if formatedReportMessage == "" && !disableAllInputs {
            return true
        }else {
            return false
        }
    }
    
    var body: some View {
        VStack{
            ZStack(alignment: .topLeading){
                if #available(iOS 16.0, *) {
                    TextEditor(text:$reportMessage)
                        .font(.body)
                        .frame(maxHeight: .infinity)
//                                                        .customTextField(color: .accentColor, padding: 5, lineWidth: 1)
                        .focused($sendAChatInputFocused)
                        .scrollContentBackground(Visibility.hidden)
//                        .border(Color.pink, width: 2)    // new technique for iOS 16
                } else {
                    // Fallback on earlier versions
                    TextEditor(text:$reportMessage)
                        .font(.body)
                        .frame(maxHeight: .infinity)
//                                                        .customTextField(color: .accentColor, padding: 5, lineWidth: 1)
                        .focused($sendAChatInputFocused)
                }
                Text((!sendTextIsValid) ? "" : " What's wrong? Spill the tea ...") //bla1
                    .font(.body)
                    .opacity(0.25)
                    .padding(.top, 8)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            sendAChatInputFocused = true
                        }
                    }
            }.padding(.horizontal)
            Spacer()
            Button {
                Task{
                    do {
                        loading = true
                        try await self.sendReportFunc.sendReport(report: reportMessage, type: type, contentId: contentId, contentOwner: contentOwnerId)
                        loading = false
                        presentAlert = true
                        presentAlertTitle = "CONTENT REPORTED"
                        presentAlertMessage = "Thanks for reporting, We'll review the content based on what you said!"
                    } catch {
                        
                    }
                }
            } label: {
                Text("Report")
            }.disabled(!sendTextIsValid)

        }
        .overlay(content: {
            if loading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color("BlackWhite").opacity(0.1))
            }
        })
        .onAppear{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                checkIfReported()
            }
        }
        .alert(presentAlertTitle, isPresented: $presentAlert, actions: {
            Button("OK", role: .cancel, action: {openView = false})
        }, message: {
            Text(presentAlertMessage)
        })
    }
    
    func checkIfReported(){
        loading = true
        guard let url = URL(string: HttpBaseUrl() + "/_functions/ifContentReported?password=07rNwMhovc4WpnyBw7SQ&contentId=\(contentId)&currentUserId=\(soundlytudeUserId())") else {
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
                loading = false
                disableAllInputs = false
                print(error!)
                return
            }
            guard let data = data else {
                presentAlert = true
                presentAlertTitle = "WARNING"
                presentAlertMessage = "There was an error proceeding. Did not recieve a response from server"
                loading = false
                disableAllInputs = false
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                presentAlert = true
                presentAlertTitle = "WARNING"
                presentAlertMessage = "There was an error proceeding. Request failed"
                loading = false
                disableAllInputs = false
                print("Error: HTTP request failed")
                return
            }
            do {
                let data = try JSONDecoder().decode (standardBasicResponse.self, from: data)
                print(data)
                
                if data.scenario == "reported" {
                    presentAlert = true
                    presentAlertTitle = "WARNING"
                    presentAlertMessage = "You've already reported this content, Please wait till we view and take action(s) on the previous report"
                }else{
                }
                loading = false
                disableAllInputs = false
            } catch {
                print(url)
                print(error)
                presentAlert = true
                presentAlertTitle = "WARNING"
                presentAlertMessage = "There was an error proceeding"
                return
            }
        }.resume()
    }
}

//struct Report_View_Previews: PreviewProvider {
//    static var previews: some View {
//        ReportView()
//    }
//}


class sendContentReport: ObservableObject {
    @Published var sendContentReportFields: [standardBasicResponse] = [] //Using
    
    func sendReport(report: String, type: String, contentId: String, contentOwner: String) async throws {
        guard let url = URL(string: HttpBaseUrl() + "/_functions/report?password=Cj0374WvMyFn3W7NZYhX") else { fatalError("Missing URL") }
        print(url)
        
        struct reportData: Codable {
            let report: String
            let type: String
            let contentId: String
            let contentOwner: String
            let currentUserId: String
        }
        
        // Add data to the model
        let reportDataModel = reportData(report: report, type: type, contentId: contentId, contentOwner: contentOwner, currentUserId: soundlytudeUserId())
        
        // Convert model to JSON data
        guard let jsonData = try? JSONEncoder().encode(reportDataModel) else {
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
        let decodedData = try JSONDecoder().decode([standardBasicResponse].self, from: data)
        print("Checkpoint4")
        DispatchQueue.main.async{
            print("Checkpoint5")
            self.sendContentReportFields = decodedData
            if decodedData[0].message == "Success" {
                print("Done interaction")
                print(decodedData[0].scenario ?? "")
            }
        }
    }
}
