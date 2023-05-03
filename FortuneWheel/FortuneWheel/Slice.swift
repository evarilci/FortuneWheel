//
//  Slice.swift
//  FortuneWheel
//
//  Created by Eymen Varilci on 3.05.2023.
//

import UIKit

class Slice {
    
    
    /**Color of the slice default is clear*/
      var color = UIColor.clear
      /**Image to be shown in the slice*/
      var image : UIImage
      /**Border line Colour.Default color is White*/
      var borderColour = UIColor.white
      /**Width of the border line.Default is 0.5*/
      var borderWidth : CGFloat = 1
      
      init(image : UIImage)
      {
          self.image = image
      }

    
}
