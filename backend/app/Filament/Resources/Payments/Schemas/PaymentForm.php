<?php

namespace App\Filament\Resources\Payments\Schemas;

use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Schemas\Schema;

class PaymentForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Select::make('tenant_id')
                    ->relationship('tenant', 'name'),
                Select::make('property_id')
                    ->relationship('property', 'name'),
                Select::make('contract_id')
                    ->relationship('contract', 'id'),
                TextInput::make('amount')
                    ->required()
                    ->numeric(),
                DatePicker::make('due_date'),
                DatePicker::make('payment_date'),
                TextInput::make('status')
                    ->required()
                    ->default('pending'),
                TextInput::make('method'),
                Textarea::make('notes')
                    ->columnSpanFull(),
            ]);
    }
}
