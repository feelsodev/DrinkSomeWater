import UIKit
import SnapKit
import Then

final class SettingsCell: UITableViewCell {
    
    static let cellID = "SettingsCell"
    
    private let iconContainerView = UIView().then {
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }
    
    private let iconImageView = UIImageView().then {
        $0.tintColor = .white
        $0.contentMode = .scaleAspectFit
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.25, alpha: 1)
    }
    
    private let detailLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .medium)
        $0.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.55, alpha: 1)
        $0.textAlignment = .right
    }
    
    private let arrowImageView = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))
        $0.tintColor = UIColor(red: 0.78, green: 0.78, blue: 0.8, alpha: 1)
        $0.contentMode = .scaleAspectFit
    }
    
    private let iconColors: [String: UIColor] = [
        "target": UIColor(red: 0.35, green: 0.78, blue: 0.62, alpha: 1),
        "bolt.fill": UIColor(red: 1.0, green: 0.76, blue: 0.28, alpha: 1),
        "bell.fill": UIColor(red: 1.0, green: 0.42, blue: 0.42, alpha: 1),
        "star.fill": UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1),
        "envelope.fill": UIColor(red: 0.35, green: 0.68, blue: 0.95, alpha: 1),
        "info.circle.fill": UIColor(red: 0.55, green: 0.55, blue: 0.6, alpha: 1)
    ]
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        selectionStyle = .none
        
        contentView.addSubviews([iconContainerView, titleLabel, detailLabel, arrowImageView])
        iconContainerView.addSubview(iconImageView)
        
        iconContainerView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(36)
        }
        
        iconImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(18)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(iconContainerView.snp.trailing).offset(14)
            $0.centerY.equalToSuperview()
        }
        
        arrowImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(8)
            $0.height.equalTo(14)
        }
        
        detailLabel.snp.makeConstraints {
            $0.trailing.equalTo(arrowImageView.snp.leading).offset(-10)
            $0.centerY.equalToSuperview()
            $0.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(12)
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.15) {
            self.contentView.alpha = highlighted ? 0.7 : 1.0
        }
    }
    
    func configure(icon: String, title: String, detail: String?, showArrow: Bool) {
        iconImageView.image = UIImage(systemName: icon, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
        titleLabel.text = title
        detailLabel.text = detail
        arrowImageView.isHidden = !showArrow
        
        iconContainerView.backgroundColor = iconColors[icon] ?? #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
    }
}
