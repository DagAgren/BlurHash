import Foundation

public struct BlurHash {
	public let components: [[(Float, Float, Float)]]

	public var numberOfHorizontalComponents: Int { return components.first!.count }
	public var numberOfVerticalComponents: Int { return components.count }

	public init(components: [[(Float, Float, Float)]]) {
		self.components = components
	}
}
