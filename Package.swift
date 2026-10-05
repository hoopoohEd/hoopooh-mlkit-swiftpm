// swift-tools-version: 5.9

// Google ML Kit face detection as a Swift package, trimmed from
// https://github.com/mdata-group/google-mlkit-swiftpm (tag 9.0.0-simfix2,
// commit 9f25322), which is a fork of d-date/google-mlkit-swiftpm.
//
// Only what face detection needs is declared, because Xcode downloads every
// binary target a package declares (the full upstream is ~680 MB per clean
// build). The binaries are the upstream 9.0.0-simfix2 zips, re-hosted unchanged
// as release assets of this repo; checksums are therefore identical upstream.
//
// The shared Google libraries are pinned exactly, as upstream does. Firebase's
// own ranges contain these versions, so Swift Package Manager resolves a single
// copy of each. Bumping Firebase may require bumping these pins.

import PackageDescription

let releaseURL = "https://github.com/OWNER_PLACEHOLDER/hoopooh-mlkit-swiftpm/releases/download/9.0.0-hoopooh.1"

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
            checksum: "f4aeacb2633c0cf727f2d37c033b17eb53598783c57f063ddf5c239121da3f77"
        ),
        .binaryTarget(
            name: "GoogleToolboxForMac",
            url: "\(releaseURL)/GoogleToolboxForMac.xcframework.zip",
            checksum: "0ffe7a585b36875b7eda993d1c1cdedeb55e5d0cafb66ddd45e5b341f658e0af"
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
