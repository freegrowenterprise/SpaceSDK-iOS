# 📡 SpaceSDK-iOS

**SpaceSDK** is a UWB-based iOS SDK developed by **FREEGROW Inc.**, providing features such as distance measurement, direction detection, and real-time RTLS (location estimation).  
With a single class `GrowSpaceSDK`, developers can easily access UWB capabilities without dealing with low-level complexities.


---

## 📦 Installation

Install via **Swift Package Manager (SPM)**:

1. In Xcode: `File → Add Packages`
2. Enter:
```
https://github.com/freegrowenterprise/SpaceSDK-iOS
```

---

## ✅ Key Features
- BLE + UWB-based distance measurement (Ranging)
- RTLS-based real-time location estimation (x, y, z)
- Real-time device connection and disconnection callbacks
- Per-device single disconnect (session-only) and persistent block list
- Capability inspection (`getUWBCapabilities`) for direction-support check before ranging

---

## 🆕 What's New in 0.0.42

- `disconnectDevice(name)` — disconnect a single device while keeping the scanner running. Auto-reconnect is suppressed for the lifetime of the current `GrowSpaceSDK` instance.
- `blockDevice(name)` / `unblockDevice(name)` / `isBlocked(name)` / `getBlockedDevices()` / `clearBlockedDevices()` — persistent block list backed by `UserDefaults`. Blocked devices are filtered out at scan time.
- `getUWBCapabilities()` — exposes the host phone's NearbyInteraction capabilities (direction / camera assistance / precise / extended distance) so callers can decide UI behavior before ranging.
- `UWBDisconnectResult.disConnectType` adds `disconnectedDueToTimeout` (STALE — UWB updates stopped after they had started) and `disconnectedDueToNoData` (NEVER\_RECEIVED — never produced a UWB update).
- ARKit / RealityKit / `ARSession` / camera-assistance code paths are removed from the SDK. **No camera permission is required** in your app's Info.plist.
- Memory-leak hardening: callback handlers should still be captured with `[weak self]` from your code; SDK-internal `Timer` and delegates are weak-referenced.

---

## 🔧 Requirements

### Software
- iOS 16.0 or later  
- Xcode 14 or later  
- Swift 5.7 or later

### Hardware
- [UWB-supported iPhone](https://blog.naver.com/growdevelopers/223775171523)  
- Physical UWB device [(Grow Space UWB product)](https://grow-space.io/product/n1-mk-01/)

---

## 📑 Info.plist Permissions
```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app requires Bluetooth access for communication with UWB devices via BLE.</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>This app requires location access to discover and connect BLE-based devices.</string>

<key>NSNearbyInteractionUsageDescription</key>
<string>This app uses the UWB feature for nearby interaction.</string>

<key>NSMotionUsageDescription</key>
<string>Motion sensor access is required for precise location calculation.</string>

<key>NSBluetoothPeripheralUsageDescription</key>
<string>This app requires BLE permission to connect to UWB devices.</string>
```

Camera permission is not required. SpaceSDK does not use ARKit, create an ARSession, or enable Nearby Interaction camera assistance.

---

## 🧱 Initialization

```swift
let growSpaceSDK = GrowSpaceSDK()
```

---

## 🚀 Start Ranging
```swift
growSpaceSDK.startUWBRanging(
    maximumConnectionCount: 4,
    replacementDistanceThreshold: 8,
    uwbUpdateTimeoutSeconds: 5,
    onUpdate: { result in
        let name = result.deviceName
        let distance = result.distance
        let azimuth = result.azimuth
        let elevation = result.elevation

        DispatchQueue.main.async {
            // Display result on UI
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

### Variable Description
```
/// Maximum number of devices that can be connected simultaneously
    maximumConnectionCount: 4,

/// Distance threshold (in meters). Devices exceeding this distance 
/// will be automatically disconnected
    replacementDistanceThreshold: 8,

/// Disconnect a device if no UWB value update is received 
/// within the specified number of seconds
    uwbUpdateTimeoutSeconds: 5,
```

---

## 🛑 Stop Ranging

```swift
growSpaceSDK.stopUWBRanging {
    print("✅ Ranging stopped")
}
```

---

## 🚫 Disconnect a Single Device / Block List

`disconnectDevice` and `blockDevice` look similar but mean different things. Pick the one that matches the user's intent.

| | `disconnectDevice(name)` | `blockDevice(name)` |
|---|---|---|
| Drop the active BLE/UWB connection | ✅ | ✅ |
| Scanner keeps running | ✅ | ✅ |
| Suppress auto-reconnect within current `GrowSpaceSDK` instance | ✅ | ✅ |
| Persisted to disk (`UserDefaults`) | ❌ | ✅ |
| Reachable again from a fresh `GrowSpaceSDK` instance / new screen | ✅ Yes | ❌ Until `unblockDevice` |
| Filtered out at BLE advertisement scan | ❌ (instance-scoped only) | ✅ (permanent) |

```swift
// Drop a single device but leave the door open for re-connection later.
growSpaceSDK.disconnectDevice("FGU-1234")

// Permanently block. Survives app relaunch via UserDefaults.
growSpaceSDK.blockDevice("FGU-1234")

// Inspect / lift the block list.
let blocked: Set<String> = growSpaceSDK.getBlockedDevices()
if growSpaceSDK.isBlocked("FGU-1234") {
    growSpaceSDK.unblockDevice("FGU-1234")
}
growSpaceSDK.clearBlockedDevices()
```

---

## 🔌 Disconnect Reasons

`UWBDisconnectResult.disConnectType` tells you why a device went away. Each case maps to a different UX response.

| Case | Meaning | Typical UX |
|---|---|---|
| `disconnectedDueToDistance` | Device exceeded `replacementDistanceThreshold` | "Out of range" toast |
| `disconnectedDueToSystem` | BLE peer disconnect, NI session invalidated, etc. | Generic "Disconnected" |
| `disconnectedDueToTimeout` | UWB updates were arriving and then stopped (STALE) | Encourage user to retry / move closer |
| `disconnectedDueToNoData` | Connected, but **never** produced a UWB update (NEVER\_RECEIVED — known iOS 26 EDM regression on U2) | Suggest reconnect; consider raising the timeout |

```swift
onDisconnect: { result in
    switch result.disConnectType {
    case .disconnectedDueToNoData:
        // Never received any UWB sample for this device.
        // Prompt the user to retry or check the device.
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

## ⚠️ Memory Leak — Capture handlers with `[weak self]`

The SDK retains the closures you pass to `startUWBRanging(onUpdate:onDisconnect:)`. If you capture `self` strongly inside those closures, your view controller / view model and the SDK will hold each other alive, and `deinit` will never fire. Always capture `self` weakly:

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

The SDK itself uses weak references for its internal `Timer` and delegate plumbing, so the cycle is purely on the caller side.

---

## 🧪 Capability Check

```swift
let caps = growSpaceSDK.getUWBCapabilities()
// caps.supportsDirection         — false on U2 (iPhone 14+); azimuth/elevation will be nil
// caps.supportsCameraAssistance  — informational only; SDK does not use camera assistance
// caps.supportsPreciseDistanceMeasurement
// caps.supportsExtendedDistanceMeasurement (nil on iOS < 17.4)
```

---


## 📍 RTLS Location Estimation
```swift
growSpaceSDK.startUWBRanging(
    onUpdate: { result in
        // Store distance results
        anchorResults[result.deviceName] = result

        // Convert to anchor data with known coordinates
        let anchors = convertToAnchorResults(
            from: anchorResults,
            coordinates: anchorCoordinateMap
        )

        // RTLS location processing
        growSpaceRTLS.startUwbRtls(
            anchors: anchors,
            onResult: { location in
                DispatchQueue.main.async {
                    // Update user's position on grid
                    updateUserPositionOnGrid(CGPoint(x: location.x, y: location.y))
                }
            }
        )
    }
)
```

---

## 📱 Test App

An official test app built using this SDK is available for public use.
You can test UWB ranging and RTLS features with actual devices.

- [GitHub](https://github.com/freegrowenterprise/SpaceSDK-iOS-TestApp)
- [App Store](https://apps.apple.com/us/app/space-uwb/id6745208882)

 ---

## 🏢 Developed by

**FREEGROW Inc.**  
We specialize in UWB-based indoor positioning and wireless communication solutions.

---

## 📫 Contact

For technical support or feedback, please contact us:

📮 contact@freegrow.io

🌐 https://grow-space.io
