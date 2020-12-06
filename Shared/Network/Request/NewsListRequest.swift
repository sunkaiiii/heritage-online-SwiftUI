//
//  NewsListRequest.swift
//  heritage-online-SwiftUI
//
//  Created by 孙楷 on 6/12/20.
//

import Foundation

struct NewsListRequest:SimpleRequestModel{

    
    let page:Int
    
    func getQueryParameter() -> [String : String] {
        return [:]
    }
    
    func getPathParameter() -> [String] {
        return ["\(page)"]
    }
}
