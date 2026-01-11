import SwiftUI

struct QuickAddView: View {
  @Environment(WatchStore.self) private var store

  private let quickAmounts = [150, 250, 300, 500]

  var body: some View {
    ScrollView {
      VStack(spacing: 8) {
        Text(String(localized: "watch.add.water"))
          .font(.headline)
          .padding(.bottom, 4)

        ForEach(quickAmounts, id: \.self) { amount in
          QuickAddButton(amount: amount) {
            Task {
              await store.addWater(amount)
            }
          }
        }

        NavigationLink {
          CustomAmountView()
        } label: {
          HStack {
            Image(systemName: "slider.horizontal.3")
            Text(String(localized: "watch.custom.input"))
          }
          .frame(maxWidth: .infinity)
          .padding(.vertical, 8)
        }
        .buttonStyle(.bordered)
        .tint(.orange)
      }
      .padding(.horizontal)
    }
    .containerBackground(.blue.gradient.opacity(0.2), for: .navigation)
  }
}

struct QuickAddButton: View {
  let amount: Int
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack {
        Image(systemName: "drop.fill")
          .foregroundStyle(.blue)
        Text("+\(amount)ml")
          .font(.system(.body, design: .rounded, weight: .medium))
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, 6)
    }
    .buttonStyle(.bordered)
    .tint(.blue)
  }
}

#Preview {
  QuickAddView()
    .environment(WatchStore())
}
