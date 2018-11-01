//
//  VideoGetStructs.swift
//  iina+
//
//  Created by xjbeta on 2018/11/1.
//  Copyright © 2018 xjbeta. All rights reserved.
//

import Cocoa
import Marshal

protocol LiveInfo {
    var title: String { get }
    var name: String { get }
    var userCover: NSImage? { get }
    var isLiving: Bool { get }
}

struct BilibiliInfo: Unmarshaling, LiveInfo {
    var title: String = ""
    var name: String = ""
    var userCover: NSImage?
    var isLiving = false
    var roomId: Int = -1
    
    init() {
    }
    
    init(object: MarshaledObject) throws {
        title = try object.value(for: "title")
        name = try object.value(for: "info.uname")
        
        let userCoverURL: String = try object.value(for: "info.face")
        if let url = URL(string: userCoverURL) {
            userCover = NSImage(contentsOf: url)
        }
        isLiving = "\(try object.any(for: "live_status"))" == "1"
    }
}

struct PandaInfo: Unmarshaling, LiveInfo {
    var title: String = ""
    var name: String = ""
    var userCover: NSImage?
    var isLiving = false
    
    init(object: MarshaledObject) throws {
        title = try object.value(for: "roominfo.name")
        name = try object.value(for: "hostinfo.name")
        let userCoverURL: String = try object.value(for: "hostinfo.avatar")
        if let str = URL(string: userCoverURL)?.lastPathComponent,
            let url = URL(string: "https://i.h2.pdim.gs/" + str) {
            userCover = NSImage(contentsOf: url)
        }
        isLiving = "\(try object.any(for: "roominfo.status"))" == "2"
    }
}

struct DouyuInfo: Unmarshaling, LiveInfo {
    var title: String = ""
    var name: String = ""
    var userCover: NSImage?
    var isLiving = false
    
    init(object: MarshaledObject) throws {
        title = try object.value(for: "room_name")
        name = try object.value(for: "owner_name")
        let userCoverURL: String = try object.value(for: "avatar")
        if let url = URL(string: userCoverURL) {
            userCover = NSImage(contentsOf: url)
        }
        isLiving = "\(try object.any(for: "room_status"))" == "1"
    }
}

struct HuyaInfo: Unmarshaling, LiveInfo {
    var title: String = ""
    var name: String = ""
    var userCover: NSImage?
    var isLiving = false
    
    init(object: MarshaledObject) throws {
        title = try object.value(for: "introduction")
        name = try object.value(for: "nick")
        var userCoverURL: String = try object.value(for: "avatar")
        userCoverURL = userCoverURL.replacingOccurrences(of: "http://", with: "https://")
        if let url = URL(string: userCoverURL) {
            userCover = NSImage(contentsOf: url)
        }
        isLiving = "\(try object.any(for: "isOn"))" == "1"
    }
}

struct PandaXingYanInfo: Unmarshaling, LiveInfo {
    var title: String = ""
    var name: String = ""
    var userCover: NSImage?
    var isLiving = false
    
    init(object: MarshaledObject) throws {
        title = try object.value(for: "roominfo.name")
        name = try object.value(for: "hostinfo.nickName")
        let userCoverURL: String = try object.value(for: "hostinfo.avatar")
        if let str = URL(string: userCoverURL)?.lastPathComponent,
            let url = URL(string: "https://i.h2.pdim.gs/" + str) {
            userCover = NSImage(contentsOf: url)
        }
        isLiving = "\(try object.any(for: "roominfo.playstatus"))" == "1"
    }
}

struct QuanMinInfo: Unmarshaling, LiveInfo {
    var title: String = ""
    var name: String = ""
    var userCover: NSImage?
    var isLiving = false
    
    init(object: MarshaledObject) throws {
        title = try object.value(for: "title")
        name = try object.value(for: "nick")
        let userCoverURL: String = try object.value(for: "avatar")
        if let url = URL(string: userCoverURL) {
            userCover = NSImage(contentsOf: url)
        }
        isLiving = "\(try object.any(for: "status"))" == "2"
    }
}

struct LongZhuInfo: Unmarshaling, LiveInfo {
    var title: String = ""
    var name: String = ""
    var userCover: NSImage?
    var isLiving = false
    
    init(object: MarshaledObject) throws {
        if let title: String = try object.value(for: "live.title") {
            self.title = title
            isLiving = true
        } else {
            self.title = try object.value(for: "defaultTitle")
            isLiving = false
        }
        name = try object.value(for: "username")
        var userCoverURL: String = try object.value(for: "avatar")
        userCoverURL = userCoverURL.replacingOccurrences(of: "http://", with: "https://")
        if let url = URL(string: userCoverURL) {
            userCover = NSImage(contentsOf: url)
        }
    }
}



// MARK: - Bilibili

struct BilibiliVideo: Unmarshaling {
    var videos: [String: String]
    var audios: [String]
    
    
    struct DashObject: Unmarshaling {
        var id: Int
        var url: String
        var backupUrl: [String]
        init(object: MarshaledObject) throws {
            id = try object.value(for: "id")
            url = try object.value(for: "baseUrl")
            backupUrl = try object.value(for: "backupUrl")
        }
    }
    
    init(object: MarshaledObject) throws {
        
        let acceptDescription: [String] = try object.value(for: "accept_description")
        let acceptQuality: [Int] = try object.value(for: "accept_quality")
        
        let video: [DashObject] = try object.value(for: "dash.video")
        let audio: [DashObject] = try object.value(for: "dash.audio")
        
        var videos: [String: String] = [:]
        
        video.forEach {
            guard let index = acceptQuality.firstIndex(of: $0.id),
                index > 0,
                index < acceptDescription.count else {
                    return
            }
            let des = acceptDescription[index]
            videos[des] = $0.url
        }
        self.videos = videos
        audios = audio.map {
            $0.url
        }
    }
}