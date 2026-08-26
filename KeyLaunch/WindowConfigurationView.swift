import AppKit
import SwiftUI

struct WindowConfigurationView: NSViewRepresentable {
    let contentSize: CGSize

    func makeNSView(context: Context) -> NSView {
        ConfigurationHostView(contentSize: contentSize)
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        guard let configurationView = nsView as? ConfigurationHostView else {
            return
        }

        configurationView.contentSize = contentSize
        configurationView.applyWindowConfiguration()
    }
}

private final class ConfigurationHostView: NSView {
    var contentSize: CGSize
    private var didApplyInitialSize = false
    private var pendingContentSize: CGSize?

    init(contentSize: CGSize) {
        self.contentSize = contentSize
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        applyWindowConfiguration()
    }

    func applyWindowConfiguration() {
        guard let window else {
            return
        }

        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.styleMask.insert(.fullSizeContentView)
        window.collectionBehavior.remove([.fullScreenPrimary, .fullScreenAllowsTiling])
        window.collectionBehavior.insert(.fullScreenDisallowsTiling)
        window.standardWindowButton(.zoomButton)?.isHidden = true
        window.minSize = CGSize(width: min(contentSize.width, 900), height: 620)

        if !didApplyInitialSize {
            window.setContentSize(contentSize)
            window.center()
            didApplyInitialSize = true
            applyDeferredResize(to: contentSize)
            return
        }

        resizeWindowKeepingTopLeft(window, to: contentSize)
        applyDeferredResize(to: contentSize)
    }

    private func resizeWindowKeepingTopLeft(_ window: NSWindow, to contentSize: CGSize) {
        let currentFrame = window.frame
        let targetFrame = window.frameRect(forContentRect: CGRect(origin: .zero, size: contentSize))
        let nextOrigin = CGPoint(
            x: currentFrame.minX,
            y: currentFrame.maxY - targetFrame.height
        )

        let nextFrame = CGRect(origin: nextOrigin, size: targetFrame.size)
        guard abs(nextFrame.width - currentFrame.width) > 1 || abs(nextFrame.height - currentFrame.height) > 1 else {
            return
        }

        window.setFrame(nextFrame, display: true, animate: false)
    }

    private func applyDeferredResize(to contentSize: CGSize) {
        pendingContentSize = contentSize

        DispatchQueue.main.async { [weak self] in
            guard let self,
                  self.pendingContentSize == contentSize,
                  let window = self.window
            else {
                return
            }

            self.resizeWindowKeepingTopLeft(window, to: contentSize)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { [weak self] in
            guard let self,
                  self.pendingContentSize == contentSize,
                  let window = self.window
            else {
                return
            }

            self.resizeWindowKeepingTopLeft(window, to: contentSize)
        }
    }
}
