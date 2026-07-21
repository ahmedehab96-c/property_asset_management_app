<?php

namespace App\Filament\Resources\Projects\Schemas;

use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Schemas\Schema;

class ProjectForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Select::make('owner_id')
                    ->relationship('owner', 'name'),
                Select::make('property_id')
                    ->relationship('property', 'name'),
                TextInput::make('name')
                    ->required(),
                TextInput::make('location'),
                TextInput::make('status')
                    ->required()
                    ->default('under_construction'),
                TextInput::make('progress')
                    ->required()
                    ->numeric()
                    ->default(0),
                TextInput::make('budget')
                    ->required()
                    ->numeric()
                    ->default(0),
                TextInput::make('paid_amount')
                    ->required()
                    ->numeric()
                    ->default(0),
                DatePicker::make('start_date'),
                DatePicker::make('end_date'),
                Textarea::make('description')
                    ->columnSpanFull(),
            ]);
    }
}
