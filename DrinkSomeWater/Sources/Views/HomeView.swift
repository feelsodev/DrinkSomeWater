import SwiftUI
import UIKit
import Analytics

struct HomeView: View {
  @Bindable var store: HomeStore
  @State private var showGoalSetting = false
  @State private var showQuickButtonSetting = false
  @State private var showWaterAdjustment = false
  @State private var isSubtractMode = false
  
  var body: some View {
    ZStack {
      WaveAnimationViewRepresentable(
        color: DS.Color.primaryLight,
        progress: 0.5,
        backgroundColor: DS.Color.backgroundPrimary
      )
      .ignoresSafeArea()

      VStack(spacing: 0) {
        if store.showNotificationBanner {
          notificationBanner
        }

        headerSection

        Spacer(minLength: 16)

        bottleSection

        Spacer(minLength: 20)

        quickButtonsSection
      }
      .padding(.horizontal, 24)
      .padding(.bottom, 8)
    }
    .background(Color(DS.Color.backgroundPrimary).ignoresSafeArea())
    .task {
      await store.send(.refreshGoal)
      await store.send(.refresh)
      await store.send(.checkNotificationPermission)
      Analytics.shared.logScreenView("home_screen")
    }
    .sheet(isPresented: $showGoalSetting) {
      GoalSettingView(
        currentGoal: Int(store.total),
        provider: store.provider
      ) {
        Task {
          await store.send(.refreshGoal)
          await store.send(.refresh)
        }
      }
      .presentationDetents([.medium])
      .presentationDragIndicator(.visible)
    }
    .sheet(isPresented: $showQuickButtonSetting) {
      QuickButtonSettingView(
        currentButtons: store.quickButtons,
        provider: store.provider
      ) {
        Task {
          await store.send(.refreshQuickButtons)
        }
      }
      .presentationDetents([.large])
      .presentationDragIndicator(.visible)
    }
    .sheet(isPresented: $showWaterAdjustment) {
      WaterAdjustmentView(store: store)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
  }
  
  private var headerSection: some View {
    VStack(spacing: 4) {
      Text("\(Int(store.ml))ml")
        .font(.system(size: 48, weight: .bold))
        .foregroundStyle(DS.SwiftUIColor.textPrimary)
        .accessibilityLabel(String(localized: "accessibility.home.current", defaultValue: "Current intake \(Int(store.ml)) milliliters"))

      Button {
        showGoalSetting = true
      } label: {
        HStack(spacing: 6) {
          Text(String(format: String(localized: "home.goal"), "\(Int(store.total))"))
            .font(.system(size: 14, weight: .semibold))
          Image(systemName: "pencil.circle.fill")
            .font(.system(size: 14, weight: .medium))
        }
        .foregroundStyle(DS.SwiftUIColor.primary)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(DS.SwiftUIColor.primary.opacity(0.12))
        .clipShape(Capsule())
      }
      .accessibilityLabel(String(localized: "accessibility.home.goal", defaultValue: "Daily goal \(Int(store.total)) milliliters"))
      .accessibilityHint(String(localized: "accessibility.home.goal.hint", defaultValue: "Double tap to change goal"))
      
      messageCard
        .padding(.top, 8)
    }
    .padding(.top, 8)
  }
  
  private var messageCard: some View {
    HStack(spacing: 8) {
      Text(store.remainingMl <= 0 ? "🎉" : "💧")
        .font(.system(size: 20))
        .accessibilityHidden(true)

      Text(store.remainingMl <= 0 ? String(localized: "home.goal.achieved") : String(format: String(localized: "home.goal.remaining"), "\(store.remainingCups)"))
        .font(.system(size: 14, weight: .semibold))
        .foregroundStyle(DS.SwiftUIColor.textPrimary)
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 10)
    .background(
      RoundedRectangle(cornerRadius: 20, style: .continuous)
        .fill(store.remainingMl <= 0 ? DS.SwiftUIColor.success.opacity(0.1) : .white)
        .shadow(
          color: store.remainingMl <= 0 ? DS.SwiftUIColor.success.opacity(0.3) : DS.SwiftUIColor.primary.opacity(0.2),
          radius: 12,
          y: 4
        )
    )
  }

  private var notificationBanner: some View {
    HStack(alignment: .center, spacing: 12) {
      Image(systemName: "bell.badge")
        .font(.system(size: 20))
        .foregroundStyle(.orange)

      VStack(alignment: .leading, spacing: 2) {
        Text(String(localized: "home.notification.banner.title"))
          .font(.system(size: 14, weight: .semibold))
          .foregroundStyle(DS.SwiftUIColor.textPrimary)
        Text(String(localized: "home.notification.banner.description"))
          .font(.system(size: 12))
          .foregroundStyle(.secondary)
          .fixedSize(horizontal: false, vertical: true)
      }
      .layoutPriority(1)

      Spacer()

      Button {
        if let url = URL(string: UIApplication.openSettingsURLString) {
          UIApplication.shared.open(url)
        }
      } label: {
        Text(String(localized: "home.notification.banner.settings"))
          .font(.system(size: 12, weight: .semibold))
          .foregroundStyle(.white)
          .padding(.horizontal, 12)
          .padding(.vertical, 6)
          .background(DS.SwiftUIColor.primary)
          .clipShape(Capsule())
      }

      Button {
        Task {
          await store.send(.dismissNotificationBanner)
        }
      } label: {
        Image(systemName: "xmark")
          .font(.system(size: 12, weight: .medium))
          .foregroundStyle(.secondary)
      }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .background(
      RoundedRectangle(cornerRadius: 12, style: .continuous)
        .fill(Color.orange.opacity(0.1))
    )
    .padding(.bottom, 8)
  }

  private var bottleSection: some View {
    VStack(spacing: 0) {
      RoundedRectangle(cornerRadius: 6)
        .fill(DS.SwiftUIColor.primaryDark)
        .frame(width: 90, height: 10)
      
      RoundedRectangle(cornerRadius: 0)
        .fill(DS.SwiftUIColor.primary.opacity(0.3))
        .frame(width: 50, height: 12)
        .offset(y: -2)
      
      ZStack {
        RoundedRectangle(cornerRadius: 32, style: .continuous)
          .fill(.white)
          .shadow(color: DS.SwiftUIColor.primary.opacity(0.4), radius: 16, y: 8)
        
        WaveAnimationViewRepresentable(
          color: DS.Color.primary,
          progress: store.progress,
          backgroundColor: UIColor.white.withAlphaComponent(0.6),
          cornerRadius: 32,
          borderWidth: 4,
          borderColor: .white
        )
      }
      .frame(width: 160)
      .offset(y: -4)
    }
  }
  
  private var quickButtonsSection: some View {
    VStack(spacing: 10) {
      HStack {
        Text(isSubtractMode ? String(localized: "home.quick.subtract") : String(localized: "home.quick.add"))
          .font(.system(size: 14, weight: .medium))
          .foregroundStyle(.gray)

        Spacer()

        Button {
          withAnimation(.easeInOut(duration: 0.2)) {
            isSubtractMode.toggle()
          }
        } label: {
          HStack(spacing: 5) {
            Text(isSubtractMode ? "−" : "+")
              .font(.system(size: 15, weight: .bold))
            Image(systemName: "arrow.triangle.2.circlepath")
              .font(.system(size: 12, weight: .medium))
          }
          .foregroundStyle(isSubtractMode ? .red : DS.SwiftUIColor.primary)
          .padding(.horizontal, 10)
          .padding(.vertical, 6)
          .background(
            Capsule()
              .fill(isSubtractMode ? Color.red.opacity(0.12) : DS.SwiftUIColor.primary.opacity(0.12))
          )
        }
        .accessibilityLabel(isSubtractMode
          ? String(localized: "accessibility.home.mode.subtract", defaultValue: "Subtract mode active")
          : String(localized: "accessibility.home.mode.add", defaultValue: "Add mode active"))
        .accessibilityHint(String(localized: "accessibility.home.mode.hint", defaultValue: "Double tap to toggle between add and subtract mode"))

        Button(String(localized: "home.edit")) {
          showQuickButtonSetting = true
        }
        .font(.system(size: 14, weight: .medium))
        .foregroundStyle(.gray)
        .padding(.leading, 8)
      }

      let buttons = store.quickButtons
      let midPoint = (buttons.count + 1) / 2
      let firstRow = Array(buttons.prefix(midPoint))
      let secondRow = Array(buttons.suffix(from: midPoint))

      quickButtonRow(amounts: firstRow)
      quickButtonRow(amounts: secondRow)
    }
  }
  
  private func quickButtonRow(amounts: [Int]) -> some View {
    HStack(spacing: 12) {
      ForEach(amounts, id: \.self) { amount in
        Button {
          Task {
            if isSubtractMode {
              await store.send(.subtractWater(amount))
            } else {
              await store.send(.addWater(amount))
            }
          }
        } label: {
          Text(isSubtractMode ? "-\(amount)ml" : "+\(amount)ml")
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(isSubtractMode ? Color.red.opacity(0.85) : DS.SwiftUIColor.primary)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        }
        .disabled(isSubtractMode && store.ml <= 0)
        .accessibilityLabel(isSubtractMode 
          ? String(localized: "accessibility.home.subtract", defaultValue: "Subtract \(amount) milliliters")
          : String(localized: "accessibility.home.add", defaultValue: "Add \(amount) milliliters"))
        .accessibilityHint(isSubtractMode
          ? String(localized: "accessibility.home.subtract.hint", defaultValue: "Double tap to subtract water")
          : String(localized: "accessibility.home.add.hint", defaultValue: "Double tap to add water"))
      }
    }
  }
}

struct GoalSettingView: View {
  let currentGoal: Int
  let provider: ServiceProviderProtocol
  let onSave: () -> Void
  @SwiftUI.Environment(\.dismiss) private var dismiss
  @State private var goal: Double
  
  init(currentGoal: Int, provider: ServiceProviderProtocol, onSave: @escaping () -> Void) {
    self.currentGoal = currentGoal
    self.provider = provider
    self.onSave = onSave
    self._goal = State(initialValue: Double(currentGoal))
  }
  
  var body: some View {
    NavigationStack {
      VStack(spacing: 24) {
        Text("\(Int(goal))ml")
          .font(.system(size: 48, weight: .bold))
          .foregroundStyle(DS.SwiftUIColor.primary)
        
        Slider(value: $goal, in: 1000...4000, step: 100)
          .tint(DS.SwiftUIColor.primary)
          .padding(.horizontal)

        HStack {
          Text(String(localized: "home.goal.min"))
            .font(.caption)
            .foregroundStyle(.secondary)
          Spacer()
          Text(String(localized: "home.goal.max"))
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal)

        Spacer()

        Button {
          Task {
            let oldGoal = currentGoal
            _ = await provider.waterService.updateGoal(to: Int(goal))
            Analytics.shared.log(.goalChanged(oldGoal: oldGoal, newGoal: Int(goal), source: .settings))
            Analytics.shared.setDailyGoal(Int(goal))
            onSave()
            dismiss()
          }
        } label: {
          Text(String(localized: "home.goal.save"))
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(DS.SwiftUIColor.primary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal)
      }
      .padding(.vertical, 24)
      .navigationTitle(String(localized: "home.goal.setting.title"))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button(String(localized: "home.goal.cancel")) { dismiss() }
        }
      }
    }
  }
}

struct QuickButtonSettingView: View {
  let currentButtons: [Int]
  let provider: ServiceProviderProtocol
  let onSave: () -> Void
  @SwiftUI.Environment(\.dismiss) private var dismiss
  @State private var buttons: [Int]
  @State private var newAmount: String = ""
  
  init(currentButtons: [Int], provider: ServiceProviderProtocol, onSave: @escaping () -> Void) {
    self.currentButtons = currentButtons
    self.provider = provider
    self.onSave = onSave
    self._buttons = State(initialValue: currentButtons)
  }
  
  var body: some View {
    NavigationStack {
      List {
        Section(String(localized: "home.quickbutton.current")) {
          ForEach(buttons, id: \.self) { amount in
            HStack {
              Text("+\(amount)ml")
              Spacer()
            }
          }
          .onDelete(perform: deleteButton)
          .onMove(perform: moveButton)
        }

        Section(String(localized: "home.quickbutton.add.section")) {
          HStack {
            TextField(String(localized: "home.quickbutton.placeholder"), text: $newAmount)
              .keyboardType(.numberPad)

            Button(String(localized: "home.quickbutton.add")) {
              if let amount = Int(newAmount), amount > 0 {
                buttons.append(amount)
                newAmount = ""
              }
            }
            .disabled(newAmount.isEmpty)
          }
        }

        Section {
          Button(String(localized: "home.quickbutton.reset")) {
            buttons = HomeStore.defaultQuickButtons
          }
          .foregroundStyle(.red)
        }
      }
      .navigationTitle(String(localized: "home.quickbutton.title"))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button(String(localized: "home.goal.cancel")) { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button(String(localized: "home.goal.save")) {
            provider.userDefaultsService.set(value: buttons, forkey: .quickButtons)
            for (index, amount) in buttons.enumerated() {
              Analytics.shared.log(.quickButtonCustomized(buttonIndex: index, amountMl: amount))
            }
            onSave()
            dismiss()
          }
        }
        ToolbarItem(placement: .topBarTrailing) {
          EditButton()
        }
      }
    }
  }
  
  private func deleteButton(at offsets: IndexSet) {
    buttons.remove(atOffsets: offsets)
  }

  private func moveButton(from source: IndexSet, to destination: Int) {
    buttons.move(fromOffsets: source, toOffset: destination)
  }
}

struct WaterAdjustmentView: View {
  let store: HomeStore
  @SwiftUI.Environment(\.dismiss) private var dismiss
  @State private var showResetConfirmation = false

  private let subtractAmounts = [50, 100, 200, 300]

  var body: some View {
    NavigationStack {
      VStack(spacing: 24) {
        Text("\(Int(store.ml))ml")
          .font(.system(size: 48, weight: .bold))
          .foregroundStyle(DS.SwiftUIColor.primary)

        VStack(spacing: 16) {
          Text(String(localized: "home.quick.subtract"))
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)

          LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(subtractAmounts, id: \.self) { amount in
              Button {
                Task {
                  await store.send(.subtractWater(amount))
                }
              } label: {
                Text("-\(amount)ml")
                  .font(.system(size: 15, weight: .semibold))
                  .foregroundStyle(.white)
                  .frame(maxWidth: .infinity)
                  .frame(height: 48)
                  .background(DS.SwiftUIColor.primary.opacity(0.8))
                  .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
              }
              .disabled(store.ml <= 0)
            }
          }
        }
        .padding(.horizontal)

        Divider()
          .padding(.horizontal)

        Button(role: .destructive) {
          showResetConfirmation = true
        } label: {
          HStack {
            Image(systemName: "arrow.counterclockwise")
            Text(String(localized: "home.adjustment.reset"))
          }
          .font(.system(size: 15, weight: .medium))
          .foregroundStyle(.red)
          .frame(maxWidth: .infinity)
          .frame(height: 48)
          .background(Color.red.opacity(0.1))
          .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(.horizontal)
        .disabled(store.ml <= 0)

        Spacer()
      }
      .padding(.vertical, 24)
      .navigationTitle(String(localized: "home.adjustment.title"))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button(String(localized: "home.adjustment.done")) { dismiss() }
        }
      }
      .confirmationDialog(
        String(localized: "home.adjustment.reset.confirm"),
        isPresented: $showResetConfirmation,
        titleVisibility: .visible
      ) {
        Button(String(localized: "home.adjustment.reset.button"), role: .destructive) {
          Task {
            await store.send(.resetTodayWater)
          }
        }
        Button(String(localized: "home.goal.cancel"), role: .cancel) {}
      } message: {
        Text(String(localized: "home.adjustment.reset.message"))
      }
    }
  }
}
