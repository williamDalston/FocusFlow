import ClockKit
import SwiftUI
import Foundation

/// Complication controller for Apple Watch
/// Provides complications for focus streak, quick start, today's sessions, and weekly progress
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
                identifier: "focus_streak",
                displayName: "Focus Streak",
                supportedFamilies: allFamilies
            ),
            CLKComplicationDescriptor(
                identifier: "focus_quick_start",
                displayName: "Quick Start",
                supportedFamilies: allFamilies
            ),
            CLKComplicationDescriptor(
                identifier: "focus_today",
                displayName: "Today's Focus",
                supportedFamilies: allFamilies
            ),
            CLKComplicationDescriptor(
                identifier: "focus_progress",
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
        case "focus_streak":
            return createStreakTemplate(for: complication, date: date)
        case "focus_quick_start":
            return createQuickStartTemplate(for: complication, date: date)
        case "focus_today":
            return createTodayTemplate(for: complication, date: date)
        case "focus_progress":
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
                textProvider: CLKSimpleTextProvider(text: "🧠\(streak)")
            )
        case .utilitarianSmallFlat:
            return CLKComplicationTemplateUtilitarianSmallFlat(
                textProvider: CLKSimpleTextProvider(text: "🍅\(streak)")
            )
        case .utilitarianLarge:
            return CLKComplicationTemplateUtilitarianLargeFlat(
                textProvider: CLKSimpleTextProvider(text: "🧠 \(streak) Day Streak")
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
                    line1TextProvider: CLKSimpleTextProvider(text: "Focus Streak"),
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
                    line1TextProvider: CLKSimpleTextProvider(text: "Focus Streak"),
                    line2TextProvider: CLKSimpleTextProvider(text: "\(streak) Days")
                )
            }
            return nil
        case .accessoryInline:
            if #available(watchOS 9.0, *) {
                return CLKComplicationTemplateAccessoryInlineStackText(
                    line1TextProvider: CLKSimpleTextProvider(text: "🧠 \(streak)"),
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
        let focusImage = UIImage(systemName: "brain.head.profile") ?? UIImage()
        let imageProvider = CLKImageProvider(onePieceImage: focusImage)
        
        switch complication.family {
        case .circularSmall:
            return CLKComplicationTemplateCircularSmallSimpleImage(imageProvider: imageProvider)
        case .circularMedium:
            return CLKComplicationTemplateCircularMediumSimpleImage(imageProvider: imageProvider)
        case .utilitarianSmall:
            return CLKComplicationTemplateUtilitarianSmallFlat(
                textProvider: CLKSimpleTextProvider(text: "25 Min")
            )
        case .utilitarianSmallFlat:
            return CLKComplicationTemplateUtilitarianSmallFlat(
                textProvider: CLKSimpleTextProvider(text: "Focus")
            )
        case .utilitarianLarge:
            return CLKComplicationTemplateUtilitarianLargeFlat(
                textProvider: CLKSimpleTextProvider(text: "Start Focus")
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
                    line2TextProvider: CLKSimpleTextProvider(text: "Focus")
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
                    line2TextProvider: CLKSimpleTextProvider(text: "Pomodoro Timer")
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
                    line2TextProvider: CLKSimpleTextProvider(text: "Pomodoro")
                )
            }
            return nil
        case .accessoryInline:
            if #available(watchOS 9.0, *) {
                return CLKComplicationTemplateAccessoryInlineStackText(
                    line1TextProvider: CLKSimpleTextProvider(text: "🧠"),
                    line2TextProvider: CLKSimpleTextProvider(text: "Focus")
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
        let todaySessions = getTodaySessions()
        let todayText = "\(todaySessions)"
        
        switch complication.family {
        case .circularSmall:
            return CLKComplicationTemplateCircularSmallStackText(
                line1TextProvider: CLKSimpleTextProvider(text: todayText),
                line2TextProvider: CLKSimpleTextProvider(text: "Today")
            )
        case .circularMedium:
            return CLKComplicationTemplateCircularMediumStackText(
                line1TextProvider: CLKSimpleTextProvider(text: todayText),
                line2TextProvider: CLKSimpleTextProvider(text: "Sessions Today")
            )
        case .utilitarianSmall:
            return CLKComplicationTemplateUtilitarianSmallFlat(
                textProvider: CLKSimpleTextProvider(text: "🧠\(todaySessions)")
            )
        case .utilitarianLarge:
            return CLKComplicationTemplateUtilitarianLargeFlat(
                textProvider: CLKSimpleTextProvider(text: "\(todaySessions) Sessions Today")
            )
        case .graphicRectangular:
            if #available(watchOS 7.0, *) {
                return CLKComplicationTemplateGraphicRectangularStackText(
                    line1TextProvider: CLKSimpleTextProvider(text: "Today's Focus"),
                    line2TextProvider: CLKSimpleTextProvider(text: "\(todaySessions)")
                )
            }
            return nil
        case .accessoryRectangular:
            if #available(watchOS 9.0, *) {
                return CLKComplicationTemplateAccessoryRectangularStackText(
                    line1TextProvider: CLKSimpleTextProvider(text: "Today"),
                    line2TextProvider: CLKSimpleTextProvider(text: "\(todaySessions) Sessions")
                )
            }
            return nil
        default:
            return createQuickStartTemplate(for: complication, date: date)
        }
    }
    
    private func createProgressTemplate(for complication: CLKComplication, date: Date) -> CLKComplicationTemplate? {
        let weeklySessions = getWeeklySessions()
        
        switch complication.family {
        case .utilitarianLarge:
            return CLKComplicationTemplateUtilitarianLargeFlat(
                textProvider: CLKSimpleTextProvider(text: "\(weeklySessions) This Week")
            )
        case .graphicRectangular:
            if #available(watchOS 7.0, *) {
                return CLKComplicationTemplateGraphicRectangularStackText(
                    line1TextProvider: CLKSimpleTextProvider(text: "Weekly Progress"),
                    line2TextProvider: CLKSimpleTextProvider(text: "\(weeklySessions) Sessions")
                )
            }
            return nil
        case .accessoryRectangular:
            if #available(watchOS 9.0, *) {
                return CLKComplicationTemplateAccessoryRectangularStackText(
                    line1TextProvider: CLKSimpleTextProvider(text: "This Week"),
                    line2TextProvider: CLKSimpleTextProvider(text: "\(weeklySessions) Sessions")
                )
            }
            return nil
        default:
            return createStreakTemplate(for: complication, date: date)
        }
    }
    
    private func createSampleTemplate(for complication: CLKComplication) -> CLKComplicationTemplate? {
        switch complication.identifier {
        case "focus_streak":
            return createStreakTemplate(for: complication, date: Date())
        case "focus_quick_start":
            return createQuickStartTemplate(for: complication, date: Date())
        case "focus_today":
            return createTodayTemplate(for: complication, date: Date())
        case "focus_progress":
            return createProgressTemplate(for: complication, date: Date())
        default:
            return createStreakTemplate(for: complication, date: Date())
        }
    }
    
    // MARK: - Data Helpers
    
    private func getCurrentStreak() -> Int {
        // Fetch from UserDefaults (synced by WatchFocusStore)
        return UserDefaults.standard.integer(forKey: "watch_focus_streak")
    }
    
    private func getTodaySessions() -> Int {
        // Get today's focus session count from stored sessions
        let calendar = Calendar.current
        let today = Date()
        
        // Load sessions from UserDefaults
        if let data = UserDefaults.standard.data(forKey: "watch_focus_sessions"),
           let sessions = try? JSONDecoder().decode([FocusSession].self, from: data) {
            return sessions.filter { session in
                calendar.isDate(session.date, inSameDayAs: today) && session.phaseType == .focus
            }.count
        }
        return 0
    }
    
    private func getWeeklySessions() -> Int {
        // Get this week's focus session count from stored sessions
        let calendar = Calendar.current
        let today = Date()
        guard let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start,
              let endOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.end else {
            return 0
        }
        
        // Load sessions from UserDefaults
        if let data = UserDefaults.standard.data(forKey: "watch_focus_sessions"),
           let sessions = try? JSONDecoder().decode([FocusSession].self, from: data) {
            return sessions.filter { session in
                session.date >= startOfWeek && session.date < endOfWeek && session.phaseType == .focus
            }.count
        }
        return 0
    }
}

