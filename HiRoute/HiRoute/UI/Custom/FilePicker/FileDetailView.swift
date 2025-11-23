//
//  FileDetailView.swift
//  HiRoute
//
//  Created by Jupond on 11/23/25.
//
import SwiftUI

struct FileDetailView: View {
    let fileModel: FileModel
    @Binding var isPresented: Bool
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 상단 바
                topBar()
                
                // 파일 내용
                fileContentView()
                    .clipped()
            }
        }
    }
    
    @ViewBuilder
    private func topBar() -> some View {
        HStack {
            // 닫기 버튼
            Button(action: {
                isPresented = false
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.black.opacity(0.3))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            // 파일 이름
            Text(fileModel.fileName)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .lineLimit(1)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            // 다운로드 버튼
            Button(action: {
                downloadFile()
            }) {
                Image(systemName: "square.and.arrow.down")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.black.opacity(0.3))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.7), Color.clear]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 100)
        )
    }
    
    @ViewBuilder
    private func fileContentView() -> some View {
        let fileType = fileModel.fileType.lowercased()
        
        switch fileType {
        case "pdf":
            if let data = FileCacheManager.shared.loadFile(fileModel: fileModel) {
                PDFViewWrapper(data: data, scale: $scale)
            } else {
                errorView()
            }
            
        case "jpg", "jpeg", "png", "gif":
            if let data = FileCacheManager.shared.loadFile(fileModel: fileModel) {
                ImageViewer(data: data, scale: $scale, offset: $offset)
            } else {
                errorView()
            }
            
        case "txt":
            if let data = FileCacheManager.shared.loadFile(fileModel: fileModel),
               let text = String(data: data, encoding: .utf8) {
                ScrollView {
                    Text(text)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.white)
                        .padding()
                }
            } else {
                errorView()
            }
            
        default:
            unsupportedFileView()
        }
    }
    
    private func errorView() -> some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            Text("파일을 불러올 수 없습니다")
                .foregroundColor(.white)
        }
    }
    
    private func unsupportedFileView() -> some View {
        VStack {
            Image(systemName: "doc")
                .font(.system(size: 50))
                .foregroundColor(.white)
            Text("미리보기를 지원하지 않는 파일 형식입니다")
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
    }
    
    private func downloadFile() {
        guard let data = FileCacheManager.shared.loadFile(fileModel: fileModel) else { return }
        
        let activityVC = UIActivityViewController(
            activityItems: [data],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = window
                popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            rootViewController.present(activityVC, animated: true)
        }
    }
}
