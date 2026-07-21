<?php

namespace App\Filament\Resources\AppNotifications\Schemas;

use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Schemas\Schema;

class AppNotificationForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Select::make('user_id')
                    ->relationship('user', 'name')
                    ->required(),
                TextInput::make('title')
                    ->required(),
                Textarea::make('message')
                    ->columnSpanFull(),
                TextInput::make('type')
                    ->required()
                    ->default('info'),
                DateTimePicker::make('read_at'),
            ]);
    }
}
