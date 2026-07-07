import XCTest
@testable import Cashjar

@MainActor
final class CashjarTests: XCTestCase {
    func testStoreSeedsBelowFreeLimit() {
        let store = Store()
        XCTAssertLessThan(store.items.count, Store.freeLimit)
    }

    func testAddIncreasesCount() {
        let store = Store()
        let before = store.items.count
        let added = store.add(Jar())
        XCTAssertTrue(added)
        XCTAssertEqual(store.items.count, before + 1)
    }

    func testAddRespectsFreeLimit() {
        let store = Store()
        while store.items.count < Store.freeLimit {
            _ = store.add(Jar())
        }
        let added = store.add(Jar())
        XCTAssertFalse(added)
        XCTAssertEqual(store.items.count, Store.freeLimit)
    }

    func testProBypassesFreeLimit() {
        let store = Store()
        store.isPro = true
        while store.items.count < Store.freeLimit {
            _ = store.add(Jar())
        }
        let added = store.add(Jar())
        XCTAssertTrue(added)
    }

    func testDeleteRemovesItem() {
        let store = Store()
        let item = Jar()
        _ = store.add(item)
        store.delete(item)
        XCTAssertFalse(store.items.contains(item))
    }

    func testDeleteAtOffsetsRemovesItem() {
        let store = Store()
        let before = store.items.count
        store.delete(at: IndexSet(integer: 0))
        XCTAssertEqual(store.items.count, before - 1)
    }

    func testIsAtFreeLimitReflectsState() {
        let store = Store()
        XCTAssertFalse(store.isAtFreeLimit)
        while store.items.count < Store.freeLimit {
            _ = store.add(Jar())
        }
        XCTAssertTrue(store.isAtFreeLimit)
    }
}
