## 1.7.2

* - Fixes `ExceptionHandler` loop issue.

## 1.7.1

* Update native android module to latest.

* Fix problem with FirebaseMessaging 20.1.0

## 1.7.0

* Update native android module to latest

## 1.0.2

* Minor bug fixes

## 1.0.1

* Fix problem with AndroidX projects.

* Changed example package name.

## 1.0.0

* Release ready version.

* New listener API for notification callbacks.

* Removed extra files and APIs.

* Remove extra Fcm service. Firebase and other services can now be added and supported natively.

* Minor improvements and bug fixes.

**Note**: Callbacks will be passed when flutter is running. So when the app is closed, notifications will not call the callback methods (They actually will, but the flutter doesn't get it).