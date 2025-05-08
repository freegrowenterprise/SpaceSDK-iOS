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
}

public struct UWBDisconnectResult {
    public let disConnectType: DisconnectTypeResult
    public let deviceName: String
}
