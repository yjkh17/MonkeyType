import AppKit

extension NSWindow {
    open override func cancelOperation(_ sender: Any?) {
        // Override Escape key to not close the window
        return
    }
}
