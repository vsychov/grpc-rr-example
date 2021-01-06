<?php


namespace App\ProtoServices;


use App\Proto\Site;
use App\Proto\SiteId;
use App\Proto\SiteList;
use App\Proto\SiteProviderInterface;
use Baldinof\RoadRunnerBundle\Grpc\GrpcServiceInterface;
use Google\Protobuf;
use Spiral\GRPC;

class SiteProviderService implements GrpcServiceInterface, SiteProviderInterface
{

    public static function getImplementedInterface(): string
    {
        return SiteProviderInterface::class;
    }

    public function List(GRPC\ContextInterface $ctx, Protobuf\GPBEmpty $in): SiteList
    {
        $sites = [new Site(['id' => new SiteId(['uuid' => 'test'])]), new Site(['id' => new SiteId(['uuid' => 'test'])])];

        return (new SiteList())
            ->setSites($sites);
    }

    public function Get(GRPC\ContextInterface $ctx, SiteId $in): Site
    {
        return new Site();
    }
}