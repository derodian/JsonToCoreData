//
//  Download.swift
//  JsonToCoreData
//
//  Created by Googoo on 6/10/19.
//  Copyright © 2019 Derodian. All rights reserved.
//

import Foundation

class Download {
    
    var file: File
    init(file: File) {
        self.file = file
    }
    
    // Download service sets these values
    var task: URLSessionDownloadTask?
    var isDownloading = false
    var resumeData: Data?
    
    // Download delegate sets this value
    var progress: Float = 0
}
