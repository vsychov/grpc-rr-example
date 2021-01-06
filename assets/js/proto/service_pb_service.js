// package: app
// file: service.proto

var service_pb = require("./service_pb");
var grpc = require("@improbable-eng/grpc-web").grpc;

var Echo = (function () {
  function Echo() {}
  Echo.serviceName = "app.Echo";
  return Echo;
}());

Echo.Ping = {
  methodName: "Ping",
  service: Echo,
  requestStream: false,
  responseStream: false,
  requestType: service_pb.Message,
  responseType: service_pb.Message
};

exports.Echo = Echo;

function EchoClient(serviceHost, options) {
  this.serviceHost = serviceHost;
  this.options = options || {};
}

EchoClient.prototype.ping = function ping(requestMessage, metadata, callback) {
  if (arguments.length === 2) {
    callback = arguments[1];
  }
  var client = grpc.unary(Echo.Ping, {
    request: requestMessage,
    host: this.serviceHost,
    metadata: metadata,
    transport: this.options.transport,
    debug: this.options.debug,
    onEnd: function (response) {
      if (callback) {
        if (response.status !== grpc.Code.OK) {
          var err = new Error(response.statusMessage);
          err.code = response.status;
          err.metadata = response.trailers;
          callback(err, null);
        } else {
          callback(null, response.message);
        }
      }
    }
  });
  return {
    cancel: function () {
      callback = null;
      client.close();
    }
  };
};

exports.EchoClient = EchoClient;

