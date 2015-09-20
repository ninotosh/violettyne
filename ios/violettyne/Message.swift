class Message: NSObject, NSCoding {
    var date = NSDate()
    let user: User
    let text: String
    
    init(user: User, text: String) {
        self.user = user
        self.text = text
    }
    
    // NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(date, forKey: "date")
        user.encodeWithCoder(aCoder)
        aCoder.encodeObject(text, forKey: "text")
    }
    
    // NSCoding
    required init?(coder aDecoder: NSCoder) {
        date = aDecoder.decodeObjectForKey("date") as! NSDate
        user = User(coder: aDecoder)!
        text = aDecoder.decodeObjectForKey("text") as! String
    }
}
                                                                                                                                                                                                                                                                                                                                                                                                                                        