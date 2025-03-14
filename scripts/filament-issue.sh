#!/usr/bin/env bash

function create-app-filament-issue-3.x {
  repro_dir="app-filament-issue-3.x"

  # Prepare dir and cd into it
  rm -rf $repro_dir
  composer create-project laravel/laravel $repro_dir
  cd $repro_dir

  # Prepare .env
  cp .env.example .env

  # Create SQLite database file
  touch database/database.sqlite

  # Install FilamentPHP
  composer require filament/filament:"^3.0-stable" -W
  php artisan filament:install --panels --no-interaction
  
  # Install auto-login functionality
  install_auto_login
  
  # Add root redirect to admin panel
  add_root_redirect_to_admin_panel
  
  # Run migrations with seeding
  php artisan migrate:fresh --seed

  # Back to root and package
  cd -
  package_zip_file filament-issue-3.x
}

function install_auto_login {
  # Ensure the Auth directory exists
  mkdir -p app/Filament/Pages/Auth

  # Copy the Login.php stub to app/Filament/Pages/Auth/Login.php
  cp "$(dirname "$0")/../stubs/Filament/Login.php" app/Filament/Pages/Auth/Login.php

  # Update the AdminPanelProvider.php file to use the custom login page
  sed -i '' "s/->login()/->login(\\\\App\\\\Filament\\\\Pages\\\\Auth\\\\Login::class)/" app/Providers/Filament/AdminPanelProvider.php

  # Replace test@example.com with test@filamentphp.com if needed
  sed -i '' "s/'email' => 'test@example.com'/'email' => 'test@filamentphp.com'/" database/seeders/DatabaseSeeder.php
  
  echo "Auto-login functionality installed successfully."
}

function add_root_redirect_to_admin_panel {
  # Replace the default welcome route with a redirect to the admin panel
  sed -i '' "s|return view('welcome');|return redirect('/admin');|" routes/web.php
}

function package_zip_file() {
    package_name=$1
    output_dir="filament-issue"

    # Create output directory if it doesn't exist
    rm -rf "$output_dir"
    mkdir -p "$output_dir"

    # Create zip file
    zip -r "$output_dir/$1.zip" "app-$1"
}
