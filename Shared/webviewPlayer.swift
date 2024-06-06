//
//  webviewPlayer.swift
//  Soundlytude (iOS)
//
//  Created by DJ bon26 on 7/7/23.
//
//
//  BaseWebViewVM.swift
//  wkwebview_demo
//
//  Created by Edward Yee on 5/16/23.
//
import SwiftUI
import Foundation
import WebKit

enum WebViewErrors: Error {
    case ErrorWithValue(value: Int)
    case GenericError
}

enum JSPanelType {
    case alert
    case confirm
    case prompt
    
    var description: String {
        switch self {
        case .alert:
            return "Alert"
        case .confirm:
            return "Confirm"
        case .prompt:
            return "Prompt"
        }
    }
}

class LocalWebViewVM: BaseWebViewVM {
    private func processWebResource(webResource: String) -> (inDirectory: String,
                                                             fileName: String,
                                                             fileExtension: String) {
        // Extract path, file name, and file extension. NSString provides
        // easier solution
        var wr = webResource
        
        var pathName = ""
        var fileExtension = ""
        var fileName = ""
         
        let filePath = Bundle.main.path(forResource: wr, ofType: "html", inDirectory: "/Web resource")
        pathName = filePath ?? ""
        fileExtension = "html"
        fileName = wr
        
        return (inDirectory: pathName,
                fileName: fileName,
                fileExtension: fileExtension)
    }

    override func loadWebPage() {
        if let webResource = webResource {
            let (inDirectory,
                 fileName,
                 fileExtension) = processWebResource(webResource: webResource)

            guard let filePath = Bundle.main.path(forResource: fileName,
                                                  ofType: fileExtension,
                                                  inDirectory: inDirectory) else {
                print("Bad path")
                return
            }

            print(filePath)
            let url = NSURL(fileURLWithPath: filePath)

            webView.loadFileURL(url as URL, allowingReadAccessTo: url as URL)
        }
    }
}

struct WebView: View {
    @ObservedObject var vm: BaseWebViewVM
    @State var alreadyLoaded: Bool  = false
    var body: some View {
        SwiftUIWebView(viewModel: vm)
            .onAppear{
                if !alreadyLoaded {
                    alreadyLoaded = true
                }
            }
            .onAppear(perform: !alreadyLoaded ? vm.loadWebPage : nil)
            .alert(vm.panelTitle,
                   isPresented: $vm.showPanel,
                   actions: {
                switch vm.panelType {
                case .alert:
                    Button("Close") {
                        vm.alertCompletionHandler()
                    }
                case .confirm:
                    Button("Ok") {
                        vm.confirmCompletionHandler(true)
                    }
                    Button("Cancel") {
                        vm.confirmCompletionHandler(false)
                    }
                case .prompt:
                    TextField(text: $vm.promptInput) {}
                    Button("Ok") {
                        vm.promptCompletionHandler(vm.promptInput)
                    }
                    Button("Cancel") {
                        vm.promptCompletionHandler(nil)
                    }
                default:
                    Button("Close") {}
                }
            }, message: {
                Text(vm.panelMessage)
            })
    }
}

struct SwiftUIWebView: UIViewRepresentable {
    typealias UIViewType = WKWebView
    
    var vm: BaseWebViewVM
    init(viewModel: BaseWebViewVM) {
        self.vm = viewModel
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let userContentController = vm.webView
            .configuration
            .userContentController
        
        // Clear all message handlers, if any
        userContentController.removeAllScriptMessageHandlers()

        // Message handler without reply
        userContentController.add(context.coordinator,
                                  name: "fromWebPage")

        // Message handlers with reply
        userContentController.addScriptMessageHandler(context.coordinator,
                                                      contentWorld: WKContentWorld.page,
                                                      name: "getData")
        
        
        if vm.injectMessageListener {
            injectJS(userContentController)
        }

        // Handle alert
        vm.webView.uiDelegate = context.coordinator
        vm.webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        vm.webView.configuration.allowsAirPlayForMediaPlayback = true
        vm.webView.configuration.allowsInlineMediaPlayback = true
        vm.webView.configuration.mediaTypesRequiringUserActionForPlayback = []
        vm.webView.configuration.preferences.isElementFullscreenEnabled = true
        vm.webView.isOpaque = false
        
        return vm.webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(viewModel: vm)
    }
    
    func injectJS(_ userContentController: WKUserContentController) {
        // Define message event listener.
        //
        // Note that there is no need to include the <script> HTML element
        let msgEventListener = """
window.addEventListener("message", (event) => {
    // Sanitize incoming message
    var content = event.data.replace(/</g, "&lt;").replace(/>/g, "&gt;")
    document.getElementById("message").innerHTML = content
})
"""

        // Inject event listener
        userContentController.addUserScript(WKUserScript(source: msgEventListener,
                                                         injectionTime: .atDocumentEnd,
                                                         forMainFrameOnly: false))
    }
}


extension SwiftUIWebView {
    class Coordinator: NSObject, WKUIDelegate,
                        WKScriptMessageHandler,
                        WKScriptMessageHandlerWithReply {
        var viewModel: BaseWebViewVM
        
        init(viewModel: BaseWebViewVM) {
            self.viewModel = viewModel
        }
        
        // MARK: - WKUIDelegate webView() functions
        func webView(_ webView: WKWebView,
                     runJavaScriptAlertPanelWithMessage message: String,
                     initiatedByFrame frame: WKFrameInfo,
                     completionHandler: @escaping () -> Void) {
            viewModel.webPanel(message: message,
                               alertCompletionHandler: completionHandler)
        }
        
        func webView(_ webView: WKWebView,
                     runJavaScriptConfirmPanelWithMessage message: String,
                     initiatedByFrame frame: WKFrameInfo,
                     completionHandler: @escaping (Bool) -> Void) {
            viewModel.webPanel(message: message,
                               confirmCompletionHandler: completionHandler)
        }
        
        func webView(_ webView: WKWebView,
                     runJavaScriptTextInputPanelWithPrompt prompt: String,
                     defaultText: String?,
                     initiatedByFrame frame: WKFrameInfo,
                     completionHandler: @escaping (String?) -> Void) {
            viewModel.webPanel(message: prompt,
                               promptCompletionHandler: completionHandler,
                               defaultText: defaultText)
        }

        // MARK: - WKScriptMessageHandler delegate function
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            self.viewModel.messageFrom(fromHandler: message.name,
                                       message: message.body)
        }

        func userContentController(_ userContentController: WKUserContentController,
                                   didReceive message: WKScriptMessage,
                                   replyHandler: @escaping (Any?, String?) -> Void) {
            do {
                let returnValue = try self.viewModel.messageFromWithReply(fromHandler: message.name,
                                                                          message: message.body)
                
                replyHandler(returnValue, nil)
            } catch WebViewErrors.GenericError {
                replyHandler(nil, "A generic error")
            } catch WebViewErrors.ErrorWithValue(let value) {
                replyHandler(nil, "Error with value: \(value)")
            } catch {
                replyHandler(nil, error.localizedDescription)
            }
        }
    }
}

class BaseWebViewVM: ObservableObject {
    @Published var webResource: String?
    var webView: WKWebView

    // MARK: - Properties for Javascript alert, confirm, and prompt dialog boxes
    @Published var showPanel: Bool = false
    var panelTitle: String = ""
    var panelType: JSPanelType? = nil
    
    var panelMessage: String = ""
        
    // Alert properties
    var alertCompletionHandler: () -> Void = {}

    // Confirm properties
    var confirmCompletionHandler: (Bool) -> Void = { _ in }

    // Prompt properties
    var promptInput: String = ""
    var promptCompletionHandler: (String?) -> Void = { _ in }
    
    // Message from web view
    @Published var messageFromWV: webviewReceiverField = webviewReceiverField(reason: "", messageString: "", messageDouble: 0.0)
    
    // Inject message listener
    var injectMessageListener: Bool = false

    init(webResource: String? = nil) {
        self.webResource = webResource
        
        self.webView = WKWebView(frame: .zero,
                                 configuration: WKWebViewConfiguration())
//
//#if DEBUG
//        self.webView.isInspectable = true
//#endif
    }
    
    func loadWebPage() {
        if let webResource = webResource {
            guard let url = URL(string: webResource) else {
                print("Bad URL")
                return
            }

            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    /// Populate and activate alert dialog box
    /// - Parameters:
    ///   - message: Alert message
    ///   - completionHandler: Completion handler
    func webPanel(message: String,
                  alertCompletionHandler completionHandler: @escaping () -> Void) {
        self.panelTitle = JSPanelType.alert.description // "Alert"
        self.panelMessage = message
        self.alertCompletionHandler = completionHandler
        self.panelType = .alert
        self.showPanel = true
//        print("\(panelTitle): \(panelMessage)")
    }

    func webPanel(message: String,
                  confirmCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        self.panelTitle = JSPanelType.confirm.description
        self.panelMessage = message
        self.confirmCompletionHandler = completionHandler
        self.panelType = .confirm
        self.showPanel = true
    }
    
    func webPanel(message: String,
                  promptCompletionHandler completionHandler: @escaping (String?) -> Void,
                  defaultText: String? = nil) {
        self.panelTitle = JSPanelType.prompt.description
        self.panelMessage = message
        self.promptInput = defaultText ?? ""
        self.promptCompletionHandler = completionHandler
        self.panelType = .prompt
        self.showPanel = true
    }

    // MARK: - Functions for messaging
    
    func messageFrom(fromHandler: String, message: Any) {
//        self.panelTitle = JSPanelType.alert.description // "Alert"
//        self.panelMessage = String(describing: message)
//        self.alertCompletionHandler = {}
//        self.panelType = .alert
//        self.showPanel = true
        let jsonData = Data(String(describing: message).utf8)
        let decoder = JSONDecoder()
        do {
            let people = try decoder.decode(webviewReceiverField.self, from: jsonData)
            self.messageFromWV = people
        } catch {
            print(String(describing: error))
        }
//        print("\(panelTitle): \(panelMessage)")
    }

    func messageFromWithReply(fromHandler: String, message: Any) throws -> String {
        
        let jsonData = Data(String(describing: message).utf8)
        let decoder = JSONDecoder()
        do {
            let people = try decoder.decode(webviewReceiverField.self, from: jsonData)
            self.messageFromWV = people
        } catch {
            print(String(describing: error))
        }

        var returnValue: String = "Good"

        /*
         * This function can throw the follow exceptions:
         *
         * - WebViewErrors.GenericError
         * - WebViewErrors.ErrorWithValue(value: 99)
         */
        
        if fromHandler == "getData" {
            returnValue = "{ data: \"It is good!\" }"
        }
        
        return returnValue
    }
    
    func messageTo(message: webviewPlayerField) {
//        let escapedMessage = message.replacingOccurrences(of: "\"", with: "\\\"")
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            
            
            let data = try encoder.encode(message)
            
            //            guard let jsonData = try? JSONEncoder().encode(message) else {
            //                print("Error: Trying to convert model to JSON data")
            //                return
            //            }
            
            let jSript = "window.postMessage(\(String(data: data, encoding: .utf8)!), \"*\")"
            self.webView.evaluateJavaScript(jSript) { (result, error) in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
            }
        }catch{
            print(error)
            return 
        }
    }
    
    func messageToExploreAudio(message: webviewExploreField) {
//        let escapedMessage = message.replacingOccurrences(of: "\"", with: "\\\"")
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            
            
            let data = try encoder.encode(message)
            
            //            guard let jsonData = try? JSONEncoder().encode(message) else {
            //                print("Error: Trying to convert model to JSON data")
            //                return
            //            }
            
            let jSript = "window.postMessage(\(String(data: data, encoding: .utf8)!), \"*\")"
            self.webView.evaluateJavaScript(jSript) { (result, error) in
                if let error = error {
                    print("Error posting msg: \(error.localizedDescription)")
                }
            }
        }catch{
            print(error)
            return
        }
    }
}


struct webviewPlayerField: Hashable, Codable {
    let reason: String
    let album: String
    let songs: [playerField]
    let `repeat`: Bool
}

struct webviewExploreField: Hashable, Codable {
    let reason: String
    let audioUrl: String
    let themeColor: String
}

struct webviewReceiverField: Hashable, Codable {
    let reason: String
    let messageString: String
    let messageDouble: Double
}
