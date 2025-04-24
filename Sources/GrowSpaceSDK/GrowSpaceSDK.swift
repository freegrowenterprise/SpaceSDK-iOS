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
    
    public func startUWBRanging() {
        uwbScanner.start()
        
        uwbScanner.spaceUWBHandler = {
            DebugLogger.debug("device Name : \($0.deviceName) distance : \($0.distance) azimuth : \($0.azimuth) elevation : \($0.elevation)")
        }
        
        uwbScanner.spcaeUWBDisconnectHandler = {
            switch $0.disConnectType {
            case .deviceRemoved:
                DebugLogger.debug("deviceRemoved")
            case .disconnectedDueToDistance:
                DebugLogger.debug("disconnectedDueToDistance")
            default:
                break
            }
        }
    }
}
