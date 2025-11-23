//
//  PDFViewWrapper.swift
//  HiRoute
//
//  Created by Jupond on 11/23/25.
//
import SwiftUI
import PDFKit

struct PDFViewWrapper: UIViewRepresentable {
    let data: Data
    @Binding var scale: CGFloat
    
    init(data: Data, scale: Binding<CGFloat> = .constant(1.0)) {
        self.data = data
        self._scale = scale
    }
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayDirection = .vertical
        pdfView.displayMode = .singlePageContinuous
        pdfView.backgroundColor = UIColor.systemBackground
        
        if let document = PDFDocument(data: data) {
            pdfView.document = document
        }
        
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        if scale != 1.0 {
            uiView.scaleFactor = scale
        }
    }
}
