import SwiftUI

struct WatchLockedView: View {
  var body: some View {
    VStack(spacing: 12) {
      Image(systemName: "lock.fill")
        .font(.system(size: 32))
        .foregroundStyle(.orange)

      Text("구독이 필요합니다")
        .font(.system(.headline, design: .rounded))

      Text("iPhone 앱에서 구독하세요")
        .font(.system(.caption2, design: .rounded))
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
    }
    .padding()
  }
}

#Preview {
  WatchLockedView()
}
