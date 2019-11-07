//
//  ClientLogger.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 04/11/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation
import Moya

/// A Client logger.
public final class ClientLogger {
    
    /// A customizable logger block.
    /// By default error messages will print to the console, but you can customize it to use own logger.
    ///
    /// - Parameters:
    ///     - icon: a small icon string like a tag for messages, e.g. 🦄
    ///     - dateAndTime: a formatted string of date and time, could be empty.
    ///     - message: a message.
    public static var logger: (_ icon: String, _ dateTime: String, _ message: String) -> Void = {
        print($0, $1.isEmpty ? "" : "[\($1)]", $2)
    }
    
    private let icon: String
    
    /// Init a client logger.
    ///
    /// - Parameters:
    ///   - icon: a string icon.
    public init(icon: String) {
        self.icon = icon
    }
    
    public func log(_ endpoint: TargetType) {
        log("➡️ \(endpoint)")
        
        switch endpoint.task {
        case .requestPlain,
             .uploadMultipart:
            return
        case .requestData(let data):
            if let jsonString = try? data.prettyPrintedJSONString() {
                log("🧾 Request Data:\n\(jsonString)")
            }
        case .requestJSONEncodable(let object),
             .requestCustomJSONEncodable(let object, encoder: _):
            log("🧾 Request JSON:\n\(object)")
        case .requestParameters(parameters: let parameters, encoding: _):
            log("🧾 Parameters: \(parameters)")
        case .requestCompositeData(bodyData: let data, urlParameters: let parameters):
            do {
                let jsonString = try data.prettyPrintedJSONString()
                log("🧾 Request Data:\n\(jsonString)")
            } catch {
                log("🧾 Request Data error decoding: \(error.localizedDescription)")
            }
            
            log("🧾 URL parameters: \(parameters)")
        case .requestCompositeParameters(bodyParameters: let bodyParameters,
                                         bodyEncoding: _,
                                         urlParameters: let urlParameters):
            log("🧾 Body parameters: \(bodyParameters)")
            log("🧾 URL parameters: \(urlParameters)")
        case .uploadFile(let url):
            log("🧾 Upload URL: \(url)")
        case .uploadCompositeMultipart(_, urlParameters: let urlParameters):
            log("🧾 URL parameters: \(urlParameters)")
        case .downloadDestination(let destination):
            log("🧾 Destination parameter: \(String(describing: destination))")
        case .downloadParameters(parameters: let parameters, encoding: _, destination: let destination):
            log("🧾 Parameters: \(parameters)")
            log("🧾 Destination: \(String(describing: destination))")
        }
    }
    
    /// Log URL response.
    ///
    /// - Parameters:
    ///   - response: an URL response.
    ///   - data: a response data.
    ///   - forceToShowData: force to always log a data.
    public func log(_ response: URLResponse?, data: Data?) {
        if let response = response as? HTTPURLResponse, let url = response.url {
            log("⬅️ Response \(response.statusCode): \(url)")
        }
        
        guard let data = data else {
            return
        }
        
        let tag = "ⒿⓈⓄⓃ \(data.description)\n"
        
        if let jsonString = try? data.prettyPrintedJSONString() {
            log(tag, jsonString)
        } else if let dataString = String(data: data, encoding: .utf8) {
            log(tag, "\"\(dataString)\"")
        }
    }
    
    /// Log an error.
    ///
    /// - Parameters:
    ///   - icon: a string icon, e.g. emoji.
    ///   - error: an error.
    ///   - message: an additional message (optional).
    ///   - function: a callee function (auto).
    ///   - line: a callee line of a code in a function (auto).
    public static func log(_ icon: String = "",
                           _ error: Error?,
                           message: String? = nil,
                           function: String = #function,
                           line: Int = #line) {
        if let error = error {
            ClientLogger.logger("\(icon)❌", "", "\(message ?? "") \(error) in \(function)[\(line)]")
        }
    }
    
    /// Log a data as a pretty printed JSON string.
    ///
    /// - Parameters:
    ///   - identifier: an identifier.
    ///   - data: a data.
    public func log(_ identifier: String, _ data: Data?) {
        guard let data = data, !data.isEmpty else {
            log(identifier, "Data is empty")
            return
        }
        
        do {
            log(identifier, try data.prettyPrintedJSONString())
        } catch {
            log(identifier, "\(error)")
        }
    }
    
    /// Log a message with an identifier.
    ///
    /// - Parameters:
    ///   - identifier: an identifier.
    ///   - message: a message.
    public func log(_ identifier: String, _ message: String) {
        ClientLogger.log(icon, dateTime: Date().log, "\(identifier) \(message)")
    }
    
    /// Log a message.
    ///
    /// - Parameter message: a message.
    public func log(_ message: String) {
        ClientLogger.log(icon, dateTime: Date().log, message)
    }
    
    /// Log a message.
    ///
    /// - Parameters:
    ///   - icon: a string icon, e.g. emoji.
    ///   - dateTime: a date time as a string.
    ///   - message: a message.
    public static func log(_ icon: String, dateTime: String = "", _ message: String) {
        ClientLogger.logger(icon, dateTime, message)
    }
}

extension Data {
    func prettyPrintedJSONString() throws -> String {
        let object = try JSONSerialization.jsonObject(with: self)
        let data = try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted])
        return String(data: data, encoding: .utf8) ?? data.description
    }
    
    mutating func append(_ string: String, encoding: String.Encoding = .utf8) {
        append(string.data(using: encoding, allowLossyConversion: false)!)
    }
}

extension Date {
    
    private static let logDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM HH:mm:ss.SSS"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter
    }()
    
    /// A string of the date for the `ClientLogger`.
    public var log: String {
        return Date.logDateFormatter.string(from: self)
    }
}
