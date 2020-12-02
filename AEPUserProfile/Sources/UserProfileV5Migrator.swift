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
import AEPServices
import Foundation

enum UserProfileV5Migrator {
    static func existingAttributes() -> [String: Any]? {
        guard let json = UserDefaults.standard.object(forKey: UserProfileConstants.V5Migration.USER_PROFILE_KEY) as? String else {
            return nil
        }
        guard let jsonData = json.data(using: .utf8) else {
            Log.debug(label: UserProfile.LOG_TAG, "data migration - failed to load (json) user attributes from data storage")
            return nil
        }
        guard let attributes = try? JSONDecoder().decode([String: AnyCodable].self, from: jsonData) else {
            Log.debug(label: UserProfile.LOG_TAG, "data migration - failed to decode json string to a [String:Any] type")
            return nil
        }
        return attributes.asDictionary()
    }

    static func clearExistingAttributes() {
        UserDefaults.standard.removeObject(forKey: UserProfileConstants.V5Migration.USER_PROFILE_KEY)
    }
}
