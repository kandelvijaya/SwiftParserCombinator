//
//  Copyright © 2018 Vijaya Prakash Kandel. All rights reserved.
//

import XCTest
@testable import ParserCombinator

final class LabelSetterTests: XCTestCase {
    
    func test_whenSetLabelIsUsed_thenParserHasLabel() {
        let parser = pchar(Character.random)
        let label = String.random
        let labelledParser = setLabel(parser, label)
        XCTAssertEqual(labelledParser.label, label)
    }
    
    func test_whenSetLabelInfixOperatorIsUsed_thenLabelIsSet() {
        let parser = pchar(Character.random)
        let label = String.random
        let labelledParser = parser <?> label
        XCTAssertEqual(labelledParser.label, label)
    }
    
}
