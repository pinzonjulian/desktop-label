import Cocoa

// Private CoreGraphics SPI — stable, used by yabai/SketchyBar/etc.
@_silgen_name("CGSMainConnectionID")
func CGSMainConnectionID() -> Int

@_silgen_name("CGSGetActiveSpace")
func CGSGetActiveSpace(_ cid: Int) -> Int

@_silgen_name("CGSCopyManagedDisplaySpaces")
func CGSCopyManagedDisplaySpaces(_ cid: Int) -> CFArray

class SpaceDetector {
    private let connectionID: Int

    init() {
        connectionID = CGSMainConnectionID()
    }

    /// Returns the 1-based index of the current Space on the main display.
    func currentSpaceIndex() -> Int {
        let activeSpaceID = CGSGetActiveSpace(connectionID)
        let displaySpaces = CGSCopyManagedDisplaySpaces(connectionID) as! [[String: Any]]

        for display in displaySpaces {
            guard let spaces = display["Spaces"] as? [[String: Any]] else { continue }
            for (index, space) in spaces.enumerated() {
                if let id64 = space["id64"] as? Int, id64 == activeSpaceID {
                    return index + 1
                }
                if let managedSpaceID = space["ManagedSpaceID"] as? Int, managedSpaceID == activeSpaceID {
                    return index + 1
                }
            }
        }
        return 1
    }
}
