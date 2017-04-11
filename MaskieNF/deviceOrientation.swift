//
//  deviceOrientation.swift
//  Maskie
//
//  Created by Ignacio Porris Gomez on 4/5/17.
//  Copyright © 2017 Ignacio Porris Gomez. All rights reserved.
//

import Foundation
import CoreMotion

let kDeviceMotionUpdateInterval = 0.05

class DeviceOrientation{
    
    var motionManager: CMMotionManager
    
    var roll = 0.0
    var pitch = 0.0
    var yaw = 0.0
    var collectingData = false
    
    init(inQueu: OperationQueue) {
        self.motionManager = CMMotionManager()
        self.motionManager.deviceMotionUpdateInterval = kDeviceMotionUpdateInterval
        
        
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.01
            motionManager.startDeviceMotionUpdates(to: inQueu) {
                [weak self] (data: CMDeviceMotion?, error: Error?) in
                if let gravity = data?.gravity {
                    self?.roll = atan2(gravity.x, gravity.y) - M_PI
                }
            }
        }
        
    }
    func start(){
        motionManager.startDeviceMotionUpdates()
        collectingData = true
    }
    
    func stop(){
        motionManager.stopDeviceMotionUpdates()
        collectingData = false
    }
    
    
    
    
}
