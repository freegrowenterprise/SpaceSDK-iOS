//
//  TagLocationResult.swift
//  GrowSpaceSDK
//
//  Created by min gwan choi on 5/8/25.
//

import Foundation

import GrowSpacePrivateSDK

public struct TagLocationResult {
    public let x: Double
    public let y: Double
    
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    
    public init(from privateLocation: GrowSpacePrivateSDK.TagLocation) {
        self.init(
            x: privateLocation.x,
            y: privateLocation.y
        )
    }
}
