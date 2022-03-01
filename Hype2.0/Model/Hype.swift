//
//  Hype.swift
//  Hype2.0
//
//  Created by Emily Asch on 3/1/22.
//

import Foundation
import CloudKit

struct HypeStringsStruct{
    static let recordTypeKey = "Hype"
 fileprivate   static let bodyKey = "body"
  fileprivate  static let timeStampKey = "timestamp"
}

class Hype{
    var body: String
    var timestamp: Date
    var recordID: CKRecord.ID
    
    init(body: String, timestamp: Date = Date(), recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)){
        self.body = body
        self.timestamp = timestamp
        self.recordID = recordID
    }
    
    
}//end of class

extension Hype{
    //taking a CKRecord and pulling values out to initialize our Hype model
    convenience init?(ckRecord: CKRecord){
        guard let body = ckRecord[HypeStringsStruct.bodyKey] as? String,
              let timestamp = ckRecord[HypeStringsStruct.timeStampKey] as? Date
        else {return nil}
        
        self.init(body: body, timestamp: timestamp, recordID: ckRecord.recordID)
    }
}

extension Hype: Equatable{
    static func == (lhs: Hype, rhs: Hype) -> Bool {
        return lhs.recordID == rhs.recordID
    }
    
    
}

extension CKRecord{
    //packaging our hype model properties to be stored in a CKRecord and saved to the cloud
    convenience init(hype: Hype){
        self.init(recordType: HypeStringsStruct.recordTypeKey, recordID: hype.recordID)
//        self.setValue(hype.body, forKey: HypeStringsStruct.bodyKey)
        self.setValuesForKeys([
            HypeStringsStruct.bodyKey: hype.body,
            HypeStringsStruct.timeStampKey: hype.timestamp
        ])
    }
}
