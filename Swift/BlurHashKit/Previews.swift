import SwiftUI

@available(iOS 17.0, *) struct BlurHashPreview: View {
	let blurHash: BlurHash

	init(_ string: String) {
		self.blurHash = .init(string: string)!
	}

	init(_ blurHash: BlurHash) {
		self.blurHash = blurHash
	}

	var body: some View {
		ZStack {
			Image(uiImage: blurHash.image(numberOfPixels: 4096, originalSize: .init(width: 1, height: 1))!)
				.resizable()
			Text(blurHash.string)
				.foregroundStyle(blurHash.isDark() ? .white : .black)
				.bold()
				.textSelection(.enabled)
		}
	}
}
