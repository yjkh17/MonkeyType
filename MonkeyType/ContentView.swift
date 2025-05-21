import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var settings = Settings()
    @StateObject private var model: TypingTestModel
    @State private var showingSettings = false
    @State private var showingCustomText = false
    @State private var showingResults = false
    @FocusState private var isInputFocused: Bool
    @State private var cursorPosition: CGPoint = .zero
    @State private var wordFrames: [CGRect] = []
    @State private var currentCharOffset: CGFloat = 0
    @State private var lastError: Date = .distantPast
    @State private var showError: Bool = false
    @Namespace private var animation
    @State private var isResetting: Bool = false
    @State private var inputFieldOpacity: Double = 1.0
    @State private var keyboardOffset: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var lineHeight: CGFloat = 0
    @State private var shouldAutoScroll: Bool = true
    @State private var currentResult: TypingTestModel.TestResult?

    init() {
        let settings = Settings()
        _settings = StateObject(wrappedValue: settings)
        _model = StateObject(wrappedValue: TypingTestModel(settings: settings))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack(spacing: 20) {
                // Left side stats
                HStack(spacing: 20) {
                    Group {
                        if model.isTestActive {
                            // Progress indicator
                            ProgressView(value: model.progress)
                                .frame(width: 100)
                                .progressViewStyle(.linear)
                                .tint(settings.theme.colors.accent)
                                .transition(.scale.combined(with: .opacity))
                        }
                        
                        // Test mode specific info
                        switch settings.testMode {
                        case .time:
                            Text("Time: \(model.timeRemaining)s")
                        case .words:
                            Text("Words: \(model.completedWords)/\(model.targetWordCount)")
                        case .quote:
                            if let quote = model.currentQuote {
                                Text("Quote: \(quote.source)")
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            } else {
                                Text("Quote")
                            }
                        case .zen:
                            Text("Words: \(model.completedWords)")
                        case .custom:
                            Text(settings.customTextName.isEmpty ? "Custom Text" : settings.customTextName)
                        case .numbers:
                            Text("Numbers: \(model.completedWords)")
                        case .punctuation:
                            Text("Punctuation: \(model.completedWords)")
                        }
                    }
                    .monospacedDigit()
                    .foregroundColor(settings.theme.colors.subtext)
                    
                    if settings.showLiveWPM {
                        Text(String(format: "WPM: %.0f", model.wpm))
                            .monospacedDigit()
                            .foregroundColor(settings.theme.colors.text)
                            .matchedGeometryEffect(id: "wpm", in: animation)
                    }
                    
                    if settings.showLiveAccuracy {
                        Text(String(format: "ACC: %.1f%%", model.accuracy))
                            .monospacedDigit()
                            .foregroundColor(
                                model.accuracy > 95 ? settings.theme.colors.success :
                                model.accuracy > 80 ? settings.theme.colors.text :
                                settings.theme.colors.error
                            )
                            .matchedGeometryEffect(id: "accuracy", in: animation)
                    }
                    
                    if model.isTestActive && settings.showLiveWPM {
                        WPMGraph(
                            values: model.wpmHistory,
                            maxValue: max(model.wpmHistory.max() ?? 100, 100),
                            color: settings.theme.colors.text,
                            showTooltip: true
                        )
                        .frame(width: 100, height: 30)
                        .transition(.scale.combined(with: .opacity))
                        .animation(.easeInOut, value: model.wpmHistory)
                    }
                }
                
                Spacer()
                
                // Right side settings
                HStack(spacing: 15) {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isResetting = true
                            model.startTest()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            isResetting = false
                        }
                    } label: {
                        Text(model.isTestActive ? "reset" : "start test")
                            .foregroundColor(settings.theme.colors.accent)
                    }
                    .buttonStyle(.plain)
                    .opacity(model.isTestActive ? 1 : 0)
                    .rotationEffect(.degrees(isResetting ? 360 : 0))
                    
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(settings.theme.colors.subtext)
                    }
                    .buttonStyle(.plain)
                }
            }
            .font(.system(.title3, design: .monospaced))
            .frame(maxWidth: .infinity)
            .padding()
            
            Spacer()
                .frame(height: 40)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .center, spacing: 8) {
                        ForEach(Array(model.currentWords.enumerated()), id: \.offset) { index, word in
                            wordView(for: word, at: index)
                                .background(wordBackgroundReader(for: index))
                                .overlay {
                                    if settings.caretStyle != .off && model.isTestActive && index == model.currentIndex {
                                        SmoothCursor(
                                            position: cursorPosition,
                                            color: settings.theme.colors.text,
                                            style: settings.caretStyle,
                                            height: CGFloat(settings.fontSize) + 4
                                        )
                                    }
                                }
                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.horizontal)
            }
            .frame(height: 150)
            .coordinateSpace(name: "scroll")
            .offset(y: -scrollOffset)
            .onAppear {
                shouldAutoScroll = true
            }
            .onChange(of: model.currentIndex) { _, _ in
                shouldAutoScroll = true
            }
            .onChange(of: settings.testMode) { _, _ in
                shouldAutoScroll = true
                scrollOffset = 0
            }
            
            Spacer()
                .frame(height: 20)
            
            TextField("", text: $model.userInput)
                .font(.system(size: CGFloat(settings.fontSize), design: .monospaced))
                .multilineTextAlignment(.center)
                .textFieldStyle(.plain)
                .frame(maxWidth: 400)
                .padding()
                .background(settings.theme.colors.background.opacity(0.3))
                .cornerRadius(8)
                .disabled(!model.isTestActive || model.isProcessingInput)
                .foregroundColor(settings.theme.colors.text)
                .opacity(inputFieldOpacity)
                .focused($isInputFocused)
                .onChange(of: model.userInput) { _, newValue in
                    model.handleInput(newValue)
                    if !model.currentWordIsCorrect {
                        let now = Date()
                        if now.timeIntervalSince(lastError) >= 0.5 {
                            lastError = now
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                showError = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                showError = false
                            }
                        }
                    }
                }
                .onChange(of: model.testState) { _, state in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        switch state {
                        case .active:
                            focusInput()
                        case .finished:
                            isInputFocused = false
                            inputFieldOpacity = 0
                        case .idle:
                            inputFieldOpacity = 1
                            focusInput()
                        }
                    }
                }
            
            Spacer()
                .frame(height: 40)
            
            if settings.showKeyboard {
                KeyboardView(
                    settings: settings, 
                    pressedKeys: Set<String>(model.userInput.lowercased().map { String($0) })
                )
                .padding()
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .offset(y: keyboardOffset)
            }
            
            // Test controls
            HStack(spacing: 20) {
                Picker("Mode", selection: $settings.testMode) {
                    ForEach(Settings.TestMode.allCases, id: \.self) { mode in
                        Text(mode.description)
                            .tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 300)
                
                if settings.testMode == .time {
                    Picker("Duration", selection: $model.selectedDuration) {
                        ForEach(TypingTestModel.TestDuration.allCases, id: \.self) { duration in
                            Text(duration.description)
                                .tag(duration)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 300)
                } else if settings.testMode == .words {
                    Picker("Words", selection: $settings.wordCount) {
                        ForEach(Settings.WordCount.allCases, id: \.self) { count in
                            Text(count.description)
                                .tag(count)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 300)
                }
            }
            .padding()
            .disabled(model.isTestActive)
            .opacity(model.isTestActive ? 0.5 : 1)
            
            // Removed other test controls
        }
        .background(settings.theme.colors.background)
        .animation(.easeInOut(duration: 0.3), value: settings.theme)
        .onChange(of: settings.showKeyboard) { _, showing in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                keyboardOffset = showing ? 0 : 200
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(settings: settings)
        }
        .sheet(isPresented: $showingCustomText) {
            CustomTextView(settings: settings)
        }
        .sheet(isPresented: $showingResults) {
            if let result = currentResult {
                ResultsOverlay(result: result, theme: settings.theme)
            }
        }
        .onAppear {
            model.loadWords()
            setupNotifications()
            focusInput()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            if !showingSettings && !showingCustomText && !showingResults {
                focusInput()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didResignActiveNotification)) { _ in
            if model.isTestActive {
                model.cancelTest()
            }
        }
        .onChange(of: settings.testMode) { _, _ in
            withAnimation(.easeInOut(duration: 0.2)) {
                shouldAutoScroll = true
                scrollOffset = 0
                if model.isTestActive {
                    model.cancelTest()
                }
            }
        }
        .onChange(of: settings.language) { _, _ in
            if model.isTestActive {
                model.cancelTest()
            }
            model.loadWords()
        }
    }
    
    private func focusInput() {
        withAnimation {
            inputFieldOpacity = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isInputFocused = true
        }
    }
    
    @ViewBuilder
    private func wordView(for word: String, at index: Int) -> some View {
        Group {
            if settings.language.hasPrefix("code_") {
                Text(SyntaxHighlighter.highlight(word, language: settings.language))
                    .font(.system(size: CGFloat(settings.fontSize), design: .monospaced))
            } else {
                Text(word)
                    .font(.system(size: CGFloat(settings.fontSize), design: .monospaced))
                    .foregroundColor(wordColor(at: index))
            }
        }
        .modifier(ShakeEffect(shake: showError && index == model.currentIndex))
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: model.currentIndex)
    }
    
    private func wordBackgroundReader(for index: Int) -> some View {
        GeometryReader { geo in
            Color.clear.onAppear {
                if wordFrames.count <= index {
                    wordFrames.append(geo.frame(in: .global))
                } else {
                    wordFrames[index] = geo.frame(in: .global)
                }
                
                if index == model.currentIndex {
                    let charWidth = geo.size.width / CGFloat(model.currentWords[index].count)
                    let charOffset = charWidth * CGFloat(model.userInput.count)
                    currentCharOffset = charOffset
                    
                    withAnimation(.spring(response: 0.1, dampingFraction: 0.8)) {
                        cursorPosition = CGPoint(
                            x: geo.frame(in: .global).minX + charOffset,
                            y: geo.frame(in: .global).midY
                        )
                    }
                }
            }
        }
    }
    
    private func wordColor(at index: Int) -> Color {
        if !model.isTestActive { return settings.theme.colors.text }
        
        if index < model.currentIndex {
            return settings.theme.colors.success.opacity(0.8)
        } else if index == model.currentIndex {
            if model.currentWordIsCorrect {
                return settings.theme.colors.text
            } else {
                return settings.theme.colors.error.opacity(showError ? 1.0 : 0.8)
            }
        } else {
            return settings.theme.colors.subtext.opacity(0.6)
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: .restartTest,
            object: nil,
            queue: .main) { _ in
                model.startTest()
                focusInput()
            }
        
        NotificationCenter.default.addObserver(
            forName: .showSettings,
            object: nil,
            queue: .main) { _ in
                showingSettings = true
            }
        
        NotificationCenter.default.addObserver(
            forName: .switchTestMode,
            object: nil,
            queue: .main) { notification in
                if let mode = notification.userInfo?["mode"] as? String,
                   let testMode = Settings.TestMode(rawValue: mode) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if model.isTestActive {
                            model.cancelTest()
                        }
                        settings.testMode = testMode
                        focusInput()
                    }
                }
            }
        
        NotificationCenter.default.addObserver(
            forName: .toggleLiveWPM,
            object: nil,
            queue: .main) { _ in
                withAnimation {
                    settings.showLiveWPM.toggle()
                }
            }
        
        NotificationCenter.default.addObserver(
            forName: .toggleLiveAccuracy,
            object: nil,
            queue: .main) { _ in
                withAnimation {
                    settings.showLiveAccuracy.toggle()
                }
            }
        
        NotificationCenter.default.addObserver(
            forName: .toggleKeyboard,
            object: nil,
            queue: .main) { _ in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    settings.showKeyboard.toggle()
                }
            }
        
        NotificationCenter.default.addObserver(
            forName: .cancelTest,
            object: nil,
            queue: .main) { _ in
                if model.isTestActive {
                    model.cancelTest()
                    focusInput()
                }
            }
        
        NotificationCenter.default.addObserver(
            forName: .testComplete,
            object: nil,
            queue: .main) { notification in
                if let result = notification.userInfo?["result"] as? TypingTestModel.TestResult {
                    currentResult = result
                    showingResults = true
                }
            }
        
        NotificationCenter.default.addObserver(
            forName: .hideResults,
            object: nil,
            queue: .main) { _ in
                showingResults = false
                currentResult = nil
            }
    }
}

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 5
    var shakesPerUnit = 3
    var animatableData: CGFloat
    
    init(shake: Bool) {
        animatableData = shake ? 1 : 0
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = amount * sin(animatableData * .pi * CGFloat(shakesPerUnit))
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}
