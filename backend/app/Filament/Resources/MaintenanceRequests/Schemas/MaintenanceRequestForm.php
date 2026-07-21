<?php

namespace App\Filament\Resources\MaintenanceRequests\Schemas;

use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Schemas\Schema;

class MaintenanceRequestForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('order_number')
                    ->required(),
                Select::make('property_id')
                    ->relationship('property', 'name'),
                Select::make('tenant_id')
                    ->relationship('tenant', 'name'),
                Select::make('owner_id')
                    ->relationship('owner', 'name'),
                TextInput::make('title')
                    ->required(),
                TextInput::make('problem_type'),
                Textarea::make('description')
                    ->columnSpanFull(),
                TextInput::make('status')
                    ->required()
                    ->default('in_progress'),
                TextInput::make('priority')
                    ->required()
                    ->default('medium'),
            ]);
    }
}
