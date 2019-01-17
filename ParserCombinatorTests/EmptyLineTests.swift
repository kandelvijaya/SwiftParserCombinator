//
//  EmptyLineTests.swift
//  ParserCombinatorTests
//
//  Created by Vijaya Prakash Kandel on 17.01.19.
//  Copyright © 2019 Vijaya Prakash Kandel. All rights reserved.
//

import Foundation
import XCTest
@testable import ParserCombinator

class EmptyLinesTest: XCTestCase {

    func test_when2emptyLinesAreParsed_theInputStateHas2Lines() {
        let rinput = "\n\n"
        let input = InputState(from: rinput)
        XCTAssertEqual(input.lines.count, 2)
    }

    func test_when1EmptyLineAndLeadingNotEmptyLineIsPresent_thenInputStateIsCorrect() {
        let input = InputState(from: "\n\nhello")
        XCTAssertEqual(input.lines.count, 3)
    }

    func test_whenParserCanBeUsedToParseLines() {
        let all = satisfy({ _ in true }, label: "all")
        let p = all |> many
        let r = p |> ParserCombinator.run("\n\n")
        XCTAssertEqual(r.value()!.0, [Character(""),Character("")])
    }

    func test_whenParserCanBeUsedToParseLines2(){
        let input = "hello\n\n\nthere"
        let expected = ["hello", "", "", "there"]
        let newLine = satisfy({ $0 == "\n"}, label: "newLine")
        let contentFulLine = (satisfy({ $0 != "\n"}, label: "all") |> many) ->> newLine
        let lines = contentFulLine |>> {
            return $0.isEmpty ? "" : String($0)
        }
        let plines = lines |> many
        let out = plines |> ParserCombinator.run(input)
        let output = out.value()!.0
        XCTAssertEqual(output, expected)
    }

}
