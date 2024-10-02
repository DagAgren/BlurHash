import Foundation
import SwiftUI

extension BlurHash {
	func transform(
		_ transform: ((Float, Float, Float)) -> (Float, Float, Float)
	) -> BlurHash {
		return .init(components: components.map { $0.map(transform) })
	}

	func transform(
		dc dcTransform: (((Float, Float, Float)) -> (Float, Float, Float))? = nil,
		ac acTransform: (((Float, Float, Float)) -> (Float, Float, Float))? = nil
	) -> BlurHash {
		return .init(components: components.enumerated().map { rowIndex, row in
			row.enumerated().map { columnIndex, component in
				if rowIndex == 0, columnIndex == 0 {
					return dcTransform?(component) ?? component
				} else {
					return acTransform?(component) ?? component
				}
			}
		})
	}

	func combine(
		with other: BlurHash,
		_ combine: ((Float, Float, Float), (Float, Float, Float)) -> (Float, Float, Float)
	) -> BlurHash {
		let numberOfVerticalComponents = max(numberOfVerticalComponents, other.numberOfVerticalComponents)
		let numberOfHorizontalComponents = max(numberOfHorizontalComponents, other.numberOfHorizontalComponents)
		return .init(components: zip(components.padded(to: numberOfVerticalComponents, with: []), other.components.padded(to: numberOfVerticalComponents, with: [])).map {
			zip($0.0.padded(to: numberOfHorizontalComponents, with: (0 as Float, 0 as Float, 0 as Float)), $0.1.padded(to: numberOfHorizontalComponents, with: (0 as Float, 0 as Float, 0 as Float))).map {
				combine($0.0, $0.1)
			}
		})
	}
}

public func *(lhs: BlurHash, rhs: Float) -> BlurHash {
	return lhs.transform { $0 * rhs }
}

public func /(lhs: BlurHash, rhs: Float) -> BlurHash {
	return lhs.transform { $0 / rhs }
}

@available(iOS 17.0, *) #Preview("Multiply darker") {
	VStack {
		BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!)
		BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")! * 0.75)
		BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")! * 0.5)
		BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")! * 0.25)
	}
		.background(Color.black.ignoresSafeArea())
}

@available(iOS 17.0, *) #Preview("Multiply lighter") {
	VStack {
		BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!)
		BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")! * 1.25)
		BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")! * 1.5)
		BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")! * 1.75)
	}
		.background(Color.black.ignoresSafeArea())
}

public func +(lhs: BlurHash, rhs: BlurHash) -> BlurHash {
	lhs.combine(with: rhs) { $0 + $1 }
}

public func -(lhs: BlurHash, rhs: BlurHash) -> BlurHash {
	lhs.combine(with: rhs) { $0 - $1 }
}

@available(iOS 17.0, *) #Preview("Sum, difference, average") {
	VStack {
		BlurHashPreview(BlurHash(string: "1%NcUo|c")!)
		BlurHashPreview(BlurHash(string: "9~LoLK|U")!)
		BlurHashPreview(BlurHash(string: "1%NcUo|c")! + BlurHash(string: "9~LoLK|U")!)
		BlurHashPreview(BlurHash(string: "1%NcUo|c")! - BlurHash(string: "9~LoLK|U")!)
		BlurHashPreview(BlurHash(string: "1%NcUo|c")! * 0.5 + BlurHash(string: "9~LoLK|U")! * 0.5)
	}
		.padding([.leading, .trailing], 64)
		.background(Color.black.ignoresSafeArea())
}

extension BlurHash {
	var dc: BlurHash {
		return .init(components: [[components[0][0]]])
	}

	var ac: BlurHash {
		var newComponents = components
		newComponents[0][0] = (0, 0, 0)
		return .init(components: newComponents)
	}
}

@available(iOS 17.0, *) #Preview("DC and AC components") {
	VStack {
		BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!)
		BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!.dc)
		BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!.ac)
		BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!.dc + BlurHash(string: "A?MiXtR4|WsO")!.ac)
	}
		.background(Color.black.ignoresSafeArea())
}

extension BlurHash {
	// Equivalent to .dc + .ac * factor.
	public func punch(_ factor: Float) -> BlurHash {
		return BlurHash(components: components.enumerated().map { (j, horizontalComponents) -> [(Float, Float, Float)] in
			return horizontalComponents.enumerated().map { (i, component) -> (Float, Float, Float) in
				if i == 0 && j == 0 {
					return component
				} else {
					return component * factor
				}
			}
		})
	}
}

@available(iOS 17.0, *) #Preview("punch() down") {
	VStack {
		BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!)
		BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!.punch(0.75))
		BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!.punch(0.5))
		BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!.punch(0.25))
	}
		.background(Color.black.ignoresSafeArea())
}

@available(iOS 17.0, *) #Preview("punch() up") {
	VStack {
		BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!)
		BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!.punch(1.25))
		BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!.punch(1.5))
		BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!.punch(2))
	}
		.background(Color.black.ignoresSafeArea())
}

extension BlurHash {
	public func darken(_ factor: Float) -> BlurHash {
		return dc * (1 - factor) + ac * (1 - factor * factor)
	}
}

@available(iOS 17.0, *) #Preview("darken()") {
	TabView {
		HStack {
			VStack {
				BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!)
				BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!.darken(0.1))
				BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!.darken(0.2))
				BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!.darken(0.3))
				BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!.darken(0.4))
			}

			VStack {
				BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!.darken(0.5))
				BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!.darken(0.6))
				BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!.darken(0.7))
				BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!.darken(0.8))
				BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!.darken(0.9))
			}
		}

		HStack {
			VStack {
				BlurHashPreview(BlurHash(string: "LGF5]+Yk^6#M@-5c,1J5@[or[Q6.")!)
				BlurHashPreview(BlurHash(string: "LGF5]+Yk^6#M@-5c,1J5@[or[Q6.")!.darken(0.1))
				BlurHashPreview(BlurHash(string: "LGF5]+Yk^6#M@-5c,1J5@[or[Q6.")!.darken(0.2))
				BlurHashPreview(BlurHash(string: "LGF5]+Yk^6#M@-5c,1J5@[or[Q6.")!.darken(0.3))
				BlurHashPreview(BlurHash(string: "LGF5]+Yk^6#M@-5c,1J5@[or[Q6.")!.darken(0.4))
			}

			VStack {
				BlurHashPreview(BlurHash(string: "LGF5]+Yk^6#M@-5c,1J5@[or[Q6.")!.darken(0.5))
				BlurHashPreview(BlurHash(string: "LGF5]+Yk^6#M@-5c,1J5@[or[Q6.")!.darken(0.6))
				BlurHashPreview(BlurHash(string: "LGF5]+Yk^6#M@-5c,1J5@[or[Q6.")!.darken(0.7))
				BlurHashPreview(BlurHash(string: "LGF5]+Yk^6#M@-5c,1J5@[or[Q6.")!.darken(0.8))
				BlurHashPreview(BlurHash(string: "LGF5]+Yk^6#M@-5c,1J5@[or[Q6.")!.darken(0.9))
			}
		}

		HStack {
			VStack {
				BlurHashPreview(BlurHash(string: "LEHV6nWB2yk8pyo0adR*.7kCMdnj")!)
				BlurHashPreview(BlurHash(string: "LEHV6nWB2yk8pyo0adR*.7kCMdnj")!.darken(0.1))
				BlurHashPreview(BlurHash(string: "LEHV6nWB2yk8pyo0adR*.7kCMdnj")!.darken(0.2))
				BlurHashPreview(BlurHash(string: "LEHV6nWB2yk8pyo0adR*.7kCMdnj")!.darken(0.3))
				BlurHashPreview(BlurHash(string: "LEHV6nWB2yk8pyo0adR*.7kCMdnj")!.darken(0.4))
			}

			VStack {
				BlurHashPreview(BlurHash(string: "LEHV6nWB2yk8pyo0adR*.7kCMdnj")!.darken(0.5))
				BlurHashPreview(BlurHash(string: "LEHV6nWB2yk8pyo0adR*.7kCMdnj")!.darken(0.6))
				BlurHashPreview(BlurHash(string: "LEHV6nWB2yk8pyo0adR*.7kCMdnj")!.darken(0.7))
				BlurHashPreview(BlurHash(string: "LEHV6nWB2yk8pyo0adR*.7kCMdnj")!.darken(0.8))
				BlurHashPreview(BlurHash(string: "LEHV6nWB2yk8pyo0adR*.7kCMdnj")!.darken(0.9))
			}
		}
	}
	.tabViewStyle(.page)
		.background(Color.black.ignoresSafeArea())
}

extension BlurHash {
		func darken2(_ factor: Float) -> BlurHash {
			return dc * (1 - factor) + ac * (1 - factor * factor * factor * factor)
		}

	public func lighten(_ factor: Float) -> BlurHash {
		let white = BlurHash(components: [[(1, 1, 1)]])
		return white - (white - self).darken2(factor)
	}
}

@available(iOS 17.0, *) #Preview("lighten()") {
	TabView {
		HStack {
			VStack {
				BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!)
				BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!.lighten(0.1))
				BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!.lighten(0.2))
				BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!.lighten(0.3))
				BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!.lighten(0.4))
			}

			VStack {
				BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!.lighten(0.5))
				BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!.lighten(0.6))
				BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!.lighten(0.7))
				BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!.lighten(0.8))
				BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!.lighten(0.9))
			}
		}

		HStack {
			VStack {
				BlurHashPreview(BlurHash(string: "LGF5]+Yk^6#M@-5c,1J5@[or[Q6.")!)
				BlurHashPreview(BlurHash(string: "LGF5]+Yk^6#M@-5c,1J5@[or[Q6.")!.lighten(0.1))
				BlurHashPreview(BlurHash(string: "LGF5]+Yk^6#M@-5c,1J5@[or[Q6.")!.lighten(0.2))
				BlurHashPreview(BlurHash(string: "LGF5]+Yk^6#M@-5c,1J5@[or[Q6.")!.lighten(0.3))
				BlurHashPreview(BlurHash(string: "LGF5]+Yk^6#M@-5c,1J5@[or[Q6.")!.lighten(0.4))
			}

			VStack {
				BlurHashPreview(BlurHash(string: "LGF5]+Yk^6#M@-5c,1J5@[or[Q6.")!.lighten(0.5))
				BlurHashPreview(BlurHash(string: "LGF5]+Yk^6#M@-5c,1J5@[or[Q6.")!.lighten(0.6))
				BlurHashPreview(BlurHash(string: "LGF5]+Yk^6#M@-5c,1J5@[or[Q6.")!.lighten(0.7))
				BlurHashPreview(BlurHash(string: "LGF5]+Yk^6#M@-5c,1J5@[or[Q6.")!.lighten(0.8))
				BlurHashPreview(BlurHash(string: "LGF5]+Yk^6#M@-5c,1J5@[or[Q6.")!.lighten(0.9))
			}
		}

		HStack {
			VStack {
				BlurHashPreview(BlurHash(string: "LEHV6nWB2yk8pyo0adR*.7kCMdnj")!)
				BlurHashPreview(BlurHash(string: "LEHV6nWB2yk8pyo0adR*.7kCMdnj")!.lighten(0.1))
				BlurHashPreview(BlurHash(string: "LEHV6nWB2yk8pyo0adR*.7kCMdnj")!.lighten(0.2))
				BlurHashPreview(BlurHash(string: "LEHV6nWB2yk8pyo0adR*.7kCMdnj")!.lighten(0.3))
				BlurHashPreview(BlurHash(string: "LEHV6nWB2yk8pyo0adR*.7kCMdnj")!.lighten(0.4))
			}

			VStack {
				BlurHashPreview(BlurHash(string: "LEHV6nWB2yk8pyo0adR*.7kCMdnj")!.lighten(0.5))
				BlurHashPreview(BlurHash(string: "LEHV6nWB2yk8pyo0adR*.7kCMdnj")!.lighten(0.6))
				BlurHashPreview(BlurHash(string: "LEHV6nWB2yk8pyo0adR*.7kCMdnj")!.lighten(0.7))
				BlurHashPreview(BlurHash(string: "LEHV6nWB2yk8pyo0adR*.7kCMdnj")!.lighten(0.8))
				BlurHashPreview(BlurHash(string: "LEHV6nWB2yk8pyo0adR*.7kCMdnj")!.lighten(0.9))
			}
		}
	}
		.tabViewStyle(.page)
		.background(Color.black.ignoresSafeArea())
}

extension BlurHash {
	public func invertBrightness(midpoint: Float = 0.3) -> BlurHash {
		setBrightness(1 - brightness(midpoint: midpoint), midpoint: midpoint)
	}

	public func setBrightnessByMultiplying(_ newBrightness: Float, midpoint: Float = 0.3) -> BlurHash {
		let exponent = -log2(midpoint) // Equivalent to log(midpoint) / log(0.5)
		let luminance = self.luminance
		let newLuminance = pow(newBrightness, exponent)

		let derivative = pow(luminance, exponent - 1)
		let newDerivative = pow(newLuminance, exponent - 1)

		let newDC = dc / luminance * newLuminance
		let newAC = ac / derivative * newDerivative

		return newDC + newAC
	}

	public func setBrightnessByScreening(_ newBrightness: Float, midpoint: Float = 0.3) -> BlurHash {
		let exponent = -log2(midpoint) // Equivalent to log(midpoint) / log(0.5)
		let luminance = self.luminance
		let newLuminance = pow(newBrightness, exponent)

		let derivative = pow(luminance, exponent - 1)
		let newDerivative = pow(newLuminance, exponent - 1)

		// 1 - (1 - x) * c = x'
		// (1 - x) * c = 1 - x'
		// c = (1 - x') / (1 - x)
		let c = (1 - newLuminance) / (1 - luminance)

		let white = BlurHash(components: [[(1, 1, 1)]])
		let newDC = white - (white - dc) * c
		let newAC = ac / derivative * newDerivative

		return newDC + newAC
	}

	public func setBrightness(_ newBrightness: Float, midpoint: Float = 0.3) -> BlurHash {
		if newBrightness < brightness(midpoint: midpoint) {
			return setBrightnessByMultiplying(newBrightness, midpoint: midpoint)
		} else {
			return setBrightnessByScreening(newBrightness, midpoint: midpoint)
		}
	}
}

@available(iOS 17.0, *) #Preview("invertBrightness()") {
	HStack {
		VStack {
			BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!)
			BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!.lighten(0.2))
			BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!.lighten(0.4))
			BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!.darken(0.4))
			BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!.darken(0.8))
		}

		VStack {
			BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!.invertBrightness())
			BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!.lighten(0.2).invertBrightness())
			BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!.lighten(0.4).invertBrightness())
			BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!.darken(0.4).invertBrightness())
			BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!.darken(0.8).invertBrightness())
		}
	}
		.background(Color.black.ignoresSafeArea())
}

@available(iOS 17.0, *) #Preview("setBrightness()") {
	TabView {
		HStack {
			VStack {
				BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!)
				BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!.setBrightness(0.1))
				BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!.setBrightness(0.2))
				BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!.setBrightness(0.3))
				BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!.setBrightness(0.4))
			}

			VStack {
				BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!.setBrightness(0.5))
				BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!.setBrightness(0.6))
				BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!.setBrightness(0.7))
				BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!.setBrightness(0.8))
				BlurHashPreview(BlurHash(string: "A?MiXtR4|WsO")!.setBrightness(0.9))
			}
		}

		HStack {
			VStack {
				BlurHashPreview(BlurHash(string: "LGF5]+Yk^6#M@-5c,1J5@[or[Q6.")!)
				BlurHashPreview(BlurHash(string: "LGF5]+Yk^6#M@-5c,1J5@[or[Q6.")!.setBrightness(0.1))
				BlurHashPreview(BlurHash(string: "LGF5]+Yk^6#M@-5c,1J5@[or[Q6.")!.setBrightness(0.2))
				BlurHashPreview(BlurHash(string: "LGF5]+Yk^6#M@-5c,1J5@[or[Q6.")!.setBrightness(0.3))
				BlurHashPreview(BlurHash(string: "LGF5]+Yk^6#M@-5c,1J5@[or[Q6.")!.setBrightness(0.4))
			}

			VStack {
				BlurHashPreview(BlurHash(string: "LGF5]+Yk^6#M@-5c,1J5@[or[Q6.")!.setBrightness(0.5))
				BlurHashPreview(BlurHash(string: "LGF5]+Yk^6#M@-5c,1J5@[or[Q6.")!.setBrightness(0.6))
				BlurHashPreview(BlurHash(string: "LGF5]+Yk^6#M@-5c,1J5@[or[Q6.")!.setBrightness(0.7))
				BlurHashPreview(BlurHash(string: "LGF5]+Yk^6#M@-5c,1J5@[or[Q6.")!.setBrightness(0.8))
				BlurHashPreview(BlurHash(string: "LGF5]+Yk^6#M@-5c,1J5@[or[Q6.")!.setBrightness(0.9))
			}
		}

		HStack {
			VStack {
				BlurHashPreview(BlurHash(string: "LEHV6nWB2yk8pyo0adR*.7kCMdnj")!)
				BlurHashPreview(BlurHash(string: "LEHV6nWB2yk8pyo0adR*.7kCMdnj")!.setBrightness(0.1))
				BlurHashPreview(BlurHash(string: "LEHV6nWB2yk8pyo0adR*.7kCMdnj")!.setBrightness(0.2))
				BlurHashPreview(BlurHash(string: "LEHV6nWB2yk8pyo0adR*.7kCMdnj")!.setBrightness(0.3))
				BlurHashPreview(BlurHash(string: "LEHV6nWB2yk8pyo0adR*.7kCMdnj")!.setBrightness(0.4))
			}

			VStack {
				BlurHashPreview(BlurHash(string: "LEHV6nWB2yk8pyo0adR*.7kCMdnj")!.setBrightness(0.5))
				BlurHashPreview(BlurHash(string: "LEHV6nWB2yk8pyo0adR*.7kCMdnj")!.setBrightness(0.6))
				BlurHashPreview(BlurHash(string: "LEHV6nWB2yk8pyo0adR*.7kCMdnj")!.setBrightness(0.7))
				BlurHashPreview(BlurHash(string: "LEHV6nWB2yk8pyo0adR*.7kCMdnj")!.setBrightness(0.8))
				BlurHashPreview(BlurHash(string: "LEHV6nWB2yk8pyo0adR*.7kCMdnj")!.setBrightness(0.9))
			}
		}
	}
		.tabViewStyle(.page)
		.background(Color.black.ignoresSafeArea())
}
extension BlurHash {
	public func simplify(maximumNumberOfComponents: (Int, Int)) -> BlurHash {
		let simplifiedComponents = Array(components.prefix(maximumNumberOfComponents.1).map { Array($0.prefix(maximumNumberOfComponents.0)) })
		return .init(components: simplifiedComponents)
	}
}

extension Collection {
	fileprivate func padded(to newCount: Int, with padding: Element) -> [Element] {
		guard newCount > count else { return .init(self) }

		return self + Array(repeating: padding, count: newCount - count)
	}
}
