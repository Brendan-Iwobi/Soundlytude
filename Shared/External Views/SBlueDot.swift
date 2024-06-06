//
//  SBlue dot.swift
//  Soundlytude
//
//  Created by DJ bon26 on 9/17/22.
//

import SwiftUI

struct SBlueDot: View {
    var scale: CGFloat = 5
    var color: Color = Color.accentColor
    var body: some View {
        Circle()
            .frame(width: scale, height: scale)
            .foregroundColor(color)
    }
}

struct SBlueDot_Previews: PreviewProvider {
    static var previews: some View {
        SBlueDot()
    }
}
