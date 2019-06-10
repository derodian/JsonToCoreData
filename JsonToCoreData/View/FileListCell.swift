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
    
    func configureCellWith(file: File) {
        DispatchQueue.main.async {
            self.fileTitleLabel.text = file.name
            self.uploadDateLabel.text = file.uploadDate
        }
        
        // Show/hide download controls Pause/Resume, Cancel buttons, progress info
        // TODO
        // Non-nil Download object means a download is in progress
        // TODO
        
        // If the file is already downloaded, enable cell selection and hide the Download button
        selectionStyle = file.downloaded ? UITableViewCell.SelectionStyle.gray : UITableViewCell.SelectionStyle.none
        downloadButton.isHidden = file.downloaded
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
    
}
