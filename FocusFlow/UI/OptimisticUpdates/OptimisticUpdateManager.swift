import SwiftUI
import Combine

/// Agent 26: Optimistic Update Manager
/// Manages optimistic UI updates - updates UI immediately before operations complete
@MainActor
final class OptimisticUpdateManager: ObservableObject {
    static let shared = OptimisticUpdateManager()
    
    @Published private(set) var pendingOperations: Set<String> = []
    @Published private(set) var undoStack: [UndoableOperation] = []
    
    private let maxUndoStackSize = 10
    
    private init() {}
    
    // MARK: - Public API
    
    /// Execute an operation with optimistic update
    /// - Parameters:
    ///   - id: Unique identifier for the operation
    ///   - optimisticAction: Action to perform optimistically (updates UI immediately)
    ///   - actualAction: Actual async operation to perform
    ///   - onError: Optional error handler - if provided, will revert optimistic update on error
    func execute<T>(
        id: String,
        optimisticAction: @escaping () -> Void,
        actualAction: @escaping () async throws -> T,
        onError: ((Error) -> Void)? = nil
    ) async -> T? {
        // Mark operation as pending
        pendingOperations.insert(id)
        
        // Perform optimistic update immediately
        optimisticAction()
        
        // Perform actual operation
        do {
            let result = try await actualAction()
            // Operation succeeded - remove from pending
            pendingOperations.remove(id)
            return result
        } catch {
            // Operation failed - revert optimistic update if error handler provided
            if let onError = onError {
                onError(error)
            }
            pendingOperations.remove(id)
            return nil
        }
    }
    
    /// Add an undoable operation to the undo stack
    func addUndoable(_ operation: UndoableOperation) {
        undoStack.append(operation)
        
        // Limit undo stack size
        if undoStack.count > maxUndoStackSize {
            undoStack.removeFirst()
        }
    }
    
    /// Undo the last operation
    func undoLast() {
        guard let lastOperation = undoStack.popLast() else { return }
        lastOperation.undo()
    }
    
    /// Check if an operation is pending
    func isPending(id: String) -> Bool {
        pendingOperations.contains(id)
    }
    
    /// Clear all pending operations (for testing/reset)
    func clearPending() {
        pendingOperations.removeAll()
    }
}

// MARK: - Undoable Operation

/// Agent 26: Represents an operation that can be undone
struct UndoableOperation: Identifiable {
    let id: String
    let description: String
    let undo: () -> Void
    let timestamp: Date
    
    init(id: String = UUID().uuidString, description: String, undo: @escaping () -> Void) {
        self.id = id
        self.description = description
        self.undo = undo
        self.timestamp = Date()
    }
}

// MARK: - View Modifier for Optimistic Updates

/// Agent 26: View modifier to show optimistic update state
struct OptimisticUpdateModifier: ViewModifier {
    @ObservedObject private var manager = OptimisticUpdateManager.shared
    let operationId: String
    
    func body(content: Content) -> some View {
        content
            .opacity(manager.isPending(id: operationId) ? 0.6 : 1.0)
            .animation(AnimationConstants.quickEase, value: manager.isPending(id: operationId))
    }
}

extension View {
    /// Apply optimistic update styling to a view
    func optimisticUpdate(id: String) -> some View {
        modifier(OptimisticUpdateModifier(operationId: id))
    }
}

