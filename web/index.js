var app = require('express')();
var http = require('http').Server(app);
var io = require('socket.io')(http);
var crypto = require('crypto');
var util = require('util');
var fs = require('fs');

var clientToSocket = {};
var socketToClient = {};
var salt = (fs.readFileSync('salt.txt') + '').trim();

function convertToClientID(deviceID) {
  return crypto.createHash('sha1').update(deviceID + salt).digest('hex');
}

function register(deviceID, socketID) {
  var clientID = convertToClientID(deviceID);
  clientToSocket[clientID] = socketID;
  socketToClient[socketID] = clientID;
}

function getClientID(socketID) {
  return socketToClient[socketID];
}

function getSocketID(clientID) {
  return clientToSocket[clientID];
}

app.get('/', function(req, res){
  res.sendFile(__dirname + '/index.html');
});

io.on('connection', function(socket){
  socket.on('id', function(deviceID) {
    register(deviceID, socket['id']);
    console.log('client ID: ' + getClientID(socket['id']));
  });

  socket.on('message', function(receiverID, message){
    if ((message == undefined) || (message == "")) {
      return;
    }
    var senderID = getClientID(socket['id']);
    var receiverSocketID = getSocketID(receiverID);
    if (receiverSocketID == undefined) {
      return;
    }
    io.to(receiverSocketID).emit('message', senderID, message);
  });

  socket.on('location', function(lng, lat){
    socket.broadcast.volatile.emit(
      'location',
      getClientID(socket['id']),
      lng+(Math.random()-0.5)/100,
      lat+(Math.random()-0.5)/100
    );
  });
});

http.listen(3000, function(){
  console.log('listening on *:3000');
});
