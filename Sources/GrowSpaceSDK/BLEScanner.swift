//
//  BLEScanner.swift
//  GrowSpaceSDK
//
//  Created by min gwan choi on 3/14/25.
//

import CoreBluetooth

class BLEScanner: NSObject, CBCentralManagerDelegate {
    private var centralManager: CBCentralManager!
    private var discoveredPeripherals: [(CBPeripheral, NSNumber)] = []
    private var onDeviceDiscovered: ((CBPeripheral, NSNumber, String?) -> Void)?

    init(onDeviceDiscovered: @escaping (CBPeripheral, NSNumber, String?) -> Void) {
        super.init()
        self.onDeviceDiscovered = onDeviceDiscovered
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("BLE 사용 가능. 스캔 시작")
            centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        } else {
            print("BLE를 사용할 수 없음. 상태: \(central.state.rawValue)")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        print("발견된 기기: \(peripheral.name ?? "알 수 없음"), RSSI: \(RSSI)")

        var macAddress: String? = nil

        if let serviceData = advertisementData[CBAdvertisementDataServiceDataKey] as? [CBUUID: Data] {
            for (key, value) in serviceData {
                if key.uuidString.lowercased() == "ffe1" {
                    if value.count == 14, value[0] == 161, value[1] == 8, value[2] == 100 {
                        macAddress = ""
                        macAddress! += toHexWithPadding(value[8])
                        macAddress! += toHexWithPadding(value[7])
                        macAddress! += toHexWithPadding(value[6])
                        macAddress! += toHexWithPadding(value[5])
                        macAddress! += toHexWithPadding(value[4])
                        macAddress! += toHexWithPadding(value[3])

                        print("🔹 MAC 주소: \(macAddress!)")
                    }
                }
            }
        }

        if !discoveredPeripherals.contains(where: { $0.0.identifier == peripheral.identifier }) {
            discoveredPeripherals.append((peripheral, RSSI))
            onDeviceDiscovered?(peripheral, RSSI, macAddress)
        }
    }

    func stopScanning() {
        centralManager.stopScan()
        print("BLE 스캔 중지됨")
    }

    private func toHexWithPadding(_ byte: UInt8) -> String {
        return String(format: "%02X", byte)
    }
}
