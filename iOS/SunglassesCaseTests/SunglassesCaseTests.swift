import XCTest
@testable import SunglassesCase

@MainActor
final class SunglassesCaseTests: XCTestCase {
    var store: Store!

    override func setUp() {
        super.setUp()
        store = Store()
    }

    func testSeedDataLoadsBelowFreeLimit() {
        XCTAssertLessThan(store.items.count, Store.freeTierLimit)
    }

    func testAddIncreasesCount() {
        let before = store.items.count
        store.add(PairItem(name: "Test", brand: "A", caseLocation: "B"))
        XCTAssertEqual(store.items.count, before + 1)
    }

    func testDeleteRemovesItem() {
        let item = PairItem(name: "ToDelete", brand: "A", caseLocation: "B")
        store.add(item)
        store.delete(item)
        XCTAssertFalse(store.items.contains(item))
    }

    func testIsAtFreeLimitFalseInitially() {
        XCTAssertFalse(store.isAtFreeLimit)
    }

    func testIsAtFreeLimitTrueAfterFilling() {
        while store.items.count < Store.freeTierLimit {
            store.add(PairItem(name: "Filler \(store.items.count)", brand: "A", caseLocation: "B"))
        }
        XCTAssertTrue(store.isAtFreeLimit)
    }

    func testUpdateChangesFields() {
        var item = PairItem(name: "Orig", brand: "A", caseLocation: "B")
        store.add(item)
        item.name = "Changed"
        store.update(item)
        XCTAssertEqual(store.items.first(where: { $0.id == item.id })?.name, "Changed")
    }

    func testDeleteAtOffsets() {
        let before = store.items.count
        store.delete(at: IndexSet(integer: 0))
        XCTAssertEqual(store.items.count, before - 1)
    }

    func testPersistenceRoundTrip() {
        store.add(PairItem(name: "Persisted", brand: "A", caseLocation: "B"))
        let reloaded = Store()
        XCTAssertTrue(reloaded.items.contains(where: { $0.name == "Persisted" }))
    }
}
