import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(CheckersLibraryTests.allTests),
        testCase(CheckersUtilsTests.allTests),
        testCase(GameStateTestsTests.allTests),
        testCase(CheckersMinMaxPlayerTests.allTests),
        testCase(PortableDraughtsNotationTests.allTests)
    ]
}
#endif
