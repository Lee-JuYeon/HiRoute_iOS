//
//  BlurView.swift
//  HiRoute
//
//  Created by Jupond on 7/3/25.
//

import SwiftUI

struct BlurView : UIViewRepresentable {
    var effect : UIBlurEffect.Style
    func makeUIView (context : Context) -> UIVisualEffectView{
        let blurEffect = UIBlurEffect(style: effect)
        let blurView = UIVisualEffectView(effect: blurEffect)
        return blurView
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        
    }
}
