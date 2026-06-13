//
//  PriceDetailSheet.swift
//  HiRoute
//
//  Created by Jupond on 4/7/26.
//
import SwiftUI

struct PriceDetailSheet: View {
    let priceItem: PriceModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title
            Text(priceItem.label)
                .font(.title3)
                .fontWeight(.bold)
                .padding(.top, 8)

            // Receipt
            VStack(spacing: 8) {
                // Base price
                HStack {
                    Text("입장료")
                        .font(.subheadline)
                    Spacer()
                    Text(priceItem.displayBasePrice)
                        .font(.subheadline)
                }

                // Discounts
                if let discounts = priceItem.discounts {
                    ForEach(Array(discounts.enumerated()), id: \.offset) { _, discount in
                        HStack {
                            HStack(spacing: 4) {
                                Text(discount.name)
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                                if let period = discount.period {
                                    Text("(\(period))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                            Text("\(PriceDetailSheet.formatNumber(discount.amount))원")
                                .font(.subheadline)
                                .foregroundColor(.red)
                        }
                    }
                }

                Divider()

                // Total
                HStack {
                    Text("합계")
                        .font(.subheadline)
                        .fontWeight(.bold)
                    Spacer()
                    Text(priceItem.displayPrice)
                        .font(.subheadline)
                        .fontWeight(.bold)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)

            // Notes
            if let notes = priceItem.notes, !notes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("참고")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    ForEach(notes, id: \.self) { note in
                        HStack(alignment: .top, spacing: 6) {
                            Text("·")
                            Text(note)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }

            Spacer()
        }
        .padding(.horizontal)
    }

    private static let numberFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        return f
    }()

    static func formatNumber(_ value: Int) -> String {
        numberFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
