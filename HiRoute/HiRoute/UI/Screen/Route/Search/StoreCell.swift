//
//  StoreCell.swift
//  HiRoute
//
//  Created by Jupond on 8/3/25.
//
import SwiftUI

// MARK: - 업소 행 뷰
struct StoreCell: View {
    let store: Store
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(store.bizesNm)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    if let branchName = store.brchNm, !branchName.isEmpty {
                        Text(branchName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(store.indsSclsNm)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(4)
                    
                    if let address = store.rdnmAdr ?? store.lnoAdr {
                        Text(address)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }
}
