//
//  File+CoreDataProperties.swift
//  JsonToCoreData
//
//  Created by Googoo on 6/8/19.
//  Copyright © 2019 Derodian. All rights reserved.
//
//

import Foundation
import CoreData


extension File {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<File> {
        return NSFetchRequest<File>(entityName: "File")
    }

    @NSManaged public var downloaded: Bool
    @NSManaged public var index: Int32
    @NSManaged public var uploadDate: String?
    @NSManaged public var fileUrl: String?
    @NSManaged public var name: String?
    @NSManaged public var id: Int32

}
