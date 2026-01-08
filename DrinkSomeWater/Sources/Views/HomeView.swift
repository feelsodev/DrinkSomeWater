import SwiftUI
import UIKit
import Analytics

struct HomeView: View {
  @Bindable var store: HomeStore
  @State private var showGoalSetting = false
  @State private var showQuickButtonSetting = false
  
  var body: some View {
    ZStack {
      WaveAnimationViewRepresentable(
        color: DS.Color.primaryLight,
        progress: 0.5,
        backgroundColor: DS.Color.backgroundPrimary
      )
      .ignoresSafeArea()
      
      VStack(spacing: 0) {
        headerSection
        
        Spacer(minLength: 16)
        
        bottleSection
        
        Spacer(minLength: 20)
        
        quickButtonsSection
      }
      .padding(.horizontal, 24)
      .padding(.bottom, 8)
    }
    .task {
      await store.send(.refreshGoal)
      await store.send(.refresh)
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
  }
  
  private var headerSection: some View {
    VStack(spacing: 4) {
      Text("\(Int(store.ml))ml")
        .font(.system(size: 48, weight: .bold))
        .foregroundStyle(DS.SwiftUIColor.textPrimary)
      
      Button {
        showGoalSetting = true
      } label: {
        HStack(spacing: 6) {
          Text("목표 \(Int(store.total))ml")
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
      
      messageCard
        .padding(.top, 8)
    }
    .padding(.top, 8)
  }
  
  private var messageCard: some View {
    HStack(spacing: 8) {
      Text(store.remainingMl <= 0 ? "🎉" : "💧")
        .font(.system(size: 20))
      
      Text(store.remainingMl <= 0 ? "오늘 목표 달성!" : "\(store.remainingCups)잔 더 마시면 목표 달성!")
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
        Text("빠른 추가")
          .font(.system(size: 14, weight: .medium))
          .foregroundStyle(.gray)
        
        Spacer()
        
        Button("편집") {
          showQuickButtonSetting = true
        }
        .font(.system(size: 14, weight: .medium))
        .foregroundStyle(.gray)
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
          Task { await store.send(.addWater(amount)) }
        } label: {
          Text("+\(amount)ml")
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(DS.SwiftUIColor.primary)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        }
      }
    }
  }
}

struct GoalSettingView: View {
  let currentGoal: Int
  let provider: ServiceProviderProtocol
  let onSave: () -> Void
  @Environment(\.dismiss) private var dismiss
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
          Text("1,000ml")
            .font(.caption)
            .foregroundStyle(.secondary)
          Spacer()
          Text("4,000ml")
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
          Text("저장")
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
      .navigationTitle("목표 설정")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("취소") { dismiss() }
        }
      }
    }
  }
}

struct QuickButtonSettingView: View {
  let currentButtons: [Int]
  let provider: ServiceProviderProtocol
  let onSave: () -> Void
  @Environment(\.dismiss) private var dismiss
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
        Section("현재 버튼") {
          ForEach(buttons, id: \.self) { amount in
            HStack {
              Text("+\(amount)ml")
              Spacer()
            }
          }
          .onDelete(perform: deleteButton)
          .onMove(perform: moveButton)
        }
        
        Section("새 버튼 추가") {
          HStack {
            TextField("용량 (ml)", text: $newAmount)
              .keyboardType(.numberPad)
            
            Button("추가") {
              if let amount = Int(newAmount), amount > 0 {
                buttons.append(amount)
                newAmount = ""
              }
            }
            .disabled(newAmount.isEmpty)
          }
        }
        
        Section {
          Button("기본값으로 초기화") {
            buttons = HomeStore.defaultQuickButtons
          }
          .foregroundStyle(.red)
        }
      }
      .navigationTitle("빠른 추가 버튼")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("취소") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("저장") {
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
