import Foundation
import SwiftUI
import UIKit
import Analytics

// MARK: - Error Types

enum SocialSharingError: Error, LocalizedError {
    case imageRenderingFailed
    case activityViewControllerFailed
    
    var errorDescription: String? {
        switch self {
        case .imageRenderingFailed:
            return "이미지 생성에 실패했습니다."
        case .activityViewControllerFailed:
            return "공유 시트를 열 수 없습니다."
        }
    }
}

// MARK: - Protocol

@MainActor
protocol SocialSharingServiceProtocol: AnyObject {
    func shareViaSystemSheet(record: WaterRecord, streak: Int, source: InstagramShareSource, from viewController: UIViewController) async throws
}

// MARK: - Implementation

@MainActor
final class SocialSharingService: SocialSharingServiceProtocol {
    
    // MARK: - Public Methods
    
    func shareViaSystemSheet(record: WaterRecord, streak: Int, source: InstagramShareSource, from viewController: UIViewController) async throws {
        let shareCardView = ShareCardView(record: record, streak: streak, style: .feed)
        
        guard let image = renderViewToImage(shareCardView) else {
            throw SocialSharingError.imageRenderingFailed
        }
        
        let activityViewController = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        
        // Configure activity view controller
        activityViewController.excludedActivityTypes = [
            .saveToCameraRoll,
            .print
        ]
        
        // Present on iPad
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = viewController.view
            popoverController.sourceRect = CGRect(
                x: viewController.view.bounds.midX,
                y: viewController.view.bounds.midY,
                width: 0,
                height: 0
            )
            popoverController.permittedArrowDirections = []
        }
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            activityViewController.completionWithItemsHandler = { _, completed, _, error in
                if let error = error {
                    Analytics.shared.log(.systemShareFailed(source: source, reason: error.localizedDescription))
                    continuation.resume(throwing: error)
                } else if completed {
                    Analytics.shared.log(.systemShareCompleted(source: source))
                    continuation.resume()
                } else {
                    Analytics.shared.log(.systemShareCancelled(source: source))
                    continuation.resume()
                }
            }
            viewController.present(activityViewController, animated: true)
        }
    }
    
    // MARK: - Private Methods
    
    private func renderViewToImage<V: View>(_ view: V) -> UIImage? {
        let renderer = ImageRenderer(content: view)
        renderer.scale = 3.0
        return renderer.uiImage
    }
}
