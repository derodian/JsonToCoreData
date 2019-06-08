//
//  FileListCell.swift
//  JsonToCoreData
//
//  Created by Googoo on 6/6/19.
//  Copyright © 2019 Derodian. All rights reserved.
//

import UIKit

class FileListCell: UITableViewCell {
    
    @IBOutlet weak var fileTitleLabel: UILabel!
    @IBOutlet weak var uploadDateLabel: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    

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
    }

    @IBAction func downloadTapped(_ sender: Any) {
    }
    
    @IBAction func pauseOrResumeTapped(_ sender: Any) {
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
    }
    
}
