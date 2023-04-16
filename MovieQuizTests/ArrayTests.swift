//
//  ArrayTests.swift
//  MovieQuizTests
//
//  Created by Ольга Чушева on 13.04.2023.
//

import Foundation
import XCTest

@testable import MovieQuiz

class ArrayTest: XCTestCase {
    func testGetValueInRange () throws { // тест на успешное взятие элемента по индексу
        //Given
        let array = [1, 1, 2, 3, 5]
        
        //When
        let value = array[2]
        
        //Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
        
    }
    func testGetValueOutOfRange () throws { // тест на взятие элемента по неправильному индексу
        //Given
        let array = [1, 1, 2, 3, 5]
        
        //When
        let value = array[20]
        
        //Then
        XCTAssertNil(value)        
    }
}
