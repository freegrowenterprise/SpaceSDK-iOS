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

    /// UWB 거리/방향 측정 결과 콜백.
    /// **호출자는 반드시 `[weak self]` 캡처를 사용해야 한다** (SDK ↔ 호출자 retain cycle 방지).
    /// - Parameter isEnableARWorldView: AR/카메라 assistance 사용 여부. 기본값 false.
    ///   true 일 때만 NI 세션이 ARSession 에 바인딩되고 isCameraAssistanceEnabled 가 true 로 설정된다.
    ///   이 경우 호스트 앱 Info.plist 에 `NSCameraUsageDescription` 이 필요하다.
    public func startUWBRanging(
        maximumConnectionCount: Int = 4,
        replacementDistanceThreshold: Float = 8,
        isConnectStrongestSignalFirst: Bool = true,
        uwbUpdateTimeoutSeconds: Int = 5,
        isEnableARWorldView: Bool = false,
        onUpdate: @escaping (UWBRangeResult) -> Void,
        onDisconnect: @escaping (UWBDisconnectResult) -> Void
    ) {
        uwbScanner.startUwbRanging(
            maximumConnectionCount: maximumConnectionCount,
            replacementDistanceThreshold: replacementDistanceThreshold,
            isConnectStrongestSignalFirst: isConnectStrongestSignalFirst,
            uwbUpdateTimeoutSeconds: uwbUpdateTimeoutSeconds,
            isEnableARWorldView: isEnableARWorldView)

        uwbScanner.spaceUWBHandler = { [weak self] result in
            guard let self else { return }
            onUpdate(self.changeUWBResultToUWBRangeResult(result))
        }

        uwbScanner.spcaeUWBDisconnectHandler = { [weak self] result in
            guard let self else { return }
            onDisconnect(self.convertDisconnectType(result))
        }
    }

    // MARK: - AR World View Toggle

    /// 런타임 중 AR/camera assistance 를 켜고 끈다.
    /// UWB 가 동작 중이면 현재 살아있는 모든 NI 세션이 stop → invalidate → 새 설정으로 재시작된다.
    /// (BLE 연결은 끊지 않는다; 디바이스에 stop / initialize 메시지가 다시 흐른다.)
    /// - Parameter enabled: AR/camera assistance 사용 여부.
    public func setARWorldViewEnabled(_ enabled: Bool) {
        uwbScanner.setARWorldViewEnabled(enabled)
    }

    /// 현재 AR World View 가 켜져 있는지 여부.
    public var isARWorldViewEnabled: Bool {
        return uwbScanner.isARWorldViewEnabled
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

    // MARK: - Single Device Disconnect

    /// 지정한 디바이스 1개의 활성 연결만 끊고, 현재 SDK 인스턴스 세션 동안 재연결을 막는다.
    /// 영구 차단이 필요하면 blockDevice(_:) 사용.
    public func disconnectDevice(_ deviceName: String) {
        uwbScanner.disconnectDevice(deviceName)
    }

    // MARK: - BlockList

    /// 디바이스를 차단 목록에 추가하고 즉시 끊는다. unblockDevice 호출 전까지 자동 재연결 안 됨.
    public func blockDevice(_ deviceName: String) {
        uwbScanner.blockDevice(deviceName)
    }

    /// 차단 목록에서 제거. 이후 스캔/연결 가능.
    public func unblockDevice(_ deviceName: String) {
        uwbScanner.unblockDevice(deviceName)
    }

    /// 디바이스가 현재 차단되어 있는지.
    public func isBlocked(_ deviceName: String) -> Bool {
        return uwbScanner.isBlocked(deviceName)
    }

    /// 현재 차단 목록 전체.
    public func getBlockedDevices() -> Set<String> {
        return uwbScanner.getBlockedDevices()
    }

    /// 모든 차단 해제.
    public func clearBlockedDevices() {
        uwbScanner.clearBlockedDevices()
    }

    // MARK: - Capabilities

    /// 현재 단말의 NearbyInteraction capability 조회.
    /// U2 환경에서 direction 미지원으로 azimuth/elevation 이 항상 nil 로 나오는지 호출자가 미리 확인할 때 사용.
    public func getUWBCapabilities() -> UWBCapabilitiesResult {
        let caps = uwbScanner.getUWBCapabilities()
        return UWBCapabilitiesResult(
            supportsDirection: caps.supportsDirection,
            supportsCameraAssistance: caps.supportsCameraAssistance,
            supportsPreciseDistanceMeasurement: caps.supportsPreciseDistanceMeasurement,
            supportsExtendedDistanceMeasurement: caps.supportsExtendedDistanceMeasurement
        )
    }

    // MARK: - Private Mappers

    private func changeUWBResultToUWBRangeResult(_ uwbResult: UWBResult) -> UWBRangeResult {
        return UWBRangeResult(
            deviceName: uwbResult.deviceName,
            distance: uwbResult.distance,
            direction: uwbResult.direction,
            azimuth: uwbResult.azimuth,
            elevation: uwbResult.elevation,
            isDirectionAvailable: uwbResult.isDirectionAvailable
        )
    }

    private func convertDisconnectType(_ type: GrowSpacePrivateSDK.UWBDisconnect) -> UWBDisconnectResult {
        let disconnectType: DisconnectTypeResult
        switch type.disConnectType {
        case .disconnectedDueToDistance:
            disconnectType = .disconnectedDueToDistance
        case .disconnectedDueToSystem:
            disconnectType = .disconnectedDueToSystem
        case .disconnectedDueToTimeout:
            disconnectType = .disconnectedDueToTimeout
        case .disconnectedDueToNoData:
            disconnectType = .disconnectedDueToNoData
        @unknown default:
            // 외부 SDK 가 미래에 새 케이스를 추가해도 빌드가 깨지지 않도록 안전망.
            disconnectType = .disconnectedDueToSystem
        }

        return UWBDisconnectResult(disConnectType: disconnectType, deviceName: type.deviceName)
    }
}
