//
//  config.swift
//  AVMultiCamPiP
//
//  Created by James on 2019/12/16.
//  Copyright © 2019 Apple. All rights reserved.
//
//  Global configurations:

let minDist: Float = 0.18  // 18cm
let maxDist: Float = 0.65  // 65cm

let minZoom: Float = 1.0
let maxZoom: Float = 5.0

/// Perform linear interpolation
/// - Parameters:
///   - t: 0 - 1
///   - lower: lower bound
///   - upper: upper bound
func lerp(_ t: Float, lower: Float, upper: Float) -> Float {
    return lower * (1 - t) + upper * t
}
