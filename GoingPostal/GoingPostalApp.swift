//
//  GoingPostalApp.swift
//  GoingPostal
//
//  Created by Robert le Clus on 2024/05/14.
//

import SwiftUI

@main
struct GoingPostalApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(PostService.shared)
        }
    }
}
