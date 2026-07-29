//
//  BackgroundWorker.swift
//  AutoCare
//

import Foundation

actor BackgroundWorker {
    static let shared = BackgroundWorker()
    private init() {}

    private let semaphore = AsyncSemaphore(value: 2)

    nonisolated func run(
        priority: TaskPriority = .background,
        _ work: @escaping () async throws -> Void
    ) {
        Task.detached(priority: priority) {
            await self.execute(work)
        }
    }

    private func execute(
        _ work: @escaping () async throws -> Void
    ) async {
        await semaphore.wait()

        do {
            try await work()
        } catch {
            print("BackgroundWorker error:", error)
        }

        await semaphore.signal()
    }
}
