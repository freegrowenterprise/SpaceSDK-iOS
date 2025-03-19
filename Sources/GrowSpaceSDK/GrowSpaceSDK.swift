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
    
    public init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    public func startSearchGrowSpaceBeacon(onDiscoverDevices: @escaping (Result<SpaceZoneResponse?, Error>) -> Void) {
        print("startSearchGrowSpaceBeacon 실행")
        if scanner == nil {
            scanner = SpaceBeaconScanner(
                apiKey: self.apiKey
            )
            
            scanner?.startScanning(onDeviceDiscovered: onDiscoverDevices)
        }
    }
    
    public func stopSearchGrowSpaceBeacon() {
        if let scanner = scanner {
            print("stopSearchGrowSpaceBeacon 실행")
            scanner.stopScanning()
            self.scanner = nil
        }
    }
}
