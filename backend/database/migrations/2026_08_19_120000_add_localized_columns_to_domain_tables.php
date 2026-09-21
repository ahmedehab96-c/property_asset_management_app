<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('owners', function (Blueprint $table) {
            $table->string('name_ar')->nullable()->after('name');
            $table->string('address_ar')->nullable()->after('address');
        });

        Schema::table('properties', function (Blueprint $table) {
            $table->string('name_ar')->nullable()->after('name');
            $table->string('location_ar')->nullable()->after('location');
            $table->string('address_ar')->nullable()->after('address');
            $table->text('description_ar')->nullable()->after('description');
        });

        Schema::table('tenants', function (Blueprint $table) {
            $table->string('name_ar')->nullable()->after('name');
            $table->string('address_ar')->nullable()->after('address');
        });

        Schema::table('maintenance_requests', function (Blueprint $table) {
            $table->string('title_ar')->nullable()->after('title');
            $table->string('problem_type_ar')->nullable()->after('problem_type');
            $table->text('description_ar')->nullable()->after('description');
        });

        Schema::table('projects', function (Blueprint $table) {
            $table->string('name_ar')->nullable()->after('name');
            $table->string('location_ar')->nullable()->after('location');
            $table->text('description_ar')->nullable()->after('description');
        });

        Schema::table('tasks', function (Blueprint $table) {
            $table->string('title_ar')->nullable()->after('title');
            $table->text('description_ar')->nullable()->after('description');
        });

        Schema::table('calendar_events', function (Blueprint $table) {
            $table->string('title_ar')->nullable()->after('title');
        });

        Schema::table('notifications', function (Blueprint $table) {
            $table->string('title_ar')->nullable()->after('title');
            $table->text('message_ar')->nullable()->after('message');
        });

        Schema::table('reports', function (Blueprint $table) {
            $table->string('title_ar')->nullable()->after('title');
        });

        Schema::table('conversations', function (Blueprint $table) {
            $table->string('subject_ar')->nullable()->after('subject');
        });
    }

    public function down(): void
    {
        Schema::table('owners', fn (Blueprint $table) => $table->dropColumn(['name_ar', 'address_ar']));
        Schema::table('properties', fn (Blueprint $table) => $table->dropColumn(['name_ar', 'location_ar', 'address_ar', 'description_ar']));
        Schema::table('tenants', fn (Blueprint $table) => $table->dropColumn(['name_ar', 'address_ar']));
        Schema::table('maintenance_requests', fn (Blueprint $table) => $table->dropColumn(['title_ar', 'problem_type_ar', 'description_ar']));
        Schema::table('projects', fn (Blueprint $table) => $table->dropColumn(['name_ar', 'location_ar', 'description_ar']));
        Schema::table('tasks', fn (Blueprint $table) => $table->dropColumn(['title_ar', 'description_ar']));
        Schema::table('calendar_events', fn (Blueprint $table) => $table->dropColumn('title_ar'));
        Schema::table('notifications', fn (Blueprint $table) => $table->dropColumn(['title_ar', 'message_ar']));
        Schema::table('reports', fn (Blueprint $table) => $table->dropColumn('title_ar'));
        Schema::table('conversations', fn (Blueprint $table) => $table->dropColumn('subject_ar'));
    }
};
