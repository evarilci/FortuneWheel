//
//  FortuneWheel.swift
//
//
//  Created by Eymen Varilci on 3.05.2023.
//

import UIKit


protocol FortuneWheelDelegate : NSObject
{
    
    /*returns the index which should be selected when the user taps the spin button to start the game.
    Default value is -1*/
    /**Index which should be selected for array slices*/
    func shouldSelectObject() -> Int?
    func finishedSelecting(index : Int? , error : FortuneWheelError?)
    
}

extension FortuneWheelDelegate
{
    func finishedSelecting(index : Int? , error : FortuneWheelError?)
    {
        
    }
    
}






class FortuneWheel: UIView {
    
    
    
    weak var delegate : FortuneWheelDelegate?

    //Index which should be selected when the play button is tapped
    var selectionIndex : Int = -1

    
    
    /**Size of the imageView which indcates which slice has been selected*/
    private lazy var indicatorSize : CGSize = {
    let size = CGSize.init(width: self.bounds.width * 0.126 , height: self.bounds.height * 0.126)
    return size }()

    /**The number slices the wheel has to be divided into is determined by this array count and
    each slice object contains its corresponding slices Data.*/
    private var slices : [Slice]?

    
    /**ImageView that holds an image which indicates which slice has been selected.*/
    private var indicator = UIImageView.init()
    
    
    /**Button which starts the spin game.This is places at the center of wheel.*/
    var playButton : UIButton = UIButton.init(type: .custom)

    typealias Radians = CGFloat
    /**Angle each slice occupies.*/
    private var sectorAngle : Radians = 0
    
    
    /**The view on which the slices will be drawn.This view will be roatated to simuate the spin.*/
    private var wheelView : UIView!

    
    /**Creates and returns an FortuneWheel with its center aligned to center CGPoint , diameter and slices drawn*/
    init(center: CGPoint, diameter : CGFloat , slices : [Slice])
    {
       super.init(frame: CGRect.init(origin: CGPoint.init(x: center.x - diameter/2, y: center.y - diameter/2), size: CGSize.init(width: diameter, height: diameter)))
       self.slices = slices
       self.initialSetUp()
     }
    
    required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    }
    
     /**The setup of the fortune wheel is done here.*/
     private func initialSetUp(){
         self.backgroundColor = .clear
         self.addWheelView()
         self.addStartBttn()
         self.addIndicator()
     }
    
    
    private func addWheelView(){
       
        let width = self.bounds.width - self.indicatorSize.width
        let height = self.bounds.height - self.indicatorSize.height
        
        /**Calculating x,y positions such that wheel view is aligned with FortuneWheel at the center*/
        let xPosition : CGFloat = (self.bounds.width/2) - (width/2)
        let yPosition : CGFloat = (self.bounds.height/2) - (height/2)
        
        self.wheelView = UIView.init(frame: CGRect.init(x: xPosition, y: yPosition, width: width, height: height))
        self.wheelView.backgroundColor = .gray
        self.wheelView.layer.cornerRadius = width/2
        self.wheelView.clipsToBounds = true
        self.addSubview(self.wheelView)
        
       
        //This functions will draw the slices.We will get to this later.
        self.addWheelLayer()
     }
    
    private func addWheelLayer()
    {
       //We check if the slices array exists or not.if not we show an error.
       if let slices = self.slices
       {
          //We check if there are atleast 2 slices in the array.if not we show an error.
          if slices.count >= 2
          {
             self.wheelView.layer.sublayers?.forEach({$0.removeFromSuperlayer()})
                    
             
              self.sectorAngle = (2 * CGFloat.pi)/CGFloat(slices.count)
                    
             
             for (index,slice) in slices.enumerated()
             {
                //we will get to this class in a moment for now ignore the errors
                let sector = FortuneWheelSlice.init(frame: self.wheelView.bounds, startAngle: self.sectorAngle * CGFloat(index), sectorAngle: self.sectorAngle, slice: slice)
                self.wheelView.layer.addSublayer(sector)
                sector.setNeedsDisplay()
             }
          }
          else
          {
            let error = FortuneWheelError.init(message: "not enough slices. Should have atleast two slices", code: 0)
            
            self.performFinish(error: error)
          }
       }
       else
       {
           let error = FortuneWheelError.init(message: "no Slices", code: 0)
           
           self.performFinish(error: error)
       }
    }
    
    @objc func startAction(sender: UIButton) {

        
        self.playButton.isEnabled = false
        
        if let slicesCount = self.slices?.count
        {
           //askes the delegate for index which should be selected. if returned assigned to selectedIndex variable
           if let index = self.delegate?.shouldSelectObject()
           {
              self.selectionIndex = index
           }
           
           //checks if selectionIndex variable is in slices array bounds.
           if (self.selectionIndex >= 0 && self.selectionIndex < slicesCount )
           {
             
             self.performSelection()
           }
           else
           {
             let error = FortuneWheelError.init(message: "Invalid selection index", code: 0)
             self.performFinish(error: error)
           }
                 
         }
         else
         {
             let error = FortuneWheelError.init(message: "No Slices", code: 0)
             self.performFinish(error: error)
         }
        
        
    }
    
    /*Function which notifies the finish of selection or any errors encountered through delegate.
     For now leave it empty will get to it in a moment*/
    private func performFinish(error : FortuneWheelError? ) {
        
        
          if let error = error
          {
             self.delegate?.finishedSelecting(index: nil, error: error)
          }
          else
          {
             //When the animation is complete transform fixes the view position to selection angle.
             self.wheelView.transform = CGAffineTransform.init(rotationAngle:self.selectionAngle)
             self.delegate?.finishedSelecting(index: self.selectionIndex, error: nil)
          }
          
          if !self.playButton.isEnabled
          {
             self.playButton.isEnabled = true
          }
       
    }
    //This variable stores the selection angle calculated in the perform selection method.which will be used to transform the Wheel view when animation completes
    private var selectionAngle : Radians = 0
   
    func performSelection() {
        var selectionSpinDuration : Double = 1
        
      
        self.selectionAngle = Degree(360).toRadians() - (self.sectorAngle * CGFloat(self.selectionIndex))
        let borderOffset = self.sectorAngle * 0.1
        self.selectionAngle -= Radians.random(in: borderOffset...(self.sectorAngle - borderOffset))
        
        //if selection angle is negative its changed to positive. negative value spins wheel in reverse direction
        if self.selectionAngle < 0
        {
           self.selectionAngle = Degree(360).toRadians() + self.selectionAngle
           selectionSpinDuration += 0.5
        }
            
        var delay : Double = 0
        
        //Rotates view Fast which simulates spin of the wheel
        let fastSpin = CABasicAnimation.init(keyPath: "transform.rotation")
        fastSpin.fromValue = NSNumber.init(floatLiteral: 0)
        fastSpin.toValue = NSNumber.init(floatLiteral: .pi * 2)
        fastSpin.duration = 0.7
        fastSpin.repeatCount = 3
        fastSpin.beginTime = CACurrentMediaTime() + delay
        delay += Double(fastSpin.duration) * Double(fastSpin.repeatCount)
        
        //Slows down the spin a bit to indicate stopping.starts immediately after fast spin is completed.
        let slowSpin = CABasicAnimation.init(keyPath: "transform.rotation")
        slowSpin.fromValue = NSNumber.init(floatLiteral: 0)
        slowSpin.toValue = NSNumber.init(floatLiteral: .pi * 2)
        slowSpin.isCumulative = true
        slowSpin.beginTime = CACurrentMediaTime() + delay
        slowSpin.repeatCount = 1
        slowSpin.duration = 1.5
        delay += Double(slowSpin.duration) * Double(slowSpin.repeatCount)
            
        //Rotates wheel to the slice which should be selected.Starts immediately after slow spin.
        let selectionSpin = CABasicAnimation.init(keyPath: "transform.rotation")
        selectionSpin.delegate = self
        selectionSpin.fromValue = NSNumber.init(floatLiteral: 0)
        selectionSpin.toValue = NSNumber.init(floatLiteral: Double(self.selectionAngle))
        selectionSpin.duration = selectionSpinDuration
        selectionSpin.beginTime = CACurrentMediaTime() + delay
        selectionSpin.isCumulative = true
        selectionSpin.repeatCount = 1
        selectionSpin.isRemovedOnCompletion = false
        selectionSpin.fillMode = .forwards
        
        //Animation is added to layer.
        self.wheelView.layer.add(fastSpin, forKey: "fastAnimation")
        self.wheelView.layer.add(slowSpin, forKey: "SlowAnimation")
        self.wheelView.layer.add(selectionSpin, forKey: "SelectionAnimation")
            
    }
   
    
    /**Adds selection Indicators*/
    private func addIndicator(){
      /**Calculating the position of the indicator such that half overlaps with the view and the rest if outsice of the view and
      locating indicator at the right side center of the wheel. i.e., at 0 degrees.*/
      let position = CGPoint.init(x: self.frame.width - self.indicatorSize.width, y: self.bounds.height/2 - self.indicatorSize.height/2)
      
      self.indicator.frame = CGRect.init(origin: position, size: self.indicatorSize)
      self.indicator.image = UIImage.init(named: "pointer")!
      if self.indicator.superview == nil
       {
          self.addSubview(self.indicator)
       }
            
     }
    
    /**Adds spin or start game button to the view*/
    private func addStartBttn()
    {
       let size = CGSize.init(width: self.bounds.width * 0.15, height: self.bounds.height * 0.15)
       let point = CGPoint.init(x:  self.frame.width/2 - size.width/2, y: self.frame.height/2 - size.height/2)
       self.playButton.setTitle("Play", for: .normal)
       self.playButton.frame = CGRect.init(origin: point, size: size)
            
       //WE will add the StartAction method later on
       self.playButton.addTarget(self, action: #selector(startAction(sender:)), for: .touchUpInside)
       self.playButton.layer.cornerRadius = self.playButton.frame.height/2
       self.playButton.clipsToBounds = true
       self.playButton.backgroundColor = .gray
       self.playButton.layer.borderWidth = 0.5
       self.playButton.layer.borderColor = UIColor.white.cgColor
       self.addSubview(self.playButton)
    }

  
}


extension FortuneWheel : CAAnimationDelegate
{
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        if flag
        {
            self.performFinish(error: nil)
        }
        else
        {
            let error = FortuneWheelError.init(message: "Error perforing selection", code: 0)
            self.performFinish(error: error)
        }
        
    }

}
