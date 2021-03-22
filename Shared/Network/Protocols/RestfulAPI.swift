//
//  RestfulAPI.swift
//  heritage-online-SwiftUI
//
//  Created by 孙楷 on 6/12/20.
//

import Foundation

import Foundation

let HTTP="http"
let HTTPS = "https"
let HTTP_PORT = 80
let DEFAULT_HTTPS_PORT = 443
enum RequestType{
    case GET
    case POST
    case PUT
    case DELETE
}

/**
  Recording of information about a requested host, every network request must contain an implementation of this interface
 */
protocol Host {
    /**
      Usually a host address
     * Eg. www.google.com
     */
    func getHostUrl()->String
         
     ///The port used by the api, e.g. 80, 5000
    func getPort()->Int
    
    ///scheme is the type of request, e.g. HTTP, HTTPS, FTP
    func getScheme()->String
}

enum RequestHost:Host{
    case heritage_server
    func getHostUrl() -> String {
        switch self {
        case .heritage_server:
            return "sunkai.xyz"
        }
    }
    
    func getPort() -> Int {
        switch self {
        case .heritage_server:
            return 5001
        }
    }
    
    func getScheme() -> String {
        switch self {
        default:
            return HTTPS
        }
    }
}

/**
 # This interface must be implemented for all network requests
 In a web request, the full path to the request api is obtained based on the RequestHost and the router. Setting the header and the action according to the requestType
 */
protocol RestfulAPI {
    
    ///Choose an understandable name for the request, which will probably be used as the default prompt in case of an error.
    func getRequestName()->String
    
    ///route is usually a specific request path after the hostname, e.g. /api/getStatus
    func getRoute()->String
    
    ///GET,POST,PUT,DELETE...or more restful action
    func getRequestType()->RequestType
    
    /**
     - returns The host information will be used to obtain the full url
     */
    func getRequestHost()->RequestHost
}

enum HeritageAPI:RestfulAPI {
    case getNewsList
    case GetBanner
    func getRequestName() -> String {
        switch self {
        case .getNewsList:
            return "GetNewsList"
        case .GetBanner:
            return "GetBanner"
        }
    }
    
    func getRoute() -> String {
        switch self {
        case .getNewsList:
            return "/api/NewsList"
        case .GetBanner:
            return "/api/banner"
        }
    }
    
    func getRequestType() -> RequestType {
        switch self{
        default:
            return .GET
        }
    }
    
    func getRequestHost() -> RequestHost {
        return .heritage_server
    }
}
