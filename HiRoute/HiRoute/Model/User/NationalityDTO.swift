//
//  NationalityDTO.swift
//  HiRoute
//
//  Created by Jupond on 3/1/26.
//

import Foundation

struct NationalityDTO: Codable, Hashable {
    let displayName: String
    let code: String
}

extension NationalityDTO {
    static let allNationalities: [NationalityDTO] = [
        NationalityDTO(displayName: "🇰🇷 Korea", code: "KOREA"),
        NationalityDTO(displayName: "🇺🇸 USA", code: "USA"),
        NationalityDTO(displayName: "🇯🇵 Japan", code: "JAPAN"),
        NationalityDTO(displayName: "🇹🇼 Taiwan", code: "TAIWAN"),
        NationalityDTO(displayName: "🇭🇰 Hong Kong", code: "HONGKONG"),
        NationalityDTO(displayName: "🇬🇧 UK", code: "UK"),
        NationalityDTO(displayName: "🇫🇷 France", code: "FRANCE"),
        NationalityDTO(displayName: "🇩🇪 Germany", code: "GERMANY"),
        NationalityDTO(displayName: "🇹🇭 Thailand", code: "THAILAND"),
        NationalityDTO(displayName: "🇻🇳 Vietnam", code: "VIETNAM"),
        NationalityDTO(displayName: "🇵🇭 Philippines", code: "PHILIPPINES"),
        NationalityDTO(displayName: "🇮🇩 Indonesia", code: "INDONESIA"),
        NationalityDTO(displayName: "🇮🇳 India", code: "INDIA"),
        NationalityDTO(displayName: "🇧🇷 Brazil", code: "BRAZIL"),
        NationalityDTO(displayName: "🇦🇺 Australia", code: "AUSTRALIA"),
        NationalityDTO(displayName: "🇨🇦 Canada", code: "CANADA"),
        NationalityDTO(displayName: "🏳️ Other", code: "OTHER"),
    ]
}
