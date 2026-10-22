<?php

namespace App\Services\Agent;

use RuntimeException;

/** The AI provider is not configured or did not return a usable answer. */
class AgentUnavailableException extends RuntimeException
{
    public function __construct(public readonly string $reason)
    {
        parent::__construct($reason);
    }
}
