import Foundation

func signPow(_ value: Float, _ exp: Float) -> Float {
	return copysign(pow(abs(value), exp), value)
}

func linearTosRGB(_ value: Float) -> Int {
	return Int(linearTosRGBFloat(value) * 255 + 0.5)
}

func linearTosRGBFloat(_ value: Float) -> Float {
	let v = max(0, min(1, value))
	if v <= 0.0031308 { return v * 12.92 }
	else { return (1.055 * pow(v, 1 / 2.4) - 0.055) }
}

func sRGBToLinear<Type: BinaryInteger>(_ value: Type) -> Float {
	return sRGBFloatToLinear(Float(Int64(value)) / 255)
}

func sRGBFloatToLinear(_ value: Float) -> Float {
	if value <= 0.04045 { return value / 12.92 }
	else { return pow((value + 0.055) / 1.055, 2.4) }
}
