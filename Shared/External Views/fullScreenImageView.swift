//
//  fullScreenImageView.swift
//  Soundlytude (iOS)
//
//  Created by DJ bon26 on 11/12/22.
//

import SwiftUI

struct fullScreenImageView: View {
    var urlString: String = "" //"https://static.wixstatic.com/media/0fd70b_317763f73b324ada82c9043962a0cce6~mv2.jpeg"
    @State var data: Data?
    @State var isDoneLoadingImage: Bool = true
    @State var disableButton: Bool = false
    
    @State private var presentAlert = false
    @State private var presentAlertTitle = ""
    @State private var presentAlertMessage = "Something isn't right on your end"
    var body: some View {
        VStack{
            squareImageChatFullScreen(urlString: urlString)
            bottomSpace()
        }
        .alert(presentAlertTitle, isPresented: $presentAlert, actions: {
            Button("OK", role: .cancel, action: { disableButton = false })
        }, message: {
            Text(presentAlertMessage)
        })
        .toolbar{
            ToolbarItem(placement: .navigation){
                Button {
                    disableButton = true
                    fetchData()
                    saveImage()
                    print("Started")
                } label: {
                    if isDoneLoadingImage {
                        Text("Save")
                    }else{
                        Text("Saving...")
                    }
                }.disabled(disableButton)
                
            }
        }
    }
    
    func saveImage() {
        var x = 0
        if(isDoneLoadingImage){
            x = x + 1
            if x == 1 {
                if let data = data, let uiimage = UIImage(data: data) {
                    let imageSaver = ImageSaver()
                    imageSaver.writeToPhotoAlbum(image: uiimage)
                }else{
                    presentAlertTitle = "Something isn't right on your end"
                    presentAlertMessage = "There was an error saving that image. Please try again later"
                    presentAlert = true
                    print("didn't save")
                }
                print("CHek point 1")
            }
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                saveImage()
            }
        }
    }
    private func fetchData(){
        isDoneLoadingImage = false
        guard let url = URL(string: "\(urlString)/v1/fit/w_768,h_768,al_c/Soundlytude-Image.png") else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, _, _
            in
            self.data = data
            isDoneLoadingImage = true
            
        }
        task.resume( )
    }
}

struct fullScreenImageView_Previews: PreviewProvider {
    static var previews: some View {
        fullScreenImageView()
    }
}

class ImageSaver: NSObject {
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("Save finished!")
    }
}
