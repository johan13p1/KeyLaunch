import AppKit
import ApplicationServices

@MainActor
final class AppShortcutMonitor {
    static let shared = AppShortcutMonitor()

    nonisolated(unsafe) private var targetsBySourceValue: [UInt64: ShortcutTarget] = [:]
    nonisolated(unsafe) private var targetsByTriggerKeyCode: [UInt16: ShortcutTarget] = [:]
    private var localKeyDownMonitor: Any?
    private var localSystemDefinedMonitor: Any?
    private var globalKeyDownMonitor: Any?
    private var globalSystemDefinedMonitor: Any?
    private var eventTap: CFMachPort?
    private var eventTapRunLoopSource: CFRunLoopSource?

    private init() {}

    func updateMappings(_ mappings: [KeyMapping]) {
        targetsBySourceValue = Dictionary(
            uniqueKeysWithValues: mappings.compactMap { mapping in
                guard let target = ShortcutTarget(action: mapping.action) else {
                    return nil
                }

                return (mapping.source.remapSourceValue, target)
            }
        )

        targetsByTriggerKeyCode = Dictionary(
            uniqueKeysWithValues: mappings.compactMap { mapping in
                guard let target = ShortcutTarget(action: mapping.action),
                      let triggerKeyCode = mapping.source.appShortcutTriggerKeyCode
                else {
                    return nil
                }

                return (triggerKeyCode, target)
            }
        )

        if targetsBySourceValue.isEmpty {
            stop()
        } else {
            startIfNeeded()
        }
    }

    private func startIfNeeded() {
        guard localKeyDownMonitor == nil, eventTap == nil else {
            return
        }

        startEventTap()

        localKeyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handle(event) == true ? nil : event
        }

        localSystemDefinedMonitor = NSEvent.addLocalMonitorForEvents(matching: .systemDefined) { [weak self] event in
            self?.handle(event) == true ? nil : event
        }

        globalKeyDownMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            _ = self?.handle(event)
        }

        globalSystemDefinedMonitor = NSEvent.addGlobalMonitorForEvents(matching: .systemDefined) { [weak self] event in
            _ = self?.handle(event)
        }
    }

    private func stop() {
        [
            localKeyDownMonitor,
            localSystemDefinedMonitor,
            globalKeyDownMonitor,
            globalSystemDefinedMonitor
        ].compactMap { $0 }.forEach(NSEvent.removeMonitor)

        if let eventTapRunLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), eventTapRunLoopSource, .commonModes)
        }

        if let eventTap {
            CFMachPortInvalidate(eventTap)
        }

        localKeyDownMonitor = nil
        localSystemDefinedMonitor = nil
        globalKeyDownMonitor = nil
        globalSystemDefinedMonitor = nil
        eventTap = nil
        eventTapRunLoopSource = nil
    }

    private func handle(_ event: NSEvent) -> Bool {
        guard !event.isARepeat else {
            return false
        }

        guard let target = target(for: event) else {
            return false
        }

        open(target)
        return true
    }

    private func open(_ target: ShortcutTarget) {
        switch target {
        case .application(let target):
            NSWorkspace.shared.openApplication(
                at: target.url,
                configuration: NSWorkspace.OpenConfiguration()
            )
        case .website(let target):
            NSWorkspace.shared.open(target.url)
        }
    }

    private func sourceValue(for event: NSEvent) -> UInt64? {
        switch event.type {
        case .keyDown:
            return SourceKey.from(functionKeyCode: event.keyCode)?.remapSourceValue
        case .systemDefined:
            return sourceValueForSystemDefinedEvent(event)
        default:
            return nil
        }
    }

    private func target(for event: NSEvent) -> ShortcutTarget? {
        if event.type == .keyDown {
            let keyCode = event.keyCode

            if let target = targetsByTriggerKeyCode[keyCode] {
                return target
            }
        }

        guard let sourceValue = sourceValue(for: event) else {
            return nil
        }

        return targetsBySourceValue[sourceValue]
    }

    private func sourceValueForSystemDefinedEvent(_ event: NSEvent) -> UInt64? {
        sourceValueForSystemDefinedEventData(
            subtype: Int(event.subtype.rawValue),
            data1: event.data1
        )
    }

    private func startEventTap() {
        let keyDownMask = CGEventMask(1 << CGEventType.keyDown.rawValue)
        let systemDefinedMask = CGEventMask(1 << CGEventType(rawValue: 14)!.rawValue)
        let mask = keyDownMask | systemDefinedMask
        let userInfo = Unmanaged.passUnretained(self).toOpaque()

        guard let eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: { _, type, event, userInfo in
                guard let userInfo else {
                    return Unmanaged.passUnretained(event)
                }

                let monitor = Unmanaged<AppShortcutMonitor>
                    .fromOpaque(userInfo)
                    .takeUnretainedValue()

                return monitor.handleEventTapEvent(type: type, event: event)
            },
            userInfo: userInfo
        ) else {
            return
        }

        self.eventTap = eventTap
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        eventTapRunLoopSource = runLoopSource

        CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
    }

    nonisolated private func handleEventTapEvent(
        type: CGEventType,
        event: CGEvent
    ) -> Unmanaged<CGEvent>? {
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            Task { @MainActor in
                if let eventTap {
                    CGEvent.tapEnable(tap: eventTap, enable: true)
                }
            }

            return Unmanaged.passUnretained(event)
        }

        guard let target = target(for: event, type: type)
        else {
            return Unmanaged.passUnretained(event)
        }

        Task { @MainActor in
            self.open(target)
        }

        return nil
    }

    nonisolated private func sourceValue(for event: CGEvent, type: CGEventType) -> UInt64? {
        if type == .keyDown {
            guard event.getIntegerValueField(.keyboardEventAutorepeat) == 0 else {
                return nil
            }

            let keyCode = UInt16(event.getIntegerValueField(.keyboardEventKeycode))
            return SourceKey.from(functionKeyCode: keyCode)?.remapSourceValue
        }

        if type.rawValue == 14,
           let nsEvent = NSEvent(cgEvent: event) {
            return sourceValueForSystemDefinedEventData(
                subtype: Int(nsEvent.subtype.rawValue),
                data1: nsEvent.data1
            )
        }

        return nil
    }

    nonisolated private func target(for event: CGEvent, type: CGEventType) -> ShortcutTarget? {
        if type == .keyDown {
            guard event.getIntegerValueField(.keyboardEventAutorepeat) == 0 else {
                return nil
            }

            let keyCode = UInt16(event.getIntegerValueField(.keyboardEventKeycode))

            if let target = targetsByTriggerKeyCode[keyCode] {
                return target
            }
        }

        guard let sourceValue = sourceValue(for: event, type: type) else {
            return nil
        }

        return targetsBySourceValue[sourceValue]
    }

    nonisolated private func sourceValueForSystemDefinedEventData(
        subtype: Int,
        data1: Int
    ) -> UInt64? {
        guard subtype == 8 else {
            return nil
        }

        let keyType = (data1 & 0xFFFF0000) >> 16
        let keyFlags = data1 & 0x0000FFFF
        let isKeyDown = ((keyFlags & 0xFF00) >> 8) == 0x0A

        guard isKeyDown else {
            return nil
        }

        return SourceKey.from(systemKeyType: keyType)?.remapSourceValue
    }
}

private enum ShortcutTarget: Sendable {
    case application(ApplicationLaunchTarget)
    case website(WebsiteLaunchTarget)

    nonisolated init?(action: KeybindAction) {
        switch action {
        case .systemFunction:
            return nil
        case .openApplication(let target):
            self = .application(target)
        case .openWebsite(let target):
            self = .website(target)
        }
    }
}
