<?php

namespace App\Filament\Resources\CalendarEvents\Schemas;

use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Schemas\Schema;

class CalendarEventForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Select::make('property_id')
                    ->relationship('property', 'name'),
                Select::make('owner_id')
                    ->relationship('owner', 'name'),
                TextInput::make('title')
                    ->required(),
                TextInput::make('type')
                    ->required()
                    ->default('maintenance'),
                DatePicker::make('date')
                    ->required(),
                TextInput::make('time'),
                TextInput::make('amount')
                    ->numeric(),
                Textarea::make('notes')
                    ->columnSpanFull(),
            ]);
    }
}
