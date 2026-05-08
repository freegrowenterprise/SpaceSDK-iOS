//
//  File.swift
//  GrowSpaceSDK
//
//  Created by min gwan choi on 5/2/25.
//

import Foundation

import GrowSpacePrivateSDK

public enum DisconnectTypeResult {
    case disconnectedDueToDistance
    case disconnectedDueToSystem
    /// 데이터 수신 후 임계 시간 동안 갱신이 끊긴 경우 (STALE).
    case disconnectedDueToTimeout
    /// BLE 연결 후 임계 시간 안에 UWB 데이터가 한 번도 들어오지 않은 경우 (NEVER_RECEIVED).
    /// iOS 26 + U2↔U2 EDM 미업데이트 회귀가 대표 케이스.
    case disconnectedDueToNoData
}

public struct UWBDisconnectResult {
    public let disConnectType: DisconnectTypeResult
    public let deviceName: String
}
