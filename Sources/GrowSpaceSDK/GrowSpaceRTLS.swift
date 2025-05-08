//
//  GrowSpaceRTLS.swift
//  GrowSpaceSDK
//
//  Created by min gwan choi on 5/8/25.
//

import Foundation

@preconcurrency import GrowSpacePrivateSDK

public class GrowSpaceRTLS {
    private var spaceRTLS: SpaceRTLS?
    
    public init(spaceRTLS: SpaceRTLS? = nil) {
        self.spaceRTLS = spaceRTLS
    }

    public func startUwbRtls(
        anchors: [RTLSAnchorResult],
        zCorrection: Double = 1.0,
        filterType: RtlsFilterType = .movingAverage,
        onResult: @Sendable @escaping (TagLocationResult) -> Void
    ) {
        self.spaceRTLS = SpaceRTLS(filterType: filterType)

        let privateAnchors: [GrowSpacePrivateSDK.RTLSAnchor] = anchors.map {
            GrowSpacePrivateSDK.RTLSAnchor(
                id: $0.id,
                x: $0.x,
                y: $0.y,
                z: $0.z,
                distance: $0.distance
            )
        }

        DispatchQueue.global().async { [spaceRTLS = self.spaceRTLS] in
            guard let location = spaceRTLS?.calculateLocation(
                anchors: privateAnchors,
                zCorrection: zCorrection
            ) else { return }

            let result = TagLocationResult(from: location)

            DispatchQueue.main.async {
                onResult(result)
            }
        }
    }
}

