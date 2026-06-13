//
//  PlaceModel.swift
//  HiRoute
//
//  Created by Jupond on 7/20/25.
//
import SwiftUI
import CoreLocation

struct PlaceModel: Codable, Identifiable, Hashable {
    var id: String { uid }
    let uid: String
    let address: AddressModel
    let type: PlaceType
    var subtype: String? = nil
    var typeDisplayText: String? = nil
    var subtypeDisplayText: String? = nil
    let title: String
    var subtitle: String? = nil
    var thumbnailImage: ImageModel? = nil
    var workingTimes: [WorkingTimeModel]? = nil
    var reviews: [ReviewModel]? = nil
    var bookMarks: [BookMarkModel]? = nil
    var stars: [StarModel]? = nil
    var placeImages: [ImageModel]? = nil

    var iconName: String {
        switch type {
        case .hospital: return "cross.fill"
        case .store: return "cart.fill"
        case .restaurant: return "fork.knife"
        case .cafe: return "cup.and.saucer.fill"
        case .park: return "leaf.fill"
        case .theater: return "film.fill"
        case .hotel: return "bed.double.fill"
        case .school: return "book.fill"
        case .landmark: return "flag.fill"
        case .temple: return "house.fill"
        case .pharmacy: return "staroflife.fill"
        }
    }

    var iconColor: Color {
        switch type {
        case .hospital: return .red
        case .store: return .blue
        case .restaurant: return .orange
        case .cafe: return .purple
        case .park: return .green
        case .theater: return .pink
        case .hotel: return .blue
        case .school: return .yellow
        case .landmark: return .gray
        case .temple: return .orange
        case .pharmacy: return .green
        }
    }
}

extension PlaceModel {
    static func empty() -> PlaceModel {
        return PlaceModel(
            uid: "",
            address: .empty(),
            type: .restaurant,
            title: ""
        )
    }
}
