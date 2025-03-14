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
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main) // ✅ 메인 스레드에서 실행
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
        if !discoveredPeripherals.contains(where: { $0.0.identifier == peripheral.identifier }) {
            discoveredPeripherals.append((peripheral, RSSI))
            onDeviceDiscovered?(peripheral, RSSI)
        }
    }

    func stopScanning() {
        centralManager.stopScan()
        print("BLE 스캔 중지됨")
    }
}
