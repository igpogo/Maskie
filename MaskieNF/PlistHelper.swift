//
//  PlistHelper.swift
//  Maskie
//
//  Created by Ignacio Porris Gomez on 4/6/17.
//  Copyright © 2017 Ignacio Porris Gomez. All rights reserved.
//

import Foundation

class PlistHelper{

    var maskShowingArray : [ImageMaskType:Bool]!

    
    static let sharedInstance : PlistHelper = PlistHelper()
    
    private init(){
        self.maskShowingArray = [ImageMaskType:Bool]()
        self.readingState()
    }
    
    func readingState(){
        let path : String
        if self.checkPlistInDocFolder(){
            path = self.plistPathInDoc()
        }else{
            let pathBundle = Bundle.main.path(forResource: "latestState", ofType: "plist")
            if pathBundle == nil{
                return
            }else{
                path = pathBundle!
            }
            
        }
        
        
        let dicState = NSDictionary.init(contentsOfFile: path) as? [String:Bool]
        if let dicState = dicState {
            for ele in dicState{
                
                let imageMaskType = imageMaskTypefromRawValue(ele.key)
                
                self.maskShowingArray[imageMaskType] = ele.value
                
                
            }
        }
        
        for maskEle in ImageMaskType.antler.array(){
            if self.maskShowingArray[maskEle] == nil{
                self.maskShowingArray[maskEle] = false
            }
            
        }
        
    }

    func checkPlistInDocFolder()-> Bool{
        
        let plistPath =  plistPathInDoc()
        return FileManager.default.fileExists(atPath: plistPath)
        
    }

    func generatePlistFileInFolderDoc() -> Bool{
        
        let plistPath =  plistPathInDoc()
        if FileManager.default.fileExists(atPath: plistPath){
            return true
        }else{
            return FileManager.default.createFile(atPath: plistPath, contents: nil, attributes: nil)
        }
    }

    func plistPathInDoc() -> String{
        let docFolderPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docFolder = docFolderPath[0]
        return "\(docFolder)/latestState.plist"
    }

    func generatePlistObjectToSave() -> NSDictionary{
        
        
        var dicState = NSMutableDictionary.init()
        for ele in maskShowingArray{
            dicState[ele.key.rawValue] = NSNumber(value:ele.value)
        }
        return dicState as NSDictionary
        
    }

    func writingState() -> Bool{
        if !self.checkPlistInDocFolder(){
            if !self.generatePlistFileInFolderDoc(){
                print("counldn't generate file \(self.plistPathInDoc())")
                return false
            }
        }
        
        let dict = self.generatePlistObjectToSave()
        let path = self.plistPathInDoc()
        
        return dict.write(toFile: path, atomically: true)
        
        
    }
    
}
