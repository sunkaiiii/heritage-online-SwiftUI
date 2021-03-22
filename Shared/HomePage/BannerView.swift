//
//  BannerView.swift
//  heritage-online-SwiftUI (iOS)
//
//  Created by 孙楷 on 22/3/21.
//

import SwiftUI

struct BannerView:View{
    @ObservedObject var banner = MainPageBinnerViewModel()
    @State private var currentPage = 0
    var body: some View{
        PagerView(pageCount: 2, currentIndex: $currentPage){
            
        }.frame(width: .none, height: 200)
    }
}
