Reading from public effective user settings.
[Planner] ## 單字卡 App 複習流程

### 目標
* 設計一個 SwiftUI 單字卡 App，幫助使用者高效管理和複習單字。

### 功能
* 顯示單字卡
* 增加單字卡
* 刪除單字卡
* 顯示單字卡的正確性
* 顯示單字卡的錯誤率

### 介面
* 單字卡列表
* 單字卡詳細頁面

### 技術
* SwiftUI
* Model
* DataSource

### 實作步驟
* 建立單字卡模型
* 建立單字卡列表
* 建立單字卡詳細頁面
* 建立 DataSource

### 第一版方案

#### 單字卡模型

```swift 5.10
import Foundation

struct WordCard: Identifiable {
    let id = UUID()
    let word: String
    let definition: String
    let isLearned: Bool
}
```

#### 單字卡列表

```swift 5.10
import SwiftUI

struct WordCardListView: View {
    @State private var wordCards: [WordCard] = [
        WordCard(word: "apple", definition: "紅色的水果", isLearned: false),
        WordCard(word: "banana", definition: "黃色的水果", isLearned: false),
        WordCard(word: "cherry", definition: "紅色的石榴", isLearned: false)
    ]

    var body: some View {
        NavigationView {
            List(wordCards) { card in
                NavigationLink(destination: WordCardDetailView(card: card)) {
                    VStack(alignment: .leading) {
                        Text(card.word)
                            .font(.headline)
                            .foregroundColor(.blue)
                        Text(card.isLearned ? "已學過" : "未學過")
                            .foregroundColor(.green)
                    }
                }
            }
            .navigationTitle("單字卡")
        }
    }
}
```

#### 單字卡詳細頁面

```swift 5.10
import SwiftUI

struct WordCardDetailView: View {
    @State private var card: WordCard

    var body: some View {
        VStack(alignment: .leading) {
            Text(card.word)
                .font(.largeTitle)
            Text(card.definition)
                .font(.subheadline)
            Spacer()
            Button(action: {
                card.isLearned.toggle()
            }) {
                Text(card.isLearned ? "已學過" : "未學過")
                    .foregroundColor(.green)
            }
            .padding()
            Spacer()
            Text("正確率: \(card.isLearned ? 100 : 0)%")
                .font(.subheadline)
        }
        .padding()
    }
}
```

#### DataSource

```swift 5.10
import SwiftUI

class WordCardDataSource: ObservableObject {
    @Published var wordCards: [WordCard] = [
        WordCard(word: "apple", definition: "紅色的水果", isLearned: false),
        WordCard(word: "banana", definition: "黃色的水果", isLearned: false),
        WordCard(word: "cherry", definition: "紅色的石榴", isLearned: false)
    ]
}
```

### 使用範例

```swift 5.10
@main
struct WordCardApp: App {
    var body: some Scene {
        WindowGroup {
            WordCardListView()
        }
    }
}
```

[Critic] ### 盲點

* 單字卡列表與詳細頁面的關係是隱藏的，使用者無法直接從列表中刪除單字卡。

* 儲存單字卡的狀態是透過 `@Published` 變數來管理，如果儲存到外部的文件中，這些變數會隨時間變化，導致 UI 更新不一致。

* 正確率的計算是透過 `card.isLearned.toggle()` 來修改狀態，這可能會導致錯誤率的計算不正確，因為狀態修改可能會影響正確率的計算方式。

### 補充更好的做法

* 使用 `@StateObject` 來管理單字卡的狀態，這樣可以避免使用 `@Published` 變數來管理狀態。

* 使用 `.environmentObject` 來提供單字卡資料給其他部分，這樣可以避免重複管理單字卡資料。

* 使用 `.onAppear` 來計算正確率，這樣可以避免每次啟動時重新計算正確率。

### 使用範例

```swift 5.10
import Foundation

struct WordCard: Identifiable {
    let id = UUID()
    let word: String
    let definition: String
    let isLearned: Bool
}

class WordCardManager: ObservableObject {
    @Published var wordCards: [WordCard] = [
        WordCard(word: "apple", definition: "紅色的水果", isLearned: false),
        WordCard(word: "banana", definition: "黃色的水果", isLearned: false),
        WordCard(word: "cherry", definition: "紅色的石榴", isLearned: false)
    ]

    func toggleLearned(for card: WordCard) {
        card.isLearned.toggle()
    }

    func calculateAccuracy() -> Double {
        let learnedCount = wordCards.filter { $0.isLearned }.count
        return Double(learnedCount) / Double(wordCards.count) * 100
    }
}

@main
struct WordCardApp: App {
    var body: some Scene {
        WindowGroup {
            WordCardListView()
                .environmentObject(WordCardManager())
        }
    }
}
```

[Planner] ### 修正版方案

#### 修改單字卡列表

* 使用 `@StateObject` 來管理單字卡資料。
* 使用 `.environmentObject` 來提供單字卡資料給其他部分。
* 使用 `.onAppear` 來計算正確率。

#### 修改單字卡詳細頁面

* 使用 `@EnvironmentObject` 來提供單字卡資料給其他部分。

#### 使用範例

```swift 5.10
import Foundation

struct WordCard: Identifiable {
    let id = UUID()
    let word: String
    let definition: String
    let isLearned: Bool
}

class WordCardManager: ObservableObject {
    @Published var wordCards: [WordCard] = [
        WordCard(word: "apple", definition: "紅色的水果", isLearned: false),
        WordCard(word: "banana", definition: "黃色的水果", isLearned: false),
        WordCard(word: "cherry", definition: "紅色的石榴", isLearned: false)
    ]

    func toggleLearned(for card: WordCard) {
        card.isLearned.toggle()
    }

    func calculateAccuracy() -> Double {
        let learnedCount = wordCards.filter { $0.isLearned }.count
        return Double(learnedCount) / Double(wordCards.count) * 100
    }
}

@main
struct WordCardApp: App {
    var body: some Scene {
        WindowGroup {
            WordCardListView()
                .environmentObject(WordCardManager())
        }
    }
}
```
