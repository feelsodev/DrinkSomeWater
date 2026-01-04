import UIKit

enum DesignTokens {
    
    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let xxxl: CGFloat = 40
        static let xxxxl: CGFloat = 48
    }
    
    enum Size {
        static let iconSmall: CGFloat = 18
        static let iconMedium: CGFloat = 24
        static let iconLarge: CGFloat = 32
        static let iconXLarge: CGFloat = 40
        
        static let buttonHeight: CGFloat = 50
        static let buttonHeightLarge: CGFloat = 56
        static let cellHeight: CGFloat = 56
        static let cellHeightLarge: CGFloat = 72
        
        static let cornerRadiusSmall: CGFloat = 8
        static let cornerRadiusMedium: CGFloat = 12
        static let cornerRadiusLarge: CGFloat = 16
        static let cornerRadiusXLarge: CGFloat = 20
        
        static let iconContainerSmall: CGFloat = 32
        static let iconContainerMedium: CGFloat = 36
        static let iconContainerLarge: CGFloat = 44
    }
    
    enum Font {
        static let captionSmall = UIFont.systemFont(ofSize: 11, weight: .regular)
        static let caption = UIFont.systemFont(ofSize: 12, weight: .regular)
        static let captionMedium = UIFont.systemFont(ofSize: 12, weight: .medium)
        static let captionSemibold = UIFont.systemFont(ofSize: 12, weight: .semibold)
        
        static let footnote = UIFont.systemFont(ofSize: 13, weight: .regular)
        static let footnoteMedium = UIFont.systemFont(ofSize: 13, weight: .medium)
        static let footnoteSemibold = UIFont.systemFont(ofSize: 13, weight: .semibold)
        
        static let subhead = UIFont.systemFont(ofSize: 14, weight: .regular)
        static let subheadMedium = UIFont.systemFont(ofSize: 14, weight: .medium)
        static let subheadSemibold = UIFont.systemFont(ofSize: 14, weight: .semibold)
        
        static let body = UIFont.systemFont(ofSize: 16, weight: .regular)
        static let bodyMedium = UIFont.systemFont(ofSize: 16, weight: .medium)
        static let bodySemibold = UIFont.systemFont(ofSize: 16, weight: .semibold)
        static let bodyBold = UIFont.systemFont(ofSize: 16, weight: .bold)
        
        static let headline = UIFont.systemFont(ofSize: 17, weight: .semibold)
        static let headlineBold = UIFont.systemFont(ofSize: 17, weight: .bold)
        
        static let title3 = UIFont.systemFont(ofSize: 20, weight: .semibold)
        static let title3Bold = UIFont.systemFont(ofSize: 20, weight: .bold)
        
        static let title2 = UIFont.systemFont(ofSize: 22, weight: .bold)
        
        static let title1 = UIFont.systemFont(ofSize: 28, weight: .bold)
        
        static let largeTitle = UIFont.systemFont(ofSize: 32, weight: .bold)
        
        static let display = UIFont.systemFont(ofSize: 48, weight: .bold)
    }
    
    enum Color {
        static let primary = UIColor(red: 0.35, green: 0.75, blue: 0.95, alpha: 1)
        static let primaryDark = UIColor(red: 0.25, green: 0.65, blue: 0.90, alpha: 1)
        static let primaryLight = UIColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 1)
        
        static let success = UIColor(red: 0.35, green: 0.78, blue: 0.62, alpha: 1)
        static let warning = UIColor(red: 1.0, green: 0.76, blue: 0.28, alpha: 1)
        static let error = UIColor(red: 1.0, green: 0.42, blue: 0.42, alpha: 1)
        
        static let textPrimary = UIColor(red: 0.2, green: 0.2, blue: 0.25, alpha: 1)
        static let textSecondary = UIColor(red: 0.5, green: 0.5, blue: 0.55, alpha: 1)
        static let textTertiary = UIColor(red: 0.7, green: 0.7, blue: 0.73, alpha: 1)
        
        static let backgroundPrimary = UIColor(red: 0.96, green: 0.96, blue: 0.98, alpha: 1)
        static let backgroundSecondary = UIColor.white
        static let backgroundTertiary = UIColor(red: 0.92, green: 0.92, blue: 0.94, alpha: 1)
        
        static let separator = UIColor(red: 0.9, green: 0.9, blue: 0.92, alpha: 1)
        static let border = UIColor(red: 0.85, green: 0.85, blue: 0.88, alpha: 1)
        
        static let iconRed = UIColor.systemRed
        static let iconOrange = UIColor.systemOrange
        static let iconYellow = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1)
        static let iconGreen = UIColor(red: 0.35, green: 0.78, blue: 0.62, alpha: 1)
        static let iconBlue = UIColor(red: 0.35, green: 0.68, blue: 0.95, alpha: 1)
        static let iconGray = UIColor(red: 0.55, green: 0.55, blue: 0.6, alpha: 1)
    }
}

typealias DS = DesignTokens
