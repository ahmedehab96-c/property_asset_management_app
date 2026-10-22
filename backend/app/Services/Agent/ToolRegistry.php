<?php

namespace App\Services\Agent;

use App\Services\Agent\Tools\CreateMaintenanceRequestTool;
use App\Services\Agent\Tools\GetPortfolioSummaryTool;
use App\Services\Agent\Tools\ListContractsTool;
use App\Services\Agent\Tools\ListMaintenanceRequestsTool;
use App\Services\Agent\Tools\ListPaymentsTool;
use App\Services\Agent\Tools\SearchPropertiesTool;
use App\Services\Agent\Tools\SearchTenantsTool;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\ValidationException;

/** The only functions the agent can reach. Anything not listed here is rejected. */
class ToolRegistry
{
    /** @var array<string, AgentTool> */
    private array $tools = [];

    public function __construct(
        GetPortfolioSummaryTool $summary,
        SearchPropertiesTool $properties,
        SearchTenantsTool $tenants,
        ListContractsTool $contracts,
        ListPaymentsTool $payments,
        ListMaintenanceRequestsTool $maintenance,
        CreateMaintenanceRequestTool $createMaintenance,
    ) {
        foreach (func_get_args() as $tool) {
            $this->tools[$tool->name()] = $tool;
        }
    }

    public function get(string $name): ?AgentTool
    {
        return $this->tools[$name] ?? null;
    }

    /**
     * @return list<array<string, mixed>>
     */
    public function declarations(): array
    {
        return array_values(array_map(fn (AgentTool $tool) => $tool->declaration(), $this->tools));
    }

    /**
     * Keeps only declared keys and validates them.
     *
     * @return array<string, mixed>
     *
     * @throws ValidationException
     */
    public function validate(AgentTool $tool, mixed $arguments): array
    {
        $arguments = is_array($arguments) ? $arguments : [];
        $allowed = array_keys($tool->rules());

        return Validator::make(array_intersect_key($arguments, array_flip($allowed)), $tool->rules())->validate();
    }
}
