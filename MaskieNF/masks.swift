//
//  masks.swift
//  Maskie
//
//  Created by Ignacio Porris Gomez on 3/22/17.
//  Copyright © 2017 Ignacio Porris Gomez. All rights reserved.
//

import UIKit
import FaceTracker


class Masks{
    
    var viewPoint : [ViewPointTracker]!
    
    var hatView = UIImageView()
    
    init(numberPoints : FacePoints) {
        
        var dict : [ViewPointTracker] = [ViewPointTracker]()
        
        let innerMouthPoints = numberPoints.innerMouth
        dict.append(contentsOf:viewPointFor(points: PointsFaceTracker(points: innerMouthPoints, type: .innerMouth), type:.innerMouth))
        
        let outerMouthPoints = numberPoints.outerMouth
        dict.append(contentsOf:viewPointFor(points: PointsFaceTracker(points: outerMouthPoints, type: .outerMouth), type:.outerMouth))
        
        let leftBrowPoints = numberPoints.leftBrow
        dict.append(contentsOf:viewPointFor(points: PointsFaceTracker(points: leftBrowPoints, type: .leftBrow), type:.leftBrow))
        
        let rightBrowPoints = numberPoints.rightBrow
        dict.append(contentsOf:viewPointFor(points: PointsFaceTracker(points: rightBrowPoints, type: .rightBrow), type:.rightBrow))
        
        let leftEyePooints = numberPoints.leftEye
        dict.append(contentsOf:viewPointFor(points: PointsFaceTracker(points: leftEyePooints, type: .leftEye), type:.leftEye))
        
        let rightEyePoints = numberPoints.rightEye
        dict.append(contentsOf:viewPointFor(points: PointsFaceTracker(points: rightEyePoints, type: .rightEye), type:.rightEye))
        
        let nosePoints = numberPoints.nose
        dict.append(contentsOf:viewPointFor(points: PointsFaceTracker(points: nosePoints, type: .nose), type:.nose))
        
        
        self.viewPoint = dict
    }
    
    func refreshFacePoints(numberPoints : FacePoints){
        
        for pointView in viewPoint{
            
            let number =  pointView.number

            let positionsArray : [CGPoint]
            
            switch pointView.type {
            case .innerMouth:
                positionsArray = numberPoints.innerMouth
            case .outerMouth:
                positionsArray = numberPoints.outerMouth

            case .leftBrow:
                positionsArray = numberPoints.leftBrow
            case .rightBrow:
                positionsArray = numberPoints.rightBrow
                
            case .leftEye:
                positionsArray = numberPoints.leftEye
            case .rightEye:
                positionsArray = numberPoints.rightEye
                
            case .nose:
                positionsArray = numberPoints.nose
            
            }
            
            pointView.newPosition(point:positionsArray[number])
            
        }
    }
    
    func viewPointFor(points :PointsFaceTracker, type: FaceTrackerPointType) -> [ViewPointTracker]{
        
        let type = points.type
        var number : Int = 0
        
        var pointTracker = [ViewPointTracker]()
        
        for point in points.points{
            
            let viewPointNew = ViewPointTracker(type: type, number: number)
            
            viewPointNew.newPosition(point: point)
            
            pointTracker.append( viewPointNew)
            
            number = number + 1
        }
        
        return pointTracker
        
    }
    
}

class ViewPointTracker{
    var view : UIView
    var type : FaceTrackerPointType
    var number : Int
    
    init(type: FaceTrackerPointType, number : Int) {
        self.view = UIView()
        self.type = type
        self.view.backgroundColor = type.colorForType()
        self.number = number
    }
    
    func newPosition(point : CGPoint){
        view.frame = CGRect(x: point.x - self.view.frame.size.width * 0.01/2, y: point.y - self.view.frame.size.width * 0.01/2, width: max(self.view.frame.size.width * 0.01,3),height: max(self.view.frame.size.width * 0.01,3))
        
    }
    
}


enum ImageMaskType : String{
    
    case sunglasses = "sunglasses"
    case monocle = "monocle"
    case eye = "eye"
    case antler = "antler"
    case beard = "beard"
    case rastaDark = "rastaDark"
    
    func array() -> [ImageMaskType]{
        return [  .monocle,.antler, .rastaDark, .beard,.sunglasses,.eye]
    }
    
    func position() -> Int{
        switch self {
        case .eye:
            return 0
        case .sunglasses:
            return 1
        case .beard:
            return 2
        case .rastaDark:
            return 3
        case .antler:
            return 4
        case .monocle:
            return 5
        default:
            return 0
        }
    }
    
}

func imageMaskTypefromRawValue(_ rV :String) -> ImageMaskType{
    switch rV {
    case ImageMaskType.sunglasses.rawValue:
        return .sunglasses
    case ImageMaskType.monocle.rawValue:
        return .monocle
    case ImageMaskType.eye.rawValue:
        return .eye
    case ImageMaskType.antler.rawValue:
        return .antler
    case ImageMaskType.beard.rawValue:
        return .beard
    case ImageMaskType.rastaDark.rawValue:
        return .rastaDark
    default:
        return .antler
    }
}

struct MaskType {


    var type : ImageMaskType
    var mask : Mask

    private var deviceOrientation : DeviceOrientation!
    
    init(type: ImageMaskType) {
        
        
        self.type = type
        switch type {
        case .eye:
            self.mask = Mask(baseImage: UIImage(named: ImageMaskType.eye.rawValue), anchorPoint: CGPoint(x:0.5,y:0.5))
        case .monocle:
            self.mask = Mask(baseImage: UIImage(named: ImageMaskType.monocle.rawValue), anchorPoint: CGPoint(x:174.0/298.0,y:102.0/176.0))
        case .sunglasses:
            self.mask = Mask(baseImage:UIImage(named: ImageMaskType.sunglasses.rawValue), anchorPoint:CGPoint(x:0.5,y:0.5))
        case .antler:
           self.mask = Mask(baseImage:UIImage(named: ImageMaskType.antler.rawValue), anchorPoint:CGPoint(x:0.5,y:280.0/296.0))
        case .beard:
            self.mask = Mask(baseImage:UIImage(named: ImageMaskType.beard.rawValue), anchorPoint:CGPoint(x:0.5,y:154.0/823.0))
        case .rastaDark:
            self.mask = Mask(baseImage:UIImage(named: ImageMaskType.rastaDark.rawValue), anchorPoint:CGPoint(x:240.0/418.0,y:224.0/647.0))
        default:
            self.mask = Mask(baseImage: UIImage(named: ImageMaskType.eye.rawValue), anchorPoint: CGPoint(x:0.5,y:0.5))
            break
        }
        
        setAnchorPoint(self.mask.anchorPoint, forView: self.mask.view)
    }
    
    func viewUpdateWith(_ points: FacePoints){
        
        let result = self.formulaForMaskType()(points)
        
        let newFrame = CGRect(x:result.0.origin.x, y:result.0.origin.y, width:result.0.size.width, height:result.0.size.height)
        self.mask.view.transform = CGAffineTransform.identity
        
//        print("type:\(self.type.rawValue)\nold frame:\(self.mask.view.frame)\nnew frame:\(newFrame)")
        self.mask.view.frame = newFrame
//        print("set frame:\(self.mask.view.frame)")
        
        
        self.mask.view.transform = CGAffineTransform(rotationAngle: result.1)
//        print("rotated:\(self.mask.view.frame)")
        
        
        // actions
        self.actions(points: points)
        
        
        
    }
    
    func actions(points: FacePoints) {
        
        switch self.type {
        case .sunglasses:
            var drawingStar = false
            var starOrigin = CGPoint(x:50,y:100)
            if !points.eyeLeftOpen() && points.eyeRightOpen(){
                // star in the left corner
                drawingStar = true
            }
            if !points.eyeRightOpen() && points.eyeLeftOpen(){
                // star in the right corner

                drawingStar = true
                starOrigin = CGPoint(x:930,y:100)
                
            }

            if drawingStar{
                let imageStar = UIImage(named: "littleStar")
                let imageLittleStar = UIImageView(image:imageStar!)
                setAnchorPoint(CGPoint(x:0.5,y:0.5), forView: imageLittleStar)

                imageLittleStar.frame = CGRect(x: self.mask.view.frame.size.width*starOrigin.x/self.mask.baseImage!.size.width , y: self.mask.view.frame.size.height*starOrigin.y/self.mask.baseImage!.size.height, width: self.mask.view.frame.size.width*100/self.mask.baseImage!.size.width, height: self.mask.view.frame.size.width*100/self.mask.baseImage!.size.width)
                imageLittleStar.alpha = 0.0
                imageLittleStar.tag = 12345
                
                if self.mask.view.viewWithTag(12345) == nil{
                    print("star drawing animation \(imageLittleStar) \n\(self.mask.view.frame)")
                    self.mask.view.addSubview(imageLittleStar)
                    UIView.animate(withDuration: 0.8, animations: {
                        imageLittleStar.alpha = 0.8
                        imageLittleStar.transform = CGAffineTransform.init(rotationAngle: CGFloat(M_PI))
                    }, completion: { (complete) in
                        imageLittleStar.removeFromSuperview()
                    })
                }
            }
            
            
            
        default:
            break
        }
    }
    
    
    func frameResultFor(centerPoint: CGPoint, sizeView: CGSize) -> CGRect{
        
        
            
            let newPosition = CGPoint(
                x: centerPoint.x - (sizeView.width * (self.mask.anchorPoint.x)),
                y: centerPoint.y - (sizeView.height * (self.mask.anchorPoint.y)))
            
            return CGRect(origin: newPosition, size: sizeView)
            
    }
    
    func compareFrames(result: CGRect, traditional: CGRect, maskType: ImageMaskType){
        print(maskType.rawValue)
        if result.origin == traditional.origin {
            print("same origin for frame")
        }else{
            print("different origin for frame  \(result.origin) =/= \(traditional.origin)) ")
            if result.size.width == result.width{
                print("width  ->  \(result.size.width) =/= \(traditional.size.width)")
            }
            if result.size.height == traditional.height{
                print("height ->  \(result.size.height) =/= \(traditional.size.height)")
            }
        }
        if result.size.width == result.width && result.size.height == traditional.height {
            print("same size for frame")
        }else{
            print("different size for frame  \(result.size) =/= \(traditional.size)")
            if result.size.width == result.width{
                print("width  ->  \(result.size.width) =/= \(traditional.size.width)")
            }
            if result.size.height == traditional.height{
                print("height ->  \(result.size.height) =/= \(traditional.size.height)")
            }
        }
        print("")
    }
   
    func formulaForMaskType() -> ((_ points: FacePoints) -> (CGRect,CGFloat)){
       
        
        switch self.type {
        case .eye:
            return {(_ points: FacePoints) -> (CGRect,CGFloat)  in
                
                let tilt = points.tiltFace()
                
                let sizeEye = points.sizeEyeLeft()
                let widthEye = max(sizeEye.width,sizeEye.height)
                
                if self.mask.baseImage != nil{
                    
                    let heigthEye = widthEye * self.mask.baseImage!.size.height / self.mask.baseImage!.size.width
                    
                    let sizeEye = CGSize(width: widthEye,height:heigthEye)
                    let positionEyeCenter = points.midLeftEye()
                    let positionEye = CGPoint(x:positionEyeCenter.x - (widthEye * self.mask.anchorPoint.x),y: positionEyeCenter.y - (widthEye * self.mask.anchorPoint.y))
                    
                    let widhtResultEye = max(sizeEye.width,sizeEye.height)
                    let sizeResultEye = CGSize(width:widhtResultEye,height:widhtResultEye)
                    let rectFrame =  self.frameResultFor(centerPoint: points.midLeftEye(), sizeView: sizeResultEye)
                    self.compareFrames(result: rectFrame, traditional: CGRect(origin: positionEye, size: sizeEye),maskType: self.type)
                    
                    return (CGRect(origin: positionEye, size: sizeEye),tilt)
                    
                } else{
                    return (CGRect.zero,tilt)
                }
            }
        case .sunglasses:
            return {(_ points: FacePoints) -> (CGRect,CGFloat)  in
                
                let outerEye = points.distanceEyeOutter()
                let tilt = points.tiltFace()
                
                let widthSunglasses = 1.3 * outerEye
                
                if self.mask.baseImage != nil{
                    
                    let heigthSunglasses = widthSunglasses * self.mask.baseImage!.size.height / self.mask.baseImage!.size.width
                    
                    let sizeSunglasses = CGSize(width: widthSunglasses,height:heigthSunglasses)
                    
                    let midEyes = points.midEyes()
                    
                    let sunglassesPosition = CGPoint(
                        x: midEyes.x + (widthSunglasses * (self.mask.anchorPoint.x-1)),
                        y: midEyes.y + (heigthSunglasses * (self.mask.anchorPoint.y-1)))
                    
                    
                    let widhtResult = points.distanceEyeOutter()*1.64
                    let sizeResult = CGSize(width:widhtResult,height:widhtResult * self.mask.baseImage!.size.height / self.mask.baseImage!.size.width)
                    let rectFrame =  self.frameResultFor(centerPoint: points.midEyes(), sizeView: sizeResult)
                    self.compareFrames(result: rectFrame, traditional: CGRect(origin: sunglassesPosition, size: sizeSunglasses),maskType: self.type)
                    
                    return (CGRect(origin: sunglassesPosition, size: sizeSunglasses),tilt)
                    
                } else{
                    return (CGRect.zero,tilt)
                }
            }
        case .monocle:
            return{(_ points: FacePoints) -> (CGRect,CGFloat) in
                
                let tilt = points.tiltFace()
                
                if self.mask.baseImage != nil{
                    
                    let widhtResult = 5.0 * points.distanceEyeOutter()
                    let sizeResult = CGSize(width:widhtResult,height:widhtResult * self.mask.baseImage!.size.height / self.mask.baseImage!.size.width)
                    let rectFrame =  self.frameResultFor(centerPoint: points.midRightEye(), sizeView: sizeResult)
                    
                    return (rectFrame,tilt)//(CGRect(origin: positionMonocle, size: sizeMonocle),tilt)
                } else{
                    return (CGRect.zero,tilt)
                }
            }
        case .antler:
            return{(_ points: FacePoints) -> (CGRect,CGFloat) in
                
                let tilt = points.tiltFace()
                let nose = points.midNose()
                let midEyes = points.midEyes()
                let dist = 1.8 * midEyes.distanceTo(nose)
                let front = CGPoint(x:midEyes.x - dist*cos(CGFloat(M_PI_2) + tilt),y:midEyes.y - dist*sin(CGFloat(M_PI_2) + tilt))
                
                if self.mask.baseImage != nil{
                    
                    let widhtResult = 6 * points.distanceEyeOutter()
                    let sizeResult = CGSize(width:widhtResult, height:widhtResult * self.mask.baseImage!.size.height / self.mask.baseImage!.size.width)
                    let rectFrame =  self.frameResultFor(centerPoint: front, sizeView: sizeResult)
                    
                    return (rectFrame,tilt)
                } else{
                    return (CGRect.zero,tilt)
                }
            }
        case .beard:
            return{(_ points: FacePoints) -> (CGRect,CGFloat) in
                
                
                let tilt = points.tiltFace()
                
                let middleNose = points.midNose()
                
                let middleMouth = points.midMouth()
                
                let middleEye = points.midEyes()
                
                let distanceMouthEye = middleEye.distanceTo(middleMouth) //* 0.96
                
                
                var newPosition = middleNose.midPointTo(middleMouth)
                newPosition.x = middleMouth.x
                newPosition = CGPoint(x: middleEye.x + distanceMouthEye * sin(CGFloat(M_PI) + tilt) ,y: middleEye.y + distanceMouthEye * cos(CGFloat(M_PI) + tilt))
                
                if self.mask.baseImage != nil{
                    let widthBeard =  points.distanceEyeOutter() * 1.46 * (self.mask.baseImage!.size.width/504)
                    let heigthBeard = widthBeard * self.mask.baseImage!.size.height / self.mask.baseImage!.size.width
                    let sizeBeard = CGSize(width: widthBeard,height:heigthBeard)
                    let positionBeard =
                        CGPoint(
                            x: newPosition.x + (widthBeard * (self.mask.anchorPoint.x-1)),
                            y: newPosition.y - (heigthBeard * (self.mask.anchorPoint.y)))//-1)))//-1)))//-1)))//- (heigthBeard * (self.mask.anchorPoint.y-1)))
                    
                    let widhtResult = points.distanceEyeOutter() * 1.46 * (self.mask.baseImage!.size.width/504)
                    let sizeResult = CGSize(width:widhtResult,height:widhtResult * self.mask.baseImage!.size.height / self.mask.baseImage!.size.width)
                    let rectFrame =  self.frameResultFor(centerPoint: points.midMouth().midPointTo(points.midEyes()), sizeView: sizeResult)
                    self.compareFrames(result: rectFrame, traditional: CGRect(origin: positionBeard, size: sizeBeard),maskType: self.type)
                    
                    
                    return (rectFrame, tilt)//(CGRect(origin: positionBeard, size: sizeBeard),tilt)
                } else{
                    return (CGRect.zero,tilt)
                }
            }
        case .rastaDark:
            return{(_ points: FacePoints) -> (CGRect,CGFloat) in
                
                
                let tilt = points.tiltFace()
                
                let middleEye = points.midEyes()
                
                if self.mask.baseImage != nil{
                    
                    let widhtResult = points.distanceEyeOutter() * 2.26
                    let sizeResult = CGSize(width:widhtResult,height:widhtResult * self.mask.baseImage!.size.height / self.mask.baseImage!.size.width)
                    let rectFrame =  self.frameResultFor(centerPoint: middleEye, sizeView: sizeResult)
                    
                    
                    return (rectFrame, tilt)//(CGRect(origin: positionBeard, size: sizeBeard),tilt)
                } else{
                    return (CGRect.zero,tilt)
                }
                
            }
        

        default:
            return {(_ points: FacePoints) -> (CGRect,CGFloat)  in
                
                    return (CGRect.zero,0.0)
            }
        }
    }
}


extension CGPoint{
    
    func midPointTo(_ p2: CGPoint) -> CGPoint {
        
        return CGPoint(x:(self.x + p2.x)/2, y:(self.y + p2.y)/2)
        
        
    }
    
    func distanceTo(_ p2:CGPoint) -> CGFloat{
        return sqrt(pow(self.x - p2.x,2)+pow(self.y - p2.y,2))
    }
    
}

struct Mask{
    
    var baseImage : UIImage?
    var anchorPoint : CGPoint
    var view : UIImageView!
    
    init (baseImage : UIImage?, anchorPoint: CGPoint){
        self.baseImage = baseImage
        self.view = UIImageView()
        self.view.image = baseImage
        self.anchorPoint = anchorPoint
        
    }
    
}

func setAnchorPoint(_ anchorPoint: CGPoint, forView view: UIView) {
    var newPoint = CGPoint(x: view.bounds.size.width * anchorPoint.x, y: view.bounds.size.height * anchorPoint.y)
    var oldPoint = CGPoint(x: view.bounds.size.width * view.layer.anchorPoint.x, y: view.bounds.size.height * view.layer.anchorPoint.y)
    
    newPoint = newPoint.applying(view.transform)
    oldPoint = oldPoint.applying(view.transform)
    
    var position = view.layer.position
    position.x -= oldPoint.x
    position.x += newPoint.x
    
    position.y -= oldPoint.y
    position.y += newPoint.y
    
    view.layer.position = position
    view.layer.anchorPoint = anchorPoint
    
    
}

struct PointsFaceTracker {
    
    var points:[CGPoint]
    var color : UIColor
    var type : FaceTrackerPointType
    
    init(points: [CGPoint], type : FaceTrackerPointType) {
        self.points = points
        self.type = type
        self.color = type.colorForType()
    }
    
}

enum FaceTrackerPointType{
    case outerMouth
    case innerMouth
    case leftBrow
    case rightBrow
    case leftEye
    case rightEye
    case nose
    
    
    func colorForType() -> UIColor{
        switch self {
        case .outerMouth:
            return UIColor.blue
        case .innerMouth:
            return UIColor.lightGray
        case .leftBrow,.rightBrow:
            return UIColor.red
        case .leftEye,.rightEye:
            return UIColor.green
        case .nose:
            return UIColor.yellow
        
        }
    }
    
    
}



