//
//  PrivacyPolicyView.swift
//  HiRoute
//
//  Created by Jupond on 5/6/26.
//

import SwiftUI

struct PrivacyPolicyView: View {
    let termTitle: String
    let termId: Int
    let onDismiss: () -> Void

    var body: some View {
        PolicyDetailView(termTitle: termTitle, termId: termId, onDismiss: onDismiss)
    }
}
