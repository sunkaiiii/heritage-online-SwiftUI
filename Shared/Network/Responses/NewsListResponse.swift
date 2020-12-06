//
//  NewsListResponse.swift
//  heritage-online-SwiftUI
//
//  Created by 孙楷 on 6/12/20.
//

import Foundation

// MARK: - NewsListResponseElement
struct NewsListInfo: Codable,Identifiable {
    let id, link, title: String
    let img: String?
    let date, content: String
    let compressImg: String?
}

typealias NewsListResponse = [NewsListInfo]
