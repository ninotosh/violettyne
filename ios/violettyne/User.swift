import Foundation

// NSObject, NSCoding: to be converted to NSData
// Hashable: to use User as a dictionary key
class User: NSObject, NSCoding {
    let id: String
    var name: String?
    var image: UIImage?
    // Hashable
    override var hashValue: Int {
        return id.hashValue
    }
    
    init(id: String) {
        self.id = id
    }
    
    // NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(id, forKey: "id")
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(image, forKey: "image")
    }
    
    // NSCoding
    required init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObjectForKey("id") as! String
        name = aDecoder.decodeObjectForKey("name") as? String
        image = aDecoder.decodeObjectForKey("image") as? UIImage
    }
}

// Hashable: must be at global scope
func ==(lhs: User, rhs: User) -> Bool {
    return lhs.id == rhs.id
}
