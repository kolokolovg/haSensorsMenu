import SwiftUI

struct SwitchesSettingsView: View {
    @ObservedObject var settings: SettingsManager
    @State private var showingAddSwitch = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(L10n("configured_switches"))
                    .font(.headline)
                Spacer()
                Button(action: { showingAddSwitch = true }) {
                    Label(L10n("add"), systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
            }

            if settings.switches.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "togglepower")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text(L10n("no_switches"))
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text(L10n("add_first_switch"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 200)
            } else {
                VStack(spacing: 0) {
                    ForEach($settings.switches) { $switchConfig in
                        SwitchConfigRow(switchConfig: $switchConfig, settings: settings)
                        if switchConfig.id != settings.switches.last?.id {
                            Divider()
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .sheet(isPresented: $showingAddSwitch) {
            AddSwitchView(settings: settings)
        }
    }
}

struct SwitchConfigRow: View {
    @Binding var switchConfig: HASwitchConfig
    @ObservedObject var settings: SettingsManager
    @State private var showingEdit = false

    private var index: Int {
        settings.switches.firstIndex(where: { $0.id == switchConfig.id }) ?? 0
    }

    private var isFirst: Bool { index == 0 }
    private var isLast: Bool { index == settings.switches.count - 1 }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .foregroundColor(.accentColor)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(switchConfig.name)
                    .font(.headline)
                Text(switchConfig.entityID)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: {
                withAnimation {
                    settings.switches.move(fromOffsets: IndexSet(integer: index), toOffset: index - 1)
                }
            }) {
                Image(systemName: "chevron.up")
            }
            .buttonStyle(.borderless)
            .disabled(isFirst)
            .help(L10n("edit"))

            Button(action: {
                withAnimation {
                    settings.switches.move(fromOffsets: IndexSet(integer: index), toOffset: index + 2)
                }
            }) {
                Image(systemName: "chevron.down")
            }
            .buttonStyle(.borderless)
            .disabled(isLast)
            .help(L10n("edit"))

            Button(action: { showingEdit = true }) {
                Image(systemName: "pencil.circle")
            }
            .buttonStyle(.borderless)
            .help(L10n("edit"))

            Button(action: {
                withAnimation {
                    settings.switches.removeAll { $0.id == switchConfig.id }
                }
            }) {
                Image(systemName: "trash.circle")
            }
            .buttonStyle(.borderless)
            .foregroundColor(.red)
            .help(L10n("delete"))
        }
        .padding(.vertical, 12)
        .sheet(isPresented: $showingEdit) {
            EditSwitchView(switchConfig: $switchConfig)
        }
    }

    var iconName: String {
        let domain = switchConfig.entityID.components(separatedBy: ".").first ?? ""
        return domain == "light" ? "lightbulb.fill" : "powerplug.fill"
    }
}

struct AddSwitchView: View {
    @ObservedObject var settings: SettingsManager
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var entityID = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(L10n("add_switch"))
                .font(.title2)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 16) {
                    Text(L10n("name"))
                        .frame(width: 120, alignment: .leading)
                    TextField("", text: $name)
                        .textFieldStyle(.roundedBorder)
                }

                HStack(spacing: 16) {
                    Text(L10n("entity_id"))
                        .frame(width: 120, alignment: .leading)
                    TextField("", text: $entityID)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(.body, design: .monospaced))
                }
            }

            HStack {
                Spacer()
                Button(L10n("cancel")) { dismiss() }
                Button(L10n("add")) {
                    settings.switches.append(HASwitchConfig(name: name, entityID: entityID))
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(name.isEmpty || entityID.isEmpty)
            }
        }
        .padding(20)
        .frame(width: 500, alignment: .leading)
    }
}

struct EditSwitchView: View {
    @Binding var switchConfig: HASwitchConfig
    @Environment(\.dismiss) var dismiss
    @State private var name: String
    @State private var entityID: String

    init(switchConfig: Binding<HASwitchConfig>) {
        self._switchConfig = switchConfig
        self._name = State(initialValue: switchConfig.wrappedValue.name)
        self._entityID = State(initialValue: switchConfig.wrappedValue.entityID)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(L10n("edit_switch"))
                .font(.title2)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 16) {
                    Text(L10n("name"))
                        .frame(width: 120, alignment: .leading)
                    TextField("", text: $name)
                        .textFieldStyle(.roundedBorder)
                }

                HStack(spacing: 16) {
                    Text(L10n("entity_id"))
                        .frame(width: 120, alignment: .leading)
                    TextField("", text: $entityID)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(.body, design: .monospaced))
                }
            }

            HStack {
                Spacer()
                Button(L10n("cancel")) { dismiss() }
                Button(L10n("save")) {
                    switchConfig.name = name
                    switchConfig.entityID = entityID
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(name.isEmpty || entityID.isEmpty)
            }
        }
        .padding(20)
        .frame(width: 500, alignment: .leading)
    }
}
