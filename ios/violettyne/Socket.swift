class Socket {
    private static let singleton = Socket()
    
    private static var sioSocket: SIOSocket?
    private static var isConnected = false
    
    static var onReceiveLocation: ((String, Double, Double) -> (Void)) = {_, _, _ in}
    /// current location
    static var getCurrentLocation: ((Void) -> (CLLocation?)) = {nil}

    private init() {
        SIOSocket.socketWithHost("http://localhost:3000") {socket in // TODO config
            Socket.sioSocket = socket
            
            socket.onConnect = {
                Socket.onConnect()
            }
            socket.onDisconnect = {
                Socket.isConnected = false
            }
            socket.onReconnect = {numberOfAttempts in
                Socket.onConnect()
            }
            
            socket.on(EventName.Message.rawValue) {args in
                if let userID = args[0] as? String {
                    if let text = args[1] as? String {
                        MessageReceiver.receiveMessage(userID, text: text)
                    }
                }
            }
            
            socket.on(EventName.Location.rawValue) {args in
                if let userID = args[0] as? String {
                    if let latitude = args[1] as? Double {
                        if let longitude = args[2] as? Double {
                            Socket.onReceiveLocation(userID, latitude, longitude)
                        }
                    }
                }
            }
        }
    }
    
    private func noop() {
        // instance method to be called only to make sure `singleton` is instantiated
    }
    
    private class func onConnect() {
        singleton.noop()
        
        Socket.isConnected = true
        Socket.sioSocket?.emit(EventName.ID.rawValue, args: [PersistentStorage.getMyself().id])
        Socket.updateLocation()
    }
    
    class func updateLocation() {
        singleton.noop()

        if Socket.isConnected {
            if let l = Socket.getCurrentLocation() {
                Socket.sioSocket?.emit(EventName.Location.rawValue, args: [l.coordinate.latitude, l.coordinate.longitude])
            }
        }
    }
    
    class func sendMessage(neighbor: User, message: Message) {
        singleton.noop()

        Socket.sioSocket?.emit(EventName.Message.rawValue, args: [neighbor.id, message.text])
    }
}

enum EventName: String {
    case ID = "id"
    case Location = "location"
    case Message = "message"
}
