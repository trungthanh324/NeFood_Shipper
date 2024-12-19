//
//  NeFoodforDeliverierApp.swift
//  NeFoodforDeliverier
//
//  Created by Trung Thành  on 27/10/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAnalytics
@main
struct NeFoodforDeliverierApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

//    init(){
//        FirebaseApp.configure()
//    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
class AppDelegate : NSObject, UIApplicationDelegate{
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        //Analytics.setAnalyticsCollectionEnabled(true)
        return true
    }
}

