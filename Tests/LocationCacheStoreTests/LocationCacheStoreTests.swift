import CacheStore
import CoreLocation
import t
import XCTest
@testable import LocationCacheStore

final class LocationCacheStoreTests: XCTestCase {
    func testExample() throws {
        let initLocation = CLLocation()
        
        let locationStore = LocationStore(
            initialValues: [:],
            actionHandler: locationStoreActionHandler(),
            dependency: .mock(location: initLocation)
        )
        
        enum ExampleKey {
            case location
        }
        
        struct ExampleStoreContent: StoreContent {
            var store: Store<ExampleKey, Void, Void>
            
            var location: CLLocation {
                store.resolve(.location)
            }
        }
        
        var exampleStore: TestStore<ExampleKey, Void, Void> {
            TestStore(
                store: locationStore.actionlessScope(
                    keyTransformation: (
                        from: { parent in
                            switch parent {
                            case .location: return .location
                            default: return nil
                            }
                        },
                        to: { child in
                            switch child {
                            case .location: return .location
                            default: return nil
                            }
                        }
                    ),
                    dependencyTransformation: { _ in () }
                )
            )
        }
        
        // MARK: - Test
        exampleStore.content { (content: ExampleStoreContent) in
            try t.assert(content.location.coordinate.latitude, isEqualTo: initLocation.coordinate.latitude)
            try t.assert(content.location.coordinate.latitude, isEqualTo: initLocation.coordinate.latitude)
        }
        
        let newLocation = CLLocation(latitude: 1, longitude: 1)
        locationStore.handle(action: .locationUpdated(newLocation))
        
        exampleStore.content { (content: ExampleStoreContent) in
            try t.assert(content.location.coordinate.latitude, isEqualTo: newLocation.coordinate.latitude)
            try t.assert(content.location.coordinate.latitude, isEqualTo: newLocation.coordinate.latitude)
        }
    }
}
