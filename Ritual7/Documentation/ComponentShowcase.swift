import SwiftUI

/// Component Showcase - Interactive preview of all design system components
/// This file demonstrates all available components and their usage patterns
/// Use this as a reference when implementing new features
struct ComponentShowcase: View {
    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.sectionSpacing) {
                // MARK: - Typography Showcase
                typographySection
                
                // MARK: - Spacing Showcase
                spacingSection
                
                // MARK: - Icon Showcase
                iconSection
                
                // MARK: - Button Showcase
                buttonSection
                
                // MARK: - Card Showcase
                cardSection
                
                // MARK: - Color Showcase
                colorSection
            }
            .padding(DesignSystem.Spacing.cardPadding)
        }
    }
    
    // MARK: - Typography Section
    
    private var typographySection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Typography")
                .font(.system(size: DesignSystem.Hierarchy.primaryTitle, weight: DesignSystem.Hierarchy.primaryWeight))
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text("Large Title")
                    .font(Theme.largeTitle)
                Text("Title")
                    .font(Theme.title)
                Text("Title 2")
                    .font(Theme.title2)
                Text("Title 3")
                    .font(Theme.title3)
                Text("Headline")
                    .font(Theme.headline)
                Text("Body")
                    .font(Theme.body)
                Text("Subheadline")
                    .font(Theme.subheadline)
                Text("Caption")
                    .font(Theme.caption)
                Text("Caption 2")
                    .font(Theme.caption2)
                Text("Footnote")
                    .font(Theme.footnote)
            }
        }
        .cardPadding()
        .background(.ultraThinMaterial)
        .cardCornerRadius()
        .cardShadow()
    }
    
    // MARK: - Spacing Section
    
    private var spacingSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Spacing Scale")
                .font(.system(size: DesignSystem.Hierarchy.primaryTitle, weight: DesignSystem.Hierarchy.primaryWeight))
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                spacingExample("XS (8pt)", size: DesignSystem.Spacing.xs)
                spacingExample("SM (16pt)", size: DesignSystem.Spacing.sm)
                spacingExample("MD (24pt)", size: DesignSystem.Spacing.md)
                spacingExample("LG (32pt)", size: DesignSystem.Spacing.lg)
            }
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text("Semantic Spacing")
                    .font(Theme.headline)
                    .padding(.top, DesignSystem.Spacing.sm)
                
                spacingExample("Card Padding (24pt)", size: DesignSystem.Spacing.cardPadding)
                spacingExample("Regular Card Padding (16pt)", size: DesignSystem.Spacing.regularCardPadding)
                spacingExample("Section Spacing (32pt)", size: DesignSystem.Spacing.sectionSpacing)
            }
        }
        .cardPadding()
        .background(.ultraThinMaterial)
        .cardCornerRadius()
        .cardShadow()
    }
    
    private func spacingExample(_ label: String, size: CGFloat) -> some View {
        HStack {
            Text(label)
                .font(Theme.body)
            Spacer()
            Rectangle()
                .fill(Theme.accentA)
                .frame(width: size, height: 20)
                .cornerRadius(DesignSystem.CornerRadius.small)
        }
    }
    
    // MARK: - Icon Section
    
    private var iconSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Icon Sizes & Weights")
                .font(.system(size: DesignSystem.Hierarchy.primaryTitle, weight: DesignSystem.Hierarchy.primaryWeight))
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                iconExample("Small (16pt)", size: DesignSystem.IconSize.small, weight: DesignSystem.IconWeight.standard)
                iconExample("Medium (20pt)", size: DesignSystem.IconSize.medium, weight: DesignSystem.IconWeight.standard)
                iconExample("Large (24pt)", size: DesignSystem.IconSize.large, weight: DesignSystem.IconWeight.standard)
                iconExample("XLarge (32pt)", size: DesignSystem.IconSize.xlarge, weight: DesignSystem.IconWeight.standard)
                iconExample("XXLarge (48pt)", size: DesignSystem.IconSize.xxlarge, weight: DesignSystem.IconWeight.standard)
                iconExample("Huge (64pt)", size: DesignSystem.IconSize.huge, weight: DesignSystem.IconWeight.standard)
            }
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text("Icon Weights")
                    .font(Theme.headline)
                    .padding(.top, DesignSystem.Spacing.sm)
                
                iconExample("Medium (standard)", size: DesignSystem.IconSize.medium, weight: DesignSystem.IconWeight.standard)
                iconExample("Semibold (emphasis)", size: DesignSystem.IconSize.medium, weight: DesignSystem.IconWeight.emphasis)
                iconExample("Bold (strong)", size: DesignSystem.IconSize.medium, weight: DesignSystem.IconWeight.strong)
            }
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text("Semantic Sizes")
                    .font(Theme.headline)
                    .padding(.top, DesignSystem.Spacing.sm)
                
                iconExample("Button (20pt)", size: DesignSystem.IconSize.button, weight: DesignSystem.IconWeight.standard)
                iconExample("Stat Box (24pt)", size: DesignSystem.IconSize.statBox, weight: DesignSystem.IconWeight.standard)
                iconExample("Card (48pt)", size: DesignSystem.IconSize.card, weight: DesignSystem.IconWeight.standard)
            }
        }
        .cardPadding()
        .background(.ultraThinMaterial)
        .cardCornerRadius()
        .cardShadow()
    }
    
    private func iconExample(_ label: String, size: CGFloat, weight: Font.Weight) -> some View {
        HStack {
            Text(label)
                .font(Theme.body)
            Spacer()
            Image(systemName: "star.fill")
                .font(.system(size: size, weight: weight))
                .foregroundStyle(Theme.accentA)
        }
    }
    
    // MARK: - Button Section
    
    private var buttonSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Button Styles")
                .font(.system(size: DesignSystem.Hierarchy.primaryTitle, weight: DesignSystem.Hierarchy.primaryWeight))
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                Button("Primary Button (Standard)") {
                    // Action
                }
                .buttonStyle(PrimaryProminentButtonStyle())
                
                Button("Secondary Button (Small)") {
                    // Action
                }
                .buttonStyle(SecondaryGlassButtonStyle())
                
                Button("Disabled Button") {
                    // Action
                }
                .buttonStyle(PrimaryProminentButtonStyle(isEnabled: false))
            }
        }
        .cardPadding()
        .background(.ultraThinMaterial)
        .cardCornerRadius()
        .cardShadow()
    }
    
    // MARK: - Card Section
    
    private var cardSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Card Components")
                .font(.system(size: DesignSystem.Hierarchy.primaryTitle, weight: DesignSystem.Hierarchy.primaryWeight))
            
            GlassCard {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Text("Glass Card")
                        .font(Theme.headline)
                    Text("This is a glass card component with glassmorphism effects.")
                        .font(Theme.body)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    // MARK: - Color Section
    
    private var colorSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Color Palette")
                .font(.system(size: DesignSystem.Hierarchy.primaryTitle, weight: DesignSystem.Hierarchy.primaryWeight))
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                colorSwatch("Accent A", color: Theme.accentA)
                colorSwatch("Accent B", color: Theme.accentB)
                colorSwatch("Accent C", color: Theme.accentC)
            }
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("Text Colors")
                    .font(Theme.headline)
                    .padding(.top, DesignSystem.Spacing.sm)
                
                colorSwatch("Text Primary", color: Theme.textPrimary)
                colorSwatch("Text Secondary", color: Theme.textSecondary)
                colorSwatch("Text On Dark", color: Theme.textOnDark)
            }
        }
        .cardPadding()
        .background(.ultraThinMaterial)
        .cardCornerRadius()
        .cardShadow()
    }
    
    private func colorSwatch(_ label: String, color: Color) -> some View {
        HStack {
            Text(label)
                .font(Theme.body)
            Spacer()
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                .fill(color)
                .frame(width: 60, height: 30)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                        .stroke(Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle), 
                               lineWidth: DesignSystem.Border.subtle)
                )
        }
    }
}

// MARK: - Preview

#Preview {
    ComponentShowcase()
        .background(ThemeBackground())
}

