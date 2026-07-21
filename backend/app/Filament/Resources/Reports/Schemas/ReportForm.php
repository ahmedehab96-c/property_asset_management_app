<?php

namespace App\Filament\Resources\Reports\Schemas;

use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Schemas\Schema;

class ReportForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('title')
                    ->required(),
                TextInput::make('type')
                    ->required()
                    ->default('financial'),
                Select::make('owner_id')
                    ->relationship('owner', 'name'),
                Select::make('property_id')
                    ->relationship('property', 'name'),
                TextInput::make('amount')
                    ->numeric(),
                Textarea::make('meta')
                    ->columnSpanFull(),
            ]);
    }
}
