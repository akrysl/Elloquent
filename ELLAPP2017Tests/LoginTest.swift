//
//  LoginTest.swift
//  LoginTest
//
//  Created by Christopher Peterson on 1/25/18.
//  Copyright © 2018 Ellokids. All rights reserved.
//

import XCTest
import UIKit
@testable import ELLAPP2017
import Parse

extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}

class LoginTest: XCTestCase {
    
    var vc: LoginViewController!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // obtain the app variables for test access
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        vc = storyboard.instantiateViewController(withIdentifier: "vc_login") as! LoginViewController
        // That was no longer the initial view controller - NAP
        // vc = storyboard.instantiateInitialViewController() as! LoginViewController
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRoles() {
        let expectedRoles = ["teacher", "student", "admin"]
        let expect = expectation(description: "Waiting to get roles")
        var userRoles = [String]()
        
        vc.getAllRoles() {
            (roles: [PFObject]) in
            
            for role in roles {
                userRoles.append(role["name"] as! String)
            }
            
            expect.fulfill()
        }
        
        // Fails if database is down
        waitForExpectations(timeout: 10, handler: nil)

        // Check that the roles exist
        XCTAssert(userRoles.contains("teacher"), "Teacher role not found")
        XCTAssert(userRoles.contains("student"), "Student role not found")
        XCTAssert(userRoles.contains("admin"), "Admin role not found")
        
        // Check that the roles both contain the same exact elements
        XCTAssert(userRoles.containsSameElements(as: expectedRoles), "Extra roles found")
    }
    
    func testUsers() {
        var waits = [XCTestExpectation]()
        
        //TODO: This is not safe at all, needs to eventually be fixed
        let testUsers = ["_testTeacher", "_testAdmin", "_testStudent", "nick"]
        let testPasswords = ["2j2t3o", "93m943f23m", "2o23gmi", "nick"]
        
        // The exact roles we expect the above people to have. If they differ the test will fail.
        let testRoles = [["teacher"], ["admin"], ["student"], ["admin", "teacher", "student"]]
        
        // This can't be a part of the asynchronous stuff because it NEEDS to finish before running async stuff
        for i in 0...(testUsers.count - 1) {
            waits.append(expectation(description: testUsers[i]))
        }
        
        for i in 0...(testUsers.count - 1) {
            vc.login(user: testUsers[i], pass: testPasswords[i]) {
                (userObj: PFUser?) in
                
                // Get the user's roles
                self.vc.getUserRoles(userObj: userObj!) {
                    (userRoles: [String]) in
                    
                    // Are the roles equal to what we think they should be?
                    XCTAssert(userRoles.sorted() == testRoles[i].sorted(), "Roles for \(testUsers[i]) not found as expected")
                    
                    waits[i].fulfill()
                }
            }
        }
        
        // Fails if database is down
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testLoginTime() {
        measure {
            let expect = expectation(description: "Example")
        
            vc.login(user: "nick", pass: "nick") {
                (userObj: PFUser?) in
            
                self.vc.navigateToDashboard(userObj: userObj!)
            
                self.stopMeasuring()
                expect.fulfill()
            }
        
            // Fails if database is down
            waitForExpectations(timeout: 10, handler: nil)
        }
    }
    
}

