import SwiftUI
import UIKit

// MARK: - Public API

/// Create a high-res (1080x1350) poster image you can share anywhere.
enum PosterExporter {

    /// Renders a poster image with the given text, date, and streak.
    /// - Parameters:
    ///   - text: The body text (workout summary or motivational message).
    ///   - date: The date shown in the footer.
    ///   - streak: Current workout streak number shown as a badge.
    ///   - appName: Tiny footer branding (defaults to app display name).
    ///   - scale: Pixel scale for crisp output (2.0–3.0 looks great).
    /// - Returns: A UIImage ready for sharing (PNG-like quality).
    @MainActor
    static func image(
        text: String,
        date: Date = Date(),
        streak: Int = 0,
        appName: String = Bundle.main.displayName,
        scale: CGFloat = 2.0
    ) -> UIImage {
        let view = PosterCanvas(
            text: text.isEmpty ? "7 minutes. 12 exercises. Infinite possibilities." : text,
            date: date,
            streak: streak,
            appName: appName
        )
        .frame(maxWidth: min(UIScreen.main.bounds.width * 0.9, 600))
        .aspectRatio(4/5, contentMode: .fit)

        // iOS 16+: crisp SwiftUI → UIImage rendering
        let renderer = ImageRenderer(content: view)
        renderer.scale = max(1.0, min(4.0, scale)) // clamp a bit for safety
        renderer.isOpaque = true

        if let uiImage = renderer.uiImage {
            return uiImage
        }

        // Fallback (rare)
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = true
        let fallback = UIGraphicsImageRenderer(size: CGSize(width: 1080, height: 1350), format: format)
        return fallback.image { ctx in
            UIColor.black.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 1080, height: 1350))
        }
    }
    
    // MARK: - Agent 12: Workout-Specific Convenience Methods
    
    /// Create a poster for workout completion
    @MainActor
    static func workoutCompletionPoster(
        duration: TimeInterval,
        exercisesCompleted: Int,
        streak: Int = 0,
        date: Date = Date(),
        scale: CGFloat = 2.0
    ) -> UIImage {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        let text = "Just completed a 7-minute workout! 💪\n\n⏱️ \(minutes):\(String(format: "%02d", seconds))\n🏃 \(exercisesCompleted)/12 exercises"
        
        return image(text: text, date: date, streak: streak, scale: scale)
    }
    
    /// Create a poster for streak milestone
    @MainActor
    static func streakPoster(
        streak: Int,
        totalWorkouts: Int = 0,
        date: Date = Date(),
        scale: CGFloat = 2.0
    ) -> UIImage {
        var text = "🔥 \(streak)-day streak! 🔥\n\n"
        if totalWorkouts > 0 {
            text += "\(totalWorkouts) total workouts completed"
        }
        text += "\n\nKeep the momentum going! 💪"
        
        return image(text: text, date: date, streak: streak, scale: scale)
    }
    
    /// Create a poster for achievement unlock
    @MainActor
    static func achievementPoster(
        title: String,
        description: String,
        streak: Int = 0,
        date: Date = Date(),
        scale: CGFloat = 2.0
    ) -> UIImage {
        let text = "🏆 Achievement Unlocked!\n\n\(title)\n\n\(description)"
        
        return image(text: text, date: date, streak: streak, scale: scale)
    }
}

// MARK: - Poster Layout

private struct PosterCanvas: View {
    let text: String
    let date: Date
    let streak: Int
    let appName: String

    var body: some View {
        ZStack {
            backgroundGradient
            vignetteOverlays
            GrainOverlay(opacity: 0.06)

            VStack {
                Spacer(minLength: 70)
                PosterCard(text: text, date: date, streak: streak, appName: appName)
                    .padding(.horizontal, 64)
                Spacer(minLength: 70)
            }
        }
        .compositingGroup()
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(hue: 0.69, saturation: 0.72, brightness: 0.22), // deep purple
                Color(hue: 0.78, saturation: 0.68, brightness: 0.30), // blue-violet
                Color(hue: 0.83, saturation: 0.60, brightness: 0.28)  // indigo
            ],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    private var vignetteOverlays: some View {
        ZStack {
            RadialGradient(colors: [.clear, .black.opacity(0.30)],
                           center: .center, startRadius: 200, endRadius: 900)
                .blendMode(.multiply)
            AngularGradient(gradient: Gradient(colors: [.white.opacity(0.05), .clear, .clear, .white.opacity(0.05)]),
                            center: .center)
                .blendMode(.overlay)
                .opacity(0.6)
        }
    }
}

private struct PosterCard: View {
    let text: String
    let date: Date
    let streak: Int
    let appName: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 44, style: .continuous)
                .fill(.regularMaterial)
                .overlay(InnerShine(cornerRadius: 44))
                .overlay(Hairline(cornerRadius: 44))
                .shadow(color: .black.opacity(0.35), radius: 38, y: 28)

            VStack(alignment: .leading, spacing: 28) {
                HStack {
                    StreakBadge(streak: streak)
                    Spacer()
                    BrandMark()
                }

                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top, spacing: 8) {
                        Text("“")
                            .font(.system(.largeTitle, design: .rounded).weight(.bold))
                            .minimumScaleFactor(0.5)
                            .lineLimit(3)
                            .opacity(0.8)
                            .offset(y: -16)
                        Text(text)
                            .font(.system(.title, design: .rounded).weight(.semibold))
                            .minimumScaleFactor(0.6)
                            .lineLimit(4)
                            .lineSpacing(6)
                    }
                    Text("”")
                        .font(.system(.largeTitle, design: .rounded).weight(.bold))
                        .minimumScaleFactor(0.5)
                        .opacity(0.8)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .offset(y: -24)
                }
                .foregroundStyle(.white)

                Divider().overlay(Color.white.opacity(0.25))

                HStack {
                    HStack(spacing: 10) {
                        Image(systemName: "calendar")
                        Text(date.formatted(date: .abbreviated, time: .omitted))
                    }
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(.white.opacity(0.9))

                    Spacer()

                    Text(appName)
                        .font(.system(.subheadline, design: .rounded).weight(.medium))
                        .minimumScaleFactor(0.7)
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .padding(40)
        }
    }
}

// MARK: - Bits & Bobs


private struct StreakBadge: View {
    let streak: Int
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "flame.fill")
                .symbolRenderingMode(.palette)
                .foregroundStyle(.orange, .white)
            Text("\(max(0, streak))-day streak")
                .font(.system(.title2, design: .rounded).weight(.heavy))
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, 18).padding(.vertical, 10)
        .background(Capsule(style: .continuous).fill(.ultraThinMaterial))
        .overlay(Capsule().stroke(Color.white.opacity(0.25), lineWidth: 1))
        .shadow(color: .black.opacity(0.25), radius: 12, y: 8)
        .foregroundStyle(.white)
    }
}

private struct BrandMark: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "figure.run")
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, .orange)
            Text("Ritual7")
                .font(.system(.title2, design: .rounded).weight(.bold))
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, 16).padding(.vertical, 8)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.22), lineWidth: 1))
        .foregroundStyle(.white)
    }
}

/// Subtle grain so the gradients feel natural on OLED (and compress better).
/// Subtle grain so the gradients feel natural on OLED (and compress better).
private struct GrainOverlay: View {
    var opacity: CGFloat = 0.08
    var body: some View {
        Canvas { ctx, size in
            let noiseSize: CGFloat = 40
            let cols = Int(ceil(size.width / noiseSize))
            let rows = Int(ceil(size.height / noiseSize))
            for y in 0..<rows {
                for x in 0..<cols {
                    let rect = CGRect(
                        x: CGFloat(x) * noiseSize,
                        y: CGFloat(y) * noiseSize,
                        width: noiseSize,
                        height: noiseSize
                    )
                    let n = CGFloat.random(in: -0.5...0.5)
                    ctx.fill(Path(rect), with: .color(Color.white.opacity(opacity * 0.15 + n * 0.02)))
                }
            }
        }
        .allowsHitTesting(false)
        .blendMode(.overlay)
        .opacity(opacity)
    }
}


// MARK: - Helpers

private extension Bundle {
    var displayName: String {
        if let name = object(forInfoDictionaryKey: "CFBundleDisplayName") as? String { return name }
        if let name = object(forInfoDictionaryKey: "CFBundleName") as? String { return name }
        return "Ritual7"
    }
}
