//
//  Degree + Extension.swift
//  FortuneWheel
//
//  Created by Eymen Varilci on 3.05.2023.
//

import Foundation

typealias Degree = CGFloat
typealias Radians = CGFloat
extension Degree {
    func toRadians() -> Radians {
        return (self * .pi) / 180.0
    }
}
