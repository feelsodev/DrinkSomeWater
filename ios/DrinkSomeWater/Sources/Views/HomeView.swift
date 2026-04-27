import SwiftUI
import StoreKit
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
  @SwiftUI.Environment(\.requestReview) private var requestReview
  
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
    .onChange(of: store.showingRewardedAd) { _, showing in
      guard showing else { return }
      Task {
        let success = await store.provider.rewardedAdCoordinator.showRewardedAd()
        await store.send(.rewardedAdCompleted(success: success))
      }
    }
    .onChange(of: store.shouldRequestReview) { _, shouldRequest in
      guard shouldRequest else { return }
      store.shouldRequestReview = false
      Task {
        try? await Task.sleep(for: .seconds(2))
        requestReview()
      }
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
      L.Share.titleExtended,
      isPresented: $showShareSheet,
      titleVisibility: .visible
    ) {
      Button(L.Share.instagramStories) {
        Task { await shareToInstagram(destination: .stories) }
      }
      Button(L.Share.instagramFeed) {
        Task { await shareToInstagram(destination: .feed) }
      }
      Button(L.Share.system) {
        Task { await shareViaSystemSheet() }
      }
      Button(L.Home.goalCancel, role: .cancel) {}
    }
    .alert(
      L.Share.errorTitle,
      isPresented: $showInstagramNotInstalledAlert
    ) {
      Button(L.Share.errorOk, role: .cancel) {}
    } message: {
      Text(L.Share.errorInstagramNotInstalled)
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
           .accessibilityLabel(L.Accessibility.homeCurrent(Int(store.ml)))
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
         .accessibilityLabel(L.Accessibility.homeShare)
       }

       Button {
         showGoalSetting = true
       } label: {
         HStack(spacing: DS.Spacing.xs) {
           Text(L.Home.goal("\(Int(store.total))"))
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
       .accessibilityLabel(L.Accessibility.homeGoal(Int(store.total)))
       .accessibilityHint(L.Accessibility.homeGoalHint)
      
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

       Text(store.remainingMl <= 0 ? L.Home.goalAchieved : L.Home.goalRemaining("\(store.remainingCups)"))
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
         Text(L.Home.notificationBannerTitle)
           .font(DS.SwiftUIFont.subheadSemibold)
           .foregroundStyle(DS.SwiftUIColor.textPrimary)
         Text(L.Home.notificationBannerDescription)
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
         Text(L.Home.notificationBannerSettings)
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
   
    private var quickButtonsSection: some View {
      VStack(spacing: DS.Spacing.sm) {
        HStack {
         Text(isSubtractMode ? L.Home.quickSubtract : L.Home.quickAdd)
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
           ? L.Accessibility.homeModeSubtract
           : L.Accessibility.homeModeAdd)
         .accessibilityHint(L.Accessibility.homeModeHint)

         Button(L.Home.edit) {
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
           ? L.Accessibility.homeSubtract(amount)
           : L.Accessibility.homeAdd(amount))
         .accessibilityHint(isSubtractMode
           ? L.Accessibility.homeSubtractHint
           : L.Accessibility.homeAddHint)
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
           Text(L.Home.goalMin)
             .font(.caption)
             .foregroundStyle(.secondary)
           Spacer()
           Text(L.Home.goalMax)
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
           Text(L.Home.goalSave)
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
       .navigationTitle(L.Home.goalSettingTitle)
       .navigationBarTitleDisplayMode(.inline)
       .toolbar {
         ToolbarItem(placement: .cancellationAction) {
           Button(L.Home.goalCancel) { dismiss() }
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
         Section(L.Home.quickButtonCurrent) {
           ForEach(buttons, id: \.self) { amount in
             HStack {
               Text("+\(amount)ml")
               Spacer()
             }
           }
           .onDelete(perform: deleteButton)
           .onMove(perform: moveButton)
         }

         Section(L.Home.quickButtonAddSection) {
           HStack {
             TextField(L.Home.quickButtonPlaceholder, text: $newAmount)
               .keyboardType(.numberPad)

             Button(L.Home.quickButtonAdd) {
               if let amount = Int(newAmount), amount > 0 {
                 buttons.append(amount)
                 newAmount = ""
               }
             }
             .disabled(newAmount.isEmpty)
           }
         }

         Section {
           Button(L.Home.quickButtonReset) {
             buttons = HomeStore.defaultQuickButtons
           }
           .foregroundStyle(.red)
         }
       }
       .navigationTitle(L.Home.quickButtonTitle)
       .navigationBarTitleDisplayMode(.inline)
       .toolbar {
         ToolbarItem(placement: .cancellationAction) {
           Button(L.Home.goalCancel) { dismiss() }
         }
         ToolbarItem(placement: .confirmationAction) {
           Button(L.Home.goalSave) {
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
           Text(L.Home.quickSubtract)
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
             Text(L.Home.adjustmentReset)
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
       .navigationTitle(L.Home.adjustmentTitle)
       .navigationBarTitleDisplayMode(.inline)
       .toolbar {
         ToolbarItem(placement: .confirmationAction) {
           Button(L.Home.adjustmentDone) { dismiss() }
         }
       }
       .confirmationDialog(
         L.Home.adjustmentResetConfirm,
         isPresented: $showResetConfirmation,
         titleVisibility: .visible
       ) {
         Button(L.Home.adjustmentResetButton, role: .destructive) {
           Task {
             await store.send(.resetTodayWater)
           }
         }
         Button(L.Home.goalCancel, role: .cancel) {}
       } message: {
         Text(L.Home.adjustmentResetMessage)
       }
    }
  }
}
