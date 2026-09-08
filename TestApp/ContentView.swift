/*
Copyright 2024 Adobe. All rights reserved.
This file is licensed to you under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License. You may obtain a copy
of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under
the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
OF ANY KIND, either express or implied. See the License for the specific language
governing permissions and limitations under the License.
*/

import SwiftUI
import AEPCore
import AEPUserProfile

public struct CustomButtonStyle: ButtonStyle {

    public func makeBody(configuration: Self.Configuration) -> some View {
        return configuration.label
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .background(Color.gray)
            .foregroundColor(.white)
            .opacity(configuration.isPressed ? 0.7 : 1)
            .font(.caption)
            .cornerRadius(5)
    }
}

struct ContentView: View {
    @State private var appID: String = ""
    @State private var profileKey: String = ""
    @State private var profileValue: String = ""
    @State private var profileResult: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Group {
                TextField("AppID", text: $appID)
                    .padding()
                    .multilineTextAlignment(.center)
                    .border(Color.gray)
                    .autocapitalization(.none)
                Button(action: {
                    MobileCore.configureWith(appId: appID)
                }) {
                    Text("ConfigureWithAppID")
                }.buttonStyle(CustomButtonStyle())
                    .disabled(appID.isEmpty)
                
            }
            
            Group {
                TextField("Profile Key",text: $profileKey)
                    .padding()
                    .multilineTextAlignment(.center)
                    .border(Color.gray)
                    .autocapitalization(.none)
                
                TextField("Profile Value",text: $profileValue)
                    .padding()
                    .multilineTextAlignment(.center)
                    .border(Color.gray)
                    .autocapitalization(.none)
                                    
                Button(action: {
                    updateProfileAttributes()
                }) {
                    Text("Update")
                }.buttonStyle(CustomButtonStyle()).disabled(profileKey.isEmpty)
                
                Button(action: {
                    removeProfileAttributes()
                }) {
                    Text("Remove")
                }.buttonStyle(CustomButtonStyle())
                    .disabled(profileKey.isEmpty)
                
                Button(action: {
                    getProfileAttributes()
                }) {
                    Text("Get")
                }.buttonStyle(CustomButtonStyle())
                    .disabled(profileKey.isEmpty)
                
                Button(action: {
                    // To test this, configure a rule in your launch property that triggers a profile update for the following condition: a trackAction event with the action type 'trigger_update_profile'.
                    MobileCore.track(action: "trigger_update_profile", data: nil)
                }) {
                    Text("Trigger Rule (Update Profile)")
                }.buttonStyle(CustomButtonStyle())
                
                Text(profileResult)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
    }
    
    func updateProfileAttributes() {
        UserProfile.updateUserAttributes(attributeDict: [profileKey: profileValue])
        profileResult = "Profile attribute updated for `\(profileKey)`"
    }
    
    func removeProfileAttributes() {
        UserProfile.removeUserAttributes(attributeNames: [profileKey])
        profileResult = "Profile attribute removed for `\(profileKey)`"
    }

    private func getProfileAttributes() {
            UserProfile.getUserAttributes(attributeNames: [profileKey]) { attributes, error in
                if error != .none {
                    profileResult = "Error \(error) fetching profile attribute for `\(profileKey)`"
                } else {
                    if let attribute = attributes?[profileKey] as? String {
                        profileResult = "Profile attribute for `\(profileKey)` is   `\(attribute)`"
                    } else {
                        profileResult = "No attribute found for `\(profileKey)`"
                    }
                }
            }
        }
}

#Preview {
    ContentView()
}
