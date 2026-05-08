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

## 🆕 0.0.43 변경점

- AR World View / camera assistance 가 **opt-in 토글**로 돌아왔다. 기본값은 **off** 라서 기존 통합 코드는 0.0.42 와 동일하게 카메라 프롬프트 없이 동작한다.
- `startUWBRanging(..., isEnableARWorldView: Bool = false, ...)` — 시작 시점에 `true` 를 넘기면 각 `NISession` 이 `ARSession` 에 바인딩되고 `isCameraAssistanceEnabled = true` 로 설정된다.
- `setARWorldViewEnabled(_:)` — 런타임 토글. **현재 살아있는 NI 세션을 stop → invalidate → 새 설정으로 재시작**한다. BLE 연결은 유지되며, ranging 만 잠깐 끊겼다 새 direction 특성으로 다시 흐른다.
- `isARWorldViewEnabled: Bool` — 현재 상태 read-only 게터.
- 카메라 권한 (`NSCameraUsageDescription`) 은 **토글이 켜져 있을 때만** 필요하다. off 경로는 카메라/ARKit 을 건드리지 않는다.

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

카메라 권한은 **AR World View / camera assistance 를 opt-in 한 경우에만** 필요합니다 (`isEnableARWorldView: true` 또는 `setARWorldViewEnabled(true)`). 기본 off 경로는 ARKit 을 로드하지도, 카메라를 열지도 않으므로 키를 생략해도 됩니다.

```xml
<!-- 선택 사항 — AR World View / camera assistance 를 켤 때만 필요 -->
<key>NSCameraUsageDescription</key>
<string>UWB AR World View 가 ARKit camera assistance 로 방향 측정을 보조합니다.</string>
```

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
    isEnableARWorldView: false, // true 면 시작 시점부터 ARKit camera assistance 사용
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

## 🎥 AR World View / Camera Assistance 토글

`AR World View` 는 **기본 off**. 켜면 각 `NISession` 이 공유 `ARSession` 에 바인딩되고 `isCameraAssistanceEnabled = true` 가 적용된다 — camera assistance 를 지원하는 단말(특히 iPhone 14+ U2 칩, 카메라 없이 direction 미측정)에서 방향 정확도가 향상된다.

```swift
// 기본 — 카메라/ARKit 미사용 (권한 프롬프트도 뜨지 않음)
growSpaceSDK.startUWBRanging(
    isEnableARWorldView: false,
    onUpdate: { ... },
    onDisconnect: { ... }
)

// 시작 시점부터 AR ON (호출자는 NSCameraUsageDescription 보장)
growSpaceSDK.startUWBRanging(
    isEnableARWorldView: true,
    onUpdate: { ... },
    onDisconnect: { ... }
)

// 런타임 토글. 살아있는 NI 세션을 stop / invalidate / 새 설정으로 재시작.
// BLE 연결은 끊지 않음; ranging 만 잠깐 끊겼다 다시 흐른다.
growSpaceSDK.setARWorldViewEnabled(true)
print(growSpaceSDK.isARWorldViewEnabled) // true
```

**권한 안내.** 토글 ON 시점에 iOS 가 자동으로 카메라 권한 다이얼로그를 띄운다(`NSCameraUsageDescription` 가 있을 때). 사용자가 거부하면 카메라가 켜지지 않고 AR 뷰는 검정 상태, 방향 정확도 향상도 없다. 호출자는 토글을 켜기 전에 `AVCaptureDevice.authorizationStatus(for: .video)` 로 사전 확인하고, 거부 상태면 사용자를 설정 앱으로 안내해야 한다. UWB ranging 자체는 카메라 없이도 계속 동작 — U1 칩은 방향이 그대로 측정되고, U2 칩에서는 방향이 비어 있다.

---

## 🛑 거리 측정 중지

```swift
growSpaceSDK.stopUWBRanging {
    print("✅ 거리 측정 종료")
}
```

---

## 🚫 단일 끊기 / 차단 목록

`disconnectDevice` 와 `blockDevice` 는 이름이 비슷하지만 의미가 다르다. 사용자 의도에 맞게 골라 쓴다.

| | `disconnectDevice(name)` | `blockDevice(name)` |
|---|---|---|
| 활성 BLE/UWB 연결 끊기 | ✅ | ✅ |
| 스캐너 계속 동작 | ✅ | ✅ |
| 같은 `GrowSpaceSDK` 인스턴스 동안 자동 재연결 차단 | ✅ | ✅ |
| 영구 저장 (`UserDefaults`) | ❌ | ✅ |
| 새 `GrowSpaceSDK` 인스턴스 / 새 화면에서 재연결 가능 | ✅ 가능 | ❌ `unblockDevice` 호출 전까지 불가 |
| BLE 광고 단계에서 필터 | ❌ (인스턴스 세션 내) | ✅ (영구) |

```swift
// 한 번만 끊기 — 다시 연결될 가능성을 열어두는 UX.
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

## 🔌 Disconnect 사유 분기

`UWBDisconnectResult.disConnectType` 은 디바이스가 끊어진 이유를 알려준다. 각 케이스마다 적절한 UX 응답이 다르다.

| 케이스 | 의미 | 권장 UX |
|---|---|---|
| `disconnectedDueToDistance` | `replacementDistanceThreshold` 초과 | "거리 너무 멀어서 끊김" |
| `disconnectedDueToSystem` | BLE peer disconnect, NI 세션 invalid 등 | 일반 끊김 안내 |
| `disconnectedDueToTimeout` | 데이터 받다가 임계 시간 동안 끊김 (STALE) | 신호 회복 시도 안내 |
| `disconnectedDueToNoData` | 연결됐지만 UWB 데이터를 **한 번도** 못 받음 (NEVER\_RECEIVED — iOS 26 U2 EDM 회귀 가능성) | 재시도 권유 / timeout 늘려 보기 |

```swift
onDisconnect: { result in
    switch result.disConnectType {
    case .disconnectedDueToNoData:
        // UWB 데이터가 한 번도 들어오지 않은 케이스. 재시도/장치 점검 안내.
        showNoDataAlert(for: result.deviceName)
    case .disconnectedDueToTimeout:
        showTimeoutToast(for: result.deviceName)
    case .disconnectedDueToDistance, .disconnectedDueToSystem:
        showStandardDisconnectToast(for: result.deviceName)
    @unknown default:
        showStandardDisconnectToast(for: result.deviceName)
    }
}
```

---

## ⚠️ 메모리 누수 — 핸들러는 반드시 `[weak self]` 로 캡처

SDK 가 `startUWBRanging(onUpdate:onDisconnect:)` 에 넘긴 클로저를 강참조로 보관한다. 클로저 안에서 `self` 를 강하게 캡처하면 호출자(VC / VM) ↔ SDK 사이에 retain cycle 이 생겨 `deinit` 이 호출되지 않는다. 항상 약하게 잡아야 한다.

```swift
growSpaceSDK.startUWBRanging(
    onUpdate: { [weak self] result in
        guard let self else { return }
        self.update(result)
    },
    onDisconnect: { [weak self] result in
        guard let self else { return }
        self.handleDisconnect(result)
    }
)
```

SDK 내부 `Timer` / 델리게이트는 모두 weak 로 처리되어 있어, retain cycle 위험은 호출자 코드 쪽에만 남는다.

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
