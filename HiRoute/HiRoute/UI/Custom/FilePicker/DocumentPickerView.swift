//
//  DocumentPickerView.swift
//  HiRoute
//
//  Created by Jupond on 11/23/25.
//
import SwiftUI
import MobileCoreServices

struct DocumentPickerView: UIViewControllerRepresentable {
    @Binding var selectedFileURL: URL?
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        if #available(iOS 14.0, *) {
            let picker = UIDocumentPickerViewController(forOpeningContentTypes: [
                .pdf, .image, .text, .data
            ])
            picker.delegate = context.coordinator
            picker.allowsMultipleSelection = false
            return picker
        } else {
            let picker = UIDocumentPickerViewController(documentTypes: [
                "com.adobe.pdf",
                "public.image",
                "public.text",
                "public.data"
            ], in: .import)
            picker.delegate = context.coordinator
            picker.allowsMultipleSelection = false
            return picker
        }
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPickerView
        
        init(_ parent: DocumentPickerView) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.selectedFileURL = urls.first
        }
    }
}
