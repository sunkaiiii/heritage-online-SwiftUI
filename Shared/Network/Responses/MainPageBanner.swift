//
//  MainPageBanner.swift
//  heritage-online-SwiftUI (iOS)
//
//  Created by 孙楷 on 22/3/21.
//

import Foundation

struct MainpageBanner: Codable {
    let link,img:String
    let compressImg:String?
}

typealias MainpageBannerResponse = [NewsListInfo]
