import Foundation

class PersistentStorage {
    private class func defaults() -> NSUserDefaults {
        return NSUserDefaults.standardUserDefaults()
    }
}

extension PersistentStorage {
    private class func keyForMyData() -> String {
        return "keyForMyData"
    }

    class func initMyselfIfNecessary() {
        let myData = defaults().objectForKey(keyForMyData()) as? NSData
        if myData == nil {
            if let identifier = UIDevice.currentDevice().identifierForVendor {
                let myself = User(id: identifier.UUIDString)
                myself.name = "anonymous" // TODO
                setMyself(myself)
            }
        }
    }
    
    class func setMyImage(image: UIImage) {
        let myself = getMyself()
        myself.image = image
        setMyself(myself)
    }
    
    class func setMyName(name: String) {
        let myself = getMyself()
        myself.name = name
        setMyself(myself)
    }
    
    private class func setMyself(myself: User) {
        let myData = NSKeyedArchiver.archivedDataWithRootObject(myself)
        defaults().setObject(myData, forKey: keyForMyData())
    }
    
    class func getMyself() -> User {
        if let myData = defaults().objectForKey(keyForMyData()) as? NSData {
            if let myself = NSKeyedUnarchiver.unarchiveObjectWithData(myData) as? User {
                return myself
            }
        }
        return User(id: "")
    }
}

extension PersistentStorage {
    private class func keyForMessages(neighbor: User) -> String {
        return "messages_" + neighbor.id
    }
    
    class func setMessages(neighbor: User, messages: [Message]) {
        let data = NSKeyedArchiver.archivedDataWithRootObject(messages)
        defaults().setObject(data, forKey: keyForMessages(neighbor))
        
        addNeighbor(neighbor)
    }
   
    class func getMessages(neighbor: User) -> [Message] {
        if let data = defaults().objectForKey(keyForMessages(neighbor)) as? NSData {
            if let messages = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [Message] {
                return messages
            }
        }
        return []
    }
}

extension PersistentStorage {
    private class func keyForNeighbors() -> String {
        return "keyForNeighbors"
    }
    
    private class func addNeighbor(neighbor: User) {
        var neighbors = getNeighbors().filter { $0 != neighbor }
        neighbors.insert(neighbor, atIndex: 0)
        setNeighbors(neighbors)
    }
    
    private class func setNeighbors(neighbors: [User]) {
        let data = NSKeyedArchiver.archivedDataWithRootObject(neighbors)
        defaults().setObject(data, forKey: keyForNeighbors())
    }
    
    class func getNeighbors() -> [User] {
        if let data = defaults().objectForKey(keyForNeighbors()) as? NSData {
            if let neighbors = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [User] {
                return neighbors
            }
        }
        return []
    }
}
