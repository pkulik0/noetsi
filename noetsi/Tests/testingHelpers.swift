//
//  testingHelpers.swift
//  noetsi
//
//  Created by pkulik0 on 21/06/2022.
//

import XCTest

extension XCTestCase {
    func randomText(length: Int) -> String {
        let availableCharacters = "abcdefghijklmnopqrstuvwxyz0123456789"
        var text = ""
        for _ in 0..<length  {
            text.append(availableCharacters.randomElement() ?? "a")
        }
        return text
    }
}
