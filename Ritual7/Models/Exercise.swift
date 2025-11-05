import Foundation

/// Agent 2 & 3: Exercise Library - All 12 exercises from the NY Times 7-minute workout
struct Exercise: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let description: String
    let instructions: String
    let icon: String
    let order: Int
    
    // Agent 3: Exercise modifications and alternatives
    var modifications: [ExerciseModification] = []
    var alternatives: [ExerciseAlternative] = []
    var intensityLevel: IntensityLevel = .intermediate
    var muscleGroups: [MuscleGroup] = []
    var equipmentNeeded: EquipmentType = .none
    
    init(id: UUID = UUID(), name: String, description: String, instructions: String, icon: String, order: Int, modifications: [ExerciseModification] = [], alternatives: [ExerciseAlternative] = [], intensityLevel: IntensityLevel = .intermediate, muscleGroups: [MuscleGroup] = [], equipmentNeeded: EquipmentType = .none) {
        self.id = id
        self.name = name
        self.description = description
        self.instructions = instructions
        self.icon = icon
        self.order = order
        self.modifications = modifications
        self.alternatives = alternatives
        self.intensityLevel = intensityLevel
        self.muscleGroups = muscleGroups
        self.equipmentNeeded = equipmentNeeded
    }
    
    // MARK: - Agent 3: Exercise Metadata Types
    
    enum IntensityLevel: String, Codable, CaseIterable {
        case beginner = "beginner"
        case intermediate = "intermediate"
        case advanced = "advanced"
        
        var displayName: String {
            switch self {
            case .beginner: return "Beginner"
            case .intermediate: return "Intermediate"
            case .advanced: return "Advanced"
            }
        }
    }
    
    enum MuscleGroup: String, Codable, CaseIterable {
        case fullBody = "fullbody"
        case upperBody = "upperbody"
        case lowerBody = "lowerbody"
        case core = "core"
        case cardio = "cardio"
        case legs = "legs"
        case arms = "arms"
        case back = "back"
        case chest = "chest"
        
        var displayName: String {
            switch self {
            case .fullBody: return "Full Body"
            case .upperBody: return "Upper Body"
            case .lowerBody: return "Lower Body"
            case .core: return "Core"
            case .cardio: return "Cardio"
            case .legs: return "Legs"
            case .arms: return "Arms"
            case .back: return "Back"
            case .chest: return "Chest"
            }
        }
    }
    
    enum EquipmentType: String, Codable {
        case none = "none"
        case chair = "chair"
        case mat = "mat"
        case wall = "wall"
        
        var displayName: String {
            switch self {
            case .none: return "No Equipment"
            case .chair: return "Chair"
            case .mat: return "Mat"
            case .wall: return "Wall"
            }
        }
    }
    
    struct ExerciseModification: Codable, Hashable, Identifiable {
        let id: UUID
        let name: String
        let description: String
        let difficulty: IntensityLevel
        
        init(id: UUID = UUID(), name: String, description: String, difficulty: IntensityLevel) {
            self.id = id
            self.name = name
            self.description = description
            self.difficulty = difficulty
        }
    }
    
    struct ExerciseAlternative: Codable, Hashable, Identifiable {
        let id: UUID
        let name: String
        let description: String
        let reason: String // Why use this alternative (e.g., "Low impact", "No equipment")
        
        init(id: UUID = UUID(), name: String, description: String, reason: String) {
            self.id = id
            self.name = name
            self.description = description
            self.reason = reason
        }
    }
    
    /// The complete 7-minute workout routine with all 12 exercises
    static let sevenMinuteWorkout: [Exercise] = [
        Exercise(
            name: "Jumping Jacks",
            description: "Full-body cardio exercise",
            instructions: "Stand with feet together and arms at your sides. Jump up, spreading your legs while raising your arms overhead. Jump back to starting position. Repeat continuously.",
            icon: "figure.jumprope",
            order: 1,
            modifications: [
                ExerciseModification(name: "Low Impact", description: "Step out instead of jumping. Step right foot out, then left, bringing arms up. Step back in.", difficulty: .beginner)
            ],
            alternatives: [
                ExerciseAlternative(name: "Marching in Place", description: "Lift knees alternately while pumping arms overhead.", reason: "Low impact")
            ],
            intensityLevel: .intermediate,
            muscleGroups: [.fullBody, .cardio],
            equipmentNeeded: .none
        ),
        Exercise(
            name: "Wall Sit",
            description: "Isometric leg strength exercise",
            instructions: "Stand with your back against a wall. Slide down until your knees are at a 90-degree angle. Hold this position as if sitting in an invisible chair.",
            icon: "rectangle.portrait",
            order: 2,
            modifications: [
                ExerciseModification(name: "Shallow Wall Sit", description: "Slide down only halfway. Hold for shorter duration.", difficulty: .beginner),
                ExerciseModification(name: "Single Leg Wall Sit", description: "Lift one leg off the ground while holding the position.", difficulty: .advanced)
            ],
            alternatives: [
                ExerciseAlternative(name: "Chair Squat", description: "Stand in front of a chair, squat down to touch it, then stand back up.", reason: "Easier to perform")
            ],
            intensityLevel: .intermediate,
            muscleGroups: [.lowerBody, .legs],
            equipmentNeeded: .wall
        ),
        Exercise(
            name: "Push-up",
            description: "Upper body strength exercise",
            instructions: "Start in plank position with hands slightly wider than shoulders. Lower your body until chest nearly touches floor, then push back up. Keep core engaged.",
            icon: "figure.strengthtraining.functional",
            order: 3,
            modifications: [
                ExerciseModification(name: "Knee Push-up", description: "Perform push-ups on your knees instead of toes.", difficulty: .beginner),
                ExerciseModification(name: "Incline Push-up", description: "Place hands on a wall or elevated surface.", difficulty: .beginner),
                ExerciseModification(name: "Diamond Push-up", description: "Place hands in a diamond shape for triceps focus.", difficulty: .advanced)
            ],
            alternatives: [
                ExerciseAlternative(name: "Wall Push-up", description: "Stand facing a wall, place hands on wall and push.", reason: "No equipment needed, easier")
            ],
            intensityLevel: .intermediate,
            muscleGroups: [.upperBody, .chest, .arms],
            equipmentNeeded: .none
        ),
        Exercise(
            name: "Abdominal Crunch",
            description: "Core strengthening exercise",
            instructions: "Lie on your back with knees bent and feet flat on floor. Place hands behind head. Lift your shoulders off the ground, engaging your abs. Lower back down.",
            icon: "figure.core.training",
            order: 4,
            modifications: [
                ExerciseModification(name: "Knee Crunch", description: "Bring knees to chest while crunching up.", difficulty: .beginner),
                ExerciseModification(name: "Bicycle Crunch", description: "Alternate bringing opposite elbow to knee.", difficulty: .advanced)
            ],
            alternatives: [
                ExerciseAlternative(name: "Dead Bug", description: "Lie on back, extend opposite arm and leg, then return.", reason: "Low impact on neck")
            ],
            intensityLevel: .beginner,
            muscleGroups: [.core],
            equipmentNeeded: .mat
        ),
        Exercise(
            name: "Step-up onto Chair",
            description: "Lower body strength and balance",
            instructions: "Stand facing a sturdy chair. Step up with one foot onto the chair, then bring the other foot up. Step down and repeat, alternating leading leg.",
            icon: "figure.stairs",
            order: 5,
            modifications: [
                ExerciseModification(name: "Shallow Step-up", description: "Use a lower step or platform.", difficulty: .beginner),
                ExerciseModification(name: "Weighted Step-up", description: "Hold weights while stepping up.", difficulty: .advanced)
            ],
            alternatives: [
                ExerciseAlternative(name: "Lunges", description: "Step forward into a lunge position instead of stepping up.", reason: "No equipment needed")
            ],
            intensityLevel: .intermediate,
            muscleGroups: [.lowerBody, .legs],
            equipmentNeeded: .chair
        ),
        Exercise(
            name: "Squat",
            description: "Lower body strength exercise",
            instructions: "Stand with feet shoulder-width apart. Lower your body as if sitting in a chair, keeping knees behind toes. Return to standing position.",
            icon: "figure.flexibility",
            order: 6,
            modifications: [
                ExerciseModification(name: "Shallow Squat", description: "Only go down halfway. Focus on form.", difficulty: .beginner),
                ExerciseModification(name: "Jump Squat", description: "Jump up explosively from the squat position.", difficulty: .advanced)
            ],
            alternatives: [
                ExerciseAlternative(name: "Chair Squat", description: "Squat down to touch a chair, then stand back up.", reason: "Easier, helps with form")
            ],
            intensityLevel: .intermediate,
            muscleGroups: [.lowerBody, .legs],
            equipmentNeeded: .none
        ),
        Exercise(
            name: "Triceps Dip on Chair",
            description: "Upper body strength exercise",
            instructions: "Sit on edge of chair, hands gripping the edge. Slide forward until you're supporting your weight with your arms. Lower your body by bending elbows, then push back up.",
            icon: "figure.arms.open",
            order: 7,
            modifications: [
                ExerciseModification(name: "Bent Knee Dip", description: "Keep knees bent to reduce difficulty.", difficulty: .beginner),
                ExerciseModification(name: "Single Leg Dip", description: "Lift one leg while performing dips.", difficulty: .advanced)
            ],
            alternatives: [
                ExerciseAlternative(name: "Wall Push-up", description: "Stand facing wall, place hands on wall and push.", reason: "No equipment needed")
            ],
            intensityLevel: .intermediate,
            muscleGroups: [.upperBody, .arms],
            equipmentNeeded: .chair
        ),
        Exercise(
            name: "Plank",
            description: "Core strengthening exercise",
            instructions: "Start in push-up position. Keep your body in a straight line from head to heels. Hold this position, engaging your core. Don't let your hips sag or rise.",
            icon: "figure.mind.and.body",
            order: 8,
            modifications: [
                ExerciseModification(name: "Knee Plank", description: "Hold plank on knees instead of toes.", difficulty: .beginner),
                ExerciseModification(name: "Plank with Leg Lift", description: "Lift one leg while holding plank.", difficulty: .advanced)
            ],
            alternatives: [
                ExerciseAlternative(name: "Wall Plank", description: "Place hands on wall, lean forward into plank position.", reason: "Easier, no floor needed")
            ],
            intensityLevel: .intermediate,
            muscleGroups: [.core, .fullBody],
            equipmentNeeded: .none
        ),
        Exercise(
            name: "High Knees / Running in Place",
            description: "Cardio exercise",
            instructions: "Stand in place and run, bringing your knees up toward your chest as high as possible. Pump your arms as you would when running. Move at a brisk pace.",
            icon: "figure.run",
            order: 9,
            modifications: [
                ExerciseModification(name: "Slow High Knees", description: "Lift knees more slowly with control.", difficulty: .beginner),
                ExerciseModification(name: "Butt Kicks", description: "Kick heels up toward glutes instead of lifting knees.", difficulty: .intermediate)
            ],
            alternatives: [
                ExerciseAlternative(name: "Marching in Place", description: "March slowly, lifting knees alternately.", reason: "Low impact")
            ],
            intensityLevel: .intermediate,
            muscleGroups: [.cardio, .fullBody, .legs],
            equipmentNeeded: .none
        ),
        Exercise(
            name: "Lunge",
            description: "Lower body strength exercise",
            instructions: "Step forward with one leg, lowering your hips until both knees are bent at 90 degrees. Push back to starting position. Alternate legs.",
            icon: "figure.walk",
            order: 10,
            modifications: [
                ExerciseModification(name: "Shallow Lunge", description: "Take a smaller step forward, don't go as low.", difficulty: .beginner),
                ExerciseModification(name: "Jumping Lunge", description: "Jump to switch legs in lunge position.", difficulty: .advanced)
            ],
            alternatives: [
                ExerciseAlternative(name: "Reverse Lunge", description: "Step backward instead of forward into lunge.", reason: "Easier on knees")
            ],
            intensityLevel: .intermediate,
            muscleGroups: [.lowerBody, .legs],
            equipmentNeeded: .none
        ),
        Exercise(
            name: "Push-up and Rotation",
            description: "Upper body and core exercise",
            instructions: "Perform a push-up. At the top, rotate your body to one side, raising one arm toward the ceiling. Return to plank, do another push-up, then rotate to the other side.",
            icon: "arrow.triangle.2.circlepath",
            order: 11,
            modifications: [
                ExerciseModification(name: "Knee Push-up with Rotation", description: "Perform on knees with rotation.", difficulty: .beginner),
                ExerciseModification(name: "Plank Rotation", description: "Hold plank and rotate side to side without push-up.", difficulty: .intermediate)
            ],
            alternatives: [
                ExerciseAlternative(name: "Wall Push-up with Rotation", description: "Wall push-up followed by side rotation.", reason: "Easier, no floor needed")
            ],
            intensityLevel: .advanced,
            muscleGroups: [.upperBody, .core, .chest, .arms],
            equipmentNeeded: .none
        ),
        Exercise(
            name: "Side Plank",
            description: "Core and stability exercise",
            instructions: "Lie on your side with legs straight. Prop yourself up on your forearm, keeping your body in a straight line. Hold this position. Switch sides for the second round.",
            icon: "arrow.left.arrow.right",
            order: 12,
            modifications: [
                ExerciseModification(name: "Bent Knee Side Plank", description: "Keep bottom knee bent for support.", difficulty: .beginner),
                ExerciseModification(name: "Side Plank with Leg Lift", description: "Lift top leg while holding side plank.", difficulty: .advanced)
            ],
            alternatives: [
                ExerciseAlternative(name: "Standing Side Bend", description: "Stand with feet apart, lean to one side, reaching arm overhead.", reason: "Easier, no floor needed")
            ],
            intensityLevel: .intermediate,
            muscleGroups: [.core],
            equipmentNeeded: .none
        )
    ]
    
    // MARK: - Agent 6: Enhanced Exercise Guide Data
    
    /// Breathing cues for this exercise
    var breathingCues: String {
        switch name {
        case "Jumping Jacks": return "Breathe naturally and rhythmically. Inhale as you jump out, exhale as you jump back in."
        case "Wall Sit": return "Breathe steadily and deeply. Don't hold your breath—maintain normal breathing throughout."
        case "Push-up": return "Inhale as you lower down, exhale as you push back up."
        case "Abdominal Crunch": return "Exhale as you crunch up, inhale as you lower back down."
        case "Step-up onto Chair": return "Exhale as you step up, inhale as you step down."
        case "Squat": return "Inhale as you lower down, exhale as you stand back up."
        case "Triceps Dip on Chair": return "Inhale as you lower down, exhale as you push back up."
        case "Plank": return "Breathe steadily and deeply. Don't hold your breath—maintain normal breathing."
        case "High Knees / Running in Place": return "Breathe naturally and rhythmically, matching your breathing to your pace."
        case "Lunge": return "Inhale as you step forward and lower, exhale as you push back to starting position."
        case "Push-up and Rotation": return "Inhale as you lower, exhale as you push up, exhale as you rotate."
        case "Side Plank": return "Breathe steadily and deeply. Maintain normal breathing throughout the hold."
        default: return "Breathe steadily and naturally throughout the exercise."
        }
    }
    
    /// Safety warnings for this exercise
    var safetyWarnings: [String] {
        switch name {
        case "Jumping Jacks":
            return [
                "Land softly to protect your knees and ankles",
                "Stop if you feel knee or ankle pain",
                "Use a low-impact version if you have joint issues"
            ]
        case "Wall Sit":
            return [
                "Ensure your knees don't go past your toes",
                "Stop if you feel knee pain",
                "Keep your back flat against the wall"
            ]
        case "Push-up":
            return [
                "Keep your core engaged to protect your lower back",
                "Stop if you feel wrist, shoulder, or back pain",
                "Use knee push-ups if full push-ups are too difficult"
            ]
        case "Abdominal Crunch":
            return [
                "Don't pull on your neck—let your abs do the work",
                "Keep your lower back on the ground",
                "Stop if you feel neck or back pain"
            ]
        case "Step-up onto Chair":
            return [
                "Use a sturdy, stable chair that won't move",
                "Ensure the chair is at a safe height",
                "Step up with your entire foot for better balance"
            ]
        case "Squat":
            return [
                "Keep your weight in your heels",
                "Ensure your knees don't go past your toes",
                "Stop if you feel knee or back pain"
            ]
        case "Triceps Dip on Chair":
            return [
                "Use a sturdy, stable chair that won't tip",
                "Keep your shoulders away from your ears",
                "Stop if you feel shoulder or wrist pain"
            ]
        case "Plank":
            return [
                "Keep your body in a straight line",
                "Stop if you feel lower back pain",
                "Don't let your hips sag or rise too high"
            ]
        case "High Knees / Running in Place":
            return [
                "Land softly to protect your joints",
                "Stop if you feel knee or ankle pain",
                "Use a slower pace if needed"
            ]
        case "Lunge":
            return [
                "Keep your front knee over your ankle",
                "Don't let your front knee go past your toes",
                "Stop if you feel knee pain"
            ]
        case "Push-up and Rotation":
            return [
                "Complete the push-up with proper form first",
                "Rotate your whole body, not just your arms",
                "Stop if you feel shoulder, back, or core pain"
            ]
        case "Side Plank":
            return [
                "Keep your body in a straight line",
                "Don't let your hips sag",
                "Stop if you feel shoulder or core pain"
            ]
        default:
            return [
                "Listen to your body and stop if you feel pain",
                "Focus on proper form over speed",
                "Consult a doctor if you have any concerns"
            ]
        }
    }
    
    /// Common mistakes to avoid
    var commonMistakes: [String] {
        switch name {
        case "Jumping Jacks":
            return [
                "Landing too hard on your heels",
                "Not fully extending arms overhead",
                "Going too fast and losing control"
            ]
        case "Wall Sit":
            return [
                "Letting knees go past toes",
                "Lifting back off the wall",
                "Holding your breath"
            ]
        case "Push-up":
            return [
                "Sagging hips or raising them too high",
                "Not going low enough",
                "Flaring elbows out too wide"
            ]
        case "Abdominal Crunch":
            return [
                "Pulling on your neck with your hands",
                "Lifting your lower back off the ground",
                "Going too fast and using momentum"
            ]
        case "Step-up onto Chair":
            return [
                "Using only your toes instead of your full foot",
                "Not engaging your core for balance",
                "Rushing the movement"
            ]
        case "Squat":
            return [
                "Letting knees cave inward",
                "Leaning too far forward",
                "Not going low enough"
            ]
        case "Triceps Dip on Chair":
            return [
                "Shrugging shoulders up to ears",
                "Not lowering deep enough",
                "Using legs too much to assist"
            ]
        case "Plank":
            return [
                "Sagging hips toward the ground",
                "Raising hips too high",
                "Looking up instead of down"
            ]
        case "High Knees / Running in Place":
            return [
                "Not bringing knees high enough",
                "Not pumping arms",
                "Landing too hard on heels"
            ]
        case "Lunge":
            return [
                "Front knee going past toes",
                "Back knee touching the ground (not recommended)",
                "Not keeping torso upright"
            ]
        case "Push-up and Rotation":
            return [
                "Rotating only arms instead of whole body",
                "Rushing the rotation",
                "Not completing the push-up first"
            ]
        case "Side Plank":
            return [
                "Letting hips sag toward the ground",
                "Not keeping body in a straight line",
                "Putting too much weight on the bottom shoulder"
            ]
        default:
            return [
                "Sacrificing form for speed",
                "Not breathing properly",
                "Not listening to your body"
            ]
        }
    }
}

