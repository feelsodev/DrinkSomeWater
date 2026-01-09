import SwiftUI

struct HomeView: View {
  @Environment(WatchStore.self) private var store

  private var progressText: String {
    "\(store.todayWater)ml"
  }

  private var goalText: String {
    "/ \(store.goal)ml"
  }

  private var percentText: String {
    "\(store.progressPercent)%"
  }

  var body: some View {
    VStack(spacing: 8) {
      ZStack {
        Circle()
          .stroke(Color.blue.opacity(0.2), lineWidth: 12)

        Circle()
          .trim(from: 0, to: CGFloat(store.progress))
          .stroke(
            Color.blue,
            style: StrokeStyle(lineWidth: 12, lineCap: .round)
          )
          .rotationEffect(.degrees(-90))
          .animation(.easeInOut(duration: 0.5), value: store.progress)

        VStack(spacing: 2) {
          Text(percentText)
            .font(.system(size: 28, weight: .bold, design: .rounded))
            .foregroundStyle(.blue)

          Image(systemName: "drop.fill")
            .font(.system(size: 16))
            .foregroundStyle(.blue)
        }
      }
      .frame(width: 100, height: 100)

      VStack(spacing: 0) {
        Text(progressText)
          .font(.system(size: 20, weight: .semibold, design: .rounded))
        Text(goalText)
          .font(.system(size: 12))
          .foregroundStyle(.secondary)
      }
    }
    .containerBackground(.blue.gradient.opacity(0.2), for: .navigation)
  }
}

#Preview {
  HomeView()
    .environment(WatchStore())
}
