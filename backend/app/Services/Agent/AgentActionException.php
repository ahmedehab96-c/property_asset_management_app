<?php

namespace App\Services\Agent;

use RuntimeException;

/** A pending action could not be confirmed or cancelled. */
class AgentActionException extends RuntimeException
{
    public function __construct(public readonly string $reason, public readonly int $status)
    {
        parent::__construct($reason);
    }
}
