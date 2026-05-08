# 📡 SpaceSDK-iOS

**SpaceSDK**는 FREEGROW Inc.의 UWB 기반 iOS SDK로 거리 측정, 방향 계산, RTLS 실시간 위치 추정 기능을 제공합니다.  
SDK 사용자는 단일 클래스 `GrowSpaceSDK`를 통해 복잡한 연결 흐름 없이 UWB 기능을 간편하게 활용할 수 있습니다.

---

## 📦 설치 방법

**Swift Package Manager(SPM)** 를 통한 설치

1. Xcode → File → Add Packages
2. 입력:
```
https://github.com/freegrowenterprise/SpaceSDK-iOS
```

---

## ✅ 주요 기능
- BLE + UWB 기반 거리 측정 (Ranging)
- RTLS 기반 위치 추정 (x, y, z 계산)
- 실시간 디바이스 연결/해제 콜백
- 디바이스 1개만 끊는 단일 disconnect (현재 세션 한정) + 영구 차단 목록
- `getUWBCapabilities` 로 단말 NI capability(direction 등) 사전 조회

---

## 🆕 0.0.42 변경점

- `disconnectDevice(name)` — 스캐너는 그대로 두고 특정 디바이스 1개만 끊는다. 같은 `GrowSpaceSDK` 인스턴스 동안엔 자동 재연결을 막고, 새 인스턴스/새 화면에선 다시 연결될 수 있다.
- `blockDevice(name)` / `unblockDevice(name)` / `isBlocked(name)` / `getBlockedDevices()` / `clearBlockedDevices()` — `UserDefaults` 기반 영구 차단 목록. 차단된 이름은 스캔 단계에서 필터된다.
- `getUWBCapabilities()` — 단말의 NearbyInteraction capability(direction / camera assistance / precise / extended distance) 노출. ranging 시작 전 UI 분기에 활용.
- `UWBDisconnectResult.disConnectType` 에 `disconnectedDueToTimeout` (STALE — UWB 업데이트가 들어오던 중 끊김) / `disconnectedDueToNoData` (NEVER\_RECEIVED — 한 번도 안 들어옴) 케이스 추가.
- ARKit / RealityKit / `ARSession` / camera assistance 사용 경로 모두 제거. **앱 Info.plist 에 카메라 권한 불필요.**
- 메모리 누수 보강: 호출자는 핸들러를 `[weak self]` 로 캡처해야 하고, SDK 내부 Timer/델리게이트는 모두 weak.

---

## 🔧 요구 사항

### Software
- iOS 16.0 이상
- Xcode 14 이상
- Swift 5.7 이상

### Hardware
- [UWB 지원 iOS 휴대폰](https://blog.naver.com/growdevelopers/223775171523)
- 실제 UWB 디바이스 [(Grow Space UWB 제품)](https://grow-space.io/product/n1-mk-01/)

---

## 📑 Info.plist 권한 설정
```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>이 앱은 UWB 장치와 BLE 통신을 위해 Bluetooth 권한이 필요합니다.</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>이 앱은 BLE 기반 장치 검색 및 연결을 위해 위치 권한이 필요합니다.</string>

<key>NSNearbyInteractionUsageDescription</key>
<string>이 앱은 근거리 상호작용을 위해 UWB 기능을 사용합니다.</string>

<key>NSMotionUsageDescription</key>
<string>정확한 위치 계산을 위해 모션 센서 접근이 필요합니다.</string>

<key>NSBluetoothPeripheralUsageDescription</key>
<string>UWB 장치와의 BLE 연결을 위해 이 권한이 필요합니다.</string>
```

카메라 권한은 필요하지 않습니다. SpaceSDK는 ARKit을 사용하지 않고, ARSession을 생성하지 않으며, Nearby Interaction camera assistance를 켜지 않습니다.

---

## 🧱 초기화

```swift
let growSpaceSDK = GrowSpaceSDK()
```

---

## 🚀 거리 측정 시작
```swift
growSpaceSDK.startUWBRanging(
    maximumConnectionCount: 4,
    replacementDistanceThreshold: 8,
    onUpdate: { result in
        let name = result.deviceName
        let distance = result.distance
        let azimuth = result.azimuth
        let elevation = result.elevation

        DispatchQueue.main.async {
            // 결과를 UI에 표시하는 로직
            updateDeviceUI(
                name: name,
                distance: distance,
                azimuth: azimuth,
                elevation: elevation
            )
        }
    },
    onDisconnect: { result in
        DispatchQueue.main.async {
            removeDeviceUI(name: result.deviceName)
        }
    }
)
```

---

## 🛑 거리 측정 중지

```swift
growSpaceSDK.stopUWBRanging {
    print("✅ 거리 측정 종료")
}
```

---

## 🚫 단일 끊기 / 차단 목록

```swift
// 디바이스 1개만 끊기. 스캐너는 계속 동작. 같은 GrowSpaceSDK 인스턴스 안에선
// 자동 재연결을 막지만, 새 인스턴스(예: 페이지 이탈 후 재진입)에선 다시 연결될 수 있다.
growSpaceSDK.disconnectDevice("FGU-1234")

// 영구 차단. UserDefaults 에 저장되어 앱 재실행 후에도 유지.
growSpaceSDK.blockDevice("FGU-1234")

// 차단 목록 조회 / 해제.
let blocked: Set<String> = growSpaceSDK.getBlockedDevices()
if growSpaceSDK.isBlocked("FGU-1234") {
    growSpaceSDK.unblockDevice("FGU-1234")
}
growSpaceSDK.clearBlockedDevices()
```

---

## 🧪 Capability 조회

```swift
let caps = growSpaceSDK.getUWBCapabilities()
// caps.supportsDirection         — U2(iPhone 14+)에선 false. azimuth/elevation 이 항상 nil.
// caps.supportsCameraAssistance  — 정보용. SDK 는 camera assistance 를 사용하지 않음.
// caps.supportsPreciseDistanceMeasurement
// caps.supportsExtendedDistanceMeasurement (iOS < 17.4 에선 nil)
```

---


## 📍 RTLS 위치 추정
```swift
growSpaceSDK.startUWBRanging(
    onUpdate: { result in
        // 거리 수신 결과 누적
        anchorResults[result.deviceName] = result

        // 앵커 ID와 위치 매핑 정보로 RTLS 계산
        let anchors = convertToAnchorResults(
            from: anchorResults,
            coordinates: anchorCoordinateMap
        )

        // 실시간 RTLS 위치 추정
        growSpaceRTLS.startUwbRtls(
            anchors: anchors,
            onResult: { location in
                DispatchQueue.main.async {
                    // 위치 결과를 화면 격자에 표시
                    updateUserPositionOnGrid(CGPoint(x: location.x, y: location.y))
                }
            }
        )
    }
)
```

---

## 📱 테스트 앱 안내

본 SDK를 활용한 공식 테스트 앱이 아래 경로에 공개되어 있습니다.
실제 디바이스와 연동하여 UWB 거리 측정 및 RTLS 위치 추정 기능을 직접 체험할 수 있습니다.

- [GitHub](https://github.com/freegrowenterprise/SpaceSDK-iOS-TestApp)
- [App Store](https://apps.apple.com/us/app/space-uwb/id6745208882)

 ---

## 🏢 제작

**FREEGROW Inc.**  
실내 측위와 근거리 무선 통신 기술을 바탕으로 한 UWB 솔루션을 개발하고 있습니다.

---

## 📫 문의

기술 문의나 개선 제안은 아래 메일로 연락주세요.

📮 contact@freegrow.io

🌐 https://grow-space.io
