//
//  settingsView.swift
//  TaskSync
//
//  Created by Paul  on 4/7/25.
//

import SwiftUI
import RevenueCat
import WebKit
import UserNotifications

struct settingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
    @EnvironmentObject var appSubModel: appSubscriptionModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showDebug: Bool = false
    @State private var isPaywallPresented: Bool = false
    @State private var isPresentedManageSubscription = false
    @State private var showStoreView = false
    
    var body: some View {
        NavigationStack {
            List {
                if !appSubModel.isSubscriptionActive {
                    customPremiumBanner {
                        isPaywallPresented = true
                        HapticManager.shared.notify(.notification(.success))
                    }
                    .listRowInsets(EdgeInsets())
                }
                
                Section(header: Text("Notifications & Alerts"), footer: Text("Use this setting to turn off notifications on specific devices")) {
                    customRow(icon: "bell.badge", firstLabel: "Enabled on this device", secondLabel: "", showToggle: true, toggleValue: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { oldValue, newValue in
                            if !newValue {
                                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                                UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                                print("All notifications removed.")
                            }
                        }
                }
                
                Section(header: Text("Support")) {
                    customRow(icon: "questionmark.bubble", firstLabel: "Frequently Asked Questions", secondLabel: "", destination: AnyView(helpFAQView()))
                    
                    customRow(icon: "envelope", firstLabel: "Contact Support", secondLabel: "", destination: AnyView(feedbackView()))
                }
                
                Section(header: Text("Info")) {
                    customRow(icon: "list.clipboard", firstLabel: "About", secondLabel: "", destination: AnyView(aboutView()))
                    
                    customRow(icon: "app.badge", firstLabel: "Release Notes", secondLabel: "", destination: AnyView(releaseNotesView()))
                    
                    if appSubModel.isSubscriptionActive {
                        customRow(icon: "crown", firstLabel: "Manage Subscription", secondLabel: "") {
                            isPresentedManageSubscription = true
                        }
                    }
                    
                    if AppReviewRequest.showReviewButton, let url = AppReviewRequest.appURL(id: "id6737742961") {
                        customRow(icon: "star.bubble", firstLabel: "Rate & Review \(Bundle.main.appName)", secondLabel: "") {
                            UIApplication.shared.open(url)
                        }
                    }
                    
                    customRow(icon: "paperplane", firstLabel: "Join TestFlight (Beta)", secondLabel: "", url: "https://testflight.apple.com/join/P7YJDrsY", showJoinInsteadOfSafari: true)
                    
                    customRow(icon: "square.and.arrow.up", firstLabel: "Share with Friends", secondLabel: "", shareURL: URL(string: "https://apps.apple.com/us/app/tasksync-task-manager/id6737742961"))
                    
                    customRow(icon: "square.fill.text.grid.1x2", firstLabel: "More Apps", secondLabel: "") {
                        showStoreView = true
                    }
                }
                
                Section(header: Text("Legal")) {
                    customRow(icon: "link", firstLabel: "Privacy Policy", secondLabel: "", url: "https://paulrodenjr.org/tasksyncprivacypolicy")
                    
                    customRow(icon: "link", firstLabel: "Terms of Service", secondLabel: "", url: "https://paulrodenjr.org/tasksynctermsofservice")
                    
                    customRow(icon: "link", firstLabel: "EULA", secondLabel: "", url: "https://paulrodenjr.org/tasksynceula")
                }
#if DEBUG
                Section(header: Text("Debuging Tools")) {
                    customRow(icon: "ladybug", firstLabel: "RC Debug Overlay", secondLabel: "") {
                        showDebug.toggle()
                    }
                }
#endif
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle(Text("Settings"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Text("Done")
                    }
                }
            }
            .fullScreenCover(isPresented: $isPaywallPresented) {
                SubscriptionView(isPaywallPresented: $isPaywallPresented)
                    .preferredColorScheme(.dark)
            }
            .background(
                StoreProductPresenter(appStoreID: 693041126, isPresented: $showStoreView)
            )
            .manageSubscriptionsSheet(isPresented: $isPresentedManageSubscription)
            .debugRevenueCatOverlay(isPresented: $showDebug)
        }
    }
}

#Preview {
    settingsView()
}

// MARK: Custom Row
struct customRow: View {
    var icon: String
    var firstLabel: String
    var firstLabelColor: Color = .gray
    var secondLabel: String
    var action: (() -> Void)? = nil  /// <-- Optional action
    var destination: AnyView? = nil  /// <-- Optional navigation
    var url: String? = nil           /// <-- Optional URL
    var showToggle: Bool = false
    var toggleValue: Binding<Bool>? = nil /// <-- Optional toggle switch
    var shareURL: URL? = nil             /// <-- Optional share link
    var showJoinInsteadOfSafari: Bool? = nil
    
    @State private var isNavigating = false
    @State private var isSharing = false
    
    var body: some View {
        Group {
            if let urlString = url {
                NavigationLink {
                    webView(url: urlString)
                        .edgesIgnoringSafeArea(.all)
                        .navigationTitle(firstLabel)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                if let link = URL(string: urlString) {
                                    Link(destination: link) {
                                        if showJoinInsteadOfSafari ?? false {
                                            Text("Join")
                                                .fontWeight(.bold)
                                        } else {
                                            Image(systemName: "safari")
                                        }
                                    }
                                }
                            }
                        }
                } label: {
                    rowContent(showChevron: false)
                }
                .buttonStyle(.plain)
            } else if let destination = destination {
                NavigationLink {
                    destination
                } label: {
                    rowContent(showChevron: false)
                }
                .buttonStyle(.plain)
            } else if showToggle {
                rowContent(showChevron: false)
            } else {
                rowContent(showChevron: action != nil || shareURL != nil)
                    .onTapGesture {
                        if shareURL != nil {
                            isSharing = true
                        } else {
                            action?()
                        }
                    }
            }
        }
        .sheet(isPresented: $isSharing) {
            if let shareURL = shareURL {
                ActivityView(activityItems: [shareURL])
            }
        }
    }
    
    private func rowContent(showChevron: Bool) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 18)) /// <-- Fixed size, unaffected by user settings
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(.blue.gradient)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Text(firstLabel)
                .font(.headline)
                .foregroundStyle(.primary)
            
            Spacer()
            
            if showToggle, let binding = toggleValue {
                Toggle("", isOn: binding)
                    .labelsHidden()
            } else if showChevron {
                Image(systemName: "chevron.right")
                    .font(.headline)
                    .imageScale(.small)
                    .foregroundColor(Color.init(uiColor: .systemGray3))
            } else {
                Text(secondLabel)
                    .foregroundStyle((action == nil && destination == nil && url == nil && shareURL == nil) ? .gray : .primary)
            }
        }
        .contentShape(Rectangle())
    }
    
    private func isWebsite(_ urlString: String) -> Bool {
        return urlString.hasPrefix("http")
    }
}

// MARK: ActivityView
struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: WebView
struct webView: UIViewRepresentable {
    var url: String
    func makeUIView(context: UIViewRepresentableContext<webView>) -> WKWebView {
        let view = WKWebView()
        view.load(URLRequest(url: URL(string: url)!))
        return view
    }
    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<webView>) {
    }
}

// MARK: Custom Banner
struct customPremiumBanner: View {
    var onTap: () -> Void
    
    let features = [
        "Syncing from calendar",
        "and more"
    ]
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(Bundle.main.appName) Pro")
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                    
                    ForEach(features, id: \.self) { feature in
                        Text("- \(feature)")
                            .font(.subheadline)
                            .foregroundStyle(.white)
                            .opacity(0.7)
                    }
                }
                
                Spacer()
                
                ZStack {
                    Image(systemName: "checklist")
                        .font(.system(size: 70)) /// <-- Originally the size was 80
                        .foregroundStyle(.white)
                        .opacity(0.1)
                        .rotationEffect(.degrees(-20))
                        .scaleEffect(1.8) /// <-- Make it larger without affecting layout
                        .offset(x: -10, y: 20)
                        .allowsHitTesting(false) /// <-- Avoids affecting taps
                    
                    Image(systemName: "crown.fill") /// <-- Foreground icon
                        .font(.system(size: 50))
                        .foregroundStyle(.white)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle()) /// <-- Prevents default blue button style
    }
}

struct webViewScreen: View {
    let urlString: String
    let firstLabel: String
    
    var body: some View {
        webView(url: urlString)
            .edgesIgnoringSafeArea(.all)
            .navigationTitle(firstLabel)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if let link = URL(string: urlString) {
                        Link(destination: link) {
                            Image(systemName: "safari")
                        }
                    }
                }
            }
    }
}
