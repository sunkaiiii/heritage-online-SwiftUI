//
//  NewsListViewModel.swift
//  heritage-online-SwiftUI
//
//  Created by 孙楷 on 6/12/20.
//

import Foundation

class NewsListViewModel:ObservableObject,DefaultHttpRequestAction{

    
    @Published var newsList:[NewsListInfo] = []
    var page = 1
    
    init() {
        requestRestfulService(api: HeritageAPI.getNewsList, model: NewsListRequest(page: page), jsonType: NewsListResponse.self)
    }
    
    func handleResponseDataFromRestfulRequest(helper: RequestHelper, url: URLComponents, accessibleData: AccessibleNetworkData) {
        let newsList:NewsListResponse = accessibleData.retriveData()
        self.newsList.append(contentsOf: newsList)
    }
}
