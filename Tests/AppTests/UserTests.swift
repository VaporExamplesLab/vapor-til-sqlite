/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

@testable import App
import Vapor
import XCTest
import FluentSQLite

final class UserTests : XCTestCase {
    
    let usersURI = "/api/users/"
    let usersName = "Alice"
    let usersUsername = "alicea"
    var app: Application!
    var conn: SQLiteConnection!
    
    override func setUp() {
        print("•• UserTests setUp()")
        try! Application.reset()
        app = try! Application.testable()
        conn = try! app.newConnection(to: .sqlite).wait()
    }
    
    override func tearDown() {
        print("•• UserTests tearDown()")
        conn.close()
        try? app.syncShutdownGracefully()
    }
    
    func testUsersCanBeRetrievedFromAPI() throws {
        print("•• UserTests testUsersCanBeRetrievedFromAPI() ••")
        // Note: Admin/admin/password user already exists in database
        // CREATE 2nd user directly in database
        let user = try User.create(name: usersName, username: usersUsername, on: conn)
        // CREATE 3rd user (default) directly in database  
        _ = try User.create(on: conn)
        
        // GET READ users from URL
        let users = try app.getResponse(
            to: usersURI, 
            decodeTo: [User.Public].self
        )
        
        XCTAssertEqual(users.count, 3)
        // users[0].name = Admin
        XCTAssertEqual(users[1].name, usersName)
        // users[0].username = admin
        XCTAssertEqual(users[1].username, usersUsername)
        XCTAssertEqual(users[1].id, user.id)
    }
    
    func testUserCanBeSavedWithAPI() throws {
        print("•• UserTests testUserCanBeSavedWithAPI() ••")
        // instantiate user instance, not in database
        let user = User(name: usersName, username: usersUsername, password: "password")
        // POST to CREATE user in database
        let receivedUser = try app.getResponse(
            to: usersURI, 
            method: .POST, 
            headers: ["Content-Type": "application/json"], 
            data: user, 
            decodeTo: User.Public.self, 
            loggedInRequest: true
        )
        
        XCTAssertEqual(receivedUser.name, usersName)
        XCTAssertEqual(receivedUser.username, usersUsername)
        XCTAssertNotNil(receivedUser.id)
        
        // GET READ from database via URL 
        let users = try app.getResponse(
            to: usersURI, 
            decodeTo: [User.Public].self
        )
        
        XCTAssertEqual(users.count, 2)
        XCTAssertEqual(users[1].name, usersName)
        XCTAssertEqual(users[1].username, usersUsername)
        XCTAssertEqual(users[1].id, receivedUser.id)
    }
    
    func testGettingASingleUserFromTheAPI() throws {
        print("•• UserTests testGettingASingleUserFromTheAPI() ••")
        // CREATE 2nd user directly in database
        let user = try User.create(name: usersName, username: usersUsername, on: conn)
        // GET READ from database via URL
        let receivedUser = try app.getResponse(
            to: "\(usersURI)\(user.id!)", 
            decodeTo: User.Public.self
        )
        
        XCTAssertEqual(receivedUser.name, usersName)
        XCTAssertEqual(receivedUser.username, usersUsername)
        XCTAssertEqual(receivedUser.id, user.id)
    }
    
    func testGettingAUsersAcronymsFromTheAPI() throws {
        print("•• UserTests testGettingAUsersAcronymsFromTheAPI() ••")
        // CREATE user directly into database
        let user = try User.create(on: conn)
        // CREATE acronym directly into database
        let acronymShort = "OMG"
        let acronymLong = "Oh My God"
        let acronym1 = try Acronym.create(
            short: acronymShort, 
            long: acronymLong, 
            user: user, 
            on: conn
        )
        // CREATE 2nd acronym directly in database
        _ = try Acronym.create(short: "LOL", long: "Laugh Out Loud", user: user, on: conn)
        
        // GET READ all acronyms for user via URL
        let acronyms = try app.getResponse(
            to: "\(usersURI)\(user.id!)/acronyms", 
            decodeTo: [Acronym].self
        )
        
        XCTAssertEqual(acronyms.count, 2)
        XCTAssertEqual(acronyms[0].id, acronym1.id)
        XCTAssertEqual(acronyms[0].short, acronymShort)
        XCTAssertEqual(acronyms[0].long, acronymLong)
    }
    
    static let allTests = [
        ("testUsersCanBeRetrievedFromAPI", testUsersCanBeRetrievedFromAPI),
        ("testUserCanBeSavedWithAPI", testUserCanBeSavedWithAPI),
        ("testGettingASingleUserFromTheAPI", testGettingASingleUserFromTheAPI),
        ("testGettingAUsersAcronymsFromTheAPI", testGettingAUsersAcronymsFromTheAPI),
        ]
}
