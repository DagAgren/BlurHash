import Foundation
import UIKit

extension BlurHash {
    public func linearRGB(atX x: Float) -> (Float, Float, Float) {
        return components[0].enumerated().reduce((0, 0, 0)) { (sum, horizontalEnumerated) -> (Float, Float, Float) in
            let (i, component) = horizontalEnumerated
            return sum + component * cos(Float.pi * Float(i) * x)
        }
    }

    public func linearRGB(atY y: Float) -> (Float, Float, Float) {
        return components.enumerated().reduce((0, 0, 0)) { (sum, verticalEnumerated) in
            let (j, horizontalComponents) = verticalEnumerated
            return sum + horizontalComponents[0] * cos(Float.pi * Float(j) * y)
        }
    }

    public func linearRGB(at position: (Float, Float)) -> (Float, Float, Float) {
        return components.enumerated().reduce((0, 0, 0)) { (sum, verticalEnumerated) in
            let (j, horizontalComponents) = verticalEnumerated
            return horizontalComponents.enumerated().reduce(sum) { (sum, horizontalEnumerated) in
                let (i, component) = horizontalEnumerated
                return sum + component * cos(Float.pi * Float(i) * position.0) * cos(Float.pi * Float(j) * position.1)
            }
        }
    }

    public func linearRGB(from upperLeft: (Float, Float), to lowerRight: (Float, Float)) -> (Float, Float, Float) {
        return components.enumerated().reduce((0, 0, 0)) { (sum, verticalEnumerated) in
            let (j, horizontalComponents) = verticalEnumerated
            return horizontalComponents.enumerated().reduce(sum) { (sum, horizontalEnumerated) in
                let (i, component) = horizontalEnumerated
                let horizontalAverage: Float = i == 0 ? 1 : (sin(Float.pi * Float(i) * lowerRight.0) - sin(Float.pi * Float(i) * upperLeft.0)) / (Float(i) * Float.pi * (lowerRight.0 - upperLeft.0))
                let veritcalAverage: Float = j == 0 ? 1 : (sin(Float.pi * Float(j) * lowerRight.1) - sin(Float.pi * Float(j) * upperLeft.1)) / (Float(j) * Float.pi * (lowerRight.1 - upperLeft.1))
                return sum + component * horizontalAverage * veritcalAverage
            }
        }
    }

    public func linearRGB(at upperLeft: (Float, Float), size: (Float, Float)) -> (Float, Float, Float) {
        return linearRGB(from: upperLeft, to: (upperLeft.0 + size.0, upperLeft.1 + size.1))
    }

    public var averageLinearRGB: (Float, Float, Float) {
        return components[0][0]
    }

    public var leftEdgeLinearRGB: (Float, Float, Float) { return linearRGB(atX: 0) }
    public var rightEdgeLinearRGB: (Float, Float, Float) { return linearRGB(atX: 1) }
    public var topEdgeLinearRGB: (Float, Float, Float) { return linearRGB(atY: 0) }
    public var bottomEdgeLinearRGB: (Float, Float, Float) { return linearRGB(atY: 1) }
    public var topLeftCornerLinearRGB: (Float, Float, Float) { return linearRGB(at: (0, 0)) }
    public var topRightCornerLinearRGB: (Float, Float, Float) { return linearRGB(at: (1, 0)) }
    public var bottomLeftCornerLinearRGB: (Float, Float, Float) { return linearRGB(at: (0, 1)) }
    public var bottomRightCornerLinearRGB: (Float, Float, Float) { return linearRGB(at: (1, 1)) }
}

extension BlurHash {
    static public func luminance(linearRGB rgb: (Float, Float, Float)) -> Float {
		return sum(rgb * (0.299, 0.587, 0.114))
	}

    public var luminance: Float { return Self.luminance(linearRGB: averageLinearRGB) }

    public func luminance(atX x: Float) -> Float { return Self.luminance(linearRGB: linearRGB(atX: x)) }
    public func luminance(atY y: Float) -> Float { return Self.luminance(linearRGB: linearRGB(atY: y)) }
    public func luminance(at position: (Float, Float)) -> Float { return Self.luminance(linearRGB: linearRGB(at: position)) }
    public func luminance(from upperLeft: (Float, Float), to lowerRight: (Float, Float)) -> Float { return Self.luminance(linearRGB: linearRGB(from: upperLeft, to: lowerRight)) }
    public func luminance(at upperLeft: (Float, Float), size: (Float, Float)) -> Float { return Self.luminance(linearRGB: linearRGB(at: upperLeft, size: size)) }
}

extension BlurHash {
    static public func brightness(linearRGB rgb: (Float, Float, Float), midpoint: Float = 0.3) -> Float {
		let luminance = luminance(linearRGB: rgb)
		let exponent = -log2(midpoint) // Equivalent to log(midpoint) / log(0.5)
		return pow(luminance, 1 / exponent)
	}

    public func brightness(midpoint: Float = 0.3) -> Float { return Self.brightness(linearRGB: averageLinearRGB, midpoint: midpoint) }

    public func brightness(atX x: Float, midpoint: Float = 0.3) -> Float { return Self.brightness(linearRGB: linearRGB(atX: x), midpoint: midpoint) }
    public func brightness(atY y: Float, midpoint: Float = 0.3) -> Float { return Self.brightness(linearRGB: linearRGB(atY: y), midpoint: midpoint) }
    public func brightness(at position: (Float, Float), midpoint: Float = 0.3) -> Float { return Self.brightness(linearRGB: linearRGB(at: position), midpoint: midpoint) }
    public func brightness(from upperLeft: (Float, Float), to lowerRight: (Float, Float), midpoint: Float = 0.3) -> Float { return Self.brightness(linearRGB: linearRGB(from: upperLeft, to: lowerRight), midpoint: midpoint) }
    public func brightness(at upperLeft: (Float, Float), size: (Float, Float), midpoint: Float = 0.3) -> Float { return Self.brightness(linearRGB: linearRGB(at: upperLeft, size: size), midpoint: midpoint) }
}

extension BlurHash {
    static public func isDark(linearRGB rgb: (Float, Float, Float), threshold: Float = 0.3) -> Bool {
        return luminance(linearRGB: rgb) < threshold
    }

    public func isDark(threshold: Float = 0.3) -> Bool { return Self.isDark(linearRGB: averageLinearRGB, threshold: threshold) }

    public func isDark(atX x: Float, threshold: Float = 0.3) -> Bool { return Self.isDark(linearRGB: linearRGB(atX: x), threshold: threshold) }
    public func isDark(atY y: Float, threshold: Float = 0.3) -> Bool { return Self.isDark(linearRGB: linearRGB(atY: y), threshold: threshold) }
    public func isDark(at position: (Float, Float), threshold: Float = 0.3) -> Bool { return Self.isDark(linearRGB: linearRGB(at: position), threshold: threshold) }
    public func isDark(from upperLeft: (Float, Float), to lowerRight: (Float, Float), threshold: Float = 0.3) -> Bool { return Self.isDark(linearRGB: linearRGB(from: upperLeft, to: lowerRight), threshold: threshold) }
    public func isDark(at upperLeft: (Float, Float), size: (Float, Float), threshold: Float = 0.3) -> Bool { return Self.isDark(linearRGB: linearRGB(at: upperLeft, size: size), threshold: threshold) }

    public var isLeftEdgeDark: Bool { return isDark(atX: 0) }
    public var isRightEdgeDark: Bool { return isDark(atX: 1) }
    public var isTopEdgeDark: Bool { return isDark(atY: 0) }
    public var isBottomEdgeDark: Bool { return isDark(atY: 1) }
    public var isTopLeftCornerDark: Bool { return isDark(at: (0, 0)) }
    public var isTopRightCornerDark: Bool { return isDark(at: (1, 0)) }
    public var isBottomLeftCornerDark: Bool { return isDark(at: (0, 1)) }
    public var isBottomRightCornerDark: Bool { return isDark(at: (1, 1)) }
}

extension BlurHash {
	var linearContrastRGB: (Float, Float, Float) {
		let probes = 10
		let average = averageLinearRGB
		let absoluteAverage = sqrt(average.0 * average.0 + average.1 * average.1 + average.2 * average.2)
		let normalisedAverage = (average.0 / absoluteAverage, average.1 / absoluteAverage, average.2 / absoluteAverage)
		var maximumDistance: Float = 0
		var maximumContrast: (Float, Float, Float) = averageLinearRGB
		for y in (0 ..< probes) {
			let fy = Float(y) / Float(probes - 1)
			for x in (0 ..< probes) {
				let fx = Float(x) / Float(probes - 1)
				let probe = linearRGB(at: (fx, fy))

				//let dot = probe.0 * normalisedAverage.0 + probe.1 * normalisedAverage.1 + probe.2 * normalisedAverage.2
				//let perpendicular = (probe.0 - normalisedAverage.0 * dot, probe.1 - normalisedAverage.1 * dot, probe.2 - normalisedAverage.2 * dot)
				//let distance = sqrt(perpendicular.0 * perpendicular.0 + perpendicular.1 * perpendicular.1 + perpendicular.2 * perpendicular.2)

				//let difference = (probe.0 - average.0, probe.1 - average.1, probe.2 - average.2)
				//let distance = sqrt(difference.0 * difference.0 + difference.1 * difference.1 + difference.2 * difference.2)

				let averageU = average.0 - average.1 * 0.5 - average.2 * 0.5
				let averageV = average.1 * 0.866 - average.2 * 0.866
				let probeU = probe.0 - probe.1 * 0.5 - probe.2 * 0.5
				let probeV = probe.1 * 0.866 - probe.2 * 0.866
				let distance = sqrt((averageU - probeU) * (averageU - probeU) + (averageV - probeV) * (averageV - probeV))

				if distance > maximumDistance {
					maximumDistance = distance
					maximumContrast = probe
				}
			}
		}
		return maximumContrast
	}
}

extension BlurHash {
	public var averageColour: UIColor {
		return .init(linear: averageLinearRGB)
	}

	public var contrastColour: UIColor {
		return .init(linear: linearContrastRGB)
	}
}

private extension UIColor {
	convenience init(linear: (Float, Float, Float)) {
		self.init(cgColor: .init(srgbRed: .init(linearTosRGBFloat(linear.0)), green: .init(linearTosRGBFloat(linear.1)), blue: .init(linearTosRGBFloat(linear.2)), alpha: 1))
	}
}
