<?php

declare(strict_types=1);

namespace App\ProtoServices;

use App\Proto\EchoInterface;
use App\Proto\Message;
use Baldinof\RoadRunnerBundle\Grpc\GrpcServiceInterface;
use Spiral\GRPC\ContextInterface;

class EchoService implements EchoInterface, GrpcServiceInterface
{
    public function Ping(ContextInterface $ctx, Message $in): Message
    {
        $out = new Message();

        return $out->setMsg(strtoupper($in->getMsg()));
    }

    public static function getImplementedInterface(): string
    {
        return EchoInterface::class;
    }
}