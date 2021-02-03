# UserProfile API Usage

This document details all the APIs provided by UserProfile, along with sample code snippets on how to properly use the APIs.

For more in-depth information about the UserProfile extension, visit the [SDK documentation on UserProfile](https://aep-sdks.gitbook.io/docs/using-mobile-extensions/profile).

## API Usage

##### Update user attributes:

###### Swift

```swift
UserProfile.updateUserAttributes(attributeDict: ["username": "Will Smith", "usertype": "Actor"])
```

###### Objective-C

```objective-c
NSMutableDictionary *profileMap = [NSMutableDictionary dictionary];
[profileMap setObject:@"username" forKey:@"will_smith"];
[profileMap setObject:@"usertype" forKey:@"Actor"];
[AEPMobileUserProfile updateUserAttributesWithAttributeDict:profileMap];
```

##### Remove user attributes:

###### Swift

```swift
UserProfile.removeUserAttributes(attributeNames: ["itemsAddedToCart"])
```

###### Objective-C

```objective-c
[AEPMobileUserProfile removeUserAttributesWithAttributeNames:@[@"username", @"usertype"]];
```

##### Get user attributes:

###### Swift

```swift
UserProfile.getUserAttributes(attributeNames: ["itemsAddedToCart"]) {
  attributes, error in
  // your customized code
}
```

###### Objective-C

```objective-c
[AEPMobileUserProfile getUserAttributesWithAttributeNames:@[@"username", @"usertype"] completion:^(NSDictionary* dict, NSError* error){
    // your customized code
    }];
```

