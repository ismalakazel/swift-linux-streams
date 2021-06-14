# Read and Write file streams.

*© Israel Pereira Tavares da Silva*

A project that uses Core Foundation (on a Linux environment) to read and write to a file stream. 

* [swift-corelibs-foundation](https://github.com/apple/swift-corelibs-foundation)
* [Stream.swift](https://github.com/apple/swift-corelibs-foundation/blob/main/Sources/Foundation/Stream.swift#L126)
* [CFReadStream](https://developer.apple.com/documentation/corefoundation/cfreadstream-ri6)
* [CFWriteStream](https://developer.apple.com/documentation/corefoundation/cfwritestream-rc8)

The source files include a `main.swift` file that you can use to write to and read a hello world string from file.tx (also included in the repository). However, first you'll have to link the `ReadStream` and `WriteStream` modules to an executable. To do this follow the steps below:

Create the ReadStream module:

```bash 
$ swiftc -c `ReadStream.swift -emit-module
```

Create the WriteStream module:
```bash 
$ swiftc -c `WriteStream.swift -emit-module
```

Create and executable that links ReadStream and WriteStream modules
```bash 
$ swiftc -o program *.swift -I ReadStream -I WriteStream
```

Edit `main.swift` and change the variable `filePath` to include the correct path to `file.txt`.

Run the program:
```bash 
$ ./program
```
