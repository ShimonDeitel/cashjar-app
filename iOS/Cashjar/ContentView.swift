import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showAddSheet = false
    @State private var showPaywall = false
    @State private var showSettings = false
    @State private var draftName: String = ""
    @State private var draftBalance: Double = 0

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                List {
                    ForEach(store.items) { item in
                        VStack(alignment: .leading) {
                        Text(item.name).font(Theme.bodyFont.bold())
                        Text(item.balance, format: .currency(code: "USD"))
                            .font(Theme.captionFont)
                    }
                        .listRowBackground(Theme.card)
                    }
                    .onDelete { store.delete(at: $0) }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Cashjar")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        if store.isAtFreeLimit {
                            showPaywall = true
                        } else {
                            showAddSheet = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addItemButton")
                }
            }
            .sheet(isPresented: $showAddSheet) {
                addSheet
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView().accessibilityIdentifier("paywallView")
            }
        }
    }

    private var addSheet: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                    .accessibilityIdentifier("addItemFormBackground")
                    .onTapGesture {
                        hideKeyboard()
                    }
                Form {
                    Section {
                        TextField("Jar name", text: $draftName)
                        .accessibilityIdentifier("jarNameField")
                    TextField("Starting balance", value: $draftBalance, format: .number)
                        .keyboardType(.decimalPad)
                        .accessibilityIdentifier("jarBalanceField")
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("New Entry")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        _ = store.add(Jar(name: draftName, balance: draftBalance))
                        draftName = ""
                        draftBalance = 0
                        showAddSheet = false
                    }
                    .accessibilityIdentifier("saveItemButton")
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showAddSheet = false }
                        .accessibilityIdentifier("cancelItemButton")
                }
            }
        }
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
