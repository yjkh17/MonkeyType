import Foundation

extension Notification.Name {
    static let restartTest = Notification.Name("restartTest")
    static let showSettings = Notification.Name("showSettings")
    static let switchTestMode = Notification.Name("switchTestMode")
    static let toggleLiveWPM = Notification.Name("toggleLiveWPM")
    static let toggleLiveAccuracy = Notification.Name("toggleLiveAccuracy")
    static let toggleKeyboard = Notification.Name("toggleKeyboard")
    static let cancelTest = Notification.Name("cancelTest")
    static let testComplete = Notification.Name("testComplete")
    static let hideResults = Notification.Name("hideResults")
    static let testCancelled = Notification.Name("testCancelled")
}