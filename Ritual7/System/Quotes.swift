import Foundation

/// Agent 7: Motivational quotes for workouts
enum Quotes {
    static let all = [
        "The only way to do great work is to love what you do. If you haven't found it yet, keep looking. Don't settle.",
        "What lies behind us and what lies before us are tiny matters compared to what lies within us.",
        "The body achieves what the mind believes. Every movement is a declaration of self-worth.",
        "You don't have to be great to start, but you have to start to be great. Every master was once a beginner.",
        "Courage doesn't always roar. Sometimes courage is the quiet voice at the end of the day saying, 'I will try again tomorrow.'",
        "The best time to plant a tree was 20 years ago. The second best time is now. Start where you are, use what you have.",
        "Strength doesn't come from what you can do. It comes from overcoming the things you once thought you couldn't.",
        "In the middle of difficulty lies opportunity. Every challenge is a chance to grow stronger.",
        "The future belongs to those who believe in the beauty of their dreams and have the courage to pursue them daily.",
        "Success is not final, failure is not fatal: it is the courage to continue that counts.",
        "The only person you are destined to become is the person you decide to be. Choose growth, choose strength.",
        "It is during our darkest moments that we must focus to see the light. Keep moving forward.",
        "The difference between who you are and who you want to be is what you do. Make it count.",
        "Your limitation—it's only your imagination. Push yourself beyond what you think you can do.",
        "Great things never come from comfort zones. Growth happens when you step into the unknown.",
        "The pain you feel today will be the strength you feel tomorrow. Every rep is building character.",
        "Don't watch the clock; do what it does. Keep going. Consistency is the key to transformation.",
        "The only bad workout is the one that didn't happen. Every effort counts, no matter how small.",
        "Your body can do it. It's your mind you need to convince. Trust in your inner strength.",
        "The best investment you can make is in yourself. This workout is a gift to your future self.",
        "Excellence is not a destination; it's a continuous journey that never ends. Today is another step forward.",
        "What you get by achieving your goals is not as important as what you become by achieving them.",
        "The only way of finding the limits of the possible is by going beyond them into the impossible.",
        "Believe you can and you're halfway there. Self-doubt is the only thing standing between you and your goals.",
        "Success is the sum of small efforts repeated day in and day out. Today matters more than you know.",
        "The secret of getting ahead is getting started. The hardest part is already behind you—you're here, you're ready.",
        "You are stronger than you know, more capable than you imagine, and more resilient than you believe.",
        "The only person you should try to be better than is the person you were yesterday. Progress, not perfection.",
        "Champions are made from something they have deep inside them—a desire, a dream, a vision. What's yours?",
        "It's not whether you get knocked down; it's whether you get back up. Resilience is built in moments like this.",
        "The moment you give up is the moment you let someone else win. Don't let that someone be your past self.",
        "Your workout is a celebration of what your body can do, not a punishment for what you ate. Honor your strength.",
        "The greatest glory in living lies not in never falling, but in rising every time we fall. Get back up, keep going.",
        "You miss 100% of the shots you don't take. Every workout you complete is a victory over the version of you who wouldn't.",
        "The way to get started is to quit talking and begin doing. You're doing it. Right now. Keep going.",
        "In the end, we only regret the chances we didn't take, the workouts we skipped, and the strength we left untested.",
        "The only impossible journey is the one you never begin. You've begun. Now see it through.",
        "Do what you can, with what you have, where you are. Your best is enough. Your effort is enough.",
        "Motivation gets you started, but discipline keeps you going. You're building discipline right now, one rep at a time.",
        "The future depends on what you do today. Make this moment count. Make yourself proud."
    ]

    static func today() -> String {
        let dayIndex = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return all[dayIndex % all.count]
    }
    
    static func random() -> String {
        return all.randomElement() ?? all[0]
    }
    
    /// Get a motivational message based on streak
    static func forStreak(_ streak: Int) -> String {
        switch streak {
        case 1:
            return "Every journey begins with a single step. You've taken yours. This is where transformation starts."
        case 7:
            return "🔥 Seven days of consistency! You've proven to yourself that you can. This is how habits are built, one day at a time."
        case 14:
            return "🌟 Two weeks of dedication! You're not just working out—you're rewriting your story. The best version of you is emerging."
        case 30:
            return "🎉 Thirty days of transformation! You've shown incredible discipline. This is no longer a habit—it's who you are becoming."
        case 50:
            return "💪 Fifty days of commitment! You've moved beyond motivation into mastery. You're not just exercising—you're evolving."
        case 100:
            return "🏆 One hundred days of excellence! You've achieved something that most only dream of. You are a true champion of your own life."
        default:
            if streak > 100 {
                return "🏅 \(streak) days of unwavering dedication! You've transcended habit and become an inspiration. Your consistency is legendary."
            } else if streak >= 30 {
                return "🌟 \(streak) days strong! Every single day you've chosen yourself, chosen growth, chosen strength. You're unstoppable."
            } else if streak >= 7 {
                return "🔥 \(streak) days of commitment! You're building something powerful—not just a streak, but a new way of living."
            } else {
                return "💪 Day \(streak) of your journey! Each day you show up, you're proving to yourself that you can. Keep honoring that commitment."
            }
        }
    }
    
    /// Get a motivational message for workout completion
    static func forWorkoutCompletion(totalWorkouts: Int) -> String {
        switch totalWorkouts {
        case 1:
            return "🎉 Your first workout is complete! The hardest part—starting—is behind you. You've proven you can do this."
        case 5:
            return "🌟 Five workouts conquered! You're building something special. Each session is an investment in your future self."
        case 10:
            return "🔥 Ten workouts strong! You're not just exercising—you're creating a new identity. Consistency is becoming your superpower."
        case 25:
            return "💪 Twenty-five workouts completed! You've transformed intention into action. This is no longer something you do—it's who you are."
        case 50:
            return "🏆 Fifty workouts achieved! You've shown the world and yourself what dedication looks like. You're unstoppable."
        case 100:
            return "🏅 One hundred workouts mastered! You've achieved something extraordinary. You are living proof that small, consistent actions create remarkable transformations."
        default:
            if totalWorkouts > 100 {
                return "🌟 \(totalWorkouts) workouts completed! You've transcended goals and entered the realm of mastery. Your dedication is inspiring."
            } else if totalWorkouts >= 50 {
                return "🔥 \(totalWorkouts) workouts strong! Every single one has made you stronger, mentally and physically. You're a true champion."
            } else if totalWorkouts >= 10 {
                return "💪 \(totalWorkouts) workouts done! You're building a legacy of health and strength, one workout at a time. Keep going!"
            } else {
                return "🎉 Another workout conquered! Each one makes you stronger, each one builds your confidence. You're doing amazing work!"
            }
        }
    }
}
