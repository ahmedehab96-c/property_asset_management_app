<?php

namespace App\Filament\Resources\Users\Schemas;

use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Schema;

class UserForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('name')
                    ->required(),
                TextInput::make('email')
                    ->label('Email address')
                    ->email()
                    ->required(),
                DateTimePicker::make('email_verified_at'),
                TextInput::make('password')
                    ->password()
                    ->dehydrated(fn (?string $state): bool => filled($state))
                    ->required(fn (string $operation): bool => $operation === 'create'),
                TextInput::make('phone')
                    ->tel(),
                TextInput::make('role')
                    ->required()
                    ->default('owner'),
                Toggle::make('is_admin')
                    ->required(),
                TextInput::make('locale')
                    ->required()
                    ->default('ar'),
                TextInput::make('status')
                    ->required()
                    ->default('active'),
                TextInput::make('address'),
            ]);
    }
}
