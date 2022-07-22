import CacheStore
import CoreLocation

/// `LocationStore` Keys
///     - location: CLLocation
public enum LocationStoreKey {
    case location // CLLocation
}

/// `LocationStore` Actions
public enum LocationStoreAction {
    case updateLocation
    case locationUpdated(CLLocation?)
}

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

public extension LocationStoreDependency {
    /// Mock Dependency
    static func mock(location: CLLocation) -> LocationStoreDependency {
        LocationStoreDependency(
            updateLocation: { location }
        )
    }
    
    /// Live Dependency using CLLocationManager and requestWhenInUseAuthorization if authorizationStatus == .notDetermined
    static var live: LocationStoreDependency {
        LocationStoreDependency(
            updateLocation: {
                let locationManager = CLLocationManager()
                
                if locationManager.authorizationStatus == .notDetermined {
                    locationManager.requestWhenInUseAuthorization()
                }
                
                return locationManager.location
            }
        )
    }
}

/// Higher-order StoreActionHandler
public func locationStoreActionHandler(
    withActionHandler actionHandler: StoreActionHandler<LocationStoreKey, LocationStoreAction, LocationStoreDependency>? = nil
) -> StoreActionHandler<LocationStoreKey, LocationStoreAction, LocationStoreDependency> {
    StoreActionHandler<LocationStoreKey, LocationStoreAction, LocationStoreDependency> { cacheStore, action, dependency in
        switch action {
        case .updateLocation:
            struct UpdateLocationActionEffectID: Hashable { }
            
            return ActionEffect(id: UpdateLocationActionEffectID()) {
                .locationUpdated(await dependency.updateLocation())
            }
            
        case let .locationUpdated(location):
            cacheStore.set(value: location, forKey: .location)
        }
        
        guard
            let actionHandler = actionHandler,
            let nextAction = actionHandler.handle(store: &cacheStore, action: action, dependency: dependency)
        else {
            struct RepeatUpdateLocationActionEffectID: Hashable { }
            
            if dependency.shouldContinuouslyUpdate {
                return ActionEffect(id: RepeatUpdateLocationActionEffectID()) {
                    sleep(1)
                    return .updateLocation
                }
            }
            
            return .none
        }
        
        return nextAction
    }
}

public typealias LocationStore = Store<LocationStoreKey, LocationStoreAction, LocationStoreDependency>

/// LocationStore that updates the user's location
public class DefaultLocationStore: LocationStore {
    /// Create a LocationStore with an ActionHandler and Dependency
    public init(
        withActionHandler actionHandler: StoreActionHandler<LocationStoreKey, LocationStoreAction, LocationStoreDependency>? = nil,
        dependency: LocationStoreDependency = .live
    ) {
        super.init(
            initialValues: [:],
            actionHandler: locationStoreActionHandler(withActionHandler: actionHandler),
            dependency: dependency
        )
        
        handle(action: .updateLocation)
    }
    
    /// Create a LocationStore using the Store init
    public required init(
        initialValues: [LocationStoreKey: Any],
        actionHandler: StoreActionHandler<LocationStoreKey, LocationStoreAction, LocationStoreDependency>,
        dependency: LocationStoreDependency
    ) {
        super.init(
            initialValues: initialValues,
            actionHandler: locationStoreActionHandler(withActionHandler: actionHandler),
            dependency: dependency
        )
        
        handle(action: .updateLocation)
    }
}
