//
//  UWBCapabilitiesResult.swift
//  GrowSpaceSDK
//

import Foundation

/// 현재 단말의 NearbyInteraction capability 를 나타내는 외부 노출용 모델.
/// U2 칩 (iPhone 14 이상) 환경에서 direction 측정이 안 되는 사실을 호출자가 미리 알 수 있다.
public struct UWBCapabilitiesResult: Codable {
    /// AoA 기반 방향 측정 가능 여부. U2 칩은 false.
    public let supportsDirection: Bool
    /// 단말의 camera assistance capability. SpaceSDK는 이 값과 무관하게 AR/camera assistance를 사용하지 않는다.
    public let supportsCameraAssistance: Bool
    /// 정밀 거리 측정 가능 여부.
    public let supportsPreciseDistanceMeasurement: Bool
    /// 확장 거리(>~9m) 측정 가능 여부. iOS 17.4 이전 OS 에서는 nil.
    public let supportsExtendedDistanceMeasurement: Bool?
}
