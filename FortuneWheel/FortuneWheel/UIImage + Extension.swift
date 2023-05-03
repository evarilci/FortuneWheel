//
//  UIImage + Extension.swift
//  FortuneWheel
//
//  Created by Eymen Varilci on 3.05.2023.
//

import UIKit



extension UIImage
 {
    func rotateImage(angle:Radians) -> UIImage? {
        let ciImage = CIImage(image: self)
        
        let filter = CIFilter(name: "CIAffineTransform")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setDefaults()
        
        let newAngle = angle * CGFloat(1)
        
        var transform = CATransform3DIdentity
        
        transform = CATransform3DRotate(transform, CGFloat(newAngle), 0, 0, 1)
        
        let affineTransform = CATransform3DGetAffineTransform(transform)
        
        filter?.setValue(NSValue(cgAffineTransform: affineTransform), forKey: "inputTransform")
        
        let contex = CIContext(options: [CIContextOption.useSoftwareRenderer:true])
        
        let outputImage = filter?.outputImage
        let cgImage = contex.createCGImage(outputImage!, from: (outputImage?.extent)!)
        
        let result = UIImage(cgImage: cgImage!)
        return result
    }
    
}



extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(red:   .random(),
                       green: .random(),
                       blue:  .random(),
                       alpha: 1.0)
    }
}
