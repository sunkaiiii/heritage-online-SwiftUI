//
//  HomePageCardView.swift
//  heritage-online-SwiftUI
//
//  Created by 孙楷 on 6/12/20.
//

import SwiftUI

struct HomePageCardView: View {
    let newsList:NewsListInfo
    
    var body: some View {
        VStack(alignment:.leading){
            Text(newsList.title).font(.title).bold()
            Text(newsList.date).foregroundColor(.gray)
            Text(newsList.content)
        }
    }
}

struct HomePageCardView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageCardView(newsList: NewsListInfo(id: "1", link: "/news2_details/21920.html", title: "广东授牌首个省级非遗传播与发展工作站", img: "s5fc9b158371b8_1071_601_0_0.jpeg", date: "2020.12.04", content: "12月1日，2020广东非遗创新发展峰会在广州图书馆举行。广东省文化和旅游厅党组书记、厅长汪一洋出席并为广东首个非物质文化遗产传播与发展工作站——南方文化产权交易所授牌。", compressImg: "s5fc9b158371b8_1071_601_0_0_compress.jpeg"))
    }
}
