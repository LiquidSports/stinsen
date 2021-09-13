import Foundation
import SwiftUI

///The ViewCoordinatable represents a view with routes that can be switched to but not pushed or presented modally. This can be used if you have a need to switch between different "modes" in the app, for instance if you switch between logged in and logged out. The ViewCoordinatable will recreate the view and the coordinator, so it is not suited to replace a tab-bar or similar modes of navigation, where you want to preserve the state.
public protocol ViewCoordinatable: Coordinatable {
    typealias Route = ViewRoute
    typealias Router = ViewRouter<Self>
    
    associatedtype CustomizeViewType: View
    associatedtype Start: View
    /// The initial view of the ViewCoordinatable
    @ViewBuilder func start() -> Start
    
    /**
     Implement this function if you wish to customize the view on all views and child coordinators, for instance, if you wish to change the `tintColor` or inject an `EnvironmentObject`.

     - Parameter view: The input view.

     - Returns: The modified view.
     */
    func customize(_ view: AnyView) -> CustomizeViewType

    var child: ViewChild { get }
    
    /**
     Changes the active route.

     - Parameter route: The route to switch to.
     - Parameter input: The parameters that are used to create the coordinator.
     - Parameter comparator: The function to use to determine if the inputs are equal
     */
    @discardableResult func route<Input, Output: Coordinatable>(
        to route: KeyPath<Self, ((Self) -> ((Input) -> Output))>,
        _ input: Input,
        comparator: @escaping (Input, Input) -> Bool
    ) -> Output
    
    /**
     Changes the active route.

     - Parameter route: The route to switch to.
     - Parameter input: The parameters that are used to create the coordinator. If input conforms to `Equatable`, there is no need to add a comparator unless you need it.
     */
    @discardableResult func route<Input: Equatable, Output: Coordinatable>(
        to route: KeyPath<Self, ((Self) -> ((Input) -> Output))>,
        _ input: Input
    ) -> Output
    
    /**
     Changes the active route.

     - Parameter route: The route to switch to.
     - Parameter input: The parameters that are used to create the view. If input conforms to `Equatable`, there is no need to add a comparator unless you need it.
     */
    @discardableResult func route<Input: Equatable, Output: View>(
        to route: KeyPath<Self, ((Self) -> ((Input) -> Output))>,
        _ input: Input
    ) -> Output
    
    /**
     Changes the active route.

     - Parameter route: The route to switch to.
     - Parameter input: The parameters that are used to create the view.
     - Parameter comparator: The function to use to determine if the inputs are equal
     */
    @discardableResult func route<Input, Output: View>(
        to route: KeyPath<Self, ((Self) -> ((Input) -> Output))>,
        _ input: Input,
        comparator: @escaping (Input, Input) -> Bool
    ) -> Output
    
    /**
     Changes the active route.

     - Parameter route: The route to switch to.
     */
    @discardableResult func route<Output: Coordinatable>(
        to route: KeyPath<Self, ((Self) -> ((Void) -> Output))>
    ) -> Output
    
    /**
     Changes the active route.

     - Parameter route: The route to switch to.
     */
    @discardableResult func route<Output: View>(
        to route: KeyPath<Self, (Self) -> ((Void) -> Output)>
    ) -> Output
    
    /**
     Resets the ViewCoordinatable to use the view returned by `start()`.
     */
    @discardableResult func reset() -> Self
    
    /**
     Checks if no routes is active, i.e. the coordinator is showing the view returned by `start()`.
     */
    func isStart() -> Bool
    
    /**
     Checks if the specified route is active, i.e. is the one currently showing.

     - Parameter route: The route to check.
     */
    func isActive<Output: Coordinatable>(
        _ route: KeyPath<Self, ((Self) -> ((Void) -> Output))>
    ) -> Bool
    
    /**
     Checks if the specified route is active, i.e. is the one currently showing.

     - Parameter route: The route to check.
     */
    func isActive<Output: View>(
        _ route: KeyPath<Self, (Self) -> ((Void) -> Output)>
    ) -> Bool
    
    /**
     Checks if the specified route is active, i.e. is the one currently showing.

     - Parameter route: The route to check.
     */
    func isActive<Input, Output: Coordinatable>(
        _ route: KeyPath<Self, ((Self) -> ((Input) -> Output))>
    ) -> Bool
    
    /**
     Checks if the specified route is active, i.e. is the one currently showing.

     - Parameter route: The route to check.
     */
    func isActive<Input, Output: View>(
        _ route: KeyPath<Self, (Self) -> ((Input) -> Output)>
    ) -> Bool

    /**
     Checks if the specified route is active, i.e. is the one currently showing.

     - Parameter route: The route to check.
     - Parameter input: The input to consider.  If input conforms to `Equatable`, there is no need to add a comparator unless you need it.
     */
    func isActive<Input: Equatable, Output: Coordinatable>(
        _ route: KeyPath<Self, ((Self) -> ((Input) -> Output))>,
        _ input: Input
    ) -> Bool
    
    /**
     Checks if the specified route is active, i.e. is the one currently showing.

     - Parameter route: The route to check.
     - Parameter input: The input to consider. If input conforms to `Equatable`, there is no need to add a comparator unless you need it.
     */
    func isActive<Input: Equatable, Output: View>(
        _ route: KeyPath<Self, (Self) -> ((Input) -> Output)>,
        _ input: Input
    ) -> Bool
    
    /**
     Checks if the specified route is active, i.e. is the one currently showing.

     - Parameter route: The route to check.
     - Parameter input: The input to consider.  If input conforms to `Equatable`, there is no need to add a comparator unless you need it.
     - Parameter comparator: The function to use to determine if the inputs are equal
     */
    func isActive<Input: Equatable, Output: Coordinatable>(
        _ route: KeyPath<Self, ((Self) -> ((Input) -> Output))>,
        _ input: Input,
        comparator: @escaping (Input, Input) -> Bool
    ) -> Bool
    
    /**
     Checks if the specified route is active, i.e. is the one currently showing.

     - Parameter route: The route to check.
     - Parameter input: The input to consider. If input conforms to `Equatable`, there is no need to add a comparator unless you need it.
     - Parameter comparator: The function to use to determine if the inputs are equal
     */
    func isActive<Input: Equatable, Output: View>(
        _ route: KeyPath<Self, (Self) -> ((Input) -> Output)>,
        _ input: Input,
        comparator: @escaping (Input, Input) -> Bool
    ) -> Bool
}

public extension ViewCoordinatable {
    func customize(_ view: AnyView) -> some View {
        return view
    }

    func view() -> AnyView {
        return AnyView(
            ViewCoordinatableView(
                coordinator: self,
                customize: customize
            )
        )
    }
    
    @discardableResult func reset() -> Self {
        guard child.item != nil else {
            return self
        }
        
        child.item = nil
        return self
    }
    
    @discardableResult func route<Output: Coordinatable>(
        to route: KeyPath<Self, ((Self) -> ((Void) -> Output))>
    ) -> Output {
        if child.item?.keyPath == route.hashValue {
            return child.item?.child as! Output
        }
        
        let output = self[keyPath: route](self)(())
        
        self.child.item = ViewChildItem(
            keyPath: route.hashValue,
            input: nil,
            child: output
        )
        
        return output
    }
    
    @discardableResult func route<Input, Output: Coordinatable>(
        to route: KeyPath<Self, (Self) -> ((Input) -> Output)>,
        _ input: Input,
        comparator: @escaping (Input, Input) -> Bool
    ) -> Output {
        if child.item?.keyPath == route.hashValue {
            guard let inputItem = child.item?.input else {
                fatalError()
            }
            
            if comparator(inputItem as! Input, input) {
                return child.item?.child as! Output
            }
        }
        
        let output = self[keyPath: route](self)(input)
        
        self.child.item = ViewChildItem(
            keyPath: route.hashValue,
            input: input,
            child: output
        )
        
        return output
    }
    
    @discardableResult func route<Input: Equatable, Output: Coordinatable>(
        to route: KeyPath<Self, (Self) -> ((Input) -> Output)>,
        _ input: Input
    ) -> Output {
        self.route(to: route, input, comparator: { $0 == $1 })
    }
    
    @discardableResult func route<Output: View>(
        to route: KeyPath<Self, ((Self) -> ((Void) -> Output))>
    ) -> Output {
        if child.item?.keyPath == route.hashValue {
            return child.item?.child as! Output
        }
        
        let output = self[keyPath: route](self)(())
        
        self.child.item = ViewChildItem(
            keyPath: route.hashValue,
            input: nil,
            child: AnyView(output)
        )
        
        return output
    }
    
    @discardableResult func route<Input, Output: View>(
        to route: KeyPath<Self, ((Self) -> ((Input) -> Output))>,
        _ input: Input,
        comparator: @escaping (Input, Input) -> Bool
    ) -> Output {
        if child.item?.keyPath == route.hashValue {
            guard let inputItem = child.item?.input else {
                fatalError()
            }
            
            if comparator(inputItem as! Input, input) {
                return child.item?.child as! Output
            }
        }
        
        let output = self[keyPath: route](self)(input)
        
        self.child.item = ViewChildItem(
            keyPath: route.hashValue,
            input: input,
            child: AnyView(output)
        )
        
        return output
    }
    
    @discardableResult func route<Input: Equatable, Output: View>(
        to route: KeyPath<Self, ((Self) -> ((Input) -> Output))>,
        _ input: Input
    ) -> Output {
        self.route(to: route, input, comparator: { $0 == $1 })
    }
    
    func isStart() -> Bool {
        return child.item == nil
    }
    
    private func _isActive<Input, Output: Coordinatable>(
        _ route: KeyPath<Self, (Self) -> ((Input) -> Output)>,
        inputItem: (input: Input, comparator: (Input, Input) -> Bool)?
    ) -> Bool {
        guard child.item?.keyPath == route.hashValue else {
            return false
        }
        
        guard let inputItem = inputItem else {
            return true
        }

        guard let compareTo = child.item?.input else {
            fatalError()
        }

        return inputItem.comparator(compareTo as! Input, inputItem.input)
    }
    
    private func _isActive<Input, Output: View>(
        _ route: KeyPath<Self, (Self) -> ((Input) -> Output)>,
        inputItem: (input: Input, comparator: (Input, Input) -> Bool)?
    ) -> Bool {
        guard child.item?.keyPath == route.hashValue else {
            return false
        }
        
        guard let inputItem = inputItem else {
            return true
        }

        guard let compareTo = child.item?.input else {
            fatalError()
        }

        return inputItem.comparator(compareTo as! Input, inputItem.input)
    }
    
    /**
     Checks if the specified route is active, i.e. is the one currently showing.

     - Parameter route: The route to check.
     */
    func isActive<Output: Coordinatable>(
        _ route: KeyPath<Self, ((Self) -> ((Void) -> Output))>
    ) -> Bool {
        return self._isActive(route, inputItem: nil)
    }
    
    /**
     Checks if the specified route is active, i.e. is the one currently showing.

     - Parameter route: The route to check.
     */
    func isActive<Output: View>(
        _ route: KeyPath<Self, (Self) -> ((Void) -> Output)>
    ) -> Bool {
        return self._isActive(route, inputItem: nil)
    }
    
    /**
     Checks if the specified route is active, i.e. is the one currently showing.

     - Parameter route: The route to check.
     */
    func isActive<Input, Output: Coordinatable>(
        _ route: KeyPath<Self, ((Self) -> ((Input) -> Output))>
    ) -> Bool {
        return self._isActive(route, inputItem: nil)
    }
    
    /**
     Checks if the specified route is active, i.e. is the one currently showing.

     - Parameter route: The route to check.
     */
    func isActive<Input, Output: View>(
        _ route: KeyPath<Self, (Self) -> ((Input) -> Output)>
    ) -> Bool {
        return self._isActive(route, inputItem: nil)
    }

    /**
     Checks if the specified route is active, i.e. is the one currently showing.

     - Parameter route: The route to check.
     - Parameter input: The input to consider.  If input conforms to `Equatable`, there is no need to add a comparator unless you need it.

     */
    func isActive<Input: Equatable, Output: Coordinatable>(
        _ route: KeyPath<Self, ((Self) -> ((Input) -> Output))>,
        _ input: Input
    ) -> Bool {
        return self._isActive(route, inputItem: (input: input, comparator: { $0 == $1 }))
    }
    
    /**
     Checks if the specified route is active, i.e. is the one currently showing.

     - Parameter route: The route to check.
     - Parameter input: The input to consider. If input conforms to `Equatable`, there is no need to add a comparator unless you need it.
     */
    func isActive<Input: Equatable, Output: View>(
        _ route: KeyPath<Self, (Self) -> ((Input) -> Output)>,
        _ input: Input
    ) -> Bool {
        return self._isActive(route, inputItem: (input: input, comparator: { $0 == $1 }))
    }
    
    /**
     Checks if the specified route is active, i.e. is the one currently showing.

     - Parameter route: The route to check.
     - Parameter input: The input to consider.  If input conforms to `Equatable`, there is no need to add a comparator unless you need it.
     - Parameter comparator: The function to use to determine if the inputs are equal
     */
    func isActive<Input: Equatable, Output: Coordinatable>(
        _ route: KeyPath<Self, ((Self) -> ((Input) -> Output))>,
        _ input: Input,
        comparator: @escaping (Input, Input) -> Bool
    ) -> Bool {
        return self._isActive(route, inputItem: (input: input, comparator: comparator))
    }
    
    /**
     Checks if the specified route is active, i.e. is the one currently showing.

     - Parameter route: The route to check.
     - Parameter input: The input to consider. If input conforms to `Equatable`, there is no need to add a comparator unless you need it.
     - Parameter comparator: The function to use to determine if the inputs are equal
     */
    func isActive<Input: Equatable, Output: View>(
        _ route: KeyPath<Self, (Self) -> ((Input) -> Output)>,
        _ input: Input,
        comparator: @escaping (Input, Input) -> Bool
    ) -> Bool {
        return self._isActive(route, inputItem: (input: input, comparator: comparator))
    }
}
