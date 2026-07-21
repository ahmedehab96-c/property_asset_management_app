<?php

namespace App\Filament\Resources\MobileRequests\Pages;

use App\Filament\Resources\MobileRequests\MobileRequestResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListMobileRequests extends ListRecords
{
    protected static string $resource = MobileRequestResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make(),
        ];
    }
}
