<?php

namespace App\Filament\Concerns;

trait HasAdminTranslations
{
    abstract protected static function translationKey(): string;

    public static function getNavigationLabel(): string
    {
        return __('admin.nav.'.static::translationKey());
    }

    public static function getModelLabel(): string
    {
        return __('admin.models.'.static::translationKey());
    }

    public static function getPluralModelLabel(): string
    {
        return __('admin.nav.'.static::translationKey());
    }
}
