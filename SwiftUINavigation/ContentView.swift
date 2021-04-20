import SwiftUI
import Combine

// This file provides you with cople of different SwiftUI's kinds of navigation.

// Created by Jakub Kornatowski
// Free to use.

struct ContentView1: View {
    var body: some View {
        VStack {
            Text("FirstView 🎉")
            NavigationLink(
                destination:
                    // I can pass here whatever View I want.
                    // i.e.:
                    // Text("Destination"),
                    ContentView2(),
                label: {
                    Text("Navigate to view 2")
                })
                .navigationTitle("Hello, iOS freaks ✋")
        }.eraseToNavigationView()
    }
}

struct ContentView2: View {
    @State var isPresenting: Bool = false {
        didSet {
            // Try to compile it and set a breakpoint here.
            // If the state will change manually by the Button below,
            // then this didSet will handle it.
            // Otherwise in NavigationLink SwiftUI manages it under the hood.
            print(isPresenting)
        }
    }

    var body: some View {
        VStack {
            Text("2️⃣")
            NavigationLink(
                destination: ContentView3(someStringToBeShown: "Hello from View 3 🙌"),
                isActive: $isPresenting,
                label: {
                    Text("Navigate to view 3")
                })
            Button(action: {
                isPresenting.toggle()
            }, label: {
                Text("Change isPresenting")
            })
        }
    }
}

struct ContentView3: View {
    var someStringToBeShown: String

    @State var presenting: Bool = false

    var body: some View {
        VStack {
            Text("3️⃣")
            Text(someStringToBeShown)
            NavigationLink(
                destination: ContentView4(),
                isActive: $presenting,
                label: {
                    Text("Navigate to view 4")
                })
        }
    }
}

struct ContentView4: View {
    @ObservedObject var vm: ViewModel = .init()

    var body: some View {
        ZStack {
            if vm.isLoading {
                Text("Loading 😏...")
            } else {
                VStack {
                    Text("4️⃣")
                    NavigationLink(
                        destination: ContentView5(isPresented: vm.binding),
                        isActive: vm.binding,
                        label: {
                            Text("Navigate to view 5")
                        })
                    Button("Navigate that way") {
                        vm.isPresenting.toggle()
                    }
                }
            }
        }
    }
}

class ViewModel: ObservableObject {
    @Published var isPresenting: Bool = false
    @Published var isLoading: Bool = false

    init() {}

    // This bindgs enable us to handle a navigation async call
    // and update the Published property after the call.
    var binding: Binding<Bool> {
        Binding<Bool>(
            get: { self.isPresenting },
            set: { [weak self] newValue in
                if !newValue {
                    self?.isPresenting = newValue
                    self?.isLoading = false
                } else {
                self?.isLoading = true
                    // Async API request here
                    DispatchQueue.main.schedule(after: .init(.now() + 2)) {
                        self?.isPresenting = newValue
                        self?.isLoading = false
                    }
                }
            }
        )
    }
}

struct ContentView5: View {
    @Binding var isPresented: Bool
    @State var presentModal: Bool = false

    var body: some View {
        VStack {
            Text("🖐🏿")
            Button(action: { isPresented.toggle() }, label: {
                Text("Go back")
            })
            Button(action: { presentModal.toggle() }, label: {
                Text("Present modal")
            })
            NavigationLink(
                destination: ContentView6(),
                label: {
                    Text("Go to selection view")
                })
        }
        .sheet(isPresented: $presentModal, content: {
            ContentModal1()
        })
    }
}

struct ContentView6: View {
    @State var selection: Int? = 1

    var body: some View {
        VStack {
            NavigationLink(
                destination: Text("View with tag 1"),
                tag: 1,
                selection: $selection) {
                Text("Go to view with tag 1")
            }

            NavigationLink(
                destination: Text("View with tag 2"),
                tag: 2,
                selection: $selection) {
                Text("Go to view with tag 2")
            }

            NavigationLink(
                destination: Text("View with tag 3"),
                tag: 3,
                selection: $selection) {
                Text("Go to view with tag 3")
            }

            // This can be invisible also
            NavigationLink(
                destination: Text("View with tag 3"),
                tag: 4,
                selection: $selection) {
                EmptyView()
            }


            Button(action: {
                selection = Int.random(in: Range(uncheckedBounds: (1,4)))
            }, label: {
                Text("Go to random")
            })
        }
    }
}

struct ContentModal1: View {
    var body: some View {
        VStack {
            Text("Modal 1")
            NavigationLink(
                destination: ContentModal2(),
                label: {
                    Text("Navigate to modal 2")
                })
        }
        .eraseToNavigationView()
    }
}

struct ContentModal2: View {
    @Environment(\.presentationMode) var presentation
    @State var presentingAlert: Bool = false

    var body: some View {
        VStack {
            Text("Modal 2")
            Button(action: {
                // You can pop with environment
                presentation.wrappedValue.dismiss()
            }, label: {
                Text("Close me by presentationMode")
            })
            Button(action: {
                // You can pop by changing Binding value
                presentingAlert.toggle()
            }, label: {
                Text("Show alert")
            })
        }
        .alert(isPresented: $presentingAlert, content: {
            Alert(
                title: Text("Hello"),
                message: Text("You are in alert 🤷🏻‍♂️"),
                dismissButton: .cancel()
            )
        })
    }
}

// MARK: - Helpers and Utils
extension View {
    func eraseToNavigationView() -> some View {
        NavigationView { self.offset(y: -60) }
    }
}

// MARK: - Preview
#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView1()
    }
}
#endif
