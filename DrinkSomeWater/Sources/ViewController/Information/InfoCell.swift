import UIKit

final class InfoCell: BaseTableViewCell {
    
    static let cellID = "InfoCell"
    
    private struct Constant {
        static let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    
    let icon = UIImageView().then {
        $0.tintColor = .black
        $0.backgroundColor = .white
    }
    
    let titleLabel = UILabel().then {
        $0.textColor = .black
        $0.numberOfLines = 0
    }
    
    func configure(with info: Info) {
        titleLabel.text = info.title
        icon.image = info.key.getImage()
        
        switch info.key {
        case .version:
            let versionLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 20)).then {
                $0.text = Constant.version
                $0.textColor = .black
                $0.textAlignment = .right
            }
            accessoryView = versionLabel
        default:
            accessoryType = .disclosureIndicator
        }
    }
    
    override func initialize() {
        backgroundColor = .white
    }
    
    override func setupConstraints() {
        contentView.addSubviews([icon, titleLabel])
        
        icon.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.centerY.equalToSuperview()
            $0.height.width.equalTo(30)
        }
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(icon.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().offset(-30)
            $0.centerY.equalToSuperview()
        }
    }
}
