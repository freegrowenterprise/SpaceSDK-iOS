//
//  RTLSAnchorResult.swift
//  GrowSpaceSDK
//
//  Created by min gwan choi on 5/8/25.
//

import Foundation

import GrowSpacePrivateSDK

public struct RTLSAnchorResult {
    public let id: String
    public let x: Double
    public let y: Double
    public let z: Double
    public let distance: Double

    public init(id: String, x: Double, y: Double, z: Double, distance: Double) {
        self.id = id
        self.x = x
        self.y = y
        self.z = z
        self.distance = distance
    }

    public init(from anchor: GrowSpacePrivateSDK.RTLSAnchor) {
        self.init(
            id: anchor.id,
            x: anchor.x,
            y: anchor.y,
            z: anchor.z,
            distance: anchor.distance
        )
    }
}
