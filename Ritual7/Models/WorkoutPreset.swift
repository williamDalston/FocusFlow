import Foundation

/// Agent 3: Workout Preset - Predefined workout configurations
enum WorkoutPreset: String, Codable, CaseIterable, Identifiable {
    case full7 = "full7"
    case quick5 = "quick5"
    case extended10 = "extended10"
    case beginnerFriendly = "beginner"
    case advancedChallenge = "advanced"
    case absFocus = "abs"
    case fullBody = "fullbody"
    case morningEnergizer = "morning"
    case eveningStretch = "evening"
    case officeBreak = "office"
    case travelFriendly = "travel"
    case recoveryDay = "recovery"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .full7: return "Full 7"
        case .quick5: return "Quick 5"
        case .extended10: return "Extended 10"
        case .beginnerFriendly: return "Beginner Friendly"
        case .advancedChallenge: return "Advanced Challenge"
        case .absFocus: return "Abs Focus"
        case .fullBody: return "Full Body"
        case .morningEnergizer: return "Morning Energizer"
        case .eveningStretch: return "Evening Stretch"
        case .officeBreak: return "Office Break"
        case .travelFriendly: return "Travel Friendly"
        case .recoveryDay: return "Recovery Day"
        }
    }
    
    var description: String {
        switch self {
        case .full7: return "The classic 12-exercise routine. 7 minutes of full-body fitness."
        case .quick5: return "5 exercises in 3 minutes. Perfect for a quick burst of energy."
        case .extended10: return "10 exercises for a more challenging 10-minute workout."
        case .beginnerFriendly: return "Lower intensity with longer rest periods. Perfect for beginners."
        case .advancedChallenge: return "Higher intensity with shorter rest. For experienced exercisers."
        case .absFocus: return "Core-focused exercises targeting your abs and core strength."
        case .fullBody: return "Balanced selection targeting all major muscle groups."
        case .morningEnergizer: return "Wake up your body with energizing movements."
        case .eveningStretch: return "Gentle movements to unwind after a long day."
        case .officeBreak: return "Desk-friendly exercises you can do anywhere."
        case .travelFriendly: return "No equipment needed, perfect for hotel rooms."
        case .recoveryDay: return "Low-impact movements for active recovery days."
        }
    }
    
    var icon: String {
        switch self {
        case .full7: return "figure.run"
        case .quick5: return "bolt.fill"
        case .extended10: return "timer"
        case .beginnerFriendly: return "figure.walk"
        case .advancedChallenge: return "flame.fill"
        case .absFocus: return "figure.core.training"
        case .fullBody: return "figure.strengthtraining.functional"
        case .morningEnergizer: return "sun.max.fill"
        case .eveningStretch: return "moon.fill"
        case .officeBreak: return "briefcase.fill"
        case .travelFriendly: return "airplane"
        case .recoveryDay: return "leaf.fill"
        }
    }
    
    var exerciseIndices: [Int] {
        switch self {
        case .full7:
            return Array(0..<12) // All 12 exercises
        case .quick5:
            return [0, 2, 4, 6, 8] // Jumping Jacks, Push-up, Step-up, Triceps Dip, High Knees
        case .extended10:
            return Array(0..<10) // First 10 exercises
        case .beginnerFriendly:
            return [0, 2, 4, 6, 8, 10] // Lower intensity exercises
        case .advancedChallenge:
            return [1, 3, 5, 7, 9, 11] // Higher intensity exercises
        case .absFocus:
            return [3, 7, 11] // Abdominal Crunch, Plank, Side Plank
        case .fullBody:
            return [0, 2, 4, 5, 6, 8] // Balanced selection
        case .morningEnergizer:
            return [0, 2, 4, 8] // Cardio and energizing movements
        case .eveningStretch:
            return [1, 5, 7, 11] // Lower intensity, stretching-friendly
        case .officeBreak:
            return [1, 3, 7, 11] // Wall Sit, Crunch, Plank, Side Plank (desk-friendly)
        case .travelFriendly:
            return [0, 2, 3, 5, 7, 9] // No equipment needed
        case .recoveryDay:
            return [1, 3, 7] // Wall Sit, Crunch, Plank (low impact)
        }
    }
    
    var exerciseDuration: TimeInterval {
        switch self {
        case .full7: return 30.0
        case .quick5: return 20.0
        case .extended10: return 35.0
        case .beginnerFriendly: return 25.0
        case .advancedChallenge: return 45.0
        case .absFocus: return 40.0
        case .fullBody: return 30.0
        case .morningEnergizer: return 30.0
        case .eveningStretch: return 25.0
        case .officeBreak: return 20.0
        case .travelFriendly: return 30.0
        case .recoveryDay: return 20.0
        }
    }
    
    var restDuration: TimeInterval {
        switch self {
        case .full7: return 10.0
        case .quick5: return 5.0
        case .extended10: return 15.0
        case .beginnerFriendly: return 15.0
        case .advancedChallenge: return 5.0
        case .absFocus: return 10.0
        case .fullBody: return 10.0
        case .morningEnergizer: return 10.0
        case .eveningStretch: return 15.0
        case .officeBreak: return 10.0
        case .travelFriendly: return 10.0
        case .recoveryDay: return 20.0
        }
    }
    
    var prepDuration: TimeInterval {
        switch self {
        case .full7: return 10.0
        case .quick5: return 5.0
        case .extended10: return 10.0
        case .beginnerFriendly: return 10.0
        case .advancedChallenge: return 5.0
        case .absFocus: return 10.0
        case .fullBody: return 10.0
        case .morningEnergizer: return 5.0
        case .eveningStretch: return 10.0
        case .officeBreak: return 5.0
        case .travelFriendly: return 10.0
        case .recoveryDay: return 10.0
        }
    }
    
    var skipPrepTime: Bool {
        switch self {
        case .quick5, .advancedChallenge, .morningEnergizer, .officeBreak:
            return true
        default:
            return false
        }
    }
    
    var estimatedDuration: TimeInterval {
        let prep = skipPrepTime ? 0 : prepDuration
        let exercises = Double(exerciseIndices.count) * exerciseDuration
        let rest = Double(exerciseIndices.count - 1) * restDuration
        return prep + exercises + rest
    }
    
    var estimatedMinutes: Int {
        Int(ceil(estimatedDuration / 60.0))
    }
}


