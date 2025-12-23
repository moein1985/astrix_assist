# 🚀 Grok AI - Quick Start Guide

## 📋 TL;DR

ساخت سیستم تست چند نسلی برای Astrix Assist - پشتیبانی از 4 نسل مختلف Asterisk/Linux

**زمان تخمینی**: 80-100 ساعت (2-3 هفته)  
**اولویت**: بالا

---

## ⚡ Quick Commands

```bash
# 1. Review the full plan
cat docs/GROK_MULTI_GENERATION_TESTING_PLAN.md

# 2. Start with research (Phase 1)
# Read Asterisk documentation for versions 11, 13, 16, 18/20

# 3. Create generation configs (Phase 2)
# Implement lib/core/generation/*.dart files

# 4. Build mock servers (Phase 4)
# Implement tools/mock_servers/*.dart

# 5. Write tests (Phases 5-7)
# Create test/unit, test/widget, test/integration

# 6. Verify everything (Phase 9)
flutter test --coverage
```

---

## 📁 Key Files to Create

### Phase 2: Configuration (6 files)
```
lib/core/generation/
  ✅ generation_config.dart          # Interface
  ✅ generation_1_config.dart        # CentOS 6 + Asterisk 11
  ✅ generation_2_config.dart        # CentOS 7 + Asterisk 13
  ✅ generation_3_config.dart        # Rocky 8 + Asterisk 16
  ✅ generation_4_config.dart        # Rocky 9 + Asterisk 18+
lib/core/app_config.dart             # Update this
```

### Phase 3: Adapters (3 files)
```
lib/core/adapters/
  ✅ ami_adapter.dart
  ✅ ssh_adapter.dart
  ✅ cdr_adapter.dart
```

### Phase 4: Mock Infrastructure (10+ files)
```
lib/mocks/
  ✅ mock_classes.dart

test/fixtures/
  ✅ generation_1/
  ✅ generation_2/
  ✅ generation_3/
  ✅ generation_4/

tools/mock_servers/
  ✅ mock_ssh_server.dart
  ✅ mock_ami_server.dart
```

### Phase 5-7: Tests (50+ files)
```
test/unit/
test/widget/
test/integration/
test/mocks/
```

---

## 🎯 Phase-by-Phase Checklist

### ☐ Phase 1: Research (11 hours)
- [ ] Task 1.1: Research Asterisk AMI (4h)
- [ ] Task 1.2: Research CDR Format (3h)
- [ ] Task 1.3: Research SSH/Python (2h)
- [ ] Task 1.4: Create Spec Document (2h)

### ☐ Phase 2: Configuration (11 hours)
- [ ] Task 2.1: Create Interface (3h)
- [ ] Task 2.2: Implement 4 Configs (6h)
- [ ] Task 2.3: Update AppConfig (2h)

### ☐ Phase 3: Adapters (10 hours)
- [ ] Task 3.1: AMI Adapter (4h)
- [ ] Task 3.2: SSH Adapter (3h)
- [ ] Task 3.3: CDR Adapter (3h)

### ☐ Phase 4: Mock Infrastructure (25 hours)
- [ ] Task 4.1: Mock Classes (3h)
- [ ] Task 4.2: Fixture Generator (6h)
- [ ] Task 4.3: Mock SSH Server (8h)
- [ ] Task 4.4: Mock AMI Server (8h)

### ☐ Phase 5: Unit Tests (20 hours)
- [ ] Task 5.1: Test Configs (4h)
- [ ] Task 5.2: Test AppConfig (2h)
- [ ] Task 5.3: Test Adapters (6h)
- [ ] Task 5.4: Complete Existing (8h)

### ☐ Phase 6: Widget Tests (12 hours)
- [ ] Task 6.1: Test CDR Page (4h)
- [ ] Task 6.2: Test Other Pages (8h)

### ☐ Phase 7: Integration Tests (17 hours)
- [ ] Task 7.1: Generation Switching (3h)
- [ ] Task 7.2: Mock Server Tests (6h)
- [ ] Task 7.3: E2E Feature Tests (8h)

### ☐ Phase 8: Documentation (10 hours)
- [ ] Task 8.1: API Docs (4h)
- [ ] Task 8.2: User Guide (3h)
- [ ] Task 8.3: Migration Guide (2h)
- [ ] Task 8.4: Update README (1h)

### ☐ Phase 9: Verification (9 hours)
- [ ] Task 9.1: Run All Tests (2h)
- [ ] Task 9.2: Verify Mock Servers (2h)
- [ ] Task 9.3: Test on Device (3h)
- [ ] Task 9.4: Code Review (2h)

**Total**: ~105 hours

---

## 🔍 Generation Specifications

| Generation | OS | Asterisk | Python | CDR Cols | Features |
|------------|----|----|--------|----------|----------|
| **1** | CentOS 6 | 11.x | 2.6 | 14 | Basic AMI, No CoreShowChannels |
| **2** | CentOS 7 | 13.x | 2.7/3.4 | 17 | +CoreShowChannels |
| **3** | Rocky 8 | 16.x | 3.6+ | 19 | +JSON, +Timezone |
| **4** | Rocky 9 | 18+/20 | 3.9+ | 20+ | +CEL, +PJSIP, Full features |

---

## 📝 Example Code Snippets

### How to Use Generation System

```dart
import 'package:astrix_assist/core/app_config.dart';

void main() {
  // Production: Uses defaultGeneration from AppConfig
  final config = AppConfig.current;
  print('Running on Generation ${config.generation}');
  
  // Testing: Switch generation at runtime
  AppConfig.setGeneration(2);
  print('Switched to Generation ${AppConfig.current.generation}');
  
  // Reset to default
  AppConfig.resetGeneration();
}
```

### How to Write Generation-Aware Code

```dart
import 'package:astrix_assist/core/app_config.dart';

Future<List<Call>> getActiveCalls() async {
  final config = AppConfig.current;
  
  if (config.supportsCoreShowChannels) {
    // Modern Asterisk
    return await amiService.coreShowChannels();
  } else {
    // Legacy Asterisk
    return await amiService.status();
  }
}
```

### How to Test with Different Generations

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:astrix_assist/core/app_config.dart';

void main() {
  group('Feature Tests', () {
    for (var gen = 1; gen <= 4; gen++) {
      test('works on Generation $gen', () {
        AppConfig.setGeneration(gen);
        
        // Your test code here
        
        AppConfig.resetGeneration();
      });
    }
  });
}
```

---

## 🛠️ Development Workflow

### Step 1: Setup
```bash
cd C:\Users\Moein\Documents\Codes\astrix_assist
flutter pub get
```

### Step 2: Create Generation Configs
```bash
# Create directory structure
mkdir lib\core\generation
mkdir lib\core\adapters
mkdir lib\mocks

# Start with interface
# Create lib/core/generation/generation_config.dart
```

### Step 3: Implement Configs
```bash
# Implement each generation config
# generation_1_config.dart through generation_4_config.dart
```

### Step 4: Create Mock Infrastructure
```bash
mkdir tools\mock_servers
mkdir test\fixtures\generation_1
mkdir test\fixtures\generation_2
mkdir test\fixtures\generation_3
mkdir test\fixtures\generation_4

# Generate fixture data
dart tools/generate_fixtures.dart
```

### Step 5: Write Tests
```bash
mkdir test\unit\core\generation
mkdir test\unit\core\adapters
mkdir test\widget\presentation
mkdir test\integration

# Write tests following the plan
```

### Step 6: Run Tests
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Generate coverage report
genhtml coverage\lcov.info -o coverage\html
```

### Step 7: Verify
```bash
# Check coverage
start coverage\html\index.html

# Run on device
flutter run -d R92Y704M3XT
```

---

## 🎯 Success Criteria

### Must Have ✅
- [ ] All 4 generation configs implemented
- [ ] All adapters working
- [ ] Mock SSH server operational
- [ ] Mock AMI server operational
- [ ] Test coverage > 75%
- [ ] All tests passing
- [ ] Documentation complete

### Nice to Have 🌟
- [ ] Test coverage > 85%
- [ ] Performance benchmarks
- [ ] CI/CD integration
- [ ] Automated fixture generation
- [ ] Visual test reports

---

## 📚 Key Resources

### Internal
- **Full Plan**: `docs/GROK_MULTI_GENERATION_TESTING_PLAN.md`
- **Reference Project**: `C:\Users\Moein\Documents\Codes\mik_flutter`
- **Current App**: `C:\Users\Moein\Documents\Codes\astrix_assist`

### External
- [Asterisk 11 Docs](https://docs.asterisk.org/Asterisk_11_Documentation/)
- [Asterisk 13 Docs](https://docs.asterisk.org/Asterisk_13_Documentation/)
- [Asterisk 16 Docs](https://docs.asterisk.org/Asterisk_16_Documentation/)
- [Asterisk 20 Docs](https://wiki.asterisk.org/wiki/display/AST/Asterisk+20+Documentation)
- [Flutter Testing](https://docs.flutter.dev/testing)
- [Mocktail Package](https://pub.dev/packages/mocktail)

---

## 🚨 Important Notes

### DO ✅
- Follow the plan sequentially
- Check official docs before implementing
- Write tests for everything
- Document all public APIs
- Use proper error handling
- Test on real device

### DON'T ❌
- Skip research phase
- Guess API behavior
- Leave tests incomplete
- Hardcode test data
- Ignore edge cases
- Skip documentation

---

## 💡 Pro Tips

1. **Start Small**: Implement Generation 4 first (current), then work backwards
2. **Test Early**: Write tests as you code, not after
3. **Use References**: Check mik_flutter for patterns
4. **Stay Organized**: Keep files structured as in the plan
5. **Ask Questions**: If unclear, refer to full plan or ask for clarification

---

## 🐛 Common Issues & Solutions

### Issue: Tests failing with "No generation set"
**Solution**: Always call `AppConfig.resetGeneration()` in tearDown

### Issue: Mock server port already in use
**Solution**: Use different ports or kill existing process

### Issue: Fixture files not found
**Solution**: Run fixture generator first

### Issue: Low test coverage
**Solution**: Focus on unit tests first, then widget, then integration

---

## 📊 Progress Tracking

### Week 1
- [ ] Complete Phases 1-2 (Research + Configuration)
- [ ] Start Phase 3 (Adapters)

### Week 2
- [ ] Complete Phase 3 (Adapters)
- [ ] Complete Phase 4 (Mock Infrastructure)
- [ ] Start Phase 5 (Unit Tests)

### Week 3
- [ ] Complete Phase 5 (Unit Tests)
- [ ] Complete Phases 6-7 (Widget + Integration Tests)
- [ ] Complete Phases 8-9 (Documentation + Verification)

---

## ✨ Final Checklist

Before submitting:
- [ ] All phases complete
- [ ] All tests passing
- [ ] Coverage > 75%
- [ ] Documentation complete
- [ ] Code reviewed
- [ ] Tested on device
- [ ] No warnings/errors
- [ ] Git committed and pushed

---

**Ready to start? Begin with Phase 1! 🚀**

For detailed instructions, see: `GROK_MULTI_GENERATION_TESTING_PLAN.md`
