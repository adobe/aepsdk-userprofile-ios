/*
 Copyright 2020 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. You may obtain a copy
 of the License at http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software distributed under
 the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 OF ANY KIND, either express or implied. See the License for the specific language
 governing permissions and limitations under the License.
 */

import AEPCore
import AEPUserProfile
import XCTest

class AEPUserProfileE2ETests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRulesEngineIntegration() throws {
        MobileCore.setLogLevel(.trace)
        MobileCore.registerExtensions([UserProfile.self])
        // Launch Property name : AEPUserProfile_E2E_DO_NOT_DELETE
        MobileCore.configureWith(appId: "94f571f308d5/40c2dd990434/launch-c1320f564c90-development")
        sleep(2)
        UserProfile.updateUserAttributes(attributeDict: ["int_key": "200", "string_key": "xxxx string_value xxx", "int_contains_key": 5])
        sleep(1)
        let expectation = self.expectation(description: "register UserProfile extension")
        UserProfile.getUserAttributes(attributeNames: ["key_consequence"]) {
            result, _ in
            expectation.fulfill()
            XCTAssertNotNil(result?["key_consequence"])
        }
        waitForExpectations(timeout: 2)
    }
}
