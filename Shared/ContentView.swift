//
//  ContentView.swift
//  Shared
//
//  Created by DJ bon26 on 9/2/22.
//

import SwiftUI
import MediaPlayer
import Combine
import Introspect

var tabBarMiniPlayerHeight = 0.0
var iphoneXandUp: Bool {
    if UIDevice.current.hasNotch || UIDevice.current.model == "iPad" {
        return true
    }else {
        return false
    }
}

struct InnerContentSize: PreferenceKey {
    typealias Value = [CGRect]
    
    static var defaultValue: [CGRect] = []
    static func reduce(value: inout [CGRect], nextValue: () -> [CGRect]) {
        value.append(contentsOf: nextValue())
    }
}

//struct ContentView: View {
//    @State var isActive : Bool = false
//    @State private var selectedItem = 1
//    @State private var oldSelectedItem = 1
//    @State var fullScreenView: Bool = false
//    @StateObject var globalVariable = globalVariables()
//    @State var playerFrame = CGRect.zero
//    @State private var playerOffset: CGFloat = 0
//    
//    @State private var offset = CGSize.zero
//    @State var chatViewOffset = 0.0
//    
//    @Namespace var animation
//    @State var expand = false
//    
//    
//    @State var uiTabarController: UITabBarController?
//    @State var tabBarFrame: CGRect?
//    
//    var handler: Binding<Int> { Binding(
//            get: { self.selectedItem },
//            set: {
//                if $0 == self.selectedItem {
//                    print("Reset here!!")
////                    forYouPageVar = AnyView(searchPage())
//                }
//                self.selectedItem = $0
//            }
//        )}
//    
//    init() {
//        UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont(name: "Audiowide-Regular", size: 34)!]
//        UITextView.appearance().backgroundColor = .clear
//    }
//    
//    var body: some View {
//        GeometryReader { geometry in
//            ZStack(alignment: .bottom) {
//                TabView(selection: handler){
//                    forYouPage()
//                        .tabItem{
//                            Image(systemName: "house")
//                            Text("For you")
//                        }
//                        .tag(1)
//                        .environmentObject(globalVariable)
//                        .environment(\.rootPresentationMode, self.$isActive)
//                    messagesView()
////                        .scaleEffect(0.2 - ((globalVariable.offset - 0) * 0.1) / (UIScreen.main.bounds.width - 0) + 0.9)
////                        .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.95, blendDuration: 0.5), value: globalVariable.offset)
//                        .environmentObject(globalVariable)
//                        .tabItem{
//                            Image(systemName: "ellipsis.message")
//                            Text("Messages")
//                        }
//                        .tag(2)
////                    notificationsPage()
//                    playerQueue3()
//                        .tabItem{
//                            Image(systemName: "bell")
//                            Text("Notifications")
//                        }
//                        .tag(3)
//                    profilePage2()    // I want this to display the sheet.
//                        .tabItem{
//                            Image(systemName: "person.fill")
//                            Text("Profile")
//                        }
//                        .tag(4)
//                    searchItemPage()
//                        .environmentObject(webviewVariables())
//                        .environmentObject(globalVariable)
//                        .tabItem{
//                            Image(systemName: "magnifyingglass")
//                            Text("Search")
//                        }
//                        .tag(5)
//                    //                YouTubeTest()
//                    //                    .environmentObject(globalVariables())
//                    //                    .tabItem{
//                    //                        Image(systemName: "magnifyingglass")
//                    //                        Text("Youtube")
//                    //                    }
//                    //                    .tag(5)
//                }
////                .introspectTabBarController { (UITabBarController) in
////                    uiTabarController = UITabBarController
////                    self.tabBarFrame = uiTabarController?.view.frame
////                    uiTabarController?.tabBar.isHidden = globalVariable.hideTabBar
////                    uiTabarController?.view.frame = CGRect(x:0, y:0, width:tabBarFrame!.width, height:tabBarFrame!.height+UITabBarController.tabBar.frame.height);
////                }
//                .ignoresSafeArea()
//                .onPreferenceChange(InnerContentSize.self, perform: { value in
//                    self.playerOffset = geometry.size.height - (value.last?.height ?? 0)
//                })
//                .overlay(
////                    miniPlayerView()
////                        .offset(y: -playerOffset)
////                        .environmentObject(webviewVariables())
//                VStack{
//                        if !expand{
//                            Spacer()
//                        }
//                    miniplayer(playerOffset: playerOffset, animation: animation, expand: $expand)
//                                .environmentObject(globalVariable)
//                    }
//                    .opacity(globalVariable.hideTabBar ? 0 : 1)
//                    .ignoresSafeArea(.keyboard)
//                )
//            }
//        }
//    }
//}

struct bottomSpace: View{
    @State var height: Double = 50
    var body: some View{
        VStack{
            Spacer()
                .frame(height: height)
        }
        .onAppear{
            progresser()
        }
    }
    
    func progresser() {
        if(tabBarMiniPlayerHeight > 0){
            height = tabBarMiniPlayerHeight
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                progresser()
            }
        }
    }
}

struct ContentView: View{
    @State var activeId : Int = 0
    
    @State private var selectedItem = 1
    @State private var tabViews: [tabViewField] =
    [tabViewField(id: 0, systemImage: "house.fill", label: "For You", Notification: -1),
    tabViewField(id: 2, systemImage: "bell.fill", label: "Notifications", Notification: 60),
    tabViewField(id: 3, systemImage: "person.fill", label: "Profile", Notification: 0),
    tabViewField(id: 4, systemImage: "magnifyingglass", label: "Search", Notification: -1)]
    
    @State private var tabViewsNotUsing: [tabViewField] =
    [tabViewField(id: 0, systemImage: "house.fill", label: "For You", Notification: -1),
    tabViewField(id: 1, systemImage: "ellipsis.message.fill", label: "Messages", Notification: 5),
    tabViewField(id: 2, systemImage: "bell.fill", label: "Notifications", Notification: 60),
    tabViewField(id: 3, systemImage: "person.fill", label: "Profile", Notification: 0),
    tabViewField(id: 4, systemImage: "magnifyingglass", label: "Search", Notification: -1)]
    
    @StateObject var globalVariable = globalVariables()
    @State var playerFrame = CGRect.zero
    @State var isActive: Bool = false
    
    @State var loadedPages: Array<Int> = []
    
    @Namespace var animation
    @State var expand = false
    @State var wasExpanded = false
    @State var isDragging = false
    @State var localIsDragging = false
    @State var draggingOffset = 0.0
    @State var percent: Double = 0.0
    @State var scaleEffectValue: Double = 1
    @State var offsetEffectValue: Double = 0.0
    
    @State var viewWidth = 0.0
    @State var viewHeight = 0.0
    
    @State var uiTabarController: UITabBarController?
    @State var tabBarFrame: CGRect?
    
    var offsetEffect: Double {
        if isDragging {
            return offsetEffectValue
        }else{
            if expand {
                return -200
            }else{
                return 0
            }
        }
    }
    
    var scaleEffect: Double {
        if isDragging {
            return scaleEffectValue
        }else{
            if expand {
                return 0.95
            }else{
                return 1
            }
        }
    }
    
    var handler: Binding<Int> { Binding(
        get: { self.selectedItem },
        set: {
            if $0 == self.selectedItem {
                print("Reset here!!")
                //                    forYouPageVar = AnyView(searchPage())
            }
            self.selectedItem = $0
        }
    )}
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont(name: "Audiowide-Regular", size: 34)!]
        UITextView.appearance().backgroundColor = .clear
    }
    
    var body: some View{
        ZStack{
            ZStack{
                Color.black
                ZStack{
                    explorePage()
                        .offset(x: activeId == 0 ? 0 : viewWidth)
                        .environmentObject(globalVariable)
                        .environment(\.rootPresentationMode, self.$isActive)
                    if loadedPages.contains(1){
                        messagesView()
                            .offset(x: activeId == 1 ? 0 : viewWidth)
                            .environmentObject(globalVariable)
                    }
                    if loadedPages.contains(2){
                        notificationsPage()
                            .environmentObject(globalVariable)
                            .offset(x: activeId == 2 ? 0 : viewWidth)
                    }
                    if loadedPages.contains(3){
                        profilePage()    // I want this to display the sheet.
                            .environmentObject(globalVariable)
                            .offset(x: activeId == 3 ? 0 : viewWidth)
                    }
                    if loadedPages.contains(4){
                        searchItemPage()
                            .offset(x: activeId == 4 ? 0 : viewWidth)
                            .environmentObject(webviewVariables())
                            .environmentObject(globalVariable)
                    }
                    //                YouTubeTest()
                    //                    .environmentObject(globalVariables())
                    //                    .tabItem{
                    //                        Image(systemName: "magnifyingglass")
                    //                        Text("Youtube")
                    //                    }
                    //                    .tag(5)
                }
                .scaleEffect(isDragging ? scaleEffect : scaleEffect, anchor: .bottom)
                //                    .animation(.easeIn(duration: 0.4).delay(100000000), value: expand)
                .animation(.interactiveSpring(response: 0.3, dampingFraction: 1), value: scaleEffect)
                .animation(.easeIn(duration: 0.1), value: isDragging)
                .cornerRadius(iphoneXandUp ? (isDragging ? normalizeRange(x: percent, xMin: 100.0, xMax: 0, yMin: 0, yMax: 30) : (expand ? 30 : 0)) : 0)
                Color.gray.opacity(0.2)
                    .cornerRadius(iphoneXandUp ? (normalizeRange(x: percent, xMin: 100.0, xMax: 0, yMin: 0, yMax: 30)) : 0)
                    .scaleEffect(isDragging ? scaleEffect : scaleEffect, anchor: .bottom)
                    .opacity(isDragging || expand  ? normalizeRange(x: (percent / 100), xMin: 1.0, xMax: 0.0, yMin: 0, yMax: 1.0) : 0)
                    .animation(.easeIn(duration: 0.1), value: scaleEffect)
                    .animation(.easeIn(duration: 0.1), value: percent)
                    .animation(.easeIn(duration: 0.1), value: isDragging)
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0){
                Spacer()
                VStack(spacing: 0){
                    miniplayer(playerOffset: 0, animation: animation, expand: $expand, wasExpanded: $wasExpanded, isDragging: $isDragging.onChange(isDraggingChanged), draggingOffset: $draggingOffset.onChange(onOffsetChange))
                        .environmentObject(globalVariable)
                    if !expand{
                        Divider()
                            .padding(.bottom, 3)
                        HStack(spacing: 0){
                            ForEach(0..<tabViews.count, id:\.self){i in
                                let x = tabViews[i]
                                tabBarItemView(id: x.id, image: x.systemImage, label: x.label, notifications: x.Notification, active: (x.id == activeId))
                                if i != (tabViews.count - 1){
                                    Spacer()
                                }
                            }
                        }
                        .padding(.horizontal, 7.5)
                        .transition(AnyTransition.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .background(
                    VStack(spacing: 0){
                        if !isDragging && !expand {
                            BlurView()
                                .ignoresSafeArea()
                                .transition(AnyTransition.opacity.combined(with: .move(edge: .bottom)))
                                .animation(nil, value: isDragging)
                        }
                    }
                )
                .offset(y: globalVariable.hideTabBar ? tabBarMiniPlayerHeight : 0)
                .opacity(globalVariable.hideTabBar ? 0 : 1)
                .animation(.easeIn(duration: 0.1), value: globalVariable.hideTabBar)
                .overlay(
                    GeometryReader { geo in
                        Text("")
                            .onAppear{
                                if iphoneXandUp {
                                    tabBarMiniPlayerHeight = geo.size.height + 20
                                }else{
                                    tabBarMiniPlayerHeight = geo.size.height
                                }
                                print("Height: ", geo.size.height)
                            }
                            .onChange(of: geo.size) { newSize in
                                print(geo.size.height)
                            }
                    }
                )
            }
            .overlay(
                GeometryReader { geo in
                    Text("")
                        .onAppear{
                            withAnimation(.spring()){
                                viewWidth = geo.size.width
                                viewHeight = geo.size.height
                                print("Height: ", geo.size.height)
                            }
                        }
                        .onChange(of: geo.size) { newSize in
                            viewHeight = geo.size.height
                            viewWidth = geo.size.width
                            viewHeight = geo.size.height
                        }
                }
            )
            .ignoresSafeArea(.keyboard)
        }
    }
    
    @ViewBuilder
    func tabBarItemView(id: Int, image: String, label: String, notifications: Int, active: Bool)-> some View{
        Button {
            if activeId != id{
                if !loadedPages.contains(id){
                    loadedPages.append(id)
                }
                activeId = id
            }else{
                if activeId == 0 {
                    globalVariable.homeExited = false
                }
                if activeId == 1 {
                    globalVariable.homeExited = false
                }
                if activeId == 2 {
                    globalVariable.homeExited = false
                }
                if activeId == 3 {
                    globalVariable.profilePageExited = false
                }
                if activeId == 4 {
                    globalVariable.homeExited = false
                }
            }
        } label: {
            VStack(alignment: .center, spacing: 0) {
                ZStack(alignment: .topTrailing){
                    Image(systemName: image)
                        .font(.system(size: 24))
                        .frame(width: 30, height: 30)
                    if notifications > 0{
                        Text((notifications < 1 ? " " : (notifications < 100 ? "\(notifications)" : "99+")))
                            .font(.system(size: 8))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.vertical, 2)
                            .padding(.horizontal, 5)
                            .lineLimit(1)
                            .background(Color.red)
                            .cornerRadius(8)
                            .offset(x: 7.5, y: -1.5)
//                            .background(
//                                Circle()
//                                    .fill(.red)
//                                    .frame(width: notifications < 1 ? 7 : 15, height: notifications < 1 ? 7 : 15))
                    }
                }
                HStack(spacing: 1){
                    Text("\(label)")
                        .font(.system(size: 9))
                        .fontWeight(.semibold)
                    if notifications == 0 {
                        Text("●")
                            .foregroundColor(.red.opacity(0.75))
                            .font(.system(size: 8))
                            .fontWeight(.semibold)
                    }
                }
                .padding(.vertical, 2)
            }
            .foregroundColor(active ? Color.accentColor.opacity(1) : Color("BlackWhite").opacity(0.3))
            .frame(maxWidth: .infinity)
        }
    }
    
    func onOffsetChange(to value: Double) {
        let propperDraggedOffset = draggingOffset > viewHeight ? viewHeight : (draggingOffset < 0 ? 0 : draggingOffset)
            percent = (propperDraggedOffset / viewHeight) * 100
        scaleEffectValue = normalizeRange(x: percent, xMin: 0.0, xMax: 100.0, yMin: 0.95, yMax: 1.0)
//            offsetEffectValue = normalizeRange(x: percent, xMin: 0.0, xMax: 100.0, yMin: -200, yMax: 0)
    }
    
    func isDraggingChanged(to value: Bool) {
        withAnimation(.easeIn){
            if isDragging {
                localIsDragging = isDragging
            }else{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    localIsDragging = isDragging
                }
            }
        }
    }
    
    func onExpandChange(to value: Bool) {
        expand = expand
    }
}

func normalizeRange(x: Double, xMin: Double, xMax: Double, yMin: Double, yMax: Double) -> Double{
    return ((yMax - yMin) * ((x - xMin) / (xMax - xMin))) + yMin
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ViewControllerHolder {
    weak var value: UIViewController?
}

struct ViewControllerKey: EnvironmentKey {
    static var defaultValue: ViewControllerHolder {
        return ViewControllerHolder(value: UIApplication.shared.windows.first?.rootViewController)
    }
}

extension EnvironmentValues {
    var viewController: UIViewController? {
        get { return self[ViewControllerKey.self].value }
        set { self[ViewControllerKey.self].value = newValue }
    }
}

extension UIViewController {
    func present<Content: View>(style: UIModalPresentationStyle = .automatic, @ViewBuilder builder: () -> Content) {
        let toPresent = UIHostingController(rootView: AnyView(EmptyView()))
        toPresent.modalPresentationStyle = style
        toPresent.rootView = AnyView(
            builder()
                .environment(\.viewController, toPresent)
        )
        self.presentController(toPresent)
    }
    
    func presentController(_ viewControllerToPresent: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.2
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        self.view.window?.layer.add(transition, forKey: kCATransition)
        
        present(viewControllerToPresent, animated: false)
    }
    
    func dismissController() {
        let transition = CATransition()
        transition.duration = 0.2
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        self.view.window?.layer.add(transition, forKey: kCATransition)
        dismiss(animated: false)
    }
}

struct RootPresentationModeKey: EnvironmentKey {
    static let defaultValue: Binding<RootPresentationMode> = .constant(RootPresentationMode())
}

extension EnvironmentValues {
    var rootPresentationMode: Binding<RootPresentationMode> {
        get { return self[RootPresentationModeKey.self] }
        set { self[RootPresentationModeKey.self] = newValue }
    }
}

typealias RootPresentationMode = Bool

extension RootPresentationMode {
    
    public mutating func dismiss() {
        self.toggle()
    }
}

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

struct tabViewField: Hashable, Codable {
    let id: Int
    let systemImage: String
    let label: String
    let Notification: Int
}
