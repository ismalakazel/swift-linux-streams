import CoreFoundation
import Foundation

/// WriteStream is a wrapper around objects the CoreFoundation framework provides to open and read from a stream (CFWriteStream). 
///
/// - [Stream.swift](https://github.com/apple/swift-corelibs-foundation/blob/main/Sources/Foundation/Stream.swift#L126)
/// - [CFWriteStream](https://developer.apple.com/documentation/corefoundation/cfwritestream-rc8)
class WriteStream {

	/// A CFWriteStream to open and write to.
	var stream: CFWriteStream?

	/// The RunLoop mode to be used when scheduling the stream on the RunLoop.
	static let mode = CFStringCreateWithCString(kCFAllocatorDefault, "commonModes", CFStringBuiltInEncodings.UTF8.rawValue)

	/// A callback that is called everytime there is an event in the stream. 	
	private var callback: CFWriteStreamClientCallBack = { stream, event, info in
		switch event {
			case .openCompleted: print("WriteStream Event == .openCompleted")
			case .hasBytesAvailable: print("WriteStream Event == .hasBytesAvailable")
			case .canAcceptBytes: print("WriteStream Event == .canAcceptBytes")
			case .errorOccurred: print("WriteStream Event == .errorOccurred")
			case .endEncountered: print("WriteStream Event == .endEncountered")
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


	/// Creates the CFWriteStream and sets self as the client that will receive the callback with events.
	init(filePath: String) {
		let cString: CFString = CFStringCreateWithCString(kCFAllocatorDefault, filePath, CFStringBuiltInEncodings.UTF8.rawValue)
		let url: CFURL = CFURLCreateWithString(kCFAllocatorDefault, cString, nil) 
		stream = CFWriteStreamCreateWithFile(kCFAllocatorDefault, url)

		let info = Unmanaged.passUnretained(self).toOpaque()
		var context = CFStreamClientContext(version: 0, info: info, retain: nil, release: nil, copyDescription: nil)
		let _: Bool = CFWriteStreamSetClient(stream, events, callback, &context)
	}

	/// Open the stream before writing to it.
	///
	/// - Returns: True if stream opened false otherwise.
	@discardableResult func open() ->  Bool {
		return CFWriteStreamOpen(stream)
	}	

	/// Close the stream when necessary.
	func close() {
		CFWriteStreamClose(stream)
	}

	/// Schedule the stream in a RunLoop in order to receive the stream events.
	func schedule() {
		CFWriteStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), WriteStream.mode) 
	}

	/// Unschedule the stream from the RunLoop to stop receiving events.
	func unschedule() {
		CFWriteStreamUnscheduleFromRunLoop(stream, CFRunLoopGetCurrent(), WriteStream.mode) 
	}

	/// Write from the stream.
	///
	/// Can be called directly after a call to open() or after a callback with .openCompleted is received.
	///
	/// - Returns: A string with the contents read from the stream.
	@discardableResult func write(content: String) -> Bool {
		let buffer = [UInt8](content.utf8) 
		var result: Bool = false 
		stream.flatMap { stream in
			let count = CFWriteStreamWrite(stream, buffer, CFIndex(buffer.count))	
			result = count > 0
		}
		return result 
	}
}
