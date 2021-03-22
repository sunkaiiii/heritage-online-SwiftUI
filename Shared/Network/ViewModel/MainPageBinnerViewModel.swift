//
//  MainPageBinnerViewModel.swift
//  heritage-online-SwiftUI (iOS)
//
//  Created by 孙楷 on 22/3/21.
//

import Foundation

class MainPageBinnerViewModel:ObservableObject,DefaultHttpRequestAction{

    @Published var banner:MainpageBannerResponse = []
    init() {
        requestRestfulService(api: HeritageAPI.GetBanner, model: EmptyGetRequest(), jsonType: MainpageBannerResponse.self)
    }
    
    
    func handleResponseDataFromRestfulRequest(helper: RequestHelper, url: URLComponents, accessibleData: AccessibleNetworkData) {
        let data:MainpageBannerResponse = accessibleData.retriveData()
        self.banner = data
    }
}
