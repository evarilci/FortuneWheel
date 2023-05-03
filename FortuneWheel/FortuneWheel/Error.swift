//
//  Error.swift
//  FortuneWheel
//
//  Created by Eymen Varilci on 3.05.2023.
//

import Foundation
class FortuneWheelError: Error
{
    let message : String
    let code : Int
    init(message : String , code : Int) {
        self.message = message
        self.code = code
    }
    
}
