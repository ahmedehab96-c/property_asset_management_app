<?php

namespace App\Filament\Resources\MobileRequests\Pages;

use App\Filament\Resources\MobileRequests\MobileRequestResource;
use Filament\Actions\DeleteAction;
use Filament\Resources\Pages\EditRecord;

class EditMobileRequest extends EditRecord
{
    protected static string $resource = MobileRequestResource::class;

    protected function getHeaderActions(): array
    {
        return [
            DeleteAction::make(),
        ];
    }
}
