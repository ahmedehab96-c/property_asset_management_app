<?php

namespace App\Support;

/** Resolves a field to its `{field}_ar` sibling when the request locale is Arabic. */
trait Localizable
{
    public function localized(string $field): ?string
    {
        if (app()->getLocale() === 'ar') {
            $value = $this->{$field.'_ar'} ?? null;
            if (filled($value)) {
                return $value;
            }
        }

        return $this->{$field};
    }
}
