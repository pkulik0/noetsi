//
//  noetsiTests.swift
//  noetsi (noetsiTests)
//
//  Created by pkulik0 on 10/06/2022.
//

import XCTest
import Firebase
@testable import noetsi

class noetsiTests: XCTestCase {
    
    let firestoreManager = FirestoreManager()

    override func setUpWithError() throws {
        clearFirestore()
    }

    func clearFirestore() {
        let semaphore = DispatchSemaphore(value: 0)
        let projectId = FirebaseApp.app()!.options.projectID!
        let url = URL(string: "http://localhost:8080/emulator/v1/projects/\(projectId)/databases/(default)/documents")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTask(with: request) { _, _, _ in
            print("Local firestore cleared")
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
    }
    
    func waitForUpdate() {
        _ = XCTWaiter.wait(for: [expectation(description: "Wait for data update")], timeout: 2)
    }
    
    func testAddNote() throws {
        let notesSnapshot = firestoreManager.notes
        let layoutSnapshot = firestoreManager.layout
        
        firestoreManager.addNote()
        
        XCTAssert(firestoreManager.notes.count == notesSnapshot.count + 1)
        XCTAssert(firestoreManager.layout.count == layoutSnapshot.count + 1)
        XCTAssert(firestoreManager.layout[0] == firestoreManager.notes[0].id)
    }
    
    func testWriteNoteSimple() throws {
        let note = Note(id: randomText(length: 10))
        firestoreManager.writeNote(note: note)
        
        firestoreManager.fetchData()
        waitForUpdate()

        XCTAssert(firestoreManager.notes.contains(note))
    }
    
    func testWriteNoteMulitple() throws {
        var notes: [Note] = []
        for _ in 0...50 {
            let note = Note(id: randomText(length: 5))
            firestoreManager.writeNote(note: note)
            notes.append(note)
        }
        
        firestoreManager.fetchData()
        waitForUpdate()
        
        XCTAssert(firestoreManager.notes.sorted{ $0.id > $1.id } == notes.sorted{ $0.id > $1.id })
    }
    
    func testWriteLayoutSimple() throws {
        let noteID = randomText(length: 10)
        
        firestoreManager.layout.insert(noteID, at: 0)
        firestoreManager.writeLayout()
        
        firestoreManager.layout = []
        
        firestoreManager.fetchData()
        waitForUpdate()
        
        XCTAssert(firestoreManager.layout[0] == noteID)
    }
    
    func testWriteLayoutMultiple() throws {
        firestoreManager.layout = [randomText(length: 10), randomText(length: 10), randomText(length: 10)]
        firestoreManager.writeLayout()
        
        let layoutCopy = firestoreManager.layout
        firestoreManager.layout = []
        
        firestoreManager.fetchData()
        waitForUpdate()
        
        XCTAssert(firestoreManager.layout == layoutCopy)
    }
    
    func testDeleteNote() throws {
        let note = Note(id: randomText(length: 5))
        firestoreManager.writeNote(note: note)
        
        firestoreManager.fetchData()
        waitForUpdate()
        XCTAssert(firestoreManager.notes == [note])

        firestoreManager.deleteNote(id: note.id)
        firestoreManager.fetchData()
        waitForUpdate()
        XCTAssert(firestoreManager.notes == [])
    }
    
    func testFetchData() throws {
        var notes: [Note] = []
        for _ in 0...100 {
            let note = Note(id: randomText(length: 5))
            firestoreManager.writeNote(note: note)
            notes.append(note)
        }
        
        firestoreManager.fetchData()
        waitForUpdate()
        
        XCTAssert(firestoreManager.notes.sorted { $0.id > $1.id } == notes.sorted { $0.id > $1.id })
    }

    func testMoveSimple() throws {
        for _ in 0..<3 {
            firestoreManager.addNote()
        }
        let notesSnapshot = firestoreManager.notes
        let layoutSnapshot = firestoreManager.layout
        
        firestoreManager.move(from: IndexSet(integer: 2), to: 0)
        firestoreManager.move(from: IndexSet(integer: 2), to: 1)
        
        XCTAssert(firestoreManager.notes == notesSnapshot.reversed())
        XCTAssert(firestoreManager.layout == layoutSnapshot.reversed())
    }
    
    func testMoveRandom() throws {
        let notesSize = 100
        let repetitions = 25

        for _ in 0..<notesSize {
            firestoreManager.addNote()
        }
        for _ in 0..<repetitions {
            let notesSnapshot = firestoreManager.notes
            let layoutSnapshot = firestoreManager.layout
            
            let origin = Int.random(in: 0..<notesSize)
            var destination = Int.random(in: 0..<notesSize)
            
            while origin == destination {
                destination = Int.random(in: 0..<notesSize)
            }
            
            firestoreManager.move(from: IndexSet(integer: origin), to: destination)
            
            if origin < destination {
                XCTAssert(firestoreManager.notes[destination - 1] == notesSnapshot[origin])
                XCTAssert(firestoreManager.layout[destination - 1] == layoutSnapshot[origin])
            } else  {
                XCTAssert(firestoreManager.notes[destination] == notesSnapshot[origin])
                XCTAssert(firestoreManager.layout[destination] == layoutSnapshot[origin])
            }
        }
    }
    
    func testMoveTraverse() throws {
        let notesSize = 100
        for _ in 0..<notesSize {
            firestoreManager.addNote()
        }
        
        let notesSnapshot = firestoreManager.notes
        let layoutSnapshot = firestoreManager.layout
        
        for index in 0..<(notesSize - 1) {
            firestoreManager.move(from: IndexSet(integer: index), to: index + 2)
        }
        
        XCTAssert(notesSnapshot.first! == firestoreManager.notes.last!)
        XCTAssert(layoutSnapshot.first! == firestoreManager.layout.last!)
        
        XCTAssert(notesSnapshot[1] == firestoreManager.notes.first!)
        XCTAssert(layoutSnapshot[1] == firestoreManager.layout.first!)
    }
    
    func testNoteCopy() throws {
        let note = Note(id: randomText(length: 5))
        let noteCopy = note.copy()
        XCTAssert(note.id == noteCopy.id)
        
        note.id = ""
        XCTAssert(note.id != noteCopy.id)
    }
    
    func testNoteEquatable() throws {
        let note0 = Note()
        var note1 = note0.copy()
        XCTAssert(note0 == note1)
        
        note1.id = "x"
        XCTAssert(note0 != note1)
        note1 = note0.copy()
        
        note1.title = "x"
        XCTAssert(note0 != note1)
        note1 = note0.copy()
        
        note1.body = "x"
        XCTAssert(note0 != note1)
        note1 = note0.copy()
        
        note1.tags = ["x"]
        XCTAssert(note0 != note1)
        note1 = note0.copy()
        
        note1.timestamp = 1
        XCTAssert(note0 != note1)
        note1 = note0.copy()
        
        note1.color = .white
        XCTAssert(note0 != note1)
        note1 = note0.copy()
        
        note1.pattern = Pattern(type: .Grid, size: 99)
        XCTAssert(note0 != note1)
        note1 = note0.copy()
        
        note1.checklist = [ChecklistEntry(text: "x", isChecked: true)]
        XCTAssert(note0 != note1)
        note1 = note0.copy()
        
        note1.reminder = UNNotificationRequest(identifier: "x", content: UNNotificationContent(), trigger: nil)
        XCTAssert(note0 != note1)
        note1 = note0.copy()
    }
}
