# CtrlpanelCore

Core library to build a client that interacts with the Ctrlpanel API

## Hacking

The Xcode project is generated automatically from `project.yml` using [XcodeGen](https://github.com/yonaskolb/XcodeGen). It's only checked in because Carthage needs it, do not edit it manually.

```sh
$ mint run yonaskolb/xcodegen
💾  Saved project to JSBridge.xcodeproj
```

The `JSSource.swift` file is generated automatically from `index.js` by [webpack](https://webpack.js.org). It's only checked in because SwiftPM/Carthage needs it, do not edit it manually.
