Lightweight Swift Package for Android-style toast notifications on iOS.

## SwiftUI

```
struct ContentView: View {
    @State private var toast: Toast?

    var body: some View {
        Button("Show toast") {
            toast = Toast(image: .sfSymbol("checkmark"), text: "Saved!")
        }
        .toast($toast)
    }
}
```

## UIKit

```
let toastContainer = ToastContainerView()
view.addSubview(toastContainer)
NSLayoutConstraint.activate([
    toastContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
    toastContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    toastContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
])

toastContainer.show(Toast(image: .sfSymbol("checkmark"), text: "Saved!"))
```
