//
//  GrowSpaceSDK.swift
//  GrowSpaceSDK
//
//  Created by min gwan choi on 3/14/25.
//

import CoreBluetooth

import GrowSpacePrivateSDK

public class GrowSpaceSDK {
    private var uwbScanner: SpaceUWB = SpaceUWB()
    
    public init() {}
    
    public func startUWBRanging(
        maximumConnectionCount: Int = 4,
        replacementDistanceThreshold: Float = 8,
        isConnectStrongestSignalFirst: Bool = true,
        onUpdate: @escaping (UWBRangeResult) -> Void,
        onDisconnect: @escaping (DisconnectTypeResult) -> Void
    ) {
        uwbScanner.startUwbRanging(
            maximumConnectionCount: maximumConnectionCount,
            replacementDistanceThreshold: replacementDistanceThreshold,
            isConnectStrongestSignalFirst: isConnectStrongestSignalFirst)
        
        uwbScanner.spaceUWBHandler = {
            onUpdate(self.changeUWBResultToUWBRangeResult($0))
        }
        
        uwbScanner.spcaeUWBDisconnectHandler = {
            onDisconnect(self.convertDisconnectType($0))
        }
    }
    
    public func stopUWBRanging(onComplete: @escaping (Result<Void, Error>) -> Void) {
        do {
            try uwbScanner.stop()
            onComplete(.success(()))
        } catch {
            onComplete(.failure(error))
        }
    }
    
    public func startUWBRTLS(
        onResult: @escaping (UWBRangeResult) -> Void
    ) {
        
    }
    
    private func changeUWBResultToUWBRangeResult(_ uwbResult: UWBResult) -> UWBRangeResult {
        return UWBRangeResult(deviceName: uwbResult.deviceName,
                              distance: uwbResult.distance,
                              direction: uwbResult.direction,
                              azimuth: uwbResult.azimuth,
                              elevation: uwbResult.elevation)
    }
    
    func convertDisconnectType(_ type: GrowSpacePrivateSDK.UWBDisconnect) -> DisconnectTypeResult {
        switch type.disConnectType {
        case .disconnectedDueToDistance:
            return .disconnectedDueToDistance
        case .disconnectedDueToSystem:
            return .disconnectedDueToSystem
        default:
            return .disconnectedDueToSystem
        }
    }
}
