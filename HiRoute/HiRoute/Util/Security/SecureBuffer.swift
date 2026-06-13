//
//  SecureBuffer.swift
//  HiRoute
//
//  Created by Jupond on 3/1/26.
//

import Foundation

final class SecureBuffer {
    private var buffer: Data

    init(data: Data) {
        self.buffer = data
    }

    /// Scoped 접근 — 클로저 실행 후 자동 zeroing
    func withUnsafeBytes<T>(_ body: (Data) throws -> T) rethrows -> T {
        defer { clear() }
        return try body(buffer)
    }

    /// 명시적 메모리 zero (컴파일러 최적화 방지)
    func clear() {
        guard !buffer.isEmpty else { return }
        buffer.withUnsafeMutableBytes { ptr in
            for i in ptr.indices {
                ptr[i] = 0
            }
        }
        buffer = Data()
    }

    deinit {
        clear()
    }
}
