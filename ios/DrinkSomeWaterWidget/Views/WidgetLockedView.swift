import SwiftUI
import WidgetKit

struct WidgetLockedView: View {
  @Environment(\.widgetFamily) var family
  
  private var paywallURL: URL {
    URL(string: "drinksomewater://paywall")!
  }
  
  var body: some View {
    Link(destination: paywallURL) {
      content
    }
    .containerBackground(for: .widget) {
      Color(.systemBackground)
    }
  }
  
  @ViewBuilder
  private var content: some View {
    switch family {
    case .accessoryCircular:
      accessoryCircularContent
    case .accessoryRectangular:
      accessoryRectangularContent
    case .accessoryInline:
      accessoryInlineContent
    case .systemMedium:
      mediumContent
    case .systemLarge:
      largeContent
    default:
      smallContent
    }
  }
  
  // MARK: - Small
  
  private var smallContent: some View {
    VStack(spacing: 8) {
      Image(systemName: "lock.fill")
        .font(.system(size: 28, weight: .medium))
        .foregroundStyle(.secondary)
      
      Text("구독 필요")
        .font(.system(size: 14, weight: .semibold, design: .rounded))
        .foregroundStyle(.secondary)
    }
  }
  
  // MARK: - Medium
  
  private var mediumContent: some View {
    HStack(spacing: 12) {
      Image(systemName: "lock.fill")
        .font(.system(size: 32, weight: .medium))
        .foregroundStyle(.secondary)
      
      VStack(alignment: .leading, spacing: 4) {
        Text("구독하고 위젯을 사용하세요")
          .font(.system(size: 15, weight: .semibold, design: .rounded))
          .foregroundStyle(.primary)
        
        HStack(spacing: 4) {
          Text("구독하러 가기")
            .font(.system(size: 13, weight: .medium, design: .rounded))
            .foregroundStyle(.blue)
          
          Image(systemName: "arrow.right")
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.blue)
        }
      }
    }
  }
  
  // MARK: - Large
  
  private var largeContent: some View {
    VStack(spacing: 16) {
      Image(systemName: "lock.fill")
        .font(.system(size: 40, weight: .medium))
        .foregroundStyle(.secondary)
      
      VStack(spacing: 6) {
        Text("구독하고 위젯을 사용하세요")
          .font(.system(size: 17, weight: .semibold, design: .rounded))
          .foregroundStyle(.primary)
        
        HStack(spacing: 4) {
          Text("구독하러 가기")
            .font(.system(size: 15, weight: .medium, design: .rounded))
            .foregroundStyle(.blue)
          
          Image(systemName: "arrow.right")
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.blue)
        }
      }
    }
  }
  
  // MARK: - Lock Screen
  
  private var accessoryCircularContent: some View {
    Image(systemName: "lock.fill")
      .font(.system(size: 20, weight: .medium))
      .widgetAccentable()
  }
  
  private var accessoryRectangularContent: some View {
    HStack(spacing: 6) {
      Image(systemName: "lock.fill")
        .font(.system(size: 14, weight: .medium))
      
      Text("구독 필요")
        .font(.system(size: 13, weight: .medium, design: .rounded))
    }
    .widgetAccentable()
  }
  
  private var accessoryInlineContent: some View {
    Label("구독 필요", systemImage: "lock.fill")
  }
}
