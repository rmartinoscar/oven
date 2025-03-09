# Documentation for panels. File: 01-installation.md
---
title: Installation
---

## Requirements

Filament requires the following to run:

- PHP 8.1+
- Laravel v10.0+
- Livewire v3.0+

## Installation

> If you are upgrading from Filament v2, please review the [upgrade guide](upgrade-guide).

Install the Filament Panel Builder by running the following commands in your Laravel project directory:

```bash
composer require filament/filament:"^3.3" -W

php artisan filament:install --panels
```

This will create and register a new [Laravel service provider](https://laravel.com/docs/providers) called `app/Providers/Filament/AdminPanelProvider.php`.

> If you get an error when accessing your panel, check that the service provider was registered in `bootstrap/providers.php` (Laravel 11 and above) or `config/app.php` (Laravel 10 and below). If not, you should manually add it.

## Create a user
You can create a new user account with the following command:

```bash
php artisan make:filament-user
```

Open `/admin` in your web browser, sign in, and start building your app!

Not sure where to start? Review the [Getting Started guide](getting-started) to learn how to build a complete Filament admin panel.

## Using other Filament packages
The Filament Panel Builder pre-installs the [Form Builder](/docs/forms), [Table Builder](/docs/tables), [Notifications](/docs/notifications), [Actions](/docs/actions), [Infolists](/docs/infolists), and [Widgets](/docs/widgets) packages. No other installation steps are required to use these packages within a panel.

## Improving Filament panel performance

### Optimizing Filament for production

To optimize Filament for production, you should run the following command in your deployment script:

```bash
php artisan filament:optimize
```

This command will [cache the Filament components](#caching-filament-components) and additionally the [Blade icons](#caching-blade-icons), which can significantly improve the performance of your Filament panels. This command is a shorthand for the commands `php artisan filament:cache-components` and `php artisan icons:cache`.

To clear the caches at once, you can run:

```bash
php artisan filament:optimize-clear
```

#### Caching Filament components

If you're not using the [`filament:optimize` command](#optimizing-filament-for-production), you may wish to consider running `php artisan filament:cache-components` in your deployment script, especially if you have large numbers of components (resources, pages, widgets, relation managers, custom Livewire components, etc.). This will create cache files in the `bootstrap/cache/filament` directory of your application, which contain indexes for each type of component. This can significantly improve the performance of Filament in some apps, as it reduces the number of files that need to be scanned and auto-discovered for components.

However, if you are actively developing your app locally, you should avoid using this command, as it will prevent any new components from being discovered until the cache is cleared or rebuilt.

You can clear the cache at any time without rebuilding it by running `php artisan filament:clear-cached-components`.

#### Caching Blade Icons

If you're not using the [`filament:optimize` command](#optimizing-filament-for-production), you may wish to consider running `php artisan icons:cache` locally, and also in your deployment script. This is because Filament uses the [Blade Icons](https://blade-ui-kit.com/blade-icons) package, which can be much more performant when cached.

### Enabling OPcache on your server

From the [Laravel Forge documentation](https://forge.laravel.com/docs/servers/php.html#opcache):

> Optimizing the PHP OPcache for production will configure OPcache to store your compiled PHP code in memory to greatly improve performance.

Please use a search engine to find the relevant OPcache setup instructions for your environment.

### Optimizing your Laravel app

You should also consider optimizing your Laravel app for production by running `php artisan optimize` in your deployment script. This will cache the configuration files and routes.

## Deploying to production

### Allowing users to access a panel

By default, all `User` models can access Filament locally. However, when deploying to production or running unit tests, you must update your `App\Models\User.php` to implement the `FilamentUser` contract — ensuring that only the correct users can access your panel:

```php
<?php

namespace App\Models;

use Filament\Models\Contracts\FilamentUser;
use Filament\Panel;
use Illuminate\Foundation\Auth\User as Authenticatable;

class User extends Authenticatable implements FilamentUser
{
    // ...

    public function canAccessPanel(Panel $panel): bool
    {
        return str_ends_with($this->email, '@yourdomain.com') && $this->hasVerifiedEmail();
    }
}
```

> If you don't complete these steps, a 403 Forbidden error will be returned when accessing the app in production.

Learn more about [users](users).

### Using a production-ready storage disk

Filament has a storage disk defined in the [configuration](#publishing-configuration), which by default is set to `public`. You can set the `FILAMENT_FILESYSTEM_DISK` environment variable to change this.

The `public` disk, while great for easy local development, is not suitable for production. It does not support file visibility, so features of Filament such as [file uploads](../forms/fields/file-upload) will create public files. In production, you need to use a production-ready disk such as `s3` with a private access policy, to prevent unauthorized access to the uploaded files.

## Publishing configuration

You can publish the Filament package configuration (if needed) using the following command:

```bash
php artisan vendor:publish --tag=filament-config
```

## Publishing translations

You can publish the language files for translations (if needed) with the following command:

```bash
php artisan vendor:publish --tag=filament-panels-translations
```

Since this package depends on other Filament packages, you can publish the language files for those packages with the following commands:

```bash
php artisan vendor:publish --tag=filament-actions-translations

php artisan vendor:publish --tag=filament-forms-translations

php artisan vendor:publish --tag=filament-infolists-translations

php artisan vendor:publish --tag=filament-notifications-translations

php artisan vendor:publish --tag=filament-tables-translations

php artisan vendor:publish --tag=filament-translations
```

## Upgrading

> Upgrading from Filament v2? Please review the [upgrade guide](upgrade-guide).

Filament automatically upgrades to the latest non-breaking version when you run `composer update`. After any updates, all Laravel caches need to be cleared, and frontend assets need to be republished. You can do this all at once using the `filament:upgrade` command, which should have been added to your `composer.json` file when you ran `filament:install` the first time:

```json
"post-autoload-dump": [
    // ...
    "@php artisan filament:upgrade"
],
```

Please note that `filament:upgrade` does not actually handle the update process, as Composer does that already. If you're upgrading manually without a `post-autoload-dump` hook, you can run the command yourself:

```bash
composer update

php artisan filament:upgrade
```

# Documentation for panels. File: 02-getting-started.md
---
title: Getting started
---
import LaracastsBanner from "@components/LaracastsBanner.astro"

## Overview

Panels are the top-level container in Filament, allowing you to build feature-rich admin panels that include pages, resources, forms, tables, notifications, actions, infolists, and widgets. All Panels include a default dashboard that can include widgets with statistics, charts, tables, and more.

<LaracastsBanner
    title="Introduction to Filament"
    description="Watch the Rapid Laravel Development with Filament series on Laracasts - it will teach you how to get started with the panel builder. Alternatively, continue reading this text-based guide."
    url="https://laracasts.com/series/rapid-laravel-development-with-filament/episodes/2"
    series="rapid-laravel-development"
/>

## Prerequisites

Before using Filament, you should be familiar with Laravel. Filament builds upon many core Laravel concepts, especially [database migrations](https://laravel.com/docs/migrations) and [Eloquent ORM](https://laravel.com/docs/eloquent). If you're new to Laravel or need a refresher, we highly recommend completing the [Laravel Bootcamp](https://bootcamp.laravel.com), which covers the fundamentals of building Laravel apps.

## The demo project

This guide covers building a simple patient management system for a veterinary practice using Filament. It will support adding new patients (cats, dogs, or rabbits), assigning them to an owner, and recording which treatments they received. The system will have a dashboard with statistics about the types of patients and a chart showing the number of treatments administered over the past year.

## Setting up the database and models

This project needs three models and migrations: `Owner`, `Patient`, and `Treatment`. Use the following artisan commands to create these:

```bash
php artisan make:model Owner -m
php artisan make:model Patient -m
php artisan make:model Treatment -m
```

### Defining migrations

Use the following basic schemas for your database migrations:

```php

// create_owners_table
Schema::create('owners', function (Blueprint $table) {
    $table->id();
    $table->string('email');
    $table->string('name');
    $table->string('phone');
    $table->timestamps();
});

// create_patients_table
Schema::create('patients', function (Blueprint $table) {
    $table->id();
    $table->date('date_of_birth');
    $table->string('name');
    $table->foreignId('owner_id')->constrained('owners')->cascadeOnDelete();
    $table->string('type');
    $table->timestamps();
});

// create_treatments_table
Schema::create('treatments', function (Blueprint $table) {
    $table->id();
    $table->string('description');
    $table->text('notes')->nullable();
    $table->foreignId('patient_id')->constrained('patients')->cascadeOnDelete();
    $table->unsignedInteger('price')->nullable();
    $table->timestamps();
});
```

Run the migrations using `php artisan migrate`.

### Unguarding all models

For brevity in this guide, we will disable Laravel's [mass assignment protection](https://laravel.com/docs/eloquent#mass-assignment). Filament only saves valid data to models so the models can be unguarded safely. To unguard all Laravel models at once, add `Model::unguard()` to the `boot()` method of `app/Providers/AppServiceProvider.php`:

```php
use Illuminate\Database\Eloquent\Model;

public function boot(): void
{
    Model::unguard();
}
```

### Setting up relationships between models

Let's set up relationships between the models. For our system, pet owners can own multiple pets (patients), and patients can have many treatments:

```php
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Owner extends Model
{
    public function patients(): HasMany
    {
        return $this->hasMany(Patient::class);
    }
}

class Patient extends Model
{
    public function owner(): BelongsTo
    {
        return $this->belongsTo(Owner::class);
    }

    public function treatments(): HasMany
    {
        return $this->hasMany(Treatment::class);
    }
}

class Treatment extends Model
{
    public function patient(): BelongsTo
    {
        return $this->belongsTo(Patient::class);
    }
}
```

## Introducing resources

In Filament, resources are static classes used to build CRUD interfaces for your Eloquent models. They describe how administrators can interact with data from your panel using tables and forms.

Since patients (pets) are the core entity in this system, let's start by creating a patient resource that enables us to build pages for creating, viewing, updating, and deleting patients.

Use the following artisan command to create a new Filament resource for the `Patient` model:

```bash
php artisan make:filament-resource Patient
```

This will create several files in the `app/Filament/Resources` directory:

```
.
+-- PatientResource.php
+-- PatientResource
|   +-- Pages
|   |   +-- CreatePatient.php
|   |   +-- EditPatient.php
|   |   +-- ListPatients.php
```

Visit `/admin/patients` in your browser and observe a new link called "Patients" in the navigation. Clicking the link will display an empty table. Let's add a form to create new patients.

### Setting up the resource form

If you open the `PatientResource.php` file, there's a `form()` method with an empty `schema([...])` array. Adding form fields to this schema will build a form that can be used to create and edit new patients.

#### "Name" text input

Filament bundles a large selection of [form fields](../forms/fields/getting-started#available-fields). Let's start with a simple [text input field](../forms/fields/text-input):

```php
use Filament\Forms;
use Filament\Forms\Form;

public static function form(Form $form): Form
{
    return $form
        ->schema([
            Forms\Components\TextInput::make('name'),
        ]);
}
```

Visit `/admin/patients/create` (or click the "New Patient" button) and observe that a form field for the patient's name was added.

Since this field is required in the database and has a maximum length of 255 characters, let's add two [validation rules](../forms/validation) to the name field:

```php
use Filament\Forms;

Forms\Components\TextInput::make('name')
    ->required()
    ->maxLength(255)
```

Attempt to submit the form to create a new patient without a name and observe that a message is displayed informing you that the name field is required.

#### "Type" select

Let's add a second field for the type of patient: a choice between a cat, dog, or rabbit. Since there's a fixed set of options to choose from, a [select](../forms/fields/select) field works well:

```php
use Filament\Forms;
use Filament\Forms\Form;

public static function form(Form $form): Form
{
    return $form
        ->schema([
            Forms\Components\TextInput::make('name')
                ->required()
                ->maxLength(255),
            Forms\Components\Select::make('type')
                ->options([
                    'cat' => 'Cat',
                    'dog' => 'Dog',
                    'rabbit' => 'Rabbit',
                ]),
        ]);
}
```

The `options()` method of the Select field accepts an array of options for the user to choose from. The array keys should match the database, and the values are used as the form labels. Feel free to add as many animals to this array as you wish.

Since this field is also required in the database, let's add the `required()` validation rule:

```php
use Filament\Forms;

Forms\Components\Select::make('type')
    ->options([
        'cat' => 'Cat',
        'dog' => 'Dog',
        'rabbit' => 'Rabbit',
    ])
    ->required()
```

#### "Date of birth" picker

Let's add a [date picker field](../forms/fields/date-time-picker) for the `date_of_birth` column along with the validation (the date of birth is required and the date should be no later than the current day).

```php
use Filament\Forms;
use Filament\Forms\Form;

public static function form(Form $form): Form
{
    return $form
        ->schema([
            Forms\Components\TextInput::make('name')
                ->required()
                ->maxLength(255),
            Forms\Components\Select::make('type')
                ->options([
                    'cat' => 'Cat',
                    'dog' => 'Dog',
                    'rabbit' => 'Rabbit',
                ])
                ->required(),
            Forms\Components\DatePicker::make('date_of_birth')
                ->required()
                ->maxDate(now()),
        ]);
}
```

#### "Owner" select

We should also add an owner when creating a new patient. Since we added a `BelongsTo` relationship in the Patient model (associating it to the related `Owner` model), we can use the **[`relationship()` method](../forms/fields/select#integrating-with-an-eloquent-relationship)** from the select field to load a list of owners to choose from:

```php
use Filament\Forms;
use Filament\Forms\Form;

public static function form(Form $form): Form
{
    return $form
        ->schema([
            Forms\Components\TextInput::make('name')
                ->required()
                ->maxLength(255),
            Forms\Components\Select::make('type')
                ->options([
                    'cat' => 'Cat',
                    'dog' => 'Dog',
                    'rabbit' => 'Rabbit',
                ])
                ->required(),
            Forms\Components\DatePicker::make('date_of_birth')
                ->required()
                ->maxDate(now()),
            Forms\Components\Select::make('owner_id')
                ->relationship('owner', 'name')
                ->required(),
        ]);
}
```

The first argument of the `relationship()` method is the name of the function that defines the relationship in the model (used by Filament to load the select options) — in this case, `owner`. The second argument is the column name to use from the related table — in this case, `name`.

Let's also make the `owner` field required, `searchable()`, and `preload()` the first 50 owners into the searchable list (in case the list is long):

```php
use Filament\Forms;

Forms\Components\Select::make('owner_id')
    ->relationship('owner', 'name')
    ->searchable()
    ->preload()
    ->required()
```

#### Creating new owners without leaving the page
Currently, there are no owners in our database. Instead of creating a separate Filament owner resource, let's give users an easier way to add owners via a modal form (accessible as a `+` button next to the select). Use the [`createOptionForm()` method](../forms/fields/select#creating-a-new-option-in-a-modal) to embed a modal form with [`TextInput` fields](../forms/fields/text-input) for the owner's name, email address, and phone number:

```php
use Filament\Forms;

Forms\Components\Select::make('owner_id')
    ->relationship('owner', 'name')
    ->searchable()
    ->preload()
    ->createOptionForm([
        Forms\Components\TextInput::make('name')
            ->required()
            ->maxLength(255),
        Forms\Components\TextInput::make('email')
            ->label('Email address')
            ->email()
            ->required()
            ->maxLength(255),
        Forms\Components\TextInput::make('phone')
            ->label('Phone number')
            ->tel()
            ->required(),
    ])
    ->required()
```

A few new methods on the TextInput were used in this example:

- `label()` overrides the auto-generated label for each field. In this case, we want the `Email` label to be `Email address`, and the `Phone` label to be `Phone number`.
- `email()` ensures that only valid email addresses can be input into the field. It also changes the keyboard layout on mobile devices.
- `tel()` ensures that only valid phone numbers can be input into the field. It also changes the keyboard layout on mobile devices.

The form should be working now! Try creating a new patient and their owner. Once created, you will be redirected to the Edit page, where you can update their details.

### Setting up the patients table

Visit the `/admin/patients` page again. If you have created a patient, there should be one empty row in the table — with an edit button. Let's add some columns to the table, so we can view the actual patient data.

Open the `PatientResource.php` file. You should see a `table()` method with an empty `columns([...])` array. You can use this array to add columns to the `patients` table.

#### Adding text columns

Filament bundles a large selection of [table columns](../tables/columns#available-columns). Let's use a simple [text column](../tables/columns/text) for all the fields in the `patients` table:

```php
use Filament\Tables;
use Filament\Tables\Table;

public static function table(Table $table): Table
{
    return $table
        ->columns([
            Tables\Columns\TextColumn::make('name'),
            Tables\Columns\TextColumn::make('type'),
            Tables\Columns\TextColumn::make('date_of_birth'),
            Tables\Columns\TextColumn::make('owner.name'),
        ]);
}
```

> Filament uses dot notation to eager-load related data. We used `owner.name` in our table to display a list of owner names instead of less informational ID numbers. You could also add columns for the owner's email address and phone number.

##### Making columns searchable

The ability to [search](../tables/columns/getting-started#searching) for patients directly in the table would be helpful as a veterinary practice grows. You can make columns searchable by chaining the `searchable()` method to the column. Let's make the patient's name and owner's name searchable.

```php
use Filament\Tables;
use Filament\Tables\Table;

public static function table(Table $table): Table
{
    return $table
        ->columns([
            Tables\Columns\TextColumn::make('name')
                ->searchable(),
            Tables\Columns\TextColumn::make('type'),
            Tables\Columns\TextColumn::make('date_of_birth'),
            Tables\Columns\TextColumn::make('owner.name')
                ->searchable(),
        ]);
}
```

Reload the page and observe a new search input field on the table that filters the table entries using the search criteria.

##### Making the columns sortable

To make the `patients` table [sortable](../tables/columns/getting-started#sorting) by age, add the `sortable()` method to the `date_of_birth` column:

```php
use Filament\Tables;
use Filament\Tables\Table;

public static function table(Table $table): Table
{
    return $table
        ->columns([
            Tables\Columns\TextColumn::make('name')
                ->searchable(),
            Tables\Columns\TextColumn::make('type'),
            Tables\Columns\TextColumn::make('date_of_birth')
                ->sortable(),
            Tables\Columns\TextColumn::make('owner.name')
                ->searchable(),
        ]);
}
```

This will add a sort icon button to the column header. Clicking it will sort the table by date of birth.

#### Filtering the table by patient type

Although you can make the `type` field searchable, making it filterable is a much better user experience.

Filament tables can have [filters](../tables/filters/getting-started#available-filters), which are components that reduce the number of records in a table by adding a scope to the Eloquent query. Filters can even contain custom form components, making them a potent tool for building interfaces.

Filament includes a prebuilt [`SelectFilter`](../tables/filters/select) that you can add to the table's `filters()`:

```php
use Filament\Tables;
use Filament\Tables\Table;

public static function table(Table $table): Table
{
    return $table
        ->columns([
            // ...
        ])
        ->filters([
            Tables\Filters\SelectFilter::make('type')
                ->options([
                    'cat' => 'Cat',
                    'dog' => 'Dog',
                    'rabbit' => 'Rabbit',
                ]),
        ]);
}
```

Reload the page, and you should see a new filter icon in the top right corner (next to the search form). The filter opens a select menu with a list of patient types. Try filtering your patients by type.

## Introducing relation managers

Currently, patients can be associated with their owners in our system. But what happens if we want a third level? Patients come to the vet practice for treatment, and the system should be able to record these treatments and associate them with a patient.

One option is to create a new `TreatmentResource` with a select field to associate treatments with a patient. However, managing treatments separately from the rest of the patient information is cumbersome for the user. Filament uses "relation managers" to solve this problem.

Relation managers are tables that display related records for an existing resource on the edit screen for the parent resource. For example, in our project, you could view and manage a patient's treatments directly below their edit form.

> You can also use Filament ["actions"](../actions/modals#modal-forms) to open a modal form to create, edit, and delete treatments directly from the patient's table.

Use the `make:filament-relation-manager` artisan command to quickly create a relation manager, connecting the patient resource to the related treatments:

```bash
php artisan make:filament-relation-manager PatientResource treatments description
```

- `PatientResource` is the name of the resource class for the owner model. Since treatments belong to patients, the treatments should be displayed on the Edit Patient page.
- `treatments` is the name of the relationship in the Patient model we created earlier.
- `description` is the column to display from the treatments table.

This will create a `PatientResource/RelationManagers/TreatmentsRelationManager.php` file. You must register the new relation manager in the `getRelations()` method of the `PatientResource`:

```php
use App\Filament\Resources\PatientResource\RelationManagers;

public static function getRelations(): array
{
    return [
        RelationManagers\TreatmentsRelationManager::class,
    ];
}
```

The `TreatmentsRelationManager.php` file contains a class that is prepopulated with a form and table using the parameters from the `make:filament-relation-manager` artisan command. You can customize the fields and columns in the relation manager similar to how you would in a resource:

```php
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Tables;
use Filament\Tables\Table;

public function form(Form $form): Form
{
    return $form
        ->schema([
            Forms\Components\TextInput::make('description')
                ->required()
                ->maxLength(255),
        ]);
}

public function table(Table $table): Table
{
    return $table
        ->columns([
            Tables\Columns\TextColumn::make('description'),
        ]);
}
```

Visit the Edit page for one of your patients. You should already be able to create, edit, delete, and list treatments for that patient.

### Setting up the treatment form

By default, text fields only span half the width of the form. Since the `description` field might contain a lot of information, add a `columnSpan('full')` method to make the field span the entire width of the modal form:

```php
use Filament\Forms;

Forms\Components\TextInput::make('description')
    ->required()
    ->maxLength(255)
    ->columnSpan('full')
```

Let's add the `notes` field, which can be used to add more details about the treatment. We can use a [textarea](../forms/fields/textarea) field with a `columnSpan('full')`:

```php
use Filament\Forms;
use Filament\Forms\Form;

public function form(Form $form): Form
{
    return $form
        ->schema([
            Forms\Components\TextInput::make('description')
                ->required()
                ->maxLength(255)
                ->columnSpan('full'),
            Forms\Components\Textarea::make('notes')
                ->maxLength(65535)
                ->columnSpan('full'),
        ]);
}
```

#### Configuring the `price` field

Let's add a `price` field for the treatment. We can use a text input with some customizations to make it suitable for currency input. It should be `numeric()`, which adds validation and changes the keyboard layout on mobile devices. Add your preferred currency prefix using the `prefix()` method; for example, `prefix('€')` will add a `€` before the input without impacting the saved output value:

```php
use Filament\Forms;
use Filament\Forms\Form;

public function form(Form $form): Form
{
    return $form
        ->schema([
            Forms\Components\TextInput::make('description')
                ->required()
                ->maxLength(255)
                ->columnSpan('full'),
            Forms\Components\Textarea::make('notes')
                ->maxLength(65535)
                ->columnSpan('full'),
            Forms\Components\TextInput::make('price')
                ->numeric()
                ->prefix('€')
                ->maxValue(42949672.95),
        ]);
}
```

##### Casting the price to an integer

Filament stores currency values as integers (not floats) to avoid rounding and precision issues — a widely-accepted approach in the Laravel community. However, this requires creating a cast in Laravel that transforms the integer into a float when retrieved and back to an integer when stored in the database. Use the following artisan command to create the cast:

```bash
php artisan make:cast MoneyCast
```

Inside the new `app/Casts/MoneyCast.php` file, update the `get()` and `set()` methods:

```php
public function get($model, string $key, $value, array $attributes): float
{
    // Transform the integer stored in the database into a float.
    return round(floatval($value) / 100, precision: 2);
}

public function set($model, string $key, $value, array $attributes): float
{
    // Transform the float into an integer for storage.
    return round(floatval($value) * 100);
}
```

Now, add the `MoneyCast` to the `price` attribute in the `Treatment` model:

```php
use App\Casts\MoneyCast;
use Illuminate\Database\Eloquent\Model;

class Treatment extends Model
{
    protected $casts = [
        'price' => MoneyCast::class,
    ];

    // ...
}
```

### Setting up the treatments table

When the relation manager was generated previously, the `description` text column was automatically added. Let's also add a `sortable()` column for the `price` with a currency prefix. Use the Filament `money()` method to format the `price` column as money — in this case for `EUR` (`€`):

```php
use Filament\Tables;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->columns([
            Tables\Columns\TextColumn::make('description'),
            Tables\Columns\TextColumn::make('price')
                ->money('EUR')
                ->sortable(),
        ]);
}
```

Let's also add a column to indicate when the treatment was administered using the default `created_at` timestamp. Use the `dateTime()` method to display the date-time in a human-readable format:

```php
use Filament\Tables;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->columns([
            Tables\Columns\TextColumn::make('description'),
            Tables\Columns\TextColumn::make('price')
                ->money('EUR')
                ->sortable(),
            Tables\Columns\TextColumn::make('created_at')
                ->dateTime(),
        ]);
}
```

> You can pass any valid [PHP date formatting string](https://www.php.net/manual/en/datetime.format.php) to the `dateTime()` method (e.g. `dateTime('m-d-Y h:i A')`).

## Introducing widgets

Filament widgets are components that display information on your dashboard, especially statistics. Widgets are typically added to the default [Dashboard](../panels/dashboard) of the panel, but you can add them to any page, including resource pages. Filament includes built-in widgets like the [stats widget](../widgets/stats-overview), to render important statistics in a simple overview; [chart widget](../widgets/charts), which can render an interactive chart; and [table widget](../panels/dashboard#table-widgets), which allows you to easily embed the Table Builder.

Let's add a stats widget to our default dashboard page that includes a stat for each type of patient and a chart to visualize treatments administered over time.

### Creating a stats widget

Create a [stats widget](../widgets/stats-overview) to render patient types using the following artisan command:

```bash
php artisan make:filament-widget PatientTypeOverview --stats-overview
```

When prompted, do not specify a resource, and select "admin" for the location.

This will create a new `app/Filament/Widgets/PatientTypeOverview.php` file. Open it, and return `Stat` instances from the `getStats()` method:

```php
<?php

namespace App\Filament\Widgets;

use App\Models\Patient;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class PatientTypeOverview extends BaseWidget
{
    protected function getStats(): array
    {
        return [
            Stat::make('Cats', Patient::query()->where('type', 'cat')->count()),
            Stat::make('Dogs', Patient::query()->where('type', 'dog')->count()),
            Stat::make('Rabbits', Patient::query()->where('type', 'rabbit')->count()),
        ];
    }
}
```

Open your dashboard, and you should see your new widget displayed. Each stat should show the total number of patients for the specified type.

### Creating a chart widget

Let's add a chart to the dashboard to visualize the number of treatments administered over time. Use the following artisan command to create a new chart widget:

```bash
php artisan make:filament-widget TreatmentsChart --chart
```

When prompted, do not specify a resource, select "admin" for the location, and choose "line chart" as the chart type.

Open `app/Filament/Widgets/TreatmentsChart.php` and set the `$heading` of the chart to "Treatments".

The `getData()` method returns an array of datasets and labels. Each dataset is a labeled array of points to plot on the chart, and each label is a string. This structure is identical to the [Chart.js](https://www.chartjs.org/docs) library, which Filament uses to render charts.

To populate chart data from an Eloquent model, Filament recommends that you install the [flowframe/laravel-trend](https://github.com/Flowframe/laravel-trend) package:

```bash
composer require flowframe/laravel-trend
```

Update the `getData()` to display the number of treatments per month for the past year:

```php
use App\Models\Treatment;
use Flowframe\Trend\Trend;
use Flowframe\Trend\TrendValue;

protected function getData(): array
{
    $data = Trend::model(Treatment::class)
        ->between(
            start: now()->subYear(),
            end: now(),
        )
        ->perMonth()
        ->count();

    return [
        'datasets' => [
            [
                'label' => 'Treatments',
                'data' => $data->map(fn (TrendValue $value) => $value->aggregate),
            ],
        ],
        'labels' => $data->map(fn (TrendValue $value) => $value->date),
    ];
}
```

Now, check out your new chart widget in the dashboard!

> You can [customize your dashboard page](../panels/dashboard#customizing-the-dashboard-page) to change the grid and how many widgets are displayed.

## Next steps with the Panel Builder

Congratulations! Now that you know how to build a basic Filament application, here are some suggestions for further learning:

- [Create custom pages in the panel that don't belong to resources.](pages)
- [Learn more about adding action buttons to pages and resources, with modals to collect user input or for confirmation.](../actions/overview)
- [Explore the available fields to collect input from your users.](../forms/fields/getting-started#available-fields)
- [Check out the list of form layout components.](../forms/layout/getting-started)
- [Discover how to build complex, responsive table layouts without touching CSS.](../tables/layout)
- [Add summaries to your tables](../tables/summaries)
- [Write automated tests for your panel using our suite of helper methods.](testing)

# Documentation for panels. File: 03-resources/01-getting-started.md
---
title: Getting started
---
import LaracastsBanner from "@components/LaracastsBanner.astro"

## Overview

<LaracastsBanner
    title="Introduction to Filament"
    description="Watch the Rapid Laravel Development with Filament series on Laracasts - it will teach you how to get started with the resources."
    url="https://laracasts.com/series/rapid-laravel-development-with-filament/episodes/2"
    series="rapid-laravel-development"
/>

Resources are static classes that are used to build CRUD interfaces for your Eloquent models. They describe how administrators should be able to interact with data from your app - using tables and forms.

## Creating a resource

To create a resource for the `App\Models\Customer` model:

```bash
php artisan make:filament-resource Customer
```

This will create several files in the `app/Filament/Resources` directory:

```
.
+-- CustomerResource.php
+-- CustomerResource
|   +-- Pages
|   |   +-- CreateCustomer.php
|   |   +-- EditCustomer.php
|   |   +-- ListCustomers.php
```

Your new resource class lives in `CustomerResource.php`.

The classes in the `Pages` directory are used to customize the pages in the app that interact with your resource. They're all full-page [Livewire](https://livewire.laravel.com) components that you can customize in any way you wish.

> Have you created a resource, but it's not appearing in the navigation menu? If you have a [model policy](#authorization), make sure you return `true` from the `viewAny()` method.

### Simple (modal) resources

Sometimes, your models are simple enough that you only want to manage records on one page, using modals to create, edit and delete records. To generate a simple resource with modals:

```bash
php artisan make:filament-resource Customer --simple
```

Your resource will have a "Manage" page, which is a List page with modals added.

Additionally, your simple resource will have no `getRelations()` method, as [relation managers](relation-managers) are only displayed on the Edit and View pages, which are not present in simple resources. Everything else is the same.

### Automatically generating forms and tables

If you'd like to save time, Filament can automatically generate the [form](#resource-forms) and [table](#resource-tables) for you, based on your model's database columns, using `--generate`:

```bash
php artisan make:filament-resource Customer --generate
```

### Handling soft deletes

By default, you will not be able to interact with deleted records in the app. If you'd like to add functionality to restore, force delete and filter trashed records in your resource, use the `--soft-deletes` flag when generating the resource:

```bash
php artisan make:filament-resource Customer --soft-deletes
```

You can find out more about soft deleting [here](deleting-records#handling-soft-deletes).

### Generating a View page

By default, only List, Create and Edit pages are generated for your resource. If you'd also like a [View page](viewing-records), use the `--view` flag:

```bash
php artisan make:filament-resource Customer --view
```

### Specifiying a custom model namespace

By default, Filament will assume that your model exists in the `App\Models` directory. You can pass a different namespace for the model using the `--model-namespace` flag:

```bash
php artisan make:filament-resource Customer --model-namespace=Custom\\Path\\Models
```

In this example, the model should exist at `Custom\Path\Models\Customer`. Please note the double backslashes `\\` in the command that are required.

Now when [generating the resource](#automatically-generating-forms-and-tables), Filament will be able to locate the model and read the database schema.

### Generating the model, migration and factory at the same name

If you'd like to save time when scaffolding your resources, Filament can also generate the model, migration and factory for the new resource at the same time using the `--model`, `--migration` and `--factory` flags in any combination:

```bash
php artisan make:filament-resource Customer --model --migration --factory
```

## Record titles

A `$recordTitleAttribute` may be set for your resource, which is the name of the column on your model that can be used to identify it from others.

For example, this could be a blog post's `title` or a customer's `name`:

```php
protected static ?string $recordTitleAttribute = 'name';
```

This is required for features like [global search](global-search) to work.

> You may specify the name of an [Eloquent accessor](https://laravel.com/docs/eloquent-mutators#defining-an-accessor) if just one column is inadequate at identifying a record.

## Resource forms

<LaracastsBanner
    title="Basic Form Inputs"
    description="Watch the Rapid Laravel Development with Filament series on Laracasts - it will teach you the basics of adding a form to your resource."
    url="https://laracasts.com/series/rapid-laravel-development-with-filament/episodes/3"
    series="rapid-laravel-development"
/>

Resource classes contain a `form()` method that is used to build the forms on the [Create](creating-records) and [Edit](editing-records) pages:

```php
use Filament\Forms;
use Filament\Forms\Form;

public static function form(Form $form): Form
{
    return $form
        ->schema([
            Forms\Components\TextInput::make('name')->required(),
            Forms\Components\TextInput::make('email')->email()->required(),
            // ...
        ]);
}
```

The `schema()` method is used to define the structure of your form. It is an array of [fields](../../forms/fields/getting-started#available-fields) and [layout components](../../forms/layout/getting-started#available-layout-components), in the order they should appear in your form.

Check out the Forms docs for a [guide](../../forms/getting-started) on how to build forms with Filament.

### Hiding components based on the current operation

The `hiddenOn()` method of form components allows you to dynamically hide fields based on the current page or action.

In this example, we hide the `password` field on the `edit` page:

```php
use Livewire\Component;

Forms\Components\TextInput::make('password')
    ->password()
    ->required()
    ->hiddenOn('edit'),
```

Alternatively, we have a `visibleOn()` shortcut method for only showing a field on one page or action:

```php
use Livewire\Component;

Forms\Components\TextInput::make('password')
    ->password()
    ->required()
    ->visibleOn('create'),
```

## Resource tables

<LaracastsBanner
    title="Table Columns"
    description="Watch the Rapid Laravel Development with Filament series on Laracasts - it will teach you the basics of adding a table to your resource."
    url="https://laracasts.com/series/rapid-laravel-development-with-filament/episodes/9"
    series="rapid-laravel-development"
/>

Resource classes contain a `table()` method that is used to build the table on the [List page](listing-records):

```php
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

public static function table(Table $table): Table
{
    return $table
        ->columns([
            Tables\Columns\TextColumn::make('name'),
            Tables\Columns\TextColumn::make('email'),
            // ...
        ])
        ->filters([
            Tables\Filters\Filter::make('verified')
                ->query(fn (Builder $query): Builder => $query->whereNotNull('email_verified_at')),
            // ...
        ])
        ->actions([
            Tables\Actions\EditAction::make(),
        ])
        ->bulkActions([
            Tables\Actions\BulkActionGroup::make([
                Tables\Actions\DeleteBulkAction::make(),
            ]),
        ]);
}
```

Check out the [tables](../../tables/getting-started) docs to find out how to add table columns, filters, actions and more.

## Authorization

For authorization, Filament will observe any [model policies](https://laravel.com/docs/authorization#creating-policies) that are registered in your app. The following methods are used:

- `viewAny()` is used to completely hide resources from the navigation menu, and prevents the user from accessing any pages.
- `create()` is used to control [creating new records](creating-records).
- `update()` is used to control [editing a record](editing-records).
- `view()` is used to control [viewing a record](viewing-records).
- `delete()` is used to prevent a single record from being deleted. `deleteAny()` is used to prevent records from being bulk deleted. Filament uses the `deleteAny()` method because iterating through multiple records and checking the `delete()` policy is not very performant.
- `forceDelete()` is used to prevent a single soft-deleted record from being force-deleted. `forceDeleteAny()` is used to prevent records from being bulk force-deleted. Filament uses the `forceDeleteAny()` method because iterating through multiple records and checking the `forceDelete()` policy is not very performant.
- `restore()` is used to prevent a single soft-deleted record from being restored. `restoreAny()` is used to prevent records from being bulk restored. Filament uses the `restoreAny()` method because iterating through multiple records and checking the `restore()` policy is not very performant.
- `reorder()` is used to control [reordering a record](listing-records#reordering-records).

### Skipping authorization

If you'd like to skip authorization for a resource, you may set the `$shouldSkipAuthorization` property to `true`:

```php
protected static bool $shouldSkipAuthorization = true;
```

## Customizing the model label

Each resource has a "model label" which is automatically generated from the model name. For example, an `App\Models\Customer` model will have a `customer` label.

The label is used in several parts of the UI, and you may customize it using the `$modelLabel` property:

```php
protected static ?string $modelLabel = 'cliente';
```

Alternatively, you may use the `getModelLabel()` to define a dynamic label:

```php
public static function getModelLabel(): string
{
    return __('filament/resources/customer.label');
}
```

### Customizing the plural model label

Resources also have a "plural model label" which is automatically generated from the model label. For example, a `customer` label will be pluralized into `customers`.

You may customize the plural version of the label using the `$pluralModelLabel` property:

```php
protected static ?string $pluralModelLabel = 'clientes';
```

Alternatively, you may set a dynamic plural label in the `getPluralModelLabel()` method:

```php
public static function getPluralModelLabel(): string
{
    return __('filament/resources/customer.plural_label');
}
```

### Automatic model label capitalization

By default, Filament will automatically capitalize each word in the model label, for some parts of the UI. For example, in page titles, the navigation menu, and the breadcrumbs.

If you want to disable this behavior for a resource, you can set `$hasTitleCaseModelLabel` in the resource:

```php
protected static bool $hasTitleCaseModelLabel = false;
```

## Resource navigation items

Filament will automatically generate a navigation menu item for your resource using the [plural label](#plural-label).

If you'd like to customize the navigation item label, you may use the `$navigationLabel` property:

```php
protected static ?string $navigationLabel = 'Mis Clientes';
```

Alternatively, you may set a dynamic navigation label in the `getNavigationLabel()` method:

```php
public static function getNavigationLabel(): string
{
    return __('filament/resources/customer.navigation_label');
}
```

### Setting a resource navigation icon

The `$navigationIcon` property supports the name of any Blade component. By default, [Heroicons](https://heroicons.com) are installed. However, you may create your own custom icon components or install an alternative library if you wish.

```php
protected static ?string $navigationIcon = 'heroicon-o-user-group';
```

Alternatively, you may set a dynamic navigation icon in the `getNavigationIcon()` method:

```php
use Illuminate\Contracts\Support\Htmlable;

public static function getNavigationIcon(): string | Htmlable | null
{
    return 'heroicon-o-user-group';
}
```

### Sorting resource navigation items

The `$navigationSort` property allows you to specify the order in which navigation items are listed:

```php
protected static ?int $navigationSort = 2;
```

Alternatively, you may set a dynamic navigation item order in the `getNavigationSort()` method:

```php
public static function getNavigationSort(): ?int
{
    return 2;
}
```

### Grouping resource navigation items

You may group navigation items by specifying a `$navigationGroup` property:

```php
protected static ?string $navigationGroup = 'Shop';
```

Alternatively, you may use the `getNavigationGroup()` method to set a dynamic group label:

```php
public static function getNavigationGroup(): ?string
{
    return __('filament/navigation.groups.shop');
}
```

#### Grouping resource navigation items under other items

You may group navigation items as children of other items, by passing the label of the parent item as the `$navigationParentItem`:

```php
protected static ?string $navigationParentItem = 'Products';

protected static ?string $navigationGroup = 'Shop';
```

As seen above, if the parent item has a navigation group, that navigation group must also be defined, so the correct parent item can be identified.

You may also use the `getNavigationParentItem()` method to set a dynamic parent item label:

```php
public static function getNavigationParentItem(): ?string
{
    return __('filament/navigation.groups.shop.items.products');
}
```

> If you're reaching for a third level of navigation like this, you should consider using [clusters](clusters) instead, which are a logical grouping of resources and [custom pages](../pages), which can share their own separate navigation.

## Generating URLs to resource pages

Filament provides `getUrl()` static method on resource classes to generate URLs to resources and specific pages within them. Traditionally, you would need to construct the URL by hand or by using Laravel's `route()` helper, but these methods depend on knowledge of the resource's slug or route naming conventions.

The `getUrl()` method, without any arguments, will generate a URL to the resource's [List page](listing-records):

```php
use App\Filament\Resources\CustomerResource;

CustomerResource::getUrl(); // /admin/customers
```

You may also generate URLs to specific pages within the resource. The name of each page is the array key in the `getPages()` array of the resource. For example, to generate a URL to the [Create page](creating-records):

```php
use App\Filament\Resources\CustomerResource;

CustomerResource::getUrl('create'); // /admin/customers/create
```

Some pages in the `getPages()` method use URL parameters like `record`. To generate a URL to these pages and pass in a record, you should use the second argument:

```php
use App\Filament\Resources\CustomerResource;

CustomerResource::getUrl('edit', ['record' => $customer]); // /admin/customers/edit/1
```

In this example, `$customer` can be an Eloquent model object, or an ID.

### Generating URLs to resource modals

This can be especially useful if you are using [simple resources](#simple-modal-resources) with only one page.

To generate a URL for an action in the resource's table, you should pass the `tableAction` and `tableActionRecord` as URL parameters:

```php
use App\Filament\Resources\CustomerResource;
use Filament\Tables\Actions\EditAction;

CustomerResource::getUrl(parameters: [
    'tableAction' => EditAction::getDefaultName(),
    'tableActionRecord' => $customer,
]); // /admin/customers?tableAction=edit&tableActionRecord=1
```

Or if you want to generate a URL for an action on the page like a `CreateAction` in the header, you can pass it in to the `action` parameter:

```php
use App\Filament\Resources\CustomerResource;
use Filament\Actions\CreateAction;

CustomerResource::getUrl(parameters: [
    'action' => CreateAction::getDefaultName(),
]); // /admin/customers?action=create
```

### Generating URLs to resources in other panels

If you have multiple panels in your app, `getUrl()` will generate a URL within the current panel. You can also indicate which panel the resource is associated with, by passing the panel ID to the `panel` argument:

```php
use App\Filament\Resources\CustomerResource;

CustomerResource::getUrl(panel: 'marketing');
```

## Customizing the resource Eloquent query

Within Filament, every query to your resource model will start with the `getEloquentQuery()` method.

Because of this, it's very easy to apply your own query constraints or [model scopes](https://laravel.com/docs/eloquent#query-scopes) that affect the entire resource:

```php
public static function getEloquentQuery(): Builder
{
    return parent::getEloquentQuery()->where('is_active', true);
}
```

### Disabling global scopes

By default, Filament will observe all global scopes that are registered to your model. However, this may not be ideal if you wish to access, for example, soft deleted records.

To overcome this, you may override the `getEloquentQuery()` method that Filament uses:

```php
public static function getEloquentQuery(): Builder
{
    return parent::getEloquentQuery()->withoutGlobalScopes();
}
```

Alternatively, you may remove specific global scopes:

```php
public static function getEloquentQuery(): Builder
{
    return parent::getEloquentQuery()->withoutGlobalScopes([ActiveScope::class]);
}
```

More information about removing global scopes may be found in the [Laravel documentation](https://laravel.com/docs/eloquent#removing-global-scopes).

## Customizing the resource URL

By default, Filament will generate a URL based on the name of the resource. You can customize this by setting the `$slug` property on the resource:

```php
protected static ?string $slug = 'pending-orders';
```

## Resource sub-navigation

Sub-navigation allows the user to navigate between different pages within a resource. Typically, all pages in the sub-navigation will be related to the same record in the resource. For example, in a Customer resource, you may have a sub-navigation with the following pages:

- View customer, a [`ViewRecord` page](viewing-records) that provides a read-only view of the customer's details.
- Edit customer, an [`EditRecord` page](editing-records) that allows the user to edit the customer's details.
- Edit customer contact, an [`EditRecord` page](editing-records) that allows the user to edit the customer's contact details. You can [learn how to create more than one Edit page](editing-records#creating-another-edit-page).
- Manage addresses, a [`ManageRelatedRecords` page](relation-managers#relation-pages) that allows the user to manage the customer's addresses.
- Manage payments, a [`ManageRelatedRecords` page](relation-managers#relation-pages) that allows the user to manage the customer's payments.

To add a sub-navigation to each "singular record" page in the resource, you can add the `getRecordSubNavigation()` method to the resource class:

```php
use App\Filament\Resources\CustomerResource\Pages;
use Filament\Resources\Pages\Page;

public static function getRecordSubNavigation(Page $page): array
{
    return $page->generateNavigationItems([
        Pages\ViewCustomer::class,
        Pages\EditCustomer::class,
        Pages\EditCustomerContact::class,
        Pages\ManageCustomerAddresses::class,
        Pages\ManageCustomerPayments::class,
    ]);
}
```

Each item in the sub-navigation can be customized using the [same navigation methods as normal pages](../navigation).

> If you're looking to add sub-navigation to switch *between* entire resources and [custom pages](../pages), you might be looking for [clusters](../clusters), which are used to group these together. The `getRecordSubNavigation()` method is intended to construct a navigation between pages that relate to a particular record *inside* a resource.

### Sub-navigation position

The sub-navigation is rendered at the start of the page by default. You may change the position by setting the `$subNavigationPosition` property on the resource. The value may be `SubNavigationPosition::Start`, `SubNavigationPosition::End`, or `SubNavigationPosition::Top` to render the sub-navigation as tabs:

```php
use Filament\Pages\SubNavigationPosition;

protected static SubNavigationPosition $subNavigationPosition = SubNavigationPosition::End;
```

## Deleting resource pages

If you'd like to delete a page from your resource, you can just delete the page file from the `Pages` directory of your resource, and its entry in the `getPages()` method.

For example, you may have a resource with records that may not be created by anyone. Delete the `Create` page file, and then remove it from `getPages()`:

```php
public static function getPages(): array
{
    return [
        'index' => Pages\ListCustomers::route('/'),
        'edit' => Pages\EditCustomer::route('/{record}/edit'),
    ];
}
```

Deleting a page will not delete any actions that link to that page. Any actions will open a modal instead of sending the user to the non-existent page. For instance, the `CreateAction` on the List page, the `EditAction` on the table or View page, or the `ViewAction` on the table or Edit page. If you want to remove those buttons, you must delete the actions as well.

# Documentation for panels. File: 03-resources/02-listing-records.md
---
title: Listing records
---

## Using tabs to filter the records

You can add tabs above the table, which can be used to filter the records based on some predefined conditions. Each tab can scope the Eloquent query of the table in a different way. To register tabs, add a `getTabs()` method to the List page class, and return an array of `Tab` objects:

```php
use Filament\Resources\Components\Tab;
use Illuminate\Database\Eloquent\Builder;

public function getTabs(): array
{
    return [
        'all' => Tab::make(),
        'active' => Tab::make()
            ->modifyQueryUsing(fn (Builder $query) => $query->where('active', true)),
        'inactive' => Tab::make()
            ->modifyQueryUsing(fn (Builder $query) => $query->where('active', false)),
    ];
}
```

### Customizing the filter tab labels

The keys of the array will be used as identifiers for the tabs, so they can be persisted in the URL's query string. The label of each tab is also generated from the key, but you can override that by passing a label into the `make()` method of the tab:

```php
use Filament\Resources\Components\Tab;
use Illuminate\Database\Eloquent\Builder;

public function getTabs(): array
{
    return [
        'all' => Tab::make('All customers'),
        'active' => Tab::make('Active customers')
            ->modifyQueryUsing(fn (Builder $query) => $query->where('active', true)),
        'inactive' => Tab::make('Inactive customers')
            ->modifyQueryUsing(fn (Builder $query) => $query->where('active', false)),
    ];
}
```

### Adding icons to filter tabs

You can add icons to the tabs by passing an [icon](https://blade-ui-kit.com/blade-icons?set=1#search) into the `icon()` method of the tab:

```php
use use Filament\Resources\Components\Tab;

Tab::make()
    ->icon('heroicon-m-user-group')
```

You can also change the icon's position to be after the label instead of before it, using the `iconPosition()` method:

```php
use Filament\Support\Enums\IconPosition;

Tab::make()
    ->icon('heroicon-m-user-group')
    ->iconPosition(IconPosition::After)
```

### Adding badges to filter tabs

You can add badges to the tabs by passing a string into the `badge()` method of the tab:

```php
use Filament\Resources\Components\Tab;

Tab::make()
    ->badge(Customer::query()->where('active', true)->count())
```

#### Changing the color of filter tab badges

The color of a badge may be changed using the `badgeColor()` method:

```php
use Filament\Resources\Components\Tab;

Tab::make()
    ->badge(Customer::query()->where('active', true)->count())
    ->badgeColor('success')
```

### Adding extra attributes to filter tabs

You may also pass extra HTML attributes to filter tabs using `extraAttributes()`:

```php
use Filament\Resources\Components\Tab;

Tab::make()
    ->extraAttributes(['data-cy' => 'statement-confirmed-tab'])
```

### Customizing the default tab

To customize the default tab that is selected when the page is loaded, you can return the array key of the tab from the `getDefaultActiveTab()` method:

```php
use Filament\Resources\Components\Tab;

public function getTabs(): array
{
    return [
        'all' => Tab::make(),
        'active' => Tab::make(),
        'inactive' => Tab::make(),
    ];
}

public function getDefaultActiveTab(): string | int | null
{
    return 'active';
}
```

## Authorization

For authorization, Filament will observe any [model policies](https://laravel.com/docs/authorization#creating-policies) that are registered in your app.

Users may access the List page if the `viewAny()` method of the model policy returns `true`.

The `reorder()` method is used to control [reordering a record](#reordering-records).

## Customizing the table Eloquent query

Although you can [customize the Eloquent query for the entire resource](getting-started#customizing-the-resource-eloquent-query), you may also make specific modifications for the List page table. To do this, use the `modifyQueryUsing()` method in the `table()` method of the resource:

```php
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

public static function table(Table $table): Table
{
    return $table
        ->modifyQueryUsing(fn (Builder $query) => $query->withoutGlobalScopes());
}
```

## Custom list page view

For further customization opportunities, you can override the static `$view` property on the page class to a custom view in your app:

```php
protected static string $view = 'filament.resources.users.pages.list-users';
```

This assumes that you have created a view at `resources/views/filament/resources/users/pages/list-users.blade.php`.

Here's a basic example of what that view might contain:

```blade
<x-filament-panels::page>
    {{ $this->table }}
</x-filament-panels::page>
```

To see everything that the default view contains, you can check the `vendor/filament/filament/resources/views/resources/pages/list-records.blade.php` file in your project.

# Documentation for panels. File: 03-resources/03-creating-records.md
---
title: Creating records
---

## Customizing data before saving

Sometimes, you may wish to modify form data before it is finally saved to the database. To do this, you may define a `mutateFormDataBeforeCreate()` method on the Create page class, which accepts the `$data` as an array, and returns the modified version:

```php
protected function mutateFormDataBeforeCreate(array $data): array
{
    $data['user_id'] = auth()->id();

    return $data;
}
```

Alternatively, if you're creating records in a modal action, check out the [Actions documentation](../../actions/prebuilt-actions/create#customizing-data-before-saving).

## Customizing the creation process

You can tweak how the record is created using the `handleRecordCreation()` method on the Create page class:

```php
use Illuminate\Database\Eloquent\Model;

protected function handleRecordCreation(array $data): Model
{
    return static::getModel()::create($data);
}
```

Alternatively, if you're creating records in a modal action, check out the [Actions documentation](../../actions/prebuilt-actions/create#customizing-the-creation-process).

## Customizing redirects

By default, after saving the form, the user will be redirected to the [Edit page](editing-records) of the resource, or the [View page](viewing-records) if it is present.

You may set up a custom redirect when the form is saved by overriding the `getRedirectUrl()` method on the Create page class.

For example, the form can redirect back to the [List page](listing-records):

```php
protected function getRedirectUrl(): string
{
    return $this->getResource()::getUrl('index');
}
```

If you wish to be redirected to the previous page, else the index page:

```php
protected function getRedirectUrl(): string
{
    return $this->previousUrl ?? $this->getResource()::getUrl('index');
}
```

## Customizing the save notification

When the record is successfully created, a notification is dispatched to the user, which indicates the success of their action.

To customize the title of this notification, define a `getCreatedNotificationTitle()` method on the create page class:

```php
protected function getCreatedNotificationTitle(): ?string
{
    return 'User registered';
}
```

Alternatively, if you're creating records in a modal action, check out the [Actions documentation](../../actions/prebuilt-actions/create#customizing-the-save-notification).

You may customize the entire notification by overriding the `getCreatedNotification()` method on the create page class:

```php
use Filament\Notifications\Notification;

protected function getCreatedNotification(): ?Notification
{
    return Notification::make()
        ->success()
        ->title('User registered')
        ->body('The user has been created successfully.');
}
```

To disable the notification altogether, return `null` from the `getCreatedNotification()` method on the create page class:

```php
use Filament\Notifications\Notification;

protected function getCreatedNotification(): ?Notification
{
    return null;
}
```

## Lifecycle hooks

Hooks may be used to execute code at various points within a page's lifecycle, like before a form is saved. To set up a hook, create a protected method on the Create page class with the name of the hook:

```php
protected function beforeCreate(): void
{
    // ...
}
```

In this example, the code in the `beforeCreate()` method will be called before the data in the form is saved to the database.

There are several available hooks for the Create page:

```php
use Filament\Resources\Pages\CreateRecord;

class CreateUser extends CreateRecord
{
    // ...

    protected function beforeFill(): void
    {
        // Runs before the form fields are populated with their default values.
    }

    protected function afterFill(): void
    {
        // Runs after the form fields are populated with their default values.
    }

    protected function beforeValidate(): void
    {
        // Runs before the form fields are validated when the form is submitted.
    }

    protected function afterValidate(): void
    {
        // Runs after the form fields are validated when the form is submitted.
    }

    protected function beforeCreate(): void
    {
        // Runs before the form fields are saved to the database.
    }

    protected function afterCreate(): void
    {
        // Runs after the form fields are saved to the database.
    }
}
```

Alternatively, if you're creating records in a modal action, check out the [Actions documentation](../../actions/prebuilt-actions/create#lifecycle-hooks).

## Halting the creation process

At any time, you may call `$this->halt()` from inside a lifecycle hook or mutation method, which will halt the entire creation process:

```php
use Filament\Notifications\Actions\Action;
use Filament\Notifications\Notification;

protected function beforeCreate(): void
{
    if (! auth()->user()->team->subscribed()) {
        Notification::make()
            ->warning()
            ->title('You don\'t have an active subscription!')
            ->body('Choose a plan to continue.')
            ->persistent()
            ->actions([
                Action::make('subscribe')
                    ->button()
                    ->url(route('subscribe'), shouldOpenInNewTab: true),
            ])
            ->send();
    
        $this->halt();
    }
}
```

Alternatively, if you're creating records in a modal action, check out the [Actions documentation](../../actions/prebuilt-actions/create#halting-the-creation-process).

## Authorization

For authorization, Filament will observe any [model policies](https://laravel.com/docs/authorization#creating-policies) that are registered in your app.

Users may access the Create page if the `create()` method of the model policy returns `true`.

## Using a wizard

You may easily transform the creation process into a multistep wizard.

On the page class, add the corresponding `HasWizard` trait:

```php
use App\Filament\Resources\CategoryResource;
use Filament\Resources\Pages\CreateRecord;

class CreateCategory extends CreateRecord
{
    use CreateRecord\Concerns\HasWizard;
    
    protected static string $resource = CategoryResource::class;

    protected function getSteps(): array
    {
        return [
            // ...
        ];
    }
}
```

Inside the `getSteps()` array, return your [wizard steps](../../forms/layout/wizard):

```php
use Filament\Forms\Components\MarkdownEditor;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Forms\Components\Wizard\Step;

protected function getSteps(): array
{
    return [
        Step::make('Name')
            ->description('Give the category a clear and unique name')
            ->schema([
                TextInput::make('name')
                    ->required()
                    ->live()
                    ->afterStateUpdated(fn ($state, callable $set) => $set('slug', Str::slug($state))),
                TextInput::make('slug')
                    ->disabled()
                    ->required()
                    ->unique(Category::class, 'slug', fn ($record) => $record),
            ]),
        Step::make('Description')
            ->description('Add some extra details')
            ->schema([
                MarkdownEditor::make('description')
                    ->columnSpan('full'),
            ]),
        Step::make('Visibility')
            ->description('Control who can view it')
            ->schema([
                Toggle::make('is_visible')
                    ->label('Visible to customers.')
                    ->default(true),
            ]),
    ];
}
```

Alternatively, if you're creating records in a modal action, check out the [Actions documentation](../../actions/prebuilt-actions/create#using-a-wizard).

Now, create a new record to see your wizard in action! Edit will still use the form defined within the resource class.

If you'd like to allow free navigation, so all the steps are skippable, override the `hasSkippableSteps()` method:

```php
public function hasSkippableSteps(): bool
{
    return true;
}
```

### Sharing fields between the resource form and wizards

If you'd like to reduce the amount of repetition between the resource form and wizard steps, it's a good idea to extract public static resource functions for your fields, where you can easily retrieve an instance of a field from the resource or the wizard:

```php
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;

class CategoryResource extends Resource
{
    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                static::getNameFormField(),
                static::getSlugFormField(),
                // ...
            ]);
    }
    
    public static function getNameFormField(): Forms\Components\TextInput
    {
        return TextInput::make('name')
            ->required()
            ->live()
            ->afterStateUpdated(fn ($state, callable $set) => $set('slug', Str::slug($state)));
    }
    
    public static function getSlugFormField(): Forms\Components\TextInput
    {
        return TextInput::make('slug')
            ->disabled()
            ->required()
            ->unique(Category::class, 'slug', fn ($record) => $record);
    }
}
```

```php
use App\Filament\Resources\CategoryResource;
use Filament\Resources\Pages\CreateRecord;

class CreateCategory extends CreateRecord
{
    use CreateRecord\Concerns\HasWizard;
    
    protected static string $resource = CategoryResource::class;

    protected function getSteps(): array
    {
        return [
            Step::make('Name')
                ->description('Give the category a clear and unique name')
                ->schema([
                    CategoryResource::getNameFormField(),
                    CategoryResource::getSlugFormField(),
                ]),
            // ...
        ];
    }
}
```

## Importing resource records

Filament includes an `ImportAction` that you can add to the `getHeaderActions()` of the [List page](listing-records). It allows users to upload a CSV of data to import into the resource:

```php
use App\Filament\Imports\ProductImporter;
use Filament\Actions;

protected function getHeaderActions(): array
{
    return [
        Actions\ImportAction::make()
            ->importer(ProductImporter::class),
        Actions\CreateAction::make(),
    ];
}
```

The "importer" class [needs to be created](../../actions/prebuilt-actions/import#creating-an-importer) to tell Filament how to import each row of the CSV. You can learn everything about the `ImportAction` in the [Actions documentation](../../actions/prebuilt-actions/import).

## Custom actions

"Actions" are buttons that are displayed on pages, which allow the user to run a Livewire method on the page or visit a URL.

On resource pages, actions are usually in 2 places: in the top right of the page, and below the form.

For example, you may add a new button action in the header of the Create page:

```php
use App\Filament\Imports\UserImporter;
use Filament\Actions;
use Filament\Resources\Pages\CreateRecord;

class CreateUser extends CreateRecord
{
    // ...

    protected function getHeaderActions(): array
    {
        return [
            Actions\ImportAction::make()
                ->importer(UserImporter::class),
        ];
    }
}
```

Or, a new button next to "Create" below the form:

```php
use Filament\Actions\Action;
use Filament\Resources\Pages\CreateRecord;

class CreateUser extends CreateRecord
{
    // ...

    protected function getFormActions(): array
    {
        return [
            ...parent::getFormActions(),
            Action::make('close')->action('createAndClose'),
        ];
    }

    public function createAndClose(): void
    {
        // ...
    }
}
```

To view the entire actions API, please visit the [pages section](../pages#adding-actions-to-pages).

### Adding a create action button to the header

The "Create" button can be moved to the header of the page by overriding the `getHeaderActions()` method and using `getCreateFormAction()`. You need to pass `formId()` to the action, to specify that the action should submit the form with the ID of `form`, which is the `<form>` ID used in the view of the page:

```php
protected function getHeaderActions(): array
{
    return [
        $this->getCreateFormAction()
            ->formId('form'),
    ];
}
```

You may remove all actions from the form by overriding the `getFormActions()` method to return an empty array:

```php
protected function getFormActions(): array
{
    return [];
}
```

## Custom view

For further customization opportunities, you can override the static `$view` property on the page class to a custom view in your app:

```php
protected static string $view = 'filament.resources.users.pages.create-user';
```

This assumes that you have created a view at `resources/views/filament/resources/users/pages/create-user.blade.php`.

Here's a basic example of what that view might contain:

```blade
<x-filament-panels::page>
    <x-filament-panels::form wire:submit="create">
        {{ $this->form }}

        <x-filament-panels::form.actions
            :actions="$this->getCachedFormActions()"
            :full-width="$this->hasFullWidthFormActions()"
        />
    </x-filament-panels::form>
</x-filament-panels::page>
```

To see everything that the default view contains, you can check the `vendor/filament/filament/resources/views/resources/pages/create-record.blade.php` file in your project.

# Documentation for panels. File: 03-resources/04-editing-records.md
---
title: Editing records
---

## Customizing data before filling the form

You may wish to modify the data from a record before it is filled into the form. To do this, you may define a `mutateFormDataBeforeFill()` method on the Edit page class to modify the `$data` array, and return the modified version before it is filled into the form:

```php
protected function mutateFormDataBeforeFill(array $data): array
{
    $data['user_id'] = auth()->id();

    return $data;
}
```

Alternatively, if you're editing records in a modal action, check out the [Actions documentation](../../actions/prebuilt-actions/edit#customizing-data-before-filling-the-form).

## Customizing data before saving

Sometimes, you may wish to modify form data before it is finally saved to the database. To do this, you may define a `mutateFormDataBeforeSave()` method on the Edit page class, which accepts the `$data` as an array, and returns it modified:

```php
protected function mutateFormDataBeforeSave(array $data): array
{
    $data['last_edited_by_id'] = auth()->id();

    return $data;
}
```

Alternatively, if you're editing records in a modal action, check out the [Actions documentation](../../actions/prebuilt-actions/edit#customizing-data-before-saving).

## Customizing the saving process

You can tweak how the record is updated using the `handleRecordUpdate()` method on the Edit page class:

```php
use Illuminate\Database\Eloquent\Model;

protected function handleRecordUpdate(Model $record, array $data): Model
{
    $record->update($data);

    return $record;
}
```

Alternatively, if you're editing records in a modal action, check out the [Actions documentation](../../actions/prebuilt-actions/edit#customizing-the-saving-process).

## Customizing redirects

By default, saving the form will not redirect the user to another page.

You may set up a custom redirect when the form is saved by overriding the `getRedirectUrl()` method on the Edit page class.

For example, the form can redirect back to the [List page](listing-records) of the resource:

```php
protected function getRedirectUrl(): string
{
    return $this->getResource()::getUrl('index');
}
```

Or the [View page](viewing-records):

```php
protected function getRedirectUrl(): string
{
    return $this->getResource()::getUrl('view', ['record' => $this->getRecord()]);
}
```

If you wish to be redirected to the previous page, else the index page:

```php
protected function getRedirectUrl(): string
{
    return $this->previousUrl ?? $this->getResource()::getUrl('index');
}
```

## Customizing the save notification

When the record is successfully updated, a notification is dispatched to the user, which indicates the success of their action.

To customize the title of this notification, define a `getSavedNotificationTitle()` method on the edit page class:

```php
protected function getSavedNotificationTitle(): ?string
{
    return 'User updated';
}
```

Alternatively, if you're editing records in a modal action, check out the [Actions documentation](../../actions/prebuilt-actions/edit#customizing-the-save-notification).

You may customize the entire notification by overriding the `getSavedNotification()` method on the edit page class:

```php
use Filament\Notifications\Notification;

protected function getSavedNotification(): ?Notification
{
    return Notification::make()
        ->success()
        ->title('User updated')
        ->body('The user has been saved successfully.');
}
```

To disable the notification altogether, return `null` from the `getSavedNotification()` method on the edit page class:

```php
use Filament\Notifications\Notification;

protected function getSavedNotification(): ?Notification
{
    return null;
}
```

## Lifecycle hooks

Hooks may be used to execute code at various points within a page's lifecycle, like before a form is saved. To set up a hook, create a protected method on the Edit page class with the name of the hook:

```php
protected function beforeSave(): void
{
    // ...
}
```

In this example, the code in the `beforeSave()` method will be called before the data in the form is saved to the database.

There are several available hooks for the Edit pages:

```php
use Filament\Resources\Pages\EditRecord;

class EditUser extends EditRecord
{
    // ...

    protected function beforeFill(): void
    {
        // Runs before the form fields are populated from the database.
    }

    protected function afterFill(): void
    {
        // Runs after the form fields are populated from the database.
    }

    protected function beforeValidate(): void
    {
        // Runs before the form fields are validated when the form is saved.
    }

    protected function afterValidate(): void
    {
        // Runs after the form fields are validated when the form is saved.
    }

    protected function beforeSave(): void
    {
        // Runs before the form fields are saved to the database.
    }

    protected function afterSave(): void
    {
        // Runs after the form fields are saved to the database.
    }
}
```

Alternatively, if you're editing records in a modal action, check out the [Actions documentation](../../actions/prebuilt-actions/edit#lifecycle-hooks).

## Saving a part of the form independently

You may want to allow the user to save a part of the form independently of the rest of the form. One way to do this is with a [section action in the header or footer](../../forms/layout/section#adding-actions-to-the-sections-header-or-footer). From the `action()` method, you can call `saveFormComponentOnly()`, passing in the `Section` component that you want to save:

```php
use Filament\Forms\Components\Actions\Action;
use Filament\Forms\Components\Section;
use Filament\Notifications\Notification;
use Filament\Resources\Pages\EditRecord;

Section::make('Rate limiting')
    ->schema([
        // ...
    ])
    ->footerActions([
        fn (string $operation): Action => Action::make('save')
            ->action(function (Section $component, EditRecord $livewire) {
                $livewire->saveFormComponentOnly($component);
                
                Notification::make()
                    ->title('Rate limiting saved')
                    ->body('The rate limiting settings have been saved successfully.')
                    ->success()
                    ->send();
            })
            ->visible($operation === 'edit'),
    ])
```

The `$operation` helper is available, to ensure that the action is only visible when the form is being edited.

## Halting the saving process

At any time, you may call `$this->halt()` from inside a lifecycle hook or mutation method, which will halt the entire saving process:

```php
use Filament\Notifications\Actions\Action;
use Filament\Notifications\Notification;

protected function beforeSave(): void
{
    if (! $this->getRecord()->team->subscribed()) {
        Notification::make()
            ->warning()
            ->title('You don\'t have an active subscription!')
            ->body('Choose a plan to continue.')
            ->persistent()
            ->actions([
                Action::make('subscribe')
                    ->button()
                    ->url(route('subscribe'), shouldOpenInNewTab: true),
            ])
            ->send();

        $this->halt();
    }
}
```

Alternatively, if you're editing records in a modal action, check out the [Actions documentation](../../actions/prebuilt-actions/edit#halting-the-saving-process).

## Authorization

For authorization, Filament will observe any [model policies](https://laravel.com/docs/authorization#creating-policies) that are registered in your app.

Users may access the Edit page if the `update()` method of the model policy returns `true`.

They also have the ability to delete the record if the `delete()` method of the policy returns `true`.

## Custom actions

"Actions" are buttons that are displayed on pages, which allow the user to run a Livewire method on the page or visit a URL.

On resource pages, actions are usually in 2 places: in the top right of the page, and below the form.

For example, you may add a new button action next to "Delete" on the Edit page:

```php
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditUser extends EditRecord
{
    // ...

    protected function getHeaderActions(): array
    {
        return [
            Actions\Action::make('impersonate')
                ->action(function (): void {
                    // ...
                }),
            Actions\DeleteAction::make(),
        ];
    }
}
```

Or, a new button next to "Save" below the form:

```php
use Filament\Actions\Action;
use Filament\Resources\Pages\EditRecord;

class EditUser extends EditRecord
{
    // ...

    protected function getFormActions(): array
    {
        return [
            ...parent::getFormActions(),
            Action::make('close')->action('saveAndClose'),
        ];
    }

    public function saveAndClose(): void
    {
        // ...
    }
}
```

To view the entire actions API, please visit the [pages section](../pages#adding-actions-to-pages).

### Adding a save action button to the header

The "Save" button can be added to the header of the page by overriding the `getHeaderActions()` method and using `getSaveFormAction()`. You need to pass `formId()` to the action, to specify that the action should submit the form with the ID of `form`, which is the `<form>` ID used in the view of the page:

```php
protected function getHeaderActions(): array
{
    return [
        $this->getSaveFormAction()
            ->formId('form'),
    ];
}
```

You may remove all actions from the form by overriding the `getFormActions()` method to return an empty array:

```php
protected function getFormActions(): array
{
    return [];
}
```

## Creating another Edit page

One Edit page may not be enough space to allow users to navigate many form fields. You can create as many Edit pages for a resource as you want. This is especially useful if you are using [resource sub-navigation](getting-started#resource-sub-navigation), as you are then easily able to switch between the different Edit pages.

To create an Edit page, you should use the `make:filament-page` command:

```bash
php artisan make:filament-page EditCustomerContact --resource=CustomerResource --type=EditRecord
```

You must register this new page in your resource's `getPages()` method:

```php
public static function getPages(): array
{
    return [
        'index' => Pages\ListCustomers::route('/'),
        'create' => Pages\CreateCustomer::route('/create'),
        'view' => Pages\ViewCustomer::route('/{record}'),
        'edit' => Pages\EditCustomer::route('/{record}/edit'),
        'edit-contact' => Pages\EditCustomerContact::route('/{record}/edit/contact'),
    ];
}
```

Now, you can define the `form()` for this page, which can contain other fields that are not present on the main Edit page:

```php
use Filament\Forms\Form;

public function form(Form $form): Form
{
    return $form
        ->schema([
            // ...
        ]);
}
```

## Adding edit pages to resource sub-navigation

If you're using [resource sub-navigation](getting-started#resource-sub-navigation), you can register this page as normal in `getRecordSubNavigation()` of the resource:

```php
use App\Filament\Resources\CustomerResource\Pages;
use Filament\Resources\Pages\Page;

public static function getRecordSubNavigation(Page $page): array
{
    return $page->generateNavigationItems([
        // ...
        Pages\EditCustomerContact::class,
    ]);
}
```

## Custom views

For further customization opportunities, you can override the static `$view` property on the page class to a custom view in your app:

```php
protected static string $view = 'filament.resources.users.pages.edit-user';
```

This assumes that you have created a view at `resources/views/filament/resources/users/pages/edit-user.blade.php`.

Here's a basic example of what that view might contain:

```blade
<x-filament-panels::page>
    <x-filament-panels::form wire:submit="save">
        {{ $this->form }}

        <x-filament-panels::form.actions
            :actions="$this->getCachedFormActions()"
            :full-width="$this->hasFullWidthFormActions()"
        />
    </x-filament-panels::form>

    @if (count($relationManagers = $this->getRelationManagers()))
        <x-filament-panels::resources.relation-managers
            :active-manager="$this->activeRelationManager"
            :managers="$relationManagers"
            :owner-record="$record"
            :page-class="static::class"
        />
    @endif
</x-filament-panels::page>
```

To see everything that the default view contains, you can check the `vendor/filament/filament/resources/views/resources/pages/edit-record.blade.php` file in your project.

# Documentation for panels. File: 03-resources/05-viewing-records.md
---
title: Viewing records
---
import LaracastsBanner from "@components/LaracastsBanner.astro"

## Creating a resource with a View page

To create a new resource with a View page, you can use the `--view` flag:

```bash
php artisan make:filament-resource User --view
```

## Using an infolist instead of a disabled form

<LaracastsBanner
    title="Infolists"
    description="Watch the Rapid Laravel Development with Filament series on Laracasts - it will teach you the basics of adding infolists to Filament resources."
    url="https://laracasts.com/series/rapid-laravel-development-with-filament/episodes/12"
    series="rapid-laravel-development"
/>

By default, the View page will display a disabled form with the record's data. If you preferred to display the record's data in an "infolist", you can define an `infolist()` method on the resource class:

```php
use Filament\Infolists;
use Filament\Infolists\Infolist;

public static function infolist(Infolist $infolist): Infolist
{
    return $infolist
        ->schema([
            Infolists\Components\TextEntry::make('name'),
            Infolists\Components\TextEntry::make('email'),
            Infolists\Components\TextEntry::make('notes')
                ->columnSpanFull(),
        ]);
}
```

The `schema()` method is used to define the structure of your infolist. It is an array of [entries](../../infolists/entries/getting-started#available-entries) and [layout components](../../infolists/layout/getting-started#available-layout-components), in the order they should appear in your infolist.

Check out the Infolists docs for a [guide](../../infolists/getting-started) on how to build infolists with Filament.

## Adding a View page to an existing resource

If you want to add a View page to an existing resource, create a new page in your resource's `Pages` directory:

```bash
php artisan make:filament-page ViewUser --resource=UserResource --type=ViewRecord
```

You must register this new page in your resource's `getPages()` method:

```php
public static function getPages(): array
{
    return [
        'index' => Pages\ListUsers::route('/'),
        'create' => Pages\CreateUser::route('/create'),
        'view' => Pages\ViewUser::route('/{record}'),
        'edit' => Pages\EditUser::route('/{record}/edit'),
    ];
}
```

## Viewing records in modals

If your resource is simple, you may wish to view records in modals rather than on the [View page](viewing-records). If this is the case, you can just [delete the view page](getting-started#deleting-resource-pages).

If your resource doesn't contain a `ViewAction`, you can add one to the `$table->actions()` array:

```php
use Filament\Tables;
use Filament\Tables\Table;

public static function table(Table $table): Table
{
    return $table
        ->columns([
            // ...
        ])
        ->actions([
            Tables\Actions\ViewAction::make(),
            // ...
        ]);
}
```

## Customizing data before filling the form

You may wish to modify the data from a record before it is filled into the form. To do this, you may define a `mutateFormDataBeforeFill()` method on the View page class to modify the `$data` array, and return the modified version before it is filled into the form:

```php
protected function mutateFormDataBeforeFill(array $data): array
{
    $data['user_id'] = auth()->id();

    return $data;
}
```

Alternatively, if you're viewing records in a modal action, check out the [Actions documentation](../../actions/prebuilt-actions/view#customizing-data-before-filling-the-form).

## Lifecycle hooks

Hooks may be used to execute code at various points within a page's lifecycle, like before a form is filled. To set up a hook, create a protected method on the View page class with the name of the hook:

```php
use Filament\Resources\Pages\ViewRecord;

class ViewUser extends ViewRecord
{
    // ...

    protected function beforeFill(): void
    {
        // Runs before the disabled form fields are populated from the database. Not run on pages using an infolist.
    }

    protected function afterFill(): void
    {
        // Runs after the disabled form fields are populated from the database. Not run on pages using an infolist.
    }
}
```

## Authorization

For authorization, Filament will observe any [model policies](https://laravel.com/docs/authorization#creating-policies) that are registered in your app.

Users may access the View page if the `view()` method of the model policy returns `true`.

## Creating another View page

One View page may not be enough space to allow users to navigate a lot of information. You can create as many View pages for a resource as you want. This is especially useful if you are using [resource sub-navigation](getting-started#resource-sub-navigation), as you are then easily able to switch between the different View pages.

To create a View page, you should use the `make:filament-page` command:

```bash
php artisan make:filament-page ViewCustomerContact --resource=CustomerResource --type=ViewRecord
```

You must register this new page in your resource's `getPages()` method:

```php
public static function getPages(): array
{
    return [
        'index' => Pages\ListCustomers::route('/'),
        'create' => Pages\CreateCustomer::route('/create'),
        'view' => Pages\ViewCustomer::route('/{record}'),
        'view-contact' => Pages\ViewCustomerContact::route('/{record}/contact'),
        'edit' => Pages\EditCustomer::route('/{record}/edit'),
    ];
}
```

Now, you can define the `infolist()` or `form()` for this page, which can contain other components that are not present on the main View page:

```php
use Filament\Infolists\Infolist;

public function infolist(Infolist $infolist): Infolist
{
    return $infolist
        ->schema([
            // ...
        ]);
}
```

## Adding view pages to resource sub-navigation

If you're using [resource sub-navigation](getting-started#resource-sub-navigation), you can register this page as normal in `getRecordSubNavigation()` of the resource:

```php
use App\Filament\Resources\CustomerResource\Pages;
use Filament\Resources\Pages\Page;

public static function getRecordSubNavigation(Page $page): array
{
    return $page->generateNavigationItems([
        // ...
        Pages\ViewCustomerContact::class,
    ]);
}
```

## Custom view

For further customization opportunities, you can override the static `$view` property on the page class to a custom view in your app:

```php
protected static string $view = 'filament.resources.users.pages.view-user';
```

This assumes that you have created a view at `resources/views/filament/resources/users/pages/view-user.blade.php`.

Here's a basic example of what that view might contain:

```blade
<x-filament-panels::page>
    @if ($this->hasInfolist())
        {{ $this->infolist }}
    @else
        {{ $this->form }}
    @endif

    @if (count($relationManagers = $this->getRelationManagers()))
        <x-filament-panels::resources.relation-managers
            :active-manager="$this->activeRelationManager"
            :managers="$relationManagers"
            :owner-record="$record"
            :page-class="static::class"
        />
    @endif
</x-filament-panels::page>
```

To see everything that the default view contains, you can check the `vendor/filament/filament/resources/views/resources/pages/view-record.blade.php` file in your project.

# Documentation for panels. File: 03-resources/06-deleting-records.md
---
title: Deleting records
---

## Handling soft deletes

## Creating a resource with soft delete

By default, you will not be able to interact with deleted records in the app. If you'd like to add functionality to restore, force delete and filter trashed records in your resource, use the `--soft-deletes` flag when generating the resource:

```bash
php artisan make:filament-resource Customer --soft-deletes
```

## Adding soft deletes to an existing resource

Alternatively, you may add soft deleting functionality to an existing resource.

Firstly, you must update the resource:

```php
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

public static function table(Table $table): Table
{
    return $table
        ->columns([
            // ...
        ])
        ->filters([
            Tables\Filters\TrashedFilter::make(),
            // ...
        ])
        ->actions([
            // You may add these actions to your table if you're using a simple
            // resource, or you just want to be able to delete records without
            // leaving the table.
            Tables\Actions\DeleteAction::make(),
            Tables\Actions\ForceDeleteAction::make(),
            Tables\Actions\RestoreAction::make(),
            // ...
        ])
        ->bulkActions([
            Tables\Actions\BulkActionGroup::make([
                Tables\Actions\DeleteBulkAction::make(),
                Tables\Actions\ForceDeleteBulkAction::make(),
                Tables\Actions\RestoreBulkAction::make(),
                // ...
            ]),
        ]);
}

public static function getEloquentQuery(): Builder
{
    return parent::getEloquentQuery()
        ->withoutGlobalScopes([
            SoftDeletingScope::class,
        ]);
}
```

Now, update the Edit page class if you have one:

```php
use Filament\Actions;

protected function getHeaderActions(): array
{
    return [
        Actions\DeleteAction::make(),
        Actions\ForceDeleteAction::make(),
        Actions\RestoreAction::make(),
        // ...
    ];
}
```

## Deleting records on the List page

By default, you can bulk-delete records in your table. You may also wish to delete single records, using a `DeleteAction`:

```php
use Filament\Tables;
use Filament\Tables\Table;

public static function table(Table $table): Table
{
    return $table
        ->columns([
            // ...
        ])
        ->actions([
            // ...
            Tables\Actions\DeleteAction::make(),
        ]);
}
```

## Authorization

For authorization, Filament will observe any [model policies](https://laravel.com/docs/authorization#creating-policies) that are registered in your app.

Users may delete records if the `delete()` method of the model policy returns `true`.

They also have the ability to bulk-delete records if the `deleteAny()` method of the policy returns `true`. Filament uses the `deleteAny()` method because iterating through multiple records and checking the `delete()` policy is not very performant.

### Authorizing soft deletes

The `forceDelete()` policy method is used to prevent a single soft-deleted record from being force-deleted. `forceDeleteAny()` is used to prevent records from being bulk force-deleted. Filament uses the `forceDeleteAny()` method because iterating through multiple records and checking the `forceDelete()` policy is not very performant.

The `restore()` policy method is used to prevent a single soft-deleted record from being restored. `restoreAny()` is used to prevent records from being bulk restored. Filament uses the `restoreAny()` method because iterating through multiple records and checking the `restore()` policy is not very performant.

# Documentation for panels. File: 03-resources/07-relation-managers.md
---
title: Managing relationships
---
import LaracastsBanner from "@components/LaracastsBanner.astro"

## Choosing the right tool for the job

Filament provides many ways to manage relationships in the app. Which feature you should use depends on the type of relationship you are managing, and which UI you are looking for.

### Relation managers - interactive tables underneath your resource forms

> These are compatible with `HasMany`, `HasManyThrough`, `BelongsToMany`, `MorphMany` and `MorphToMany` relationships.

[Relation managers](#creating-a-relation-manager) are interactive tables that allow administrators to list, create, attach, associate, edit, detach, dissociate and delete related records without leaving the resource's Edit or View page.

### Select & checkbox list - choose from existing records or create a new one

> These are compatible with `BelongsTo`, `MorphTo` and `BelongsToMany` relationships.

Using a [select](../../forms/fields/select#integrating-with-an-eloquent-relationship), users will be able to choose from a list of existing records. You may also [add a button that allows you to create a new record inside a modal](../../forms/fields/select#creating-new-records), without leaving the page.

When using a `BelongsToMany` relationship with a select, you'll be able to select multiple options, not just one. Records will be automatically added to your pivot table when you submit the form. If you wish, you can swap out the multi-select dropdown with a simple [checkbox list](../../forms/fields/checkbox-list#integrating-with-an-eloquent-relationship). Both components work in the same way.

### Repeaters - CRUD multiple related records inside the owner's form

> These are compatible with `HasMany` and `MorphMany` relationships.

[Repeaters](../../forms/fields/repeater#integrating-with-an-eloquent-relationship) are standard form components, which can render a repeatable set of fields infinitely. They can be hooked up to a relationship, so records are automatically read, created, updated, and deleted from the related table. They live inside the main form schema, and can be used inside resource pages, as well as nesting within action modals.

From a UX perspective, this solution is only suitable if your related model only has a few fields. Otherwise, the form can get very long.

### Layout form components - saving form fields to a single relationship

> These are compatible with `BelongsTo`, `HasOne` and `MorphOne` relationships.

All layout form components ([Grid](../../forms/layout/grid#grid-component), [Section](../../forms/layout/section), [Fieldset](../../forms/layout/fieldset), etc.) have a [`relationship()` method](../../forms/advanced#saving-data-to-relationships). When you use this, all fields within that layout are saved to the related model instead of the owner's model:

```php
use Filament\Forms\Components\Fieldset;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;

Fieldset::make('Metadata')
    ->relationship('metadata')
    ->schema([
        TextInput::make('title'),
        Textarea::make('description'),
        FileUpload::make('image'),
    ])
```

In this example, the `title`, `description` and `image` are automatically loaded from the `metadata` relationship, and saved again when the form is submitted. If the `metadata` record does not exist, it is automatically created.

This feature is explained more in depth in the [Forms documentation](../../forms/advanced#saving-data-to-relationships). Please visit that page for more information about how to use it.

## Creating a relation manager

<LaracastsBanner
    title="Relation Managers"
    description="Watch the Rapid Laravel Development with Filament series on Laracasts - it will teach you the basics of adding relation managers to Filament resources."
    url="https://laracasts.com/series/rapid-laravel-development-with-filament/episodes/13"
    series="rapid-laravel-development"
/>

To create a relation manager, you can use the `make:filament-relation-manager` command:

```bash
php artisan make:filament-relation-manager CategoryResource posts title
```

- `CategoryResource` is the name of the resource class for the owner (parent) model.
- `posts` is the name of the relationship you want to manage.
- `title` is the name of the attribute that will be used to identify posts.

This will create a `CategoryResource/RelationManagers/PostsRelationManager.php` file. This contains a class where you are able to define a [form](getting-started#resource-forms) and [table](getting-started#resource-tables) for your relation manager:

```php
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Tables;
use Filament\Tables\Table;

public function form(Form $form): Form
{
    return $form
        ->schema([
            Forms\Components\TextInput::make('title')->required(),
            // ...
        ]);
}

public function table(Table $table): Table
{
    return $table
        ->columns([
            Tables\Columns\TextColumn::make('title'),
            // ...
        ]);
}
```

You must register the new relation manager in your resource's `getRelations()` method:

```php
public static function getRelations(): array
{
    return [
        RelationManagers\PostsRelationManager::class,
    ];
}
```

Once a table and form have been defined for the relation manager, visit the [Edit](editing-records) or [View](viewing-records) page of your resource to see it in action.

### Read-only mode

Relation managers are usually displayed on either the Edit or View page of a resource. On the View page, Filament will automatically hide all actions that modify the relationship, such as create, edit, and delete. We call this "read-only mode", and it is there by default to preserve the read-only behavior of the View page. However, you can disable this behavior, by overriding the `isReadOnly()` method on the relation manager class to return `false` all the time:

```php
public function isReadOnly(): bool
{
    return false;
}
```

Alternatively, if you hate this functionality, you can disable it for all relation managers at once in the panel [configuration](../configuration):

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->readOnlyRelationManagersOnResourceViewPagesByDefault(false);
}
```

### Unconventional inverse relationship names

For inverse relationships that do not follow Laravel's naming guidelines, you may wish to use the `inverseRelationship()` method on the table:

```php
use Filament\Tables;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->columns([
            Tables\Columns\TextColumn::make('title'),
            // ...
        ])
        ->inverseRelationship('section'); // Since the inverse related model is `Category`, this is normally `category`, not `section`.
}
```

### Handling soft deletes

By default, you will not be able to interact with deleted records in the relation manager. If you'd like to add functionality to restore, force delete and filter trashed records in your relation manager, use the `--soft-deletes` flag when generating the relation manager:

```bash
php artisan make:filament-relation-manager CategoryResource posts title --soft-deletes
```

You can find out more about soft deleting [here](#deleting-records).

## Listing related records

Related records will be listed in a table. The entire relation manager is based around this table, which contains actions to [create](#creating-related-records), [edit](#editing-related-records), [attach / detach](#attaching-and-detaching-records), [associate / dissociate](#associating-and-dissociating-records), and delete records.

You may use any features of the [Table Builder](../../tables) to customize relation managers.

### Listing with pivot attributes

For `BelongsToMany` and `MorphToMany` relationships, you may also add pivot table attributes. For example, if you have a `TeamsRelationManager` for your `UserResource`, and you want to add the `role` pivot attribute to the table, you can use:

```php
use Filament\Tables;

public function table(Table $table): Table
{
    return $table
        ->columns([
            Tables\Columns\TextColumn::make('name'),
            Tables\Columns\TextColumn::make('role'),
        ]);
}
```

Please ensure that any pivot attributes are listed in the `withPivot()` method of the relationship *and* inverse relationship.

## Creating related records

### Creating with pivot attributes

For `BelongsToMany` and `MorphToMany` relationships, you may also add pivot table attributes. For example, if you have a `TeamsRelationManager` for your `UserResource`, and you want to add the `role` pivot attribute to the create form, you can use:

```php
use Filament\Forms;
use Filament\Forms\Form;

public function form(Form $form): Form
{
    return $form
        ->schema([
            Forms\Components\TextInput::make('name')->required(),
            Forms\Components\TextInput::make('role')->required(),
            // ...
        ]);
}
```

Please ensure that any pivot attributes are listed in the `withPivot()` method of the relationship *and* inverse relationship.

### Customizing the `CreateAction`

To learn how to customize the `CreateAction`, including mutating the form data, changing the notification, and adding lifecycle hooks, please see the [Actions documentation](../../actions/prebuilt-actions/create).

## Editing related records

### Editing with pivot attributes

For `BelongsToMany` and `MorphToMany` relationships, you may also edit pivot table attributes. For example, if you have a `TeamsRelationManager` for your `UserResource`, and you want to add the `role` pivot attribute to the edit form, you can use:

```php
use Filament\Forms;
use Filament\Forms\Form;

public function form(Form $form): Form
{
    return $form
        ->schema([
            Forms\Components\TextInput::make('name')->required(),
            Forms\Components\TextInput::make('role')->required(),
            // ...
        ]);
}
```

Please ensure that any pivot attributes are listed in the `withPivot()` method of the relationship *and* inverse relationship.

### Customizing the `EditAction`

To learn how to customize the `EditAction`, including mutating the form data, changing the notification, and adding lifecycle hooks, please see the [Actions documentation](../../actions/prebuilt-actions/edit).

## Attaching and detaching records

Filament is able to attach and detach records for `BelongsToMany` and `MorphToMany` relationships.

When generating your relation manager, you may pass the `--attach` flag to also add `AttachAction`, `DetachAction` and `DetachBulkAction` to the table:

```bash
php artisan make:filament-relation-manager CategoryResource posts title --attach
```

Alternatively, if you've already generated your resource, you can just add the actions to the `$table` arrays:

```php
use Filament\Tables;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->columns([
            // ...
        ])
        ->headerActions([
            // ...
            Tables\Actions\AttachAction::make(),
        ])
        ->actions([
            // ...
            Tables\Actions\DetachAction::make(),
        ])
        ->bulkActions([
            Tables\Actions\BulkActionGroup::make([
                // ...
                Tables\Actions\DetachBulkAction::make(),
            ]),
        ]);
}
```

### Preloading the attachment modal select options

By default, as you search for a record to attach, options will load from the database via AJAX. If you wish to preload these options when the form is first loaded instead, you can use the `preloadRecordSelect()` method of `AttachAction`:

```php
use Filament\Tables\Actions\AttachAction;

AttachAction::make()
    ->preloadRecordSelect()
```

### Attaching with pivot attributes

When you attach record with the `Attach` button, you may wish to define a custom form to add pivot attributes to the relationship:

```php
use Filament\Forms;
use Filament\Tables\Actions\AttachAction;

AttachAction::make()
    ->form(fn (AttachAction $action): array => [
        $action->getRecordSelect(),
        Forms\Components\TextInput::make('role')->required(),
    ])
```

In this example, `$action->getRecordSelect()` returns the select field to pick the record to attach. The `role` text input is then saved to the pivot table's `role` column.

Please ensure that any pivot attributes are listed in the `withPivot()` method of the relationship *and* inverse relationship.

### Scoping the options to attach

You may want to scope the options available to `AttachAction`:

```php
use Filament\Tables\Actions\AttachAction;
use Illuminate\Database\Eloquent\Builder;

AttachAction::make()
    ->recordSelectOptionsQuery(fn (Builder $query) => $query->whereBelongsTo(auth()->user()))
```

### Searching the options to attach across multiple columns

By default, the options available to `AttachAction` will be searched in the `recordTitleAttribute()` of the table. If you wish to search across multiple columns, you can use the `recordSelectSearchColumns()` method:

```php
use Filament\Tables\Actions\AttachAction;

AttachAction::make()
    ->recordSelectSearchColumns(['title', 'description'])
```

### Attaching multiple records

The `multiple()` method on the `AttachAction` component allows you to select multiple values:

```php
use Filament\Tables\Actions\AttachAction;

AttachAction::make()
    ->multiple()
```

### Customizing the select field in the attached modal

You may customize the select field object that is used during attachment by passing a function to the `recordSelect()` method:

```php
use Filament\Forms\Components\Select;
use Filament\Tables\Actions\AttachAction;

AttachAction::make()
    ->recordSelect(
        fn (Select $select) => $select->placeholder('Select a post'),
    )
```

### Handling duplicates

By default, you will not be allowed to attach a record more than once. This is because you must also set up a primary `id` column on the pivot table for this feature to work.

Please ensure that the `id` attribute is listed in the `withPivot()` method of the relationship *and* inverse relationship.

Finally, add the `allowDuplicates()` method to the table:

```php
public function table(Table $table): Table
{
    return $table
        ->allowDuplicates();
}
```

## Associating and dissociating records

Filament is able to associate and dissociate records for `HasMany` and `MorphMany` relationships.

When generating your relation manager, you may pass the `--associate` flag to also add `AssociateAction`, `DissociateAction` and `DissociateBulkAction` to the table:

```bash
php artisan make:filament-relation-manager CategoryResource posts title --associate
```

Alternatively, if you've already generated your resource, you can just add the actions to the `$table` arrays:

```php
use Filament\Tables;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->columns([
            // ...
        ])
        ->headerActions([
            // ...
            Tables\Actions\AssociateAction::make(),
        ])
        ->actions([
            // ...
            Tables\Actions\DissociateAction::make(),
        ])
        ->bulkActions([
            Tables\Actions\BulkActionGroup::make([
                // ...
                Tables\Actions\DissociateBulkAction::make(),
            ]),
        ]);
}
```

### Preloading the associate modal select options

By default, as you search for a record to associate, options will load from the database via AJAX. If you wish to preload these options when the form is first loaded instead, you can use the `preloadRecordSelect()` method of `AssociateAction`:

```php
use Filament\Tables\Actions\AssociateAction;

AssociateAction::make()
    ->preloadRecordSelect()
```

### Scoping the options to associate

You may want to scope the options available to `AssociateAction`:

```php
use Filament\Tables\Actions\AssociateAction;
use Illuminate\Database\Eloquent\Builder;

AssociateAction::make()
    ->recordSelectOptionsQuery(fn (Builder $query) => $query->whereBelongsTo(auth()->user()))
```

### Searching the options to associate across multiple columns

By default, the options available to `AssociateAction` will be searched in the `recordTitleAttribute()` of the table. If you wish to search across multiple columns, you can use the `recordSelectSearchColumns()` method:

```php
use Filament\Tables\Actions\AssociateAction;

AssociateAction::make()
    ->recordSelectSearchColumns(['title', 'description'])
```

### Associating multiple records

The `multiple()` method on the `AssociateAction` component allows you to select multiple values:

```php
use Filament\Tables\Actions\AssociateAction;

AssociateAction::make()
    ->multiple()
```

### Customizing the select field in the associate modal

You may customize the select field object that is used during association by passing a function to the `recordSelect()` method:

```php
use Filament\Forms\Components\Select;
use Filament\Tables\Actions\AssociateAction;

AssociateAction::make()
    ->recordSelect(
        fn (Select $select) => $select->placeholder('Select a post'),
    )
```

## Viewing related records

When generating your relation manager, you may pass the `--view` flag to also add a `ViewAction` to the table:

```bash
php artisan make:filament-relation-manager CategoryResource posts title --view
```

Alternatively, if you've already generated your relation manager, you can just add the `ViewAction` to the `$table->actions()` array:

```php
use Filament\Tables;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->columns([
            // ...
        ])
        ->actions([
            Tables\Actions\ViewAction::make(),
            // ...
        ]);
}
```

## Deleting related records

By default, you will not be able to interact with deleted records in the relation manager. If you'd like to add functionality to restore, force delete and filter trashed records in your relation manager, use the `--soft-deletes` flag when generating the relation manager:

```bash
php artisan make:filament-relation-manager CategoryResource posts title --soft-deletes
```

Alternatively, you may add soft deleting functionality to an existing relation manager:

```php
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

public function table(Table $table): Table
{
    return $table
        ->modifyQueryUsing(fn (Builder $query) => $query->withoutGlobalScopes([
            SoftDeletingScope::class,
        ]))
        ->columns([
            // ...
        ])
        ->filters([
            Tables\Filters\TrashedFilter::make(),
            // ...
        ])
        ->actions([
            Tables\Actions\DeleteAction::make(),
            Tables\Actions\ForceDeleteAction::make(),
            Tables\Actions\RestoreAction::make(),
            // ...
        ])
        ->bulkActions([
            BulkActionGroup::make([
                Tables\Actions\DeleteBulkAction::make(),
                Tables\Actions\ForceDeleteBulkAction::make(),
                Tables\Actions\RestoreBulkAction::make(),
                // ...
            ]),
        ]);
}
```

### Customizing the `DeleteAction`

To learn how to customize the `DeleteAction`, including changing the notification and adding lifecycle hooks, please see the [Actions documentation](../../actions/prebuilt-actions/delete).

## Importing related records

The [`ImportAction`](../../actions/prebuilt-actions/import) can be added to the header of a relation manager to import records. In this case, you probably want to tell the importer which owner these new records belong to. You can use [import options](../../actions/prebuilt-actions/import#using-import-options) to pass through the ID of the owner record:

```php
ImportAction::make()
    ->importer(ProductImporter::class)
    ->options(['categoryId' => $this->getOwnerRecord()->getKey()])
```

Now, in the importer class, you can associate the owner in a one-to-many relationship with the imported record:

```php
public function resolveRecord(): ?Product
{
    $product = Product::firstOrNew([
        'sku' => $this->data['sku'],
    ]);
    
    $product->category()->associate($this->options['categoryId']);
    
    return $product;
}
```

Alternatively, you can attach the record in a many-to-many relationship using the `afterSave()` hook of the importer:

```php
protected function afterSave(): void
{
    $this->record->categories()->syncWithoutDetaching([$this->options['categoryId']]);
}
```

## Accessing the relationship's owner record

Relation managers are Livewire components. When they are first loaded, the owner record (the Eloquent record which serves as a parent - the main resource model) is saved into a property. You can read this property using:

```php
$this->getOwnerRecord()
```

However, if you're inside a `static` method like `form()` or `table()`, `$this` isn't accessible. So, you may [use a callback](../../forms/advanced#form-component-utility-injection) to access the `$livewire` instance:

```php
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\RelationManagers\RelationManager;

public function form(Form $form): Form
{
    return $form
        ->schema([
            Forms\Components\Select::make('store_id')
                ->options(function (RelationManager $livewire): array {
                    return $livewire->getOwnerRecord()->stores()
                        ->pluck('name', 'id')
                        ->toArray();
                }),
            // ...
        ]);
}
```

All methods in Filament accept a callback which you can access `$livewire->ownerRecord` in.

## Grouping relation managers

You may choose to group relation managers together into one tab. To do this, you may wrap multiple managers in a `RelationGroup` object, with a label:

```php
use Filament\Resources\RelationManagers\RelationGroup;

public static function getRelations(): array
{
    return [
        // ...
        RelationGroup::make('Contacts', [
            RelationManagers\IndividualsRelationManager::class,
            RelationManagers\OrganizationsRelationManager::class,
        ]),
        // ...
    ];
}
```

## Conditionally showing relation managers

By default, relation managers will be visible if the `viewAny()` method for the related model policy returns `true`.

You may use the `canViewForRecord()` method to determine if the relation manager should be visible for a specific owner record and page:

```php
use Illuminate\Database\Eloquent\Model;

public static function canViewForRecord(Model $ownerRecord, string $pageClass): bool
{
    return $ownerRecord->status === Status::Draft;
}
```

## Combining the relation manager tabs with the form

On the Edit or View page class, override the `hasCombinedRelationManagerTabsWithContent()` method:

```php
public function hasCombinedRelationManagerTabsWithContent(): bool
{
    return true;
}
```

### Setting an icon for the form tab

On the Edit or View page class, override the `getContentTabIcon()` method:

```php
public function getContentTabIcon(): ?string
{
    return 'heroicon-m-cog';
}
```

### Setting the position of the form tab

By default, the form tab is rendered before the relation tabs. To render it after, you can override the `getContentTabPosition()` method on the Edit or View page class:

```php
use Filament\Resources\Pages\ContentTabPosition;

public function getContentTabPosition(): ?ContentTabPosition
{
    return ContentTabPosition::After;
}
```

## Adding badges to relation manager tabs

You can add a badge to a relation manager tab by setting the `$badge` property:

```php
protected static ?string $badge = 'new';
```

Alternatively, you can override the `getBadge()` method:

```php
use Illuminate\Database\Eloquent\Model;

public static function getBadge(Model $ownerRecord, string $pageClass): ?string
{
    return static::$badge;
}
```

Or, if you are using a [relation group](#grouping-relation-managers), you can use the `badge()` method:

```php
use Filament\Resources\RelationManagers\RelationGroup;

RelationGroup::make('Contacts', [
    // ...
])->badge('new');
```

### Changing the color of relation manager tab badges

If a badge value is defined, it will display using the primary color by default. To style the badge contextually, set the `$badgeColor` to either `danger`, `gray`, `info`, `primary`, `success` or `warning`:

```php
protected static ?string $badgeColor = 'danger';
```

Alternatively, you can override the `getBadgeColor()` method:

```php
use Illuminate\Database\Eloquent\Model;

public static function getBadgeColor(Model $ownerRecord, string $pageClass): ?string
{
    return 'danger';
}
```

Or, if you are using a [relation group](#grouping-relation-managers), you can use the `badgeColor()` method:

```php
use Filament\Resources\RelationManagers\RelationGroup;

RelationGroup::make('Contacts', [
    // ...
])->badgeColor('danger');
```

### Adding a tooltip to relation manager tab badges

If a badge value is defined, you can add a tooltip to it by setting the `$badgeTooltip` property:

```php
protected static ?string $badgeTooltip = 'There are new posts';
```

Alternatively, you can override the `getBadgeTooltip()` method:

```php
use Illuminate\Database\Eloquent\Model;

public static function getBadgeTooltip(Model $ownerRecord, string $pageClass): ?string
{
    return 'There are new posts';
}
```

Or, if you are using a [relation group](#grouping-relation-managers), you can use the `badgeTooltip()` method:

```php
use Filament\Resources\RelationManagers\RelationGroup;

RelationGroup::make('Contacts', [
    // ...
])->badgeTooltip('There are new posts');
```

## Sharing a resource's form and table with a relation manager

You may decide that you want a resource's form and table to be identical to a relation manager's, and subsequently want to reuse the code you previously wrote. This is easy, by calling the `form()` and `table()` methods of the resource from the relation manager:

```php
use App\Filament\Resources\Blog\PostResource;
use Filament\Forms\Form;
use Filament\Tables\Table;

public function form(Form $form): Form
{
    return PostResource::form($form);
}

public function table(Table $table): Table
{
    return PostResource::table($table);
}
```

### Hiding a shared form component on the relation manager

If you're sharing a form component from the resource with the relation manager, you may want to hide it on the relation manager. This is especially useful if you want to hide a `Select` field for the owner record in the relation manager, since Filament will handle this for you anyway. To do this, you may use the `hiddenOn()` method, passing the name of the relation manager:

```php
use App\Filament\Resources\Blog\PostResource\RelationManagers\CommentsRelationManager;
use Filament\Forms\Components\Select;

Select::make('post_id')
    ->relationship('post', 'title')
    ->hiddenOn(CommentsRelationManager::class)
```

### Hiding a shared table column on the relation manager

If you're sharing a table column from the resource with the relation manager, you may want to hide it on the relation manager. This is especially useful if you want to hide a column for the owner record in the relation manager, since this is not appropriate when the owner record is already listed above the relation manager. To do this, you may use the `hiddenOn()` method, passing the name of the relation manager:

```php
use App\Filament\Resources\Blog\PostResource\RelationManagers\CommentsRelationManager;
use Filament\Tables\Columns\TextColumn;

TextColumn::make('post.title')
    ->hiddenOn(CommentsRelationManager::class)
```

### Hiding a shared table filter on the relation manager

If you're sharing a table filter from the resource with the relation manager, you may want to hide it on the relation manager. This is especially useful if you want to hide a filter for the owner record in the relation manager, since this is not appropriate when the table is already filtered by the owner record. To do this, you may use the `hiddenOn()` method, passing the name of the relation manager:

```php
use App\Filament\Resources\Blog\PostResource\RelationManagers\CommentsRelationManager;
use Filament\Tables\Filters\SelectFilter;

SelectFilter::make('post')
    ->relationship('post', 'title')
    ->hiddenOn(CommentsRelationManager::class)
```

### Overriding shared configuration on the relation manager

Any configuration that you make inside the resource can be overwritten on the relation manager. For example, if you wanted to disable pagination on the relation manager's inherited table but not the resource itself:

```php
use App\Filament\Resources\Blog\PostResource;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return PostResource::table($table)
        ->paginated(false);
}
```

It is probably also useful to provide extra configuration on the relation manager if you wanted to add a header action to [create](#creating-related-records), [attach](#attaching-and-detaching-records), or [associate](#associating-and-dissociating-records) records in the relation manager:

```php
use App\Filament\Resources\Blog\PostResource;
use Filament\Tables;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return PostResource::table($table)
        ->headerActions([
            Tables\Actions\CreateAction::make(),
            Tables\Actions\AttachAction::make(),
        ]);
}
```

## Customizing the relation manager Eloquent query

You can apply your own query constraints or [model scopes](https://laravel.com/docs/eloquent#query-scopes) that affect the entire relation manager. To do this, you can pass a function to the `modifyQueryUsing()` method of the table, inside which you can customize the query:

```php
use Filament\Tables;
use Illuminate\Database\Eloquent\Builder;

public function table(Table $table): Table
{
    return $table
        ->modifyQueryUsing(fn (Builder $query) => $query->where('is_active', true))
        ->columns([
            // ...
        ]);
}
```

## Customizing the relation manager title

To set the title of the relation manager, you can use the `$title` property on the relation manager class:

```php
protected static ?string $title = 'Posts';
```

To set the title of the relation manager dynamically, you can override the `getTitle()` method on the relation manager class:

```php
use Illuminate\Database\Eloquent\Model;

public static function getTitle(Model $ownerRecord, string $pageClass): string
{
    return __('relation-managers.posts.title');
}
```

The title will be reflected in the [heading of the table](../../tables/advanced#customizing-the-table-header), as well as the relation manager tab if there is more than one. If you want to customize the table heading independently, you can still use the `$table->heading()` method:

```php
use Filament\Tables;

public function table(Table $table): Table
{
    return $table
        ->heading('Posts')
        ->columns([
            // ...
        ]);
}
```

## Customizing the relation manager record title

The relation manager uses the concept of a "record title attribute" to determine which attribute of the related model should be used to identify it. When creating a relation manager, this attribute is passed as the third argument to the `make:filament-relation-manager` command:

```bash
php artisan make:filament-relation-manager CategoryResource posts title
```

In this example, the `title` attribute of the `Post` model will be used to identify a post in the relation manager.

This is mainly used by the action classes. For instance, when you [attach](#attaching-and-detaching-records) or [associate](#associating-and-dissociating-records) a record, the titles will be listed in the select field. When you [edit](#editing-related-records), [view](#viewing-related-records) or [delete](#deleting-related-records) a record, the title will be used in the header of the modal.

In some cases, you may want to concatenate multiple attributes together to form a title. You can do this by replacing the `recordTitleAttribute()` configuration method with `recordTitle()`, passing a function that transforms a model into a title:

```php
use App\Models\Post;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->recordTitle(fn (Post $record): string => "{$record->title} ({$record->id})")
        ->columns([
            // ...
        ]);
}
```

If you're using `recordTitle()`, and you have an [associate action](#associating-and-dissociating-records) or [attach action](#attaching-and-detaching-records), you will also want to specify search columns for those actions:

```php
use Filament\Tables\Actions\AssociateAction;
use Filament\Tables\Actions\AttachAction;

AssociateAction::make()
    ->recordSelectSearchColumns(['title', 'id']);

AttachAction::make()
    ->recordSelectSearchColumns(['title', 'id'])
```

## Relation pages

Using a `ManageRelatedRecords` page is an alternative to using a relation manager, if you want to keep the functionality of managing a relationship separate from editing or viewing the owner record.

This feature is ideal if you are using [resource sub-navigation](getting-started#resource-sub-navigation), as you are easily able to switch between the View or Edit page and the relation page.

To create a relation page, you should use the `make:filament-page` command:

```bash
php artisan make:filament-page ManageCustomerAddresses --resource=CustomerResource --type=ManageRelatedRecords
```

When you run this command, you will be asked a series of questions to customize the page, for example, the name of the relationship and its title attribute.

You must register this new page in your resource's `getPages()` method:

```php
public static function getPages(): array
{
    return [
        'index' => Pages\ListCustomers::route('/'),
        'create' => Pages\CreateCustomer::route('/create'),
        'view' => Pages\ViewCustomer::route('/{record}'),
        'edit' => Pages\EditCustomer::route('/{record}/edit'),
        'addresses' => Pages\ManageCustomerAddresses::route('/{record}/addresses'),
    ];
}
```

> When using a relation page, you do not need to generate a relation manager with `make:filament-relation-manager`, and you do not need to register it in the `getRelations()` method of the resource.

Now, you can customize the page in exactly the same way as a relation manager, with the same `table()` and `form()`.

### Adding relation pages to resource sub-navigation

If you're using [resource sub-navigation](getting-started#resource-sub-navigation), you can register this page as normal in `getRecordSubNavigation()` of the resource:

```php
use App\Filament\Resources\CustomerResource\Pages;
use Filament\Resources\Pages\Page;

public static function getRecordSubNavigation(Page $page): array
{
    return $page->generateNavigationItems([
        // ...
        Pages\ManageCustomerAddresses::class,
    ]);
}
```

## Passing properties to relation managers

When registering a relation manager in a resource, you can use the `make()` method to pass an array of [Livewire properties](https://livewire.laravel.com/docs/properties) to it:

```php
use App\Filament\Resources\Blog\PostResource\RelationManagers\CommentsRelationManager;

public static function getRelations(): array
{
    return [
        CommentsRelationManager::make([
            'status' => 'approved',
        ]),
    ];
}
```

This array of properties gets mapped to [public Livewire properties](https://livewire.laravel.com/docs/properties) on the relation manager class:

```php
use Filament\Resources\RelationManagers\RelationManager;

class CommentsRelationManager extends RelationManager
{
    public string $status;

    // ...
}
```

Now, you can access the `status` in the relation manager class using `$this->status`.

## Disabling lazy loading

By default, relation managers are lazy-loaded. This means that they will only be loaded when they are visible on the page.

To disable this behavior, you may override the `$isLazy` property on the relation manager class:

```php
protected static bool $isLazy = false;
```

# Documentation for panels. File: 03-resources/08-global-search.md
---
title: Global search
---

## Overview

Global search allows you to search across all of your resource records, from anywhere in the app.

## Setting global search result titles

To enable global search on your model, you must [set a title attribute](getting-started#record-titles) for your resource:

```php
protected static ?string $recordTitleAttribute = 'title';
```

This attribute is used to retrieve the search result title for that record.

> Your resource needs to have an Edit or View page to allow the global search results to link to a URL, otherwise no results will be returned for this resource.

You may customize the title further by overriding `getGlobalSearchResultTitle()` method. It may return a plain text string, or an instance of `Illuminate\Support\HtmlString` or `Illuminate\Contracts\Support\Htmlable`. This allows you to render HTML, or even Markdown, in the search result title:

```php
use Illuminate\Contracts\Support\Htmlable;

public static function getGlobalSearchResultTitle(Model $record): string | Htmlable
{
    return $record->name;
}
```

## Globally searching across multiple columns

If you would like to search across multiple columns of your resource, you may override the `getGloballySearchableAttributes()` method. "Dot notation" allows you to search inside relationships:

```php
public static function getGloballySearchableAttributes(): array
{
    return ['title', 'slug', 'author.name', 'category.name'];
}
```

## Adding extra details to global search results

Search results can display "details" below their title, which gives the user more information about the record. To enable this feature, you must override the `getGlobalSearchResultDetails()` method:

```php
public static function getGlobalSearchResultDetails(Model $record): array
{
    return [
        'Author' => $record->author->name,
        'Category' => $record->category->name,
    ];
}
```

In this example, the category and author of the record will be displayed below its title in the search result. However, the `category` and `author` relationships will be lazy-loaded, which will result in poor results performance. To [eager-load](https://laravel.com/docs/eloquent-relationships#eager-loading) these relationships, we must override the `getGlobalSearchEloquentQuery()` method:

```php
public static function getGlobalSearchEloquentQuery(): Builder
{
    return parent::getGlobalSearchEloquentQuery()->with(['author', 'category']);
}
```

## Customizing global search result URLs

Global search results will link to the [Edit page](editing-records) of your resource, or the [View page](viewing-page) if the user does not have [edit permissions](editing-records#authorization). To customize this, you may override the `getGlobalSearchResultUrl()` method and return a route of your choice:

```php
public static function getGlobalSearchResultUrl(Model $record): string
{
    return UserResource::getUrl('edit', ['record' => $record]);
}
```

## Adding actions to global search results

Global search supports actions, which are buttons that render below each search result. They can open a URL or dispatch a Livewire event.

Actions can be defined as follows:

```php
use Filament\GlobalSearch\Actions\Action;

public static function getGlobalSearchResultActions(Model $record): array
{
    return [
        Action::make('edit')
            ->url(static::getUrl('edit', ['record' => $record])),
    ];
}
```

You can learn more about how to style action buttons [here](../../actions/trigger-button).

### Opening URLs from global search actions

You can open a URL, optionally in a new tab, when clicking on an action:

```php
use Filament\GlobalSearch\Actions\Action;

Action::make('view')
    ->url(static::getUrl('view', ['record' => $record]), shouldOpenInNewTab: true)
```

### Dispatching Livewire events from global search actions

Sometimes you want to execute additional code when a global search result action is clicked. This can be achieved by setting a Livewire event which should be dispatched on clicking the action. You may optionally pass an array of data, which will be available as parameters in the event listener on your Livewire component:

```php
use Filament\GlobalSearch\Actions\Action;

Action::make('quickView')
    ->dispatch('quickView', [$record->id])
```

## Limiting the number of global search results

By default, global search will return up to 50 results per resource. You can customize this on the resource label by overriding the `$globalSearchResultsLimit` property:

```php
protected static int $globalSearchResultsLimit = 20;
```

## Disabling global search

As [explained above](#title), global search is automatically enabled once you set a title attribute for your resource. Sometimes you may want to specify the title attribute while not enabling global search.

This can be achieved by disabling global search in the [configuration](configuration):

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->globalSearch(false);
}
```

## Registering global search key bindings

The global search field can be opened using keyboard shortcuts. To configure these, pass the `globalSearchKeyBindings()` method to the [configuration](configuration):

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->globalSearchKeyBindings(['command+k', 'ctrl+k']);
}
```

## Configuring the global search debounce

Global search has a default debounce time of 500ms, to limit the number of requests that are made while the user is typing. You can alter this by using the `globalSearchDebounce()` method in the [configuration](configuration):

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->globalSearchDebounce('750ms');
}
```

## Configuring the global search field suffix

Global search field by default doesn't include any suffix. You may customize it using the `globalSearchFieldSuffix()` method in the [configuration](configuration).

If you want to display the currently configured [global search key bindings](#registering-global-search-key-bindings) in the suffix, you can use the `globalSearchFieldKeyBindingSuffix()` method, which will display the first registered key binding as the suffix of the global search field:

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->globalSearchFieldKeyBindingSuffix();
}
```

To customize the suffix yourself, you can pass a string or function to the `globalSearchFieldSuffix()` method. For example, to provide a custom key binding suffix for each platform manually:

```php
use Filament\Panel;
use Filament\Support\Enums\Platform;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->globalSearchFieldSuffix(fn (): ?string => match (Platform::detect()) {
            Platform::Windows, Platform::Linux => 'CTRL+K',
            Platform::Mac => '⌘K',
            default => null,
        });
}
```

# Documentation for panels. File: 03-resources/09-widgets.md
---
title: Widgets
---
import LaracastsBanner from "@components/LaracastsBanner.astro"

## Overview

<LaracastsBanner
    title="Widgets"
    description="Watch the Rapid Laravel Development with Filament series on Laracasts - it will teach you the basics of adding widgets to Filament resources."
    url="https://laracasts.com/series/rapid-laravel-development-with-filament/episodes/15"
    series="rapid-laravel-development"
/>

Filament allows you to display widgets inside pages, below the header and above the footer.

You can use an existing [dashboard widget](../dashboard), or create one specifically for the resource.

## Creating a resource widget

To get started building a resource widget:

```bash
php artisan make:filament-widget CustomerOverview --resource=CustomerResource
```

This command will create two files - a widget class in the `app/Filament/Resources/CustomerResource/Widgets` directory, and a view in the `resources/views/filament/resources/customer-resource/widgets` directory.

You must register the new widget in your resource's `getWidgets()` method:

```php
public static function getWidgets(): array
{
    return [
        CustomerResource\Widgets\CustomerOverview::class,
    ];
}
```

If you'd like to learn how to build and customize widgets, check out the [Dashboard](../dashboard) documentation section.

## Displaying a widget on a resource page

To display a widget on a resource page, use the `getHeaderWidgets()` or `getFooterWidgets()` methods for that page:

```php
<?php

namespace App\Filament\Resources\CustomerResource\Pages;

use App\Filament\Resources\CustomerResource;

class ListCustomers extends ListRecords
{
    public static string $resource = CustomerResource::class;

    protected function getHeaderWidgets(): array
    {
        return [
            CustomerResource\Widgets\CustomerOverview::class,
        ];
    }
}
```

`getHeaderWidgets()` returns an array of widgets to display above the page content, whereas `getFooterWidgets()` are displayed below.

If you'd like to customize the number of grid columns used to arrange widgets, check out the [Pages documentation](../pages#customizing-the-widgets-grid).

## Accessing the current record in the widget

If you're using a widget on an [Edit](editing-records) or [View](viewing-records) page, you may access the current record by defining a `$record` property on the widget class:

```php
use Illuminate\Database\Eloquent\Model;

public ?Model $record = null;
```

## Accessing page table data in the widget

If you're using a widget on a [List](listing-records) page, you may access the table data by first adding the `ExposesTableToWidgets` trait to the page class:

```php
use Filament\Pages\Concerns\ExposesTableToWidgets;
use Filament\Resources\Pages\ListRecords;

class ListProducts extends ListRecords
{
    use ExposesTableToWidgets;

    // ...
}
```

Now, on the widget class, you must add the `InteractsWithPageTable` trait, and return the name of the page class from the `getTablePage()` method:

```php
use App\Filament\Resources\ProductResource\Pages\ListProducts;
use Filament\Widgets\Concerns\InteractsWithPageTable;
use Filament\Widgets\Widget;

class ProductStats extends Widget
{
    use InteractsWithPageTable;

    protected function getTablePage(): string
    {
        return ListProducts::class;
    }

    // ...
}
```

In the widget class, you can now access the Eloquent query builder instance for the table data using the `$this->getPageTableQuery()` method:

```php
use Filament\Widgets\StatsOverviewWidget\Stat;

Stat::make('Total Products', $this->getPageTableQuery()->count()),
```

Alternatively, you can access a collection of the records on the current page using the `$this->getPageTableRecords()` method:

```php
use Filament\Widgets\StatsOverviewWidget\Stat;

Stat::make('Total Products', $this->getPageTableRecords()->count()),
```

## Passing properties to widgets on resource pages

When registering a widget on a resource page, you can use the `make()` method to pass an array of [Livewire properties](https://livewire.laravel.com/docs/properties) to it:

```php
protected function getHeaderWidgets(): array
{
    return [
        CustomerResource\Widgets\CustomerOverview::make([
            'status' => 'active',
        ]),
    ];
}
```

This array of properties gets mapped to [public Livewire properties](https://livewire.laravel.com/docs/properties) on the widget class:

```php
use Filament\Widgets\Widget;

class CustomerOverview extends Widget
{
    public string $status;

    // ...
}
```

Now, you can access the `status` in the widget class using `$this->status`.

# Documentation for panels. File: 03-resources/10-custom-pages.md
---
title: Custom pages
---

## Overview

Filament allows you to create completely custom pages for resources. To create a new page, you can use:

```bash
php artisan make:filament-page SortUsers --resource=UserResource --type=custom
```

This command will create two files - a page class in the `/Pages` directory of your resource directory, and a view in the `/pages` directory of the resource views directory.

You must register custom pages to a route in the static `getPages()` method of your resource:

```php
public static function getPages(): array
{
    return [
        // ...
        'sort' => Pages\SortUsers::route('/sort'),
    ];
}
```

> The order of pages registered in this method matters - any wildcard route segments that are defined before hard-coded ones will be matched by Laravel's router first.

Any [parameters](https://laravel.com/docs/routing#route-parameters) defined in the route's path will be available to the page class, in an identical way to [Livewire](https://livewire.laravel.com/docs/components#accessing-route-parameters).

## Using a resource record

If you'd like to create a page that uses a record similar to the [Edit](editing-records) or [View](viewing-records) pages, you can use the `InteractsWithRecord` trait:

```php
use Filament\Resources\Pages\Page;
use Filament\Resources\Pages\Concerns\InteractsWithRecord;

class ManageUser extends Page
{
    use InteractsWithRecord;
    
    public function mount(int | string $record): void
    {
        $this->record = $this->resolveRecord($record);
    }

    // ...
}
```

The `mount()` method should resolve the record from the URL and store it in `$this->record`. You can access the record at any time using `$this->getRecord()` in the class or view.

To add the record to the route as a parameter, you must define `{record}` in `getPages()`:

```php
public static function getPages(): array
{
    return [
        // ...
        'manage' => Pages\ManageUser::route('/{record}/manage'),
    ];
}
```

# Documentation for panels. File: 03-resources/11-security.md
---
title: Security
---

## Protecting model attributes

Filament will expose all model attributes to JavaScript, except if they are `$hidden` on your model. This is Livewire's behavior for model binding. We preserve this functionality to facilitate the dynamic addition and removal of form fields after they are initially loaded, while preserving the data they may need.

> While attributes may be visible in JavaScript, only those with a form field are actually editable by the user. This is not an issue with mass assignment.

To remove certain attributes from JavaScript on the Edit and View pages, you may override [the `mutateFormDataBeforeFill()` method](editing-records#customizing-data-before-filling-the-form):

```php
protected function mutateFormDataBeforeFill(array $data): array
{
    unset($data['is_admin']);

    return $data;
}
```

In this example, we remove the `is_admin` attribute from JavaScript, as it's not being used by the form.

# Documentation for panels. File: 04-pages.md
---
title: Pages
---

## Overview

Filament allows you to create completely custom pages for the app.

## Creating a page

To create a new page, you can use:

```bash
php artisan make:filament-page Settings
```

This command will create two files - a page class in the `/Pages` directory of the Filament directory, and a view in the `/pages` directory of the Filament views directory.

Page classes are all full-page [Livewire](https://livewire.laravel.com) components with a few extra utilities you can use with the panel.

## Authorization

You can prevent pages from appearing in the menu by overriding the `canAccess()` method in your Page class. This is useful if you want to control which users can see the page in the navigation, and also which users can visit the page directly:

```php
public static function canAccess(): bool
{
    return auth()->user()->canManageSettings();
}
```

## Adding actions to pages

Actions are buttons that can perform tasks on the page, or visit a URL. You can read more about their capabilities [here](../actions).

Since all pages are Livewire components, you can [add actions](../actions/adding-an-action-to-a-livewire-component#adding-the-action) anywhere. Pages already have the `InteractsWithActions` trait, `HasActions` interface, and `<x-filament-actions::modals />` Blade component all set up for you.

### Header actions

You can also easily add actions to the header of any page, including [resource pages](resources/getting-started). You don't need to worry about adding anything to the Blade template, we handle that for you. Just return your actions from the `getHeaderActions()` method of the page class:

```php
use Filament\Actions\Action;

protected function getHeaderActions(): array
{
    return [
        Action::make('edit')
            ->url(route('posts.edit', ['post' => $this->post])),
        Action::make('delete')
            ->requiresConfirmation()
            ->action(fn () => $this->post->delete()),
    ];
}
```

### Opening an action modal when a page loads

You can also open an action when a page loads by setting the `$defaultAction` property to the name of the action you want to open:

```php
use Filament\Actions\Action;

public $defaultAction = 'onboarding';

public function onboardingAction(): Action
{
    return Action::make('onboarding')
        ->modalHeading('Welcome')
        ->visible(fn (): bool => ! auth()->user()->isOnBoarded());
}
```

You can also pass an array of arguments to the default action using the `$defaultActionArguments` property:

```php
public $defaultActionArguments = ['step' => 2];
```

Alternatively, you can open an action modal when a page loads by specifying the `action` as a query string parameter to the page:

```
/admin/products/edit/932510?action=onboarding
```

### Refreshing form data

If you're using actions on an [Edit](resources/editing-records) or [View](resources/viewing-records) resource page, you can refresh data within the main form using the `refreshFormData()` method:

```php
use App\Models\Post;
use Filament\Actions\Action;

Action::make('approve')
    ->action(function (Post $record) {
        $record->approve();

        $this->refreshFormData([
            'status',
        ]);
    })
```

This method accepts an array of model attributes that you wish to refresh in the form.

## Adding widgets to pages

Filament allows you to display [widgets](dashboard) inside pages, below the header and above the footer.

To add a widget to a page, use the `getHeaderWidgets()` or `getFooterWidgets()` methods:

```php
use App\Filament\Widgets\StatsOverviewWidget;

protected function getHeaderWidgets(): array
{
    return [
        StatsOverviewWidget::class
    ];
}
```

`getHeaderWidgets()` returns an array of widgets to display above the page content, whereas `getFooterWidgets()` are displayed below.

If you'd like to learn how to build and customize widgets, check out the [Dashboard](dashboard) documentation section.

### Customizing the widgets' grid

You may change how many grid columns are used to display widgets.

You may override the `getHeaderWidgetsColumns()` or `getFooterWidgetsColumns()` methods to return a number of grid columns to use:

```php
public function getHeaderWidgetsColumns(): int | array
{
    return 3;
}
```

#### Responsive widgets grid

You may wish to change the number of widget grid columns based on the responsive [breakpoint](https://tailwindcss.com/docs/responsive-design#overview) of the browser. You can do this using an array that contains the number of columns that should be used at each breakpoint:

```php
public function getHeaderWidgetsColumns(): int | array
{
    return [
        'md' => 4,
        'xl' => 5,
    ];
}
```

This pairs well with [responsive widget widths](dashboard#responsive-widget-widths).

#### Passing data to widgets from the page

You may pass data to widgets from the page using the `getWidgetsData()` method:

```php
public function getWidgetData(): array
{
    return [
        'stats' => [
            'total' => 100,
        ],
    ];
}
```

Now, you can define a corresponding public `$stats` array property on the widget class, which will be automatically filled:

```php
public $stats = [];
```

### Passing properties to widgets on pages

When registering a widget on a page, you can use the `make()` method to pass an array of [Livewire properties](https://livewire.laravel.com/docs/properties) to it:

```php
use App\Filament\Widgets\StatsOverviewWidget;

protected function getHeaderWidgets(): array
{
    return [
        StatsOverviewWidget::make([
            'status' => 'active',
        ]),
    ];
}
```

This array of properties gets mapped to [public Livewire properties](https://livewire.laravel.com/docs/properties) on the widget class:

```php
use Filament\Widgets\Widget;

class StatsOverviewWidget extends Widget
{
    public string $status;

    // ...
}
```

Now, you can access the `status` in the widget class using `$this->status`.

## Customizing the page title

By default, Filament will automatically generate a title for your page based on its name. You may override this by defining a `$title` property on your page class:

```php
protected static ?string $title = 'Custom Page Title';
```

Alternatively, you may return a string from the `getTitle()` method:

```php
use Illuminate\Contracts\Support\Htmlable;

public function getTitle(): string | Htmlable
{
    return __('Custom Page Title');
}
```

## Customizing the page navigation label

By default, Filament will use the page's [title](#customizing-the-page-title) as its [navigation](navigation) item label. You may override this by defining a `$navigationLabel` property on your page class:

```php
protected static ?string $navigationLabel = 'Custom Navigation Label';
```

Alternatively, you may return a string from the `getNavigationLabel()` method:

```php
public static function getNavigationLabel(): string
{
    return __('Custom Navigation Label');
}
```

## Customizing the page URL

By default, Filament will automatically generate a URL (slug) for your page based on its name. You may override this by defining a `$slug` property on your page class:

```php
protected static ?string $slug = 'custom-url-slug';
```

## Customizing the page heading

By default, Filament will use the page's [title](#customizing-the-page-title) as its heading. You may override this by defining a `$heading` property on your page class:

```php
protected ?string $heading = 'Custom Page Heading';
```

Alternatively, you may return a string from the `getHeading()` method:

```php
public function getHeading(): string
{
    return __('Custom Page Heading');
}
```

### Adding a page subheading

You may also add a subheading to your page by defining a `$subheading` property on your page class:

```php
protected ?string $subheading = 'Custom Page Subheading';
```

Alternatively, you may return a string from the `getSubheading()` method:

```php
public function getSubheading(): ?string
{
    return __('Custom Page Subheading');
}
```

## Replacing the page header with a custom view

You may replace the default [heading](#customizing-the-page-heading), [subheading](#adding-a-page-subheading) and [actions](#header-actions) with a custom header view for any page. You may return it from the `getHeader()` method:

```php
use Illuminate\Contracts\View\View;

public function getHeader(): ?View
{
    return view('filament.settings.custom-header');
}
```

This example assumes you have a Blade view at `resources/views/filament/settings/custom-header.blade.php`.

## Rendering a custom view in the footer of the page

You may also add a footer to any page, below its content. You may return it from the `getFooter()` method:

```php
use Illuminate\Contracts\View\View;

public function getFooter(): ?View
{
    return view('filament.settings.custom-footer');
}
```

This example assumes you have a Blade view at `resources/views/filament/settings/custom-footer.blade.php`.

## Customizing the maximum content width

By default, Filament will restrict the width of the content on the page, so it doesn't become too wide on large screens. To change this, you may override the `getMaxContentWidth()` method. Options correspond to [Tailwind's max-width scale](https://tailwindcss.com/docs/max-width). The options are `ExtraSmall`, `Small`, `Medium`, `Large`, `ExtraLarge`, `TwoExtraLarge`, `ThreeExtraLarge`, `FourExtraLarge`, `FiveExtraLarge`, `SixExtraLarge`, `SevenExtraLarge`, `Full`, `MinContent`, `MaxContent`, `FitContent`,  `Prose`, `ScreenSmall`, `ScreenMedium`, `ScreenLarge`, `ScreenExtraLarge` and `ScreenTwoExtraLarge`. The default is `SevenExtraLarge`:

```php
use Filament\Support\Enums\MaxWidth;

public function getMaxContentWidth(): MaxWidth
{
    return MaxWidth::Full;
}
```

## Generating URLs to pages

Filament provides `getUrl()` static method on page classes to generate URLs to them. Traditionally, you would need to construct the URL by hand or by using Laravel's `route()` helper, but these methods depend on knowledge of the page's slug or route naming conventions.

The `getUrl()` method, without any arguments, will generate a URL:

```php
use App\Filament\Pages\Settings;

Settings::getUrl(); // /admin/settings
```

If your page uses URL / query parameters, you should use the argument:

```php
use App\Filament\Pages\Settings;

Settings::getUrl(['section' => 'notifications']); // /admin/settings?section=notifications
```

### Generating URLs to pages in other panels

If you have multiple panels in your app, `getUrl()` will generate a URL within the current panel. You can also indicate which panel the page is associated with, by passing the panel ID to the `panel` argument:

```php
use App\Filament\Pages\Settings;

Settings::getUrl(panel: 'marketing');
```

## Adding sub-navigation between pages

You may want to add a common sub-navigation to multiple pages, to allow users to quickly navigate between them. You can do this by defining a [cluster](clusters). Clusters can also contain [resources](resources), and you can switch between multiple pages or resources within a cluster.

## Adding extra attributes to the body tag of a page

You may wish to add extra attributes to the `<body>` tag of a page. To do this, you can set an array of attributes in `$extraBodyAttributes`:

```php
protected array $extraBodyAttributes = [];
```

Or, you can return an array of attributes and their values from the `getExtraBodyAttributes()` method:

```php
public function getExtraBodyAttributes(): array
{
    return [
        'class' => 'settings-page',
    ];
}
```

# Documentation for panels. File: 05-dashboard.md
---
title: Dashboard
---

## Overview

Filament allows you to build dynamic dashboards, comprised of "widgets", very easily.

The following document will explain how to use these widgets to assemble a dashboard using the panel.

## Available widgets

Filament ships with these widgets:

- [Stats overview](../widgets/stats-overview) widgets display any data, often numeric data, as stats in a row.
- [Chart](../widgets/charts) widgets display numeric data in a visual chart.
- [Table](#table-widgets) widgets which display a [table](../tables/getting-started) on your dashboard.

You may also [create your own custom widgets](#custom-widgets) which can then have a consistent design with Filament's prebuilt widgets.

## Sorting widgets

Each widget class contains a `$sort` property that may be used to change its order on the page, relative to other widgets:

```php
protected static ?int $sort = 2;
```

## Customizing widget width

You may customize the width of a widget using the `$columnSpan` property. You may use a number between 1 and 12 to indicate how many columns the widget should span, or `full` to make it occupy the full width of the page:

```php
protected int | string | array $columnSpan = 'full';
```

### Responsive widget widths

You may wish to change the widget width based on the responsive [breakpoint](https://tailwindcss.com/docs/responsive-design#overview) of the browser. You can do this using an array that contains the number of columns that the widget should occupy at each breakpoint:

```php
protected int | string | array $columnSpan = [
    'md' => 2,
    'xl' => 3,
];
```

This is especially useful when using a [responsive widgets grid](#responsive-widgets-grid).

## Customizing the widgets' grid

You may change how many grid columns are used to display widgets.

Firstly, you must [replace the original Dashboard page](#customizing-the-dashboard-page).

Now, in your new `app/Filament/Pages/Dashboard.php` file, you may override the `getColumns()` method to return a number of grid columns to use:

```php
public function getColumns(): int | string | array
{
    return 2;
}
```

### Responsive widgets grid

You may wish to change the number of widget grid columns based on the responsive [breakpoint](https://tailwindcss.com/docs/responsive-design#overview) of the browser. You can do this using an array that contains the number of columns that should be used at each breakpoint:

```php
public function getColumns(): int | string | array
{
    return [
        'md' => 4,
        'xl' => 5,
    ];
}
```

This pairs well with [responsive widget widths](#responsive-widget-widths).

## Conditionally hiding widgets

You may override the static `canView()` method on widgets to conditionally hide them:

```php
public static function canView(): bool
{
    return auth()->user()->isAdmin();
}
```

## Table widgets

You may easily add tables to your dashboard. Start by creating a widget with the command:

```bash
php artisan make:filament-widget LatestOrders --table
```

You may now [customize the table](../tables/getting-started) by editing the widget file.

## Custom widgets

To get started building a `BlogPostsOverview` widget:

```bash
php artisan make:filament-widget BlogPostsOverview
```

This command will create two files - a widget class in the `/Widgets` directory of the Filament directory, and a view in the `/widgets` directory of the Filament views directory.

## Filtering widget data

You may add a form to the dashboard that allows the user to filter the data displayed across all widgets. When the filters are updated, the widgets will be reloaded with the new data.

Firstly, you must [replace the original Dashboard page](#customizing-the-dashboard-page).

Now, in your new `app/Filament/Pages/Dashboard.php` file, you may add the `HasFiltersForm` trait, and add the `filtersForm()` method to return form components:

```php
use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\Section;
use Filament\Forms\Form;
use Filament\Pages\Dashboard as BaseDashboard;
use Filament\Pages\Dashboard\Concerns\HasFiltersForm;

class Dashboard extends BaseDashboard
{
    use HasFiltersForm;

    public function filtersForm(Form $form): Form
    {
        return $form
            ->schema([
                Section::make()
                    ->schema([
                        DatePicker::make('startDate'),
                        DatePicker::make('endDate'),
                        // ...
                    ])
                    ->columns(3),
            ]);
    }
}
```

In widget classes that require data from the filters, you need to add the `InteractsWithPageFilters` trait, which will allow you to use the `$this->filters` property to access the raw data from the filters form:

```php
use App\Models\BlogPost;
use Carbon\CarbonImmutable;
use Filament\Widgets\StatsOverviewWidget;
use Filament\Widgets\Concerns\InteractsWithPageFilters;
use Illuminate\Database\Eloquent\Builder;

class BlogPostsOverview extends StatsOverviewWidget
{
    use InteractsWithPageFilters;

    public function getStats(): array
    {
        $startDate = $this->filters['startDate'] ?? null;
        $endDate = $this->filters['endDate'] ?? null;

        return [
            StatsOverviewWidget\Stat::make(
                label: 'Total posts',
                value: BlogPost::query()
                    ->when($startDate, fn (Builder $query) => $query->whereDate('created_at', '>=', $startDate))
                    ->when($endDate, fn (Builder $query) => $query->whereDate('created_at', '<=', $endDate))
                    ->count(),
            ),
            // ...
        ];
    }
}
```

The `$this->filters` array will always reflect the current form data. Please note that this data is not validated, as it is available live and not intended to be used for anything other than querying the database. You must ensure that the data is valid before using it. In this example, we check if the start date is set before using it in the query.

### Filtering widget data using an action modal

Alternatively, you can swap out the filters form for an action modal, that can be opened by clicking a button in the header of the page. There are many benefits to using this approach:

- The filters form is not always visible, which allows you to use the full height of the page for widgets.
- The filters do not update the widgets until the user clicks the "Apply" button, which means that the widgets are not reloaded until the user is ready. This can improve performance if the widgets are expensive to load.
- Validation can be performed on the filters form, which means that the widgets can rely on the fact that the data is valid - the user cannot submit the form until it is. Canceling the modal will discard the user's changes.

To use an action modal instead of a filters form, you can use the `HasFiltersAction` trait instead of `HasFiltersForm`. Then, register the `FilterAction` class as an action in `getHeaderActions()`:

```php
use Filament\Forms\Components\DatePicker;
use Filament\Forms\Form;
use Filament\Pages\Dashboard as BaseDashboard;
use Filament\Pages\Dashboard\Actions\FilterAction;
use Filament\Pages\Dashboard\Concerns\HasFiltersAction;

class Dashboard extends BaseDashboard
{
    use HasFiltersAction;
    
    protected function getHeaderActions(): array
    {
        return [
            FilterAction::make()
                ->form([
                    DatePicker::make('startDate'),
                    DatePicker::make('endDate'),
                    // ...
                ]),
        ];
    }
}
```

Handling data from the filter action is the same as handling data from the filters header form, except that the data is validated before being passed to the widget. The `InteractsWithPageFilters` trait still applies.

## Disabling the default widgets

By default, two widgets are displayed on the dashboard. These widgets can be disabled by updating the `widgets()` array of the [configuration](configuration):

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->widgets([]);
}
```

## Customizing the dashboard page

If you want to customize the dashboard class, for example, to [change the number of widget columns](#customizing-widget-width), create a new file at `app/Filament/Pages/Dashboard.php`:

```php
<?php

namespace App\Filament\Pages;

class Dashboard extends \Filament\Pages\Dashboard
{
    // ...
}
```

Finally, remove the original `Dashboard` class from [configuration file](configuration):

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->pages([]);
}
```

### Creating multiple dashboards

If you want to create multiple dashboards, you can do so by repeating [the process described above](#customizing-the-dashboard-page). Creating new pages that extend the `Dashboard` class will allow you to create as many dashboards as you need.

You will also need to define the URL path to the extra dashboard, otherwise it will be at `/`:

```php
protected static string $routePath = 'finance';
```

You may also customize the title of the dashboard by overriding the `$title` property:

```php
protected static ?string $title = 'Finance dashboard';
```

The primary dashboard shown to a user is the first one they have access to (controlled by [`canAccess()` method](pages#authorization)), according to the defined navigation sort order.

The default sort order for dashboards is `-2`. You can control the sort order of custom dashboards with `$navigationSort`:

```php
protected static ?int $navigationSort = 15;
```

# Documentation for panels. File: 06-navigation.md
---
title: Navigation
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Overview

By default, Filament will register navigation items for each of your [resources](resources/getting-started), [custom pages](pages), and [clusters](clusters). These classes contain static properties and methods that you can override, to configure that navigation item.

If you're looking to add a second layer of navigation to your app, you can use [clusters](clusters). These are useful for grouping resources and pages together.

## Customizing a navigation item's label

By default, the navigation label is generated from the resource or page's name. You may customize this using the `$navigationLabel` property:

```php
protected static ?string $navigationLabel = 'Custom Navigation Label';
```

Alternatively, you may override the `getNavigationLabel()` method:

```php
public static function getNavigationLabel(): string
{
    return 'Custom Navigation Label';
}
```

## Customizing a navigation item's icon

To customize a navigation item's [icon](https://blade-ui-kit.com/blade-icons?set=1#search), you may override the `$navigationIcon` property on the [resource](resources/getting-started) or [page](pages) class:

```php
protected static ?string $navigationIcon = 'heroicon-o-document-text';
```

<AutoScreenshot name="panels/navigation/change-icon" alt="Changed navigation item icon" version="3.x" />

If you set `$navigationIcon = null` on all items within the same navigation group, those items will be joined with a vertical bar below the group label.

### Switching navigation item icon when it is active

You may assign a navigation [icon](https://blade-ui-kit.com/blade-icons?set=1#search) which will only be used for active items using the `$activeNavigationIcon` property:

```php
protected static ?string $activeNavigationIcon = 'heroicon-o-document-text';
```

<AutoScreenshot name="panels/navigation/active-icon" alt="Different navigation item icon when active" version="3.x" />

## Sorting navigation items

By default, navigation items are sorted alphabetically. You may customize this using the `$navigationSort` property:

```php
protected static ?int $navigationSort = 3;
```

Now, navigation items with a lower sort value will appear before those with a higher sort value - the order is ascending.

<AutoScreenshot name="panels/navigation/sort-items" alt="Sort navigation items" version="3.x" />

## Adding a badge to a navigation item

To add a badge next to the navigation item, you can use the `getNavigationBadge()` method and return the content of the badge:

```php
public static function getNavigationBadge(): ?string
{
    return static::getModel()::count();
}
```

<AutoScreenshot name="panels/navigation/badge" alt="Navigation item with badge" version="3.x" />

If a badge value is returned by `getNavigationBadge()`, it will display using the primary color by default. To style the badge contextually, return either `danger`, `gray`, `info`, `primary`, `success` or `warning` from the `getNavigationBadgeColor()` method:

```php
public static function getNavigationBadgeColor(): ?string
{
    return static::getModel()::count() > 10 ? 'warning' : 'primary';
}
```

<AutoScreenshot name="panels/navigation/badge-color" alt="Navigation item with badge color" version="3.x" />

A custom tooltip for the navigation badge can be set in `$navigationBadgeTooltip`:

```php
protected static ?string $navigationBadgeTooltip = 'The number of users';
```

Or it can be returned from `getNavigationBadgeTooltip()`:

```php
public static function getNavigationBadgeTooltip(): ?string
{
    return 'The number of users';
}
```

<AutoScreenshot name="panels/navigation/badge-tooltip" alt="Navigation item with badge tooltip" version="3.x" />

## Grouping navigation items

You may group navigation items by specifying a `$navigationGroup` property on a [resource](resources/getting-started) and [custom page](pages):

```php
protected static ?string $navigationGroup = 'Settings';
```

<AutoScreenshot name="panels/navigation/group" alt="Grouped navigation items" version="3.x" />

All items in the same navigation group will be displayed together under the same group label, "Settings" in this case. Ungrouped items will remain at the start of the navigation.

### Grouping navigation items under other items

You may group navigation items as children of other items, by passing the label of the parent item as the `$navigationParentItem`:

```php
protected static ?string $navigationParentItem = 'Notifications';

protected static ?string $navigationGroup = 'Settings';
```

You may also use the `getNavigationParentItem()` method to set a dynamic parent item label:

```php
public static function getNavigationParentItem(): ?string
{
    return __('filament/navigation.groups.settings.items.notifications');
}
```

As seen above, if the parent item has a navigation group, that navigation group must also be defined, so the correct parent item can be identified.

> If you're reaching for a third level of navigation like this, you should consider using [clusters](clusters) instead, which are a logical grouping of resources and custom pages, which can share their own separate navigation.

### Customizing navigation groups

You may customize navigation groups by calling `navigationGroups()` in the [configuration](configuration), and passing `NavigationGroup` objects in order:

```php
use Filament\Navigation\NavigationGroup;
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->navigationGroups([
            NavigationGroup::make()
                 ->label('Shop')
                 ->icon('heroicon-o-shopping-cart'),
            NavigationGroup::make()
                ->label('Blog')
                ->icon('heroicon-o-pencil'),
            NavigationGroup::make()
                ->label(fn (): string => __('navigation.settings'))
                ->icon('heroicon-o-cog-6-tooth')
                ->collapsed(),
        ]);
}
```

In this example, we pass in a custom `icon()` for the groups, and make one `collapsed()` by default.

#### Ordering navigation groups

By using `navigationGroups()`, you are defining a new order for the navigation groups. If you just want to reorder the groups and not define an entire `NavigationGroup` object, you may just pass the labels of the groups in the new order:

```php
$panel
    ->navigationGroups([
        'Shop',
        'Blog',
        'Settings',
    ])
```

#### Making navigation groups not collapsible

By default, navigation groups are collapsible.

<AutoScreenshot name="panels/navigation/group-collapsible" alt="Collapsible navigation groups" version="3.x" />

You may disable this behavior by calling `collapsible(false)` on the `NavigationGroup` object:

```php
use Filament\Navigation\NavigationGroup;

NavigationGroup::make()
    ->label('Settings')
    ->icon('heroicon-o-cog-6-tooth')
    ->collapsible(false);
```

<AutoScreenshot name="panels/navigation/group-not-collapsible" alt="Not collapsible navigation groups" version="3.x" />

Or, you can do it globally for all groups in the [configuration](configuration):

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->collapsibleNavigationGroups(false);
}
```

#### Adding extra HTML attributes to navigation groups

You can pass extra HTML attributes to the navigation group, which will be merged onto the outer DOM element. Pass an array of attributes to the `extraSidebarAttributes()` or `extraTopbarAttributes()` method, where the key is the attribute name and the value is the attribute value:

```php
NavigationGroup::make()
    ->extraSidebarAttributes(['class' => 'featured-sidebar-group']),
    ->extraTopbarAttributes(['class' => 'featured-topbar-group']),
```

The `extraSidebarAttributes()` will be applied to navigation group elements contained in the sidebar, and the `extraTopbarAttributes()` will only be applied to topbar navigation group dropdowns when using [top navigation](#using-top-navigation).

## Collapsible sidebar on desktop

To make the sidebar collapsible on desktop as well as mobile, you can use the [configuration](configuration):

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->sidebarCollapsibleOnDesktop();
}
```

<AutoScreenshot name="panels/navigation/sidebar-collapsible-on-desktop" alt="Collapsible sidebar on desktop" version="3.x" />

By default, when you collapse the sidebar on desktop, the navigation icons still show. You can fully collapse the sidebar using the `sidebarFullyCollapsibleOnDesktop()` method:

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->sidebarFullyCollapsibleOnDesktop();
}
```

<AutoScreenshot name="panels/navigation/sidebar-fully-collapsible-on-desktop" alt="Fully collapsible sidebar on desktop" version="3.x" />

### Navigation groups in a collapsible sidebar on desktop

> This section only applies to `sidebarCollapsibleOnDesktop()`, not `sidebarFullyCollapsibleOnDesktop()`, since the fully collapsible UI just hides the entire sidebar instead of changing its design.

When using a collapsible sidebar on desktop, you will also often be using [navigation groups](#grouping-navigation-items). By default, the labels of each navigation group will be hidden when the sidebar is collapsed, since there is no space to display them. Even if the navigation group itself is [collapsible](#making-navigation-groups-not-collapsible), all items will still be visible in the collapsed sidebar, since there is no group label to click on to expand the group.

These issues can be solved, to achieve a very minimal sidebar design, by [passing an `icon()`](#customizing-navigation-groups) to the navigation group objects. When an icon is defined, the icon will be displayed in the collapsed sidebar instead of the items at all times. When the icon is clicked, a dropdown will open to the side of the icon, revealing the items in the group.

When passing an icon to a navigation group, even if the items also have icons, the expanded sidebar UI will not show the item icons. This is to keep the navigation hierarchy clear, and the design minimal. However, the icons for the items will be shown in the collapsed sidebar's dropdowns though, since the hierarchy is already clear from the fact that the dropdown is open.

## Registering custom navigation items

To register new navigation items, you can use the [configuration](configuration):

```php
use Filament\Navigation\NavigationItem;
use Filament\Pages\Dashboard;
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->navigationItems([
            NavigationItem::make('Analytics')
                ->url('https://filament.pirsch.io', shouldOpenInNewTab: true)
                ->icon('heroicon-o-presentation-chart-line')
                ->group('Reports')
                ->sort(3),
            NavigationItem::make('dashboard')
                ->label(fn (): string => __('filament-panels::pages/dashboard.title'))
                ->url(fn (): string => Dashboard::getUrl())
                ->isActiveWhen(fn () => request()->routeIs('filament.admin.pages.dashboard')),
            // ...
        ]);
}
```

## Conditionally hiding navigation items

You can also conditionally hide a navigation item by using the `visible()` or `hidden()` methods, passing in a condition to check:

```php
use Filament\Navigation\NavigationItem;

NavigationItem::make('Analytics')
    ->visible(fn(): bool => auth()->user()->can('view-analytics'))
    // or
    ->hidden(fn(): bool => ! auth()->user()->can('view-analytics')),
```

## Disabling resource or page navigation items

To prevent resources or pages from showing up in navigation, you may use:

```php
protected static bool $shouldRegisterNavigation = false;
```

Or, you may override the `shouldRegisterNavigation()` method:

```php
public static function shouldRegisterNavigation(): bool
{
    return false;
}
```

Please note that these methods do not control direct access to the resource or page. They only control whether the resource or page will show up in the navigation. If you want to also control access, then you should use [resource authorization](resources/getting-started#authorization) or [page authorization](pages#authorization).

## Using top navigation

By default, Filament will use a sidebar navigation. You may use a top navigation instead by using the [configuration](configuration):

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->topNavigation();
}
```

<AutoScreenshot name="panels/navigation/top-navigation" alt="Top navigation" version="3.x" />

## Customizing the width of the sidebar

You can customize the width of the sidebar by passing it to the `sidebarWidth()` method in the [configuration](configuration):

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->sidebarWidth('40rem');
}
```

Additionally, if you are using the `sidebarCollapsibleOnDesktop()` method, you can customize width of the collapsed icons by using the `collapsedSidebarWidth()` method in the [configuration](configuration):

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->sidebarCollapsibleOnDesktop()
        ->collapsedSidebarWidth('9rem');
}
```

## Advanced navigation customization

The `navigation()` method can be called from the [configuration](configuration). It allows you to build a custom navigation that overrides Filament's automatically generated items. This API is designed to give you complete control over the navigation.

### Registering custom navigation items

To register navigation items, call the `items()` method:

```php
use App\Filament\Pages\Settings;
use App\Filament\Resources\UserResource;
use Filament\Navigation\NavigationBuilder;
use Filament\Navigation\NavigationItem;
use Filament\Pages\Dashboard;
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->navigation(function (NavigationBuilder $builder): NavigationBuilder {
            return $builder->items([
                NavigationItem::make('Dashboard')
                    ->icon('heroicon-o-home')
                    ->isActiveWhen(fn (): bool => request()->routeIs('filament.admin.pages.dashboard'))
                    ->url(fn (): string => Dashboard::getUrl()),
                ...UserResource::getNavigationItems(),
                ...Settings::getNavigationItems(),
            ]);
        });
}
```

<AutoScreenshot name="panels/navigation/custom-items" alt="Custom navigation items" version="3.x" />

### Registering custom navigation groups

If you want to register groups, you can call the `groups()` method:

```php
use App\Filament\Pages\HomePageSettings;
use App\Filament\Resources\CategoryResource;
use App\Filament\Resources\PageResource;
use Filament\Navigation\NavigationBuilder;
use Filament\Navigation\NavigationGroup;
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->navigation(function (NavigationBuilder $builder): NavigationBuilder {
            return $builder->groups([
                NavigationGroup::make('Website')
                    ->items([
                        ...PageResource::getNavigationItems(),
                        ...CategoryResource::getNavigationItems(),
                        ...HomePageSettings::getNavigationItems(),
                    ]),
            ]);
        });
}
```

### Disabling navigation

You may disable navigation entirely by passing `false` to the `navigation()` method:

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->navigation(false);
}
```

<AutoScreenshot name="panels/navigation/disabled-navigation" alt="Disabled navigation sidebar" version="3.x" />

### Disabling the topbar

You may disable topbar entirely by passing `false` to the `topbar()` method:

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->topbar(false);
}
```

## Customizing the user menu

The user menu is featured in the top right corner of the admin layout. It's fully customizable.

To register new items to the user menu, you can use the [configuration](configuration):

```php
use App\Filament\Pages\Settings;
use Filament\Navigation\MenuItem;
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->userMenuItems([
            MenuItem::make()
                ->label('Settings')
                ->url(fn (): string => Settings::getUrl())
                ->icon('heroicon-o-cog-6-tooth'),
            // ...
        ]);
}
```

<AutoScreenshot name="panels/navigation/user-menu" alt="User menu with custom menu item" version="3.x" />

### Customizing the profile link

To customize the user profile link at the start of the user menu, register a new item with the `profile` array key:

```php
use Filament\Navigation\MenuItem;
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->userMenuItems([
            'profile' => MenuItem::make()->label('Edit profile'),
            // ...
        ]);
}
```

For more information on creating a profile page, check out the [authentication features documentation](users#authentication-features).

### Customizing the logout link

To customize the user logout link at the end of the user menu, register a new item with the `logout` array key:

```php
use Filament\Navigation\MenuItem;
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->userMenuItems([
            'logout' => MenuItem::make()->label('Log out'),
            // ...
        ]);
}
```

### Conditionally hiding user menu items

You can also conditionally hide a user menu item by using the `visible()` or `hidden()` methods, passing in a condition to check. Passing a function will defer condition evaluation until the menu is actually being rendered:

```php
use App\Models\Payment;
use Filament\Navigation\MenuItem;

MenuItem::make()
    ->label('Payments')
    ->visible(fn (): bool => auth()->user()->can('viewAny', Payment::class))
    // or
    ->hidden(fn (): bool => ! auth()->user()->can('viewAny', Payment::class))
```

### Sending a `POST` HTTP request from a user menu item

You can send a `POST` HTTP request from a user menu item by passing a URL to the `postAction()` method:

```php
use Filament\Navigation\MenuItem;

MenuItem::make()
    ->label('Lock session')
    ->postAction(fn (): string => route('lock-session'))
```

## Disabling breadcrumbs

The default layout will show breadcrumbs to indicate the location of the current page within the hierarchy of the app.

You may disable breadcrumbs in your [configuration](configuration):

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->breadcrumbs(false);
}
```

# Documentation for panels. File: 07-notifications.md
---
title: Notifications
---

## Overview

The Panel Builder uses the [Notifications](../notifications/sending-notifications) package to send messages to users. Please read the [documentation](../notifications/sending-notifications) to discover how to send notifications easily.

If you'd like to receive [database notifications](../notifications/database-notifications), you can enable them in the [configuration](configuration):

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->databaseNotifications();
}
```

You may also control database notification [polling](../notifications/database-notifications#polling-for-new-database-notifications):

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->databaseNotifications()
        ->databaseNotificationsPolling('30s');
}
```

## Setting up websockets in a panel

The Panel Builder comes with a level of inbuilt support for real-time broadcast and database notifications. However there are a number of areas you will need to install and configure to wire everything up and get it working.

1. If you haven't already, read up on [broadcasting](https://laravel.com/docs/broadcasting) in the Laravel documentation.
2. Install and configure broadcasting to use a [server-side websockets integration](https://laravel.com/docs/broadcasting#server-side-installation) like Pusher.
3. If you haven't already, you will need to publish the Filament package configuration:

```bash
php artisan vendor:publish --tag=filament-config
```

4. Edit the configuration at `config/filament.php` and uncomment the `broadcasting.echo` section - ensuring the settings are correctly configured according to your broadcasting installation.
5. Ensure the [relevant `VITE_*` entries](https://laravel.com/docs/broadcasting#client-pusher-channels) exist in your `.env` file.
6. Clear relevant caches with `php artisan route:clear` and `php artisan config:clear` to ensure your new configuration takes effect.

Your panel should now be connecting to your broadcasting service. For example, if you log into the Pusher debug console you should see an incoming connection each time you load a page.

To send a real-time notification, see the [broadcast notifications documentation](../notifications/broadcast-notifications).

# Documentation for panels. File: 08-users.md
---
title: Users
---

## Overview

By default, all `App\Models\User`s can access Filament locally. To allow them to access Filament in production, you must take a few extra steps to ensure that only the correct users have access to the app.

## Authorizing access to the panel

To set up your `App\Models\User` to access Filament in non-local environments, you must implement the `FilamentUser` contract:

```php
<?php

namespace App\Models;

use Filament\Models\Contracts\FilamentUser;
use Filament\Panel;
use Illuminate\Foundation\Auth\User as Authenticatable;

class User extends Authenticatable implements FilamentUser
{
    // ...

    public function canAccessPanel(Panel $panel): bool
    {
        return str_ends_with($this->email, '@yourdomain.com') && $this->hasVerifiedEmail();
    }
}
```

The `canAccessPanel()` method returns `true` or `false` depending on whether the user is allowed to access the `$panel`. In this example, we check if the user's email ends with `@yourdomain.com` and if they have verified their email address.

Since you have access to the current `$panel`, you can write conditional checks for separate panels. For example, only restricting access to the admin panel while allowing all users to access the other panels of your app:

```php
<?php

namespace App\Models;

use Filament\Models\Contracts\FilamentUser;
use Filament\Panel;
use Illuminate\Foundation\Auth\User as Authenticatable;

class User extends Authenticatable implements FilamentUser
{
    // ...

    public function canAccessPanel(Panel $panel): bool
    {
        if ($panel->getId() === 'admin') {
            return str_ends_with($this->email, '@yourdomain.com') && $this->hasVerifiedEmail();
        }

        return true;
    }
}
```

## Authorizing access to Resources

See the [Authorization](resources/getting-started#authorization) section in the Resource documentation for controlling access to Resource pages and their data records.

## Setting up user avatars

Out of the box, Filament uses [ui-avatars.com](https://ui-avatars.com) to generate avatars based on a user's name. However, if your user model has an `avatar_url` attribute, that will be used instead. To customize how Filament gets a user's avatar URL, you can implement the `HasAvatar` contract:

```php
<?php

namespace App\Models;

use Filament\Models\Contracts\FilamentUser;
use Filament\Models\Contracts\HasAvatar;
use Illuminate\Foundation\Auth\User as Authenticatable;

class User extends Authenticatable implements FilamentUser, HasAvatar
{
    // ...

    public function getFilamentAvatarUrl(): ?string
    {
        return $this->avatar_url;
    }
}
```

The `getFilamentAvatarUrl()` method is used to retrieve the avatar of the current user. If `null` is returned from this method, Filament will fall back to [ui-avatars.com](https://ui-avatars.com).

### Using a different avatar provider

You can easily swap out [ui-avatars.com](https://ui-avatars.com) for a different service, by creating a new avatar provider.

In this example, we create a new file at `app/Filament/AvatarProviders/BoringAvatarsProvider.php` for [boringavatars.com](https://boringavatars.com). The `get()` method accepts a user model instance and returns an avatar URL for that user:

```php
<?php

namespace App\Filament\AvatarProviders;

use Filament\AvatarProviders\Contracts;
use Filament\Facades\Filament;
use Illuminate\Contracts\Auth\Authenticatable;
use Illuminate\Database\Eloquent\Model;

class BoringAvatarsProvider implements Contracts\AvatarProvider
{
    public function get(Model | Authenticatable $record): string
    {
        $name = str(Filament::getNameForDefaultAvatar($record))
            ->trim()
            ->explode(' ')
            ->map(fn (string $segment): string => filled($segment) ? mb_substr($segment, 0, 1) : '')
            ->join(' ');

        return 'https://source.boringavatars.com/beam/120/' . urlencode($name);
    }
}
```

Now, register this new avatar provider in the [configuration](configuration):

```php
use App\Filament\AvatarProviders\BoringAvatarsProvider;
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->defaultAvatarProvider(BoringAvatarsProvider::class);
}
```

## Configuring the user's name attribute

By default, Filament will use the `name` attribute of the user to display their name in the app. To change this, you can implement the `HasName` contract:

```php
<?php

namespace App\Models;

use Filament\Models\Contracts\FilamentUser;
use Filament\Models\Contracts\HasName;
use Illuminate\Foundation\Auth\User as Authenticatable;

class User extends Authenticatable implements FilamentUser, HasName
{
    // ...

    public function getFilamentName(): string
    {
        return "{$this->first_name} {$this->last_name}";
    }
}
```

The `getFilamentName()` method is used to retrieve the name of the current user.

## Authentication features

You can easily enable authentication features for a panel in the configuration file:

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->login()
        ->registration()
        ->passwordReset()
        ->emailVerification()
        ->profile();
}
```

### Customizing the authentication features

If you'd like to replace these pages with your own, you can pass in any Filament page class to these methods.

Most people will be able to make their desired customizations by extending the base page class from the Filament codebase, overriding methods like `form()`, and then passing the new page class in to the configuration:

```php
use App\Filament\Pages\Auth\EditProfile;
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->profile(EditProfile::class);
}
```

In this example, we will customize the profile page. We need to create a new PHP class at `app/Filament/Pages/Auth/EditProfile.php`:

```php
<?php

namespace App\Filament\Pages\Auth;

use Filament\Forms\Components\TextInput;
use Filament\Forms\Form;
use Filament\Pages\Auth\EditProfile as BaseEditProfile;

class EditProfile extends BaseEditProfile
{
    public function form(Form $form): Form
    {
        return $form
            ->schema([
                TextInput::make('username')
                    ->required()
                    ->maxLength(255),
                $this->getNameFormComponent(),
                $this->getEmailFormComponent(),
                $this->getPasswordFormComponent(),
                $this->getPasswordConfirmationFormComponent(),
            ]);
    }
}
```

This class extends the base profile page class from the Filament codebase. Other page classes you could extend include:

- `Filament\Pages\Auth\Login`
- `Filament\Pages\Auth\Register`
- `Filament\Pages\Auth\EmailVerification\EmailVerificationPrompt`
- `Filament\Pages\Auth\PasswordReset\RequestPasswordReset`
- `Filament\Pages\Auth\PasswordReset\ResetPassword`

In the `form()` method of the example, we call methods like `getNameFormComponent()` to get the default form components for the page. You can customize these components as required. For all the available customization options, see the base `EditProfile` page class in the Filament codebase - it contains all the methods that you can override to make changes.

#### Customizing an authentication field without needing to re-define the form

If you'd like to customize a field in an authentication form without needing to define a new `form()` method, you could extend the specific field method and chain your customizations:

```php
use Filament\Forms\Components\Component;

protected function getPasswordFormComponent(): Component
{
    return parent::getPasswordFormComponent()
        ->revealable(false);
}
```

### Using a sidebar on the profile page

By default, the profile page does not use the standard page layout with a sidebar. This is so that it works with the [tenancy](tenancy) feature, otherwise it would not be accessible if the user had no tenants, since the sidebar links are routed to the current tenant.

If you aren't using [tenancy](tenancy) in your panel, and you'd like the profile page to use the standard page layout with a sidebar, you can pass the `isSimple: false` parameter to `$panel->profile()` when registering the page:

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->profile(isSimple: false);
}
```

### Customizing the authentication route slugs

You can customize the URL slugs used for the authentication routes in the [configuration](configuration):

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->loginRouteSlug('login')
        ->registrationRouteSlug('register')
        ->passwordResetRoutePrefix('password-reset')
        ->passwordResetRequestRouteSlug('request')
        ->passwordResetRouteSlug('reset')
        ->emailVerificationRoutePrefix('email-verification')
        ->emailVerificationPromptRouteSlug('prompt')
        ->emailVerificationRouteSlug('verify');
}
```

### Setting the authentication guard

To set the authentication guard that Filament uses, you can pass in the guard name to the `authGuard()` [configuration](configuration) method:

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->authGuard('web');
}
```

### Setting the password broker

To set the password broker that Filament uses, you can pass in the broker name to the `authPasswordBroker()` [configuration](configuration) method:

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->authPasswordBroker('users');
}
```

### Disabling revealable password inputs

By default, all password inputs in authentication forms are [`revealable()`](../forms/fields/text-input#revealable-password-inputs). This allows the user can see a plain text version of the password they're typing by clicking a button. To disable this feature, you can pass `false` to the `revealablePasswords()` [configuration](configuration) method:

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->revealablePasswords(false);
}
```

You could also disable this feature on a per-field basis by calling `->revealable(false)` on the field object when [extending the base page class](#customizing-an-authentication-field-without-needing-to-re-define-the-form).

## Setting up guest access to a panel

By default, Filament expects to work with authenticated users only. To allow guests to access a panel, you need to avoid using components which expect a signed-in user (such as profiles, avatars), and remove the built-in Authentication middleware:

- Remove the default `Authenticate::class` from the `authMiddleware()` array in the panel configuration.
- Remove `->login()` and any other [authentication features](#authentication-features) from the panel.
- Remove the default `AccountWidget` from the `widgets()` array, because it reads the current user's data.

### Authorizing guests in policies

When present, Filament relies on [Laravel Model Policies](https://laravel.com/docs/authorization#generating-policies) for access control. To give read-access for [guest users in a model policy](https://laravel.com/docs/authorization#guest-users), create the Policy and update the `viewAny()` and `view()` methods, changing the `User $user` param to `?User $user` so that it's optional, and `return true;`. Alternatively, you can remove those methods from the policy entirely.

# Documentation for panels. File: 09-configuration.md
---
title: Configuration
---

## Overview

By default, the configuration file is located at `app/Providers/Filament/AdminPanelProvider.php`. Keep reading to learn more about [panels](#introducing-panels) and how each has [its own configuration file](#creating-a-new-panel).

## Introducing panels

By default, when you install the package, there is one panel that has been set up for you - and it lives on `/admin`. All the [resources](resources/getting-started), [custom pages](pages), and [dashboard widgets](dashboard) you create get registered to this panel.

However, you can create as many panels as you want, and each can have its own set of resources, pages and widgets.

For example, you could build a panel where users can log in at `/app` and access their dashboard, and admins can log in at `/admin` and manage the app. The `/app` panel and the `/admin` panel have their own resources, since each group of users has different requirements. Filament allows you to do that by providing you with the ability to create multiple panels.

### The default admin panel

When you run `filament:install`, a new file is created in `app/Providers/Filament` - `AdminPanelProvider.php`. This file contains the configuration for the `/admin` panel.

When this documentation refers to the "configuration", this is the file you need to edit. It allows you to completely customize the app.

### Creating a new panel

To create a new panel, you can use the `make:filament-panel` command, passing in the unique name of the new panel:

```bash
php artisan make:filament-panel app
```

This command will create a new panel called "app". A configuration file will be created at `app/Providers/Filament/AppPanelProvider.php`. You can access this panel at `/app`, but you can [customize the path](#changing-the-path) if you don't want that.

Since this configuration file is also a [Laravel service provider](https://laravel.com/docs/providers), it needs to be registered in `bootstrap/providers.php` (Laravel 11 and above) or `config/app.php` (Laravel 10 and below). Filament will attempt to do this for you, but if you get an error while trying to access your panel then this process has probably failed.

## Changing the path

In a panel configuration file, you can change the path that the app is accessible at using the `path()` method:

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->path('app');
}
```

If you want the app to be accessible without any prefix, you can set this to be an empty string:

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->path('');
}
```

Make sure your `routes/web.php` file doesn't already define the `''` or `'/'` route, as it will take precedence.

## Render hooks

[Render hooks](../support/render-hooks) allow you to render Blade content at various points in the framework views. You can [register global render hooks](../support/render-hooks#registering-render-hooks) in a service provider or middleware, but it also allows you to register render hooks that are specific to a panel. To do that, you can use the `renderHook()` method on the panel configuration object. Here's an example, integrating [`wire-elements/modal`](https://github.com/wire-elements/modal) with Filament:

```php
use Filament\Panel;
use Filament\View\PanelsRenderHook;
use Illuminate\Support\Facades\Blade;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->renderHook(
            PanelsRenderHook::BODY_START,
            fn (): string => Blade::render('@livewire(\'livewire-ui-modal\')'),
        );
}
```

A full list of available render hooks can be found [here](../support/render-hooks#available-render-hooks).

## Setting a domain

By default, Filament will respond to requests from all domains. If you'd like to scope it to a specific domain, you can use the `domain()` method, similar to [`Route::domain()` in Laravel](https://laravel.com/docs/routing#route-group-subdomain-routing):

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->domain('admin.example.com');
}
```

## Customizing the maximum content width

By default, Filament will restrict the width of the content on the page, so it doesn't become too wide on large screens. To change this, you may use the `maxContentWidth()` method. Options correspond to [Tailwind's max-width scale](https://tailwindcss.com/docs/max-width). The options are `ExtraSmall`, `Small`, `Medium`, `Large`, `ExtraLarge`, `TwoExtraLarge`, `ThreeExtraLarge`, `FourExtraLarge`, `FiveExtraLarge`, `SixExtraLarge`, `SevenExtraLarge`, `Full`, `MinContent`, `MaxContent`, `FitContent`,  `Prose`, `ScreenSmall`, `ScreenMedium`, `ScreenLarge`, `ScreenExtraLarge` and `ScreenTwoExtraLarge`. The default is `SevenExtraLarge`:

```php
use Filament\Panel;
use Filament\Support\Enums\MaxWidth;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->maxContentWidth(MaxWidth::Full);
}
```

If you'd like to set the max content width for pages of the type `SimplePage`, like login and registration pages, you may do so using the `simplePageMaxContentWidth()` method. The default is `Large`:

```php
use Filament\Panel;
use Filament\Support\Enums\MaxWidth;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->simplePageMaxContentWidth(MaxWidth::Small);
}
```

## Lifecycle hooks

Hooks may be used to execute code during a panel's lifecycle. `bootUsing()` is a hook that gets run on every request that takes place within that panel. If you have multiple panels, only the current panel's `bootUsing()` will be run. The function gets run from middleware, after all service providers have been booted:

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->bootUsing(function (Panel $panel) {
            // ...
        });
}
```

## SPA mode

SPA mode utilizes [Livewire's `wire:navigate` feature](https://livewire.laravel.com/docs/navigate) to make your server-rendered panel feel like a single-page-application, with less delay between page loads and a loading bar for longer requests. To enable SPA mode on a panel, you can use the `spa()` method:

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->spa();
}
```

### Disabling SPA navigation for specific URLs

By default, when enabling SPA mode, any URL that lives on the same domain as the current request will be navigated to using Livewire's [`wire:navigate`](https://livewire.laravel.com/docs/navigate) feature. If you want to disable this for specific URLs, you can use the `spaUrlExceptions()` method:

```php
use App\Filament\Resources\PostResource;
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->spa()
        ->spaUrlExceptions(fn (): array => [
            url('/admin'),
            PostResource::getUrl(),
        ]);
}
```

> In this example, we are using [`getUrl()`](/resources/getting-started#generating-urls-to-resource-pages) on a resource to get the URL to the resource's index page. This feature requires the panel to already be registered though, and the configuration is too early in the request lifecycle to do that. You can use a function to return the URLs instead, which will be resolved when the panel has been registered.

These URLs need to exactly match the URL that the user is navigating to, including the domain and protocol. If you'd like to use a pattern to match multiple URLs, you can use an asterisk (`*`) as a wildcard character:

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->spa()
        ->spaUrlExceptions([
            '*/admin/posts/*',
        ]);
}
```

## Unsaved changes alerts

You may alert users if they attempt to navigate away from a page without saving their changes. This is applied on [Create](resources/creating-records) and [Edit](resources/editing-records) pages of a resource, as well as any open action modals. To enable this feature, you can use the `unsavedChangesAlerts()` method:

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->unsavedChangesAlerts();
}
```

## Enabling database transactions

By default, Filament does not wrap operations in database transactions, and allows the user to enable this themselves when they have tested to ensure that their operations are safe to be wrapped in a transaction. However, you can enable database transactions at once for all operations by using the `databaseTransactions()` method:

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->databaseTransactions();
}
```

For any actions you do not want to be wrapped in a transaction, you can use the `databaseTransaction(false)` method:

```php
CreateAction::make()
    ->databaseTransaction(false)
```

And for any pages like [Create resource](resources/creating-records) and [Edit resource](resources/editing-records), you can define the `$hasDatabaseTransactions` property to `false` on the page class:

```php
use Filament\Resources\Pages\CreateRecord;

class CreatePost extends CreateRecord
{
    protected ?bool $hasDatabaseTransactions = false;

    // ...
}
```

### Opting in to database transactions for specific actions and pages

Instead of enabling database transactions everywhere and opting out of them for specific actions and pages, you can opt in to database transactions for specific actions and pages.

For actions, you can use the `databaseTransaction()` method:

```php
CreateAction::make()
    ->databaseTransaction()
```

For pages like [Create resource](resources/creating-records) and [Edit resource](resources/editing-records), you can define the `$hasDatabaseTransactions` property to `true` on the page class:

```php
use Filament\Resources\Pages\CreateRecord;

class CreatePost extends CreateRecord
{
    protected ?bool $hasDatabaseTransactions = true;

    // ...
}
```

## Registering assets for a panel

You can register [assets](../support/assets) that will only be loaded on pages within a specific panel, and not in the rest of the app. To do that, pass an array of assets to the `assets()` method:

```php
use Filament\Panel;
use Filament\Support\Assets\Css;
use Filament\Support\Assets\Js;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->assets([
            Css::make('custom-stylesheet', resource_path('css/custom.css')),
            Js::make('custom-script', resource_path('js/custom.js')),
        ]);
}
```

Before these [assets](../support/assets) can be used, you'll need to run `php artisan filament:assets`.

## Applying middleware

You can apply extra middleware to all routes by passing an array of middleware classes to the `middleware()` method in the configuration:

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->middleware([
            // ...
        ]);
}
```

By default, middleware will be run when the page is first loaded, but not on subsequent Livewire AJAX requests. If you want to run middleware on every request, you can make it persistent by passing `true` as the second argument to the `middleware()` method:

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->middleware([
            // ...
        ], isPersistent: true);
}
```

### Applying middleware to authenticated routes

You can apply middleware to all authenticated routes by passing an array of middleware classes to the `authMiddleware()` method in the configuration:

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->authMiddleware([
            // ...
        ]);
}
```

By default, middleware will be run when the page is first loaded, but not on subsequent Livewire AJAX requests. If you want to run middleware on every request, you can make it persistent by passing `true` as the second argument to the `authMiddleware()` method:

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->authMiddleware([
            // ...
        ], isPersistent: true);
}
```

## Disabling broadcasting

By default, Laravel Echo will automatically connect for every panel, if credentials have been set up in the [published `config/filament.php` configuration file](installation#publishing-configuration). To disable this automatic connection in a panel, you can use the `broadcasting(false)` method:

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->broadcasting(false);
}
```

# Documentation for panels. File: 10-clusters.md
---
title: Clusters
---

## Overview

Clusters are a hierarchical structure in panels that allow you to group [resources](resources) and [custom pages](pages) together. They are useful for organizing your panel into logical sections, and can help reduce the size of your panel's sidebar.

When using a cluster, a few things happen:

- A new navigation item is added to the navigation, which is a link to the first resource or page in the cluster.
- The individual navigation items for the resources or pages are no longer visible in the main navigation.
- A new sub-navigation UI is added to each resource or page in the cluster, which contains the navigation items for the resources or pages in the cluster.
- Resources and pages in the cluster get a new URL, prefixed with the name of the cluster. If you are generating URLs to [resources](resources/getting-started#generating-urls-to-resource-pages) and [pages](pages#generating-urls-to-pages) correctly, then this change should be handled for you automatically.
- The cluster's name is in the breadcrumbs of all resources and pages in the cluster. When clicking it, you are taken to the first resource or page in the cluster.

## Creating a cluster

Before creating your first cluster, you must tell the panel where cluster classes should be located. Alongside methods like `discoverResources()` and `discoverPages()` in the [configuration](configuration), you can use `discoverClusters()`:

```php
public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->discoverResources(in: app_path('Filament/Resources'), for: 'App\\Filament\\Resources')
        ->discoverPages(in: app_path('Filament/Pages'), for: 'App\\Filament\\Pages')
        ->discoverClusters(in: app_path('Filament/Clusters'), for: 'App\\Filament\\Clusters');
}
```

Now, you can create a cluster with the `php artisan make:filament-cluster` command:

```bash
php artisan make:filament-cluster Settings
```

This will create a new cluster class in the `app/Filament/Clusters` directory:

```php
<?php

namespace App\Filament\Clusters;

use Filament\Clusters\Cluster;

class Settings extends Cluster
{
    protected static ?string $navigationIcon = 'heroicon-o-squares-2x2';
}
```

The [`$navigationIcon`](navigation#customizing-a-navigation-items-icon) property is defined by default since you will most likely want to customize this immediately. All other [navigation properties and methods](navigation) are also available to use, including [`$navigationLabel`](navigation#customizing-a-navigation-items-label), [`$navigationSort`](navigation#sorting-navigation-items) and [`$navigationGroup`](navigation#grouping-navigation-items). These are used to customize the cluster's main navigation item, in the same way you would customize the item for a resource or page.

## Adding resources and pages to a cluster

To add resources and pages to a cluster, you just need to define the `$cluster` property on the resource or page class, and set it to the cluster class [you created](#creating-a-cluster):

```php
use App\Filament\Clusters\Settings;

protected static ?string $cluster = Settings::class;
```

## Code structure recommendations for panels using clusters

When using clusters, it is recommended that you move all of your resources and pages into a directory with the same name as the cluster. For example, here is a directory structure for a panel that uses a cluster called `Settings`, containing a `ColorResource` and two custom pages:

```
.
+-- Clusters
|   +-- Settings.php
|   +-- Settings
|   |   +-- Pages
|   |   |   +-- ManageBranding.php
|   |   |   +-- ManageNotifications.php
|   |   +-- Resources
|   |   |   +-- ColorResource.php
|   |   |   +-- ColorResource
|   |   |   |   +-- Pages
|   |   |   |   |   +-- CreateColor.php
|   |   |   |   |   +-- EditColor.php
|   |   |   |   |   +-- ListColors.php
```

This is a recommendation, not a requirement. You can structure your panel however you like, as long as the resources and pages in your cluster use the [`$cluster`](#adding-resources-and-pages-to-a-cluster) property. This is just a suggestion to help you keep your panel organized.

When a cluster exists in your panel, and you generate new resources or pages with the `make:filament-resource` or `make:filament-page` commands, you will be asked if you want to create them inside a cluster directory, according to these guidelines. If you choose to, then Filament will also assign the correct `$cluster` property to the resource or page class for you. If you do not, you will need to [define the `$cluster` property](#adding-resources-and-pages-to-a-cluster) yourself.

## Customizing the cluster breadcrumb

The cluster's name is in the breadcrumbs of all resources and pages in the cluster.

You may customize the breadcrumb name using the `$clusterBreadcrumb` property in the cluster class:

```php
protected static ?string $clusterBreadcrumb = 'cluster';
```

Alternatively, you may use the `getClusterBreadcrumb()` to define a dynamic breadcrumb name:

```php
public static function getClusterBreadcrumb(): string
{
    return __('filament/clusters/cluster.name');
}
```

# Documentation for panels. File: 11-tenancy.md
---
title: Multi-tenancy
---

## Overview

Multi-tenancy is a concept where a single instance of an application serves multiple customers. Each customer has their own data and access rules that prevent them from viewing or modifying each other's data. This is a common pattern in SaaS applications. Users often belong to groups of users (often called teams or organizations). Records are owned by the group, and users can be members of multiple groups. This is suitable for applications where users need to collaborate on data.

Multi-tenancy is a very sensitive topic. It's important to understand the security implications of multi-tenancy and how to properly implement it. If implemented partially or incorrectly, data belonging to one tenant may be exposed to another tenant. Filament provides a set of tools to help you implement multi-tenancy in your application, but it is up to you to understand how to use them. Filament does not provide any guarantees about the security of your application. It is your responsibility to ensure that your application is secure. Please see the [security](#tenancy-security) section for more information.

## Simple one-to-many tenancy

The term "multi-tenancy" is broad and may mean different things in different contexts. Filament's tenancy system implies that the user belongs to **many** tenants (*organizations, teams, companies, etc.*) and may switch between them.

If your case is simpler and you don't need a many-to-many relationship, then you don't need to set up the tenancy in Filament. You could use [observers](https://laravel.com/docs/eloquent#observers) and [global scopes](https://laravel.com/docs/eloquent#global-scopes) instead.

Let's say you have a database column `users.team_id`, you can scope all records to have the same `team_id` as the user using a [global scope](https://laravel.com/docs/eloquent#global-scopes):

```php
use Illuminate\Database\Eloquent\Builder;

class Post extends Model
{
    protected static function booted(): void
    {
        static::addGlobalScope('team', function (Builder $query) {
            if (auth()->hasUser()) {
                $query->where('team_id', auth()->user()->team_id);
                // or with a `team` relationship defined:
                $query->whereBelongsTo(auth()->user()->team);
            }
        });
    }
}
```

To automatically set the `team_id` on the record when it's created, you can create an [observer](https://laravel.com/docs/eloquent#observers):

```php
class PostObserver
{
    public function creating(Post $post): void
    {
        if (auth()->hasUser()) {
            $post->team_id = auth()->user()->team_id;
            // or with a `team` relationship defined:
            $post->team()->associate(auth()->user()->team);
        }
    }
}
```

## Setting up tenancy

To set up tenancy, you'll need to specify the "tenant" (like team or organization) model in the [configuration](configuration):

```php
use App\Models\Team;
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->tenant(Team::class);
}
```

You'll also need to tell Filament which tenants a user belongs to. You can do this by implementing the `HasTenants` interface on the `App\Models\User` model:

```php
<?php

namespace App\Models;

use Filament\Models\Contracts\FilamentUser;
use Filament\Models\Contracts\HasTenants;
use Filament\Panel;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Support\Collection;

class User extends Authenticatable implements FilamentUser, HasTenants
{
    // ...

    public function teams(): BelongsToMany
    {
        return $this->belongsToMany(Team::class);
    }

    public function getTenants(Panel $panel): Collection
    {
        return $this->teams;
    }

    public function canAccessTenant(Model $tenant): bool
    {
        return $this->teams()->whereKey($tenant)->exists();
    }
}
```

In this example, users belong to many teams, so there is a `teams()` relationship. The `getTenants()` method returns the teams that the user belongs to. Filament uses this to list the tenants that the user has access to.

For security, you also need to implement the `canAccessTenant()` method of the `HasTenants` interface to prevent users from accessing the data of other tenants by guessing their tenant ID and putting it into the URL.

You'll also want users to be able to [register new teams](#adding-a-tenant-registration-page).

## Adding a tenant registration page

A registration page will allow users to create a new tenant.

When visiting your app after logging in, users will be redirected to this page if they don't already have a tenant.

To set up a registration page, you'll need to create a new page class that extends `Filament\Pages\Tenancy\RegisterTenant`. This is a full-page Livewire component. You can put this anywhere you want, such as `app/Filament/Pages/Tenancy/RegisterTeam.php`:

```php
namespace App\Filament\Pages\Tenancy;

use App\Models\Team;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Form;
use Filament\Pages\Tenancy\RegisterTenant;

class RegisterTeam extends RegisterTenant
{
    public static function getLabel(): string
    {
        return 'Register team';
    }

    public function form(Form $form): Form
    {
        return $form
            ->schema([
                TextInput::make('name'),
                // ...
            ]);
    }

    protected function handleRegistration(array $data): Team
    {
        $team = Team::create($data);

        $team->members()->attach(auth()->user());

        return $team;
    }
}
```

You may add any [form components](../forms/getting-started) to the `form()` method, and create the team inside the `handleRegistration()` method.

Now, we need to tell Filament to use this page. We can do this in the [configuration](configuration):

```php
use App\Filament\Pages\Tenancy\RegisterTeam;
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->tenantRegistration(RegisterTeam::class);
}
```

### Customizing the tenant registration page

You can override any method you want on the base registration page class to make it act as you want. Even the `$view` property can be overridden to use a custom view of your choice.

## Adding a tenant profile page

A profile page will allow users to edit information about the tenant.

To set up a profile page, you'll need to create a new page class that extends `Filament\Pages\Tenancy\EditTenantProfile`. This is a full-page Livewire component. You can put this anywhere you want, such as `app/Filament/Pages/Tenancy/EditTeamProfile.php`:

```php
namespace App\Filament\Pages\Tenancy;

use Filament\Forms\Components\TextInput;
use Filament\Forms\Form;
use Filament\Pages\Tenancy\EditTenantProfile;

class EditTeamProfile extends EditTenantProfile
{
    public static function getLabel(): string
    {
        return 'Team profile';
    }

    public function form(Form $form): Form
    {
        return $form
            ->schema([
                TextInput::make('name'),
                // ...
            ]);
    }
}
```

You may add any [form components](../forms/getting-started) to the `form()` method. They will get saved directly to the tenant model.

Now, we need to tell Filament to use this page. We can do this in the [configuration](configuration):

```php
use App\Filament\Pages\Tenancy\EditTeamProfile;
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->tenantProfile(EditTeamProfile::class);
}
```

### Customizing the tenant profile page

You can override any method you want on the base profile page class to make it act as you want. Even the `$view` property can be overridden to use a custom view of your choice.

## Accessing the current tenant

Anywhere in the app, you can access the tenant model for the current request using `Filament::getTenant()`:

```php
use Filament\Facades\Filament;

$tenant = Filament::getTenant();
```

## Billing

### Using Laravel Spark

Filament provides a billing integration with [Laravel Spark](https://spark.laravel.com). Your users can start subscriptions and manage their billing information.

To install the integration, first [install Spark](https://spark.laravel.com/docs/installation.html) and configure it for your tenant model.

Now, you can install the Filament billing provider for Spark using Composer:

```bash
composer require filament/spark-billing-provider
```

In the [configuration](configuration), set Spark as the `tenantBillingProvider()`:

```php
use Filament\Billing\Providers\SparkBillingProvider;
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->tenantBillingProvider(new SparkBillingProvider());
}
```

Now, you're all good to go! Users can manage their billing by clicking a link in the tenant menu.

### Requiring a subscription

To require a subscription to use any part of the app, you can use the `requiresTenantSubscription()` configuration method:

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->requiresTenantSubscription();
}
```

Now, users will be redirected to the billing page if they don't have an active subscription.

#### Requiring a subscription for specific resources and pages

Sometimes, you may wish to only require a subscription for certain [resources](resources/getting-started) and [custom pages](pages) in your app. You can do this by returning `true` from the `isTenantSubscriptionRequired()` method on the resource or page class:

```php
public static function isTenantSubscriptionRequired(Panel $panel): bool
{
    return true;
}
```

If you're using the `requiresTenantSubscription()` configuration method, then you can return `false` from this method to allow access to the resource or page as an exception.

### Writing a custom billing integration

Billing integrations are quite simple to write. You just need a class that implements the `Filament\Billing\Providers\Contracts\Provider` interface. This interface has two methods.

`getRouteAction()` is used to get the route action that should be run when the user visits the billing page. This could be a callback function, or the name of a controller, or a Livewire component - anything that works when using `Route::get()` in Laravel normally. For example, you could put in a simple redirect to your own billing page using a callback function.

`getSubscribedMiddleware()` returns the name of a middleware that should be used to check if the tenant has an active subscription. This middleware should redirect the user to the billing page if they don't have an active subscription.

Here's an example billing provider that uses a callback function for the route action and a middleware for the subscribed middleware:

```php
use App\Http\Middleware\RedirectIfUserNotSubscribed;
use Filament\Billing\Providers\Contracts\Provider;
use Illuminate\Http\RedirectResponse;

class ExampleBillingProvider implements Provider
{
    public function getRouteAction(): string
    {
        return function (): RedirectResponse {
            return redirect('https://billing.example.com');
        };
    }

    public function getSubscribedMiddleware(): string
    {
        return RedirectIfUserNotSubscribed::class;
    }
}
```

### Customizing the billing route slug

You can customize the URL slug used for the billing route using the `tenantBillingRouteSlug()` method in the [configuration](configuration):

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->tenantBillingRouteSlug('billing');
}
```

## Customizing the tenant menu

The tenant-switching menu is featured in the admin layout. It's fully customizable.

To register new items to the tenant menu, you can use the [configuration](configuration):

```php
use App\Filament\Pages\Settings;
use Filament\Navigation\MenuItem;
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->tenantMenuItems([
            MenuItem::make()
                ->label('Settings')
                ->url(fn (): string => Settings::getUrl())
                ->icon('heroicon-m-cog-8-tooth'),
            // ...
        ]);
}
```

### Customizing the registration link

To customize the registration link on the tenant menu, register a new item with the `register` array key:

```php
use Filament\Navigation\MenuItem;
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->tenantMenuItems([
            'register' => MenuItem::make()->label('Register new team'),
            // ...
        ]);
}
```

### Customizing the profile link

To customize the profile link on the tenant menu, register a new item with the `profile` array key:

```php
use Filament\Navigation\MenuItem;
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->tenantMenuItems([
            'profile' => MenuItem::make()->label('Edit team profile'),
            // ...
        ]);
}
```

### Customizing the billing link

To customize the billing link on the tenant menu, register a new item with the `billing` array key:

```php
use Filament\Navigation\MenuItem;
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->tenantMenuItems([
            'billing' => MenuItem::make()->label('Manage subscription'),
            // ...
        ]);
}
```

### Conditionally hiding tenant menu items

You can also conditionally hide a tenant menu item by using the `visible()` or `hidden()` methods, passing in a condition to check. Passing a function will defer condition evaluation until the menu is actually being rendered:

```php
use Filament\Navigation\MenuItem;

MenuItem::make()
    ->label('Settings')
    ->visible(fn (): bool => auth()->user()->can('manage-team'))
    // or
    ->hidden(fn (): bool => ! auth()->user()->can('manage-team'))
```

### Sending a `POST` HTTP request from a tenant menu item

You can send a `POST` HTTP request from a tenant menu item by passing a URL to the `postAction()` method:

```php
use Filament\Navigation\MenuItem;

MenuItem::make()
    ->label('Lock session')
    ->postAction(fn (): string => route('lock-session'))
```

### Hiding the tenant menu

You can hide the tenant menu by using the `tenantMenu(false)`

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->tenantMenu(false);
}
```

However, this is a sign that Filament's tenancy feature is not suitable for your project. If each user only belongs to one tenant, you should stick to [simple one-to-many tenancy](#simple-one-to-many-tenancy).

## Setting up avatars

Out of the box, Filament uses [ui-avatars.com](https://ui-avatars.com) to generate avatars based on a user's name. However, if you user model has an `avatar_url` attribute, that will be used instead. To customize how Filament gets a user's avatar URL, you can implement the `HasAvatar` contract:

```php
<?php

namespace App\Models;

use Filament\Models\Contracts\FilamentUser;
use Filament\Models\Contracts\HasAvatar;
use Illuminate\Database\Eloquent\Model;

class Team extends Model implements HasAvatar
{
    // ...

    public function getFilamentAvatarUrl(): ?string
    {
        return $this->avatar_url;
    }
}
```

The `getFilamentAvatarUrl()` method is used to retrieve the avatar of the current user. If `null` is returned from this method, Filament will fall back to [ui-avatars.com](https://ui-avatars.com).

You can easily swap out [ui-avatars.com](https://ui-avatars.com) for a different service, by creating a new avatar provider. [You can learn how to do this here.](users#using-a-different-avatar-provider)

## Configuring the tenant relationships

When creating and listing records associated with a Tenant, Filament needs access to two Eloquent relationships for each resource - an "ownership" relationship that is defined on the resource model class, and a relationship on the tenant model class. By default, Filament will attempt to guess the names of these relationships based on standard Laravel conventions. For example, if the tenant model is `App\Models\Team`, it will look for a `team()` relationship on the resource model class. And if the resource model class is `App\Models\Post`, it will look for a `posts()` relationship on the tenant model class.

### Customizing the ownership relationship name

You can customize the name of the ownership relationship used across all resources at once, using the `ownershipRelationship` argument on the `tenant()` configuration method. In this example, resource model classes have an `owner` relationship defined:

```php
use App\Models\Team;
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->tenant(Team::class, ownershipRelationship: 'owner');
}
```

Alternatively, you can set the `$tenantOwnershipRelationshipName` static property on the resource class, which can then be used to customize the ownership relationship name that is just used for that resource. In this example, the `Post` model class has an `owner` relationship defined:

```php
use Filament\Resources\Resource;

class PostResource extends Resource
{
    protected static ?string $tenantOwnershipRelationshipName = 'owner';

    // ...
}
```

### Customizing the resource relationship name

You can set the `$tenantRelationshipName` static property on the resource class, which can then be used to customize the relationship name that is used to fetch that resource. In this example, the tenant model class has an `blogPosts` relationship defined:

```php
use Filament\Resources\Resource;

class PostResource extends Resource
{
    protected static ?string $tenantRelationshipName = 'blogPosts';

    // ...
}
```

## Configuring the slug attribute

When using a tenant like a team, you might want to add a slug field to the URL rather than the team's ID. You can do that with the `slugAttribute` argument on the `tenant()` configuration method:

```php
use App\Models\Team;
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->tenant(Team::class, slugAttribute: 'slug');
}
```

## Configuring the name attribute

By default, Filament will use the `name` attribute of the tenant to display its name in the app. To change this, you can implement the `HasName` contract:

```php
<?php

namespace App\Models;

use Filament\Models\Contracts\HasName;
use Illuminate\Database\Eloquent\Model;

class Team extends Model implements HasName
{
    // ...

    public function getFilamentName(): string
    {
        return "{$this->name} {$this->subscription_plan}";
    }
}
```

The `getFilamentName()` method is used to retrieve the name of the current user.

## Setting the current tenant label

Inside the tenant switcher, you may wish to add a small label like "Active team" above the name of the current team. You can do this by implementing the `HasCurrentTenantLabel` method on the tenant model:

```php
<?php

namespace App\Models;

use Filament\Models\Contracts\HasCurrentTenantLabel;
use Illuminate\Database\Eloquent\Model;

class Team extends Model implements HasCurrentTenantLabel
{
    // ...

    public function getCurrentTenantLabel(): string
    {
        return 'Active team';
    }
}
```

## Setting the default tenant

When signing in, Filament will redirect the user to the first tenant returned from the `getTenants()` method.

Sometimes, you might wish to change this. For example, you might store which team was last active, and redirect the user to that team instead.

To customize this, you can implement the `HasDefaultTenant` contract on the user:

```php
<?php

namespace App\Models;

use Filament\Models\Contracts\FilamentUser;
use Filament\Models\Contracts\HasDefaultTenant;
use Filament\Models\Contracts\HasTenants;
use Filament\Panel;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class User extends Model implements FilamentUser, HasDefaultTenant, HasTenants
{
    // ...

    public function getDefaultTenant(Panel $panel): ?Model
    {
        return $this->latestTeam;
    }

    public function latestTeam(): BelongsTo
    {
        return $this->belongsTo(Team::class, 'latest_team_id');
    }
}
```

## Applying middleware to tenant-aware routes

You can apply extra middleware to all tenant-aware routes by passing an array of middleware classes to the `tenantMiddleware()` method in the [panel configuration file](configuration):

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->tenantMiddleware([
            // ...
        ]);
}
```

By default, middleware will be run when the page is first loaded, but not on subsequent Livewire AJAX requests. If you want to run middleware on every request, you can make it persistent by passing `true` as the second argument to the `tenantMiddleware()` method:

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->tenantMiddleware([
            // ...
        ], isPersistent: true);
}
```

## Adding a tenant route prefix

By default the URL structure will put the tenant ID or slug immediately after the panel path. If you wish to prefix it with another URL segment, use the `tenantRoutePrefix()` method:

```php
use App\Models\Team;
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->path('admin')
        ->tenant(Team::class)
        ->tenantRoutePrefix('team');
}
```

Before, the URL structure was `/admin/1` for tenant 1. Now, it is `/admin/team/1`.

## Using a domain to identify the tenant

When using a tenant, you might want to use domain or subdomain routing like `team1.example.com/posts` instead of a route prefix like `/team1/posts` . You can do that with the `tenantDomain()` method, alongside the `tenant()` configuration method. The `tenant` argument corresponds to the slug attribute of the tenant model:

```php
use App\Models\Team;
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->tenant(Team::class, slugAttribute: 'slug')
        ->tenantDomain('{tenant:slug}.example.com');
}
```

In the above examples, the tenants live on subdomains of the main app domain. You may also set the system up to resolve the entire domain from the tenant as well:

```php
use App\Models\Team;
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->tenant(Team::class, slugAttribute: 'domain')
        ->tenantDomain('{tenant:domain}');
}
```

In this example, the `domain` attribute should contain a valid domain host, like `example.com` or `subdomain.example.com`.

> Note: When using a parameter for the entire domain (`tenantDomain('{tenant:domain}')`), Filament will register a [global route parameter pattern](https://laravel.com/docs/routing#parameters-global-constraints) for all `tenant` parameters in the application to be `[a-z0-9.\-]+`. This is because Laravel does not allow the `.` character in route parameters by default. This might conflict with other panels using tenancy, or other parts of your application that use a `tenant` route parameter.

## Disabling tenancy for a resource

By default, all resources within a panel with tenancy will be scoped to the current tenant. If you have resources that are shared between tenants, you can disable tenancy for them by setting the `$isScopedToTenant` static property to `false` on the resource class:

```php
protected static bool $isScopedToTenant = false;
```

### Disabling tenancy for all resources

If you wish to opt-in to tenancy for each resource instead of opting-out, you can call `Resource::scopeToTenant(false)` inside a service provider's `boot()` method or a middleware:

```php
use Filament\Resources\Resource;

Resource::scopeToTenant(false);
```

Now, you can opt-in to tenancy for each resource by setting the `$isScopedToTenant` static property to `true` on a resource class:

```php
protected static bool $isScopedToTenant = true;
```

## Tenancy security

It's important to understand the security implications of multi-tenancy and how to properly implement it. If implemented partially or incorrectly, data belonging to one tenant may be exposed to another tenant. Filament provides a set of tools to help you implement multi-tenancy in your application, but it is up to you to understand how to use them. Filament does not provide any guarantees about the security of your application. It is your responsibility to ensure that your application is secure.

Below is a list of features that Filament provides to help you implement multi-tenancy in your application:

- Automatic scoping of resources to the current tenant. The base Eloquent query that is used to fetch records for a resource is automatically scoped to the current tenant. This query is used to render the resource's list table, and is also used to resolve records from the current URL when editing or viewing a record. This means that if a user attempts to view a record that does not belong to the current tenant, they will receive a 404 error.

- Automatic association of new resource records to the current tenant.

And here are the things that Filament does not currently provide:

- Scoping of relation manager records to the current tenant. When using the relation manager, in the vast majority of cases, the query will not need to be scoped to the current tenant, since it is already scoped to the parent record, which is itself scoped to the current tenant. For example, if a `Team` tenant model had an `Author` resource, and that resource had a `posts` relationship and relation manager set up, and posts only belong to one author, there is no need to scope the query. This is because the user will only be able to see authors that belong to the current team anyway, and thus will only be able to see posts that belong to those authors. You can [scope the Eloquent query](resources/relation-managers#customizing-the-relation-manager-eloquent-query) if you wish.

- Form component and filter scoping. When using the `Select`, `CheckboxList` or `Repeater` form components, the `SelectFilter`, or any other similar Filament component which is able to automatically fetch "options" or other data from the database (usually using a `relationship()` method), this data is not scoped. The main reason for this is that these features often don't belong to the Filament Panel Builder package, and have no knowledge that they are being used within that context, and that a tenant even exists. And even if they did have access to the tenant, there is nowhere for the tenant relationship configuration to live. To scope these components, you need to pass in a query function that scopes the query to the current tenant. For example, if you were using the `Select` form component to select an `author` from a relationship, you could do this:

```php
use Filament\Facades\Filament;
use Filament\Forms\Components\Select;
use Illuminate\Database\Eloquent\Builder;

Select::make('author_id')
    ->relationship(
        name: 'author',
        titleAttribute: 'name',
        modifyQueryUsing: fn (Builder $query) => $query->whereBelongsTo(Filament::getTenant()),
    );
```

### Using tenant-aware middleware to apply global scopes

It might be useful to apply global scopes to your Eloquent models while they are being used in your panel. This would allow you to forget about scoping your queries to the current tenant, and instead have the scoping applied automatically. To do this, you can create a new middleware class like `ApplyTenantScopes`:

```bash
php artisan make:middleware ApplyTenantScopes
```

Inside the `handle()` method, you can apply any global scopes that you wish:

```php
use App\Models\Author;
use Closure;
use Filament\Facades\Filament;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Request;

class ApplyTenantScopes
{
    public function handle(Request $request, Closure $next)
    {
        Author::addGlobalScope(
            fn (Builder $query) => $query->whereBelongsTo(Filament::getTenant()),
        );

        return $next($request);
    }
}
```

You can now [register this middleware](#applying-middleware-to-tenant-aware-routes) for all tenant-aware routes, and ensure that it is used across all Livewire AJAX requests by making it persistent:

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->tenantMiddleware([
            ApplyTenantScopes::class,
        ], isPersistent: true);
}
```

# Documentation for panels. File: 12-themes.md
---
title: Themes
---

## Changing the colors

In the [configuration](configuration), you can easily change the colors that are used. Filament ships with 6 predefined colors that are used everywhere within the framework. They are customizable as follows:

```php
use Filament\Panel;
use Filament\Support\Colors\Color;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->colors([
            'danger' => Color::Rose,
            'gray' => Color::Gray,
            'info' => Color::Blue,
            'primary' => Color::Indigo,
            'success' => Color::Emerald,
            'warning' => Color::Orange,
        ]);
}
```

The `Filament\Support\Colors\Color` class contains color options for all [Tailwind CSS color palettes](https://tailwindcss.com/docs/customizing-colors).

You can also pass in a function to `register()` which will only get called when the app is getting rendered. This is useful if you are calling `register()` from a service provider, and want to access objects like the currently authenticated user, which are initialized later in middleware.

Alternatively, you may pass your own palette in as an array of RGB values:

```php
$panel
    ->colors([
        'primary' => [
            50 => '238, 242, 255',
            100 => '224, 231, 255',
            200 => '199, 210, 254',
            300 => '165, 180, 252',
            400 => '129, 140, 248',
            500 => '99, 102, 241',
            600 => '79, 70, 229',
            700 => '67, 56, 202',
            800 => '55, 48, 163',
            900 => '49, 46, 129',
            950 => '30, 27, 75',
        ],
    ])
```

### Generating a color palette

If you want us to attempt to generate a palette for you based on a singular hex or RGB value, you can pass that in:

```php
$panel
    ->colors([
        'primary' => '#6366f1',
    ])

$panel
    ->colors([
        'primary' => 'rgb(99, 102, 241)',
    ])
```

## Changing the font

By default, we use the [Inter](https://fonts.google.com/specimen/Inter) font. You can change this using the `font()` method in the [configuration](configuration) file:

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->font('Poppins');
}
```

All [Google Fonts](https://fonts.google.com) are available to use.

### Changing the font provider

[Bunny Fonts CDN](https://fonts.bunny.net) is used to serve the fonts. It is GDPR-compliant. If you'd like to use [Google Fonts CDN](https://fonts.google.com) instead, you can do so using the `provider` argument of the `font()` method:

```php
use Filament\FontProviders\GoogleFontProvider;

$panel->font('Inter', provider: GoogleFontProvider::class)
```

Or if you'd like to serve the fonts from a local stylesheet, you can use the `LocalFontProvider`:

```php
use Filament\FontProviders\LocalFontProvider;

$panel->font(
    'Inter',
    url: asset('css/fonts.css'),
    provider: LocalFontProvider::class,
)
```

## Creating a custom theme

Filament allows you to change the CSS used to render the UI by compiling a custom stylesheet to replace the default one. This custom stylesheet is called a "theme".

Themes use [Tailwind CSS](https://tailwindcss.com), the Tailwind Forms plugin, the Tailwind Typography plugin, the [PostCSS Nesting plugin](https://www.npmjs.com/package/postcss-nesting), and [Autoprefixer](https://github.com/postcss/autoprefixer).

> Filament v3 uses Tailwind CSS v3 for styling. As such, when creating a theme, you need to use Tailwind CSS v3. The `php artisan make:filament-theme` command will install Tailwind CSS v3 if you do not have it installed already. If you have Tailwind CSS v4 installed, it will not fully install the necessary Vite configuration to compile the theme. We suggest that you either use the Tailwind CLI to compile the theme, or downgrade your project to Tailwind CSS v3. The command to compile the theme with the Tailwind CLI will be output when you run the `make:filament-theme` command. You could save this command into a script in `package.json` for easy use.
> 
> Filament v4 will support Tailwind CSS v4.

To create a custom theme for a panel, you can use the `php artisan make:filament-theme` command:

```bash
php artisan make:filament-theme
```

If you have multiple panels, you can specify the panel you want to create a theme for:

```bash
php artisan make:filament-theme admin
```

By default, this command will use NPM to install dependencies. If you want to use a different package manager, you can use the `--pm` option:

```bash
php artisan make:filament-theme --pm=bun
````

The command will create a CSS file and Tailwind Configuration file in the `/resources/css/filament` directory. You can then customize the theme by editing these files. It will also give you instructions on how to compile the theme and register it in Filament. **Please follow the instructions in the command to complete the setup process:**

```
⇂ First, add a new item to the `input` array of `vite.config.js`: `resources/css/filament/admin/theme.css`
⇂ Next, register the theme in the admin panel provider using `->viteTheme('resources/css/filament/admin/theme.css')`
⇂ Finally, run `npm run build` to compile the theme
```

Please reference the command to see the exact file names that you need to register, they may not be `admin/theme.css`.

If you have Tailwind v4 installed, the output may look like this:

```
⇂ It looks like you have Tailwind v4 installed. Filament uses Tailwind v3. You should downgrade your project and re-run this command with `--force`, or use the following command to compile the theme with the Tailwind v3 CLI:
⇂ npx tailwindcss@3 --input ./resources/css/filament/admin/theme.css --output ./public/css/filament/admin/theme.css --config ./resources/css/filament/admin/tailwind.config.js --minify
⇂ Make sure to register the theme in the admin panel provider using `->theme(asset('css/filament/admin/theme.css'))`
```

## Disabling dark mode

To disable dark mode switching, you can use the [configuration](configuration) file:

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->darkMode(false);
}
```

## Changing the default theme mode

By default, Filament uses the user's system theme as the default mode. For example, if the user's computer is in dark mode, Filament will use dark mode by default. The system mode in Filament is reactive if the user changes their computer's mode. If you want to change the default mode to force light or dark mode, you can use the `defaultThemeMode()` method, passing `ThemeMode::Light` or `ThemeMode::Dark`:

```php
use Filament\Enums\ThemeMode;
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->defaultThemeMode(ThemeMode::Light);
}
```

## Adding a logo

By default, Filament uses your app's name to render a simple text-based logo. However, you can easily customize this.

If you want to simply change the text that is used in the logo, you can use the `brandName()` method:

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->brandName('Filament Demo');
}
```

To render an image instead, you can pass a URL to the `brandLogo()` method:

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->brandLogo(asset('images/logo.svg'));
}
```

Alternatively, you may directly pass HTML to the `brandLogo()` method to render an inline SVG element for example:

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->brandLogo(fn () => view('filament.admin.logo'));
}
```

```blade
<svg
    viewBox="0 0 128 26"
    xmlns="http://www.w3.org/2000/svg"
    class="h-full fill-gray-500 dark:fill-gray-400"
>
    <!-- ... -->
</svg>
```

If you need a different logo to be used when the application is in dark mode, you can pass it to `darkModeBrandLogo()` in the same way.

The logo height defaults to a sensible value, but it's impossible to account for all possible aspect ratios. Therefore, you may customize the height of the rendered logo using the `brandLogoHeight()` method:

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->brandLogo(fn () => view('filament.admin.logo'))
        ->brandLogoHeight('2rem');
}
```


## Adding a favicon

To add a favicon, you can use the [configuration](configuration) file, passing the public URL of the favicon:

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->favicon(asset('images/favicon.png'));
}
```

# Documentation for panels. File: 13-plugins.md
---
title: Plugin development
---
import LaracastsBanner from "@components/LaracastsBanner.astro"

<LaracastsBanner
    title="Panel Builder Plugins"
    description="Watch the Build Advanced Components for Filament series on Laracasts - it will teach you how to get started with your plugin. The text-based guide on this page can also give a good overview."
    url="https://laracasts.com/series/build-advanced-components-for-filament/episodes/16"
    series="building-advanced-components"
/>

## Overview

The basis of Filament plugins are Laravel packages. They are installed into your Filament project via Composer, and follow all the standard techniques, like using service providers to register routes, views, and translations. If you're new to Laravel package development, here are some resources that can help you grasp the core concepts:

- [The Package Development section of the Laravel docs](https://laravel.com/docs/packages) serves as a great reference guide.
- [Spatie's Package Training course](https://spatie.be/products/laravel-package-training) is a good instructional video series to teach you the process step by step.
- [Spatie's Package Tools](https://github.com/spatie/laravel-package-tools) allows you to simplify your service provider classes using a fluent configuration object.

Filament plugins build on top of the concepts of Laravel packages and allow you to ship and consume reusable features for any Filament panel. They can be added to each panel one at a time, and are also configurable differently per-panel.

## Configuring the panel with a plugin class

A plugin class is used to allow your package to interact with a panel [configuration](configuration) file. It's a simple PHP class that implements the `Plugin` interface. 3 methods are required:

- The `getId()` method returns the unique identifier of the plugin amongst other plugins. Please ensure that it is specific enough to not clash with other plugins that might be used in the same project.
- The `register()` method allows you to use any [configuration](configuration) option that is available to the panel. This includes registering [resources](resources/getting-started), [custom pages](pages), [themes](themes), [render hooks](configuration#render-hooks) and more.
- The `boot()` method is run only when the panel that the plugin is being registered to is actually in-use. It is executed by a middleware class.

```php
<?php

namespace DanHarrin\FilamentBlog;

use DanHarrin\FilamentBlog\Pages\Settings;
use DanHarrin\FilamentBlog\Resources\CategoryResource;
use DanHarrin\FilamentBlog\Resources\PostResource;
use Filament\Contracts\Plugin;
use Filament\Panel;

class BlogPlugin implements Plugin
{
    public function getId(): string
    {
        return 'blog';
    }

    public function register(Panel $panel): void
    {
        $panel
            ->resources([
                PostResource::class,
                CategoryResource::class,
            ])
            ->pages([
                Settings::class,
            ]);
    }

    public function boot(Panel $panel): void
    {
        //
    }
}
```

The users of your plugin can add it to a panel by instantiating the plugin class and passing it to the `plugin()` method of the [configuration](configuration):

```php
use DanHarrin\FilamentBlog\BlogPlugin;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->plugin(new BlogPlugin());
}
```

### Fluently instantiating the plugin class

You may want to add a `make()` method to your plugin class to provide a fluent interface for your users to instantiate it. In addition, by using the container (`app()`) to instantiate the plugin object, it can be replaced with a different implementation at runtime:

```php
use Filament\Contracts\Plugin;

class BlogPlugin implements Plugin
{
    public static function make(): static
    {
        return app(static::class);
    }
    
    // ...
}
```

Now, your users can use the `make()` method:

```php
use DanHarrin\FilamentBlog\BlogPlugin;
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->plugin(BlogPlugin::make());
}
```

### Configuring plugins per-panel

You may add other methods to your plugin class, which allow your users to configure it. We suggest that you add both a setter and a getter method for each option you provide. You should use a property to store the preference in the setter and retrieve it again in the getter:

```php
use DanHarrin\FilamentBlog\Resources\AuthorResource;
use Filament\Contracts\Plugin;
use Filament\Panel;

class BlogPlugin implements Plugin
{
    protected bool $hasAuthorResource = false;
    
    public function authorResource(bool $condition = true): static
    {
        // This is the setter method, where the user's preference is
        // stored in a property on the plugin object.
        $this->hasAuthorResource = $condition;
    
        // The plugin object is returned from the setter method to
        // allow fluent chaining of configuration options.
        return $this;
    }
    
    public function hasAuthorResource(): bool
    {
        // This is the getter method, where the user's preference
        // is retrieved from the plugin property.
        return $this->hasAuthorResource;
    }
    
    public function register(Panel $panel): void
    {
        // Since the `register()` method is executed after the user
        // configures the plugin, you can access any of their
        // preferences inside it.
        if ($this->hasAuthorResource()) {
            // Here, we only register the author resource on the
            // panel if the user has requested it.
            $panel->resources([
                AuthorResource::class,
            ]);
        }
    }
    
    // ...
}
```

Additionally, you can use the unique ID of the plugin to access any of its configuration options from outside the plugin class. To do this, pass the ID to the `filament()` method:

```php
filament('blog')->hasAuthorResource()
```

You may wish to have better type safety and IDE autocompletion when accessing configuration. It's completely up to you how you choose to achieve this, but one idea could be adding a static method to the plugin class to retrieve it:

```php
use Filament\Contracts\Plugin;

class BlogPlugin implements Plugin
{
    public static function get(): static
    {
        return filament(app(static::class)->getId());
    }
    
    // ...
}
```

Now, you can access the plugin configuration using the new static method:

```php
BlogPlugin::get()->hasAuthorResource()
```

## Distributing a panel in a plugin

It's very easy to distribute an entire panel in a Laravel package. This way, a user can simply install your plugin and have an entirely new part of their app pre-built.

When [configuring](configuration) a panel, the configuration class extends the `PanelProvider` class, and that is a standard Laravel service provider. You can use it as a service provider in your package:

```php
<?php

namespace DanHarrin\FilamentBlog;

use Filament\Panel;
use Filament\PanelProvider;

class BlogPanelProvider extends PanelProvider
{
    public function panel(Panel $panel): Panel
    {
        return $panel
            ->id('blog')
            ->path('blog')
            ->resources([
                // ...
            ])
            ->pages([
                // ...
            ])
            ->widgets([
                // ...
            ])
            ->middleware([
                // ...
            ])
            ->authMiddleware([
                // ...
            ]);
    }
}
```

You should then register it as a service provider in the `composer.json` of your package:

```json
"extra": {
    "laravel": {
        "providers": [
            "DanHarrin\\FilamentBlog\\BlogPanelProvider"
        ]
    }
}
```

# Documentation for panels. File: 14-testing.md
---
title: Testing
---

## Overview

All examples in this guide will be written using [Pest](https://pestphp.com). To use Pest's Livewire plugin for testing, you can follow the installation instructions in the Pest documentation on plugins: [Livewire plugin for Pest](https://pestphp.com/docs/plugins#livewire). However, you can easily adapt this to PHPUnit.

Since all pages in the app are Livewire components, we're just using Livewire testing helpers everywhere. If you've never tested Livewire components before, please read [this guide](https://livewire.laravel.com/docs/testing) from the Livewire docs.

## Getting started

Ensure that you are authenticated to access the app in your `TestCase`:

```php
protected function setUp(): void
{
    parent::setUp();

    $this->actingAs(User::factory()->create());
}
```

### Testing multiple panels

If you have multiple panels and you would like to test a non-default panel, you will need to tell Filament which panel you are testing. This can be done in the `setUp()` method of the test case, or you can do it at the start of a particular test. Filament usually does this in a middleware when you access the panel through a request, so if you're not making a request in your test like when testing a Livewire component, you need to set the current panel manually:

```php
use Filament\Facades\Filament;

Filament::setCurrentPanel(
    Filament::getPanel('app'), // Where `app` is the ID of the panel you want to test.
);
```

## Resources

### Pages

#### List

##### Routing & render

To ensure that the List page for the `PostResource` is able to render successfully, generate a page URL, perform a request to this URL and ensure that it is successful:

```php
it('can render page', function () {
    $this->get(PostResource::getUrl('index'))->assertSuccessful();
});
```

##### Table

Filament includes a selection of helpers for testing tables. A full guide to testing tables can be found [in the Table Builder documentation](../tables/testing).

To use a table [testing helper](../tables/testing), make assertions on the resource's List page class, which holds the table:

```php
use function Pest\Livewire\livewire;

it('can list posts', function () {
    $posts = Post::factory()->count(10)->create();

    livewire(PostResource\Pages\ListPosts::class)
        ->assertCanSeeTableRecords($posts);
});
```

#### Create

##### Routing & render

To ensure that the Create page for the `PostResource` is able to render successfully, generate a page URL, perform a request to this URL and ensure that it is successful:

```php
it('can render page', function () {
    $this->get(PostResource::getUrl('create'))->assertSuccessful();
});
```

##### Creating

You may check that data is correctly saved into the database by calling `fillForm()` with your form data, and then asserting that the database contains a matching record:

```php
use function Pest\Livewire\livewire;

it('can create', function () {
    $newData = Post::factory()->make();

    livewire(PostResource\Pages\CreatePost::class)
        ->fillForm([
            'author_id' => $newData->author->getKey(),
            'content' => $newData->content,
            'tags' => $newData->tags,
            'title' => $newData->title,
        ])
        ->call('create')
        ->assertHasNoFormErrors();

    $this->assertDatabaseHas(Post::class, [
        'author_id' => $newData->author->getKey(),
        'content' => $newData->content,
        'tags' => json_encode($newData->tags),
        'title' => $newData->title,
    ]);
});
```

##### Validation

Use `assertHasFormErrors()` to ensure that data is properly validated in a form:

```php
use function Pest\Livewire\livewire;

it('can validate input', function () {
    livewire(PostResource\Pages\CreatePost::class)
        ->fillForm([
            'title' => null,
        ])
        ->call('create')
        ->assertHasFormErrors(['title' => 'required']);
});
```

#### Edit

##### Routing & render

To ensure that the Edit page for the `PostResource` is able to render successfully, generate a page URL, perform a request to this URL and ensure that it is successful:

```php
it('can render page', function () {
    $this->get(PostResource::getUrl('edit', [
        'record' => Post::factory()->create(),
    ]))->assertSuccessful();
});
```

##### Filling existing data

To check that the form is filled with the correct data from the database, you may `assertFormSet()` that the data in the form matches that of the record:

```php
use function Pest\Livewire\livewire;

it('can retrieve data', function () {
    $post = Post::factory()->create();

    livewire(PostResource\Pages\EditPost::class, [
        'record' => $post->getRouteKey(),
    ])
        ->assertFormSet([
            'author_id' => $post->author->getKey(),
            'content' => $post->content,
            'tags' => $post->tags,
            'title' => $post->title,
        ]);
});
```

##### Saving

You may check that data is correctly saved into the database by calling `fillForm()` with your form data, and then asserting that the database contains a matching record:

```php
use function Pest\Livewire\livewire;

it('can save', function () {
    $post = Post::factory()->create();
    $newData = Post::factory()->make();

    livewire(PostResource\Pages\EditPost::class, [
        'record' => $post->getRouteKey(),
    ])
        ->fillForm([
            'author_id' => $newData->author->getKey(),
            'content' => $newData->content,
            'tags' => $newData->tags,
            'title' => $newData->title,
        ])
        ->call('save')
        ->assertHasNoFormErrors();

    expect($post->refresh())
        ->author_id->toBe($newData->author->getKey())
        ->content->toBe($newData->content)
        ->tags->toBe($newData->tags)
        ->title->toBe($newData->title);
});
```

##### Validation

Use `assertHasFormErrors()` to ensure that data is properly validated in a form:

```php
use function Pest\Livewire\livewire;

it('can validate input', function () {
    $post = Post::factory()->create();

    livewire(PostResource\Pages\EditPost::class, [
        'record' => $post->getRouteKey(),
    ])
        ->fillForm([
            'title' => null,
        ])
        ->call('save')
        ->assertHasFormErrors(['title' => 'required']);
});
```

##### Deleting

You can test the `DeleteAction` using `callAction()`:

```php
use Filament\Actions\DeleteAction;
use function Pest\Livewire\livewire;

it('can delete', function () {
    $post = Post::factory()->create();

    livewire(PostResource\Pages\EditPost::class, [
        'record' => $post->getRouteKey(),
    ])
        ->callAction(DeleteAction::class);

    $this->assertModelMissing($post);
});
```

You can ensure that a particular user is not able to see a `DeleteAction` using `assertActionHidden()`:

```php
use Filament\Actions\DeleteAction;
use function Pest\Livewire\livewire;

it('can not delete', function () {
    $post = Post::factory()->create();

    livewire(PostResource\Pages\EditPost::class, [
        'record' => $post->getRouteKey(),
    ])
        ->assertActionHidden(DeleteAction::class);
});
```

#### View

##### Routing & render

To ensure that the View page for the `PostResource` is able to render successfully, generate a page URL, perform a request to this URL and ensure that it is successful:

```php
it('can render page', function () {
    $this->get(PostResource::getUrl('view', [
        'record' => Post::factory()->create(),
    ]))->assertSuccessful();
});
```

##### Filling existing data

To check that the form is filled with the correct data from the database, you may `assertFormSet()` that the data in the form matches that of the record:

```php
use function Pest\Livewire\livewire;

it('can retrieve data', function () {
    $post = Post::factory()->create();

    livewire(PostResource\Pages\ViewPost::class, [
        'record' => $post->getRouteKey(),
    ])
        ->assertFormSet([
            'author_id' => $post->author->getKey(),
            'content' => $post->content,
            'tags' => $post->tags,
            'title' => $post->title,
        ]);
});
```

### Relation managers

##### Render

To ensure that a relation manager is able to render successfully, mount the Livewire component:

```php
use App\Filament\Resources\CategoryResource\Pages\EditCategory;
use function Pest\Livewire\livewire;

it('can render relation manager', function () {
    $category = Category::factory()
        ->has(Post::factory()->count(10))
        ->create();

    livewire(CategoryResource\RelationManagers\PostsRelationManager::class, [
        'ownerRecord' => $category,
        'pageClass' => EditCategory::class,
    ])
        ->assertSuccessful();
});
```

##### Table

Filament includes a selection of helpers for testing tables. A full guide to testing tables can be found [in the Table Builder documentation](../tables/testing).

To use a table [testing helper](../tables/testing), make assertions on the relation manager class, which holds the table:

```php
use App\Filament\Resources\CategoryResource\Pages\EditCategory;
use function Pest\Livewire\livewire;

it('can list posts', function () {
    $category = Category::factory()
        ->has(Post::factory()->count(10))
        ->create();

    livewire(CategoryResource\RelationManagers\PostsRelationManager::class, [
        'ownerRecord' => $category,
        'pageClass' => EditCategory::class,
    ])
        ->assertCanSeeTableRecords($category->posts);
});
```

# Documentation for panels. File: 15-upgrade-guide.md
---
title: Upgrading from v2.x
---

> If you see anything missing from this guide, please do not hesitate to [make a pull request](https://github.com/filamentphp/filament/edit/3.x/packages/panels/docs/14-upgrade-guide.md) to our repository! Any help is appreciated!

## New requirements

- Laravel v10.0+
- Livewire v3.0+

Please upgrade Filament before upgrading to Livewire v3. Instructions on how to upgrade Livewire can be found [here](https://livewire.laravel.com/docs/upgrading).

## Upgrading automatically

The easiest way to upgrade your app is to run the automated upgrade script. This script will automatically upgrade your application to the latest version of Filament and make changes to your code, which handles most breaking changes.

```bash
composer require filament/upgrade:"^3.2" -W --dev

vendor/bin/filament-v3
```

Make sure to carefully follow the instructions, and review the changes made by the script. You may need to make some manual changes to your code afterwards, but the script should handle most of the repetitive work for you.

A new `app/Providers/Filament/*PanelProvider.php` file will be created, and the configuration from your old `config/filament.php` file should be copied. Since this is a [Laravel service provider](https://laravel.com/docs/providers), it needs to be registered in `config/app.php`. Filament will attempt to do this for you, but if you get an error while trying to access your panel, then this process has probably failed. You can manually register the service provider by adding it to the `providers` array.

Finally, you must run `php artisan filament:install` to finalize the Filament v3 installation. This command must be run for all new Filament projects.

You can now `composer remove filament/upgrade` as you don't need it anymore.

> Some plugins you're using may not be available in v3 just yet. You could temporarily remove them from your `composer.json` file until they've been upgraded, replace them with a similar plugins that are v3-compatible, wait for the plugins to be upgraded before upgrading your app, or even write PRs to help the authors upgrade them.

## Upgrading manually

After upgrading the dependency via Composer, you should execute `php artisan filament:upgrade` in order to clear any Laravel caches and publish the new frontend assets.

### High-impact changes

#### Panel provider instead of the config file

The Filament v2 config file grew pretty big, and now it is incredibly small. Most of the configuration is now done in a service provider, which provides a cleaner API, more type safety, IDE autocomplete support, and [the ability to create multiple panels in your app](configuration#introducing-panels). We call these special configuration service providers **"panel providers"**.

Before you can create the new panel provider, make sure that you've got Filament v3 installed with Composer. Then, run the following command:

```bash
php artisan filament:install --panels
```

A new `app/Providers/Filament/AdminPanelProvider.php` file will be created, ready for you to transfer over your old configuration from the `config/filament.php` file. Since this is a [Laravel service provider](https://laravel.com/docs/providers), it needs to be registered in `config/app.php`. Filament will attempt to do this for you, but if you get an error while trying to access your panel, then this process has probably failed. You can manually register the service provider by adding it to the `providers` array.

Most configuration transfer is very self-explanatory, but if you get stuck, please refer to the [configuration documentation](configuration).

This will especially affect configuration done via the `Filament::serving()` method, which was used for theme customization, navigation and menu registration. Consult the [configuration](configuration), [navigation](navigation) and [themes](themes) documentation sections.

Finally, you can run the following command to replace the old config file with the shiny new one:

```bash
php artisan vendor:publish --tag=filament-config --force
```

#### `FILAMENT_FILESYSTEM_DRIVER` .env variable

The `FILAMENT_FILESYSTEM_DRIVER` .env variable has been renamed to `FILAMENT_FILESYSTEM_DISK`. This is to make it more consistent with Laravel, as Laravel v9 introduced this change as well. Please ensure that you update your .env files accordingly, and don't forget production!

#### Resource and relation manager imports

Some classes that are imported in resources and relation managers have moved:

- `Filament\Resources\Form` has moved to `Filament\Forms\Form`
- `Filament\Resources\Table` has moved to `Filament\Tables\Table`

#### Method signature changes

User model (with `FilamentUser` interface):

- `canAccessFilament()` has been renamed to `canAccessPanel()` and has a new `\Filament\Panel $panel` parameter

Resource classes:

- `applyGlobalSearchAttributeConstraint()` now has a `string $search` parameter before `$searchAttributes()` instead of `$searchQuery` after
- `getGlobalSearchEloquentQuery()` is public
- `getGlobalSearchResults()`has a `$search` parameter instead of `$searchQuery`
- `getRouteBaseName()` has a new `?string $panel` parameter

Resource classes and all page classes, including resource pages, custom pages, settings pages, and dashboard pages:

- `getActiveNavigationIcon()` is public
- `getNavigationBadge()` is public
- `getNavigationBadgeColor()` is public
- `getNavigationGroup()` is public
- `getNavigationIcon()` is public
- `getNavigationLabel()` is public
- `getNavigationSort()` is public
- `getNavigationUrl()` is public
- `shouldRegisterNavigation()` is public

All page classes, including resource pages, custom pages, settings pages, and custom dashboard pages:

- `getBreadcrumbs()` is public
- `getFooterWidgetsColumns()` is public
- `getHeader()` is public
- `getHeaderWidgetsColumns()` is public
- `getHeading()` is public
- `getRouteName()` has a new `?string $panel` parameter
- `getSubheading()` is public
- `getTitle()` is public
- `getVisibleFooterWidgets()` is public
- `getVisibleHeaderWidgets()` is public

List and Manage resource pages:

- `table()` is public

Create resource pages:

- `canCreateAnother()` is public

Edit and View resource pages:

- `getFormTabLabel()` is now `getContentTabLabel()`

Relation managers:

- `form()` is no longer static
- `getInverseRelationshipName()` return type is now `?string`
- `table()` is no longer static

Custom dashboard pages:

- `getDashboard()` is public
- `getWidgets()` is public

#### Property signature changes

Resource classes and all page classes, including resource pages, custom pages, settings pages, and dashboard pages:

- `$middlewares` is now `$routeMiddleware`

#### Heroicons have been updated to v2

The Heroicons library has been updated to v2. This means that any icons you use in your app may have changed names. You can find a list of changes [here](https://github.com/tailwindlabs/heroicons/releases/tag/v2.0.0).

### Medium-impact changes

#### Date-time pickers

The date-time picker form field now uses the browser's native date picker by default. It usually has a better UX than the old date picker, but you may notice features missing, bad browser compatibility, or behavioral bugs. If you want to revert to the old date picker, you can use the `native(false)` method:

```php
use Filament\Forms\Components\DateTimePicker;

DateTimePicker::make('published_at')
    ->native(false)
```

#### Secondary color

Filament v2 had a `secondary` color for many components which was gray. All references to `secondary` should be replaced with `gray` to preserve the same appearance. This frees `secondary` to be registered to a new custom color of your choice.

#### `$get` and `$set` closure parameters

In the Form Builder package, `$get` and `$set` parameters now use a type of either `\Filament\Forms\Get` or `\Filament\Forms\Set` instead of `\Closure`. This allows for better IDE autocomplete support of each function's parameters.

An easy way to upgrade your code quickly is to find and replace:

- `Closure $get` to `\Filament\Forms\Get $get`
- `Closure $set` to `\Filament\Forms\Set $set`

#### Blade icon components have been disabled

During v2, we noticed performance issues with Blade icon components. We've decided to disable them by default in v3, so we only use the [`@svg()` syntax](https://github.com/blade-ui-kit/blade-icons#directive) for rendering icons.

A side effect of this change is that all custom icons that you use must now be [registered in a set](https://github.com/blade-ui-kit/blade-icons#defining-sets). We no longer allow arbitrary Blade components to be used as custom icons.

#### Logo customization

In v2, you can customize the logo of the admin panel using a `/resources/views/vendor/filament/components/brand.blade.php` file. In v3, this has been moved to the new `brandLogo()` API. You can now [set the brand logo](themes#adding-a-logo) by adding it to your panel configuration.

#### Plugins

Filament v3 has a new universal plugin system that breaches the constraints of the admin panel. Learn how to build v3 plugins [here](plugins).

### Low-impact changes

#### Default actions and type-specific relation manager classes

> If you started the Filament project after v2.13, you can skip this section. Since then, new resources and relation managers have been generated with the new syntax.

Since v2.13, resources and relation managers now define actions within the `table()` method instead of them being assumed by default.

When using simple resources, remove the `CanCreateRecords`, `CanDeleteRecords`, `CanEditRecords`, and `CanViewRecords` traits from the Manage page.

We also deprecated type-specific relation manager classes. Any classes extending `BelongsToManyRelationManager`, `HasManyRelationManager`, `HasManyThroughRelationManager`, `MorphManyRelationManager`, or `MorphToManyRelationManager` should now extend `\Filament\Resources\RelationManagers\RelationManager`. You can also remove the `CanAssociateRecords`, `CanAttachRecords`, `CanCreateRecords`, `CanDeleteRecords`, `CanDetachRecords`, `CanDisassociateRecords`, `CanEditRecords`, and `CanViewRecords` traits from relation managers.

To learn more about v2.13 changes, read our [blog post](https://v2.filamentphp.com/blog/v2130-admin-resources).

#### Blade components

Some Blade components have been moved to different namespaces:

- `<x-filament::page>` is now `<x-filament-panels::page>`
- `<x-filament::widget>` is now `<x-filament-widgets::widget>`

However, aliases have been set up so that you don't need to change your code.

#### Resource pages without a `$resource` property

Filament v2 allowed for resource pages to be created without a `$resource` property. In v3 you must declare this, else you may end up with the error:

`Typed static property Filament\Resources\Pages\Page::$resource must not be accessed before initialization`

You should ensure that the `$resource` property is set on all resource pages:

```php
protected static string $resource = PostResource::class;
```

