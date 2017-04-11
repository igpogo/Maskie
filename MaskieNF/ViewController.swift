//
//  ViewController.swift
//  Maskie
//
//  Created by Ignacio Porris Gomez on 3/20/17.
//  Copyright © 2017 Ignacio Porris Gomez. All rights reserved.
//

import UIKit
import FaceTracker

let faceTrackerSegue = "FaceTrackerContainer"
let maskCellIdentifier = "MaskCellIdentifier"

enum CameraState{
    case frontCamera, backCamera
    
}

class ViewController: UIViewController, FaceTrackerViewControllerDelegate , UICollectionViewDelegate,UICollectionViewDataSource, UIImagePickerControllerDelegate{

    var faceTrackerViewController: FaceTrackerViewController? // the framework that detect the face and fetures in the image
    
    var maskArray : [MaskType]! // the array that holds the mask object
    
    var maskShowingArray : [ImageMaskType:Bool]! // dictionary that holds the state of the application
    
    var cameraUsing : CameraState! // camera back or front
    
    @IBOutlet weak var maskView: UIView! // view that holds the mask view
    
    @IBOutlet weak var shareButton: UIButton! // button to share the current image

    @IBOutlet weak var containerFaceTracker: UIView! // container controller for the view of the camera source by FaceTracker
    
    var mask : Masks! // mask object with the face points
    
    @IBOutlet var maskCollectionContainerView: UIView!
    @IBOutlet weak var maskCollectionView: UICollectionView!
    
    var maskCollectionContainerViewIsHide : Bool!
    
    @IBOutlet weak var maskCollectionButton: UIButton!
    @IBOutlet weak var swapCameraButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var constrainPositionHide : NSLayoutConstraint!
    var constrainPositionShown : NSLayoutConstraint!
    
    var pListHelper : PlistHelper! // class to get the saving state of the application
    
//MARK: -
//MARK: - Loading View
    
    
       
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.pListHelper = PlistHelper.sharedInstance
        
        self.maskShowingArray = pListHelper.maskShowingArray
        
        
        self.cameraUsing = CameraState.frontCamera
        
        maskCollectionButton.imageView?.image = self.drawButtonUp(maskCollectionButton.frame.size)
        print(maskCollectionContainerView)
        
        self.maskCollectionView.delegate = self
        self.maskCollectionView.dataSource = self
        
        print(maskCollectionButton)
        print("here")
        print(swapCameraButton)
        
        maskCollectionContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(maskCollectionContainerView)
        
        let leftContraint = maskCollectionContainerView.leftAnchor.constraint(equalTo: maskCollectionButton.rightAnchor)
        
        let constraintToEdge = maskCollectionContainerView.rightAnchor.constraint(equalTo: shareButton.leftAnchor)
        
        let constraintsize = maskCollectionContainerView.heightAnchor.constraint(equalTo: maskCollectionButton.heightAnchor)
        
        let constrainttoBottom = maskCollectionContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        
        NSLayoutConstraint.activate([leftContraint,constraintToEdge,constraintsize,constrainttoBottom])
        view.layoutIfNeeded()
        maskCollectionContainerView.transform = CGAffineTransform(translationX: 0, y: maskCollectionButton.frame.size.height)
        maskCollectionContainerViewIsHide = true
        
        
        
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        faceTrackerViewController!.startTracking { () -> Void in
            self.activityIndicator.stopAnimating()
        }
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == faceTrackerSegue {
            faceTrackerViewController = segue.destination as? FaceTrackerViewController
            faceTrackerViewController!.delegate = self
        }
    }
    
// MARK: -
// MARK: - swap camera view
    @IBAction func swapCameraTouched(_ sender: Any) {
        
        self.faceTrackerViewController!.swapCamera()
        
        var cameraImage = UIImage.init(named: "frontCamera")
        
        
        if cameraUsing == CameraState.frontCamera{
            cameraImage = UIImage.init(named: "backCamera")
            cameraUsing = CameraState.backCamera
        }else{
            cameraUsing = CameraState.frontCamera
        }
        UIView.animate(withDuration: 0.4) { 
            self.swapCameraButton.setImage(cameraImage, for: UIControlState.normal)
        }
        
        
        
    }

// MARK: -
// MARK: - Face tracker update
    
    func recievedFrame(image : UIImage, withPoints:FacePoints?){
        print(image)
        
    }

    
    func faceTrackerDidUpdate(_ points: FacePoints?) {
        
        
        if let points = points{
            
            
        
            if self.maskArray == nil{
                let imageMaskTypeArray = ImageMaskType.eye.array()
                self.maskArray = [MaskType]()
                for imageMaskType in imageMaskTypeArray{
                    self.maskArray.append(MaskType(type: imageMaskType))
                    
                }
            }
            
//            for maskType in self.maskArray{
//                
//                maskType.viewUpdateWith(points)
//            }
            
            self.drawPoints(points)
            
        }else{
            if mask != nil{
                self.hidePoints(true)
            }
            if maskArray != nil{
                self.hidePoints(true)
            }
        }
    }
    
    func reorderingMasks(){
        var maskTypeDict = [Int:ImageMaskType]()

        for view in maskView.subviews{
            
            for maskComp in maskArray{
                if maskComp.mask.view == view {
                    if view.accessibilityHint == maskComp.type.rawValue{
                        maskTypeDict[maskComp.type.position()] = maskComp.type
                    }
                }
            }
        }
        // rearrange 
        let positionArray = maskTypeDict.keys
        let sortedPositionArray = positionArray.sorted { (v1, v2) -> Bool in
            return v1 < v2
        }
        
        var index = 0
            for pos in sortedPositionArray{
                var currentIndex = 0
                for view in maskView.subviews{
                    if maskTypeDict[pos]?.rawValue == view.accessibilityHint{
                        maskView.exchangeSubview(at: currentIndex, withSubviewAt: index)
                    }
                    currentIndex = currentIndex + 1
                }
                index =  index + 1
            }
        
        
    }
    
    func drawPoints(_ points:FacePoints){

        if maskArray != nil{
            
            for  maskType in maskArray{
                
                if maskShowingArray[maskType.type]!{
                    
                    maskType.viewUpdateWith(points)
                    
                    if maskType.mask.view != nil{
                        
                        if maskType.mask.view.superview == nil{
                            maskType.mask.view.accessibilityHint = maskType.type.rawValue
                            maskView.addSubview(maskType.mask.view)//, at: maskType.type.position())
                        }else{
                            
                            reorderingMasks()
                        }

                    }
                }
                
            }
            
        }
        
//        if mask.viewPoint != nil{
//            for pointView in mask.viewPoint{
//                
//                if pointView.view.superview == nil{
//                    
//                    self.view.insertSubview(pointView.view, aboveSubview: containerFaceTracker)
//                    
//                }
//                
//            }
//            
//        }
        
        hidePoints(false)
        
    }
    
    
    
    
    func hidePoints(_ hide : Bool){

//        if mask.viewPoint != nil{
//            for pointView in mask.viewPoint{
//                
//                pointView.view.isHidden = hide
//                
//            }
//        }
//        
        if maskArray != nil{
            
            for  maskType in maskArray{
                
                if maskType.mask.view != nil{
                        
                    maskType.mask.view.isHidden = hide == false ? !maskShowingArray[maskType.type]! : hide
                    
                }
                
            }
            
        }
        
    }
    
// MARK : - touch on the screen -> image taken
    
    @IBAction func shareImage(_ sender: UIButton) {
        
        let image = self.takeCurrentImage()
        
        let share = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        self.present(share, animated: true, completion: nil)
    }
    
    func takeCurrentImage()-> UIImage{
        let viewComposing = UIView(frame: self.view.bounds)
        
        
        UIGraphicsBeginImageContext(viewComposing.bounds.size)
        let context = UIGraphicsGetCurrentContext()
        faceTrackerViewController!.view.layer.render(in: context!)
        maskView.layer.render(in: context!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return image!
    }
    
    @IBAction func takeImage(_ sender: UITapGestureRecognizer) {
        
        // save image to documents
        if sender.view == maskView!{
        
        let image = self.takeCurrentImage()
        
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        
    }
    
    
    func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {

            let flashView = UIView(frame: self.view.bounds)
            flashView.backgroundColor = UIColor.white
            flashView.alpha = 0.0
            self.view.insertSubview(flashView, aboveSubview: maskView!)
            UIView.animate(withDuration: 0.3, animations: { 
                
                flashView.alpha = 0.8
            }, completion: { (complete) in
                UIView.animate(withDuration: 0.2, animations: { 
                    flashView.alpha = 0.0
                }, completion: { (complete2) in
                    flashView.removeFromSuperview()
                })
            })
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
    }
    
// MARK: - collectionView
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ImageMaskType.antler.array().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: maskCellIdentifier, for: indexPath) as? MaskCollectionCell

        cell!.imageView.image = UIImage(named: ImageMaskType.antler.array()[indexPath.row].rawValue)
        let selectedBackground = UIView(frame:cell!.bounds)
        selectedBackground.backgroundColor = UIColor.darkGray
        cell!.selectedBackgroundView = selectedBackground
        
        let nonSelectedBackground = UIView(frame:cell!.bounds)
        nonSelectedBackground.backgroundColor = UIColor.lightGray
        cell!.backgroundView = nonSelectedBackground
        
        cell!.isHighlighted = maskShowingArray[ImageMaskType.antler.array()[indexPath.row]]!
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? MaskCollectionCell

        
        if cell != nil{
            cell!.isHighlighted = !maskShowingArray[ImageMaskType.antler.array()[indexPath.row]]!
            maskShowingArray[ImageMaskType.antler.array()[indexPath.row]] = !maskShowingArray[ImageMaskType.antler.array()[indexPath.row]]!
            collectionView.reloadData()
            
            if pListHelper.writingState(){
                print("success saving state")
            }else{
                print("something went wrong saving state")
            }
            
        }
    }

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    // MARK: - Button
    
    func drawButtonUp(_ size:CGSize) -> UIImage?{
        
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.clear(CGRect(origin: CGPoint(x:0,y:0), size: size))
        
        context?.strokeLineSegments(between: [CGPoint(x:size.width/2,y:size.height*3/4),CGPoint(x:0,y:0),CGPoint(x:size.width,y:0)])
        context?.setStrokeColor (UIColor.lightGray.cgColor)
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(max(size.width/10,2))
        
        let arrow = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return arrow
        
        
    }
    
    
    @IBAction func maskCollectionButtonTouched(_ sender: UIButton) {
        
        var rotate : Double = M_PI

        var transform = CGAffineTransform(translationX: 0, y: 0)
        // to hide

        if !maskCollectionContainerViewIsHide!{
            
            transform = CGAffineTransform(translationX: 0, y: maskCollectionButton.frame.size.height)
            rotate = 0.0
        }
        
        //maskCollectionButton.imageView?.transform = CGAffineTransform.identity
        
        maskCollectionContainerViewIsHide = !maskCollectionContainerViewIsHide!
        
        UIView.animate(withDuration: 0.4, animations: {
            self.maskCollectionContainerView.transform = transform
            self.maskCollectionButton.imageView?.transform = CGAffineTransform.init(rotationAngle: CGFloat(rotate))
            
        })
        
    }
}




