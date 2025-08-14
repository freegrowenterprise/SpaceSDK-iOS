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

<key>NSCameraUsageDescription</key>
<string>Camera access is required to improve the accuracy of distance and direction measurements.</string>

<key>NSMotionUsageDescription</key>
<string>Motion sensor access is required for precise location calculation.</string>

<key>NSBluetoothPeripheralUsageDescription</key>
<string>This app requires BLE permission to connect to UWB devices.</string>
```

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

---

## 🛑 Stop Ranging

```swift
growSpaceSDK.stopUWBRanging {
    print("✅ Ranging stopped")
}
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

