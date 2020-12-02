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
@testable import AEPUserProfile
import XCTest

class UserProfileTests: XCTestCase {
    private var theExpectation: XCTestExpectation?

    override func setUpWithError() throws {
        UserDefaults.standard.removeObject(forKey: "Adobe.com.adobe.module.userProfile.attributes")
    }

    override func tearDownWithError() throws {}

    func testHandlingExtensionOnRegisteredEmpty() throws {
        let runtime = TestableExtensionRuntime()
        let profile = UserProfile(runtime: runtime)
        profile.onRegistered()
        XCTAssertEqual(3, runtime.listeners.count)
        XCTAssert(runtime.listeners["\(EventType.userProfile)-\(EventSource.requestProfile)"] != nil)
        XCTAssert(runtime.listeners["\(EventType.userProfile)-\(EventSource.requestReset)"] != nil)
        XCTAssert(runtime.listeners["\(EventType.rulesEngine)-\(EventSource.responseContent)"] != nil)
        XCTAssertEqual(1, runtime.createdSharedStates.count)
        guard let profileData = runtime.createdSharedStates[0]?["userprofiledata"] as? [String: Any] else {
            XCTFail()
            return
        }
        XCTAssertEqual(0, profileData.count)
        UserDefaults.standard.set(["key1": "value1", "key2": "value2"], forKey: "Adobe.com.adobe.module.userProfile.attributes")
    }

    func testHandlingExtensionOnRegisteredWithStoredAttributes() throws {
        UserDefaults.standard.set(["key1": "value1", "key2": "value2"], forKey: "Adobe.com.adobe.module.userProfile.attributes")
        let runtime = TestableExtensionRuntime()
        let profile = UserProfile(runtime: runtime)
        profile.onRegistered()
        XCTAssertEqual(3, runtime.listeners.count)
        XCTAssert(runtime.listeners["\(EventType.userProfile)-\(EventSource.requestProfile)"] != nil)
        XCTAssert(runtime.listeners["\(EventType.userProfile)-\(EventSource.requestReset)"] != nil)
        XCTAssert(runtime.listeners["\(EventType.rulesEngine)-\(EventSource.responseContent)"] != nil)
        XCTAssertEqual(1, runtime.createdSharedStates.count)
        guard let profileData = runtime.createdSharedStates[0]?["userprofiledata"] as? [String: String] else {
            XCTFail()
            return
        }
        XCTAssertEqual(2, profileData.count)
        XCTAssertEqual(["key1": "value1", "key2": "value2"], profileData)
    }

    func testHandleRulesEngineResponseForWrite() throws {
        let runtime = TestableExtensionRuntime()
        let profile = UserProfile(runtime: runtime)
        profile.onRegistered()
        guard let handleRulesEngineResponse = runtime.listeners["\(EventType.rulesEngine)-\(EventSource.responseContent)"] else {
            XCTFail()
            return
        }
        let event = Event(name: "consequence event", type: "com.adobe.eventType.rulesEngine", source: "com.adobe.eventSource.responseContent", data: ["triggeredconsequence": ["type": "csp", "detail": ["key": "key3", "value": "value3", "operation": "write"]]])
        handleRulesEngineResponse(event)
        guard let storedAttributes = UserDefaults.standard.object(forKey: "Adobe.com.adobe.module.userProfile.attributes") as? [String: String] else {
            XCTFail()
            return
        }
        XCTAssertEqual(1, storedAttributes.count)
        XCTAssertEqual(["key3": "value3"], storedAttributes)
        XCTAssertEqual(2, runtime.createdSharedStates.count)
        guard let attributes = runtime.createdSharedStates[1]?["userprofiledata"] as? [String: String] else {
            XCTFail()
            return
        }
        XCTAssertEqual(["key3": "value3"], attributes)
    }

    func testHandleRulesEngineResponseForWriteWithEmptyStringValue() throws {
        UserDefaults.standard.set(["key1": "value1", "key2": "value2"], forKey: "Adobe.com.adobe.module.userProfile.attributes")
        let runtime = TestableExtensionRuntime()
        let profile = UserProfile(runtime: runtime)
        profile.onRegistered()
        XCTAssertEqual(1, runtime.createdSharedStates.count)
        runtime.createdSharedStates.removeAll()
        guard let handleRulesEngineResponse = runtime.listeners["\(EventType.rulesEngine)-\(EventSource.responseContent)"] else {
            XCTFail()
            return
        }
        let event = Event(name: "consequence event", type: "com.adobe.eventType.rulesEngine", source: "com.adobe.eventSource.responseContent", data: ["triggeredconsequence": ["type": "csp", "detail": ["key": "key1", "value": "", "operation": "write"]]])
        handleRulesEngineResponse(event)
        guard let storedAttributes = UserDefaults.standard.object(forKey: "Adobe.com.adobe.module.userProfile.attributes") as? [String: String] else {
            XCTFail()
            return
        }
        XCTAssertEqual(1, storedAttributes.count)
        XCTAssertEqual(["key2": "value2"], storedAttributes)
        XCTAssertEqual(1, runtime.createdSharedStates.count)
        guard let attributes = runtime.createdSharedStates[0]?["userprofiledata"] as? [String: String] else {
            XCTFail()
            return
        }
        XCTAssertEqual(["key2": "value2"], attributes)
    }

    func testHandleRulesEngineResponseForDelete() throws {
        UserDefaults.standard.set(["key1": "value1", "key2": "value2"], forKey: "Adobe.com.adobe.module.userProfile.attributes")
        let runtime = TestableExtensionRuntime()
        let profile = UserProfile(runtime: runtime)
        profile.onRegistered()
        guard let handleRulesEngineResponse = runtime.listeners["\(EventType.rulesEngine)-\(EventSource.responseContent)"] else {
            XCTFail()
            return
        }
        let event = Event(name: "consequence event", type: "com.adobe.eventType.rulesEngine", source: "com.adobe.eventSource.responseContent", data: ["triggeredconsequence": ["type": "csp", "detail": ["key": "key1", "operation": "delete"]]])
        handleRulesEngineResponse(event)
        guard let storedAttributes = UserDefaults.standard.object(forKey: "Adobe.com.adobe.module.userProfile.attributes") as? [String: String] else {
            XCTFail()
            return
        }
        XCTAssertEqual(1, storedAttributes.count)
        XCTAssertEqual(["key2": "value2"], storedAttributes)
        XCTAssertEqual(2, runtime.createdSharedStates.count)
        guard let attributes = runtime.createdSharedStates[1]?["userprofiledata"] as? [String: String] else {
            XCTFail()
            return
        }
        XCTAssertEqual(["key2": "value2"], attributes)
    }

    func testHandleRulesEngineResponseBadFormat() throws {
        UserDefaults.standard.set(["key1": "value1"], forKey: "Adobe.com.adobe.module.userProfile.attributes")
        let runtime = TestableExtensionRuntime()
        let profile = UserProfile(runtime: runtime)
        profile.onRegistered()
        XCTAssertEqual(1, runtime.createdSharedStates.count)
        runtime.createdSharedStates.removeAll()

        guard let handleRulesEngineResponse = runtime.listeners["\(EventType.rulesEngine)-\(EventSource.responseContent)"] else {
            XCTFail()
            return
        }
        let consequenceEventWithoutType = Event(name: "consequence event", type: "com.adobe.eventType.rulesEngine", source: "com.adobe.eventSource.responseContent", data: ["triggeredconsequence": ["detail": ["key": "key3", "value": "value3", "operation": "write"]]])
        handleRulesEngineResponse(consequenceEventWithoutType)
        guard let storedAttributes = UserDefaults.standard.object(forKey: "Adobe.com.adobe.module.userProfile.attributes") as? [String: String] else {
            XCTFail()
            return
        }
        XCTAssertEqual(1, storedAttributes.count)
        XCTAssertEqual(0, runtime.createdSharedStates.count)

        let consequenceEventWriteWithoutKey = Event(name: "consequence event", type: "com.adobe.eventType.rulesEngine", source: "com.adobe.eventSource.responseContent", data: ["triggeredconsequence": ["type": "csp", "detail": ["value": "value3", "operation": "write"]]])
        handleRulesEngineResponse(consequenceEventWriteWithoutKey)
        XCTAssertEqual(0, runtime.createdSharedStates.count)

        let consequenceEventDeleteWithoutKey = Event(name: "consequence event", type: "com.adobe.eventType.rulesEngine", source: "com.adobe.eventSource.responseContent", data: ["triggeredconsequence": ["type": "csp", "detail": ["operation": "delete"]]])
        handleRulesEngineResponse(consequenceEventDeleteWithoutKey)
        XCTAssertEqual(0, runtime.createdSharedStates.count)
    }

    func testUpdateAttributes() throws {
        UserDefaults.standard.set(["key1": "value1", "key2": "value2"], forKey: "Adobe.com.adobe.module.userProfile.attributes")
        let runtime = TestableExtensionRuntime()
        let profile = UserProfile(runtime: runtime)
        profile.onRegistered()
        XCTAssertEqual(1, runtime.createdSharedStates.count)
        runtime.createdSharedStates.removeAll()

        guard let handleRequestProfile = runtime.listeners["\(EventType.userProfile)-\(EventSource.requestProfile)"] else {
            XCTFail()
            return
        }
        let event = Event(name: "UserProfileUpdate", type: "com.adobe.eventType.userProfile", source: "com.adobe.eventSource.requestProfile", data: ["userprofileupdatekey": ["key1": "valuex", "key2": ""]])
        XCTAssert(event.isUpdateAttributesEvent)
        handleRequestProfile(event)
        guard let storedAttributes = UserDefaults.standard.object(forKey: "Adobe.com.adobe.module.userProfile.attributes") as? [String: String] else {
            XCTFail()
            return
        }
        XCTAssertEqual(1, storedAttributes.count)
        XCTAssertEqual(["key1": "valuex"], storedAttributes)
        XCTAssertEqual(1, runtime.createdSharedStates.count)
        guard let attributes = runtime.createdSharedStates[0]?["userprofiledata"] as? [String: String] else {
            XCTFail()
            return
        }
        XCTAssertEqual(["key1": "valuex"], attributes)
    }

    func testUpdateAttributesWithEmptyStringValue() throws {
        UserDefaults.standard.set(["key1": "value1"], forKey: "Adobe.com.adobe.module.userProfile.attributes")
        let runtime = TestableExtensionRuntime()
        let profile = UserProfile(runtime: runtime)
        profile.onRegistered()
        XCTAssertEqual(1, runtime.createdSharedStates.count)
        runtime.createdSharedStates.removeAll()

        guard let handleRequestProfile = runtime.listeners["\(EventType.userProfile)-\(EventSource.requestProfile)"] else {
            XCTFail()
            return
        }
        let event = Event(name: "UserProfileUpdate", type: "com.adobe.eventType.userProfile", source: "com.adobe.eventSource.requestProfile", data: ["userprofileupdatekey": ["key2": "value2", "key3": "value3"]])
        XCTAssert(event.isUpdateAttributesEvent)
        handleRequestProfile(event)
        guard let storedAttributes = UserDefaults.standard.object(forKey: "Adobe.com.adobe.module.userProfile.attributes") as? [String: String] else {
            XCTFail()
            return
        }
        XCTAssertEqual(3, storedAttributes.count)
        XCTAssertEqual(["key1": "value1", "key2": "value2", "key3": "value3"], storedAttributes)
        XCTAssertEqual(1, runtime.createdSharedStates.count)
        guard let attributes = runtime.createdSharedStates[0]?["userprofiledata"] as? [String: String] else {
            XCTFail()
            return
        }
        XCTAssertEqual(["key1": "value1", "key2": "value2", "key3": "value3"], attributes)
    }

    func testUpdateAttributesWithMultipleValueTypes() throws {
        UserDefaults.standard.set(["k_string": "value1", "k_int": 2, "k_bool": true, "k_double": 2.1], forKey: "Adobe.com.adobe.module.userProfile.attributes")
        let runtime = TestableExtensionRuntime()
        let profile = UserProfile(runtime: runtime)
        profile.onRegistered()
        XCTAssertEqual(1, runtime.createdSharedStates.count)
        runtime.createdSharedStates.removeAll()

        guard let handleRequestProfile = runtime.listeners["\(EventType.userProfile)-\(EventSource.requestProfile)"] else {
            XCTFail()
            return
        }
        let event = Event(name: "UserProfileUpdate", type: "com.adobe.eventType.userProfile", source: "com.adobe.eventSource.requestProfile", data: ["userprofileupdatekey": ["k_int": 3]])
        XCTAssert(event.isUpdateAttributesEvent)
        handleRequestProfile(event)
        guard let storedAttributes = UserDefaults.standard.object(forKey: "Adobe.com.adobe.module.userProfile.attributes") as? [String: Any] else {
            XCTFail()
            return
        }
        XCTAssertEqual(4, storedAttributes.count)

        XCTAssertEqual("value1", storedAttributes["k_string"] as? String)
        XCTAssertEqual(3, storedAttributes["k_int"] as? Int)
        XCTAssertEqual(true, storedAttributes["k_bool"] as? Bool)
        XCTAssertEqual(2.1, storedAttributes["k_double"] as? Double)
        XCTAssertEqual(1, runtime.createdSharedStates.count)
        guard let attributes = runtime.createdSharedStates[0]?["userprofiledata"] as? [String: Any] else {
            XCTFail()
            return
        }
        print(attributes)
        XCTAssertEqual("value1", attributes["k_string"] as? String)
        XCTAssertEqual(3, attributes["k_int"] as? Int)
        XCTAssertEqual(true, attributes["k_bool"] as? Bool)
        XCTAssertEqual(2.1, attributes["k_double"] as? Double)
    }

    func testUpdateAttributesWithUnacceptedValue() throws {
        UserDefaults.standard.set(["key1": "value1", "key2": "value2"], forKey: "Adobe.com.adobe.module.userProfile.attributes")
        let runtime = TestableExtensionRuntime()
        let profile = UserProfile(runtime: runtime)
        profile.onRegistered()
        XCTAssertEqual(1, runtime.createdSharedStates.count)
        runtime.createdSharedStates.removeAll()

        guard let handleRequestProfile = runtime.listeners["\(EventType.userProfile)-\(EventSource.requestProfile)"] else {
            XCTFail()
            return
        }
        let event = Event(name: "UserProfileUpdate", type: "com.adobe.eventType.userProfile", source: "com.adobe.eventSource.requestProfile", data: ["userprofileupdatekey": ["key1": "valuex", "key2": UserProfile(runtime: TestableExtensionRuntime())]])
        XCTAssert(event.isUpdateAttributesEvent)

        handleRequestProfile(event)

        guard let storedAttributes = UserDefaults.standard.object(forKey: "Adobe.com.adobe.module.userProfile.attributes") as? [String: String] else {
            XCTFail()
            return
        }
        XCTAssertEqual(2, storedAttributes.count)
        XCTAssertEqual(["key1": "value1", "key2": "value2"], storedAttributes)
        XCTAssertEqual(0, runtime.createdSharedStates.count)
    }

    func testGetAttributes() throws {
        UserDefaults.standard.set(["key1": "value1", "key2": "value2"], forKey: "Adobe.com.adobe.module.userProfile.attributes")
        let runtime = TestableExtensionRuntime()
        let profile = UserProfile(runtime: runtime)
        profile.onRegistered()
        XCTAssertEqual(1, runtime.createdSharedStates.count)
        runtime.createdSharedStates.removeAll()
        guard let handleRequestProfile = runtime.listeners["\(EventType.userProfile)-\(EventSource.requestProfile)"] else {
            XCTFail()
            return
        }
        let event = Event(name: "getUserAttributes", type: "com.adobe.eventType.userProfile", source: "com.adobe.eventSource.requestProfile", data: ["userprofilegetattributes": ["key1", "key2", "key3"]])
        XCTAssert(event.isGetAttributesEvent)
        handleRequestProfile(event)
        XCTAssertEqual(0, runtime.createdSharedStates.count)
        XCTAssertEqual(1, runtime.dispatchedEvents.count)

        XCTAssertEqual("getUserAttributes", runtime.dispatchedEvents[0].name)
        XCTAssertEqual("com.adobe.eventType.userProfile", runtime.dispatchedEvents[0].type)
        XCTAssertEqual("com.adobe.eventSource.responseProfile", runtime.dispatchedEvents[0].source)
        XCTAssertEqual(["key1": "value1", "key2": "value2"], runtime.dispatchedEvents[0].data?["userprofilegetattributes"] as? [String: String])
        XCTAssertEqual(event.id, runtime.dispatchedEvents[0].responseID)
    }

    func testGetAttributesEmptyKey() throws {
        UserDefaults.standard.set(["key1": "value1", "key2": "value2"], forKey: "Adobe.com.adobe.module.userProfile.attributes")
        let runtime = TestableExtensionRuntime()
        let profile = UserProfile(runtime: runtime)
        profile.onRegistered()
        XCTAssertEqual(1, runtime.createdSharedStates.count)
        runtime.createdSharedStates.removeAll()
        guard let handleRequestProfile = runtime.listeners["\(EventType.userProfile)-\(EventSource.requestProfile)"] else {
            XCTFail()
            return
        }
        let event = Event(name: "getUserAttributes", type: "com.adobe.eventType.userProfile", source: "com.adobe.eventSource.requestProfile", data: ["userprofilegetattributes": []])
        XCTAssert(event.isGetAttributesEvent)
        handleRequestProfile(event)
        XCTAssertEqual(0, runtime.createdSharedStates.count)
        XCTAssertEqual(1, runtime.dispatchedEvents.count)
    }

    func testRemoveAttributes() throws {
        UserDefaults.standard.set(["key1": "value1", "key2": "value2"], forKey: "Adobe.com.adobe.module.userProfile.attributes")
        let runtime = TestableExtensionRuntime()
        let profile = UserProfile(runtime: runtime)
        profile.onRegistered()
        XCTAssertEqual(1, runtime.createdSharedStates.count)
        runtime.createdSharedStates.removeAll()

        guard let removeAttributes = runtime.listeners["\(EventType.userProfile)-\(EventSource.requestReset)"] else {
            XCTFail()
            return
        }
        let event = Event(name: "RemoveUserProfiles", type: "com.adobe.eventType.userProfile", source: "com.adobe.eventSource.requestReset", data: ["userprofileremovekeys": ["key2", "key3"]])
        removeAttributes(event)
        guard let storedAttributes = UserDefaults.standard.object(forKey: "Adobe.com.adobe.module.userProfile.attributes") as? [String: String] else {
            XCTFail()
            return
        }
        XCTAssertEqual(1, storedAttributes.count)
        XCTAssertEqual(["key1": "value1"], storedAttributes)
        XCTAssertEqual(1, runtime.createdSharedStates.count)
        guard let attributes = runtime.createdSharedStates[0]?["userprofiledata"] as? [String: String] else {
            XCTFail()
            return
        }
        XCTAssertEqual(["key1": "value1"], attributes)
    }

    func testRemoveAttributesKeyNotExist() throws {
        UserDefaults.standard.set(["key1": "value1", "key2": "value2"], forKey: "Adobe.com.adobe.module.userProfile.attributes")
        let runtime = TestableExtensionRuntime()
        let profile = UserProfile(runtime: runtime)
        profile.onRegistered()
        XCTAssertEqual(1, runtime.createdSharedStates.count)
        runtime.createdSharedStates.removeAll()

        guard let removeAttributes = runtime.listeners["\(EventType.userProfile)-\(EventSource.requestReset)"] else {
            XCTFail()
            return
        }
        let event = Event(name: "RemoveUserProfiles", type: "com.adobe.eventType.userProfile", source: "com.adobe.eventSource.requestReset", data: ["userprofileremovekeys": ["key3"]])
        removeAttributes(event)
        guard let storedAttributes = UserDefaults.standard.object(forKey: "Adobe.com.adobe.module.userProfile.attributes") as? [String: String] else {
            XCTFail()
            return
        }
        XCTAssertEqual(2, storedAttributes.count)
        XCTAssertEqual(["key1": "value1", "key2": "value2"], storedAttributes)
        XCTAssertEqual(0, runtime.createdSharedStates.count)
    }

    func testV5MigratorLoadExistingAttributes() throws {
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
        guard let attributes = UserProfileV5Migrator.existingAttributes() else {
            XCTFail()
            return
        }
        XCTAssertEqual("aaa", attributes["a"] as? String)
        XCTAssertEqual(123, attributes["b"] as? Int)
        XCTAssertEqual([1, 2], attributes["c"] as? [Int])
        XCTAssertEqual(["a1": "xx", "a2": "yy"], attributes["d"] as? [String: String])
    }

    func testV5MigratorLoadExistingAttributesWithIncorrectFormat() throws {
        let json = """
        {
          "d"
        }
        """
        UserDefaults.standard.set(json, forKey: "Adobe.ADBUserProfile.user_profile")
        guard let _ = UserProfileV5Migrator.existingAttributes() else {
            return
        }
        XCTFail()
    }
}

public class TestableExtensionRuntime: ExtensionRuntime {
    public var listeners: [String: EventListener] = [:]
    public var createdSharedStates: [[String: Any]?] = []
    public var dispatchedEvents: [Event] = []

    public func unregisterExtension() {}

    public func registerListener(type: String, source: String, listener: @escaping EventListener) {
        listeners["\(type)-\(source)"] = listener
    }

    public func startEvents() {}

    public func stopEvents() {}

    public func dispatch(event: Event) {
        dispatchedEvents.append(event)
    }

    public func createSharedState(data: [String: Any], event _: Event?) {
        createdSharedStates += [data]
    }

    public func createPendingSharedState(event _: Event?) -> SharedStateResolver {
        return { _ in
            print()
        }
    }

    public func getSharedState(extensionName _: String, event _: Event?, barrier _: Bool) -> SharedStateResult? { return nil }
}
