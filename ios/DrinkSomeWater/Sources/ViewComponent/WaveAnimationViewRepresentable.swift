import SwiftUI
import UIKit

struct WaveAnimationViewRepresentable: UIViewRepresentable {
  let color: UIColor
  let progress: Float
  let backgroundColor: UIColor?
  let cornerRadius: CGFloat
  let borderWidth: CGFloat
  let borderColor: UIColor?
  
  init(
    color: UIColor,
    progress: Float,
    backgroundColor: UIColor? = nil,
    cornerRadius: CGFloat = 0,
    borderWidth: CGFloat = 0,
    borderColor: UIColor? = nil
  ) {
    self.color = color
    self.progress = progress
    self.backgroundColor = backgroundColor
    self.cornerRadius = cornerRadius
    self.borderWidth = borderWidth
    self.borderColor = borderColor
  }
  
  func makeUIView(context: Context) -> WaveAnimationView {
    let view = WaveAnimationView(frame: .zero, color: color)
    view.backgroundColor = backgroundColor
    view.layer.cornerRadius = cornerRadius
    view.layer.cornerCurve = .continuous
    view.layer.borderWidth = borderWidth
    view.layer.borderColor = borderColor?.cgColor
    view.layer.masksToBounds = true
    view.setProgress(progress)
    view.startAnimation()
    return view
  }
  
  func updateUIView(_ uiView: WaveAnimationView, context: Context) {
    uiView.setProgress(progress)
    uiView.updateFrame(uiView.bounds)
  }
  
  static func dismantleUIView(_ uiView: WaveAnimationView, coordinator: ()) {
    uiView.stopAnimation()
  }
}
