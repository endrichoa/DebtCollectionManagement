//
//  UrunanTBkuApp.swift
//  UrunanTBku
//
//  Created by Endricho Abednego on 05/09/25.
//

import SwiftUI
import UIKit
import FirebaseCore

@main
struct UrunanTBkuApp: App {
    // Initialize Firebase at launch
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.appEnvironment, AppEnvironment.live)
                .preferredColorScheme(.light)
                .onAppear {
                    // Start Firestore listeners after Firebase is configured
                    AppEnvironment.live.dataManager.startListening()
                }
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Configure Firebase FIRST before anything else
        FirebaseApp.configure()
        return true
    }
}
