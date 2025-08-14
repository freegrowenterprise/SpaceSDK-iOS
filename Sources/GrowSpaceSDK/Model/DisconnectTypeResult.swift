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
    case disconnectedDueToTimeout
}

public struct UWBDisconnectResult {
    public let disConnectType: DisconnectTypeResult
    public let deviceName: String
}
