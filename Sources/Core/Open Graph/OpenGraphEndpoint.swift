//
//  OpenGraphEndpoint.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 11/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Moya

enum OpenGraphEndpoint {
    case og(_ ulr: URL)
}

extension OpenGraphEndpoint: StreamTargetType {
    
    var path: String {
        return "og/"
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        switch self {
        case .og(let url):
            return .requestParameters(parameters: ["url": url], encoding: URLEncoding.default)
        }
    }
    
    var sampleJSON: String {
        return """
        {"duration":"455.24ms","title":"The Imitation Game (2014)","type":"video.movie","url":"http://www.imdb.com/title/tt2084970/","site_name":"IMDb","description":"Directed by Morten Tyldum.  With Benedict Cumberbatch, Keira Knightley, Matthew Goode, Allen Leech. During World War II, the English mathematical genius Alan Turing tries to crack the German Enigma code with help from fellow mathematicians.","images":[{"image":"https://m.media-amazon.com/images/M/MV5BOTgwMzFiMWYtZDhlNS00ODNkLWJiODAtZDVhNzgyNzJhYjQ4L2ltYWdlXkEyXkFqcGdeQXVyNzEzOTYxNTQ@._V1_UY1200_CR87,0,630,1200_AL_.jpg"}]}
        """
    }
}
