//
//  Zoomer.swift
//  AVMultiCamPiP
//
//  Created by James on 2020/9/9.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import AVFoundation
import Photos
import Vision

extension ViewController {
    
    public func performVisionRequest(pixelBuffer: CVPixelBuffer) {
        guard self.autoZoomSwitch.isOn else {
            return
        }
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [
            CIDetectorAccuracy: CIDetectorAccuracyHigh,
            CIDetectorEyeBlink: true,
            CIDetectorSmile: true
        ])
        let faces = faceDetector!.features(in: CIImage(cvPixelBuffer: pixelBuffer), options: [
            CIDetectorAccuracy: CIDetectorAccuracyHigh,
            CIDetectorEyeBlink: true,
            CIDetectorSmile: true
        ])
        let face = faces.max(by: {
            obj1, obj2 in return obj1.bounds.size.width * obj1.bounds.size.height < obj2.bounds.size.width * obj2.bounds.size.height
        })
        if let face = face as? CIFaceFeature {
            let size = face.bounds.size.width * face.bounds.size.height * 3.7e-7;
            // MARK: Eye blink to capture part
            let closeVal: Float = face.leftEyeClosed && face.rightEyeClosed ? 1 : 0
            if eyeBlinkDetector.detect(closeVal) {
                capture()
            }
//            if face.hasSmile {
//                let oldSmile = accumulatedSmile
//                accumulatedSmile = lerp(momentum, lower: 1, upper: accumulatedSmile)
//                if oldSmile < smileThreshold && accumulatedSmile >= smileThreshold { // detect positive edge
//                    capture()
//                }
//            } else {
//                accumulatedSmile = lerp(momentum, lower: 0, upper: accumulatedSmile)
//            }
            // MARK: Auto zooming part
            let distance = 1 / size
            currentDistance = distance
            
            // calibrated distance should range from 1 to 7
            let calDist = Float(calibrationFactor * distance)
            
            let newZoom = lerp(clamp((calDist - 1.0) / 6.0), lower: minZoom, upper: maxZoom)
            accumulatedZoom = lerp(momentum, lower: newZoom, upper: accumulatedZoom)
            
            DispatchQueue.main.sync {  // all GUI controll should be put here
                self.zoom = accumulatedZoom
                self.distView.text! = String(format: "di: %.2f", distance)
                self.calDistView.text! = String(format: "cd: %.1f", calDist)
                if face.leftEyeClosed && face.rightEyeClosed {
                    self.debugTextView.text! = "Both eyes closed!"
                } else if !face.leftEyeClosed && !face.rightEyeClosed {
                    self.debugTextView.text! = "Both eyes open!"
                } else {
                    self.debugTextView.text! = "One eye closed!"
                }
            }
        }
        else {
            DispatchQueue.main.sync {
                self.distView.text! = "No face"
                self.calDistView.text! = ""
                self.currentDistance = nil
                return
            }
        }
    }
}
