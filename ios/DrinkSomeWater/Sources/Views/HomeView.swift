import SwiftUI
import UIKit
import Analytics

struct HomeView: View {
  @Bindable var store: HomeStore
  @State private var showGoalSetting = false
  @State private var showQuickButtonSetting = false
  @State private var showWaterAdjustment = false
  @State private var isSubtractMode = false
  @State private var showShareSheet = false
  @State private var showInstagramNotInstalledAlert = false
  
  var body: some View {
    ZStack {
      WaveAnimationViewRepresentable(
        color: DS.Color.primaryLight,
        progress: 0.5,
        backgroundColor: DS.Color.backgroundPrimary
      )
      .ignoresSafeArea()

      VStack(spacing: DS.Spacing.none) {
        if store.showNotificationBanner {
          notificationBanner
        }

        headerSection

        Spacer(minLength: DS.Spacing.md)

        bottleSection

        Spacer(minLength: DS.Spacing.lg)

        quickButtonsSection
      }
      .padding(.horizontal, DS.Spacing.xl)
      .padding(.bottom, DS.Spacing.xs)
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
    .confirmationDialog(
      String(localized: "share.title.extended"),
      isPresented: $showShareSheet,
      titleVisibility: .visible
    ) {
      Button(String(localized: "share.instagram.stories")) {
        Task { await shareToInstagram(destination: .stories) }
      }
      Button(String(localized: "share.instagram.feed")) {
        Task { await shareToInstagram(destination: .feed) }
      }
      Button(String(localized: "share.system")) {
        Task { await shareViaSystemSheet() }
      }
      Button(String(localized: "home.goal.cancel"), role: .cancel) {}
    }
    .alert(
      String(localized: "share.error.title"),
      isPresented: $showInstagramNotInstalledAlert
    ) {
      Button(String(localized: "share.error.ok"), role: .cancel) {}
    } message: {
      Text(String(localized: "share.error.instagram.not.installed"))
    }
  }
  
   private func shareToInstagram(destination: ShareDestination) async {
     let instagramService = store.provider.instagramSharingService
     let analyticsDestination: InstagramShareDestination = destination == .stories ? .stories : .feed
     
     Analytics.shared.log(.instagramShareInitiated(destination: analyticsDestination, source: .home))
     
     guard instagramService.isInstagramInstalled() else {
       Analytics.shared.log(.instagramShareFailed(destination: analyticsDestination, reason: "instagram_not_installed"))
       showInstagramNotInstalledAlert = true
       return
     }
     
     let todayRecord = WaterRecord(
       date: Date(),
       value: Int(store.ml),
       isSuccess: store.ml >= store.total,
       goal: Int(store.total)
     )
     let streak = store.calculateStreak()
     
     do {
       switch destination {
       case .stories:
         try await instagramService.shareToStories(record: todayRecord, streak: streak)
       case .feed:
         try await instagramService.shareToFeed(record: todayRecord, streak: streak)
       }
       Analytics.shared.log(.instagramShareCompleted(destination: analyticsDestination, source: .home))
     } catch {
       Analytics.shared.log(.instagramShareFailed(destination: analyticsDestination, reason: error.localizedDescription))
       showInstagramNotInstalledAlert = true
     }
   }
   
   private func shareViaSystemSheet() async {
     let socialService = store.provider.socialSharingService
     let todayRecord = WaterRecord(
       date: Date(),
       value: Int(store.ml),
       isSuccess: store.ml >= store.total,
       goal: Int(store.total)
     )
     let streak = store.calculateStreak()
     
     guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController else { return }
     
    do {
        try await socialService.shareViaSystemSheet(record: todayRecord, streak: streak, source: .home, from: rootVC)
      } catch {
      }
   }
  
  private var headerSection: some View {
    VStack(spacing: DS.Spacing.xxs) {
      HStack {
        Spacer()
        Text("\(Int(store.ml))ml")
          .font(DS.SwiftUIFont.display)
          .foregroundStyle(DS.SwiftUIColor.textPrimary)
          .accessibilityLabel(String(localized: "accessibility.home.current", defaultValue: "Current intake \(Int(store.ml)) milliliters"))
        Spacer()
        
        Button {
          showShareSheet = true
        } label: {
          Image(systemName: "square.and.arrow.up")
            .font(DS.SwiftUIFont.title3)
            .foregroundStyle(DS.SwiftUIColor.primary)
            .frame(width: DS.Size.iconContainerMedium, height: DS.Size.iconContainerMedium)
            .background(DS.SwiftUIColor.primary.opacity(0.12))
            .clipShape(Circle())
        }
        .accessibilityLabel(String(localized: "accessibility.home.share", defaultValue: "Share to Instagram"))
      }

      Button {
        showGoalSetting = true
      } label: {
        HStack(spacing: DS.Spacing.xs) {
          Text(String(format: String(localized: "home.goal"), "\(Int(store.total))"))
            .font(DS.SwiftUIFont.subheadSemibold)
          Image(systemName: "pencil.circle.fill")
            .font(DS.SwiftUIFont.subheadMedium)
        }
        .foregroundStyle(DS.SwiftUIColor.primary)
        .padding(.horizontal, DS.Spacing.md)
        .padding(.vertical, DS.Spacing.xs)
        .background(DS.SwiftUIColor.primary.opacity(0.12))
        .clipShape(Capsule())
      }
      .accessibilityLabel(String(localized: "accessibility.home.goal", defaultValue: "Daily goal \(Int(store.total)) milliliters"))
      .accessibilityHint(String(localized: "accessibility.home.goal.hint", defaultValue: "Double tap to change goal"))
      
      messageCard
        .padding(.top, DS.Spacing.xs)
    }
    .padding(.top, DS.Spacing.xs)
  }
  
  private var messageCard: some View {
    HStack(spacing: DS.Spacing.xs) {
      Text(store.remainingMl <= 0 ? "🎉" : "💧")
        .font(DS.SwiftUIFont.title3)
        .accessibilityHidden(true)

      Text(store.remainingMl <= 0 ? String(localized: "home.goal.achieved") : String(format: String(localized: "home.goal.remaining"), "\(store.remainingCups)"))
        .font(DS.SwiftUIFont.subheadSemibold)
        .foregroundStyle(DS.SwiftUIColor.textPrimary)
    }
    .padding(.horizontal, DS.Spacing.md)
    .padding(.vertical, DS.Spacing.sm)
    .background(
      RoundedRectangle(cornerRadius: DS.Size.cornerRadiusXLarge, style: .continuous)
        .fill(store.remainingMl <= 0 ? DS.SwiftUIColor.success.opacity(0.1) : .white)
        .shadow(
          color: store.remainingMl <= 0 ? DS.SwiftUIColor.success.opacity(0.3) : DS.SwiftUIColor.primary.opacity(0.2),
          radius: DS.Spacing.sm,
          y: DS.Spacing.xxs
        )
    )
  }

  private var notificationBanner: some View {
    HStack(alignment: .center, spacing: DS.Spacing.sm) {
      Image(systemName: "bell.badge")
        .font(DS.SwiftUIFont.title3)
        .foregroundStyle(.orange)

      VStack(alignment: .leading, spacing: DS.Spacing.xxs) {
        Text(String(localized: "home.notification.banner.title"))
          .font(DS.SwiftUIFont.subheadSemibold)
          .foregroundStyle(DS.SwiftUIColor.textPrimary)
        Text(String(localized: "home.notification.banner.description"))
          .font(DS.SwiftUIFont.caption)
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
          .font(DS.SwiftUIFont.captionSemibold)
          .foregroundStyle(.white)
          .padding(.horizontal, DS.Spacing.sm)
          .padding(.vertical, DS.Spacing.xs)
          .background(DS.SwiftUIColor.primary)
          .clipShape(Capsule())
      }

      Button {
        Task {
          await store.send(.dismissNotificationBanner)
        }
      } label: {
        Image(systemName: "xmark")
          .font(DS.SwiftUIFont.captionMedium)
          .foregroundStyle(.secondary)
      }
    }
    .padding(.horizontal, DS.Spacing.md)
    .padding(.vertical, DS.Spacing.sm)
    .background(
      RoundedRectangle(cornerRadius: DS.Size.cornerRadiusMedium, style: .continuous)
        .fill(Color.orange.opacity(0.1))
    )
    .padding(.bottom, DS.Spacing.xs)
  }

  private var bottleSection: some View {
    VStack(spacing: DS.Spacing.none) {
      RoundedRectangle(cornerRadius: DS.Size.cornerRadiusSmall)
        .fill(DS.SwiftUIColor.primaryDark)
        .frame(width: 90, height: 10)
      
      RoundedRectangle(cornerRadius: DS.Spacing.none)
        .fill(DS.SwiftUIColor.primary.opacity(0.3))
        .frame(width: 50, height: DS.Spacing.sm)
        .offset(y: -2)
      
      ZStack {
        RoundedRectangle(cornerRadius: DS.Size.cornerRadiusPill, style: .continuous)
          .fill(.white)
          .shadow(color: DS.SwiftUIColor.primary.opacity(0.4), radius: DS.Spacing.md, y: DS.Spacing.xs)
        
        WaveAnimationViewRepresentable(
          color: DS.Color.primary,
          progress: store.progress,
          backgroundColor: UIColor.white.withAlphaComponent(0.6),
          cornerRadius: DS.Size.cornerRadiusPill,
          borderWidth: 4,
          borderColor: .white
        )
      }
      .frame(width: 160)
      .offset(y: -DS.Spacing.xxs)
    }
  }
  
  private var drinkTypePicker: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: DS.Spacing.xs) {
        ForEach(DrinkType.allCases) { type in
          drinkTypeButton(type)
        }
      }
      .padding(.horizontal, DS.Spacing.lg)
    }
  }
  
  private func drinkTypeButton(_ type: DrinkType) -> some View {
    Button {
      Task { await store.send(.selectDrinkType(type)) }
    } label: {
      VStack(spacing: DS.Spacing.xxs) {
        Image(systemName: type.iconName)
          .font(DS.SwiftUIFont.body)
        Text(type.displayName)
          .font(DS.SwiftUIFont.captionMedium)
          .lineLimit(1)
      }
      .foregroundStyle(store.selectedDrinkType == type ? DS.SwiftUIColor.backgroundSecondary : DS.SwiftUIColor.primary)
      .frame(width: 56)
      .padding(.vertical, DS.Spacing.xs)
      .background(store.selectedDrinkType == type ? DS.SwiftUIColor.primary : DS.SwiftUIColor.primary.opacity(0.1))
      .clipShape(RoundedRectangle(cornerRadius: DS.Size.cornerRadiusMedium))
    }
  }
  
  private var hydrationInfoText: some View {
    Group {
      if store.selectedDrinkType != .water {
        Text(String(format: String(localized: "drink.type.hydration.info"), "\(Int(store.selectedDrinkType.hydrationFactor * 100))"))
          .font(DS.SwiftUIFont.caption)
          .foregroundStyle(DS.SwiftUIColor.textSecondary)
      }
    }
  }
  
  private var quickButtonsSection: some View {
    VStack(spacing: DS.Spacing.sm) {
      drinkTypePicker
      
      hydrationInfoText
      
      HStack {
        Text(isSubtractMode ? String(localized: "home.quick.subtract") : String(localized: "home.quick.add"))
          .font(DS.SwiftUIFont.subheadMedium)
          .foregroundStyle(.gray)

        Spacer()

        Button {
          withAnimation(.easeInOut(duration: 0.2)) {
            isSubtractMode.toggle()
          }
        } label: {
          HStack(spacing: DS.Spacing.xxs) {
            Text(isSubtractMode ? "−" : "+")
              .font(DS.SwiftUIFont.bodyBold)
            Image(systemName: "arrow.triangle.2.circlepath")
              .font(DS.SwiftUIFont.captionMedium)
          }
          .foregroundStyle(isSubtractMode ? .red : DS.SwiftUIColor.primary)
          .padding(.horizontal, DS.Spacing.sm)
          .padding(.vertical, DS.Spacing.xs)
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
        .font(DS.SwiftUIFont.subheadMedium)
        .foregroundStyle(.gray)
        .padding(.leading, DS.Spacing.xs)
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
    HStack(spacing: DS.Spacing.sm) {
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
            .font(DS.SwiftUIFont.footnoteSemibold)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: DS.Size.iconContainerLarge)
            .background(isSubtractMode ? Color.red.opacity(0.85) : DS.SwiftUIColor.primary)
            .clipShape(RoundedRectangle(cornerRadius: DS.Size.cornerRadiusMedium, style: .continuous))
            .shadow(color: .black.opacity(0.1), radius: DS.Spacing.xxs, y: 2)
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
      VStack(spacing: DS.Spacing.xl) {
        Text("\(Int(goal))ml")
          .font(DS.SwiftUIFont.display)
          .foregroundStyle(DS.SwiftUIColor.primary)
        
        Slider(value: $goal, in: 1000...4500, step: 100)
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
            .frame(height: DS.Size.buttonHeight)
            .background(DS.SwiftUIColor.primary)
            .clipShape(RoundedRectangle(cornerRadius: DS.Size.cornerRadiusMedium))
        }
        .padding(.horizontal)
      }
      .padding(.vertical, DS.Spacing.xl)
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
      VStack(spacing: DS.Spacing.xl) {
        Text("\(Int(store.ml))ml")
          .font(DS.SwiftUIFont.display)
          .foregroundStyle(DS.SwiftUIColor.primary)

        VStack(spacing: DS.Spacing.md) {
          Text(String(localized: "home.quick.subtract"))
            .font(DS.SwiftUIFont.subheadMedium)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)

          LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: DS.Spacing.sm) {
            ForEach(subtractAmounts, id: \.self) { amount in
              Button {
                Task {
                  await store.send(.subtractWater(amount))
                }
              } label: {
                Text("-\(amount)ml")
                  .font(DS.SwiftUIFont.bodySemibold)
                  .foregroundStyle(.white)
                  .frame(maxWidth: .infinity)
                  .frame(height: DS.Spacing.xxxxl)
                  .background(DS.SwiftUIColor.primary.opacity(0.8))
                  .clipShape(RoundedRectangle(cornerRadius: DS.Size.cornerRadiusMedium, style: .continuous))
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
          .font(DS.SwiftUIFont.bodyMedium)
          .foregroundStyle(.red)
          .frame(maxWidth: .infinity)
          .frame(height: DS.Spacing.xxxxl)
          .background(Color.red.opacity(0.1))
          .clipShape(RoundedRectangle(cornerRadius: DS.Size.cornerRadiusMedium, style: .continuous))
        }
        .padding(.horizontal)
        .disabled(store.ml <= 0)

        Spacer()
      }
      .padding(.vertical, DS.Spacing.xl)
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
