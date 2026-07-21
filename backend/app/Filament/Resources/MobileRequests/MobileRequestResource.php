<?php

namespace App\Filament\Resources\MobileRequests;

use App\Filament\Concerns\HasAdminTranslations;
use App\Filament\Resources\MobileRequests\Pages\CreateMobileRequest;
use App\Filament\Resources\MobileRequests\Pages\EditMobileRequest;
use App\Filament\Resources\MobileRequests\Pages\ListMobileRequests;
use App\Filament\Resources\MobileRequests\Schemas\MobileRequestForm;
use App\Filament\Resources\MobileRequests\Tables\MobileRequestsTable;
use App\Models\MobileRequest;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;

class MobileRequestResource extends Resource
{
    use HasAdminTranslations;

    protected static ?string $model = MobileRequest::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedRectangleStack;

    protected static function translationKey(): string
    {
        return 'mobile_requests';
    }

    public static function form(Schema $schema): Schema
    {
        return MobileRequestForm::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return MobileRequestsTable::configure($table);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => ListMobileRequests::route('/'),
            'create' => CreateMobileRequest::route('/create'),
            'edit' => EditMobileRequest::route('/{record}/edit'),
        ];
    }
}
