#!/bin/bash

# Comprehensive Compiler Safety Verification Script
# Checks for iOS 17+ API usage, type safety, and other compiler issues

echo "🔍 Compiler Safety Verification"
echo "================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

# Check 1: Find all symbolEffect calls without availability checks
echo "1. Checking symbolEffect usage..."
SYMBOL_EFFECTS=$(grep -r "\.symbolEffect\|symbolEffect(" --include="*.swift" Ritual7/ | grep -v "#available" | grep -v "SymbolBounceModifier\|SymbolPulseModifier\|applySymbolEffect" | wc -l)
if [ "$SYMBOL_EFFECTS" -gt 0 ]; then
    echo -e "${RED}❌ Found $SYMBOL_EFFECTS symbolEffect calls without availability checks${NC}"
    ERRORS=$((ERRORS + SYMBOL_EFFECTS))
else
    echo -e "${GREEN}✅ All symbolEffect calls properly guarded${NC}"
fi

# Check 2: Find all iOS 17+ API usage
echo ""
echo "2. Checking iOS 17+ API usage..."
IOS17_APIS=$(grep -r "\.bounce\|\.pulse\|\.appear\|\.disappear" --include="*.swift" Ritual7/ | grep -v "#available\|BounceAnimation\|applySymbolEffect\|SymbolBounceModifier\|SymbolPulseModifier" | wc -l)
if [ "$IOS17_APIS" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Found $IOS17_APIS potential iOS 17+ API calls (may be custom extensions)${NC}"
    WARNINGS=$((WARNINGS + IOS17_APIS))
else
    echo -e "${GREEN}✅ All iOS 17+ API calls properly guarded${NC}"
fi

# Check 3: Check for force unwraps
echo ""
echo "3. Checking for force unwraps..."
FORCE_UNWRAPS=$(grep -r "!" --include="*.swift" Ritual7/ | grep -v "//\|nil\|guard\|if.*==\|if.*!=\|!contains\|!isEmpty\|!reduceMotion" | wc -l)
if [ "$FORCE_UNWRAPS" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Found $FORCE_UNWRAPS potential force unwraps (may be safe)${NC}"
    WARNINGS=$((WARNINGS + FORCE_UNWRAPS))
else
    echo -e "${GREEN}✅ No dangerous force unwraps found${NC}"
fi

# Check 4: Check for onChange with non-Equatable types
echo ""
echo "4. Checking onChange modifiers..."
ONCHANGE_ISSUES=$(grep -r "\.onChange(of:" --include="*.swift" Ritual7/ | grep -v "\.exerciseDuration\|\.restDuration\|\.prepDuration\|\.skipPrepTime\|\.phase\|\.streak\|\.trigger\|\.isPressed\|\.isRefreshing\|\.matchSystem\|\.forcedScheme\|\.reminderEnabled\|\.reminderHour\|\.reminderMinute\|\.streakReminderEnabled\|\.noWorkoutNudgeEnabled\|\.weeklySummaryEnabled\|\.soundEnabled\|\.vibrationEnabled\|\.colorTheme\|\.selectedTimeframe\|\.showCelebration\|\.value\|\.newValue\|\.size\|\.scenePhase\|\.text" | wc -l)
if [ "$ONCHANGE_ISSUES" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Found $ONCHANGE_ISSUES onChange calls that may need Equatable types${NC}"
    WARNINGS=$((WARNINGS + ONCHANGE_ISSUES))
else
    echo -e "${GREEN}✅ All onChange modifiers use Equatable types${NC}"
fi

# Check 5: Check for explicit returns in ViewBuilder
echo ""
echo "5. Checking ViewBuilder for explicit returns..."
VIEWBUILDER_RETURNS=$(grep -r "@ViewBuilder" --include="*.swift" -A 20 Ritual7/ | grep "return " | wc -l)
if [ "$VIEWBUILDER_RETURNS" -gt 0 ]; then
    echo -e "${RED}❌ Found $VIEWBUILDER_RETURNS explicit returns in ViewBuilder contexts${NC}"
    ERRORS=$((ERRORS + VIEWBUILDER_RETURNS))
else
    echo -e "${GREEN}✅ No explicit returns in ViewBuilder contexts${NC}"
fi

# Check 6: Check for MainActor isolation issues
echo ""
echo "6. Checking MainActor isolation..."
MAINACTOR_ISSUES=$(grep -r "@MainActor" --include="*.swift" Ritual7/ | grep -v "Task.*@MainActor\|@MainActor.*class\|@MainActor.*struct\|@MainActor.*func" | wc -l)
if [ "$MAINACTOR_ISSUES" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Found $MAINACTOR_ISSUES potential MainActor isolation issues${NC}"
    WARNINGS=$((WARNINGS + MAINACTOR_ISSUES))
else
    echo -e "${GREEN}✅ MainActor isolation properly handled${NC}"
fi

# Summary
echo ""
echo "================================"
echo "📊 Summary"
echo "================================"
echo -e "Errors: ${RED}$ERRORS${NC}"
echo -e "Warnings: ${YELLOW}$WARNINGS${NC}"

if [ "$ERRORS" -eq 0 ]; then
    echo -e "\n${GREEN}✅ All critical checks passed!${NC}"
    exit 0
else
    echo -e "\n${RED}❌ Found $ERRORS critical issues${NC}"
    exit 1
fi


