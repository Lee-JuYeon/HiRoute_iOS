//
//  FileListView.swift
//  HiRoute
//
//  Created by Jupond on 11/23/25.
//
import SwiftUI
import Combine

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
    
    
    @ViewBuilder
    private func fileViewer(_ fileModel: FileModel) -> some View {
        ZStack(alignment: .topLeading){
            Rectangle()
                .fill(Color.getColour(.label_alternative))
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
                .overlay(
                    VStack {
                        Image(systemName: getFileIcon(for: fileModel.fileType))
                            .font(.system(size: 50))
                            .foregroundColor(Color.getColour(.label_strong))
                        
                        Text("파일 미리보기")
                            .foregroundColor(Color.getColour(.label_strong))
                    }
                )
                .cornerRadius(12)
            
            
            // 파일 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(fileModel.fileName)
                    .font(.system(size: 16))
                    .foregroundColor(Color.getColour(.label_strong))
                    .fontWeight(.bold)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text("크기: \(ByteCountFormatter.string(fromByteCount: fileModel.fileSize, countStyle: .file))")
                    .font(.system(size: 14))
                    .foregroundColor(Color.getColour(.label_strong))
                    .fontWeight(.light)
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                
                Text("타입: \(fileModel.fileType.uppercased())")
                    .font(.system(size: 14))
                    .foregroundColor(Color.getColour(.label_strong))
                    .fontWeight(.light)
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
            }
            .padding(EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4))
            .background(BlurView(effect: .light))
            .cornerRadius(8)
            .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .padding(EdgeInsets(top: 0, leading: 8, bottom: 8, trailing: 8))
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
                .padding(0)
                .padding(
                    EdgeInsets(top: 0, leading: 8, bottom: 16, trailing: 8)
                )
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .center
                )
            } else {
                // iOS 13+ 호환 TabView
                if #available(iOS 14.0, *) {
                    TabView(selection: $currentIndex) {
                        ForEach(Array(fileList.enumerated()), id: \.element.id) { index, fileModel in
                            fileViewer(fileModel)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                } else {
                    // iOS 13용 대체 방법
                    VStack {
                        if currentIndex < fileList.count {
                            fileViewer(fileList[currentIndex])
                        }
                        
                        HStack {
                            Button("이전") {
                                if currentIndex > 0 {
                                    currentIndex -= 1
                                }
                            }
                            .disabled(currentIndex == 0)
                            
                            Spacer()
                            
                            Text("\(currentIndex + 1) / \(fileList.count)")
                                .font(.caption)
                            
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
        .sheet(isPresented: $presentDocumentPicker) {
            DocumentPickerView(selectedFileURL: $selectedFileURL)
        }
        .onReceive(Just(selectedFileURL)) { newURL in
            if let url = newURL,
               let fileModel = FileCacheManager.shared.saveFile(from: url) {
                fileList.append(fileModel)
                selectedFileURL = nil
            }
        }
    }
}
