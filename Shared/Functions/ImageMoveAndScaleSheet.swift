//
//  ImageMoveAndScaleSheet.swift
//  Soundlytude (iOS)
//
//  Created by DJ bon26 on 1/6/23.
//

import SwiftUI
import Foundation
import UIKit

struct ImageMoveAndScaleSheet: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isShowingImagePicker = false
    
    ///The croped image is what will will send back to the parent view.
    ///It should be the part of the image in the square defined by the
    ///cutout circle's diamter. See below, the cutout circle has an "inset" value
    ///which can be changed.
    @Binding var croppedImage: UIImage?
    
    ///The input image is received from the ImagePicker.
    ///We will need to calculate and refer to its aspectr ratio in the functions.
    @State private var inputImage: UIImage?
    @State private var inputW: CGFloat = 750.5556577
    @State private var inputH: CGFloat = 1336.5556577
    
    @State private var theAspectRatio: CGFloat = 0.0
    
    ///The profileImage is what wee see on this view. When added from the
    ///ImapgePicker, it will be sized to fit the screen,
    ///meaning either its width will match the width of the device's screen,
    ///or its height will match the height of the device screen.
    ///This is not suitable for landscape mode or for iPads.
    @State private var profileImage: Image?
    @State private var profileW: CGFloat = 0.0
    @State private var profileH: CGFloat = 0.0
    
    ///Zoom and Drag ...
    @State private var currentAmount: CGFloat = 0
    @State private var finalAmount: CGFloat = 1
    
    @State private var currentPosition: CGSize = .zero
    @State private var newPosition: CGSize = .zero
    
    ///We track of amount the image is moved for use in functions below.
    @State private var horizontalOffset: CGFloat = 0.0
    @State private var verticalOffset: CGFloat = 0.0
    ///Alert Errors
    @State private var presentAlert = false
    @State private var presentAlertTitle = ""
    @State private var presentAlertMessage = "Something isn't right on your end"
    
    var body: some View {
        
        ZStack {
            ZStack {
                Color("WhiteBlack").opacity(0.8)
                if profileImage != nil {
                    profileImage?
                        .resizable()
                        .scaleEffect(finalAmount + currentAmount)
                        .scaledToFill()
                        .aspectRatio(contentMode: .fit)
                        .offset(x: self.currentPosition.width, y: self.currentPosition.height)
                } else {
                    Image(systemName: "photo")
                        .font(.system(size: 64))
                        .opacity(0.5)
                }
            }
            Rectangle()
                .fill(Color.black).opacity(0.625)
                .mask(HoleShapeMask().fill(style: FillStyle(eoFill: true)))
                .edgesIgnoringSafeArea(.all)
            VStack {
                Text((profileImage != nil) ? "Move and Scale" : "Select a Photo by tapping the icon below")
                    .foregroundColor(.white)
                Spacer()
                HStack {
                    Button(role: .cancel) {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Cancel")
                    }
                    Spacer()
                    Button {
                        isShowingImagePicker = true
                    } label: {
                        ZStack{
                            Image(systemName: "circle.fill")
                                .font(.custom("system", size: 50))
                                .foregroundColor(.white)
                            Image(systemName: "photo.on.rectangle")
                                .imageScale(.medium)
                                .foregroundColor(.black)
                        }
                    }
                    Spacer()
                    Button {
                        self.save()
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Save")
                    }
                    .disabled((profileImage != nil) ? false: true)
                    
                }
                .padding(.horizontal)
            }
            .padding()
            .alert(presentAlertTitle, isPresented: $presentAlert, actions: {
                Button("OK", role: .cancel, action: { })
            }, message: {
                Text(presentAlertMessage)
            })
        }
        
        //MARK: - Gestures
        
        .gesture(
            MagnificationGesture()
                .onChanged { amount in
                    self.currentAmount = amount - 1
                    fixSmallScaleError()
                }
                .onEnded { amount in
                    self.finalAmount += self.currentAmount
                    self.currentAmount = 0
                    repositionImage()
                    fixSmallScaleError()
                }
        )
        .simultaneousGesture(
            DragGesture()
                .onChanged { value in
                    self.currentPosition = CGSize(width: value.translation.width + self.newPosition.width, height: value.translation.height + self.newPosition.height)
                    fixSmallScaleError()
                }
                .onEnded { value in
                    self.currentPosition = CGSize(width: value.translation.width + self.newPosition.width, height: value.translation.height + self.newPosition.height)
                    self.newPosition = self.currentPosition
                    repositionImage()
                    fixSmallScaleError()
                }
        )
        .simultaneousGesture(
            TapGesture(count: 2)
                .onEnded({
                    resetImageOriginAndScale()
                })
        )
        .sheet(isPresented: $isShowingImagePicker, onDismiss: loadImage) {
            UIImagePicker(image: self.$inputImage)
                .tint(Color.systemRed)
                .accentColor(Color.systemRed)
        }
    }
    
    //MARK: - functions
    
    private func HoleShapeMask() -> Path {
        let rect = CGRect(x: 0, y: 0, width: viewableWidth, height: UIScreen.main.bounds.height)
        let insetRect = CGRect(x: inset, y: inset, width: viewableWidth - ( inset * 2 ), height: UIScreen.main.bounds.height - ( inset * 2 ))
        var shape = Rectangle().path(in: rect)
        shape.addPath(Circle().path(in: insetRect))
        return shape
    }
    
    ///Called when the ImagePicker is dismissed.
    ///We want to measure the image receoived and determine the aspect ratio.
    
    private func loadImage() {
        guard let inputImage = inputImage else { return }
        let w = inputImage.size.width
        let h = inputImage.size.height
        profileImage = Image(uiImage: inputImage)
        
        inputW = w
        inputH = h
        theAspectRatio = w / h
        
        resetImageOriginAndScale()
    }
    
    ///The profileImage will size to fit the screen.
    ///But we need to know the width and height
    ///to set the related @State variables.
    ///Douobke-tpping the image will also set it
    ///as it was sized originally upon loading.
    private func resetImageOriginAndScale() {
        withAnimation(.easeInOut){
            if theAspectRatio >= screenAspect {
                profileW = viewableWidth
                profileH = profileW / theAspectRatio
            } else {
                profileH = UIScreen.main.bounds.height
                profileW = profileH * theAspectRatio
            }
            currentAmount = 0
            finalAmount = 1
            currentPosition = .zero
            newPosition = .zero
        }
    }
    
    private func fixSmallScaleError(){
        let scale = (inputImage?.size.width ?? 0) / profileW
        let radius = ( viewableWidth - inset * 2 ) * scale
        if radius > 20000 || radius < 0 {
            resetImageOriginAndScale()
        }
    }
    
    private func repositionImage() {
        
        //Screen width
        let w = viewableWidth
        
        if theAspectRatio > screenAspect {
            profileW = viewableWidth * finalAmount
            profileH = profileW / theAspectRatio
        } else {
            profileH = UIScreen.main.bounds.height * finalAmount
            profileW = profileH * theAspectRatio
        }
        
        horizontalOffset = (profileW - w ) / 2
        verticalOffset = ( profileH - w ) / 2
        
        
        ///Keep the user from zooming too far in. Adjust as required by the individual project.
        if finalAmount > 4.0 {
            withAnimation{
                finalAmount = 4.0
            }
        }
        
        ///The following if statements keep the image filling the circle cutout.
        if profileW >= viewableWidth {
            
            if newPosition.width > horizontalOffset {
                withAnimation(.easeInOut) {
                    newPosition = CGSize(width: horizontalOffset + inset, height: newPosition.height)
                    currentPosition = CGSize(width: horizontalOffset + inset, height: currentPosition.height)
                }
            }
            
            if newPosition.width < ( horizontalOffset * -1) {
                withAnimation(.easeInOut){
                    newPosition = CGSize(width: ( horizontalOffset * -1) - inset, height: newPosition.height)
                    currentPosition = CGSize(width: ( horizontalOffset * -1 - inset), height: currentPosition.height)
                }
            }
        } else {
            
            withAnimation(.easeInOut) {
                newPosition = CGSize(width: 0, height: newPosition.height)
                currentPosition = CGSize(width: 0, height: newPosition.height)
            }
        }
        
        if profileH >= viewableWidth {
            
            if newPosition.height > verticalOffset {
                withAnimation(.easeInOut){
                    newPosition = CGSize(width: newPosition.width, height: verticalOffset + inset)
                    currentPosition = CGSize(width: newPosition.width, height: verticalOffset + inset)
                }
            }
            
            if newPosition.height < ( verticalOffset * -1) {
                withAnimation(.easeInOut){
                    newPosition = CGSize(width: newPosition.width, height: ( verticalOffset * -1) - inset)
                    currentPosition = CGSize(width: newPosition.width, height: ( verticalOffset * -1) - inset)
                }
            }
        } else {
            
            withAnimation (.easeInOut){
                newPosition = CGSize(width: newPosition.width, height: 0)
                currentPosition = CGSize(width: newPosition.width, height: 0)
            }
        }
        
        if profileW <= viewableWidth && theAspectRatio > screenAspect {
            resetImageOriginAndScale()
        }
        if profileH <= UIScreen.main.bounds.height && theAspectRatio < screenAspect {
            resetImageOriginAndScale()
        }
    }
    
    private func save() {
        
        let scale = (inputImage?.size.width)! / profileW
        
        let xPos = ( ( ( profileW - viewableWidth ) / 2 ) + inset + ( currentPosition.width * -1 ) ) * scale
        let yPos = ( ( ( profileH - viewableWidth ) / 2 ) + inset + ( currentPosition.height * -1 ) ) * scale
        let radius = ( viewableWidth - inset * 2 ) * scale
        
        croppedImage = imageWithImage(image: inputImage!, croppedTo: CGRect(x: xPos, y: yPos, width: radius, height: radius))
        
        ///Debug maths
        print("Input: w \(inputW) h \(inputH)")
        print("Profile: w \(profileW) h \(profileH)")
        print("X Origin: \( ( ( profileW - viewableWidth - inset ) / 2 ) + ( currentPosition.width  * -1 ) )")
        print("Y Origin: \( ( ( profileH - viewableWidth - inset) / 2 ) + ( currentPosition.height  * -1 ) )")
        
        print("Scale: \(scale)")
        print("Profile:\(profileW) + \(profileH)" )
        print("Curent Pos: \(currentPosition.debugDescription)")
        print("Radius: \(radius)")
        print("x:\(xPos), y:\(yPos)")
    }
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.draw(in: CGRectMake(0, 0, newWidth, newHeight))
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage(named: "Soundlytude empty placeHolder")! }
        UIGraphicsEndImageContext()
        
        return newImage
    }
    let inset: CGFloat = 15
    let screenAspect = viewableWidth / UIScreen.main.bounds.height
}
