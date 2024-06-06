//
//  PlayerView.swift
//  Soundlytude (iOS)
//
//  Created by DJ bon26 on 2/13/23.
//

import SwiftUI
import WebKit
import MediaPlayer

enum MyURLError: Error {
    case invalidURL
    
    var description: String {
        switch self{
        case .invalidURL:
            return "Your url is invalid"
        }
    }
}
//
//struct WebView: UIViewRepresentable{
//    let url: URL?
//    let onError: (MyURLError) -> Void
//    var mNativeToWebHandler : String = "jsMessageHandler"
//    var bundle: Bundle {
//            return Bundle.main
//        }
//
//    var scriptString: String {
//            if let path = bundle.path(forResource: "form", ofType: "js") {
//                do {
//                    return try String(contentsOfFile: path)
//                } catch {
//                    return ""
//                }
//            } else {
//                return ""
//            }
//        }
//
//
//    func makeUIView(context: Context) -> WKWebView {
//        let script = WKUserScript(source: scriptString, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
//        let userController = WKUserContentController()
//        let config = WKWebViewConfiguration()
//        config.allowsInlineMediaPlayback = true
//        config.userContentController.addUserScript(script)
//        config.userContentController.add(ContentController, name: "alert")
//        return WKWebView(
//            frame: .zero,
//            configuration: config
//        )
//    }
//
//    func updateUIView(_ uiView: WKWebView, context: Context) {
//        guard let myUrl = url else{
//            return
//        }
//        let request = URLRequest(url: myUrl)
//        uiView.load(request)
//    }
//
//    class ContentController: NSObject, WKScriptMessageHandler {
//        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//            if message.name == "jsHandler"{
//                print(message.body)
//            }
//        }
//    }
//
//    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//            if let msg = message.body as? String {
//                print(msg)
//            }
//    }
//}

struct WebView2: UIViewRepresentable {
    let url: URL?
    let onError: (MyURLError) -> Void
    let contentController = ContentController()
    
    func makeUIView(context: Context) -> WKWebView  {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        return WKWebView(
            frame: .zero,
            configuration: config
        )
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.configuration.userContentController.add(contentController, name: "jsHandler")
        
        guard let myUrl = url else{
            return
        }
        let request = URLRequest(url: myUrl)
        uiView.load(request)
    }
    
    class ContentController: NSObject, WKScriptMessageHandler {
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "jsHandler"{
                print(message.body)
            }
        }
        func evaluateWebView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("playvideo();", completionHandler: nil)
        }
    }
}

struct WebView3: UIViewRepresentable {
    let url: URL?
    let height: CGFloat
    let onError: (MyURLError) -> Void
    @State var onMessage: Bool = false
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let coordinator = makeCoordinator()
        let userContentController = WKUserContentController()
        userContentController.add(coordinator, name: "jsHandler")
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.preferences.isElementFullscreenEnabled = true
        
        let _wkwebview = WKWebView(frame: .zero, configuration: configuration)
        _wkwebview.navigationDelegate = coordinator
        _wkwebview.backgroundColor = .clear
        _wkwebview.isOpaque = false
        
        return _wkwebview
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        guard let myUrl = URL(string: "\(url!)&height=\(height)") else{
            return print(URL(string: "\(String(describing: url))&height=\(height)"))
        }
        webView.backgroundColor = .clear
        webView.isOpaque = false
        print(myUrl)
        let request = URLRequest(url: myUrl)
        webView.load(request)
    }
}

class Coordinator: NSObject, ObservableObject, WKNavigationDelegate, WKScriptMessageHandler {
    @Published var msgFromWebviews: [msgFromWebview] = []
    @Published var isFullscreen = false
    var webView: WKWebView?
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.webView = webView
    }
    
    // receive message from wkwebview
    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        print(message.body)
        guard let htmlStr = message.body as? String else {
            return
        }
        do {
            let dec = JSONDecoder()
            dec.keyDecodingStrategy = .convertFromSnakeCase
            let res = try dec.decode(msgFromWebview.self, from:Data(htmlStr.utf8))
            print(res)
            DispatchQueue.main.async{
                self.msgFromWebviews = self.msgFromWebviews + [res]
                if res.message == "fullscreen"{
                    self.isFullscreen = true
                }
                if res.message == "defaultscreen"{
                    self.isFullscreen = false
                }
            }
        } catch  {
            print("having trouble converting it to a dictionary" , error)
        }
        //            let date = Date()
        //            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        //                self.messageToWebview(msg: "hello, I got your messsage: \(message.body) at \(date)")
        //            }
    }
    
    func messageToWebview(msg: String) {
        self.webView?.evaluateJavaScript(msg)
    }
    
}
struct msgFromWebview : Codable, Hashable {
    let type: String
    let message: String
}

extension WKWebView{
    func load(_ htmlFileName: String){
        guard !htmlFileName.isEmpty else{
            return print("Empty file name")
        }
        guard let filePath = Bundle.main.path(forResource: htmlFileName, ofType: "html") else {
            return print("Error file path")
        }
        
        do {
            let htmlString = try String(contentsOfFile: filePath, encoding: .utf8)
            loadHTMLString(htmlString, baseURL: URL(fileURLWithPath: filePath))
        } catch {
            print("error here")
        }
    }
}

struct PlayerView: View {
    
    var id: String
    var body: some View {
        VStack{
            //            Button {
            //                functionToRun = "togglePlay()"
            //            } label: {
            //                Text("Play video")
            //                    .padding(50)
            //            }
            WebView3(url: URL(string: id),height: 10.0,
                    onError: {err in
                print(err.description)
            })
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            .onAppear{
                print("id recieved: ", id)
            }
        }
    }
}

struct miniPlayerView: View {
    @EnvironmentObject var webviewVariable : webviewVariables
    @Environment(\.colorScheme) var colorScheme
    @State private var offset = CGSize.zero
    @State private var height = 70.0
    var playerOffset: CGFloat = 0.0
    @State var lastDragPosition: DragGesture.Value?
    @State var geometryHeight = 0.0
    @StateObject var coordinator = Coordinator()
    
    var body: some View {
        ZStack{
            if webviewVariable.useMaximized{
                Color.black
                    .ignoresSafeArea()
            }
            GeometryReader { geometry in
                VStack(spacing: 0){
                    Spacer()
                    ZStack{
                        if webviewVariable.isMaximized == false || height < 200{
                            Blur(style: .systemChromeMaterial)
                                .frame(maxHeight: (webviewVariable.useMaximized) ? geometry.size.height : height)
                        }
                        WebView3(url: webviewVariable.url, height: geometry.size.height,
                                onError: {err in
                            print(err.description)
                        })
                        .frame(maxHeight: (webviewVariable.useMaximized) ? geometry.size.height - 20 : height)
                        .animation(.easeOut, value: height)
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    offset = gesture.translation
                                    if webviewVariable.isMaximized{
                                        webviewVariable.useMaximized = false
                                        height = min(max(70, height - offset.height), geometry.size.height)
                                    }else{
                                        height = min(max(70, height - offset.height), geometry.size.height)
                                    }
                                }
                                .onEnded { gesture in
                                    print(height)
                                    if height > ((75/100) * geometry.size.height) {
                                        if(abs(gesture.velocity.height) > 150){
                                            miniscreen()
                                        }else{
                                            withAnimation(.easeInOut(duration: 0.25)) {
                                                webviewVariable.isMaximized = true
                                                webviewVariable.useMaximized = true
                                                height = geometry.size.height
                                            }
                                        }
                                    }else if height < 200 {
                                        miniscreen()
                                    }else if(abs(gesture.velocity.height) > 150){
                                        if(webviewVariable.isMaximized){
                                            miniscreen()
                                        }else{
                                            withAnimation(.easeInOut(duration: 0.25)) {
                                                webviewVariable.isMaximized = true
                                                webviewVariable.useMaximized = true
                                                height = geometry.size.height
                                            }
                                        }
                                    }else{
                                        if(webviewVariable.isMaximized){
                                            withAnimation(.easeInOut(duration: 0.25)) {
                                                webviewVariable.isMaximized = true
                                                webviewVariable.useMaximized = true
                                                height = geometry.size.height
                                            }
                                        }else{
                                            miniscreen()
                                        }
                                    }
                                    offset = .zero
                                }
                        )
                    }
                }
                .onAppear{
                    geometryHeight = geometry.size.height
                }
                //            .onReceive(self.webviewVariable.$isMaximized) { _ in
                //                geometryHeight = geometry.size.height
                //            }
            }
            .frame(maxHeight: .infinity)
        }
    }
    
    func fullscreen(){
        withAnimation(.easeInOut(duration: 0.25)) {
            webviewVariable.isMaximized = true
            webviewVariable.useMaximized = true
            height = geometryHeight
        }
    }
    func miniscreen(){
        withAnimation(.easeInOut(duration: 0.25)) {
            webviewVariable.isMaximized = false
            height = 70.0
            webviewVariable.useMaximized = false
        }
    }
}

//struct PlayerView_Previews: PreviewProvider {
//    static var previews: some View {
//        miniPlayerView()
//    }
//}

extension DragGesture.Value {
    
    /// The current drag velocity.
    ///
    /// While the velocity value is contained in the value, it is not publicly available and we
    /// have to apply tricks to retrieve it. The following code accesses the underlying value via
    /// the `Mirror` type.
    internal var velocity: CGSize {
        let valueMirror = Mirror(reflecting: self)
        for valueChild in valueMirror.children {
            if valueChild.label == "velocity" {
                let velocityMirror = Mirror(reflecting: valueChild.value)
                for velocityChild in velocityMirror.children {
                    if velocityChild.label == "valuePerSecond" {
                        if let velocity = velocityChild.value as? CGSize {
                            return velocity
                        }
                    }
                }
            }
        }
        
        fatalError("Unable to retrieve velocity from \(Self.self)")
    }
    
}
