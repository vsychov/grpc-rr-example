// package: app
// file: service.proto

import * as service_pb from "./service_pb";
import {grpc} from "@improbable-eng/grpc-web";

type EchoPing = {
  readonly methodName: string;
  readonly service: typeof Echo;
  readonly requestStream: false;
  readonly responseStream: false;
  readonly requestType: typeof service_pb.Message;
  readonly responseType: typeof service_pb.Message;
};

export class Echo {
  static readonly serviceName: string;
  static readonly Ping: EchoPing;
}

export type ServiceError = { message: string, code: number; metadata: grpc.Metadata }
export type Status = { details: string, code: number; metadata: grpc.Metadata }

interface UnaryResponse {
  cancel(): void;
}
interface ResponseStream<T> {
  cancel(): void;
  on(type: 'data', handler: (message: T) => void): ResponseStream<T>;
  on(type: 'end', handler: (status?: Status) => void): ResponseStream<T>;
  on(type: 'status', handler: (status: Status) => void): ResponseStream<T>;
}
interface RequestStream<T> {
  write(message: T): RequestStream<T>;
  end(): void;
  cancel(): void;
  on(type: 'end', handler: (status?: Status) => void): RequestStream<T>;
  on(type: 'status', handler: (status: Status) => void): RequestStream<T>;
}
interface BidirectionalStream<ReqT, ResT> {
  write(message: ReqT): BidirectionalStream<ReqT, ResT>;
  end(): void;
  cancel(): void;
  on(type: 'data', handler: (message: ResT) => void): BidirectionalStream<ReqT, ResT>;
  on(type: 'end', handler: (status?: Status) => void): BidirectionalStream<ReqT, ResT>;
  on(type: 'status', handler: (status: Status) => void): BidirectionalStream<ReqT, ResT>;
}

export class EchoClient {
  readonly serviceHost: string;

  constructor(serviceHost: string, options?: grpc.RpcOptions);
  ping(
    requestMessage: service_pb.Message,
    metadata: grpc.Metadata,
    callback: (error: ServiceError|null, responseMessage: service_pb.Message|null) => void
  ): UnaryResponse;
  ping(
    requestMessage: service_pb.Message,
    callback: (error: ServiceError|null, responseMessage: service_pb.Message|null) => void
  ): UnaryResponse;
}

