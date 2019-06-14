//
//  FileListCell.swift
//  JsonToCoreData
//
//  Created by Googoo on 6/6/19.
//  Copyright © 2019 Derodian. All rights reserved.
//

import UIKit

protocol FileListDelegate {
    func pauseTapped(_ cell: FileListCell)
    func resumeTapped(_ cell: FileListCell)
    func cancelTapped(_ cell: FileListCell)
    func downloadTapped(_ cell: FileListCell)
}

class FileListCell: UITableViewCell {
    
    @IBOutlet weak var fileTitleLabel: UILabel!
    @IBOutlet weak var uploadDateLabel: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    
    // Delegate identifies file for this cell and passes it to a download service method
    var delegate: FileListDelegate?
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCellWith(file: File, download: Download?) {
        DispatchQueue.main.async {
            self.fileTitleLabel.text = file.name
            self.uploadDateLabel.text = String(file.index)
            
            // Show/hide download controls Pause/Resume, Cancel buttons, progress info
            var showDownloadControls = false
            
            // Non-nil Download object means a download is in progress
            if let download = download {
                showDownloadControls = true
                let title = download.isDownloading ? "Pause" : "Resume"
                self.pauseButton.setTitle(title, for: .normal)
                // Show something on progressLabel before getting update from delegate
                self.progressLabel.text = download.isDownloading ? "Downloading..." : "Paused"
            }
            
            // Show buttons if download is active
            self.pauseButton.isHidden = !showDownloadControls
            self.cancelButton.isHidden = !showDownloadControls
            self.progressView.isHidden = !showDownloadControls
            self.progressLabel.isHidden = !showDownloadControls
            
            // If the file is already downloaded, enable cell selection and hide the Download button
            self.selectionStyle = file.downloaded ? UITableViewCell.SelectionStyle.gray : UITableViewCell.SelectionStyle.none
            self.downloadButton.isHidden = file.downloaded || showDownloadControls
        }
        
        
    }

    @IBAction func downloadTapped(_ sender: Any) {
        delegate?.downloadTapped(self)
    }
    
    @IBAction func pauseOrResumeTapped(_ sender: Any) {
        if(pauseButton.titleLabel?.text == "Pause") {
            delegate?.pauseTapped(self)
        } else {
            delegate?.resumeTapped(self)
        }
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        delegate?.cancelTapped(self)
    }
    
    func updateDisplay(progress: Float, totalSize: String) {
        progressView.progress = progress
        progressLabel.text = String(format: "%.1f%% of %@", progress * 100, totalSize)
    }
}
