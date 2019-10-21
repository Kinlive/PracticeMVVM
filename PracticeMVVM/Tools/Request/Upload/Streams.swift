//
//  Streams.swift
//  DemoSignature
//
//  Created by Thinkpower on 2019/7/19.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import UIKit

struct Streams {
    let input: InputStream
    let output: OutputStream
}

protocol StreamHandlerDelegate: class {
    func sending(currentSize: Double, percent: Double, to destination: URL, with model: DownloadModelProtocol?)
    func needHeaders(on model: DownloadModelProtocol) -> [String : String]
    
//     optional method defined
    func prepareDataEnd()
}
// StreamHandlerDelegate optional methods
extension StreamHandlerDelegate {
    func prepareDataEnd() { }
}


class StreamsHandler: NSObject {
    
    weak var delegate: StreamHandlerDelegate?
    
    
    private var session: URLSession!
    private var boundStreams: Streams?

    private var canWrite: Bool = false
    
    private var data: Data = Data()
    
    private var destinationURL: URL = URL(string: "http://localhost:3000/uploadStream")!
    private var fromURL: URL?
    
    private var cacheModel: DownloadModelProtocol?
    
    // MARK: - Initialize and deinitialize ============================================================
    private override init() {
        super.init()
    }
    
    /// use convenience initialization to prepare something, default destination was local server.
    public convenience init(destination url: URL? = nil) {
        self.init()
        
        if let url = url {
            self.destinationURL = url
        }
        
    }
    
    // deinit clear something
    deinit {
        guard let streams = boundStreams else { return }
        
        if streams.output.streamStatus == .open {
            streams.output.close()
        }
        if streams.input.streamStatus == .open {
            streams.input.close()
        }
        
    }
    
    // MARK: - Actions to upload ============================================================
    
    /// when use this test case, reminds of implement optional delegate function *prepareDataEnd()* to call *upload(with data:)*.
    /// - Parameter size: 1 ~= 40 byte, 1000 ~= 40Kbyte..., default ~= 4Mbyte.
    public func testUploadBigData(size: Int = Int(1e6)) {
        // prepare big data
        var bigStrs: String = ""
        
        DispatchQueue.global().async {
            for i in 0...size {
                bigStrs += "A big data with very more count: \(i), \n"
            }
            let bigData = bigStrs.data(using: .utf8)
            guard let newData = bigData else { return }
            self.data = newData
            if let delegate = self.delegate {
                delegate.prepareDataEnd()
            }
        }
    }
    
    public func upload(with data: Data?) {
        if let data = data {
            self.data = data
        }
        uploadData()
    }
    
    public func upload(from url: URL) {
        guard let data = try? Data(contentsOf: url) else { return }
        self.data = data
        uploadData()
        
    }
    
    // For FileManager use
    // Get local file path: download task stores tune here; AV player plays it.
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    func localFilePath(for url: URL) -> URL {
        var startAppend = false
        var docMusicPath = documentsPath
        
        for component in url.pathComponents {
            if component == documentsPath.lastPathComponent {
                startAppend = true
            }
            
            if startAppend, component != documentsPath.lastPathComponent {
                docMusicPath.appendPathComponent(component)
            }
        }
        
        return docMusicPath
        
//        return documentsPath.appendingPathComponent(url.lastPathComponent)
    }
    
    public func upload(with model: DownloadModelProtocol) {
        cacheModel = model
        let url = localFilePath(for: model.url)
        
        let urlStr = url.absoluteString.replacingOccurrences(of: "file://", with: "", options: .literal, range: nil)
        
        guard let data = FileManager.default.contents(atPath: urlStr) else {
            printLog(logs: ["Data not found on:\(urlStr)"], title: "Upload data fail.")
            return }
        
        self.data = data
        uploadData()
    }
    
    // MARK: - Private actions ============================================================
    
    /// start upload data
    private func uploadData() {
        
        if boundStreams == nil {
            boundStreams = getNewStreams()
        }
        
        if session == nil {
            session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        }
        
        guard let stream = boundStreams, let session = session else { return }
        
        var request = URLRequest(url: destinationURL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: .infinity)
        request.httpMethod = "POST"
        // FIXME: - custom headers.
        if let model = cacheModel, let headerValues = delegate?.needHeaders(on: model) {
            
            headerValues.forEach { request.addValue($1, forHTTPHeaderField: $0) }
            
        } else {
            request.addValue("BigData_", forHTTPHeaderField: "fileName")
            request.addValue("", forHTTPHeaderField: "path")
        }
        
        request.httpBodyStream = stream.input
        
        let uploadTask = session.uploadTask(withStreamedRequest: request)
        uploadTask.resume()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.beginWriteData(stream: stream)
        }
    }
    
    private func getNewStreams() -> Streams {
        
        var inputStreamOrNil: InputStream?
        var outputStreamOrNil: OutputStream?
        
        // bufferSize: byte, ex: size = image(1024*1024) / 8
        Stream.getBoundStreams(withBufferSize: self.data.count, inputStream: &inputStreamOrNil, outputStream: &outputStreamOrNil)
        
        guard let input = inputStreamOrNil, let output = outputStreamOrNil else {
            fatalError("On return of `getBoundStreams`, both `inputStream` and `outputStream` will contain non-nil streams.")
        }
        
        output.delegate = self
        output.schedule(in: .current, forMode: .default)
        output.open()
        
        return Streams(input: input, output: output)
    }
    
    
    private func beginWriteData(stream: Streams) {
        guard canWrite else { return }
        
        // here will run all data transfer from input to output
        let bytesWritten: Int = self.data.withUnsafeBytes() { dataBytes in
            self.canWrite = false
            let buffer: UnsafePointer<UInt8> = dataBytes.baseAddress!.assumingMemoryBound(to: UInt8.self)
        
            return stream.output.write(buffer, maxLength: self.data.count)
        }
        
        printLog(logs: ["bytesWritten: \(bytesWritten)", "dataCount: \(self.data.count)"], title: "Size display")
        
        if bytesWritten < self.data.count {
            // Handle writing less data than expected.
            printLog(logs: ["bytesWritten < messageData.count", "bytyesWritte: \(bytesWritten), dataCount: \(self.data.count)"], title: "Handle writing less data than expected.")
            
        }
    }
    
}

extension StreamsHandler: URLSessionStreamDelegate {

    func urlSession(_ session: URLSession, task: URLSessionTask, needNewBodyStream completionHandler: @escaping (InputStream?) -> Void) {
        // provide input stream
        printLog(logs: [task.currentRequest?.url?.absoluteString ?? ""], title: "needNewBodyStream completionHandler")
        guard let stream = boundStreams else { return }
        completionHandler(stream.input)
        
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        
        // FIXME: - upload process
        let currentSize = Double(totalBytesSent)//Double(bytesSent) / 1000.0
        let percent = (Double(totalBytesSent) / Double(data.count)) * 100
        //printLog(logs: ["bytesSent:\(bytesSent)","totalBytesSent: \(totalBytesSent)","totalBytesExpectedToSend: \(totalBytesExpectedToSend)"], title: "didSendBodyData")
        
        delegate?.sending(currentSize: currentSize, percent: percent, to: destinationURL, with: cacheModel)
        
        if Int(totalBytesSent) == data.count { // when send data all finished
            printLog(logs: ["bytesSent:\(bytesSent)","totalBytesSent: \(totalBytesSent)","totalBytesExpectedToSend: \(totalBytesExpectedToSend)"], title: "didSendBodyData")
            
            if boundStreams!.input.streamStatus == .atEnd {
                boundStreams?.input.close()
            }
            
            if boundStreams!.output.streamStatus != .writing {
                boundStreams?.output.close()
            }
            
            self.boundStreams = nil
            session.finishTasksAndInvalidate()
            self.session = nil
        }
        
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        printLog(logs: [error?.localizedDescription ?? ""], title: "CompleteWithError")
    }
}

extension StreamsHandler: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        guard aStream == boundStreams!.output else {
            printLog(logs: ["aStream == boundStreams.output"], title: "handle eventCode")
            return }
  
        let title = "handleEventCode"

        switch eventCode {
        case Stream.Event.hasSpaceAvailable:
            canWrite = true
            
        case Stream.Event.errorOccurred:
            // Close the streams and alert the user that the upload failed.
            aStream.close()
            boundStreams?.input.close()
            session.finishTasksAndInvalidate()
            printLog(logs: ["\(String(describing: aStream.streamError?.localizedDescription))"], title: "Upload stream error")
            
        case Stream.Event.openCompleted:
            printLog(logs: ["Stream.Event.openCompleted: \(eventCode.rawValue)"], title: title)
        
        case Stream.Event.hasBytesAvailable:
            printLog(logs: ["Stream.Event.hasBytesAvailable: \(eventCode.rawValue)"], title: title)
       
        case Stream.Event.endEncountered:
            printLog(logs: ["Stream.Event.endEncountered: \(eventCode.rawValue)"], title: title)

        default:
            break
        }
    
    }
}
