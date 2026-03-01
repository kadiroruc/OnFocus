import Foundation
import Network

final class NetworkMonitor {
    static let shared = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.onfocus.network.monitor")
    private var isMonitoring = false
    private(set) var isConnected: Bool = true

    private init() {}

    func start() {
        guard !isMonitoring else { return }
        isMonitoring = true
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            let connected = path.status == .satisfied
            if self.isConnected != connected {
                self.isConnected = connected
                NotificationCenter.default.post(
                    name: .networkStatusChanged,
                    object: nil,
                    userInfo: ["isConnected": connected]
                )
            }
        }
        monitor.start(queue: queue)
    }

    func stop() {
        guard isMonitoring else { return }
        monitor.cancel()
        isMonitoring = false
    }
}
