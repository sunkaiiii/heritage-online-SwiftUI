//
//  HomePageList.swift
//  heritage-online-SwiftUI
//
//  Created by 孙楷 on 6/12/20.
//

import SwiftUI

struct HomePageList: View {
    @ObservedObject var newsListModel = NewsListViewModel()
    var title:String
    var body: some View {
        NavigationView{
            VStack{
                BannerView()
                List(newsListModel.newsList){ news in
                    HomePageCardView(newsList: news)
                }.navigationBarTitle(Text(title))
            }

        }
    }
}

struct HomePageList_Previews: PreviewProvider {
    static var previews: some View {
        HomePageList(title: "HomePage")
    }
}
