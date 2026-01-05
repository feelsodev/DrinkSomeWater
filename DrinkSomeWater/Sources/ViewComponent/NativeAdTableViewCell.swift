import UIKit
import GoogleMobileAds
import SnapKit

final class NativeAdTableViewCell: UITableViewCell {
  
  static let cellID = "NativeAdTableViewCell"
  
  private var nativeAdView: GADNativeAdView?
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    backgroundColor = .clear
    selectionStyle = .none
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(with nativeAd: GADNativeAd) {
    nativeAdView?.removeFromSuperview()
    
    let adView = createNativeAdView()
    contentView.addSubview(adView)
    adView.snp.makeConstraints {
      $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
    }
    
    (adView.iconView as? UIImageView)?.image = nativeAd.icon?.image
    (adView.headlineView as? UILabel)?.text = nativeAd.headline
    (adView.bodyView as? UILabel)?.text = nativeAd.body
    (adView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
    
    adView.nativeAd = nativeAd
    nativeAdView = adView
  }
  
  private func createNativeAdView() -> GADNativeAdView {
    let nativeAdView = GADNativeAdView()
    nativeAdView.backgroundColor = .white
    nativeAdView.layer.cornerRadius = 16
    nativeAdView.layer.shadowColor = DS.Color.primary.withAlphaComponent(0.4).cgColor
    nativeAdView.layer.shadowOpacity = 0.2
    nativeAdView.layer.shadowOffset = CGSize(width: 0, height: 4)
    nativeAdView.layer.shadowRadius = 8
    
    let adBadge = UILabel()
    adBadge.text = "AD"
    adBadge.font = .systemFont(ofSize: 9, weight: .bold)
    adBadge.textColor = .white
    adBadge.backgroundColor = DS.Color.primary.withAlphaComponent(0.8)
    adBadge.layer.cornerRadius = 4
    adBadge.clipsToBounds = true
    adBadge.textAlignment = .center
    nativeAdView.addSubview(adBadge)
    
    let iconImageView = UIImageView()
    iconImageView.contentMode = .scaleAspectFill
    iconImageView.layer.cornerRadius = 8
    iconImageView.clipsToBounds = true
    nativeAdView.addSubview(iconImageView)
    nativeAdView.iconView = iconImageView
    
    let headlineLabel = UILabel()
    headlineLabel.font = DS.Font.bodySemibold
    headlineLabel.textColor = DS.Color.textPrimary
    headlineLabel.numberOfLines = 1
    nativeAdView.addSubview(headlineLabel)
    nativeAdView.headlineView = headlineLabel
    
    let bodyLabel = UILabel()
    bodyLabel.font = DS.Font.caption
    bodyLabel.textColor = DS.Color.textSecondary
    bodyLabel.numberOfLines = 2
    nativeAdView.addSubview(bodyLabel)
    nativeAdView.bodyView = bodyLabel
    
    let ctaButton = UIButton(type: .system)
    ctaButton.titleLabel?.font = .systemFont(ofSize: 11, weight: .semibold)
    ctaButton.setTitleColor(.white, for: .normal)
    ctaButton.backgroundColor = DS.Color.primary
    ctaButton.layer.cornerRadius = 10
    ctaButton.isUserInteractionEnabled = false
    ctaButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
    nativeAdView.addSubview(ctaButton)
    nativeAdView.callToActionView = ctaButton
    
    adBadge.snp.makeConstraints {
      $0.top.leading.equalToSuperview().offset(12)
      $0.width.equalTo(22)
      $0.height.equalTo(14)
    }
    
    iconImageView.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(12)
      $0.centerY.equalToSuperview()
      $0.width.height.equalTo(40)
    }
    
    headlineLabel.snp.makeConstraints {
      $0.top.equalToSuperview().offset(14)
      $0.leading.equalTo(iconImageView.snp.trailing).offset(12)
      $0.trailing.lessThanOrEqualTo(ctaButton.snp.leading).offset(-8)
    }
    
    bodyLabel.snp.makeConstraints {
      $0.top.equalTo(headlineLabel.snp.bottom).offset(2)
      $0.leading.equalTo(iconImageView.snp.trailing).offset(12)
      $0.trailing.lessThanOrEqualTo(ctaButton.snp.leading).offset(-8)
      $0.bottom.lessThanOrEqualToSuperview().offset(-14)
    }
    
    ctaButton.snp.makeConstraints {
      $0.trailing.equalToSuperview().offset(-12)
      $0.centerY.equalToSuperview()
    }
    
    return nativeAdView
  }
}
