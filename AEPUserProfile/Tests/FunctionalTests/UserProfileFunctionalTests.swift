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

@testable import AEPCore
import AEPServices
import AEPTestUtils
@testable import AEPUserProfile
import XCTest

class UserProfileFunctionalTests: XCTestCase {
    private var theExpectation: XCTestExpectation?

    private let EXTENSION_NAME = "com.adobe.module.userProfile"
    private let DATASTORE_KEY_ATTRIBUTES = "attributes"

    private func setAttributesInDatastore(_ value: [String: Any]?) {
        let dataStore = NamedCollectionDataStore(name: EXTENSION_NAME)
        dataStore.set(key: DATASTORE_KEY_ATTRIBUTES, value: value)
    }

    private func getAttributesInDatastore() -> [String: Any]? {
        let dataStore = NamedCollectionDataStore(name: EXTENSION_NAME)
        return dataStore.getDictionary(key: DATASTORE_KEY_ATTRIBUTES) as? [String: Any]
    }

    override func setUpWithError() throws {
        MobileCore.setLogLevel(.trace)
        NamedCollectionDataStore.clear()
    }

    override func tearDownWithError() throws {
        MobileCore.unregisterExtension(UserProfile.self)
        MobileCore.unregisterExtension(MonitorExtension.self)
        EventHub.shared = EventHub()
    }

    func testExtensionRegistrationWillCreateSharedStateWithEmptyAttributes() throws {
        // Given
        theExpectation = expectation(description: "monitor the shared state from UserProfile")

        MonitorExtension.profileSharedStateReceiver = { _ in
            guard let data = MonitorExtension.instance?.userProfileSharedStateData?["userprofiledata"] as? [String: String] else {
                return
            }
            XCTAssertEqual(0, data.count)
            self.theExpectation?.fulfill()
            MonitorExtension.profileSharedStateReceiver = nil
        }

        // When
        MobileCore.registerExtensions([UserProfile.self, MonitorExtension.self]) {}

        // Then
        waitForExpectations(timeout: 3)
    }

    func testExtensionRegistrationWillCreateSharedState() throws {
        setAttributesInDatastore(["key1": "value1"])
        theExpectation = expectation(description: "monitor the shared state from UserProfile")

        MonitorExtension.profileSharedStateReceiver = { _ in
            guard let data = MonitorExtension.instance?.userProfileSharedStateData?["userprofiledata"] as? [String: String] else {
                return
            }
            XCTAssertEqual(["key1": "value1"], data)
            self.theExpectation?.fulfill()
            MonitorExtension.profileSharedStateReceiver = nil
        }
        MobileCore.registerExtensions([UserProfile.self, MonitorExtension.self]) {}
        waitForExpectations(timeout: 3)
    }

    func testUpdateUserAttributesWithAllSupportedTypes() throws {
        // Given
        let expectation = self.expectation(description: "register UserProfile extension")
        setAttributesInDatastore(["k1": "v1", "k4": 11])


        MobileCore.registerExtensions([UserProfile.self]) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2)

        // When
        UserProfile.updateUserAttributes(attributeDict: ["k2": 2.1, "k3": 3, "k4": true])

        // Then
        let expectGet = self.expectation(description: "getUserAttributes()")
        UserProfile.getUserAttributes(attributeNames: ["k1", "k2", "k3", "k4"]) {
            attributes, _ in
            XCTAssertNotNil(attributes)
            expectGet.fulfill()
            XCTAssertEqual("v1", attributes?["k1"] as? String)
            XCTAssertEqual(2.1, attributes?["k2"] as? Double)
            XCTAssertEqual(3, attributes?["k3"] as? Int)
            XCTAssertEqual(true, attributes?["k4"] as? Bool)
        }
        waitForExpectations(timeout: 2)
    }

    func testUpdateUserAttributesWithEmptyDict() throws {
        // Given
        let expectation = self.expectation(description: "register UserProfile extension")
        setAttributesInDatastore(["k1": "v1"])

        MobileCore.registerExtensions([UserProfile.self]) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2)

        // When
        UserProfile.updateUserAttributes(attributeDict: [:])

        // Then
        let expectGet = self.expectation(description: "getUserAttributes()")
        UserProfile.getUserAttributes(attributeNames: ["k1"]) {
            attributes, _ in
            XCTAssertEqual(["k1": "v1"], attributes as? [String: String])
            XCTAssertEqual(["k1": "v1"], self.getAttributesInDatastore() as? [String: String])
            expectGet.fulfill()
        }
        waitForExpectations(timeout: 2)
    }

    func testGetUserAttributesWithEmptyDict() throws {
        // Given
        let expectation = self.expectation(description: "register UserProfile extension")
        setAttributesInDatastore(["k1": "v1", "k2": "v2"])

        MobileCore.registerExtensions([UserProfile.self, MonitorExtension.self]) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2)

        // When
        let expectGet = self.expectation(description: "getUserAttributes()")
        UserProfile.getUserAttributes(attributeNames: []) {
            _, error in
            XCTAssertEqual(AEPError.none, error)
            XCTAssertEqual(["k1": "v1", "k2": "v2"], self.getAttributesInDatastore() as? [String: String])
            expectGet.fulfill()
        }

        // Then
        waitForExpectations(timeout: 2)
    }

    func testRemoveUserAttributes() throws {
        let expectation = self.expectation(description: "register UserProfile extension")
        setAttributesInDatastore(["k1": "v1", "k2": "v2"])

        MobileCore.registerExtensions([UserProfile.self]) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2)

        UserProfile.removeUserAttributes(attributeNames: ["k1", "k3"])

        let expectGet = self.expectation(description: "getUserAttributes()")
        UserProfile.getUserAttributes(attributeNames: ["k1", "k2", "k3"]) {
            attributes, _ in
            expectGet.fulfill()
            XCTAssertEqual(["k2": "v2"], attributes as? [String: String])
        }
        waitForExpectations(timeout: 2)
    }

    func testRemoveUserAttributesWithEmptyDict() throws {
        let expectation = self.expectation(description: "register UserProfile extension")
        setAttributesInDatastore(["k1": "v1", "k2": "v2"])

        MobileCore.registerExtensions([UserProfile.self]) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2)

        UserProfile.removeUserAttributes(attributeNames: [])

        let expectGet = self.expectation(description: "getUserAttributes()")
        UserProfile.getUserAttributes(attributeNames: ["k1", "k2", "k3"]) {
            attributes, _ in
            expectGet.fulfill()
            XCTAssertEqual(["k1": "v1", "k2": "v2"], attributes as? [String: String])
        }
        waitForExpectations(timeout: 2)
    }

    func testRulesConsequenceEventOperationWrite() throws {
        setAttributesInDatastore(["key1": "value1", "key2": "value2"])
        let expectation = self.expectation(description: "register UserProfile extension")

        MobileCore.registerExtensions([UserProfile.self, MonitorExtension.self]) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2)

        theExpectation = self.expectation(description: "monitor the shared state from UserProfile")
        let event = Event(name: "consequence event", type: "com.adobe.eventType.rulesEngine", source: "com.adobe.eventSource.responseContent", data: ["triggeredconsequence": ["type": "csp", "detail": ["key": "key3", "value": "value3", "operation": "write"]] as [String: Any]])
        MonitorExtension.profileSharedStateReceiver = { _ in
            guard let data = EventHub.shared.getSharedState(extensionName: "com.adobe.module.userProfile", event: event)?.value?["userprofiledata"] as? [String: String] else {
                return
            }
            guard data.count != 2 else {
                return
            }
            XCTAssertEqual(3, data.count)
            XCTAssertEqual(["key1": "value1", "key2": "value2", "key3": "value3"], data)
            self.theExpectation?.fulfill()
            MonitorExtension.profileSharedStateReceiver = nil
        }
        MobileCore.dispatch(event: event)

        waitForExpectations(timeout: 2)

        MobileCore.unregisterExtension(UserProfile.self)
        MobileCore.unregisterExtension(MonitorExtension.self)
    }

    func testRulesConsequenceEventOperationDelete() throws {
        setAttributesInDatastore(["key1": "value1", "key2": "value2"])
        let expectation = self.expectation(description: "register UserProfile extension")

        MobileCore.registerExtensions([UserProfile.self, MonitorExtension.self]) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2)

        theExpectation = self.expectation(description: "monitor the shared state from UserProfile")
        let event = Event(name: "consequence event", type: "com.adobe.eventType.rulesEngine", source: "com.adobe.eventSource.responseContent", data: ["triggeredconsequence": ["type": "csp", "detail": ["key": "key1", "operation": "delete"]] as [String: Any]])
        MonitorExtension.profileSharedStateReceiver = { _ in
            guard let data = EventHub.shared.getSharedState(extensionName: "com.adobe.module.userProfile", event: event)?.value?["userprofiledata"] as? [String: String] else {
                return
            }
            guard data.count != 2 else {
                return
            }
            XCTAssertEqual(1, data.count)
            XCTAssertEqual(["key2": "value2"], data)
            MonitorExtension.profileSharedStateReceiver = nil
            self.theExpectation?.fulfill()
        }
        MobileCore.dispatch(event: event)

        waitForExpectations(timeout: 2)
    }

    func testRulesConsequenceEventBadData() throws {
        MonitorExtension.sharedStateChanged = 0
        setAttributesInDatastore(["key1": "value1", "key2": "value2"])
        let expectation = self.expectation(description: "register UserProfile extension")

        MobileCore.registerExtensions([UserProfile.self, MonitorExtension.self]) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2)

        MobileCore.dispatch(event: Event(name: "consequence event", type: "com.adobe.eventType.rulesEngine", source: "com.adobe.eventSource.responseContent", data: ["triggeredconsequence": ["detail": ["key": "key3", "value": "value3", "operation": "write"]]]))
        MobileCore.dispatch(event: Event(name: "consequence event", type: "com.adobe.eventType.rulesEngine", source: "com.adobe.eventSource.responseContent", data: ["triggeredconsequence": ["detail": ["key": "key1", "operation": "delete"]]]))
        MobileCore.dispatch(event: Event(name: "consequence event", type: "com.adobe.eventType.rulesEngine", source: "com.adobe.eventSource.responseContent", data: ["triggeredconsequence": ["detail": ["key": "key2", "operation": "delete"]]]))
        MobileCore.dispatch(event: Event(name: "consequence event", type: "com.adobe.eventType.rulesEngine", source: "com.adobe.eventSource.responseContent", data: ["triggeredconsequence": ["type": "csp", "detail": ["key": "key1", "operation": "add"]] as [String: Any]]))
        MobileCore.dispatch(event: Event(name: "consequence event", type: "com.adobe.eventType.rulesEngine", source: "com.adobe.eventSource.responseContent", data: ["triggeredconsequence": ["type": "csp", "detail": ["key": "key3", "operation": "write"]] as [String: Any]]))
        MobileCore.dispatch(event: Event(name: "consequence event", type: "com.adobe.eventType.rulesEngine", source: "com.adobe.eventSource.responseContent", data: ["triggeredconsequence": ["type": "csp", "detail": ["value": "value1", "operation": "delete"]] as [String: Any]]))
        usleep(1000)

        XCTAssertEqual(1, MonitorExtension.sharedStateChanged)
    }

    func testDataMigration() throws {
        // Given
        let json = """
        {
          "d" : {
            "a2" : "yy",
            "a1" : "xx"
          },
          "b" : 123,
          "c" : [
            1,
            2
          ],
          "a" : "aaa"
        }
        """
        UserDefaults.standard.set(json, forKey: "Adobe.ADBUserProfile.user_profile")
        let expectation = self.expectation(description: "register UserProfile extension")

        MobileCore.registerExtensions([UserProfile.self, MonitorExtension.self]) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2)
        // When
        let expectGet = self.expectation(description: "getUserAttributes()")
        UserProfile.getUserAttributes(attributeNames: []) {
            _, error in
            expectGet.fulfill()
            XCTAssertEqual(AEPError.none, error)
            let storedAttributes = self.getAttributesInDatastore()
            XCTAssertEqual("aaa", storedAttributes?["a"] as? String)
            XCTAssertEqual(123, storedAttributes?["b"] as? Int)
            XCTAssertEqual([1, 2], storedAttributes?["c"] as? [Int])
            XCTAssertEqual(["a1": "xx", "a2": "yy"], storedAttributes?["d"] as? [String: String])
            XCTAssertNil(UserDefaults.standard.object(forKey: "Adobe.ADBUserProfile.user_profile"))
        }

        // Then
        waitForExpectations(timeout: 2)
    }
}

@objc(MonitorExtension)
public class MonitorExtension: NSObject, Extension {
    public static var instance: MonitorExtension?

    public static var sharedStateChanged = 0

    public static var profileResponseEventCounts = 0

    public var name: String = "MonitorExtension"

    public var friendlyName: String = "Monitor Extension"

    public static var extensionVersion: String = "0.0.1"

    public var metadata: [String: String]?

    public var runtime: ExtensionRuntime

    public static var profileSharedStateReceiver: ((Event) -> Void)?

    public static var profileResponseEventReceiver: (([String: String]) -> Void)?

    public func onRegistered() {
        MonitorExtension.instance = self
        registerListener(type: "com.adobe.eventType.hub", source: "com.adobe.eventSource.sharedState") {
            event in
            if let owner = event.data?["stateowner"] as? String, owner == "com.adobe.module.userProfile" {
                MonitorExtension.sharedStateChanged += 1
                if let receiver = MonitorExtension.profileSharedStateReceiver {
                    receiver(event)
                }
            }
        }
        registerListener(type: "com.adobe.eventType.userProfile", source: "com.adobe.eventSource.responseProfile") {
            event in
            MonitorExtension.profileResponseEventCounts += 1
            if let data = event.data?["userprofilegetattributes"] as? [String: String] {
                if let receiver = MonitorExtension.profileResponseEventReceiver {
                    receiver(data)
                }
            }
        }
    }

    public func onUnregistered() {}

    public var userProfileSharedStateData: [String: Any]? {
        getSharedState(extensionName: "com.adobe.module.userProfile", event: nil)?.value
    }

    public func readyForEvent(_: Event) -> Bool {
        true
    }

    public required init(runtime: ExtensionRuntime) {
        self.runtime = runtime
        super.init()
    }
}
