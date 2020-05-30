// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Beethoven",
    products: [
        .library(name: "Beethoven", targets: ["Beethoven"]),
    ],
    dependencies: [
      .package(url: "https://github.com/rhx/Pitchy.git", .branch("master")),
      .package(url: "https://github.com/Quick/Nimble.git", .branch("master")),
      .package(url: "https://github.com/Quick/Quick.git", .branch("master")),
    ],
    targets: [
        .target(name: "Beethoven", dependencies: ["Pitchy"]),
        .testTarget(name: "BeethovenTests", dependencies: ["Beethoven", "Quick", "Nimble"]),
    ]
)
