//
//  ViewController.swift
//  FortuneWheel
//
//  Created by Eymen Varilci on 3.05.2023.
//

import UIKit

class ViewController: UIViewController {
    
    var slices = [Slice]()
  
  override func viewDidLoad() {
        super.viewDidLoad()
      view.backgroundColor = .systemGray6
      self.ShowFortuneWheel()
    }
    
    //Assign the center CGPoint for the wheel and a diameter adn the slices it should show and conform to the protocol
    func ShowFortuneWheel() {

        for i in 1...10
        {
            let slice = Slice.init(image: UIImage.init(named: "\(i <= 5 ? i : (i - 5))")!)
            slice.color = .random()
            slices.append(slice)
        }
        let fortuineWheel = FortuneWheel.init(center: CGPoint.init(x: self.view.frame.width/2, y: self.view.frame.height/2), diameter: 300, slices: slices)
        
        fortuineWheel.delegate = self
        self.view.addSubview(fortuineWheel)
    }

}

//Conform to the delegate
extension ViewController : FortuneWheelDelegate
{
    func shouldSelectObject() -> Int? {
        return Int.random(in: 0...slices.count)
    }
    
    func finishedSelecting(index: Int?, error: FortuneWheelError?) {
        dump(index)
    }
}
