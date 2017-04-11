//
//  extensionFacePoints.swift
//  Maskie
//
//  Created by Ignacio Porris Gomez on 3/30/17.
//  Copyright © 2017 Ignacio Porris Gomez. All rights reserved.
//

import Foundation
import UIKit
import FaceTracker

extension FacePoints{
    
    
    func midLeftEye() -> CGPoint{
        
        let leftEyeLeft = self.leftEye.first!
        let leftEyeRight = self.leftEye[5]
        
        return leftEyeLeft.midPointTo(leftEyeRight)
    }
    
    func midRightEye() -> CGPoint{
        let rightEyeLeft = self.rightEye.first!
        let rightEyeRight = self.rightEye[5]
        
        return rightEyeLeft.midPointTo(rightEyeRight)
    }
    
    func midEyes() -> CGPoint{
        let midLeft = self.midLeftEye()
        let midRight = self.midRightEye()
        
        return midLeft.midPointTo(midRight)
    }
    
    func midNose() -> CGPoint{
        let leftNoseBase = self.nose[1]
        let rightNoseBase = self.nose[5]
        return leftNoseBase.midPointTo(rightNoseBase)
        
    }
    
    func midMouth() -> CGPoint{
        let leftMouthOuter = self.outerMouth[0]
        let rightMouthOuter = self.outerMouth[6]
        let leftMouthInner = self.innerMouth[0]
        let rightMouthInner = self.innerMouth[4]
        
        let midOuter = leftMouthOuter.midPointTo(rightMouthOuter)
        let midInner = leftMouthInner.midPointTo(rightMouthInner)
        
        return midOuter.midPointTo(midInner)
    }
    
    func eyeLeftOpen() -> Bool{
        let size = self.sizeEyeLeft()
        if size.height < size.width/3.8{
            return false
        }
        return true
        
    }
    func eyeRightOpen() -> Bool{
        
        let size = self.sizeEyeRight()
        if size.height < size.width/3.8{
            return false
        }
        return true
        
    }
    
    func mouthOpen() -> Bool{
        
        if self.distanceMouthInnerOpenning() < 6{
            return false
        }
        return true
        
    }
    
    func tiltFace()-> CGFloat{
        
        let leftEye = self.leftEye[0]
        let rightEye = self.rightEye[5]
        
        return CGFloat(atan2(-leftEye.y+rightEye.y, -leftEye.x+rightEye.x))
        
    }
    
    func distanceEyeOutter() -> CGFloat{
        
        let leftEye = self.leftEye[0]
        let rightEye = self.rightEye[5]
        
        return leftEye.distanceTo(rightEye)
        
    }
    
    func distanceEyeInner() -> CGFloat{
        let leftEye = self.leftEye[5]
        let rightEye = self.rightEye[0]
        
        return leftEye.distanceTo(rightEye)
    }
    
    func distanceMouthOuter() -> CGFloat{
        let leftMouth = self.outerMouth[0]
        let rightMouth = self.outerMouth[6]
        
        return leftMouth.distanceTo(rightMouth)
    }
    
    func distanceMouthInner() -> CGFloat{
        let leftMouth = self.innerMouth[0]
        let rightMouth = self.innerMouth[4]
        
        return leftMouth.distanceTo(rightMouth)
    }
    func distanceMouthInnerOpenning() -> CGFloat{
        let upMouth = self.innerMouth[2]
        let downMouth = self.innerMouth[6]
        
        return upMouth.distanceTo(downMouth)
    }
    
    func minMouthOpening() -> CGFloat{
        
        return min(distanceMouthInner(),distanceMouthInnerOpenning())
    }
    
    func maxMouthOpening() -> CGFloat{
        
        return max(distanceMouthInner(),distanceMouthInnerOpenning())
    }
    
    func sizeEyeLeft() -> CGSize{
        let leftEyeLeft = self.leftEye[0]
        let leftEyeRight = self.leftEye[5]
        var leftEyeUp = CGPoint(x:0,y:0)
        var leftEyeDown = CGPoint(x:0,y:10000)
        
        for point in self.leftEye.enumerated(){
            if leftEyeUp.y < point.element.y{
                leftEyeUp = point.element
            }
            
            if leftEyeDown.y > point.element.y{
                leftEyeDown = point.element
            }
        }
        
        return CGSize(width:leftEyeRight.distanceTo(leftEyeLeft), height: leftEyeUp.distanceTo(leftEyeDown))
    }
    
    func sizeEyeRight() -> CGSize{
        let rightEyeLeft = self.rightEye[0]
        let rightEyeRight = self.rightEye[5]
        var rightEyeUp = CGPoint(x:0,y:0)
        var rightEyeDown = CGPoint(x:0,y:10000)
        
        for point in self.leftEye.enumerated(){
            if rightEyeUp.y < point.element.y{
                rightEyeUp = point.element
            }
            
            if rightEyeDown.y > point.element.y{
                rightEyeDown = point.element
            }
        }
        
        return CGSize(width:rightEyeRight.distanceTo(rightEyeLeft), height: rightEyeUp.distanceTo(rightEyeDown))
    }
    
    
}
