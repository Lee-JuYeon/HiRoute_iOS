//
//  ContentBlock.swift
//  HiRoute
//
//  Created by Jupond on 5/6/26.
//

enum ContentBlock: Codable, Hashable {
    case text(body: String)
    case image(url: String, caption: String?)
    case audio(url: String, duration: Int, transcript: String?)
    case list(items: [ListItem])
    case price(items: [PriceModel])

    // Custom Codable with "type" discriminator
    enum CodingKeys: String, CodingKey {
        case type, body, url, caption, duration, transcript, items
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "text":
            let body = try container.decode(String.self, forKey: .body)
            self = .text(body: body)
        case "image":
            let url = try container.decode(String.self, forKey: .url)
            let caption = try container.decodeIfPresent(String.self, forKey: .caption)
            self = .image(url: url, caption: caption)
        case "audio":
            let url = try container.decode(String.self, forKey: .url)
            let duration = try container.decode(Int.self, forKey: .duration)
            let transcript = try container.decodeIfPresent(String.self, forKey: .transcript)
            self = .audio(url: url, duration: duration, transcript: transcript)
        case "list":
            let items = try container.decode([ListItem].self, forKey: .items)
            self = .list(items: items)
        case "price":
            let items = try container.decode([PriceModel].self, forKey: .items)
            self = .price(items: items)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown block type: \(type)")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .text(let body):
            try container.encode("text", forKey: .type)
            try container.encode(body, forKey: .body)
        case .image(let url, let caption):
            try container.encode("image", forKey: .type)
            try container.encode(url, forKey: .url)
            try container.encodeIfPresent(caption, forKey: .caption)
        case .audio(let url, let duration, let transcript):
            try container.encode("audio", forKey: .type)
            try container.encode(url, forKey: .url)
            try container.encode(duration, forKey: .duration)
            try container.encodeIfPresent(transcript, forKey: .transcript)
        case .list(let items):
            try container.encode("list", forKey: .type)
            try container.encode(items, forKey: .items)
        case .price(let items):
            try container.encode("price", forKey: .type)
            try container.encode(items, forKey: .items)
        }
    }
}
