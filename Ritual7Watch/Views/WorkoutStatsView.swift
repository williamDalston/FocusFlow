import SwiftUI
import HealthKit

/// Agent 15: Workout Stats View - Display heart rate zones, active calories, and workout stats during workout
struct WorkoutStatsView: View {
    @ObservedObject var heartRateMonitor: HeartRateMonitor
    @ObservedObject var workoutEngine: WorkoutEngineWatch
    
    // Calorie estimation
    private let caloriesPerMinute: Double = 7.0 // Average for HIIT
    
    var body: some View {
        VStack(spacing: 8) {
            // Heart Rate Section
            if let heartRate = heartRateMonitor.currentHeartRate {
                VStack(spacing: 4) {
                    HStack {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                            .foregroundStyle(.red)
                        
                        Text("\(Int(heartRate))")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.primary)
                        
                        Text("BPM")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    
                    // Heart Rate Zone
                    HStack(spacing: 4) {
                        Circle()
                            .fill(heartRateMonitor.heartRateZone.color)
                            .frame(width: 6, height: 6)
                        
                        Text(heartRateMonitor.heartRateZone.displayName)
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(heartRateMonitor.heartRateZone.color)
                    }
                }
                .padding(.vertical, 4)
            } else {
                // Heart rate not available
                VStack(spacing: 4) {
                    Image(systemName: "heart")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("--")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.secondary)
                    
                    Text("BPM")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
            
            Divider()
                .padding(.vertical, 2)
            
            // Active Calories Section
            VStack(spacing: 4) {
                HStack {
                    Image(systemName: "flame.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                    
                    Text("\(Int(activeCalories))")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.primary)
                    
                    Text("kcal")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)
            
            Divider()
                .padding(.vertical, 2)
            
            // Workout Stats
            VStack(spacing: 6) {
                // Exercise Progress
                HStack {
                    Text("Exercise")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text("\(workoutEngine.currentExerciseIndex + 1)/\(workoutEngine.exercises.count)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.primary)
                }
                
                // Time Elapsed
                if let duration = workoutEngine.currentSessionDuration {
                    HStack {
                        Text("Time")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Text(timeString(from: duration))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.primary)
                            .monospacedDigit()
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.green.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Computed Properties
    
    private var activeCalories: Double {
        guard let duration = workoutEngine.currentSessionDuration else {
            return 0
        }
        
        let minutes = duration / 60.0
        return minutes * caloriesPerMinute
    }
    
    // MARK: - Helpers
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Heart Rate Zone Color Extension

extension HeartRateMonitor.HeartRateZone {
    var color: Color {
        switch self {
        case .unknown: return .gray
        case .resting: return .blue
        case .warmUp: return .green
        case .fatBurn: return .yellow
        case .aerobic: return .orange
        case .anaerobic: return .red
        }
    }
}

