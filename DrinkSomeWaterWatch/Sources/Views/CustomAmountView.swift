import SwiftUI

struct CustomAmountView: View {
  @Environment(WatchStore.self) private var store
  @Environment(\.dismiss) private var dismiss

  @State private var amount: Int = 200

  private let minAmount = 50
  private let maxAmount = 1000
  private let step = 50

  var body: some View {
    VStack(spacing: 16) {
      Text("\(amount)ml")
        .font(.system(size: 32, weight: .bold, design: .rounded))
        .foregroundStyle(.blue)

      HStack(spacing: 20) {
        Button {
          if amount > minAmount {
            amount -= step
          }
        } label: {
          Image(systemName: "minus.circle.fill")
            .font(.system(size: 32))
            .foregroundStyle(amount > minAmount ? .blue : .gray)
        }
        .buttonStyle(.plain)
        .disabled(amount <= minAmount)

        Button {
          if amount < maxAmount {
            amount += step
          }
        } label: {
          Image(systemName: "plus.circle.fill")
            .font(.system(size: 32))
            .foregroundStyle(amount < maxAmount ? .blue : .gray)
        }
        .buttonStyle(.plain)
        .disabled(amount >= maxAmount)
      }

      Button {
        Task {
          await store.addWater(amount)
          dismiss()
        }
      } label: {
        HStack {
          Image(systemName: "plus")
          Text("추가")
        }
        .frame(maxWidth: .infinity)
      }
      .buttonStyle(.borderedProminent)
      .tint(.blue)
    }
    .padding()
    .navigationTitle("직접 입력")
    .containerBackground(.blue.gradient.opacity(0.2), for: .navigation)
  }
}

#Preview {
  NavigationStack {
    CustomAmountView()
      .environment(WatchStore())
  }
}
