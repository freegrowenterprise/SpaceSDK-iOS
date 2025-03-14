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
    private var onDeviceDiscovered: ((CBPeripheral, NSNumber) -> Void)?

    init(onDeviceDiscovered: @escaping (CBPeripheral, NSNumber) -> Void) {
        super.init()
        self.onDeviceDiscovered = onDeviceDiscovered
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    // BLE 상태 업데이트
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("BLE 사용 가능. 스캔 시작")
            centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        } else {
            print("BLE를 사용할 수 없음. 상태: \(central.state.rawValue)")
        }
    }

    // 기기 발견 시 호출됨
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        print("발견된 기기: \(peripheral.name ?? "알 수 없음"), RSSI: \(RSSI)")

        // 중복된 기기 필터링
        if !discoveredPeripherals.contains(where: { $0.0.identifier == peripheral.identifier }) {
            discoveredPeripherals.append((peripheral, RSSI))
            onDeviceDiscovered?(peripheral, RSSI)
        }
    }

    // 스캔 중지 함수
    func stopScanning() {
        centralManager.stopScan()
        print("BLE 스캔 중지됨")
    }
}
