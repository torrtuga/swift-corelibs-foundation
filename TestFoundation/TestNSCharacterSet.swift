  // This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//



#if DEPLOYMENT_RUNTIME_OBJC || os(Linux)
import Foundation
import XCTest
#else
import SwiftFoundation
import SwiftXCTest
#endif



class TestNSCharacterSet : XCTestCase {
    
    static var allTests: [(String, (TestNSCharacterSet) -> () throws -> Void)] {
        return [
            ("testBasicConstruction", testBasicConstruction),
            ("testMutability_copyOnWrite", testMutability_copyOnWrite),
            ("testRanges", testRanges),
            ("testInsertAndRemove", testInsertAndRemove),
            ("testBasics", testBasics),
            ("testClosedRanges_SR_2988", testClosedRanges_SR_2988),
            ("test_Predefines", test_Predefines),
            ("test_Range", test_Range),
            ("test_String", test_String),
            ("test_Bitmap", test_Bitmap),
            ("test_AnnexPlanes", test_AnnexPlanes),
            ("test_Planes", test_Planes),
            ("test_InlineBuffer", test_InlineBuffer),
        ]
    }
    
    let capitalA = UnicodeScalar(0x0041)! // LATIN CAPITAL LETTER A
    let capitalB = UnicodeScalar(0x0042)! // LATIN CAPITAL LETTER B
    let capitalC = UnicodeScalar(0x0043)! // LATIN CAPITAL LETTER C
    
    func testBasicConstruction() {
        // Create a character set
        let cs = CharacterSet.letters
        
        // Use some method from it
        let invertedCs = cs.inverted
        XCTAssertTrue(!invertedCs.contains(capitalA), "Character set must not contain our letter")
        
        // Use another method from it
        let originalCs = invertedCs.inverted
        
        XCTAssertTrue(originalCs.contains(capitalA), "Character set must contain our letter")
    }
    
    func testMutability_copyOnWrite() {
        var firstCharacterSet = CharacterSet(charactersIn: "ABC")
        XCTAssertTrue(firstCharacterSet.contains(capitalA), "Character set must contain our letter")
        XCTAssertTrue(firstCharacterSet.contains(capitalB), "Character set must contain our letter")
        XCTAssertTrue(firstCharacterSet.contains(capitalC), "Character set must contain our letter")
        
        // Make a 'copy' (just the struct)
        var secondCharacterSet = firstCharacterSet
        // first: ABC, second: ABC
        
        // Mutate first and verify that it has correct content
        firstCharacterSet.remove(charactersIn: "A")
        // first: BC, second: ABC
        
        XCTAssertTrue(!firstCharacterSet.contains(capitalA), "Character set must not contain our letter")
        XCTAssertTrue(secondCharacterSet.contains(capitalA), "Copy should not have been mutated")
        
        // Make a 'copy' (just the struct) of the second set, mutate it
        let thirdCharacterSet = secondCharacterSet
        // first: BC, second: ABC, third: ABC
        
        secondCharacterSet.remove(charactersIn: "B")
        // first: BC, second: AC, third: ABC
        
        XCTAssertTrue(firstCharacterSet.contains(capitalB), "Character set must contain our letter")
        XCTAssertTrue(!secondCharacterSet.contains(capitalB), "Character set must not contain our letter")
        XCTAssertTrue(thirdCharacterSet.contains(capitalB), "Character set must contain our letter")
        
        firstCharacterSet.remove(charactersIn: "C")
        // first: B, second: AC, third: ABC
        
        XCTAssertTrue(!firstCharacterSet.contains(capitalC), "Character set must not contain our letter")
        XCTAssertTrue(secondCharacterSet.contains(capitalC), "Character set must not contain our letter")
        XCTAssertTrue(thirdCharacterSet.contains(capitalC), "Character set must contain our letter")
    }
    
    func testRanges() {
        // Simple range check
        let asciiUppercase = CharacterSet(charactersIn: UnicodeScalar(0x41)!...UnicodeScalar(0x5A)!)
        XCTAssertTrue(asciiUppercase.contains(UnicodeScalar(0x49)!))
        XCTAssertTrue(asciiUppercase.contains(UnicodeScalar(0x5A)!))
        XCTAssertTrue(asciiUppercase.contains(UnicodeScalar(0x41)!))
        XCTAssertTrue(!asciiUppercase.contains(UnicodeScalar(0x5B)!))
        
        // Some string filtering tests
        let asciiLowercase = CharacterSet(charactersIn: UnicodeScalar(0x61)!...UnicodeScalar(0x7B)!)
        let testString = "helloHELLOhello"
        let expected = "HELLO"
        
        let result = testString.trimmingCharacters(in: asciiLowercase)
        XCTAssertEqual(result, expected)
    }
    
    func testInsertAndRemove() {
        var asciiUppercase = CharacterSet(charactersIn: UnicodeScalar(0x41)!...UnicodeScalar(0x5A)!)
        XCTAssertTrue(asciiUppercase.contains(UnicodeScalar(0x49)!))
        XCTAssertTrue(asciiUppercase.contains(UnicodeScalar(0x5A)!))
        XCTAssertTrue(asciiUppercase.contains(UnicodeScalar(0x41)!))
        
        asciiUppercase.remove(UnicodeScalar(0x49))
        XCTAssertTrue(!asciiUppercase.contains(UnicodeScalar(0x49)!))
        XCTAssertTrue(asciiUppercase.contains(UnicodeScalar(0x5A)!))
        XCTAssertTrue(asciiUppercase.contains(UnicodeScalar(0x41)!))
        
        
        // Zero-length range
        asciiUppercase.remove(charactersIn: UnicodeScalar(0x41)!..<UnicodeScalar(0x41)!)
        XCTAssertTrue(asciiUppercase.contains(UnicodeScalar(0x41)!))
        
        asciiUppercase.remove(charactersIn: UnicodeScalar(0x41)!..<UnicodeScalar(0x42)!)
        XCTAssertTrue(!asciiUppercase.contains(UnicodeScalar(0x41)!))
        
        asciiUppercase.remove(charactersIn: "Z")
        XCTAssertTrue(!asciiUppercase.contains(UnicodeScalar(0x5A)!))
    }
    
    func testBasics() {
        
        var result : [String] = []
        
        let string = "The quick, brown, fox jumps over the lazy dog - because, why not?"
        var set = CharacterSet(charactersIn: ",-")
        result = string.components(separatedBy: set)
        XCTAssertEqual(5, result.count)
        XCTAssertEqual(["The quick", " brown", " fox jumps over the lazy dog ", " because", " why not?"], result)
        
        set.remove(charactersIn: ",")
        set.insert(charactersIn: " ")
        result = string.components(separatedBy: set)
        XCTAssertEqual(14, result.count)
        
        set.remove(" ".unicodeScalars.first!)
        result = string.components(separatedBy: set)
        XCTAssertEqual(2, result.count)
    }
    
    func test_Predefines() {
        let cset = CharacterSet.controlCharacters
        
        XCTAssertTrue(cset.contains(UnicodeScalar(0xFEFF)!), "Control set should contain UFEFF")
        XCTAssertTrue(CharacterSet.letters.contains(UnicodeScalar(0x61)!), "Letter set should contain 'a'")
        XCTAssertTrue(CharacterSet.lowercaseLetters.contains(UnicodeScalar(0x61)!), "Lowercase Letter set should contain 'a'")
        XCTAssertTrue(CharacterSet.uppercaseLetters.contains(UnicodeScalar(0x41)!), "Uppercase Letter set should contain 'A'")
        XCTAssertTrue(CharacterSet.uppercaseLetters.contains(UnicodeScalar(0x01C5)!), "Uppercase Letter set should contain U01C5")
        XCTAssertTrue(CharacterSet.capitalizedLetters.contains(UnicodeScalar(0x01C5)!), "Uppercase Letter set should contain U01C5")
        XCTAssertTrue(CharacterSet.symbols.contains(UnicodeScalar(0x002B)!), "Symbol set should contain U002B")
        XCTAssertTrue(CharacterSet.symbols.contains(UnicodeScalar(0x20B1)!), "Symbol set should contain U20B1")
        XCTAssertTrue(CharacterSet.newlines.contains(UnicodeScalar(0x000A)!), "Newline set should contain 0x000A")
        XCTAssertTrue(CharacterSet.newlines.contains(UnicodeScalar(0x2029)!), "Newline set should contain 0x2029")
        
        let mcset = CharacterSet.whitespacesAndNewlines
        let cset2 = CharacterSet.whitespacesAndNewlines

        XCTAssert(mcset.isSuperset(of: cset2))
        XCTAssert(cset2.isSuperset(of: mcset))
        
        XCTAssertTrue(CharacterSet.whitespacesAndNewlines.isSuperset(of: CharacterSet.newlines), "whitespace and newline should be a superset of newline")
        let data = CharacterSet.uppercaseLetters.bitmapRepresentation
        XCTAssertNotNil(data)
    }
    
    func test_Range() {
//        let cset1 = CharacterSet(range: NSMakeRange(0x20, 40))
        let cset1 = CharacterSet(charactersIn: UnicodeScalar(0x20)!..<UnicodeScalar(0x20 + 40)!)
        for idx: unichar in 0..<0xFFFF {
            if idx < 0xD800 || idx > 0xDFFF {
                XCTAssertEqual(cset1.contains(UnicodeScalar(idx)!), (idx >= 0x20 && idx < 0x20 + 40 ? true : false))
            }
            
        }
        
        let cset2 = CharacterSet(charactersIn: UnicodeScalar(0x0000)!..<UnicodeScalar(0xFFFF)!)
        for idx: unichar in 0..<0xFFFF {
            if idx < 0xD800 || idx > 0xDFFF {
                XCTAssertEqual(cset2.contains(UnicodeScalar(idx)!), true)
            }
            
        }
        

        let cset3 = CharacterSet(charactersIn: UnicodeScalar(0x0000)!..<UnicodeScalar(10)!)
        for idx: unichar in 0..<0xFFFF {
            if idx < 0xD800 || idx > 0xDFFF {
                XCTAssertEqual(cset3.contains(UnicodeScalar(idx)!), (idx < 10 ? true : false))
            }
            
        }
        
        let cset4 = CharacterSet(charactersIn: UnicodeScalar(0x20)!..<UnicodeScalar(0x20)!)
        for idx: unichar in 0..<0xFFFF {
            if idx < 0xD800 || idx > 0xDFFF {
                XCTAssertEqual(cset4.contains(UnicodeScalar(idx)!), false)
            }
            
        }
    }
    
    func test_String() {
        let cset = CharacterSet(charactersIn: "abcABC")
        for idx: unichar in 0..<0xFFFF {
            if idx < 0xD800 || idx > 0xDFFF {
                XCTAssertEqual(cset.contains(UnicodeScalar(idx)!), (idx >= unichar(unicodeScalarLiteral: "a") && idx <= unichar(unicodeScalarLiteral: "c")) || (idx >= unichar(unicodeScalarLiteral: "A") && idx <= unichar(unicodeScalarLiteral: "C")) ? true : false)
            }
        }
    }
    
    func testClosedRanges_SR_2988() {
        // "CharacterSet.insert(charactersIn: ClosedRange) crashes on a closed ClosedRange<UnicodeScalar> containing U+D7FF"
        let problematicChar = UnicodeScalar(0xD7FF)!
        let range = capitalA...problematicChar
        var characters = CharacterSet(charactersIn: range) // this should not crash
        XCTAssertTrue(characters.contains(problematicChar))
        characters.remove(charactersIn: range) // this should not crash
        XCTAssertTrue(!characters.contains(problematicChar))
        characters.insert(charactersIn: range) // this should not crash
        XCTAssertTrue(characters.contains(problematicChar))
    }
    
    func test_Bitmap() {
        
    }
    
    func test_AnnexPlanes() {
        
    }
    
    func test_Planes() {
        
    }
    
    func test_InlineBuffer() {
        
    }
}

