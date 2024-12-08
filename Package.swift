// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "aoc24",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-parsing", from: "0.13.0"),
    ],
    targets: [
        .executableTarget(
            name: "aoc24",
            dependencies: [
                .product(name: "Parsing", package: "swift-parsing")
            ],
            path: "aoc24"
        )
    ]
) 