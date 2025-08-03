//
//  StoreListView.swift
//  HiRoute
//
//  Created by Jupond on 8/3/25.
//
import SwiftUI

struct StoreListView: View {
    let stores: [Store]
    let onStoreSelect: (Store) -> Void
    let onClose: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 헤더
            HStack {
                Text("주변 업소 \(stores.count)곳")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("닫기") {
                    onClose()
                }
                .foregroundColor(.blue)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            
            // 리스트
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(stores, id: \.bizesId) { store in
                        StoreCell(store: store) {
                            onStoreSelect(store)
                        }
                        
                        if store.bizesId != stores.last?.bizesId {
                            Divider()
                        }
                    }
                }
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 5)
        .frame(maxHeight: 200)
    }
}
