//
//  DistanceCalc.h
//  AVMultiCamPiP
//
//  Created by James on 2019/12/15.
//  Copyright © 2019 Apple. All rights reserved.
//

#ifndef DistanceCalc_h
#define DistanceCalc_h

#import <CoreVideo/CoreVideo.h>

@interface DistanceCalc : NSObject

+ (float) calcDistanceForDepthBuffer:(CVPixelBufferRef)depthBuffer
                            minDepth:(float)minDepth
                            maxDepth:(float)maxDepth;

@end

#endif /* DistanceCalc_h */
