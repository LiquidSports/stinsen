import Foundation
import SwiftUI

public struct TabChildItem {
    public let presentable: ViewPresentable
    let keyPathIsEqual: (Any) -> Bool
    public let tabItem: (Bool) -> AnyView
}

/// Wrapper around childCoordinators
/// Used so that you don't need to write @Published
public class TabChild: ObservableObject {
    weak var parent: ChildDismissable?
    public let startingItems: [AnyKeyPath]
    
    @Published public var activeItem: TabChildItem!
    @Published public var numberOfTaps: Int!
    
    public internal(set) var allItems: [TabChildItem]!
    
    public var activeTab: Int {
        didSet {
            guard oldValue != activeTab else {
                numberOfTaps += 1
                return
            }
            numberOfTaps = 1
            let newItem = allItems[activeTab]
            self.activeItem = newItem
        }
    }
    
    public init(startingItems: [AnyKeyPath], activeTab: Int = 0) {
        self.startingItems = startingItems
        self.activeTab = activeTab
    }
}
