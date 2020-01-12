# PushPole flutter

A plugin to use PushPole sdk in Flutter framework.

### Run the sample

Run: `git clone https://github.com/push-pole/flutter-sample.git`<br>
The go to example: `cd example`<br>
And run the example on a connected device: `flutter run`<br>

## Installation

Add the plugin to `pubspec.yaml`:

```yaml
dependencies:
  pushpole: ^version
```
<img src="https://img.shields.io/github/release/push-pole/pushpole-flutter"></img>

Then run `flutter packages get` to sync the libraries.

### Set up credentials

Go to https://console.push-pole.com , create an application with the same package name and get the manifest tag. Add the manifest tag in the `Application` tag. It should be something like this:

```xml
<meta-data android:name="com.pushpole.sdk.token"
           android:value="PUSHPOLE_12345678" />
```

### Add the code snippets

In your `main.dart`:

```dart
import 'package:pushpole/pushpole.dart';
```

```dart
PushPole.initialize();
```

## More Info
For more details, visit [HomePage docs](https://docs.push-pole.com/docs/flutter/)
