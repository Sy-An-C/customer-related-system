<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Service;
use App\Models\Appointment;
use Illuminate\Support\Facades\Hash;
// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Create admin user
        User::create([
            'name' => 'Admin User',
            'email' => 'admin@example.com',
            'password' => Hash::make('password'),
            'role' => 'admin'
        ]);

        // Create services
        Service::create(['name' => 'Haircut', 'duration_minutes' => 30, 'price' => 25.00]);
        Service::create(['name' => 'Manicure', 'duration_minutes' => 45, 'price' => 35.00]);
        Service::create(['name' => 'Facial', 'duration_minutes' => 60, 'price' => 50.00]);

        // Create sample appointments
        Appointment::factory()->count(10)->create();
    }
}
