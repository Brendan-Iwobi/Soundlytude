//
//  roundedCornerFunction.swift
//  Soundlytude
//
//  Created by DJ bon26 on 9/17/22.
//

import Foundation
import SwiftUI

struct roundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( roundedCorner(radius: radius, corners: corners) )
    }
}

