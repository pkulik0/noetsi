//
//  noetsiTests.swift
//  noetsi (noetsiTests)
//
//  Created by pkulik0 on 10/06/2022.
//

import XCTest
import SwiftUI
@testable import noetsi

class noetsiTests: XCTestCase {
    
    var firestoreManager = FirestoreManager()

    override func setUpWithError() throws {
        firestoreManager = FirestoreManager()
    }

    override func tearDownWithError() throws {
        
    }
    
    func randomText(length: Int) -> String {
        let availableCharacters = "abcdefghijklmnopqrstuvwxyz0123456789"
        var text = ""
        for _ in 0..<length  {
            text.append(availableCharacters.randomElement() ?? "a")
        }
        return text
    }
    
    func waitForUpdate(seconds duration: Double) {
        _ = XCTWaiter.wait(for: [expectation(description: "Wait for data update")], timeout: duration)
    }
    
    func testWriteNoteSimple() throws {
        let note = Note(id: randomText(length: 10))
        firestoreManager.writeNote(note: note)
        waitForUpdate(seconds: 1)
        
        firestoreManager.fetchData()
        waitForUpdate(seconds: 1)

        XCTAssert(firestoreManager.notes == [note])
    }
    
    func testWriteNoteMulitple() throws {
        var notes: [Note] = []
        for _ in 5...20 {
            let note = Note(id: randomText(length: 10))
            notes.append(note)
            firestoreManager.writeNote(note: note)
        }
        waitForUpdate(seconds: 3)
        
        firestoreManager.fetchData()
        waitForUpdate(seconds: 1)
        
        XCTAssert(firestoreManager.notes.sorted{ $0.id > $1.id } == notes.sorted{ $0.id > $1.id })
    }
    
    func testWriteLayoutSimple() throws {
        let noteID = randomText(length: 10)
        
        firestoreManager.layout.append(noteID)
        firestoreManager.writeLayout()
        waitForUpdate(seconds: 1)
        
        firestoreManager.layout = []
        
        firestoreManager.fetchData()
        waitForUpdate(seconds: 1)
        
        XCTAssert(firestoreManager.layout.contains(noteID))
    }
    
    func testWriteLayoutMultiple() throws {
        firestoreManager.layout = [randomText(length: 10), randomText(length: 10), randomText(length: 10)]
        firestoreManager.writeLayout()
        waitForUpdate(seconds: 1)
        
        let layoutCopy = firestoreManager.layout
        firestoreManager.layout = []
        
        firestoreManager.fetchData()
        waitForUpdate(seconds: 1)
        
        XCTAssert(firestoreManager.layout == layoutCopy)
    }
}
