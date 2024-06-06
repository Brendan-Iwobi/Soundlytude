//
//  iconButton.swift
//  Soundlytude (iOS)
//
//  Created by DJ bon26 on 11/8/22.
//

import SwiftUI

struct IconButton: View {
    var icon: String = "music.note"
    var size: CGFloat = 40
    var background: Color = Color.accentColor.opacity(0.25)
    var foregroundColor: Color = Color.accentColor
    var body: some View {
        ZStack{
            VStack{EmptyView()}
                .frame(width: size, height: size)
                .background(background)
            Image(systemName: icon)
                .frame(width: 10, height: 10)
//                .font(Font.headline.weight(.bold))
                .foregroundColor(foregroundColor)
        }.cornerRadius(100)
    }
}

struct IconButton_Previews: PreviewProvider {
    static var previews: some View {
        IconButton()
    }
}
