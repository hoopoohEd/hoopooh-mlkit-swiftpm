// swift-tools-version: 5.9

// Google ML Kit face detection as a Swift package, trimmed from
// https://github.com/mdata-group/google-mlkit-swiftpm (tag 9.0.0-simfix2,
// commit 9f25322), which is a fork of d-date/google-mlkit-swiftpm.
//
// Only what face detection needs is declared, because Xcode downloads every
// binary target a package declares (the full upstream is ~680 MB per clean
// build). The binaries are the upstream 9.0.0-simfix2 zips, re-hosted as
// release assets of this repo. Four are unchanged (same checksums as upstream).
//
// MLKitFaceDetection.xcframework.zip is the upstream zip with
// GoogleMVFaceDetectorResources.bundle (the face models) removed from both
// slices; the binaries inside are untouched. ML Kit only looks for that bundle
// at the top level of the APP bundle ([NSBundle mainBundle] /
// [NSBundle bundleForClass:], which is the app because ML Kit links
// statically). Swift Package Manager cannot put a resource there, so the app
// must ship the bundle itself (hoopooh: ios/Runner/GoogleMVFaceDetectorResources.bundle).
// Left inside the framework it was dead weight (~10 MB) that ML Kit never found.
//
// The shared Google libraries are pinned exactly, as upstream does. Firebase's
// own ranges contain these versions, so Swift Package Manager resolves a single
// copy of each. Bumping Firebase may require bumping these pins.
//
// From 9.0.0-hoopooh.3, GoogleToolboxForMac is built from source instead of
// upstream's prebuilt GoogleToolboxForMac.xcframework. That binary was an
// unsigned dynamic framework, and GoogleToolboxForMac is on Apple's list of
// commonly used SDKs, so App Store Connect rejected the app (ITMS-91065:
// Missing signature). Built from source it links statically into the app and
// no framework ships. ML Kit only needs GTMLogger and the NSData+zlib category,
// so just those files are vendored (Sources/GoogleToolboxForMac, from
// google/google-toolbox-for-mac v6.0.1, Apache 2.0, unmodified). Depending on
// Google's package instead fails in Xcode: its header-only GTMDefines target
// produces no GTMDefines.o, which the link step still expects.

import PackageDescription

// The four ML Kit zips have not changed since 9.0.0-hoopooh.2, so they are
// still served from that release.
let releaseURL = "https://github.com/hoopoohEd/hoopooh-mlkit-swiftpm/releases/download/9.0.0-hoopooh.2"

let package = Package(
    name: "GoogleMLKitSwiftPM",
    platforms: [.iOS(.v15)],
    products: [
        // What google_mlkit_commons imports (MLKitCommon, MLKitVision). Upstream
        // has no such product, so the plugin used to pull in barcode scanning.
        .library(
            name: "MLKitVision",
            targets: ["MLImage", "MLKitVision", "Common"]
        ),
        .library(
            name: "MLKitFaceDetection",
            targets: ["MLKitFaceDetection", "MLImage", "MLKitVision", "Common"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/google/promises.git", exact: "2.4.0"),
        .package(url: "https://github.com/google/GoogleDataTransport.git", exact: "10.1.0"),
        .package(url: "https://github.com/google/GoogleUtilities.git", exact: "8.1.0"),
        .package(url: "https://github.com/google/gtm-session-fetcher.git", exact: "3.5.0"),
        .package(url: "https://github.com/firebase/nanopb.git", exact: "2.30910.0"),
    ],
    targets: [
        .binaryTarget(
            name: "MLImage",
            url: "\(releaseURL)/MLImage.xcframework.zip",
            checksum: "b36d7a463d9b92f2a26f81d60466807ad32daefc643ea6da4c0521fc6d9b12a3"
        ),
        .binaryTarget(
            name: "MLKitCommon",
            url: "\(releaseURL)/MLKitCommon.xcframework.zip",
            checksum: "c283013f4888a3bd298b6c64e78faf376a844944ab8e85568c92bc297d3e4a82"
        ),
        .binaryTarget(
            name: "MLKitVision",
            url: "\(releaseURL)/MLKitVision.xcframework.zip",
            checksum: "031bba088c27c5ef63df528e5df722fa9cc44011c14cc7f6415c60f2b419751a"
        ),
        .binaryTarget(
            name: "MLKitFaceDetection",
            url: "\(releaseURL)/MLKitFaceDetection.xcframework.zip",
            // Upstream minus the resources bundle (see top of file).
            checksum: "5358526ed489cefa5176dcc0a0ef288b79cadad40ac1a4a9141e83a0ba034d1f"
        ),
        // GTMLogger + GTMNSData+zlib from google-toolbox-for-mac (see top of file).
        .target(
            name: "GoogleToolboxForMac",
            resources: [.copy("Resources/PrivacyInfo.xcprivacy")],
            linkerSettings: [.linkedLibrary("z")]
        ),
        .target(
            name: "Common",
            dependencies: [
                "MLKitAbseilStubs",
                "MLKitCommon",
                "GoogleToolboxForMac",
                .product(name: "GULAppDelegateSwizzler", package: "GoogleUtilities"),
                .product(name: "GULEnvironment", package: "GoogleUtilities"),
                .product(name: "GULLogger", package: "GoogleUtilities"),
                .product(name: "GULMethodSwizzler", package: "GoogleUtilities"),
                .product(name: "GULNSData", package: "GoogleUtilities"),
                .product(name: "GULNetwork", package: "GoogleUtilities"),
                .product(name: "GULReachability", package: "GoogleUtilities"),
                .product(name: "GULUserDefaults", package: "GoogleUtilities"),
                .product(name: "GTMSessionFetcher", package: "gtm-session-fetcher"),
                .product(name: "GoogleDataTransport", package: "GoogleDataTransport"),
                .product(name: "nanopb", package: "nanopb"),
                .product(name: "FBLPromises", package: "promises"),
            ]
        ),
        // Simulator-only (the whole file is under TARGET_OS_SIMULATOR && arm64):
        // logging internals the re-targeted arm64 simulator slices reference.
        // Compiles to nothing on device.
        .target(
            name: "MLKitAbseilStubs",
            path: "Sources/MLKitAbseilStubs"
        ),
    ]
)
