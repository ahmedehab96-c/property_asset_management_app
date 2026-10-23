<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/** Removes the column left behind by the withdrawn WhatsApp channel. */
return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasColumn('ai_conversations', 'channel')) {
            Schema::table('ai_conversations', function (Blueprint $table) {
                $table->dropColumn('channel');
            });
        }
    }

    public function down(): void
    {
        //
    }
};
