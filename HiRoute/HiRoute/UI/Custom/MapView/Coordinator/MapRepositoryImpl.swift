//
//  FeedView.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import SwiftUI
import MapKit

class MapRepositoryImpl: MapRepository {
    
    func searchLocation(_ query: String, region: MKCoordinateRegion) async throws -> [MKMapItem] {
        if #available(iOS 15.0, *) {
            return try await searchLocationAsync(query, region: region)
        } else {
            return try await searchLocationLegacy(query, region: region)
        }
    }
    
    @available(iOS 15.0, *)
    private func searchLocationAsync(_ query: String, region: MKCoordinateRegion) async throws -> [MKMapItem] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = region
        
        let search = MKLocalSearch(request: request)
        let response = try await search.start()
        return response.mapItems
    }
    
    // iOS 14 이하를 위한 async/await 변환
    private func searchLocationLegacy(_ query: String, region: MKCoordinateRegion) async throws -> [MKMapItem] {
        return try await withCheckedThrowingContinuation { continuation in
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            request.region = region
            
            let search = MKLocalSearch(request: request)
            search.start { response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let response = response {
                    continuation.resume(returning: response.mapItems)
                } else {
                    continuation.resume(throwing: NSError(domain: "SearchError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No results"]))
                }
            }
        }
    }
}
