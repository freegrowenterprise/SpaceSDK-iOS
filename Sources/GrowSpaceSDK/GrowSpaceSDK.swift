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
    private var network: SpaceNetwork
    
    public init(apiKey: String) {
        self.apiKey = apiKey
        self.network = SpaceNetwork(
            apiKey: apiKey
        )
    }
    
    public func startSearchGrowSpaceBeacon(onDiscoverDevices: @escaping (String, Int) -> Void) {
        print("startSearchGrowSpaceBeacon 실행")
        if scanner == nil {
            scanner = SpaceBeaconScanner(apiKey: self.apiKey) { macAddress, rssi in
                print("MacAddress : \(macAddress), RSSI : \(rssi)")
                onDiscoverDevices(macAddress, rssi)
            }
        }
    }
    
    public func stopSearchGrowSpaceBeacon() {
        if let scanner = scanner {
            print("stopSearchGrowSpaceBeacon 실행")
            scanner.stopScanning()
            self.scanner = nil
        }
    }
    
    public func spaceBeaconLocation(macAddress: String) async -> SpaceZoneResponse? {
        return await self.network.sendGetRequestToServer(macAddress: macAddress)
    }
}
