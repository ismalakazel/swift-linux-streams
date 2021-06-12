import CoreFoundation
import Foundation

/// ReadStream is a wrapper around objects the CoreFoundation framework provides to open and read from a stream (CFReadStream). 
///
/// - [Stream.swift](https://github.com/apple/swift-corelibs-foundation/blob/main/Sources/Foundation/Stream.swift#L126)
/// - [CFReadStream](https://developer.apple.com/documentation/corefoundation/cfreadstream-ri6)
class ReadStream {

	/// A CFReadStream to open and read from.
	var stream: CFReadStream?

	/// The RunLoop mode to be used when scheduling the stream on the RunLoop.
	static let mode = CFStringCreateWithCString(kCFAllocatorDefault, "commonModes", CFStringBuiltInEncodings.UTF8.rawValue)

	/// A callback that is called everytime there is an event in the stream. 	
	private var callback: CFReadStreamClientCallBack = { stream, event, info in
		switch event {
			case .openCompleted: print("Stream Event == .openCompleted")
			case .hasBytesAvailable: print("Stream Event == .hasBytesAvailable")
			case .canAcceptBytes: print("Stream Event == .canAcceptBytes")
			case .errorOccurred: print("Stream Event == .errorOccurred")
			case .endEncountered: print("Stream Event == .endEncountered")
			default: break
		}
	}
	
	/// The types of events that are going to be received in the callback.
	private let events: CFOptionFlags =
	CFStreamEventType.openCompleted.rawValue |
	CFStreamEventType.canAcceptBytes.rawValue |
    CFStreamEventType.hasBytesAvailable.rawValue |
    CFStreamEventType.errorOccurred.rawValue |
    CFStreamEventType.endEncountered.rawValue 	


	/// Creates the CFReadStream and sets self as the client that will receive the callback with events.
	init(filePath: String) {
		let cString: CFString = CFStringCreateWithCString(kCFAllocatorDefault, filePath, CFStringBuiltInEncodings.UTF8.rawValue)
		let url: CFURL = CFURLCreateWithString(kCFAllocatorDefault, cString, nil) 
		stream = CFReadStreamCreateWithFile(kCFAllocatorDefault, url)

		let info = Unmanaged.passUnretained(self).toOpaque()
		var context = CFStreamClientContext(version: 0, info: info, retain: nil, release: nil, copyDescription: nil)
		let _: Bool = CFReadStreamSetClient(stream, events, callback, &context)
	}

	/// Open the stream before reading from it.
	///
	/// - Returns: A true if stream opened false otherwise.
	@discardableResult func open() ->  Bool {
		return CFReadStreamOpen(stream)
	}	

	/// Close the stream when necessary.
	func close() {
		CFReadStreamClose(stream)
	}

	/// Schedule the stream in a RunLoop in order to receive the stream events.
	func schedule() {
		CFReadStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), ReadStream.mode) 
	}

	/// Unschedule the stream from the RunLoop to stop receiving events.
	func unschedule() {
		CFReadStreamUnscheduleFromRunLoop(stream, CFRunLoopGetCurrent(), ReadStream.mode) 
	}

	/// Check if the stream has new bytes to be read.
	func hasBytesAvailable() -> Bool {
		return CFReadStreamHasBytesAvailable(stream)	
	}

	/// Read from the stream.
	///
	/// Can be called directly after a call to open() or after a callback with .openCompleted is received.
	///
	/// - Returns: A string with the contents read from the stream.
	func read() -> String? {
		let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 1024)
		defer {
			buffer.deallocate()
		}
		var data = Data()
		var string: String? 
		stream.flatMap { stream in
			let content = CFReadStreamRead(stream, buffer, 1024) 
			data.append(buffer, count: content)
			string = String(decoding: data, as: UTF8.self)
		}
		return string
	}
}

/// Create a new read stream
let readStream = ReadStream(filePath: "file:///path/to/file.txt")

/// Schedule the read stream in a run loop to receive callback events
readStream.schedule()

/// Check if the stream is open
if readStream.open() {

	/// If the read function returns a string print it to the stdin
	readStream.read().flatMap { string in 
		print(string)
	}
}

