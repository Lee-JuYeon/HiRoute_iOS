//
//  CacheStats.swift
//  HiRoute
//
//  Created by Jupond on 12/5/25.
//

struct CacheStats {
    let totalItems: Int
    let totalCost: Int
    let hitRate: Double
    let maxSize: Int
    let utilizationRate: Double
    
    var description: String {
        return """
        📊 캐시 통계:
        • 항목: \(totalItems)개
        • 크기: \(totalCost/1024)KB / \(maxSize/1024)KB
        • 사용률: \(String(format: "%.1f", utilizationRate))%
        • 히트율: \(String(format: "%.1f", hitRate))%
        """
    }
    
    var isHealthy: Bool {
        return utilizationRate < 90 && hitRate > 50
    }
}
