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
        case itemDetail(Item.ID)
        case itemDetailRoute(ItemDetailState.Route)
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
    case tappedItem(Item.ID)
    case itemDetail(ItemDetailAction)
}

let appReducer = Reducer<AppState, AppAction, Void> { state, action, _ in
    switch action {
    case .itemDetail(.tappedChildButton):
        state.path.append(.itemDetailRoute(.child))
        return .none
    case let .tappedItem(id):
        guard let item = state.items[id: id] else { return .none }
        state.itemDetail = .init(item: item)
        state.path.append(.itemDetail(item.id))
        return .none
    case .binding(\.$path):
        if state.path.isEmpty {
            state.itemDetail = nil
        }
        return .none
    case .binding:
        return .none
    case .itemDetail:
        return .none
    }
}
.binding()

struct Item: Identifiable, Equatable, Hashable {
    var id: UUID = .init()
    var name: String
}

struct ItemDetailState: Equatable {
    let item: Item

    enum Route {
        case child
    }
}

enum ItemDetailAction {
    case tappedChildButton
}

struct ContentView: View {
    let store: Store<AppState, AppAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationStack(path: viewStore.binding(\.$path)) {
                List {
                    ForEach(viewStore.items) { item in
//                        NavigationLink(item.name, value: AppState.Route.itemDetail(id: item.id))
                        Button {
                            viewStore.send(.tappedItem(item.id))
                        } label: {
                            Text(item.name)
                        }
                        .buttonStyle(NavigationLinkButtonStyle())
                    }
                    NavigationLink("Navigation Link", value: "foo")
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
                    case .itemDetailRoute(.child):
                        Text("Child View")
                    }
                }
            }
        }
    }
}

struct NavigationLinkButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.bold))
                .foregroundColor(Color(UIColor.tertiaryLabel))
        }
        .contentShape(Rectangle())
    }
}

struct DetailView: View {
    let store: Store<ItemDetailState, ItemDetailAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            Text(viewStore.item.name)

            Button("Open Child") {
                viewStore.send(.tappedChildButton)
            }
        }
//        .navigationDestination(for: ItemDetailState.Route.self) { route in
//            switch route {
//            case .child:
//                Text("Child View")
//            }
//        }
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
