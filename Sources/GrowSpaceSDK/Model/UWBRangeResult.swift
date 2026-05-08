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
    /// AoA 방향 벡터 [x, y, z]. U2 칩 등 direction 미지원 환경에서는 nil.
    public let direction: [Float]?
    /// 방위각(degree). direction 이 nil 이면 nil.
    public let azimuth: Int?
    /// 고도각(degree). direction 이 nil 이면 nil.
    public let elevation: Int?
    /// 현재 디바이스가 direction 측정을 지원하는지. false 면 direction/azimuth/elevation 항상 nil.
    public let isDirectionAvailable: Bool
}
