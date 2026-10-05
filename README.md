# hoopooh-mlkit-swiftpm

Google ML Kit **face detection** for iOS as a Swift package, so the hoopooh app
can use ML Kit without CocoaPods.

## Why this exists

ML Kit is only published as CocoaPods. The app builds Firebase through Swift
Package Manager, and the ML Kit pods bring their own copies of GoogleUtilities,
GoogleDataTransport, FBLPromises and nanopb. iOS then loads 31 Google classes
twice ("Class … is implemented in both"). As a Swift package, ML Kit shares
Firebase's single copy of each.

It is consumed by
[`hoopooh-mlkit-flutter`](https://github.com/hoopoohEd/hoopooh-mlkit-flutter),
the Flutter plugins, which come from upstream PR
[flutter-ml/google_ml_kit_flutter#890](https://github.com/flutter-ml/google_ml_kit_flutter/pull/890).

## Provenance

Trimmed from
[`mdata-group/google-mlkit-swiftpm`](https://github.com/mdata-group/google-mlkit-swiftpm)
at tag `9.0.0-simfix2` (commit `9f25322`), itself a fork of
[`d-date/google-mlkit-swiftpm`](https://github.com/d-date/google-mlkit-swiftpm).

Changes from upstream:
- Only the targets face detection needs: MLImage, MLKitCommon, MLKitVision,
  MLKitFaceDetection, GoogleToolboxForMac, plus the two source targets.
  - Xcode downloads every binary a package declares: about 38 MB here,
    about 680 MB for the full upstream.
- A new `MLKitVision` product for `google_mlkit_commons`. Upstream has no such
  product, so the plugin linked barcode scanning just to reach MLKitVision.
- The binary URLs point at this repo's releases.
- `Sources/` is unchanged.
- From `9.0.0-hoopooh.2`, `MLKitFaceDetection.xcframework.zip` no longer
  contains `GoogleMVFaceDetectorResources.bundle` (the face models). Nothing
  else in it changed. See "The face models" below.

Four zips are the upstream `9.0.0-simfix2` release assets, unchanged, with
upstream's checksums. The face-detection zip is the upstream one minus the
model bundle.

## The face models: the app must ship them

ML Kit looks for `GoogleMVFaceDetectorResources.bundle` only at the top level
of the app bundle (`[NSBundle mainBundle]`, or `[NSBundle bundleForClass:]`,
which is the app too because ML Kit links statically). CocoaPods copied it
there. Swift Package Manager cannot place a resource there, and left inside the
framework ML Kit never finds it: detection then silently returns **no faces**.

So the consuming app ships the bundle as one of its own resources. hoopooh
keeps Google's copy in `ios/Runner/GoogleMVFaceDetectorResources.bundle`, added
to the Runner target's Copy Bundle Resources. It comes from
`https://dl.google.com/dl/cpdc/f06945444b6acdf3/MLKitFaceDetection-8.0.0.tar.gz`
(`Resources/GoogleMVFaceDetectorResources`). Update it whenever ML Kit is updated.

## What was verified (Oct 2026)

Each device (`ios-arm64`) slice was compared with Google's own pods from
`dl.google.com`, the URLs in the CocoaPods trunk specs:

| Binary | Result |
|---|---|
| MLKitCommon 14.0.0 | byte-identical |
| MLKitVision 10.0.0 | byte-identical |
| MLImage 1.0.0-beta8 | byte-identical |
| MLKitFaceDetection 8.0.0 | code and symbols identical. Two packaging changes: a 7-byte header edit (an empty `LC_DATA_IN_CODE` replaced by `LC_VERSION_MIN_IPHONEOS 15.5`, so the linker knows the platform), and the object wrapped in a static archive |
| GoogleToolboxForMac | **not verifiable**: Google ships it as source only, and this binary was built upstream |

The simulator slices are relabelled arm64 builds, so they run on Apple Silicon
simulators. `Sources/MLKitAbseilStubs` is compiled only for the arm64 simulator
(`#if TARGET_OS_SIMULATOR && defined(__arm64__)`) and is empty on device.

## Publishing

1. Push this repo, then create the tag and a GitHub release named after the
   version in `releaseURL` in `Package.swift` (currently `9.0.0-hoopooh.2`).
   Every release needs all five zips: the URLs point at a single release.
2. Upload the five files from `release-assets/` (git-ignored) to that release,
   under these exact names:
   `MLImage.xcframework.zip`, `MLKitCommon.xcframework.zip`,
   `MLKitVision.xcframework.zip`, `MLKitFaceDetection.xcframework.zip`,
   `GoogleToolboxForMac.xcframework.zip`.
3. The release must stay public, or every build fails to download the binaries.

## Updating

- **Firebase bumps:** the shared Google libraries are pinned `exact`, as upstream
  pins them. A Firebase release whose minimums move past these pins will fail
  to resolve: bump the pins here, tag a new version, and update the plugin repo.
- **ML Kit updates:** take new zips from upstream (or rebuild them), verify the
  device slices as above, update the checksums
  (`swift package compute-checksum <zip>`), and release under a new tag.

## Licences

The source in this repo is Apache-2.0 (see `LICENSE`, from upstream). The ML
Kit binaries are Google's and remain under the
[ML Kit terms](https://developers.google.com/ml-kit/terms).
