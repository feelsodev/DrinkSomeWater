import SwiftUI
import UIKit
import GoogleMobileAds

struct NativeAdViewRepresentable: UIViewRepresentable {
  let nativeAd: GADNativeAd
  
  func makeUIView(context: Context) -> GADNativeAdView {
    let nativeAdView = GADNativeAdView()
    nativeAdView.backgroundColor = .white
    nativeAdView.layer.cornerRadius = 16
    nativeAdView.layer.shadowColor = UIColor.black.cgColor
    nativeAdView.layer.shadowOpacity = 0.08
    nativeAdView.layer.shadowOffset = CGSize(width: 0, height: 2)
    nativeAdView.layer.shadowRadius = 8
    nativeAdView.clipsToBounds = false
    
    let containerView = UIView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    nativeAdView.addSubview(containerView)
    
    NSLayoutConstraint.activate([
      containerView.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: 12),
      containerView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: 12),
      containerView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: -12),
      containerView.bottomAnchor.constraint(equalTo: nativeAdView.bottomAnchor, constant: -12)
    ])
    
    let adBadge = UILabel()
    adBadge.text = "AD"
    adBadge.font = .systemFont(ofSize: 10, weight: .bold)
    adBadge.textColor = .white
    adBadge.backgroundColor = DS.Color.primary.withAlphaComponent(0.8)
    adBadge.layer.cornerRadius = 4
    adBadge.clipsToBounds = true
    adBadge.textAlignment = .center
    adBadge.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(adBadge)
    
    let iconImageView = UIImageView()
    iconImageView.contentMode = .scaleAspectFill
    iconImageView.layer.cornerRadius = 8
    iconImageView.clipsToBounds = true
    iconImageView.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(iconImageView)
    nativeAdView.iconView = iconImageView
    
    let headlineLabel = UILabel()
    headlineLabel.font = .systemFont(ofSize: 14, weight: .semibold)
    headlineLabel.textColor = DS.Color.textPrimary
    headlineLabel.numberOfLines = 2
    headlineLabel.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(headlineLabel)
    nativeAdView.headlineView = headlineLabel
    
    let bodyLabel = UILabel()
    bodyLabel.font = .systemFont(ofSize: 12, weight: .regular)
    bodyLabel.textColor = DS.Color.textSecondary
    bodyLabel.numberOfLines = 2
    bodyLabel.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(bodyLabel)
    nativeAdView.bodyView = bodyLabel
    
    let ctaButton = UIButton(type: .system)
    ctaButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
    ctaButton.setTitleColor(.white, for: .normal)
    ctaButton.backgroundColor = DS.Color.primary
    ctaButton.layer.cornerRadius = 12
    ctaButton.isUserInteractionEnabled = false
    ctaButton.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(ctaButton)
    nativeAdView.callToActionView = ctaButton
    
    NSLayoutConstraint.activate([
      adBadge.topAnchor.constraint(equalTo: containerView.topAnchor),
      adBadge.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      adBadge.widthAnchor.constraint(equalToConstant: 24),
      adBadge.heightAnchor.constraint(equalToConstant: 16),
      
      iconImageView.topAnchor.constraint(equalTo: adBadge.bottomAnchor, constant: 8),
      iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      iconImageView.widthAnchor.constraint(equalToConstant: 40),
      iconImageView.heightAnchor.constraint(equalToConstant: 40),
      
      headlineLabel.topAnchor.constraint(equalTo: adBadge.bottomAnchor, constant: 8),
      headlineLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 10),
      headlineLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      
      bodyLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 4),
      bodyLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 10),
      bodyLabel.trailingAnchor.constraint(equalTo: ctaButton.leadingAnchor, constant: -8),
      
      ctaButton.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
      ctaButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      ctaButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
      ctaButton.heightAnchor.constraint(equalToConstant: 28)
    ])
    
    return nativeAdView
  }
  
  func updateUIView(_ nativeAdView: GADNativeAdView, context: Context) {
    (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
    (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
    (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
    (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
    
    nativeAdView.nativeAd = nativeAd
  }
}

struct NativeAdCard: View {
  let nativeAd: GADNativeAd
  
  var body: some View {
    NativeAdViewRepresentable(nativeAd: nativeAd)
      .frame(height: 90)
  }
}
