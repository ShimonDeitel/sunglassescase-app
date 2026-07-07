import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showingAdd = false
    @State private var showingSettings = false
    @State private var showingPaywall = false
    @State private var editingItem: PairItem?

    var body: some View {
        NavigationStack {
            Group {
                if store.items.isEmpty {
                    ContentUnavailableView("No Pairs Yet", systemImage: "tray", description: Text("Tap + to add your first pair."))
                } else {
                    List {
                        ForEach(store.items) { item in
                            Button {
                                editingItem = item
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.name)
                                        .font(Theme.headlineFont)
                                        .foregroundStyle(Theme.ink)
                                    Text("Brand: \(item.brand)")
                                        .font(Theme.bodyFont)
                                        .foregroundStyle(Theme.inkMuted)
                                    Text("Case Location: \(item.caseLocation)")
                                        .font(Theme.bodyFont)
                                        .foregroundStyle(Theme.inkMuted)
                                    if store.categoryToggles["Show Notes on Cards"] == true, !item.notes.isEmpty {
                                        Text(item.notes)
                                            .font(.caption)
                                            .foregroundStyle(Theme.inkMuted)
                                    }
                                }
                            }
                            .accessibilityIdentifier("itemRow_\(item.name)")
                        }
                        .onDelete { offsets in
                            store.delete(at: offsets)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("SunglassesCase")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if store.isAtFreeLimit && !purchases.isPro {
                            showingPaywall = true
                        } else {
                            showingAdd = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("addItemButton")
                }
            }
            .sheet(isPresented: $showingAdd) {
                ItemEditView(item: nil)
            }
            .sheet(item: $editingItem) { item in
                ItemEditView(item: item)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .background(Theme.background.ignoresSafeArea())
        }
    }
}

struct ItemEditView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    var item: PairItem?

    @State private var name: String = ""
    @State private var field1: String = ""
    @State private var field2: String = ""
    @State private var notes: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Pair Details") {
                    TextField("Name", text: $name)
                        .accessibilityIdentifier("itemNameField")
                    TextField("Brand", text: $field1)
                        .accessibilityIdentifier("itemField1Field")
                    TextField("Case Location", text: $field2)
                        .accessibilityIdentifier("itemField2Field")
                }
                Section("Notes") {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .accessibilityIdentifier("itemNotesField")
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .navigationTitle(item == nil ? "Add Pair" : "Edit Pair")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("itemCancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                    .accessibilityIdentifier("itemSaveButton")
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let item {
                    name = item.name
                    field1 = item.brand
                    field2 = item.caseLocation
                    notes = item.notes
                }
            }
        }
    }

    private func save() {
        if var item {
            item.name = name
            item.brand = field1
            item.caseLocation = field2
            item.notes = notes
            store.update(item)
        } else {
            let new = PairItem(name: name, brand: field1, caseLocation: field2, notes: notes)
            store.add(new)
        }
    }
}
