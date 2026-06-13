//
//  GuideProtocol.swift
//  HiRoute
//
//  Created by Jupond on 4/7/26.
//
import Combine

protocol GuideProtocol {
    func readGuides(placeUid: String) -> AnyPublisher<[GuideItem], Error>
}
