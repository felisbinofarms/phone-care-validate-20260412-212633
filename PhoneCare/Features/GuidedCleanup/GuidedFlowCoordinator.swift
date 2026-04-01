import SwiftUI

struct FlowStep: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let isSkippable: Bool
}

@MainActor
@Observable
final class GuidedFlowCoordinator {

    // MARK: - State

    let flowType: GuidedFlowType
    let steps: [FlowStep]
    private(set) var currentStepIndex: Int = 0
    private(set) var isComplete: Bool = false
    private(set) var completedSteps: Set<String> = []

    // Stats for completion screen
    private(set) var itemsCleaned: Int = 0
    private(set) var bytesFreed: Int64 = 0

    // MARK: - Computed

    var currentStep: FlowStep? {
        guard currentStepIndex < steps.count else { return nil }
        return steps[currentStepIndex]
    }

    var progress: Double {
        guard !steps.isEmpty else { return 1.0 }
        return Double(currentStepIndex) / Double(steps.count)
    }

    var totalSteps: Int { steps.count }
    var currentStepNumber: Int { currentStepIndex + 1 }

    var canGoBack: Bool { currentStepIndex > 0 }
    var canGoForward: Bool { currentStepIndex < steps.count - 1 }

    // MARK: - Init

    init(flowType: GuidedFlowType, steps: [FlowStep]) {
        self.flowType = flowType
        self.steps = steps
    }

    // MARK: - Navigation

    func next() {
        if let step = currentStep {
            completedSteps.insert(step.id)
        }
        if currentStepIndex < steps.count - 1 {
            currentStepIndex += 1
        } else {
            isComplete = true
        }
    }

    func back() {
        if currentStepIndex > 0 {
            currentStepIndex -= 1
        }
    }

    func skip() {
        next()
    }

    func recordCleanup(items: Int, bytes: Int64) {
        itemsCleaned += items
        bytesFreed += bytes
    }
}
