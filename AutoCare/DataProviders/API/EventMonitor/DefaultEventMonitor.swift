//
//  DefaultEventMonitor.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 25/03/25.
//


import Foundation
import Alamofire

final class DefaultEventMonitor: EventMonitor {
    func requestDidFinish(_ request: Request) {
        print(request.description)
        
        if let httpBody = request.request?.httpBody,
           let json = try? JSONSerialization.jsonObject(with: httpBody, options: .mutableContainers) {
            print(json)
        }
    }

    func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        guard let data = response.data else {return}
        if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) {
            print(json)
        }
    }
}
