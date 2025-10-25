
⸻

🧩 Часть 1. Принципы перехода Combine → async/await

| Что было (Combine)                  | Что стало (Concurrency)                | Комментарий                                      |
|------------------------------------|--------------------------------------|-------------------------------------------------|
| `@Published → .sink`               | `for await value in $property.values` | Подписка превращается в асинхронный поток      |
| `Just(value)`                       | просто `return value` или `async let` | Just — это просто мгновенное значение          |
| `Future { promise in ... }`         | async функция + `try await`           | Промисы больше не нужны                         |
| `debounce`                          | `try await Task.sleep(...)` перед действием | Можно написать вручную в Task                  |
| `combineLatest`                      | `async let / await TaskGroup`         | Для параллельных значений                       |
| `sink`, `assign`                     | прямое присваивание через `@MainActor` | Асинхронность встроена в поток                  |

⸻

🧱 Часть 2. Архитектура ViewModel (async/await)

Структура, к которой нужно стремиться:

@MainActor
final class SomeViewModel: ObservableObject {
    // MARK: - Published properties
    @Published var text: String = ""
    @Published var items: [Item] = []
    @Published var state: State = .idle

    // MARK: - Internal state
    private var task: Task<Void, Never>? = nil

    // MARK: - Lifecycle
    init() {
        observeTextChanges()
    }

    // MARK: - Public methods (для View)
    func loadData() async { ... }
    func refresh() async { ... }

    // MARK: - Private async logic
    private func observeTextChanges() { ... }
    private func debounce(_ duration: TimeInterval) async { ... }
    private func handleError(_ error: Error) { ... }
}


⸻

## ⚙️ Правила расстановки методов

1. **@Published всегда сверху**  
   → это “интерфейс состояния” между View и ViewModel.

2. **`init()` — сразу после Published**  
   → удобно видеть, какие наблюдения запускаются при создании.

3. **Публичные методы (`load`, `refresh`, `start`, `stop`)**  
   → идут после `init`, это “API” для View.

4. **Приватные async-методы**  
   → всё, что связано с наблюдением, сетевыми вызовами, дебаунсом, обработкой ошибок.

5. **MARK-комментарии**  
   ```swift
   // MARK: - Published properties
   // MARK: - Lifecycle
   // MARK: - Public API
   // MARK: - Private helpers


6.	Каждый async метод должен быть “изолирован”
→ то есть сам управляет своим Task, отменой и MainActor.

⸻

🧠 Пример (Combine → async/await)

Было (Combine):
``` 
final class SearchViewModel: ObservableObject {
    @Published var query = ""
    @Published var results: [String] = []
    private var cancellables = Set<AnyCancellable>()

    init() {
        $query
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] text in
                self?.fetch(text)
            }
            .store(in: &cancellables)
    }

    private func fetch(_ query: String) {
        ...
    }
}
```
Стало (Async/Await):


```
@MainActor
final class SearchViewModel: ObservableObject {
    @Published var query = ""
    @Published var results: [String] = []

    init() {
        observeQueryAsync()
    }

    private func observeQueryAsync() {
        Task {
            for await text in $query.values {
                guard !text.isEmpty else { continue }
                try? await Task.sleep(nanoseconds: 500_000_000) // debounce
                await fetchAsync(text)
            }
        }
    }

    private func fetchAsync(_ query: String) async {
        // имитация API
        results = ["\(query) result 1", "\(query) result 2"]
    }
}
```

⸻

💬 Что важно запомнить

✅ for await $property.values = поток изменений @Published
✅ Task.sleep = debounce/throttle
✅ async let = combineLatest
✅ TaskGroup = merge нескольких задач
✅ @MainActor защищает UI
✅ Всегда cancel() старый Task при создании нового

⸻