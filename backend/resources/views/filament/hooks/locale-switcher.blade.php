@php
    $current = app()->getLocale();
    $locales = [
        'ar' => [
            'label' => __('admin.arabic'),
            'flag' => '🇸🇦',
            'code' => 'AR',
        ],
        'en' => [
            'label' => __('admin.english'),
            'flag' => '🇺🇸',
            'code' => 'EN',
        ],
    ];
    $active = $locales[$current] ?? $locales['en'];
@endphp

<div
    @class([
        'fi-locale-switcher',
        'fi-locale-switcher--centered' => ($centered ?? false) === true,
    ])
    x-data="{ open: false }"
    @keydown.escape.window="open = false"
    @click.outside="open = false"
>
    <button
        type="button"
        class="fi-locale-trigger"
        @click="open = ! open"
        :aria-expanded="open"
        aria-haspopup="listbox"
        aria-label="{{ __('admin.language') }}"
        title="{{ __('admin.language') }}"
    >
        <span class="fi-locale-trigger__icon" aria-hidden="true">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75">
                <circle cx="12" cy="12" r="9" />
                <path d="M3 12h18M12 3c2.5 2.8 3.8 6.2 3.8 9s-1.3 6.2-3.8 9M12 3c-2.5 2.8-3.8 6.2-3.8 9s1.3 6.2 3.8 9" />
            </svg>
        </span>
        <span class="fi-locale-trigger__badge">{{ $active['code'] }}</span>
        <span class="fi-locale-trigger__chevron" :class="{ 'is-open': open }" aria-hidden="true">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M5.23 7.21a.75.75 0 011.06.02L10 11.168l3.71-3.938a.75.75 0 111.08 1.04l-4.25 4.5a.75.75 0 01-1.08 0l-4.25-4.5a.75.75 0 01.02-1.06z" clip-rule="evenodd" />
            </svg>
        </span>
    </button>

    <div
        x-show="open"
        x-transition:enter="fi-locale-menu-enter"
        x-transition:enter-start="fi-locale-menu-enter-start"
        x-transition:enter-end="fi-locale-menu-enter-end"
        x-transition:leave="fi-locale-menu-leave"
        x-transition:leave-start="fi-locale-menu-leave-start"
        x-transition:leave-end="fi-locale-menu-leave-end"
        class="fi-locale-menu"
        role="listbox"
        x-cloak
    >
        <p class="fi-locale-menu__title">{{ __('admin.language') }}</p>
        @foreach ($locales as $code => $locale)
            <a
                href="{{ route('admin.locale.switch', ['locale' => $code]) }}"
                class="fi-locale-option {{ $current === $code ? 'is-active' : '' }}"
                role="option"
                aria-selected="{{ $current === $code ? 'true' : 'false' }}"
            >
                <span class="fi-locale-option__flag" aria-hidden="true">{{ $locale['flag'] }}</span>
                <span class="fi-locale-option__text">
                    <span class="fi-locale-option__label">{{ $locale['label'] }}</span>
                    <span class="fi-locale-option__code">{{ $locale['code'] }}</span>
                </span>
                @if ($current === $code)
                    <span class="fi-locale-option__check" aria-hidden="true">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
                            <path fill-rule="evenodd" d="M16.704 5.29a1 1 0 010 1.42l-7.25 7.25a1 1 0 01-1.42 0l-3.25-3.25a1 1 0 111.42-1.42l2.54 2.54 6.54-6.54a1 1 0 011.42 0z" clip-rule="evenodd" />
                        </svg>
                    </span>
                @endif
            </a>
        @endforeach
    </div>
</div>
