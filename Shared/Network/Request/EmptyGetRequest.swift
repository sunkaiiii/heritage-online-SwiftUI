//
//  EmptyGetRequest.swift
//  heritage-online-SwiftUI (iOS)
//
//  Created by 孙楷 on 22/3/21.
//

import Foundation

struct EmptyGetRequest:SimpleRequestModel {
    func getQueryParameter() -> [String : String] {
        [:]
    }
    
    
}
