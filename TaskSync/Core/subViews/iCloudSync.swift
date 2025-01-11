//
//  iCloudSync.swift
//  TaskSync
//
//  Created by Paul  on 1/10/25.
//

import SwiftUI

struct iCloudSync: View {
    @StateObject var taskModel: TaskViewModel = TaskViewModel()
    @AppStorage("isiCloudSyncEnabled") private var isiCloudSyncEnabled: Bool = true
    @State private var showingSyncAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("iCloud Sync", isOn: $isiCloudSyncEnabled)
                        .onChange(of: isiCloudSyncEnabled) { oldValue, newValue in
                            if newValue {
                                taskModel.startSyncing()
                            }
                        }
                    
                    if isiCloudSyncEnabled {
                        HStack {
                            Text("Last Synced:")
                            Spacer()
                            Text(taskModel.formattedLastSync())
                                .foregroundStyle(.gray)
                        }
                        
                        Button("Manually Sync Data") {
                            taskModel.startSyncing()
                        }
                        .disabled(taskModel.syncStatus == .syncing)
                    }
                }
                
                Section(header: Text("iCloud Sync Status"), footer: Text("Keep your tasks up-to-date with real-time syncing.")) {
                    HStack {
                        Image(systemName: isiCloudSyncEnabled ? getSyncIcon() : "xmark.icloud").foregroundColor(.orange)
                        Text(isiCloudSyncEnabled ? taskModel.syncStatus.statusText : "Syncing issue detected")
                    }
                }
            }
            .alert("Sync Issue", isPresented: $showingSyncAlert, actions: {
                Button("OK", role: .cancel) { }
            }, message: {
                Text("An issue occurred while syncing. Please try again later.")
            })
            .onChange(of: taskModel.syncStatus) { _, newValue in
                if newValue == .issue {
                    showingSyncAlert = true
                }
            }
            .navigationTitle("iCloud Sync")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func getSyncIcon() -> String {
        switch taskModel.syncStatus {
        case .syncing: return "arrow.trianglehead.2.clockwise.rotate.90.icloud" // Syncing icon
        case .issue: return "xmark.icloud" // Error icon
        case .delay: return "exclamationmark.icloud" // Delayed icon
        case .idle: return "icloud" // Idle icon
        }
    }
}

#Preview {
    iCloudSync()
}
