# adyen_flutter

An Adyen Flutter plugin to support the Adyen API integration.

It exposes the `EncryptedCard` class's method `encryptToken` and `encryptCard`.

## Getting Started

This Plugin relies on the following Adyen SDK:
+ [Adyen iOS SDK](https://github.com/Adyen/adyen-ios)
    with the [Adyen Pod 2.7.2](https://cocoapods.org/pods/Adyen)
+ [Adyen Android SDK](https://github.com/Adyen/adyen-android)
    with the packages:
    - com.adyen.checkout:core:2.3.1
    - com.adyen.checkout:core-card:2.3.1


## Android

The Android version requires the following permission to be set:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

## iOS

The iOS version requires the ios hosting project to target iOS 10.3 or above.
This is a limitation of the iOS SDK.