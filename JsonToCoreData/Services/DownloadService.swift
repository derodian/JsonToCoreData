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
    
//    private init() {}
//    static let instance = DownloadService()
    
    // Maintain mapping between url and its active Download
    var activeDownloads: [URL: Download] = [:]
    
    // Create downloadsSession
    var downloadsSession: URLSession!
    
    // MARK: - Download methods called by FileListCell delegate methods
    
    func startDownload (_ file: File) {
        // Initialize download with the file
        let download = Download(file: file)
        
        // Create URLSessionDownloadTask with file's url and set it to task using new session
        guard let fileUrl = file.fileUrl else { return }
        download.task = downloadsSession.downloadTask(with: fileUrl)
        
        // Start the download task with resume()
        download.task!.resume()
        download.isDownloading = true
        guard let url = download.file.fileUrl else { return }
        activeDownloads[url] = download
    }
    
    func pauseDownload (_ file: File) {
        // Stop download of the file and save data for resume(if supported) to corresponding Download
        guard let fileUrl = file.fileUrl else { return }
        guard let download = activeDownloads[fileUrl] else { return }
        if download.isDownloading {
            download.task?.cancel(byProducingResumeData: { (data) in
                download.resumeData = data
            })
            download.isDownloading = false
        }
    }
    
    func cancelDownload(_ file: File) {
        // Cancel download of the file and remove its entry from activeDownloads
        guard let fileUrl = file.fileUrl else { return }
        if let download = activeDownloads[fileUrl] {
            download.task?.cancel()
            activeDownloads[fileUrl] = nil
        }
    }
    
    func resumeDownload(_ file: File) {
        // Resume(if supported) or start new download of file using resumeData saved for that file
        guard let fileUrl = file.fileUrl else { return }
        guard let download = activeDownloads[fileUrl] else { return }
        if let resumeData = download.resumeData {
            download.task = downloadsSession.downloadTask(withResumeData: resumeData)
        } else {
            download.task = downloadsSession.downloadTask(with: download.file.fileUrl!)
        }
        download.task?.resume()
        download.isDownloading = true
    }
}
