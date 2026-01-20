import Foundation
import Observation

@MainActor
final class ObservationToken {
  private var _cancelled = false
  private var observer: (() -> Void)?
  
  nonisolated func cancel() {
    MainActor.assumeIsolated {
      _cancelled = true
    }
  }
  
  var isCancelled: Bool { _cancelled }
  
  func startObserving(_ render: @escaping () -> Void) {
    observer = render
    runObservation()
  }
  
  private func runObservation() {
    guard !_cancelled, let render = observer else { return }
    withObservationTracking {
      render()
    } onChange: { [weak self] in
      Task { @MainActor [weak self] in
        self?.runObservation()
      }
    }
  }
}

@MainActor
func startObservation(_ render: @escaping @MainActor () -> Void) -> ObservationToken {
  let token = ObservationToken()
  token.startObserving(render)
  return token
}
