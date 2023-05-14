//
//  MovieQuizTests.swift
//  MovieQuizTests
//
//  Created by Ольга Чушева on 13.04.2023.
//

import XCTest

    struct ArifmeticOperation {
        func addiction(num1: Int, num2: Int, handler: @escaping (Int)->Void) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                handler(num1 + num2)
            }
        }
        
        func subtraction(num1: Int, num2: Int, handler: @escaping (Int)->Void) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                handler(num1 - num2)
            }
        }
        
        func multiplication(num1: Int, num2: Int, handler: @escaping (Int)->Void) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                handler(num1 * num2)
            }
        }
    }

final class MovieQuizTests: XCTestCase {
    func testAddiction() throws {
        let arifmeticOperation = ArifmeticOperation()
        let num1 = 1
        let num2 = 2
        
        let expectation = expectation(description: "Addiction function expectdtion")
        
        arifmeticOperation.addiction(num1: 1, num2: 2) { result in
            
            XCTAssertEqual(result, 3)
            expectation.fulfill()
            
        }
        
        waitForExpectations(timeout: 2)
    }
}
