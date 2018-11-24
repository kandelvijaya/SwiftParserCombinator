//
//  Copyright © 2018 Vijaya Prakash Kandel. All rights reserved.
//

import XCTest
@testable import ParserCombinator

final class ParserSTLIBTests: XCTestCase {
    
    func test_whenStringHasDigits_thenItCanBeParsedWithPDigit() {
        assert(parser: pdigit, input: "1Hello", has: 1)
    }
    
    func test_whenStringHasNoDigits_thenItCannotBeParsedWithPDigit() {
        assertError(parser: pdigit, input: "hellothere")
    }
    
    func test_whenStringHasInteger_thenItCanBeParsedWithPInt() {
        assert(parser: pint, input: "12345 hello", has: 12345)
    }
    
    func test_whenStringHasDouble_thenItCannotBeParsedWithPInt() {
        assert(parser: pint, input: "123.34 hello there", has: 123)
    }
    
    func test_whenStringHasNegativeInteger_thenItCanBeParsedWithPInt() {
        assert(parser: pint, input: "-77.65 Euro", has: -77)
    }
    
    func test_whenStringHasDouble_thenPDoubleCanParserIt() {
        assert(parser: pfloat, input: "123.45 apple", has: 123.45)
    }
    
    func test_whenStringHasNegatedDouble_thenPDoubleCanParseIt() {
        assert(parser: pfloat, input: "-77.67 Euros", has: -77.67)
    }
    
    func test_whenStringHasMatchingSubString_thenPStringCanMatchThat() {
        assert(parser: pstring("hello"), input: "hello there", has: "hello")
    }
    
    func test_whenStringHasNoMatchingSubString_thenPStringCannotMatch() {
        let parser = pstring("hello")
        let input = "nothing! hello there"
        assertError(parser: parser, input: input, at: ParserErrorPosition(currentLine: input, row: 0, col: 1), with: parser.label)
    }
    
    func test_whenStringWithQuotedSubStringExists_thenPQuotedStringCanMatchIt() {
        assert(parser: pquotedString("hello"), input: "\"hello\", says Mike.", has: "hello")
    }
    
}
