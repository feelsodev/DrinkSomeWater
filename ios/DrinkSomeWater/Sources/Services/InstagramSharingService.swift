import Foundation
import SwiftUI
import UIKit
import Photos

// MARK: - Error Types

enum InstagramSharingError: Error, LocalizedError {
    case instagramNotInstalled
    case imageRenderingFailed
    case photoLibraryAccessDenied
    case photoSaveFailed
    case urlOpenFailed
    
    var errorDescription: String? {
        switch self {
        case .instagramNotInstalled:
            return "Instagram이 설치되어 있지 않습니다."
        case .imageRenderingFailed:
            return "이미지 생성에 실패했습니다."
        case .photoLibraryAccessDenied:
            return "사진 라이브러리 접근 권한이 필요합니다."
        case .photoSaveFailed:
            return "사진 저장에 실패했습니다."
        case .urlOpenFailed:
            return "Instagram을 열 수 없습니다."
        }
    }
}

// MARK: - Protocol

@MainActor
protocol InstagramSharingServiceProtocol: AnyObject {
    func isInstagramInstalled() -> Bool
    func shareToStories(record: WaterRecord, streak: Int) async throws
    func shareToFeed(record: WaterRecord, streak: Int) async throws
}

// MARK: - Implementation

@MainActor
final class InstagramSharingService: InstagramSharingServiceProtocol {
    
    // MARK: - Public Methods
    
    func isInstagramInstalled() -> Bool {
        guard let url = URL(string: "instagram://app") else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
    
    func shareToStories(record: WaterRecord, streak: Int) async throws {
        guard isInstagramInstalled() else {
            throw InstagramSharingError.instagramNotInstalled
        }
        
        let shareCardView = ShareCardView(record: record, streak: streak, style: .stories)
        
        guard let image = renderViewToImage(shareCardView) else {
            throw InstagramSharingError.imageRenderingFailed
        }
        
        guard let imageData = image.pngData() else {
            throw InstagramSharingError.imageRenderingFailed
        }
        
        let pasteboard = UIPasteboard.general
        pasteboard.setData(imageData, forPasteboardType: "com.instagram.sharedSticker.backgroundImage")
        
        guard let bundleId = Bundle.main.bundleIdentifier,
              let url = URL(string: "instagram-stories://share?source_application=\(bundleId)") else {
            throw InstagramSharingError.urlOpenFailed
        }
        
        let opened = await UIApplication.shared.open(url)
        if !opened {
            throw InstagramSharingError.urlOpenFailed
        }
    }
    
    func shareToFeed(record: WaterRecord, streak: Int) async throws {
        guard isInstagramInstalled() else {
            throw InstagramSharingError.instagramNotInstalled
        }
        
        let shareCardView = ShareCardView(record: record, streak: streak, style: .feed)
        
        guard let image = renderViewToImage(shareCardView) else {
            throw InstagramSharingError.imageRenderingFailed
        }
        
        let assetId = try await saveImageToPhotoLibrary(image)
        
        guard let url = URL(string: "instagram://library?LocalIdentifier=\(assetId)") else {
            throw InstagramSharingError.urlOpenFailed
        }
        
        let opened = await UIApplication.shared.open(url)
        if !opened {
            throw InstagramSharingError.urlOpenFailed
        }
    }
    
    // MARK: - Private Methods
    
    private func renderViewToImage<V: View>(_ view: V) -> UIImage? {
        let renderer = ImageRenderer(content: view)
        renderer.scale = 3.0
        return renderer.uiImage
    }
    
    private func saveImageToPhotoLibrary(_ image: UIImage) async throws -> String {
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        
        guard status == .authorized || status == .limited else {
            throw InstagramSharingError.photoLibraryAccessDenied
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            var localIdentifier: String?
            
            PHPhotoLibrary.shared().performChanges({
                let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                localIdentifier = request.placeholderForCreatedAsset?.localIdentifier
            }) { success, error in
                if success, let identifier = localIdentifier {
                    continuation.resume(returning: identifier)
                } else {
                    continuation.resume(throwing: InstagramSharingError.photoSaveFailed)
                }
            }
        }
    }
}
