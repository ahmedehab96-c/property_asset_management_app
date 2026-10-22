<?php

namespace App\Services\Agent;

use App\Models\User;

/**
 * A function the agent may call. Arguments are validated against rules()
 * before execute() ever sees them; the model never runs anything else.
 */
abstract class AgentTool
{
    abstract public function name(): string;

    abstract public function description(): string;

    /**
     * Gemini parameter schema (OpenAPI subset). Empty for no-argument tools.
     *
     * @return array<string, mixed>
     */
    public function parameters(): array
    {
        return [];
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [];
    }

    /** Writes return true: they become pending actions the user must confirm. */
    public function requiresConfirmation(): bool
    {
        return false;
    }

    /** Human-readable summary of a proposed write, shown on the confirm card. */
    public function describe(array $arguments, string $locale): string
    {
        return $this->name();
    }

    /**
     * @param  array<string, mixed>  $arguments  already validated
     * @return array<string, mixed>
     */
    abstract public function execute(array $arguments, User $user): array;

    /**
     * @return array<string, mixed>
     */
    public function declaration(): array
    {
        $declaration = ['name' => $this->name(), 'description' => $this->description()];

        if ($this->parameters() !== []) {
            $declaration['parameters'] = $this->parameters();
        }

        return $declaration;
    }

    protected function limitArg(array $arguments): int
    {
        return (int) ($arguments['limit'] ?? 10);
    }

    /**
     * @return array<string, mixed>
     */
    protected static function limitSchema(): array
    {
        return ['type' => 'INTEGER', 'description' => 'Max rows to return (1-20, default 10).'];
    }
}
