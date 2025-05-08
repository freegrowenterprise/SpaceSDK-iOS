//
//  File.swift
//  GrowSpaceSDK
//
//  Created by min gwan choi on 5/2/25.
//

import Foundation

public struct UWBRangeResult: Codable {
    public let deviceName: String
    public let distance: Float
    public let direction: [Float]
    public let azimuth: Int
    public let elevation: Int
}
