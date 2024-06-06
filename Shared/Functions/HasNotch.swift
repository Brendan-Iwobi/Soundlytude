//
//  HasNotch.swift
//  Soundlytude
//
//  Created by DJ bon26 on 9/16/22.
//

import Foundation
import SwiftUI

//extension UIDevice {
//    /// Returns `true` if the device has a notch
//    var hasNotch: Bool {
//        guard #available(iOS 11.0, *), let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else { return false }
//        if UIDevice.current.orientation.isPortrait {
//            return window.safeAreaInsets.top >= 44
//        } else {
//            return window.safeAreaInsets.left > 0 || window.safeAreaInsets.right > 0
//        }
//    }
//}

extension UIDevice {
    
    /// Returns 'true' if the current device has a notch
    var hasNotch: Bool {
        if #available(iOS 11.0, *) {
            // Case 1: Portrait && top safe area inset >= 44
            let case1 = !UIDevice.current.orientation.isLandscape && (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0) >= 44
            // Case 2: Lanscape && left/right safe area inset > 0
            let case2 = UIDevice.current.orientation.isLandscape && ((UIApplication.shared.keyWindow?.safeAreaInsets.left ?? 0) > 0 || (UIApplication.shared.keyWindow?.safeAreaInsets.right ?? 0) > 0)
            
            return case1 || case2
        } else {
            // Fallback on earlier versions
            return false
        }
    }
}
