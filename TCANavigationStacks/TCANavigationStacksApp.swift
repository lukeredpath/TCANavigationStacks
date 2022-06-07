//
//  TCANavigationStacksApp.swift
//  TCANavigationStacks
//
//  Created by Luke Redpath on 07/06/2022.
//

import ComposableArchitecture
import SwiftUI

@main
struct TCANavigationStacksApp: App {
    @State var store = Store<AppState, AppAction>(
        initialState: .mock,
        reducer: appReducer.debug(),
        environment: ()
    )

    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
    }
}
