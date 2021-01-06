import {grpc} from "@improbable-eng/grpc-web";

// Import code-generated data structures.
import {Echo} from "./proto/service_pb_service";
import {Message} from "./proto/service_pb";

const message = new Message();
message.setMsg('ssss');

grpc.unary(Echo.Ping, {
    request: message,
    host: 'http://localhost:8090', //TODO: move to env
    transport: grpc.WebsocketTransport(),
    onEnd: res => {
        const { status, statusMessage, headers, message, trailers } = res;
        if (status === grpc.Code.OK && message) {
            console.log(message.toObject());
        }
    }
});