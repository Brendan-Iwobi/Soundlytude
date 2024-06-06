//
//  Images.swift
//  Soundlytude
//
//  Created by DJ bon26 on 10/26/22.
//

import SwiftUI
import Photos
import PhotosUI

struct Images2: View {
    @State var showChatMenu: Bool = true
    @State var chatMenuOwner: Bool = false
    @State var selectedReaction: String = "👍"
    @State var selectedReactionGrow: Double = 1
    @State var chatMenuChatOffsetY: Double = 0.0
    @State var unanimatedChatMenuChatOffsetY: Double = 0.0
    @State var chatMenuChat: AnyView = AnyView(EmptyView())
    @State var replyView: AnyView = AnyView(EmptyView())
    @State var showReplyView: Bool = false
    
    let reactions: Array<String> = ["👍","👎","❤️","😂","😭","😐","😢","😱","🤔","😮","❓","⁉️"]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false){
            HStack{
                ForEach(reactions, id: \.self){i in
                    let index = reactions.firstIndex(of: i)
                    Button {
                    } label: {
                        Text(i)
                            .font(.system(size: 20))
                            .scaleEffect(selectedReaction == i ? selectedReactionGrow : 1)
                            .animation(.interpolatingSpring(stiffness: 170, damping: 10), value: selectedReactionGrow)
                    }
                    .offset(x: showChatMenu ? 0 : -10)
                    .scaleEffect(showChatMenu ? 1 : 0, anchor: .bottomLeading)
                    .rotationEffect(.degrees(showChatMenu ? 0 : -45))
                    .frame(width: 35, height: 35)
                    .background(selectedReaction == i ? Color("BlackWhite").opacity(0.2) : .clear)
                    .cornerRadius(35)
                    .padding(.vertical, 5)
                    .animation(.interpolatingSpring(stiffness: 170, damping: 14).delay((Double(index ?? 0) - 0.1) / 15), value: showChatMenu)
                }
            }
            .padding(.horizontal, 5)
        }
        .background(Color.accentColor.opacity(0.5))
    }
}

struct Images_Previews: PreviewProvider {
    static var previews: some View {
//        squareImage64by64 (urlString: "")
        Images2()

    }
}

struct squareImage48by48: View {
    var urlString: String
    var imageTitle: String = "Soundlytude Image"
    var cornerRadius: CGFloat = 5
    var borderWidth: Double = 1
    var borderColor: Color = .white
    @State var data: Data?
    var body: some View {
        
        AsyncImage(url: URL(string: "\(urlString)/v1/fill/w_96,h_96,al_c/\(imageTitle.replacingOccurrences(of: " ", with: "+")).jpg")) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .background (Color.gray)
//                .scaledToFill()
            
        } placeholder: {
            Image("Soundlytude empty placeHolder")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .opacity(0.5)
        }
        .cornerRadius(cornerRadius)
        .frame(width: 48, height: 48)
        .overlay( /// apply a rounded border
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(borderColor, lineWidth: borderWidth)
        )
    }
}

struct circleImage40by40: View {
    var urlString: String
    var imageTitle: String = "Soundlytude Image"
    var cornerRadius: CGFloat = 50
    var body: some View {
        AsyncImage(url: URL(string: "\(urlString)/v1/fill/w_64,h_64,al_c/\(imageTitle.replacingOccurrences(of: " ", with: "+")).jpg")) { image in
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
        .cornerRadius(cornerRadius)
        .frame(width: 40, height: 40)
    }
}

struct circleImageCustomSize: View {
    var urlString: String
    var imageTitle: String = "Soundlytude Image"
    var resolution: Int = 128
    var multiply: Int = 1
    @State var data: Data?
    var body: some View {
        
            AsyncImage(url: URL(string: "\(urlString)/v1/fill/w_\(resolution * multiply),h_\(resolution * multiply),al_c/\(imageTitle.replacingOccurrences(of: " ", with: "+")).jpg")) { image in
                image
                    .resizable()
                    .background (Color.gray)
                    .scaledToFit()
                
            } placeholder: {
                Image("Soundlytude empty placeHolder")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .opacity(0.5)
            }
            .cornerRadius(CGFloat(resolution))
            .frame(width: CGFloat(resolution), height: CGFloat(resolution))
            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y:0)
    }
}

struct PFPcircleImageCustomSize: View {
    var imageTitle: String = "Soundlytude Image"
    var cornerRadius: CGFloat = 128
    var resolution: Int = 128
    var multiply: Int = 1
    @State var data: Data?
    var body: some View {
        if let data = data, let uiimage = UIImage(data: data) {
            Image(uiImage: uiimage)
                .resizable()
                .background (Color.gray)
                .scaledToFit()
                .cornerRadius(CGFloat(resolution))
                .frame(width: CGFloat(resolution), height: CGFloat(resolution))
                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y:0)
                .onAppear{
                    fetchData()
                }
        }
        else {
            Image("Soundlytude empty placeHolder")
                .resizable()
                .scaledToFit()
                .cornerRadius(CGFloat(resolution))
                .frame(width: CGFloat(resolution), height: CGFloat(resolution))
                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y:0)
                .opacity(0.1)
                .onAppear {
                    fetchData()
                }
        }
    }
    
    private func fetchData(){
        guard let url = URL(string: "\(newlyUpdatedPfpUrl)/v1/fill/w_\(resolution * multiply),h_\(resolution * multiply),al_c/\(imageTitle.replacingOccurrences(of: " ", with: "+")).jpg") else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, _, _
            in
            self.data = data
        }
        task.resume( )
    }
}

struct squareImage160by160: View {
    var urlString: String
    var imageTitle: String = "Soundlytude Image"
    var cornerRadius: CGFloat = 10
    @State var data: Data?
    var body: some View {
        if let data = data, let uiimage = UIImage(data: data) {
            Image(uiImage: uiimage)
                .resizable()
                .background (Color.gray)
                .scaledToFit()
                .cornerRadius(cornerRadius)
                .frame(width: 160, height: 160)
                .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y:5)
        }
        else {
            Image("Soundlytude empty placeHolder")
                .resizable()
                .opacity(0.1)
                .scaledToFit()
                .cornerRadius(cornerRadius)
                .frame(width: 160, height: 160)
                .onAppear {
                    fetchData()
                }
        }
    }
    
    private func fetchData(){
        guard let url = URL(string: "\(urlString)/v1/fill/w_200,h_200,al_c/\(imageTitle.replacingOccurrences(of: " ", with: "+")).jpg") else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, _, _
            in
            self.data = data
        }
        task.resume( )
    }
}

struct squareImage64by64: View {
    var urlString: String
    var imageTitle: String = "Soundlytude Image"
    var cornerRadius: CGFloat = 5
    var borderWidth: Double = 1
    var borderColor: Color = .white
    @State var data: Data?
    var body: some View {
        AsyncImage(url: URL(string: "\(urlString)/v1/fill/w_128,h_128,al_c/\(imageTitle.replacingOccurrences(of: " ", with: "+")).jpg")) { image in
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
        .cornerRadius(cornerRadius)
        .frame(width: 64, height: 64)
        .overlay( /// apply a rounded border
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(borderColor, lineWidth: borderWidth)
        )
    }
}


struct squareImageChat20: View {
    var imageTitle: String = "Soundlytude Image"
    var cornerRadius: CGFloat = 128
    var resolution: Int = 128
    var multiply: Int = 1
    var maxWidth: Double = 170
    var maxHeight: Double = 255
    @State var data: Data?
    var body: some View {
        if let data = data, let uiimage = UIImage(data: data) {
            Image(uiImage: uiimage)
                .resizable()
                .background (Color.gray)
                .scaledToFit()
                .cornerRadius(CGFloat(resolution))
                .frame(width: CGFloat(resolution), height: CGFloat(resolution))
                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y:0)
                .onAppear{
                    fetchData()
                }
        }
        else {
            Image("Soundlytude empty placeHolder")
                .resizable()
                .scaledToFit()
                .cornerRadius(CGFloat(resolution))
                .frame(width: CGFloat(resolution), height: CGFloat(resolution))
                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y:0)
                .opacity(0.1)
                .onAppear {
                    fetchData()
                }
        }
    }
    
    private func fetchData(){
        guard let url = URL(string: "\(newlyUpdatedPfpUrl)/v1/fill/w_\(resolution * multiply),h_\(resolution * multiply),al_c/\(imageTitle.replacingOccurrences(of: " ", with: "+")).jpg") else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, _, _
            in
            self.data = data
        }
        task.resume( )
    }
}

struct squareImageChat: View {
    var imageTitle: String = "Soundlytude Image"
    var cornerRadius: CGFloat = 10
    var x: String
    var caption: String
    var resolution: Int = 427
    var OGSize: Bool = true
    var maxWidth: Double = 170
    var maxHeight: Double = 255
    
    @State var viewImageLinkActivated: Bool = false
    @State var viewImageLinkView: AnyView = AnyView(EmptyView())
    @State var uiImageW: Double = 256
    @State var uiImageH: Double = 384
    var body: some View {
        //        Button {
        //        } label: {
        ZStack(alignment: .bottom){
            AsyncImage(url: URL(string: "\(x)/v1/fit/w_\(resolution),h_\(resolution),al_c/\(imageTitle.replacingOccurrences(of: " ", with: "+")).jpg")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .background(rectReader())
                    .background(
                        NavigationLink(destination: viewImageLinkView, isActive: $viewImageLinkActivated) {
                            EmptyView()
                        }
                            .hidden()
                    )
                    .if(OGSize) { view in
                        view.frame(width: uiImageW, height: uiImageH)
                    }
                    .if(!OGSize){ view in
                        view.frame(maxWidth: maxWidth, maxHeight: maxHeight)
                    }
            } placeholder: {
                ProgressView()
            }
            if caption != "" {
                Text(caption)
                    .frame(width: OGSize ? (uiImageW - 10) : (maxWidth - 10))
                    .padding(.all, 5)
                    .foregroundColor(Color.white)
                    .background(Color.black.opacity(0.5))
                    .lineLimit(10)
            }
        }
        .onTapGesture {
            viewImageLinkView = AnyView(VStack{fullScreenImageView(urlString: x);Text(caption).padding()})
            viewImageLinkActivated = true
        }
        //        }
    }
//
//    private func rectReader() -> some View {
//       GeometryReader { (geometry) -> Color in
//            let imageSize = geometry.size
//            DispatchQueue.main.async {
//                self.uiImageW = imageSize.width
//                self.uiImageH = imageSize.height
//                print("AHHHHH: ", imageSize)
//            }
//            return Color.clear
//        }
//    }
    
    private func rectReader() -> some View {
        return GeometryReader { (geometry) -> Color in
            let imageSize = geometry.size
            DispatchQueue.main.async {
                if imageSize.width > maxWidth {
                    let x = imageSize.width - maxWidth
                    self.uiImageW = maxWidth
                    self.uiImageH = (imageSize.height - x) < 0 ? 1 : (imageSize.height - x)
                }else{
                    if imageSize.height > maxHeight{
                        let x = imageSize.height - maxHeight
                        self.uiImageW = (imageSize.width - x) < 0 ? 1 : (imageSize.width - x)
                        self.uiImageH = maxHeight
                    }else{
                        self.uiImageW = imageSize.width
                        self.uiImageH = imageSize.height
                    }
                }
//                self.uiImageH = imageSize.height
            }
            return .clear
        }
    }
}

struct squareImageChatBackup: View { //NOT USING
    var imageTitle: String = "Soundlytude Image"
    var cornerRadius: CGFloat = 10
    var x: messengerPageFetchMessagesField
    var resolution: Int = 384
    
    @State var viewImageLinkActivated: Bool = false
    @State var viewImageLinkView: AnyView = AnyView(EmptyView())
    @State var uiImageW: Double = 256
    @State var uiImageH: Double = 384
    var body: some View {
//        Button {
//        } label: {
            ZStack(alignment: .bottom){
                VStack{
                    ForEach(x.photo ?? [], id: \.self){i in
                        let scaleEffect: Double = Double(1/((x.photo!.firstIndex(of: i)!) + 1))
                        AsyncImage(url: URL(string: "\(i)/v1/fit/w_\(resolution),h_\(resolution),al_c/\(imageTitle.replacingOccurrences(of: " ", with: "+")).jpg")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .background(rectReader())
                                .background(
                                    NavigationLink(destination: viewImageLinkView, isActive: $viewImageLinkActivated) {
                                        EmptyView()
                                    }
                                        .hidden()
                                )
                                .frame(width: uiImageW, height: uiImageH)
                        } placeholder: {
                            ProgressView()
                        }
                    }
                }
                if (x.text ?? "") != "" {
                    Text(x.text ?? "")
                        .frame(width: (uiImageW - 10))
                        .padding(.all, 5)
                        .foregroundColor(Color.white)
                        .background(Color.black.opacity(0.5))
                        .lineLimit(10)
                }
            }
            .onTapGesture {
                viewImageLinkView = AnyView(VStack{fullScreenImageView(urlString: x.photo?[0] ?? "");Text(x.text ?? "").padding()})
                viewImageLinkActivated = true
            }
//        }
    }
//
//    private func rectReader() -> some View {
//       GeometryReader { (geometry) -> Color in
//            let imageSize = geometry.size
//            DispatchQueue.main.async {
//                self.uiImageW = imageSize.width
//                self.uiImageH = imageSize.height
//                print("AHHHHH: ", imageSize)
//            }
//            return Color.clear
//        }
//    }
    
    private func rectReader() -> some View {
        return GeometryReader { (geometry) -> Color in
            let imageSize = geometry.size
            DispatchQueue.main.async {
                if imageSize.width > 256 {
                    let x = imageSize.width - 256
                    self.uiImageW = 256
                    self.uiImageH = (imageSize.height - x) < 0 ? 1 : (imageSize.height - x)
                }else{
                    if imageSize.height > 384{
                        let x = imageSize.height - 384
                        self.uiImageW = (imageSize.width - x) < 0 ? 1 : (imageSize.width - x)
                        self.uiImageH = 384
                    }else{
                        self.uiImageW = imageSize.width
                        self.uiImageH = imageSize.height
                    }
                }
//                self.uiImageH = imageSize.height
            }
            return .clear
        }
    }
}

struct squareImageChat2: View {
    var imageTitle: String = "Soundlytude Image"
    var cornerRadius: CGFloat = 10
    var x: String
    var caption: String
    var resolution: Int = 427
    var OGSize: Bool = true
    var maxWidth: Double = 170
    var maxHeight: Double = 255
    
    @State var viewImageLinkActivated: Bool = false
    @State var viewImageLinkView: AnyView = AnyView(EmptyView())
    @State var uiImageW: Double = 256
    @State var uiImageH: Double = 384
    
//    var imageTitle: String = "Soundlytude Image"
//    var cornerRadius: CGFloat = 10
////    var x: messengerPageFetchMessagesField
//    var x: messengerPageFetchMessagesField
//
//    @State var viewImageLinkActivated: Bool = false
//    @State var viewImageLinkView: AnyView = AnyView(EmptyView())
    @State var uiImageW2: Double = 0.0
//    @State var uiImageH2: Double = 0.0
    
    @State var data: Data?
    var body: some View {
        ZStack(alignment: .bottom){
            if let data = data, let uiimage = UIImage(data: data), let uiImageW = UIImage(data: data)?.size.width, let uiImageH = UIImage(data: data)?.size.height {
                Image(uiImage: uiimage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
//                    .frame(maxWidth: 192, maxHeight: 384)
                    .frame(width: uiImageW, height: uiImageH)
                    .background(
                        NavigationLink(destination: viewImageLinkView, isActive: $viewImageLinkActivated) {
                            EmptyView()
                        }
                            .hidden()
                    )
                    .onAppear{
                        uiImageW2 = uiImageW - 10
                    }
            }
            else {
                ProgressView()
                    .onAppear {
                        fetchData()
                    }
            }
            if caption != "" {
                Text(caption)
                    .frame(width: uiImageW2)
                    .padding(.all, 5)
                    .foregroundColor(Color.white)
                    .background(Color.black.opacity(0.5))
                    .lineLimit(10)
            }
        }
        .onTapGesture {
//            viewImageLinkView = AnyView(VStack{fullScreenImageView(urlString: x.photo ?? "");Text(x.text ?? "").padding()})
            viewImageLinkActivated = true
        }
    }
    
    private func fetchData(){
        guard let url = URL(string: "\(x)/v1/fit/w_\(resolution),h_\(resolution),al_c/\(imageTitle.replacingOccurrences(of: " ", with: "+")).jpg") else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, _, _
            in
            self.data = data
        }
        task.resume( )
    }
}


struct squareImageChatOriginal: View {
    var urlString: String
    var imageTitle: String = "Soundlytude Image"
    var cornerRadius: CGFloat = 10
    @State var data: Data?
    var body: some View {
        if let data = data, let uiimage = UIImage(data: data) {
            Image(uiImage: uiimage)
                .resizable()
                .aspectRatio(contentMode: .fill)
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//                .scaledToFit()
//                .frame(width: 256, height: 256)
        }
        else {
            ProgressView()
                .onAppear {
                    fetchData()
                }
        }
    }
    private func fetchData(){
        guard let url = URL(string: "\(urlString)/v1/fill/w_256,h_256,al_c/\(imageTitle.replacingOccurrences(of: " ", with: "+")).jpg") else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, _, _
            in
            self.data = data
        }
        task.resume( )
    }
}

struct squareImageChatFullScreen: View {
    var urlString: String
    var imageTitle: String = "Soundlytude Image"
    var cornerRadius: CGFloat = 1
    @State var data: Data?
    var body: some View {
        if let data = data, let uiimage = UIImage(data: data) {
            Image(uiImage: uiimage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .background (Color.gray)
                .cornerRadius(cornerRadius)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y:5)
        }
        else {
            Image("Soundlytude empty placeHolder")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .opacity(0.1)
                .cornerRadius(cornerRadius)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    fetchData()
                }
        }
    }
    private func fetchData(){
        guard let url = URL(string: "\(urlString)/v1/fit/w_768,h_768,al_c/\(imageTitle.replacingOccurrences(of: " ", with: "+")).png") else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, _, _
            in
            self.data = data
        }
        task.resume( )
    }
}

struct squareImageMaxDisplay: View {
    var urlString: String
    var imageTitle: String = "Soundlytude Image"
    var cornerRadius: CGFloat = 10
    @State var data: Data?
    var body: some View {
        if let data = data, let uiimage = UIImage(data: data) {
            Image(uiImage: uiimage)
                .resizable()
                .background (Color.gray)
                .scaledToFill()
                .cornerRadius(10)
                .clipped()
                .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y:5)
        }
        else {
            Image("Soundlytude empty placeHolder")
                .resizable()
                .background (Color.gray)
                .scaledToFill()
                .cornerRadius(10)
                .clipped()
                .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y:5)
                .opacity(0.1)
                .onAppear {
                    fetchData()
                }
        }
    }
    private func fetchData(){
        guard let url = URL(string: "\(urlString)/v1/fill/w_512,h_512,al_c/\(imageTitle.replacingOccurrences(of: " ", with: "+")).jpg") else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, _, _
            in
            self.data = data
        }
        task.resume( )
    }
}


struct CustomPicker : View {
    
    @Binding var selected : [SelectedImages]
    @State var grid : [[Images]] = []
    @Binding var show : Bool
    @State var disabled = false
    @State var gotAllImages = false
    
    var body: some View{
        
        GeometryReader{ geo in
            
            ZStack{
                if !self.grid.isEmpty{
                    ScrollView(.vertical, showsIndicators: false) {
                        Spacer().frame(height: 50)
                        VStack(alignment: .leading, spacing: 1){
                            
                            ForEach(self.grid,id: \.self){i in
                                
                                HStack(spacing: 1){
                                    
                                    ForEach(i,id: \.self){j in
                                        
                                        Card(data: j, selected: self.$selected, width: geo.size.width)
                                    }
                                }
                            }
                        }
                        .padding(.bottom)
                        Spacer().frame(height: 50)
                    }
                    VStack(spacing: 0){
                        HStack{
                            Button(role: .destructive, action: {
                                selected = []
                                self.show.toggle()
                            }) {
                                Text(selected == [] ? "Cancel" : "Remove all and cancel")
                            }
                            Spacer()
                            
                            Text("Pick a Image")
                                .fontWeight(.bold)
                            
                        }
                        .padding()
                        .frame(height: 50)
                        .background(BlurView())
                        Divider()
                        Spacer()
                        ZStack{
                            BlurView().ignoresSafeArea()
                            VStack(spacing: 0){
                                Divider()
                                Button(action: {
                                    
                                    self.show.toggle()
                                    
                                }) {
                                    
                                    Text("Select (\(self.selected.count)/10)")
                                        .foregroundColor(.white)
                                        .padding(.vertical,10)
                                        .frame(width: UIScreen.main.bounds.width / 2)
                                }
                                .background(Color.red.opacity((self.selected.count != 0) ? 1 : 0.5))
                                .clipShape(Capsule())
                                .padding()
                                .disabled((self.selected.count != 0) ? false : true)
                            }
                        }
                        .frame(height: 50)
                    }
                }
                else{
                    
                    if self.disabled{
                        VStack{
                            Text("Enable Storage Access In Settings!")
                                .padding(.top, 60)
                            Spacer()
                        }
                    }
                    if self.grid.count == 0{
                        VStack{
                            ProgressView()
                                .padding(.top, 60)
                            Spacer()
                        }
                    }
                }
            }
        }
//        .background(Color.black.opacity(0.1).edgesIgnoringSafeArea(.all)
//        .onTapGesture {
//
//            self.show.toggle()
//
//        })
        .onAppear {
            print(selected)
            PHPhotoLibrary.requestAuthorization { (status) in
                
                if status == .authorized{
                    if !gotAllImages {
                        self.getAllImages()
                        self.disabled = false
                        gotAllImages = true
                    }
                }
                else{
                    
                    print("not authorized")
                    self.disabled = true
                }
            }
        }
    }
    
    func getAllImages(){
        
        let opt = PHFetchOptions()
        opt.includeHiddenAssets = false
        
        let req = PHAsset.fetchAssets(with: .image, options: .none)
        
        DispatchQueue.global(qos: .background).async {

           let options = PHImageRequestOptions()
           options.isSynchronous = true
                
        // New Method For Generating Grid Without Refreshing....
          for i in stride(from: 0, to: req.count, by: 3){
                    
                var iteration : [Images] = []
                    
              for j in i..<i+3{
                  if (j < req.count){
                      var m: Int = (req.count - 1) - j
                      PHCachingImageManager.default().requestImage(for: req[m], targetSize: CGSize(width: viewableWidth/1.5, height: viewableWidth/1.5), contentMode: .default, options: options) { (image, _) in
                          
                          let data1 = Images(image: image!, selected: false, asset: req[m])
                          
                          iteration.append(data1)
                          
                      }
                  }
              }
//              if !removed {
//                  removed = true
//                  iteration.remove(at: 0)
//              }
              self.grid.append(iteration)
            }
            
        }
    }
}

struct Card : View {
    
    @State var data : Images
    @Binding var selected : [SelectedImages]
    @State var width : Double
    
    var body: some View{
        Button {
            if !self.data.selected{
                if !(self.selected.count > 9){
                    self.data.selected = true
                    
                    // Extracting Orginal Size of Image from Asset
                    
                    DispatchQueue.global(qos: .background).async {
                        
                        let options = PHImageRequestOptions()
                        options.isSynchronous = true
                        
                        // You can give your own Image size by replacing .init() to CGSize....
                        
                        PHCachingImageManager.default().requestImage(for: self.data.asset, targetSize: .init(), contentMode: .default, options: options) { (image, _) in
                            var selectedIndex = 0
                            let filtered = selected.filter { word in
                                return word.asset == self.data.asset
                            }
                            if filtered.count < 1{
                                self.selected.append(SelectedImages(asset: self.data.asset, image: image!))
                            }
                        }
                    }
                }
            }
            else{
                
                for i in 0..<self.selected.count{
                    
                    if self.selected[i].asset == self.data.asset{
                        
                        self.selected.remove(at: i)
                        self.data.selected = false
                        return
                    }
                    
                }
            }
        } label: {
            Image(uiImage: self.data.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: (width / 3), height: (width / 3))
                .clipped()
                .overlay(
                    ZStack{
                        Color.black.opacity(self.data.selected ? 0.5 : 0.001)
                        if self.data.selected{
                            Image(systemName: "checkmark")
                                .resizable()
                                .foregroundColor(.white)
                                .frame(width: (width / 9), height: (width / 9))
                        }
                    })
        }
        .onAppear{
            let filtered = selected.filter { word in
                return word.asset == self.data.asset
            }
            if filtered.count > 0{
                self.data.selected = true
            }
//            if selected.contains(SelectedImages(asset: self.data.asset, image: self.data.image)){
//                self.data.selected = true
//            }
        }
    }
}

struct Indicator : UIViewRepresentable {
    
    func makeUIView(context: Context) -> UIActivityIndicatorView  {
        
        let view = UIActivityIndicatorView(style: .large)
        view.startAnimating()
        return view
    }
    
    func updateUIView(_ uiView:  UIActivityIndicatorView, context: Context) {
        
        
    }
}

struct Images: Hashable {
    
    var image : UIImage
    var selected : Bool
    var asset : PHAsset
}

struct SelectedImages: Hashable{
    
    var asset : PHAsset
    var image : UIImage
}


struct MultipleImagePicker: UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator {
        return MultipleImagePicker.Coordinator(parent1: self)
    }
    
    @Binding var images: [UIImage]
    @Binding var show: Bool
    @State var reset: Bool = false
    
    func makeUIViewController(context: Context) -> some UIViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 10 //0 = unlimited selection
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        //
    }
    
    class Coordinator: NSObject,PHPickerViewControllerDelegate{
        var parent: MultipleImagePicker
        
        init(parent1: MultipleImagePicker){
            parent = parent1
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.show.toggle()
            
            for img in results{
                //checking whether the image can be loaded
                if img.itemProvider.canLoadObject(ofClass: UIImage.self){
                    img.itemProvider.loadObject(ofClass: UIImage.self) { (image, err) in
                        guard let image1 = image else {
                            print("ERROR")
                            return
                        }
                        if !self.parent.reset {
                            self.parent.images = []
                            self.parent.reset = true
                        }
                        self.parent.images.append(image1 as! UIImage)
                    }
                }else{
                    print("ERROR: Cannot be loaded")
                }
            }
        }
    }
}
