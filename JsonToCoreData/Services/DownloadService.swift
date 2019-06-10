//
//  DownloadService.swift
//  JsonToCoreData
//
//  Created by Googoo on 6/9/19.
//  Copyright © 2019 Derodian. All rights reserved.
//

import Foundation
// Downloads files and stores in local file. Allows cancel, pause and resume download
class DownloadService {
    
    private init() {}
    static let instance = DownloadService()
    
    // Create downloadsSession
    var downloadsSession: URLSession
    
    // MARK: - Download methods called by FileListCell delegate methods
    
    func startDownload (_ file: File) {
        
    }
    
    func pauseDownload (_ file: File) {
        
    }
    
    func cancelDownload(_ file: File) {
        
    }
    
    func resumeDownload(_ file: File) {
        
    }
}
