//
//  FormateMinutes.swift
//  Soundlytude
//
//  Created by DJ bon26 on 9/23/22.
//

import Foundation
import SwiftUI

func FormatMinutes(time: Double) -> String {
    let minute = (Int(time/60) > 9) ? "\(Int(time/60))" : "0\(Int(time/60))"
    let seconds = (Int(time.truncatingRemainder(dividingBy: 60)) > 9) ? "\(Int(time.truncatingRemainder(dividingBy: 60)))" : "0\(Int(time.truncatingRemainder(dividingBy: 60)))"
    if time < 0.01{
        return "--:--"
    }
    let toReturn = "\(minute):\(seconds)"
    return toReturn
}
