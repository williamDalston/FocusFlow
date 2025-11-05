import ClockKit
import SwiftUI

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Complication Configuration
    
    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        // Agent 15: Support all complication sizes
        let allFamilies: [CLKComplicationFamily] = [
            .circularSmall,
            .circularMedium,
            .utilitarianSmall,
            .utilitarianSmallFlat,
            .utilitarianLarge,
            .extraLarge,
            .graphicCorner,
            .graphicCircular,
            .graphicRectangular,
            .graphicBezel,
            .graphicExtraLarge,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
            .accessoryCorner
        ]
        
        let descriptors = [
            CLKComplicationDescriptor(
                identifier: "workout_streak",
                displayName: "Workout Streak",
                supportedFamilies: allFamilies
            ),
            CLKComplicationDescriptor(
                identifier: "workout_quick_start",
                displayName: "Quick Start",
                supportedFamilies: allFamilies
            ),
            CLKComplicationDescriptor(
                identifier: "workout_today",
                displayName: "Today's Workouts",
                supportedFamilies: allFamilies
            ),
            CLKComplicationDescriptor(
                identifier: "workout_progress",
                displayName: "Weekly Progress",
                supportedFamilies: allFamilies
            )
        ]
        handler(descriptors)
    }
    
    func handleSharedComplicationDescriptors(_ complicationDescriptors: [CLKComplicationDescriptor]) {
        // Handle shared complication descriptors
    }
    
    // MARK: - Timeline Configuration
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        // Timeline ends at midnight each day
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        let endOfDay = calendar.startOfDay(for: tomorrow)
        handler(endOfDay)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        handler(createTimelineEntry(for: complication, date: Date()))
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        var entries: [CLKComplicationTimelineEntry] = []
        var currentDate = date
        
        for _ in 0..<limit {
            if let entry = createTimelineEntry(for: complication, date: currentDate) {
                entries.append(entry)
            }
            currentDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate) ?? currentDate
        }
        
        handler(entries.isEmpty ? nil : entries)
    }
    
    // MARK: - Sample Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        handler(createSampleTemplate(for: complication))
    }
    
    // MARK: - Helper Methods
    
    private func createTimelineEntry(for complication: CLKComplication, date: Date) -> CLKComplicationTimelineEntry? {
        guard let template = createTemplate(for: complication, date: date) else { return nil }
        return CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
    }
    
    private func createTemplate(for complication: CLKComplication, date: Date) -> CLKComplicationTemplate? {
        switch complication.identifier {
        case "workout_streak":
            return createStreakTemplate(for: complication, date: date)
        case "workout_quick_start":
            return createQuickStartTemplate(for: complication, date: date)
        case "workout_today":
            return createTodayTemplate(for: complication, date: date)
        case "workout_progress":
            return createProgressTemplate(for: complication, date: date)
        default:
            return createStreakTemplate(for: complication, date: date)
        }
    }
    
    private func createStreakTemplate(for complication: CLKComplication, date: Date) -> CLKComplicationTemplate? {
        let streak = getCurrentStreak()
        let streakText = "\(streak)"
        
        switch complication.family {
        case .circularSmall:
            return CLKComplicationTemplateCircularSmallStackText(
                line1TextProvider: CLKSimpleTextProvider(text: streakText),
                line2TextProvider: CLKSimpleTextProvider(text: "Days")
            )
        case .circularMedium:
            return CLKComplicationTemplateCircularMediumStackText(
                line1TextProvider: CLKSimpleTextProvider(text: streakText),
                line2TextProvider: CLKSimpleTextProvider(text: "Day Streak")
            )
        case .utilitarianSmall:
            return CLKComplicationTemplateUtilitarianSmallFlat(
                textProvider: CLKSimpleTextProvider(text: "🔥\(streak)")
            )
        case .utilitarianSmallFlat:
            return CLKComplicationTemplateUtilitarianSmallFlat(
                textProvider: CLKSimpleTextProvider(text: "💪\(streak)")
            )
        case .utilitarianLarge:
            return CLKComplicationTemplateUtilitarianLargeFlat(
                textProvider: CLKSimpleTextProvider(text: "🔥 \(streak) Day Streak")
            )
        case .extraLarge:
            if #available(watchOS 7.0, *) {
                return CLKComplicationTemplateExtraLargeStackText(
                    line1TextProvider: CLKSimpleTextProvider(text: streakText),
                    line2TextProvider: CLKSimpleTextProvider(text: "Days")
                )
            }
            return nil
        case .graphicCorner:
            if #available(watchOS 7.0, *) {
                return CLKComplicationTemplateGraphicCornerStackText(
                    line1TextProvider: CLKSimpleTextProvider(text: "\(streak)"),
                    line2TextProvider: CLKSimpleTextProvider(text: "Day Streak")
                )
            }
            return nil
        case .graphicCircular:
            if #available(watchOS 7.0, *) {
                return CLKComplicationTemplateGraphicCircularStackText(
                    line1TextProvider: CLKSimpleTextProvider(text: streakText),
                    line2TextProvider: CLKSimpleTextProvider(text: "Days")
                )
            }
            return nil
        case .graphicRectangular:
            if #available(watchOS 7.0, *) {
                return CLKComplicationTemplateGraphicRectangularStackText(
                    line1TextProvider: CLKSimpleTextProvider(text: "Workout Streak"),
                    line2TextProvider: CLKSimpleTextProvider(text: "\(streak) Days")
                )
            }
            return nil
        case .graphicBezel:
            if #available(watchOS 7.0, *) {
                let circularTemplate = CLKComplicationTemplateGraphicCircularStackText(
                    line1TextProvider: CLKSimpleTextProvider(text: streakText),
                    line2TextProvider: CLKSimpleTextProvider(text: "Days")
                )
                return CLKComplicationTemplateGraphicBezelCircularText(
                    circularTemplate: circularTemplate,
                    textProvider: CLKSimpleTextProvider(text: "\(streak) Day Streak")
                )
            }
            return nil
        case .graphicExtraLarge:
            if #available(watchOS 7.0, *) {
                return CLKComplicationTemplateGraphicExtraLargeCircularStackText(
                    line1TextProvider: CLKSimpleTextProvider(text: streakText),
                    line2TextProvider: CLKSimpleTextProvider(text: "Days")
                )
            }
            return nil
        case .accessoryCircular:
            if #available(watchOS 9.0, *) {
                return CLKComplicationTemplateAccessoryCircularStackText(
                    line1TextProvider: CLKSimpleTextProvider(text: streakText),
                    line2TextProvider: CLKSimpleTextProvider(text: "Days")
                )
            }
            return nil
        case .accessoryRectangular:
            if #available(watchOS 9.0, *) {
                return CLKComplicationTemplateAccessoryRectangularStackText(
                    line1TextProvider: CLKSimpleTextProvider(text: "Workout Streak"),
                    line2TextProvider: CLKSimpleTextProvider(text: "\(streak) Days")
                )
            }
            return nil
        case .accessoryInline:
            if #available(watchOS 9.0, *) {
                return CLKComplicationTemplateAccessoryInlineStackText(
                    line1TextProvider: CLKSimpleTextProvider(text: "🔥 \(streak)"),
                    line2TextProvider: CLKSimpleTextProvider(text: "Day Streak")
                )
            }
            return nil
        case .accessoryCorner:
            if #available(watchOS 9.0, *) {
                return CLKComplicationTemplateAccessoryCornerStackText(
                    line1TextProvider: CLKSimpleTextProvider(text: streakText),
                    line2TextProvider: CLKSimpleTextProvider(text: "Days")
                )
            }
            return nil
        @unknown default:
            return nil
        }
    }
    
    private func createQuickStartTemplate(for complication: CLKComplication, date: Date) -> CLKComplicationTemplate? {
        let workoutImage = UIImage(systemName: "figure.run") ?? UIImage()
        let imageProvider = CLKImageProvider(onePieceImage: workoutImage)
        
        switch complication.family {
        case .circularSmall:
            return CLKComplicationTemplateCircularSmallSimpleImage(imageProvider: imageProvider)
        case .circularMedium:
            return CLKComplicationTemplateCircularMediumSimpleImage(imageProvider: imageProvider)
        case .utilitarianSmall:
            return CLKComplicationTemplateUtilitarianSmallFlat(
                textProvider: CLKSimpleTextProvider(text: "7 Min")
            )
        case .utilitarianSmallFlat:
            return CLKComplicationTemplateUtilitarianSmallFlat(
                textProvider: CLKSimpleTextProvider(text: "Start")
            )
        case .utilitarianLarge:
            return CLKComplicationTemplateUtilitarianLargeFlat(
                textProvider: CLKSimpleTextProvider(text: "7-Min Workout")
            )
        case .extraLarge:
            if #available(watchOS 7.0, *) {
                return CLKComplicationTemplateExtraLargeSimpleImage(imageProvider: imageProvider)
            }
            return nil
        case .graphicCorner:
            if #available(watchOS 7.0, *) {
                return CLKComplicationTemplateGraphicCornerStackImage(
                    line1ImageProvider: imageProvider,
                    line2TextProvider: CLKSimpleTextProvider(text: "7 Min")
                )
            }
            return nil
        case .graphicCircular:
            if #available(watchOS 7.0, *) {
                return CLKComplicationTemplateGraphicCircularSimpleImage(imageProvider: imageProvider)
            }
            return nil
        case .graphicRectangular:
            if #available(watchOS 7.0, *) {
                return CLKComplicationTemplateGraphicRectangularStackImage(
                    line1ImageProvider: imageProvider,
                    line2TextProvider: CLKSimpleTextProvider(text: "7-Minute Workout")
                )
            }
            return nil
        case .graphicBezel:
            if #available(watchOS 7.0, *) {
                let circularTemplate = CLKComplicationTemplateGraphicCircularSimpleImage(imageProvider: imageProvider)
                return CLKComplicationTemplateGraphicBezelCircularText(
                    circularTemplate: circularTemplate,
                    textProvider: CLKSimpleTextProvider(text: "Quick Start")
                )
            }
            return nil
        case .graphicExtraLarge:
            if #available(watchOS 7.0, *) {
                return CLKComplicationTemplateGraphicExtraLargeCircularSimpleImage(imageProvider: imageProvider)
            }
            return nil
        case .accessoryCircular:
            if #available(watchOS 9.0, *) {
                return CLKComplicationTemplateAccessoryCircularStackImage(
                    line1ImageProvider: imageProvider,
                    line2TextProvider: CLKSimpleTextProvider(text: "Start")
                )
            }
            return nil
        case .accessoryRectangular:
            if #available(watchOS 9.0, *) {
                return CLKComplicationTemplateAccessoryRectangularStackImage(
                    line1ImageProvider: imageProvider,
                    line2TextProvider: CLKSimpleTextProvider(text: "7-Min Workout")
                )
            }
            return nil
        case .accessoryInline:
            if #available(watchOS 9.0, *) {
                return CLKComplicationTemplateAccessoryInlineStackText(
                    line1TextProvider: CLKSimpleTextProvider(text: "🏃"),
                    line2TextProvider: CLKSimpleTextProvider(text: "7 Min")
                )
            }
            return nil
        case .accessoryCorner:
            if #available(watchOS 9.0, *) {
                return CLKComplicationTemplateAccessoryCornerStackImage(
                    line1ImageProvider: imageProvider,
                    line2TextProvider: CLKSimpleTextProvider(text: "Start")
                )
            }
            return nil
        @unknown default:
            return nil
        }
    }
    
    // Agent 15: Additional complication templates
    
    private func createTodayTemplate(for complication: CLKComplication, date: Date) -> CLKComplicationTemplate? {
        let todayWorkouts = getTodayWorkouts()
        let todayText = "\(todayWorkouts)"
        
        switch complication.family {
        case .circularSmall:
            return CLKComplicationTemplateCircularSmallStackText(
                line1TextProvider: CLKSimpleTextProvider(text: todayText),
                line2TextProvider: CLKSimpleTextProvider(text: "Today")
            )
        case .circularMedium:
            return CLKComplicationTemplateCircularMediumStackText(
                line1TextProvider: CLKSimpleTextProvider(text: todayText),
                line2TextProvider: CLKSimpleTextProvider(text: "Workouts Today")
            )
        case .utilitarianSmall:
            return CLKComplicationTemplateUtilitarianSmallFlat(
                textProvider: CLKSimpleTextProvider(text: "💪\(todayWorkouts)")
            )
        case .utilitarianLarge:
            return CLKComplicationTemplateUtilitarianLargeFlat(
                textProvider: CLKSimpleTextProvider(text: "\(todayWorkouts) Workouts Today")
            )
        case .graphicRectangular:
            if #available(watchOS 7.0, *) {
                return CLKComplicationTemplateGraphicRectangularStackText(
                    line1TextProvider: CLKSimpleTextProvider(text: "Today's Workouts"),
                    line2TextProvider: CLKSimpleTextProvider(text: "\(todayWorkouts)")
                )
            }
            return nil
        case .accessoryRectangular:
            if #available(watchOS 9.0, *) {
                return CLKComplicationTemplateAccessoryRectangularStackText(
                    line1TextProvider: CLKSimpleTextProvider(text: "Today"),
                    line2TextProvider: CLKSimpleTextProvider(text: "\(todayWorkouts) Workouts")
                )
            }
            return nil
        default:
            return createQuickStartTemplate(for: complication, date: date)
        }
    }
    
    private func createProgressTemplate(for complication: CLKComplication, date: Date) -> CLKComplicationTemplate? {
        let weeklyWorkouts = getWeeklyWorkouts()
        
        switch complication.family {
        case .utilitarianLarge:
            return CLKComplicationTemplateUtilitarianLargeFlat(
                textProvider: CLKSimpleTextProvider(text: "\(weeklyWorkouts) This Week")
            )
        case .graphicRectangular:
            if #available(watchOS 7.0, *) {
                return CLKComplicationTemplateGraphicRectangularStackText(
                    line1TextProvider: CLKSimpleTextProvider(text: "Weekly Progress"),
                    line2TextProvider: CLKSimpleTextProvider(text: "\(weeklyWorkouts) Workouts")
                )
            }
            return nil
        case .accessoryRectangular:
            if #available(watchOS 9.0, *) {
                return CLKComplicationTemplateAccessoryRectangularStackText(
                    line1TextProvider: CLKSimpleTextProvider(text: "This Week"),
                    line2TextProvider: CLKSimpleTextProvider(text: "\(weeklyWorkouts) Workouts")
                )
            }
            return nil
        default:
            return createStreakTemplate(for: complication, date: date)
        }
    }
    
    private func createSampleTemplate(for complication: CLKComplication) -> CLKComplicationTemplate? {
        switch complication.identifier {
        case "workout_streak":
            return createStreakTemplate(for: complication, date: Date())
        case "workout_quick_start":
            return createQuickStartTemplate(for: complication, date: Date())
        case "workout_today":
            return createTodayTemplate(for: complication, date: Date())
        case "workout_progress":
            return createProgressTemplate(for: complication, date: Date())
        default:
            return createStreakTemplate(for: complication, date: Date())
        }
    }
    
    // MARK: - Data Helpers
    
    private func getCurrentStreak() -> Int {
        // In a real implementation, you'd fetch this from WatchWorkoutStore
        // For now, return a sample value
        if let data = UserDefaults.standard.data(forKey: "watch_workout_streak"),
           let streak = try? JSONDecoder().decode(Int.self, from: data) {
            return streak
        }
        return UserDefaults.standard.integer(forKey: "watch_workout_streak")
    }
    
    private func getTodayWorkouts() -> Int {
        // Get today's workout count
        let calendar = Calendar.current
        let today = Date()
        // This would be fetched from WatchWorkoutStore in a real implementation
        return UserDefaults.standard.integer(forKey: "watch_today_workouts")
    }
    
    private func getWeeklyWorkouts() -> Int {
        // Get this week's workout count
        // This would be fetched from WatchWorkoutStore in a real implementation
        return UserDefaults.standard.integer(forKey: "watch_weekly_workouts")
    }
}

