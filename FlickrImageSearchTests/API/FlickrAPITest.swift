//
//  FlickrAPITest.swift
//  FlickrImageSearch
//
//  Created by Andre Nguyen on 9/11/17.
//  Copyright © 2017 Andre Nguyen. All rights reserved.
//

@testable import FlickrImageSearch
import XCTest
import Alamofire

class FlickrAPITest: XCTestCase {
    
    var flickrAPI : FlickrAPI!
    
    override func setUp() {
        super.setUp()
        
        self.flickrAPI = FlickrAPI(withAPIKey: API.FlickrAPIKey)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testPhotoSearchDoesReturnPhotos() {
        
        let expct = expectation(description: "Returns photo")
        
        flickrAPI.photoSearch(withText: "Hurricane Irma", andPage: 1, completion: { (success, photos, message) in
            XCTAssertTrue(success, message)
            expct.fulfill()
        })
        
        waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                XCTFail("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testValidatePhotoImageURL() {
        
        let expct = expectation(description: "Returns all fields to create valid image url")
        
        flickrAPI.photoSearch(withText: "Amsterdam", andPage: 1, completion: { (success, photos, message) in
            if success {
                
                guard let photosCount = photos?.count else {
                    XCTFail("No photos returned")
                    return
                }
                
                if photosCount > 0 {
                    XCTAssert(true, "Returned photos")
                    
                    // Pick first photo to test image url
                    let photo = photos?.first
                    
                    if photo?.farm == nil {
                        XCTFail("No farm id returned")
                    }
                    
                    if photo?.server == nil {
                        XCTFail("No server id returned")
                    }
                    
                    if photo?.photoId == nil {
                        XCTFail("No photo id returned")
                    }
                    
                    if photo?.secret == nil {
                        XCTFail("No secret id returned")
                    }
                    
                    XCTAssert(true, "Success")
                    expct.fulfill()
                }
                
            }
            else {
                XCTFail(message)
            }
        })
        
        waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                XCTFail("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testPhotoSearchInvalidText() {
        
        let expct = expectation(description: "Returns photo")
        
        flickrAPI.photoSearch(withText: "", andPage: 1, completion: { (success, photos, message) in
            XCTAssertFalse(success, message)
            expct.fulfill()
        })
        
        waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                XCTFail("Error: \(error.localizedDescription)")
            }
        }
    }
    
}
