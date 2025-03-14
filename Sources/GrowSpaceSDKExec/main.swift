import GrowSpaceSDK
import Foundation

let sdk = GrowSpaceSDK()
sdk.startSearchGrowSpaceBeacon()
print("실행 완료")

RunLoop.main.run()
