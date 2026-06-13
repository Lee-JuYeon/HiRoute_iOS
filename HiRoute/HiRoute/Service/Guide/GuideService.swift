//
//  GuideService.swift
//  HiRoute
//
//  Created by Jupond on 4/7/26.
//
import Combine

class GuideService {
    private let guideProtocol: GuideProtocol

    init(guideProtocol: GuideProtocol) {
        self.guideProtocol = guideProtocol
    }

    func readGuides(placeUid: String) -> AnyPublisher<[GuideItem], Error> {
        guideProtocol.readGuides(placeUid: placeUid)
    }
}
