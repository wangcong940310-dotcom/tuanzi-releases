import SpriteKit

enum TextureGroup: String, CaseIterable {
    case idle, randomIdle1, randomIdle2
    case enterSearch, searchLoop, exitSearch
    case enterThinking, thinkingLoop, exitThinking
    case enterWorking, workingLoop, exitWorking
    case drinkWater, message, click
    case enterSleep, sleepLoop, wakeUp
    case enterTyping, typingLoop, exitTyping
    case dragEnter, dragLoop, dragExit
    case runEnter, runLoop, runExit, runRest
    case pet, attention
    case snapLeftEnter, snapLeftIdle, snapLeftExit
    case snapRightEnter, snapRightIdle, snapRightExit
    case snapReminder1, snapReminder2

    var recipe: (prefix: String, range: Range<Int>) {
        switch self {
        case .idle:             return ("待机",     0..<240)
        case .randomIdle1:      return ("伸懒腰",   0..<80)
        case .randomIdle2:      return ("舔爪子",   0..<80)

        case .enterSearch:      return ("搜索",     0..<20)
        case .searchLoop:       return ("搜索",     20..<67)
        case .exitSearch:       return ("搜索",     67..<80)

        case .enterThinking:    return ("思考",     0..<17)
        case .thinkingLoop:     return ("思考",     17..<67)
        case .exitThinking:     return ("思考",     67..<79)

        case .enterWorking:     return ("工作",     0..<59)
        case .workingLoop:      return ("工作",     59..<78)
        case .exitWorking:      return ("工作",     78..<127)

        case .drinkWater:       return ("喝水",     0..<80)
        case .message:          return ("提醒",     0..<48)
        case .click:            return ("戳",       19..<48)

        case .enterSleep:       return ("睡觉",     0..<52)
        case .sleepLoop:        return ("睡觉",     52..<120)
        case .wakeUp:           return ("睡觉",     120..<160)

        case .enterTyping:      return ("敲键盘",   0..<38)
        case .typingLoop:       return ("敲键盘",   38..<100)
        case .exitTyping:       return ("敲键盘",   100..<128)

        case .dragEnter:        return ("提起",     18..<59)
        case .dragLoop:         return ("提起",     129..<177)
        case .dragExit:         return ("提起",     178..<226)

        case .runEnter:         return ("滚动",     0..<46)
        case .runLoop:          return ("滚动",     46..<81)
        case .runExit:          return ("滚动",     81..<106)
        case .runRest:          return ("滚动",     106..<152)

        case .pet:              return ("摸摸",     0..<80)
        case .attention:        return ("完成",     0..<80)

        case .snapLeftEnter:    return ("走到左侧", 0..<49)
        case .snapLeftIdle:     return ("左侧待机", 0..<81)
        case .snapLeftExit:     return ("左侧走出", 0..<49)
        case .snapRightEnter:   return ("走到右侧", 0..<49)
        case .snapRightIdle:    return ("右侧待机", 0..<81)
        case .snapRightExit:    return ("右侧走出", 0..<49)
        case .snapReminder1:    return ("右提醒",   0..<48)
        case .snapReminder2:    return ("左提醒",   0..<48)
        }
    }

    static let normalNonEssential: Set<TextureGroup> = [
        .enterSearch, .searchLoop, .exitSearch,
        .enterThinking, .thinkingLoop, .exitThinking,
        .enterWorking, .workingLoop, .exitWorking,
        .drinkWater, .message, .click,
        .enterSleep, .sleepLoop, .wakeUp,
        .enterTyping, .typingLoop, .exitTyping,
        .dragEnter, .dragLoop, .dragExit,
        .runEnter, .runLoop, .runExit, .runRest,
        .pet, .attention,
    ]

    static let snapAll: Set<TextureGroup> = [
        .snapLeftEnter, .snapLeftIdle, .snapLeftExit,
        .snapRightEnter, .snapRightIdle, .snapRightExit,
        .snapReminder1, .snapReminder2,
    ]
}

final class TextureManager {
    static let shared = TextureManager()
    private init() {}

    private var cache: [TextureGroup: [SKTexture]] = [:]

    private static func loadFromFile(_ name: String) -> SKTexture {
        if let path = Bundle.main.path(forResource: name, ofType: "webp"),
           let image = NSImage(contentsOfFile: path) {
            return SKTexture(image: image)
        }
        return SKTexture(imageNamed: name)
    }

    func textures(for group: TextureGroup) -> [SKTexture] {
        if let cached = cache[group] { return cached }
        let r = group.recipe
        let textures = r.range.map { Self.loadFromFile("\(r.prefix)_\($0)") }
        cache[group] = textures
        return textures
    }

    func preload(_ groups: Set<TextureGroup>) {
        var allTextures: [SKTexture] = []
        for group in groups {
            allTextures.append(contentsOf: textures(for: group))
        }
        SKTexture.preload(allTextures) { }
    }

    func evict(_ groups: Set<TextureGroup>) {
        for group in groups {
            cache.removeValue(forKey: group)
        }
    }

    func evictAll(except keep: Set<TextureGroup> = []) {
        for key in cache.keys where !keep.contains(key) {
            cache.removeValue(forKey: key)
        }
    }
}
