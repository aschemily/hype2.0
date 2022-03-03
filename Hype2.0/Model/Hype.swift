//
//  Hype.swift
//  Hype2.0
//
//  Created by Emily Asch on 3/1/22.
//

import UIKit
import CloudKit

struct HypeStringsStruct{
    static let recordTypeKey = "Hype"
 fileprivate   static let bodyKey = "body"
  fileprivate  static let timeStampKey = "timestamp"
    fileprivate static let userReferenceKey = "userReference"
    fileprivate static let photoAssetKey = "photoAsset"
}

class Hype{
    var body: String
    var timestamp: Date
    var hypePhoto: UIImage?{
        get{
            guard let photoData = self.photoData else {return nil}
            return UIImage(data: photoData)
        }set{
            photoData = newValue?.jpegData(compressionQuality: 0.5)
        }
    }
    var photoData: Data?
    
    var recordID: CKRecord.ID
    var userReference: CKRecord.Reference?
    var photoAsset: CKAsset?{
        get{
            let tempDirectory = NSTemporaryDirectory()
            let tempDirectoryURL = URL(fileURLWithPath: tempDirectory)
            let fileURL = tempDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
            do{
                try photoData?.write(to: fileURL)
            }catch{
                print("🔴error in \(#function), \(error.localizedDescription), \(error)🔴")
            }
            return CKAsset(fileURL: fileURL)
        }
        
    }
    
    init(body: String, timestamp: Date = Date(), hypePhoto: UIImage? = nil, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), userReference: CKRecord.Reference?){
        self.body = body
        self.timestamp = timestamp
        self.recordID = recordID
        self.userReference = userReference
        self.hypePhoto = hypePhoto
    }
    
    
}//end of class

extension Hype{
    //taking a CKRecord and pulling values out to initialize our Hype model
    convenience init?(ckRecord: CKRecord){
        guard let body = ckRecord[HypeStringsStruct.bodyKey] as? String,
              let timestamp = ckRecord[HypeStringsStruct.timeStampKey] as? Date
        else {return nil}
        
        let userReference = ckRecord[HypeStringsStruct.userReferenceKey] as? CKRecord.Reference
        
        var foundPhoto: UIImage?
        if let photoAsset = ckRecord[HypeStringsStruct.photoAssetKey] as? CKAsset{
            do{
                let data = try Data(contentsOf: photoAsset.fileURL!)
                foundPhoto = UIImage(data: data)
            }catch{
               print("could not transform asset to data")
            }
        }
        
        self.init(body: body, timestamp: timestamp, hypePhoto: foundPhoto, recordID: ckRecord.recordID, userReference: userReference)
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
            HypeStringsStruct.timeStampKey: hype.timestamp,
            HypeStringsStruct.userReferenceKey : hype.userReference,
            HypeStringsStruct.photoAssetKey : hype.photoAsset
        ])
    }
}
