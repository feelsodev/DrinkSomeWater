import UIKit
import SnapKit
import Then

final class SettingsCell: UITableViewCell {
    
    static let cellID = "SettingsCell"
    
    private let iconContainerView = UIView().then {
        $0.layer.cornerRadius = DS.Size.cornerRadiusSmall
        $0.clipsToBounds = true
    }
    
    private let iconImageView = UIImageView().then {
        $0.tintColor = .white
        $0.contentMode = .scaleAspectFit
    }
    
    private let titleLabel = UILabel().then {
        $0.font = DS.Font.bodySemibold
        $0.textColor = DS.Color.textPrimary
    }
    
    private let detailLabel = UILabel().then {
        $0.font = DS.Font.subheadMedium
        $0.textColor = DS.Color.textSecondary
        $0.textAlignment = .right
    }
    
    private let arrowImageView = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))
        $0.tintColor = DS.Color.textTertiary
        $0.contentMode = .scaleAspectFit
    }
    
    private let separatorView = UIView().then {
        $0.backgroundColor = DS.Color.separator
    }
    
    private let iconColors: [String: UIColor] = [
        "person.fill": DS.Color.primary,
        "target": DS.Color.success,
        "bolt.fill": DS.Color.warning,
        "bell.fill": DS.Color.error,
        "apps.iphone": DS.Color.primary,
        "star.fill": DS.Color.iconYellow,
        "envelope.fill": DS.Color.iconBlue,
        "info.circle.fill": DS.Color.iconGray
    ]
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = DS.Color.backgroundSecondary
        selectionStyle = .none
        
        contentView.addSubviews([iconContainerView, titleLabel, detailLabel, arrowImageView, separatorView])
        iconContainerView.addSubview(iconImageView)
        
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
            self.contentView.alpha = highlighted ? 0.7 : 1.0
            self.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
        }
    }
    
    func configure(icon: String, title: String, detail: String?, showArrow: Bool, isLast: Bool = false) {
        iconImageView.image = UIImage(systemName: icon, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
        titleLabel.text = title
        detailLabel.text = detail
        arrowImageView.isHidden = !showArrow
        separatorView.isHidden = isLast
        
        iconContainerView.backgroundColor = iconColors[icon] ?? DS.Color.primary
    }
}
