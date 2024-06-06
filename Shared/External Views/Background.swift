//
//  Background.swift
//  Soundlytude
//
//  Created by DJ bon26 on 9/17/22.
//

import SwiftUI

struct Background: View {
    var backgroundColor: String
    var type: String
    var body: some View {
        if type == "Hex"{
            VStack{
                Color(hexStringToUIColor(hex: backgroundColor))
            }.ignoresSafeArea()
        }
        if type == "Accent"{
            VStack{
                Color("\(backgroundColor)")
            }.ignoresSafeArea()
        }
    }
}

struct Background_Previews: PreviewProvider {
    static var previews: some View {
        Background(backgroundColor: "AccentColor", type: "Accent")
    }
}
