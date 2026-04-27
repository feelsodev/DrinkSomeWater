import UIKit
import SnapKit

final class SettingsCell: UITableViewCell {
  
  static let cellID = "SettingsCell"
  
  var maskedCorners: CACornerMask = [] {
    didSet {
      cardView.layer.maskedCorners = maskedCorners
      cardView.layer.cornerRadius = maskedCorners.isEmpty ? 0 : 24
    }
  }
  
  private lazy var cardView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.layer.shadowColor = DS.Color.primary.withAlphaComponent(0.4).cgColor
    view.layer.shadowOffset = CGSize(width: 0, height: 8)
    view.layer.shadowOpacity = 0.3
    view.layer.shadowRadius = 16
    view.layer.cornerCurve = .continuous
    return view
  }()
  
  private lazy var iconContainerView: UIView = {
    let view = UIView()
    view.layer.cornerRadius = DS.Size.cornerRadiusMedium
    view.clipsToBounds = true
    return view
  }()
  
  private lazy var iconImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.tintColor = .white
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.font = DS.Font.bodySemibold
    label.textColor = DS.Color.textPrimary
    return label
  }()
  
  private lazy var detailLabel: UILabel = {
    let label = UILabel()
    label.font = DS.Font.subheadMedium
    label.textColor = DS.Color.textSecondary
    label.textAlignment = .right
    return label
  }()
  
  private lazy var arrowImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))
    imageView.tintColor = DS.Color.textTertiary
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  private lazy var separatorView: UIView = {
    let view = UIView()
    view.backgroundColor = DS.Color.separator
    return view
  }()
  
  private let iconColors: [String: UIColor] = [
    "person.fill": DS.Color.primary,
    "target": DS.Color.success,
    "bolt.fill": DS.Color.warning,
    "bell.fill": DS.Color.error,
    "apps.iphone": DS.Color.primary,
    "heart.fill": DS.Color.iconRed,
    "star.fill": DS.Color.iconYellow,
    "envelope.fill": DS.Color.iconBlue,
    "info.circle.fill": DS.Color.iconGray,
    "hammer.fill": .systemOrange
  ]
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupUI() {
    backgroundColor = .clear
    selectionStyle = .none
    
    contentView.addSubview(cardView)
    cardView.addSubviews([iconContainerView, titleLabel, detailLabel, arrowImageView, separatorView])
    iconContainerView.addSubview(iconImageView)
    
    cardView.snp.makeConstraints {
      $0.top.bottom.equalToSuperview()
      $0.leading.trailing.equalToSuperview().inset(DS.Spacing.md)
    }
    
    iconContainerView.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(DS.Spacing.md)
      $0.centerY.equalToSuperview()
      $0.width.height.equalTo(DS.Size.iconContainerMedium)
    }
    
    iconImageView.snp.makeConstraints {
      $0.center.equalToSuperview()
      $0.width.height.equalTo(DS.Size.iconSmall)
    }
    
    titleLabel.snp.makeConstraints {
      $0.leading.equalTo(iconContainerView.snp.trailing).offset(DS.Spacing.sm)
      $0.centerY.equalToSuperview()
    }
    
    arrowImageView.snp.makeConstraints {
      $0.trailing.equalToSuperview().offset(-DS.Spacing.md)
      $0.centerY.equalToSuperview()
      $0.width.equalTo(8)
      $0.height.equalTo(14)
    }
    
    detailLabel.snp.makeConstraints {
      $0.trailing.equalTo(arrowImageView.snp.leading).offset(-DS.Spacing.xs)
      $0.centerY.equalToSuperview()
      $0.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(DS.Spacing.sm)
    }
    
    separatorView.snp.makeConstraints {
      $0.leading.equalTo(titleLabel.snp.leading)
      $0.trailing.equalToSuperview()
      $0.bottom.equalToSuperview()
      $0.height.equalTo(0.5)
    }
  }
  
  override func setHighlighted(_ highlighted: Bool, animated: Bool) {
    super.setHighlighted(highlighted, animated: animated)
    UIView.animate(withDuration: 0.15) {
      self.cardView.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
      self.cardView.backgroundColor = highlighted ? DS.Color.backgroundTertiary : .white
    }
  }
  
  func configure(icon: String, title: String, detail: String?, showArrow: Bool, isLast: Bool = false) {
    iconImageView.image = UIImage(systemName: icon, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
    titleLabel.text = title
    detailLabel.text = detail
    arrowImageView.isHidden = !showArrow
    separatorView.isHidden = isLast
    
    let color = iconColors[icon] ?? DS.Color.primary
    iconContainerView.backgroundColor = color.withAlphaComponent(0.1)
    iconImageView.tintColor = color
  }
}
