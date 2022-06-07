//
//  ContentView.swift
//  TCANavigationStacks
//
//  Created by Luke Redpath on 07/06/2022.
//

import ComposableArchitecture
import SwiftUI

struct AppState: Equatable {
    var items: IdentifiedArrayOf<Item>
    var itemDetail: ItemDetailState?
    @BindableState var path: [Route] = []

    enum Route: Equatable, Hashable {
        case itemDetail(id: Item.ID)
    }
}

extension AppState {
    static let mock = AppState(
        items: [
            .init(name: "Apple"),
            .init(name: "Banana"),
            .init(name: "Pear")
        ]
    )
}

enum AppAction: BindableAction {
    case binding(BindingAction<AppState>)
    case itemDetail(ItemDetailAction)
}

let appReducer = Reducer<AppState, AppAction, Void> { state, action, _ in
    switch action {
    case .binding(\.$path):
        guard let route = state.path.last else {
            state.itemDetail = nil
            return .none
        }
        switch route {
        case let .itemDetail(id):
            guard let item = state.items[id: id] else { return .none }
            state.itemDetail = .init(item: item)
        }
        return .none
    case .binding:
        return .none
    case .itemDetail:
        return .none
    }
}
.binding()

struct Item: Identifiable, Equatable {
    var id: UUID = .init()
    var name: String
}

struct ItemDetailState: Equatable {
    let item: Item
}

enum ItemDetailAction {
    case stub
}

struct ContentView: View {
    let store: Store<AppState, AppAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationStack(path: viewStore.binding(\.$path)) {
                List {
                    ForEach(viewStore.items) { item in
                        NavigationLink(item.name, value: AppState.Route.itemDetail(id: item.id))
                    }
                }
                .navigationTitle("Items")
                .navigationDestination(for: AppState.Route.self) { route in
                    switch route {
                    case .itemDetail:
                        IfLetStore(
                            store.scope(
                                state: \.itemDetail,
                                action: AppAction.itemDetail
                            ),
                            then: DetailView.init(store:)
                        )
                    }
                }
            }
        }
    }
}

struct DetailView: View {
    let store: Store<ItemDetailState, ItemDetailAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            Text(viewStore.item.name)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            store: .init(
                initialState: .mock,
                reducer: appReducer,
                environment: ()
            )
        )
    }
}
