//
//  GrowSpaceSDK.swift
//  GrowSpaceSDK
//
//  Created by min gwan choi on 3/14/25.
//

import CoreBluetooth

public class GrowSpaceSDK {
    private var scanner: BLEScanner?

    public init() {}

    public func startSearchGrowSpaceBeacon() {
        scanner = BLEScanner { peripheral, rssi in
            print("🔹 발견된 기기: \(peripheral.name ?? "알 수 없음"), RSSI: \(rssi)")
        }
    }
}
