<?php

namespace App\Filament\Resources\Conversations\Schemas;

use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Schema;

class ConversationForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('subject'),
                Select::make('owner_id')
                    ->relationship('owner', 'name'),
                Select::make('tenant_id')
                    ->relationship('tenant', 'name'),
                DateTimePicker::make('last_message_at'),
            ]);
    }
}
