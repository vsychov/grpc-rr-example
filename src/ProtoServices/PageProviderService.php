<?php


namespace App\ProtoServices;


use App\Proto\PageProviderInterface;
use App\Proto\Site;
use App\Proto\SiteId;
use App\Proto\SiteList;
use Baldinof\RoadRunnerBundle\Grpc\GrpcServiceInterface;
use Spiral\GRPC;

class PageProviderService implements GrpcServiceInterface, PageProviderInterface
{
    public static function getImplementedInterface(): string
    {
        return PageProviderInterface::class;
    }

    public function List(GRPC\ContextInterface $ctx, SiteId $in): SiteList
    {
        return new SiteList();
    }

    public function Get(GRPC\ContextInterface $ctx, SiteId $in): Site
    {
        return new Site();
    }
}