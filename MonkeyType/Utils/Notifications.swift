import Foundation

extension Notification.Name {
    // Test Control
    static let restartTest = Notification.Name("restartTest")
    static let cancelTest = Notification.Name("cancelTest")
    static let testComplete = Notification.Name("testComplete")
    static let testCancelled = Notification.Name("testCancelled")
    
    // Settings
    static let showSettings = Notification.Name("showSettings")
    static let hideResults = Notification.Name("hideResults")
    
    // Test Mode
    static let switchTestMode = Notification.Name("switchTestMode")
    
    // View Controls
    static let toggleLiveWPM = Notification.Name("toggleLiveWPM")
    static let toggleLiveAccuracy = Notification.Name("toggleLiveAccuracy")
    static let toggleKeyboard = Notification.Name("toggleKeyboard")
}
