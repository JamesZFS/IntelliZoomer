//
//  RingQueue.swift
//  AVMultiCamPiP
//
//  Created by James on 2019/12/16.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation

class RingQueue<T: AdditiveArithmetic> {
    private var elem: [T]
    private var curIdx: Int
    
    public init(repeating: T, capacity: Int) {
        guard capacity > 0 else {
            exit(1)
        }
        elem = .init(repeating: repeating, count: capacity)
        curIdx = 0  // points to the first elem
    }
    
    public func push(_ e: T) {
        elem[curIdx] = e
        curIdx = (curIdx + 1) % elem.count
    }
    
    public var curElem: T {
        get {
            return elem[curIdx]
        }
        set {
            elem[curIdx] = newValue
        }
    }
    
    public var sum: T {
        get {
            var res: T = .zero
            for e in elem {
                res += e
            }
            return res
        }
    }
    
    public var capacity: Int {
        get { return elem.count }
    }
}
