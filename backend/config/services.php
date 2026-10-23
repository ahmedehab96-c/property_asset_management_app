<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Third Party Services
    |--------------------------------------------------------------------------
    |
    | This file is for storing the credentials for third party services such
    | as Mailgun, Postmark, AWS and more. This file provides the de facto
    | location for this type of information, allowing packages to have
    | a conventional file to locate the various service credentials.
    |
    */

    'postmark' => [
        'key' => env('POSTMARK_API_KEY'),
    ],

    'resend' => [
        'key' => env('RESEND_API_KEY'),
    ],

    'ses' => [
        'key' => env('AWS_ACCESS_KEY_ID'),
        'secret' => env('AWS_SECRET_ACCESS_KEY'),
        'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
    ],

    'slack' => [
        'notifications' => [
            'bot_user_oauth_token' => env('SLACK_BOT_USER_OAUTH_TOKEN'),
            'channel' => env('SLACK_BOT_USER_DEFAULT_CHANNEL'),
        ],
    ],

    'openai' => [
        'key' => env('OPENAI_API_KEY'),
        'base_url' => env('OPENAI_BASE_URL', 'https://api.openai.com/v1'),
        'vision_model' => env('OPENAI_VISION_MODEL', 'gpt-4o-mini'),
    ],

    'gemini' => [
        'key' => env('GEMINI_API_KEY'),
        'base_url' => env('GEMINI_BASE_URL', 'https://generativelanguage.googleapis.com/v1beta'),
        'model' => env('GEMINI_MODEL', 'gemini-3.1-flash-lite'),
        'temperature' => (float) env('GEMINI_TEMPERATURE', 0.7),
        'timeout' => (int) env('GEMINI_TIMEOUT', 60),
        'agent' => [
            'max_steps' => (int) env('AI_AGENT_MAX_STEPS', 4),
            'max_output_tokens' => (int) env('AI_AGENT_MAX_OUTPUT_TOKENS', 1024),
            'history_messages' => (int) env('AI_AGENT_HISTORY_MESSAGES', 12),
            'per_minute' => (int) env('AI_AGENT_PER_MINUTE', 10),
            'per_day' => (int) env('AI_AGENT_PER_DAY', 200),
            'action_ttl_minutes' => (int) env('AI_AGENT_ACTION_TTL_MINUTES', 30),
        ],
    ],

];
