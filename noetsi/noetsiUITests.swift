//
//  noetsiUITests.swift
//  noetsi (noetsiUITests)
//
//  Created by pkulik0 on 20/06/2022.
//

import XCTest

class noetsiUITests: XCTestCase {

    let app = XCUIApplication()
    let availableCharacters = "abcdefghijklmnopqrstuvwxyz 0123456789 .!?"
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
        try loginUser()
    }

    override func tearDownWithError() throws {
        try logoutUser()
    }
    
    func randomText(length: Int) -> String {
        var text = ""
        for _ in 0..<length  {
            text.append(availableCharacters.randomElement() ?? "a")
        }
        return text
    }
    
    func loginUser() throws {
        app.textFields["email"].tap()
        app.typeText("Test@test.com")
        
        app.secureTextFields["password"].tap()
        app.typeText("testnoetsi")
        
        app.buttons["sign in"].tap()
        
        let navBar = app.navigationBars["noetsi"]
        XCTAssert(navBar.waitForExistence(timeout: 3))
    }
    
    func logoutUser() throws {
        app.tabBars["Tab Bar"].buttons["Settings"].tap()
        app.tables.cells["Sign Out"].tap()
    }

    func testAddNote() throws {
        let noteTitle = randomText(length: Int.random(in: 5...15))
        let noteBody = randomText(length: Int.random(in: 10...30)) + "\n" + randomText(length: Int.random(in: 10...30))

        app.navigationBars["noetsi"].buttons["Add note"].tap()

        let titleField = app.scrollViews.otherElements.textFields["Title"]
        XCTAssert(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        app.typeText(noteTitle)
        
        app.scrollViews.otherElements.staticTexts["Empty"].tap()
        app.typeText(noteBody)
        
        app.toolbars["Toolbar"].buttons["Done"].tap()
        app.navigationBars["_TtGC7SwiftUI19UIHosting"].buttons["noetsi"].tap()
    }
    
    func testAddTag() throws {
        let tagName = randomText(length: Int.random(in: 4...10))

        let editButtons = app.buttons["editTagsButton"]
        XCTAssert(editButtons.waitForExistence(timeout: 2))
        editButtons.firstMatch.tap()
        
        app.tables.textFields["Tag"].tap()
        app.typeText(tagName)
        
        let addButton = app.tables.buttons["Add"]
        XCTAssert(addButton.waitForExistence(timeout: 1))
        app.tables.buttons["Add"].tap()
        
        XCTAssert(app.tables.cells["#\(tagName)"].exists)
        
        app.navigationBars["Tag Editor"].buttons["Save"].tap()
    }
}
