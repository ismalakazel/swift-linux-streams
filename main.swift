import Foundation
import CoreFoundation

let filePath = "file:///path/to/file.txt"
let readStream = ReadStream(filePath: filePath)
let writeStream = WriteStream(filePath: filePath)

writeStream.schedule()
readStream.schedule()

writeStream.open()
readStream.open() 

if writeStream.write(content: "hello World") {
	writeStream.close()
	readStream.read().flatMap { print($0) }
	readStream.close()
}

CFRunLoopRunInMode(ReadStream.mode, 2, false)
