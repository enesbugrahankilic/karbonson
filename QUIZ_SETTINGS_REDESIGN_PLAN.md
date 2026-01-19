# Quiz Settings and Questions Redesign Plan

## Information Gathered

### Current State Analysis:

1. **quiz_settings_page.dart** (lib/pages/quiz_settings_page.dart)
   - Glass morphism design with gradient background
   - Category selection grid (2x4 for mobile, 4x2 for desktop)
   - Difficulty selection with 3 cards (Kolay/Orta/Zor)
   - Question count with slider (5-25) and 5 labeled options
   - Summary card showing selected options
   - Start quiz button

2. **question.dart** (lib/models/question.dart)
   - `DifficultyLevel` enum: easy, medium, hard with displayName, pointMultiplier, color
   - `QuizCategory` enum: all, energy, water, forest, recycling, transportation, consumption
   - `Option` class: text, score, feedback
   - `Question` class: id, text, options, category, difficulty, timeLimit, explanation, tags, imageUrl
   - `QuizResult` class for storing results

3. **Questions Data** (lib/data/)
   - energy_questions_expansion.dart
   - water_questions_expansion.dart (Part 1-3)
   - recycling_questions_expansion.dart
   - forest_questions_expansion.dart
   - consumption_questions_expansion.dart
   - transportation_questions_expansion.dart

---

## Plan

### Phase 1: Redesign Quiz Settings Page

#### 1.1 New Layout Structure
- **Tab-based navigation** for cleaner organization:
  - Tab 1: Kategori (Category)
  - Tab 2: Zorluk (Difficulty) 
  - Tab 3: Ayarlar (Settings)
- **Animated transitions** between tabs
- **Progress indicator** showing completion status

#### 1.2 Enhanced Category Selection
- **Category cards with visual preview** showing:
  - Icon with gradient background
  - Category name
  - Question count (dynamic from database)
  - Brief description
  - Difficulty distribution (Easy/Medium/Hard counts)
- **All/Custom category** with multi-select support
- **Recent categories** quick access

#### 1.3 Enhanced Difficulty Selection
- **Visual difficulty meter** with slider
- **Detailed explanation** for each level:
  - Point multiplier
  - Expected time
  - Question types
  - Success rate requirements
- **Adaptive difficulty** suggestion based on user history

#### 1.4 Enhanced Question Count Selection
- **Visual timeline** showing quiz duration
- **Time estimates** with breaks
- **Question distribution** preview
- **Energy/sprint mode** option (5 questions)

#### 1.5 New Settings Options
- **Timer settings**:
  - Per question time limit
  - Total time limit
  - No timer option
- **Question order**:
  - Random shuffle
  - Difficulty gradient (easy → hard)
  - Category grouped
- **Feedback options**:
  - Show correct answer immediately
  - Show explanation after each question
  - End of quiz summary only

#### 1.6 New Summary Card
- **Interactive preview** of quiz configuration
- **Estimated points** calculation
- **Time commitment** visualization
- **Quick modify** buttons for each section

---

### Phase 2: Enhanced Questions Database

#### 2.1 Question Model Improvements
- **Add difficulty distribution** to categories
- **Add learning objectives** to questions
- **Add question type** (factual, conceptual, application)
- **Add seasonal/relevant tags**
- **Add language support** field

#### 2.2 Question Categories Enhancement
- **Add new categories**:
  - Climate Change (İklim Değişikliği)
  - Biodiversity (Biyoçeşitlilik)
  - Sustainable Living (Sürdürülebilir Yaşam)
- **Update question counts** per category
- **Add difficulty-based filtering**

#### 2.3 Question Quality Improvements
- **Add explanations** to all questions
- **Add fun facts** section
- **Add related questions** references
- **Add difficulty calibration** based on user performance

---

### Phase 3: New Quiz Preview & Configuration Screen

#### 3.1 Quiz Preview Card
- **Visual representation** of quiz configuration
- **Estimated duration** with visual timeline
- **Point potential** calculation
- **Category preview** with icons

#### 3.2 Configuration Summary
- **Clear overview** of all settings
- **Edit buttons** for quick modifications
- **Save as preset** option
- **Load from preset** option

---

### Phase 4: UI/UX Improvements

#### 4.1 Animations & Transitions
- **Staggered animations** for cards appearing
- **Smooth transitions** between sections
- **Loading skeletons** for quiz generation
- **Celebration animations** on completion

#### 4.2 Accessibility
- **Screen reader support** for all elements
- **High contrast mode** support
- **Large touch targets** (min 48dp)
- **Keyboard navigation** support

#### 4.3 Responsive Design
- **Mobile-first approach**
- **Tablet optimization**
- **Desktop side-by-side layout**
- **Foldable device support**

---

## Files to Create/Modify

### New Files:
1. `lib/pages/new_quiz_settings_page.dart` - Redesigned settings page
2. `lib/widgets/quiz_preview_card.dart` - Quiz preview widget
3. `lib/widgets/difficulty_selector.dart` - Enhanced difficulty selector
4. `lib/widgets/category_selector.dart` - Enhanced category selector
5. `lib/data/quiz_questions_enhanced.dart` - Enhanced questions database
6. `lib/models/quiz_config.dart` - Quiz configuration model

### Files to Modify:
1. `lib/pages/quiz_settings_page.dart` - Keep for backward compatibility
2. `lib/models/question.dart` - Add new fields
3. `lib/data/*.dart` - Update question data

---

## Follow-up Steps

1. ✅ Create TODO.md plan
2. ⏳ Create new quiz settings page with enhanced UI
3. ⏳ Create enhanced question widgets
4. ⏳ Update questions database with explanations
5. ⏳ Add animations and transitions
6. ⏳ Test on multiple screen sizes
7. ⏳ Verify accessibility compliance

