//
//  DistanceCalc.m
//  AVMultiCamPiP
//
//  Created by James on 2019/12/15.
//  Copyright © 2019 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "DistanceCalc.h"

@implementation DistanceCalc

+ (float) calcDistanceForDepthBuffer:(CVPixelBufferRef)depthBuffer
                            minDepth:(float)minDepth
                            maxDepth:(float)maxDepth {
    size_t width = CVPixelBufferGetWidth(depthBuffer);
    size_t height = CVPixelBufferGetHeight(depthBuffer);
    size_t stride = CVPixelBufferGetBytesPerRow(depthBuffer);
    
    CVPixelBufferLockBaseAddress(depthBuffer, kCVPixelBufferLock_ReadOnly);
    const uint8_t* baseAddr = (const uint8_t*)CVPixelBufferGetBaseAddress(depthBuffer);
    float avgDepth = 0;
    size_t count = 0;
    
    const size_t half_w = 3;
    const size_t y_lo = height / 2 - half_w, y_hi = height / 2 + half_w;
    const size_t x_lo = width / 2 - half_w, x_hi = width / 2 + half_w;
    for (size_t y = y_lo; y < y_hi; ++y) {
        const __fp16* data = (const __fp16*)(baseAddr + y * stride) + x_lo;
        for (size_t x = x_lo; x < x_hi; ++x, ++data) {
            __fp16 depth = *data;
            if (!isnan(depth) && depth > minDepth && depth < maxDepth) {
                avgDepth += depth;
                count += 1;
            }
        }
    }
    
    if (count == 0) { // all depth values are beyond our expectation
        const __fp16 mid = *((const __fp16*)(baseAddr + (height / 2) * stride) + (width / 2));
        printf("mid depth: %f \n", mid);
        if (mid < minDepth) {
            avgDepth = minDepth;
        } else if (mid > maxDepth) {
            avgDepth = maxDepth;
        } else { // nan
            avgDepth = (minDepth + maxDepth) / 2;
        }
        avgDepth = 1.0 / mid;
    } else {
        avgDepth /= count;
    }
    
    if (avgDepth > maxDepth) {
        avgDepth = maxDepth;
    } else if (avgDepth < minDepth) {
        avgDepth = minDepth;
    }
    
    printf("avgDepth %f cm\n", 100 * avgDepth);
    CVPixelBufferUnlockBaseAddress(depthBuffer, kCVPixelBufferLock_ReadOnly);
    return avgDepth;
}

@end
