# LocationCacheStore

*CoreLocation State Store*

## What is [`CacheStore`](https://github.com/0xOpenBytes/CacheStore)?

`CacheStore` is a SwiftUI state management framework that uses a dictionary as the state. Scoping creates a single source of truth for the parent state. `CacheStore` uses [`c`](https://github.com/0xOpenBytes/c), which a simple composition framework. [`c`](https://github.com/0xOpenBytes/c) has the ability to create transformations that are either unidirectional or bidirectional.

## LocationStore
```swift
public typealias LocationStore = Store<LocationStoreKey, LocationStoreAction, LocationStoreDependency>
```

## Keys
```swift
/// `LocationStore` Keys
///     - location: CLLocation
public enum LocationStoreKey {
    case location // CLLocation
}
```

## Actions
```swift
/// `LocationStore` Actions
public enum LocationStoreAction {
    case updateLocation
    case locationUpdated(CLLocation?)
}
```

## Dependency
```swift
/// `LocationStore` Dependency
public struct LocationStoreDependency {
    public var shouldContinuouslyUpdate: Bool
    public var updateLocation: () async -> CLLocation?
    
    public init(
        shouldContinuouslyUpdate: Bool = true,
        updateLocation: @escaping () async -> CLLocation?
    ) {
        self.shouldContinuouslyUpdate = shouldContinuouslyUpdate
        self.updateLocation = updateLocation
    }
}
```

## StoreActionHandler
```swift
/// Higher-order StoreActionHandler
public func locationStoreActionHandler(
    withActionHandler actionHandler: StoreActionHandler<LocationStoreKey, LocationStoreAction, LocationStoreDependency>? = nil
) -> StoreActionHandler<LocationStoreKey, LocationStoreAction, LocationStoreDependency>
```

## DefaultLocationStore
```swift
public class DefaultLocationStore: LocationStore
```
