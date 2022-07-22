import CacheStore
import CoreLocation
import t
import XCTest
@testable import LocationCacheStore

final class LocationCacheStoreTests: XCTestCase {
    func testExample() throws {
        let initLocation = CLLocation()
        
        let store = TestStore(
            store: LocationStore(
                initialValues: [:],
                actionHandler: locationStoreActionHandler(),
                dependency: LocationStoreDependency(
                    shouldContinuouslyUpdate: false,
                    updateLocation: { initLocation }
                )
            )
        )
        
        store.send(.updateLocation, expecting: { _ in })
        
        store.receive(.locationUpdated(initLocation)) { cacheStore in
            cacheStore.set(value: initLocation, forKey: .location)
        }
        
        let newLocation = CLLocation(latitude: 1, longitude: 1)
        
        store.send(.locationUpdated(newLocation)) { cacheStore in
            cacheStore.set(value: newLocation, forKey: .location)
        }
    }
}
