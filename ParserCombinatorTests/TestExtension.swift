//
//  Copyright © 2018 Vijaya Prakash Kandel. All rights reserved.
//

import XCTest
@testable import ParserCombinator

func assertHasValue<T>(_ parsed: ParserResult<T>) {
    XCTAssertNotNil(parsed.value())
    XCTAssertNil(parsed.error())
}

func assertHasError<T>(_ parsed: ParserResult<T>) {
    XCTAssertNil(parsed.value())
    XCTAssertNotNil(parsed.error())
}

func assert<T>(parser: Parser<T>, input: String, has value: T? = nil) where T: Equatable {
    let run = parser |> ParserCombinator.run(input)
    XCTAssertNotNil(run.value())
    XCTAssertNil(run.error())
    if let eventualValue = value {
        XCTAssertEqual(run.value()!.0, eventualValue)
    }
}

func assertError<T>(parser: Parser<T>, input: String, at position: ParserErrorPosition? = nil, with label: String? = nil) {
    let run = parser |> ParserCombinator.run(input)
    XCTAssertNil(run.value())
    XCTAssertNotNil(run.error())
    
    if let expectedCursorPosition = position {
        XCTAssertEqual(run.error()!.position, expectedCursorPosition)
    }
    
    if let expectedLabel = label {
        XCTAssertEqual(run.error()!.label, expectedLabel)
    }
}
