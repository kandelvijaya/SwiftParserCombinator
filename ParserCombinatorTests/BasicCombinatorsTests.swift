//
//  BasicCombinatorsTests.swift
//  ParserCombinatorTests
//
//  Created by Vijaya Prakash Kandel on 4/1/18.
//  Copyright © 2018 Vijaya Prakash Kandel. All rights reserved.
//

import Foundation
import XCTest
@testable import ParserCombinator

final class BasicCombinatorsTests: XCTestCase {
    
    private var c1: Character!
    private var c2: Character!
    private var c3: Character!
    private var pc1: Parser<Character>!
    private var pc2: Parser<Character>!
    private var pc3: Parser<Int>!
    
    override func setUp() {
        super.setUp()
        c1 = Character.random
        c2 = Character.random
        c3 = Character("3")
        pc1 = pchar(c1)
        pc2 = pchar(c2)
        pc3 = pdigit
    }
    
    // MARK:- andThen
    
    func test_whenAndThenIsCalledAndThereIsNoError_thenOutputAreTupled() {
        let stringToParse = String([c1, c2])
        let output = pc1.andThen(pc2)
            |> ParserCombinator.run(stringToParse)
        let value = output.value()
        assertHasValue(output)
        XCTAssertEqual([value!.0.0, value!.0.1], [c1, c2])
    }
    
    func test_whenAndThenIsCalledAndThereIsErrorOnFirst_thenSameErrorIsPropagated() {
        let stringToParse = String([c1, c2])
        let output = pc2.andThen(pc2)
            |> ParserCombinator.run(stringToParse)
        assertHasError(output)
        XCTAssertEqual(output.error()!.position, ParserErrorPosition(currentLine: stringToParse, row: 0, col: 1))
    }
    
    func test_whenAndThenIsCalledAndThereIsErrorOnSecond_thenSameErrorIsPropagated() {
        let stringToParse = String([c1, c2])
        let output = pc1.andThen(pc1)
            |> ParserCombinator.run(stringToParse)
        assertHasError(output)
        XCTAssertEqual(output.error()!.position, ParserErrorPosition(currentLine: stringToParse, row: 0, col: 2))

    }
    
    func test_whenAndThenIsCalledWithBothParsersErroring_thenOnlyFirstParserIsExecuted() {
        let stringToParse = String([c1, c2])
        let output = pc2.andThen(pc1)
            |> ParserCombinator.run(stringToParse)
        assertHasError(output)
        XCTAssertEqual(output.error()!.position, ParserErrorPosition(currentLine: stringToParse, row: 0, col: 1))
    }
    
    func test_whenAndThenIsCalledWithDifferentParsers_itWorks() {
        let input = String([c3,c1,c2])
        let parsed = pc3 ->>- pc1 |> ParserCombinator.run(input)
        assertHasValue(parsed)
        XCTAssertEqual(parsed.value()!.0.0, Int(String(c3))!)
    }
    
    
    //MARK:- orElse
    
    func test_whenOrElseIsCalledAndBothParserAreGood_thenFirstOneIsExecuted() {
        let input = String([c1, c2])
        let parsed = pc1.orElse(pc2)
            |> ParserCombinator.run(input)
        assertHasValue(parsed)
        XCTAssertEqual(parsed.value()!.0, c1)
    }
    
    func test_whenOrElseIsCalledAndOnlyFirstParserSucceeds_thenFirstOneIsUsed() {
        let input = String([c1, c2])
        let parsed = pc1.orElse(pc1)
            |> ParserCombinator.run(input)
        assertHasValue(parsed)
        XCTAssertEqual(parsed.value()!.0, c1)
    }
    
    func test_whenOrEleseIsCalledAndOnlySecondParserSucceeds_thenSecondOneIsUsed() {
        let input = String([c1, c2])
        let parsed = pc2.orElse(pc1)
            |> ParserCombinator.run(input)
        assertHasValue(parsed)
        XCTAssertEqual(parsed.value()!.0, c1)
    }
    
    func test_whenOrElseIsCalledAndBothParsersFails_thenSecondFailureIsReported() {
        let input = String([c1, c2])
        let parsed = pc2.orElse(pc2)
            |> ParserCombinator.run(input)
        assertHasError(parsed)
        XCTAssertEqual(parsed.error()!.position, ParserErrorPosition(currentLine: input, row: 0, col: 1))
    }
    
    func test_OrElseCannotBeInvokedWithDifferentlyTypedParser() { }
    
    //MARK:- Keep Left
    func test_whenKeepLeftIsCalled_thenInputIsParsedButResultOfLeftIsOnlyKept() {
        let input = String([c1,c2])
        let parsed = pc1.keepLeft(pc2) |> ParserCombinator.run(input)
        assertHasValue(parsed)
        XCTAssertEqual(parsed.value()?.0, c1)
        XCTAssertEqual(parsed.value()!.1.position, ParserPosition(row: 0, col: 2))
    }
    
    func test_whenKeepLeftIsCalledAndEither1ParserFails_itReportsError() {
        let input = String([c2,c1])
        // ->> is KeepLeft operator
        let parsed = pc1 ->> pc2 |> ParserCombinator.run(input)
        assertHasError(parsed)
    }
    
    // MARK:- Kepp Right
    func test_whenKeepRightIsCalled_thenInputIsParsedButResultOfRightIsOnlyKept() {
        let input = String([c1,c2])
        let parsed = pc1.keepRight(pc2) |> ParserCombinator.run(input)
        assertHasValue(parsed)
        XCTAssertEqual(parsed.value()?.0, c2)
        XCTAssertEqual(parsed.value()!.1.position, ParserPosition(row: 0, col: 2))
    }
    
    func test_whenKeepRightIsCalledAndEither1ParserFails_itReportsError() {
        let input = String([c2,c1])
        // >>- is KeepLeft operator
        let parsed = pc1 >>- pc2 |> ParserCombinator.run(input)
        assertHasError(parsed)
    }
    
    
    // MARK:- parse Zero Or More
    func test_whenParseZeroOrMoreIsCalled_thenItParsesUntilItFailsEagerly() {
        let input = String([c1,c1,c1,c3])
        let parsed = pc1.parseZeroOrMore(InputState(from: input))
        XCTAssertEqual(parsed.0, [c1,c1,c1])
        XCTAssertEqual(parsed.1.position, ParserPosition(row: 0, col: 3))
    }
    
    func test_whenParsesZeroOrMoreIsCalledAndNoMatchIsFound_thenItReturnsEmptyArray() {
        let input = String([c3,c3,c3])
        let parsed = pc1.parseZeroOrMore(InputState(from: input))
        XCTAssertEqual(parsed.0, [])
        XCTAssertEqual(parsed.1.position, ParserPosition(row: 0, col: 0))
    }
    
    // MARK:- many
    
    func test_whenManyIsCalled_thenItAccumulatesMatchesEagerly() {
        let input = "hellohello there"
        let phello = pstring("hello")
        let parsed = many(phello) |> ParserCombinator.run(input)
        assertHasValue(parsed)
        XCTAssertEqual(parsed.value()!.0, ["hello", "hello"])
    }
    
    func test_whenManyIsCalledAndThereAreNoMatches_thenItReturnsEmptyArray() {
        let input = "hellohelloThere"
        let pThere = pstring("There")
        let parsed = pThere |> many |> ParserCombinator.run(input)
        assertHasValue(parsed)
        XCTAssertEqual(parsed.value()!.0, [])
    }
    
    // MARK:- choice
    func test_whenInputMatchesFromListOfSameTypedParsers_thenMatchingParserIsUsedAndOnlyMatchedParserConsumesTheInput() {
        let input = "hello"
        let pc = pchar("c")
        let pe = pchar("e")
        let ph = pchar("h")
        let parsed = choice([pc, pe, ph]) |> ParserCombinator.run(input)
        assertHasValue(parsed)
        XCTAssertEqual(parsed.value()!.0, "h")
        XCTAssertEqual(parsed.value()!.1.position, ParserPosition(row: 0, col: 1))
    }
    
    func test_whenInputDoesnotMatchListOfChoiceParser_thenParsedIsError() {
        let input = "hello there"
        let papple = pstring("apple")
        let pball = pstring("ball")
        
        let parsed = [papple, pball] |> choice |> ParserCombinator.run(input)
        assertHasError(parsed)
        
        XCTAssertEqual(parsed.error()!.position, ParserErrorPosition(currentLine: input, row: 0, col: 1))
    }
    
    // MARK:- many1
    
    func test_whenParserMatchesNoneForMany1_thenItErrors() {
        let input = "hello there"
        let pa = pchar("a")
        let parsed = pa |> many1 |> ParserCombinator.run(input)
        assertHasError(parsed)
    }
    
    func test_whenParserMatches1ForMany1_thenResultArrayHas1Item() {
        let input = "hello there"
        let pa = pchar("h")
        let parsed = pa |> many1 |> ParserCombinator.run(input)
        assertHasValue(parsed)
        let output = parsed.value()!.0
        XCTAssertEqual(output.count, 1)
        XCTAssertEqual(output.first!, "h")
    }
    
    func test_whenParserMatchesMoreThan1ForMany1_thenParsedOutputIsArray() {
        let input = "aallo"
        let pa = pchar("a")
        let parsed = pa |> many1 |> ParserCombinator.run(input)
        assertHasValue(parsed)
        let output = parsed.value()!.0
        XCTAssertEqual(output.count, 2)
        XCTAssertEqual(output, ["a", "a"])
    }
    
    // MARK:- Optional match
    // TODO
    
    // MARK:- separated1
    func test_whenSeparatedBy1IsUsedToMatchWhereNothingMatches_thenItReportsError() {
        let input = "b-b-b-b"
        let pa = pchar("a")
        let comma = pchar(",")
        let parser = separated1(pa, by: comma)
        let parsed = parser |> ParserCombinator.run(input)
        assertHasError(parsed)
    }
    
    func test_whenSeparatedBy1IsUsedToMatchWhereManyItemsMtches_thenItReportsResultInarray() {
        let input = "a,a,b"
        let pa = pchar("a")
        let comma = pchar(",")
        let parser = separated1(pa, by: comma)
        let parsed = parser |> ParserCombinator.run(input)
        assertHasValue(parsed)
        XCTAssertEqual(parsed.value()?.0, ["a","a"])
    }
    
    func test_whenSeparatedBy1IsUsedAndItMatchesParserButNotSeparator_thenParsedContainsJustTheMatchedParser() {
        let input = "a-a-b"
        let pa = pchar("a")
        let comma = pchar(",")
        let parser = separated1(pa, by: comma)
        let parsed = parser |> ParserCombinator.run(input)
        assertHasValue(parsed)
        XCTAssertEqual(parsed.value()?.0, ["a"])
    }
    
    // MARK:- Separated
    
    func test_whenSeparatedByIsUsedToMatchWhereNothingMatches_thenItReportsEmptyArray() {
        let input = "b,b,b"
        let pa = pchar("a")
        let comma = pchar("-")
        let parser = separated(pa, by: comma)
        let parsed = parser |> ParserCombinator.run(input)
        assertHasValue(parsed)
        XCTAssertEqual(parsed.value()!.0, [])
    }
    
    func test_whenSeparatedByMatchesMultipleInstances_thenItReportsResultInArry() {
        let input = "a-a-a-b"
        let pa = pchar("a")
        let comma = pchar("-")
        let parser = separated(pa, by: comma)
        let parsed = parser |> ParserCombinator.run(input)
        assertHasValue(parsed)
        XCTAssertEqual(parsed.value()!.0, ["a", "a", "a"])
    }
    
}
