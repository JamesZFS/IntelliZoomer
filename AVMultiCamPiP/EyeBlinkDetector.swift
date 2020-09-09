//
//  EyeBlinkDetector.swift
//  AVMultiCamPiP
//
//  Created by James on 2020/9/9.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation

// This class detects multiple consecutive eye blink events
class EyeBlinkDetector
{
    private let triggerTimes: Int = 2
    private let consecutiveInterval: TimeInterval = .init(1.0)  // in seconds
    private let momentum: Float = 0.9
    private let threshold: Float = 0.5
    private var accumulated: Float = 0  // accumulated close value
    private var curCount: Int = 0  // when curCount reaches triggerTimes, a trigger signal is emited
    private var tic: Date!  // time stamp of the previous eye close detection
    
    private var eyeClosed: Bool = false
    
    // Input a value describing how much eye is closed, return if we should trigger
    public func detect(_ newVal: Float) -> Bool
    {
        let oldVal = accumulated
        accumulated = lerp(momentum, lower: newVal, upper: accumulated)
        if oldVal < threshold && accumulated >= threshold {
            // Detected eye close event
            return onCloseEye()
        } else if oldVal >= threshold && accumulated < threshold {
            // Detected eye open event
            return onOpenEye()
        }
        return false
    }
    
    private func onCloseEye() -> Bool
    {
        print("onCloseEye")
        eyeClosed = true
        return false
    }
    
    private func onOpenEye() -> Bool
    {
        guard eyeClosed else {
            print("error in onOpenEye")
            return false
        }
        print("onOpenEye")
        eyeClosed = false
        let prevTic = tic
        tic = Date()
        if curCount > 0 {
            // Check if two blinkings are consecutive
            let elapse = prevTic!.distance(to: tic)
            print("Elapse: \(elapse)")
            guard elapse <= consecutiveInterval else {
                print("Eye blink chain broke")
                curCount = 1
                return false
            }
        }
        curCount += 1
        print("\(curCount) / \(triggerTimes)")
        if curCount == triggerTimes {
            curCount = 0
            print("Trigger!")
            return true
        } else {
            return false
        }
    }
}
