//
//  GrowSpaceSDK.swift
//  GrowSpaceSDK
//
//  Created by min gwan choi on 3/14/25.
//

import CoreBluetooth

import GrowSpacePrivateSDK

public class GrowSpaceSDK {
    private let apiKey: String
    
    private var scanner: SpaceBeaconScanner?
    private var uwbScanner: SpaceUWB = SpaceUWB()
    
    public init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    public func startSearchGrowSpaceBeacon(onDiscoverDevices: @escaping (Result<SpaceZoneResponse?, Error>) -> Void) {
        DebugLogger.debug("startSearchGrowSpaceBeacon 실행")
        if scanner == nil {
            scanner = SpaceBeaconScanner(
                apiKey: self.apiKey
            )
            
            scanner?.startScanning(onDeviceDiscovered: onDiscoverDevices)
        }
    }
    
    public func stopSearchGrowSpaceBeacon() {
        if let scanner = scanner {
            DebugLogger.debug("stopSearchGrowSpaceBeacon 실행")
            scanner.stopScanning()
            self.scanner = nil
        }
    }
    
    public func startUWBRanging(
        maximumConnectionCount: Int,
        replacementDistanceThreshold: Float,
        isConnectStrongestSignalFirst: Bool,
        onUpdate: @escaping (UWBResult) -> Void,
        onDisconnect: @escaping (UWBDisconnect) -> Void
    ) {
        uwbScanner.startUwbRanging(
            maximumConnectionCount: maximumConnectionCount,
            replacementDistanceThreshold: replacementDistanceThreshold,
            isConnectStrongestSignalFirst: isConnectStrongestSignalFirst)
        
        uwbScanner.spaceUWBHandler = {
            onUpdate($0)
        }
        
        uwbScanner.spcaeUWBDisconnectHandler = {
            onDisconnect($0)
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
}
