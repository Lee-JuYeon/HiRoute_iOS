//
//  FileListView.swift
//  HiRoute
//
//  Created by Jupond on 11/23/25.
//
import SwiftUI
import Combine
import PDFKit

struct FileListView: View {
    
    @Binding private var presentDocumentPicker : Bool
    
    init(
        isPresentDocumentPicker : Binding<Bool>
    ){
        self._presentDocumentPicker = isPresentDocumentPicker
    }
    
    @State private var fileList: [FileModel] = []
    @State private var currentIndex = 0
    @State private var selectedFileURL: URL?
    @State private var showFileDetail = false
    @State private var selectedFileModel: FileModel?
       
    
    @ViewBuilder
    private func fileContentView(_ fileModel: FileModel) -> some View {
        let fileType = fileModel.fileType.lowercased()
        
        switch fileType {
        case "pdf":
            if let data = FileCacheManager.shared.loadFile(fileModel: fileModel) {
                PDFViewWrapper(data: data) // scale 파라미터 제거 (기본값 사용)
                    .cornerRadius(12)
            } else {
                defaultFileIcon(fileModel.fileType)
            }
        case "jpg", "jpeg", "png", "gif":
            if let data = FileCacheManager.shared.loadFile(fileModel: fileModel),
               let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .cornerRadius(12)
            } else {
                defaultFileIcon(fileModel.fileType)
            }
        case "txt":
            if let data = FileCacheManager.shared.loadFile(fileModel: fileModel),
               let text = String(data: data, encoding: .utf8) {
                VStack {
                    Text(text.prefix(100) + (text.count > 100 ? "..." : ""))
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(Color.getColour(.label_normal))
                        .multilineTextAlignment(.leading)
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity,
                            alignment: .topLeading
                        )
                        .padding(8)
                }
                .background(Color.getColour(.fill_alternative))
                .cornerRadius(12)
            } else {
                defaultFileIcon(fileModel.fileType)
            }
        default:
            defaultFileIcon(fileModel.fileType)
        }
    }
    
    @ViewBuilder
    private func defaultFileIcon(_ fileType: String) -> some View {
        VStack {
            Image(systemName: getFileIcon(for: fileType))
                .font(.system(size: 40))
                .foregroundColor(Color.getColour(.label_strong))
            Text(fileType.uppercased())
                .font(.caption)
                .foregroundColor(Color.getColour(.label_alternative))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.getColour(.fill_alternative))
        .cornerRadius(12)
    }
    
    
    @ViewBuilder
    private func fileViewer(_ fileModel: FileModel) -> some View {
        VStack(spacing: 8) {
            // 파일 내용 미리보기
            fileContentView(fileModel)
                .frame(height: 200) // 고정 높이 설정
                .onTapGesture {
                    selectedFileModel = fileModel
                    showFileDetail = true
                }
            
            HStack(alignment: .center, spacing: 0) {
                // 파일 정보
                VStack(alignment: .leading, spacing: 4) {
                    Text(fileModel.fileName)
                        .font(.system(size: 16))
                        .foregroundColor(Color.getColour(.label_strong))
                        .fontWeight(.bold)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Text("크기: \(ByteCountFormatter.string(fromByteCount: fileModel.fileSize, countStyle: .file))")
                            .font(.system(size: 12))
                            .foregroundColor(Color.getColour(.label_alternative))
                        
                        Text(fileModel.fileType.uppercased())
                            .font(.system(size: 12))
                            .foregroundColor(Color.getColour(.label_alternative))
                            .padding(.horizontal, 6)
                    }
                }
                
                Spacer()
                
                // 삭제버튼
                Button(action: {
                    deleteFile(fileModel)
                }) {
                    Image(systemName: "trash")
                        .renderingMode(.template)
                        .font(.system(size: 16))
                        .foregroundColor(Color.getColour(.status_destructive))
                        .frame(width: 32, height: 32)
                        .background(Color.getColour(.status_destructive).opacity(0.1))
                        .clipShape(Circle())
                }
            }
        }
        .padding(
            EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10)
        )
    }
    
    private func deleteFile(_ fileModel: FileModel) {
        FileCacheManager.shared.deleteFile(fileModel: fileModel)
        fileList.removeAll { $0.id == fileModel.id }
        if currentIndex >= fileList.count && !fileList.isEmpty {
            currentIndex = fileList.count - 1
        }
    }
    
    private func getFileIcon(for fileType: String) -> String {
        switch fileType.lowercased() {
        case "pdf":
            return "doc.text"
        case "jpg", "jpeg", "png", "gif":
            return "photo"
        case "txt":
            return "doc.plaintext"
        default:
            return "doc"
        }
    }
    
    var body: some View {
        VStack {
            if fileList.isEmpty {
                VStack(alignment: .center, spacing: 16) {
                    Image(systemName: "folder")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("추가된 파일이 없습니다")
                        .foregroundColor(.gray)
                        .font(.body)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                VStack {
                    // 파일 네비게이션
                    if fileList.count > 1 {
                        Text("\(currentIndex + 1) / \(fileList.count)")
                            .font(.caption)
                            .foregroundColor(Color.getColour(.label_alternative))
                    }
                    
                    // 파일 뷰어
                    if #available(iOS 14.0, *) {
                        TabView(selection: $currentIndex) {
                            ForEach(Array(fileList.enumerated()), id: \.element.id) { index, fileModel in
                                fileViewer(fileModel)
                                    .tag(index)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    } else {
                        VStack {
                            if currentIndex < fileList.count {
                                fileViewer(fileList[currentIndex])
                            }
                            
                            if fileList.count > 1 {
                                HStack {
                                    Button("이전") {
                                        if currentIndex > 0 {
                                            currentIndex -= 1
                                        }
                                    }
                                    .disabled(currentIndex == 0)
                                    
                                    Spacer()
                                    
                                    Button("다음") {
                                        if currentIndex < fileList.count - 1 {
                                            currentIndex += 1
                                        }
                                    }
                                    .disabled(currentIndex == fileList.count - 1)
                                }
                                .padding()
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $presentDocumentPicker) {
            DocumentPickerView(selectedFileURL: $selectedFileURL)
        }
        .fullScreenCover(item: $selectedFileModel) { fileModel in
            FileDetailView(
                fileModel: fileModel,
                isPresented: Binding(
                    get: { selectedFileModel != nil },
                    set: { _ in selectedFileModel = nil }
                )
            )
        }
        .onReceive(Just(selectedFileURL)) { newURL in
            if let url = newURL,
               let fileModel = FileCacheManager.shared.saveFile(from: url) {
                fileList.append(fileModel)
                currentIndex = fileList.count - 1
                selectedFileURL = nil
            }
        }
    }
}



