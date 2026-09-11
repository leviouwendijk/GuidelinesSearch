// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "GuidelinesSearch",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "GuidelinesSearch",
            targets: [
                "GuidelinesSearch",
            ]
        ),
        .executable(
            name: "gsearchtest",
            targets: [
                "GuidelinesSearchTest",
            ]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/leviouwendijk/Guidelines.git",
            branch: "master"
        ),
        .package(
            url: "https://github.com/leviouwendijk/DSL.git",
            branch: "master"
        ),
        .package(
            url: "https://github.com/leviouwendijk/Fuzzy.git",
            branch: "master"
        ),
        .package(
            url: "https://github.com/leviouwendijk/Matching.git",
            branch: "master"
        ),
        .package(
            url: "https://github.com/leviouwendijk/Ranking.git",
            branch: "master"
        ),
    ],
    targets: [
        .target(
            name: "GuidelinesSearch",
            dependencies: [
                .product(
                    name: "Guidelines",
                    package: "Guidelines"
                ),
                .product(
                    name: "DSL",
                    package: "DSL"
                ),
                .product(
                    name: "Fuzzy",
                    package: "Fuzzy"
                ),
                .product(
                    name: "Matching",
                    package: "Matching"
                ),
                .product(
                    name: "Ranking",
                    package: "Ranking"
                ),
            ]
        ),
        .executableTarget(
            name: "GuidelinesSearchTest",
            dependencies: [
                "GuidelinesSearch",
                .product(
                    name: "Guidelines",
                    package: "Guidelines"
                ),
            ]
        ),
    ],
    swiftLanguageModes: [
        .v6,
    ]
)
