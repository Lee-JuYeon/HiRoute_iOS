//
//  PhotoGridPickerView.swift
//  HiRoute
//
//  Created by Jupond on 3/2/26.
//

import SwiftUI
import Photos

/// 인스타그램 스타일 커스텀 포토 그리드 피커.
/// 포토 라이브러리에서 다중 이미지 선택. 선택 순서가 번호로 표시됨.
/// iOS 14 호환 (PHAsset, PHImageManager, LazyVGrid 모두 iOS 14+).
struct PhotoGridPickerView: View {
    let onComplete: ([(UIImage, Bool)]) -> Void
    @Environment(\.presentationMode) private var presentationMode

    @State private var assets: [PHAsset] = []
    @State private var selectedAssetIDs: [String] = []
    @State private var aiAssetIDs: Set<String> = []
    @State private var authStatus: PHAuthorizationStatus = .notDetermined
    @State private var isExporting: Bool = false
    @State private var pendingAsset: PHAsset? = nil
    @State private var showAIAlert: Bool = false

    private let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]

    // MARK: - Toolbar

    @ViewBuilder
    private func toolbar() -> some View {
        HStack(alignment: .center) {
            Image(systemName: "xmark")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color.getColour(.label_strong))
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
                .onTapGesture {
                    presentationMode.wrappedValue.dismiss()
                }

            Spacer()

            Text("사진 선택")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color.getColour(.label_strong))

            Spacer()

            if selectedAssetIDs.isEmpty {
                Color.clear.frame(width: 44, height: 44)
            } else {
                Text("초기화")
                    .font(.system(size: 14))
                    .foregroundColor(Color.getColour(.label_alternative))
                    .frame(height: 44)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedAssetIDs.removeAll()
                        aiAssetIDs.removeAll()
                    }
            }
        }
        .padding(.horizontal, 8)
    }

    // MARK: - Grid

    @ViewBuilder
    private func photoGrid() -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(assets, id: \.localIdentifier) { asset in
                    PhotoGridCell(
                        asset: asset,
                        selectionIndex: selectionIndex(for: asset),
                        onTap: { toggleSelection(asset) }
                    )
                }
            }
        }
    }

    // MARK: - Bottom Bar

    @ViewBuilder
    private func bottomBar() -> some View {
        HStack {
            Text("\(selectedAssetIDs.count)장 선택됨")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.getColour(.label_normal))

            Spacer()

            Image(systemName: "arrow.right")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color.getColour(.background_white))
                .frame(width: 44, height: 44)
                .background(Circle().fill(Color.getColour(.label_strong)))
                .contentShape(Circle())
                .onTapGesture { confirmSelection() }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    // MARK: - Permission Denied

    @ViewBuilder
    private func permissionDeniedView() -> some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 48))
                .foregroundColor(Color.getColour(.label_alternative))

            Text("사진 접근 권한이 필요합니다")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color.getColour(.label_normal))

            Text("설정에서 사진 접근을 허용해주세요")
                .font(.system(size: 14))
                .foregroundColor(Color.getColour(.label_alternative))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                toolbar()

                if authStatus == .authorized || authStatus == .limited {
                    photoGrid()
                } else if authStatus == .denied || authStatus == .restricted {
                    permissionDeniedView()
                } else {
                    Spacer()
                    ProgressView()
                    Spacer()
                }

                if !selectedAssetIDs.isEmpty {
                    bottomBar()
                }
            }

            if isExporting {
                Color.getColour(.material_dimmer)
                    .ignoresSafeArea()
                ProgressView()
                    .scaleEffect(1.2)
            }
        }
        .background(Color.getColour(.background_white).ignoresSafeArea())
        .onAppear { requestAccess() }
        .alert(isPresented: $showAIAlert) {
            Alert(
                title: Text("AI 생성 이미지"),
                message: Text("이 사진은 AI로 생성된 이미지인가요?"),
                primaryButton: .default(Text("네")) {
                    if let asset = pendingAsset {
                        selectedAssetIDs.append(asset.localIdentifier)
                        aiAssetIDs.insert(asset.localIdentifier)
                    }
                    pendingAsset = nil
                },
                secondaryButton: .default(Text("아니요")) {
                    if let asset = pendingAsset {
                        selectedAssetIDs.append(asset.localIdentifier)
                    }
                    pendingAsset = nil
                }
            )
        }
    }

    // MARK: - Logic

    private func selectionIndex(for asset: PHAsset) -> Int? {
        guard let index = selectedAssetIDs.firstIndex(of: asset.localIdentifier) else { return nil }
        return index + 1
    }

    private func toggleSelection(_ asset: PHAsset) {
        let id = asset.localIdentifier
        if let index = selectedAssetIDs.firstIndex(of: id) {
            selectedAssetIDs.remove(at: index)
            aiAssetIDs.remove(id)
        } else {
            pendingAsset = asset
            showAIAlert = true
        }
    }

    private func requestAccess() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    self.authStatus = newStatus
                    if newStatus == .authorized || newStatus == .limited {
                        loadAssets()
                    }
                }
            }
        } else {
            authStatus = status
            if status == .authorized || status == .limited {
                loadAssets()
            }
        }
    }

    private func loadAssets() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        let results = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        var fetched: [PHAsset] = []
        fetched.reserveCapacity(results.count)
        results.enumerateObjects { asset, _, _ in
            fetched.append(asset)
        }
        assets = fetched
    }

    private func confirmSelection() {
        let selectedAssets = selectedAssetIDs.compactMap { id in
            assets.first { $0.localIdentifier == id }
        }
        guard !selectedAssets.isEmpty else { return }

        isExporting = true

        let group = DispatchGroup()
        var results: [(Int, UIImage, Bool)] = []
        let lock = NSLock()

        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true

        let exportSize = CGSize(width: 1080, height: 1080)

        for (index, asset) in selectedAssets.enumerated() {
            let isAI = aiAssetIDs.contains(asset.localIdentifier)
            group.enter()
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: exportSize,
                contentMode: .aspectFit,
                options: options
            ) { image, _ in
                if let image = image {
                    lock.lock()
                    results.append((index, image, isAI))
                    lock.unlock()
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.isExporting = false
            let sorted = results.sorted { $0.0 < $1.0 }.map { ($0.1, $0.2) }
            self.onComplete(sorted)
            self.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - PhotoGridCell

