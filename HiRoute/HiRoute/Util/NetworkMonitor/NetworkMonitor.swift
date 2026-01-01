//
//  NetworkMonitor.swift
//  HiRoute
//
//  Created by Jupond on 12/5/25.
//
import Network

class NetworkMonitor {

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitoring")
    
    var networkStatus: NetworkStatus = .offline
    var connectionType: ConnectionType = .unknown

    func startMonitoring(handler: @escaping (NetworkStatus, ConnectionType) -> Void) {
        monitor.pathUpdateHandler = { path in
            // NWPath.Status를 NetworkStatus로 매핑
            switch path.status {
            case .satisfied:
                self.networkStatus = .connected
            case .unsatisfied:
                self.networkStatus = .offline
            case .requiresConnection:
                self.networkStatus = .connecting  // 연결 시도 중
            @unknown default:
                self.networkStatus = .offline
            }
            
            if path.usesInterfaceType(.wifi) {
                self.connectionType = .wifi
            } else if path.usesInterfaceType(.cellular) {
                self.connectionType = .cellular
            } else {
                self.connectionType = .unknown
            }
            
            DispatchQueue.main.async {
                handler(self.networkStatus, self.connectionType)
            }
        }
        
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
    
    // 현재 네트워크 상태 즉시 반환
    func getCurrentStatus() -> (networkStatus: NetworkStatus, connectionType: ConnectionType) {
        return (networkStatus, connectionType)
    }
       
    
    var isConnected: Bool {
        return networkStatus == .connected
    }
    
    var isConnecting: Bool {
        return networkStatus == .connecting
    }
    
    var isOffline: Bool {
        return networkStatus == .offline
    }
    
    // 메모리 누수 방지
    deinit {
        stopMonitoring()
    }
}
