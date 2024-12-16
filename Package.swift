// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "BlurHashKit",
    platforms: [
       .iOS(.v13)
    ],
	products: [
		.library(name: "BlurHashKit", targets: ["BlurHashKit"]),
	],
	targets: [
		.target(
			name: "BlurHashKit",
			path: "Swift/BlurHashKit"
		),
	]
)
