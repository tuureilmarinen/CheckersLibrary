import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(CheckersLibraryTests.allTests),
        testCase(CheckersUtilsTests.allTests),
        testCase(GameStateTestsTests),
        testCase(CheckersMinMaxPlayerTests)
    ]
}
#endif
