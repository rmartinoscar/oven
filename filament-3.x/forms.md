# Documentation for forms. File: 01-installation.md
---
title: Installation
---

**The Form Builder package is pre-installed with the [Panel Builder](/docs/panels).** This guide is for using the Form Builder in a custom TALL Stack application (Tailwind, Alpine, Livewire, Laravel).

## Requirements

Filament requires the following to run:

- PHP 8.1+
- Laravel v10.0+
- Livewire v3.0+
- Tailwind v3.0+ [(Using Tailwind v4?)](#installing-tailwind-css)

## Installation

Require the Form Builder package using Composer:

```bash
composer require filament/forms:"^3.3" -W
```

## New Laravel projects

To quickly get started with Filament in a new Laravel project, run the following commands to install [Livewire](https://livewire.laravel.com), [Alpine.js](https://alpinejs.dev), and [Tailwind CSS](https://tailwindcss.com):

> Since these commands will overwrite existing files in your application, only run this in a new Laravel project!

```bash
php artisan filament:install --scaffold --forms

npm install

npm run dev
```

## Existing Laravel projects

Run the following command to install the Form Builder assets:

```bash
php artisan filament:install --forms
```

### Installing Tailwind CSS

> Filament uses Tailwind CSS v3 for styling. If your project uses Tailwind CSS v4, you will unfortunately need to downgrade it to v3 to use Filament. Filament v3 can't support Tailwind CSS v4 since it introduces breaking changes. Filament v4 will support Tailwind CSS v4.

Run the following command to install Tailwind CSS with the Tailwind Forms and Typography plugins:

```bash
npm install tailwindcss@3 @tailwindcss/forms @tailwindcss/typography postcss postcss-nesting autoprefixer --save-dev
```

Create a new `tailwind.config.js` file and add the Filament `preset` *(includes the Filament color scheme and the required Tailwind plugins)*:

```js
import preset from './vendor/filament/support/tailwind.config.preset'

export default {
    presets: [preset],
    content: [
        './app/Filament/**/*.php',
        './resources/views/filament/**/*.blade.php',
        './vendor/filament/**/*.blade.php',
    ],
}
```

### Configuring styles

Add Tailwind's CSS layers to your `resources/css/app.css`:

```css
@tailwind base;
@tailwind components;
@tailwind utilities;
@tailwind variants;
```

Create a `postcss.config.js` file in the root of your project and register Tailwind CSS, PostCSS Nesting and Autoprefixer as plugins:

```js
export default {
    plugins: {
        'tailwindcss/nesting': 'postcss-nesting',
        tailwindcss: {},
        autoprefixer: {},
    },
}
```

### Automatically refreshing the browser
You may also want to update your `vite.config.js` file to refresh the page automatically when Livewire components are updated:

```js
import { defineConfig } from 'vite'
import laravel, { refreshPaths } from 'laravel-vite-plugin'

export default defineConfig({
    plugins: [
        laravel({
            input: ['resources/css/app.css', 'resources/js/app.js'],
            refresh: [
                ...refreshPaths,
                'app/Livewire/**',
            ],
        }),
    ],
})
```

### Compiling assets

Compile your new CSS and Javascript assets using `npm run dev`.

### Configuring your layout

Create a new `resources/views/components/layouts/app.blade.php` layout file for Livewire components:

```blade
<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
    <head>
        <meta charset="utf-8">

        <meta name="application-name" content="{{ config('app.name') }}">
        <meta name="csrf-token" content="{{ csrf_token() }}">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <title>{{ config('app.name') }}</title>

        <style>
            [x-cloak] {
                display: none !important;
            }
        </style>

        @filamentStyles
        @vite('resources/css/app.css')
    </head>

    <body class="antialiased">
        {{ $slot }}

        @filamentScripts
        @vite('resources/js/app.js')
    </body>
</html>
```

## Publishing configuration

You can publish the package configuration using the following command (optional):

```bash
php artisan vendor:publish --tag=filament-config
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

# Documentation for forms. File: 02-getting-started.md
---
title: Getting started
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Overview

Filament's form package allows you to easily build dynamic forms in your app. You can use it to [add a form to any Livewire component](adding-a-form-to-a-livewire-component). Additionally, it's used within other Filament packages to render forms within [app resources](../panels/resources/getting-started), [action modals](../actions/modals), [table filters](../tables/filters/getting-started), and more. Learning how to build forms is essential to learning how to use these Filament packages.

This guide will walk you through the basics of building forms with Filament's form package. If you're planning to add a new form to your own Livewire component, you should [do that first](adding-a-form-to-a-livewire-component) and then come back. If you're adding a form to an [app resource](../panels/resources/getting-started), or another Filament package, you're ready to go!

## Form schemas

All Filament forms have a "schema". This is an array, which contains [fields](fields/getting-started#available-fields) and [layout components](layout/getting-started#available-layout-components).

Fields are the inputs that your user will fill their data into. For example, HTML's `<input>` or `<select>` elements. Each field has its own PHP class. For example, the [`TextInput`](fields/text-input) class is used to render a text input field, and the [`Select`](fields/select) class is used to render a select field. You can see a full [list of available fields here](fields/getting-started#available-fields).

Layout components are used to group fields together, and to control how they are displayed. For example, you can use a [`Grid`](layout/grid#grid-component) component to display multiple fields side-by-side, or a [`Wizard`](layout/wizard) to separate fields into a multistep form. You can deeply nest layout components within each other to create very complex responsive UIs. You can see a full [list of available layout components here](layout/getting-started#available-layout-components).

### Adding fields to a form schema

Initialise a field or layout component with the `make()` method, and build a schema array with multiple fields:

```php
use Filament\Forms\Components\RichEditor;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Form;

public function form(Form $form): Form
{
    return $form
        ->schema([
            TextInput::make('title'),
            TextInput::make('slug'),
            RichEditor::make('content'),
        ]);
}
```

<AutoScreenshot name="forms/getting-started/fields" alt="Form fields" version="3.x" />

Forms within a panel and other packages usually have 2 columns by default. For custom forms, you can use the `columns()` method to achieve the same effect:

```php
$form
    ->schema([
        // ...
    ])
    ->columns(2);
```

<AutoScreenshot name="forms/getting-started/columns" alt="Form fields in 2 columns" version="3.x" />

Now, the `RichEditor` will only consume half of the available width. We can use the `columnSpan()` method to make it span the full width:

```php
use Filament\Forms\Components\RichEditor;
use Filament\Forms\Components\TextInput;

[
    TextInput::make('title'),
    TextInput::make('slug'),
    RichEditor::make('content')
        ->columnSpan(2), // or `columnSpan('full')`
]
```

<AutoScreenshot name="forms/getting-started/column-span" alt="Form fields in 2 columns, but with the rich editor spanning the full width of the form" version="3.x" />

You can learn more about columns and spans in the [layout documentation](layout/grid). You can even make them responsive!

### Adding layout components to a form schema

Let's add a new [`Section`](layout/section) to our form. `Section` is a layout component, and it allows you to add a heading and description to a set of fields. It can also allow fields inside it to collapse, which saves space in long forms.

```php
use Filament\Forms\Components\RichEditor;
use Filament\Forms\Components\Section;
use Filament\Forms\Components\TextInput;

[
    TextInput::make('title'),
    TextInput::make('slug'),
    RichEditor::make('content')
        ->columnSpan(2),
    Section::make('Publishing')
        ->description('Settings for publishing this post.')
        ->schema([
            // ...
        ]),
]
```

In this example, you can see how the `Section` component has its own `schema()` method. You can use this to nest other fields and layout components inside:

```php
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Section;
use Filament\Forms\Components\Select;

Section::make('Publishing')
    ->description('Settings for publishing this post.')
    ->schema([
        Select::make('status')
            ->options([
                'draft' => 'Draft',
                'reviewing' => 'Reviewing',
                'published' => 'Published',
            ]),
        DateTimePicker::make('published_at'),
    ])
```

<AutoScreenshot name="forms/getting-started/section" alt="Form with section component" version="3.x" />

This section now contains a [`Select` field](fields/select) and a [`DateTimePicker` field](fields/date-time-picker). You can learn more about those fields and their functionalities on the respective docs pages.

## Validating fields

In Laravel, validation rules are usually defined in arrays like `['required', 'max:255']` or a combined string like `required|max:255`. This is fine if you're exclusively working in the backend with simple form requests. But Filament is also able to give your users frontend validation, so they can fix their mistakes before any backend requests are made.

In Filament, you can add validation rules to your fields by using methods like `required()` and `maxLength()`. This is also advantageous over Laravel's validation syntax, since your IDE can autocomplete these methods:

```php
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\RichEditor;
use Filament\Forms\Components\Section;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;

[
    TextInput::make('title')
        ->required()
        ->maxLength(255),
    TextInput::make('slug')
        ->required()
        ->maxLength(255),
    RichEditor::make('content')
        ->columnSpan(2)
        ->maxLength(65535),
    Section::make('Publishing')
        ->description('Settings for publishing this post.')
        ->schema([
            Select::make('status')
                ->options([
                    'draft' => 'Draft',
                    'reviewing' => 'Reviewing',
                    'published' => 'Published',
                ])
                ->required(),
            DateTimePicker::make('published_at'),
        ]),
]
```

In this example, some fields are `required()`, and some have a `maxLength()`. We have [methods for most of Laravel's validation rules](validation#available-rules), and you can even add your own [custom rules](validation#custom-rules).

## Dependant fields

Since all Filament forms are built on top of Livewire, form schemas are completely dynamic. There are so many possibilities, but here are a couple of examples of how you can use this to your advantage:

Fields can hide or show based on another field's values. In our form, we can hide the `published_at` timestamp field until the `status` field is set to `published`. This is done by passing a closure to the `hidden()` method, which allows you to dynamically hide or show a field while the form is being used. Closures have access to many useful arguments like `$get`, and you can find a [full list here](advanced#form-component-utility-injection). The field that you depend on (the `status` in this case) needs to be set to `live()`, which tells the form to reload the schema each time it gets changed.

```php
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Get;

[
    Select::make('status')
        ->options([
            'draft' => 'Draft',
            'reviewing' => 'Reviewing',
            'published' => 'Published',
        ])
        ->required()
        ->live(),
    DateTimePicker::make('published_at')
        ->hidden(fn (Get $get) => $get('status') !== 'published'),
]
```

It's not just `hidden()` - all Filament form methods support closures like this. You can use them to change the label, placeholder, or even the options of a field, based on another. You can even use them to add new fields to the form, or remove them. This is a powerful tool that allows you to create complex forms with minimal effort.

Fields can also write data to other fields. For example, we can set the title to automatically generate a slug when the title is changed. This is done by passing a closure to the `afterStateUpdated()` method, which gets run each time the title is changed. This closure has access to the title (`$state`) and a function (`$set`) to set the slug field's state. You can find a [full list of closure arguments here](advanced#form-component-utility-injection). The field that you depend on (the `title` in this case) needs to be set to `live()`, which tells the form to reload and set the slug each time it gets changed.

```php
use Filament\Forms\Components\TextInput;
use Filament\Forms\Set;
use Illuminate\Support\Str;

[
    TextInput::make('title')
        ->required()
        ->maxLength(255)
        ->live()
        ->afterStateUpdated(function (Set $set, $state) {
            $set('slug', Str::slug($state));
        }),
    TextInput::make('slug')
        ->required()
        ->maxLength(255),
]
```

## Next steps with the forms package

Now you've finished reading this guide, where to next? Here are some suggestions:

- [Explore the available fields to collect input from your users.](fields/getting-started#available-fields)
- [Check out the list of layout components to craft intuitive form structures with.](fields/getting-started#available-fields)
- [Find out about all advanced techniques that you can customize forms to your needs.](advanced)
- [Write automated tests for your forms using our suite of helper methods.](testing)

# Documentation for forms. File: 03-fields/01-getting-started.md
---
title: Getting started
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Overview

Field classes can be found in the `Filament\Form\Components` namespace.

Fields reside within the schema of your form, alongside any [layout components](layout/getting-started).

Fields may be created using the static `make()` method, passing its unique name. The name of the field should correspond to a property on your Livewire component. You may use "dot notation" to bind fields to keys in arrays.

```php
use Filament\Forms\Components\TextInput;

TextInput::make('name')
```

<AutoScreenshot name="forms/fields/simple" alt="Form field" version="3.x" />

## Available fields

Filament ships with many types of field, suitable for editing different types of data:

- [Text input](text-input)
- [Select](select)
- [Checkbox](checkbox)
- [Toggle](toggle)
- [Checkbox list](checkbox-list)
- [Radio](radio)
- [Date-time picker](date-time-picker)
- [File upload](file-upload)
- [Rich editor](rich-editor)
- [Markdown editor](markdown-editor)
- [Repeater](repeater)
- [Builder](builder)
- [Tags input](tags-input)
- [Textarea](textarea)
- [Key-value](key-value)
- [Color picker](color-picker)
- [Toggle buttons](toggle-buttons)
- [Hidden](hidden)

You may also [create your own custom fields](custom) to edit data however you wish.

## Setting a label

By default, the label of the field will be automatically determined based on its name. To override the field's label, you may use the `label()` method. Customizing the label in this way is useful if you wish to use a [translation string for localization](https://laravel.com/docs/localization#retrieving-translation-strings):

```php
use Filament\Forms\Components\TextInput;

TextInput::make('name')
    ->label(__('fields.name'))
```

Optionally, you can have the label automatically translated [using Laravel's localization features](https://laravel.com/docs/localization) with the `translateLabel()` method:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('name')
    ->translateLabel() // Equivalent to `label(__('Name'))`
```

## Setting an ID

In the same way as labels, field IDs are also automatically determined based on their names. To override a field ID, use the `id()` method:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('name')
    ->id('name-field')
```

## Setting a default value

Fields may have a default value. This will be filled if the [form's `fill()` method](getting-started#default-data) is called without any arguments. To define a default value, use the `default()` method:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('name')
    ->default('John')
```

Note that these defaults are only used when the form is loaded without existing data. Inside [panel resources](../../panels/resources#resource-forms) this only works on Create Pages, as Edit Pages will always fill the data from the model.

## Adding helper text below the field

Sometimes, you may wish to provide extra information for the user of the form. For this purpose, you may add helper text below the field.

The `helperText()` method is used to add helper text:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('name')
    ->helperText('Your full name here, including any middle names.')
```

This method accepts a plain text string, or an instance of `Illuminate\Support\HtmlString` or `Illuminate\Contracts\Support\Htmlable`. This allows you to render HTML, or even markdown, in the helper text:

```php
use Filament\Forms\Components\TextInput;
use Illuminate\Support\HtmlString;

TextInput::make('name')
    ->helperText(new HtmlString('Your <strong>full name</strong> here, including any middle names.'))

TextInput::make('name')
    ->helperText(str('Your **full name** here, including any middle names.')->inlineMarkdown()->toHtmlString())

TextInput::make('name')
    ->helperText(view('name-helper-text'))
```

<AutoScreenshot name="forms/fields/helper-text" alt="Form field with helper text" version="3.x" />

## Adding a hint next to the label

As well as [helper text](#adding-helper-text-below-the-field) below the field, you may also add a "hint" next to the label of the field. This is useful for displaying additional information about the field, such as a link to a help page.

The `hint()` method is used to add a hint:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('password')
    ->hint('Forgotten your password? Bad luck.')
```

This method accepts a plain text string, or an instance of `Illuminate\Support\HtmlString` or `Illuminate\Contracts\Support\Htmlable`. This allows you to render HTML, or even markdown, in the helper text:

```php
use Filament\Forms\Components\TextInput;
use Illuminate\Support\HtmlString;

TextInput::make('password')
    ->hint(new HtmlString('<a href="/forgotten-password">Forgotten your password?</a>'))

TextInput::make('password')
    ->hint(str('[Forgotten your password?](/forgotten-password)')->inlineMarkdown()->toHtmlString())

TextInput::make('password')
    ->hint(view('forgotten-password-hint'))
```

<AutoScreenshot name="forms/fields/hint" alt="Form field with hint" version="3.x" />

### Changing the text color of the hint

You can change the text color of the hint. By default, it's gray, but you may use `danger`, `info`, `primary`, `success` and `warning`:

```php
use Filament\Forms\Components\RichEditor;

RichEditor::make('content')
    ->hint('Translatable')
    ->hintColor('primary')
```

<AutoScreenshot name="forms/fields/hint-color" alt="Form field with hint color" version="3.x" />

### Adding an icon aside the hint

Hints may also have an [icon](https://blade-ui-kit.com/blade-icons?set=1#search) rendered next to them:

```php
use Filament\Forms\Components\RichEditor;

RichEditor::make('content')
    ->hint('Translatable')
    ->hintIcon('heroicon-m-language')
```

<AutoScreenshot name="forms/fields/hint-icon" alt="Form field with hint icon" version="3.x" />

#### Adding a tooltip to a hint icon

Additionally, you can add a tooltip to display when you hover over the hint icon, using the `tooltip` parameter of `hintIcon()`:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('name')
    ->hintIcon('heroicon-m-question-mark-circle', tooltip: 'Need some more information?')
```

## Adding extra HTML attributes

You can pass extra HTML attributes to the field, which will be merged onto the outer DOM element. Pass an array of attributes to the `extraAttributes()` method, where the key is the attribute name and the value is the attribute value:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('name')
    ->extraAttributes(['title' => 'Text input'])
```

Some fields use an underlying `<input>` or `<select>` DOM element, but this is often not the outer element in the field, so the `extraAttributes()` method may not work as you wish. In this case, you may use the `extraInputAttributes()` method, which will merge the attributes onto the `<input>` or `<select>` element:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('categories')
    ->extraInputAttributes(['width' => 200])
```

You can also pass extra HTML attributes to the field wrapper which surrounds the label, entry, and any other text:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('categories')
    ->extraFieldWrapperAttributes(['class' => 'components-locked'])
```

## Disabling a field

You may disable a field to prevent it from being edited by the user:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('name')
    ->disabled()
```

<AutoScreenshot name="forms/fields/disabled" alt="Disabled form field" version="3.x" />

Optionally, you may pass a boolean value to control if the field should be disabled or not:

```php
use Filament\Forms\Components\Toggle;

Toggle::make('is_admin')
    ->disabled(! auth()->user()->isAdmin())
```

Disabling a field will prevent it from being saved. If you'd like it to be saved, but still not editable, use the `dehydrated()` method:

```php
Toggle::make('is_admin')
    ->disabled()
    ->dehydrated()
```

> If you choose to dehydrate the field, a skilled user could still edit the field's value by manipulating Livewire's JavaScript.

### Hiding a field

You may hide a field:

 ```php
 use Filament\Forms\Components\TextInput;

 TextInput::make('name')
    ->hidden()
 ```

Optionally, you may pass a boolean value to control if the field should be hidden or not:

 ```php
 use Filament\Forms\Components\TextInput;

 TextInput::make('name')
    ->hidden(! auth()->user()->isAdmin())
 ```

## Autofocusing a field when the form is loaded

Most fields are autofocusable. Typically, you should aim for the first significant field in your form to be autofocused for the best user experience. You can nominate a field to be autofocused using the `autofocus()` method:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('name')
    ->autofocus()
```

## Setting a placeholder

Many fields will also include a placeholder value for when it has no value. This is displayed in the UI but not saved if the field is submitted with no value. You may customize this placeholder using the `placeholder()` method:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('name')
    ->placeholder('John Doe')
```

<AutoScreenshot name="forms/fields/placeholder" alt="Form field with placeholder" version="3.x" />

## Marking a field as required

By default, [required fields](validation#required) will show an asterisk `*` next to their label. You may want to hide the asterisk on forms where all fields are required, or where it makes sense to add a [hint](#adding-a-hint-next-to-the-label) to optional fields instead:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('name')
    ->required() // Adds validation to ensure the field is required
    ->markAsRequired(false) // Removes the asterisk
```

If your field is not `required()`, but you still wish to show an asterisk `*` you can use `markAsRequired()` too:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('name')
    ->markAsRequired()
```

## Global settings

If you wish to change the default behavior of a field globally, then you can call the static `configureUsing()` method inside a service provider's `boot()` method or a middleware. Pass a closure which is able to modify the component. For example, if you wish to make all [checkboxes `inline(false)`](checkbox#positioning-the-label-above), you can do it like so:

```php
use Filament\Forms\Components\Checkbox;

Checkbox::configureUsing(function (Checkbox $checkbox): void {
    $checkbox->inline(false);
});
```

Of course, you are still able to overwrite this behavior on each field individually:

```php
use Filament\Forms\Components\Checkbox;

Checkbox::make('is_admin')
    ->inline()
```

# Documentation for forms. File: 03-fields/02-text-input.md
---
title: Text input
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Overview

The text input allows you to interact with a string:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('name')
```

<AutoScreenshot name="forms/fields/text-input/simple" alt="Text input" version="3.x" />

## Setting the HTML input type

You may set the type of string using a set of methods. Some, such as `email()`, also provide validation:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('text')
    ->email() // or
    ->numeric() // or
    ->integer() // or
    ->password() // or
    ->tel() // or
    ->url()
```

You may instead use the `type()` method to pass another [HTML input type](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input#input_types):

```php
use Filament\Forms\Components\TextInput;

TextInput::make('backgroundColor')
    ->type('color')
```

## Setting the HTML input mode

You may set the [`inputmode` attribute](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input#inputmode) of the input using the `inputMode()` method:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('text')
    ->numeric()
    ->inputMode('decimal')
```

## Setting the numeric step

You may set the [`step` attribute](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input#step) of the input using the `step()` method:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('number')
    ->numeric()
    ->step(100)
```

## Autocompleting text

You may allow the text to be [autocompleted by the browser](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input#autocomplete) using the `autocomplete()` method:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('password')
    ->password()
    ->autocomplete('new-password')
```

As a shortcut for `autocomplete="off"`, you may use `autocomplete(false)`:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('password')
    ->password()
    ->autocomplete(false)
```

For more complex autocomplete options, text inputs also support [datalists](#autocompleting-text-with-a-datalist).

### Autocompleting text with a datalist

You may specify [datalist](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/datalist) options for a text input using the `datalist()` method:

```php
TextInput::make('manufacturer')
    ->datalist([
        'BMW',
        'Ford',
        'Mercedes-Benz',
        'Porsche',
        'Toyota',
        'Tesla',
        'Volkswagen',
    ])
```

Datalists provide autocomplete options to users when they use a text input. However, these are purely recommendations, and the user is still able to type any value into the input. If you're looking to strictly limit users to a set of predefined options, check out the [select field](select).

## Autocapitalizing text

You may allow the text to be [autocapitalized by the browser](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input#autocapitalize) using the `autocapitalize()` method:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('name')
    ->autocapitalize('words')
```

## Adding affix text aside the field

You may place text before and after the input using the `prefix()` and `suffix()` methods:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('domain')
    ->prefix('https://')
    ->suffix('.com')
```

<AutoScreenshot name="forms/fields/text-input/affix" alt="Text input with affixes" version="3.x" />

### Using icons as affixes

You may place an [icon](https://blade-ui-kit.com/blade-icons?set=1#search) before and after the input using the `prefixIcon()` and `suffixIcon()` methods:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('domain')
    ->url()
    ->suffixIcon('heroicon-m-globe-alt')
```

<AutoScreenshot name="forms/fields/text-input/suffix-icon" alt="Text input with suffix icon" version="3.x" />

#### Setting the affix icon's color

Affix icons are gray by default, but you may set a different color using the `prefixIconColor()` and `suffixIconColor()` methods:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('domain')
    ->url()
    ->suffixIcon('heroicon-m-check-circle')
    ->suffixIconColor('success')
```

## Revealable password inputs

When using `password()`, you can also make the input `revealable()`, so that the user can see a plain text version of the password they're typing by clicking a button:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('password')
    ->password()
    ->revealable()
```

<AutoScreenshot name="forms/fields/text-input/revealable-password" alt="Text input with revealable password" version="3.x" />

## Input masking

Input masking is the practice of defining a format that the input value must conform to.

In Filament, you may use the `mask()` method to configure an [Alpine.js mask](https://alpinejs.dev/plugins/mask#x-mask):

```php
use Filament\Forms\Components\TextInput;

TextInput::make('birthday')
    ->mask('99/99/9999')
    ->placeholder('MM/DD/YYYY')
```

To use a [dynamic mask](https://alpinejs.dev/plugins/mask#mask-functions), wrap the JavaScript in a `RawJs` object:

```php
use Filament\Forms\Components\TextInput;
use Filament\Support\RawJs;

TextInput::make('cardNumber')
    ->mask(RawJs::make(<<<'JS'
        $input.startsWith('34') || $input.startsWith('37') ? '9999 999999 99999' : '9999 9999 9999 9999'
    JS))
```

Alpine.js will send the entire masked value to the server, so you may need to strip certain characters from the state before validating the field and saving it. You can do this with the `stripCharacters()` method, passing in a character or an array of characters to remove from the masked value:

```php
use Filament\Forms\Components\TextInput;
use Filament\Support\RawJs;

TextInput::make('amount')
    ->mask(RawJs::make('$money($input)'))
    ->stripCharacters(',')
    ->numeric()
```

## Making the field read-only

Not to be confused with [disabling the field](getting-started#disabling-a-field), you may make the field "read-only" using the `readOnly()` method:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('name')
    ->readOnly()
```

There are a few differences, compared to [`disabled()`](getting-started#disabling-a-field):

- When using `readOnly()`, the field will still be sent to the server when the form is submitted. It can be mutated with the browser console, or via JavaScript. You can use [`dehydrated(false)`](advanced#preventing-a-field-from-being-dehydrated) to prevent this.
- There are no styling changes, such as less opacity, when using `readOnly()`.
- The field is still focusable when using `readOnly()`.

## Text input validation

As well as all rules listed on the [validation](../validation) page, there are additional rules that are specific to text inputs.

### Length validation

You may limit the length of the input by setting the `minLength()` and `maxLength()` methods. These methods add both frontend and backend validation:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('name')
    ->minLength(2)
    ->maxLength(255)
```

You can also specify the exact length of the input by setting the `length()`. This method adds both frontend and backend validation:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('code')
    ->length(8)
```

### Size validation

You may validate the minimum and maximum value of a numeric input by setting the `minValue()` and `maxValue()` methods:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('number')
    ->numeric()
    ->minValue(1)
    ->maxValue(100)
```

### Phone number validation

When using a `tel()` field, the value will be validated using: `/^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\.\/0-9]*$/`.

If you wish to change that, then you can use the `telRegex()` method:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('phone')
    ->tel()
    ->telRegex('/^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\.\/0-9]*$/')
```

Alternatively, to customize the `telRegex()` across all fields, use a service provider:

```php
use Filament\Forms\Components\TextInput;

TextInput::configureUsing(function (TextInput $component): void {
    $component->telRegex('/^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\.\/0-9]*$/');
});
```

# Documentation for forms. File: 03-fields/03-select.md
---
title: Select
---
import AutoScreenshot from "@components/AutoScreenshot.astro"
import LaracastsBanner from "@components/LaracastsBanner.astro"

## Overview

<LaracastsBanner
    title="Select Input"
    description="Watch the Rapid Laravel Development with Filament series on Laracasts - it will teach you the basics of adding select fields to Filament forms."
    url="https://laracasts.com/series/rapid-laravel-development-with-filament/episodes/4"
    series="rapid-laravel-development"
/>

The select component allows you to select from a list of predefined options:

```php
use Filament\Forms\Components\Select;

Select::make('status')
    ->options([
        'draft' => 'Draft',
        'reviewing' => 'Reviewing',
        'published' => 'Published',
    ])
```

<AutoScreenshot name="forms/fields/select/simple" alt="Select" version="3.x" />

## Enabling the JavaScript select

By default, Filament uses the native HTML5 select. You may enable a more customizable JavaScript select using the `native(false)` method:

```php
use Filament\Forms\Components\Select;

Select::make('status')
    ->options([
        'draft' => 'Draft',
        'reviewing' => 'Reviewing',
        'published' => 'Published',
    ])
    ->native(false)
```

<AutoScreenshot name="forms/fields/select/javascript" alt="JavaScript select" version="3.x" />

## Searching options

You may enable a search input to allow easier access to many options, using the `searchable()` method:

```php
use Filament\Forms\Components\Select;

Select::make('author_id')
    ->label('Author')
    ->options(User::all()->pluck('name', 'id'))
    ->searchable()
```

<AutoScreenshot name="forms/fields/select/searchable" alt="Searchable select" version="3.x" />

### Returning custom search results

If you have lots of options and want to populate them based on a database search or other external data source, you can use the `getSearchResultsUsing()` and `getOptionLabelUsing()` methods instead of `options()`.

The `getSearchResultsUsing()` method accepts a callback that returns search results in `$key => $value` format. The current user's search is available as `$search`, and you should use that to filter your results.

The `getOptionLabelUsing()` method accepts a callback that transforms the selected option `$value` into a label. This is used when the form is first loaded when the user has not made a search yet. Otherwise, the label used to display the currently selected option would not be available.

Both `getSearchResultsUsing()` and `getOptionLabelUsing()` must be used on the select if you want to provide custom search results:

```php
Select::make('author_id')
    ->searchable()
    ->getSearchResultsUsing(fn (string $search): array => User::where('name', 'like', "%{$search}%")->limit(50)->pluck('name', 'id')->toArray())
    ->getOptionLabelUsing(fn ($value): ?string => User::find($value)?->name),
```

## Multi-select

The `multiple()` method on the `Select` component allows you to select multiple values from the list of options:

```php
use Filament\Forms\Components\Select;

Select::make('technologies')
    ->multiple()
    ->options([
        'tailwind' => 'Tailwind CSS',
        'alpine' => 'Alpine.js',
        'laravel' => 'Laravel',
        'livewire' => 'Laravel Livewire',
    ])
```

<AutoScreenshot name="forms/fields/select/multiple" alt="Multi-select" version="3.x" />

These options are returned in JSON format. If you're saving them using Eloquent, you should be sure to add an `array` [cast](https://laravel.com/docs/eloquent-mutators#array-and-json-casting) to the model property:

```php
use Illuminate\Database\Eloquent\Model;

class App extends Model
{
    protected $casts = [
        'technologies' => 'array',
    ];

    // ...
}
```

If you're [returning custom search results](#returning-custom-search-results), you should define `getOptionLabelsUsing()` instead of `getOptionLabelUsing()`. `$values` will be passed into the callback instead of `$value`, and you should return a `$key => $value` array of labels and their corresponding values:

```php
Select::make('technologies')
    ->multiple()
    ->searchable()
    ->getSearchResultsUsing(fn (string $search): array => Technology::where('name', 'like', "%{$search}%")->limit(50)->pluck('name', 'id')->toArray())
    ->getOptionLabelsUsing(fn (array $values): array => Technology::whereIn('id', $values)->pluck('name', 'id')->toArray()),
```

## Grouping options

You can group options together under a label, to organize them better. To do this, you can pass an array of groups to `options()` or wherever you would normally pass an array of options. The keys of the array are used as group labels, and the values are arrays of options in that group:

```php
use Filament\Forms\Components\Select;

Select::make('status')
    ->searchable()
    ->options([
        'In Process' => [
            'draft' => 'Draft',
            'reviewing' => 'Reviewing',
        ],
        'Reviewed' => [
            'published' => 'Published',
            'rejected' => 'Rejected',
        ],
    ])
```

<AutoScreenshot name="forms/fields/select/grouped" alt="Grouped select" version="3.x" />

## Integrating with an Eloquent relationship

> If you're building a form inside your Livewire component, make sure you have set up the [form's model](../adding-a-form-to-a-livewire-component#setting-a-form-model). Otherwise, Filament doesn't know which model to use to retrieve the relationship from.

You may employ the `relationship()` method of the `Select` to configure a `BelongsTo` relationship to automatically retrieve options from. The `titleAttribute` is the name of a column that will be used to generate a label for each option:

```php
use Filament\Forms\Components\Select;

Select::make('author_id')
    ->relationship(name: 'author', titleAttribute: 'name')
```

The `multiple()` method may be used in combination with `relationship()` to use a `BelongsToMany` relationship. Filament will load the options from the relationship, and save them back to the relationship's pivot table when the form is submitted. If a `name` is not provided, Filament will use the field name as the relationship name:

```php
use Filament\Forms\Components\Select;

Select::make('technologies')
    ->multiple()
    ->relationship(titleAttribute: 'name')
```

When using `disabled()` with `multiple()` and `relationship()`, ensure that `disabled()` is called before `relationship()`. This ensures that the `dehydrated()` call from within `relationship()` is not overridden by the call from `disabled()`:

```php
use Filament\Forms\Components\Select;

Select::make('technologies')
    ->multiple()
    ->disabled()
    ->relationship(titleAttribute: 'name')
```

### Searching relationship options across multiple columns

By default, if the select is also searchable, Filament will return search results for the relationship based on the title column of the relationship. If you'd like to search across multiple columns, you can pass an array of columns to the `searchable()` method:

```php
use Filament\Forms\Components\Select;

Select::make('author_id')
    ->relationship(name: 'author', titleAttribute: 'name')
    ->searchable(['name', 'email'])
```

### Preloading relationship options

If you'd like to populate the searchable options from the database when the page is loaded, instead of when the user searches, you can use the `preload()` method:

```php
use Filament\Forms\Components\Select;

Select::make('author_id')
    ->relationship(name: 'author', titleAttribute: 'name')
    ->searchable()
    ->preload()
```

### Excluding the current record

When working with recursive relationships, you will likely want to remove the current record from the set of results.

This can be easily be done using the `ignoreRecord` argument:

```php
use Filament\Forms\Components\Select;

Select::make('parent_id')
    ->relationship(name: 'parent', titleAttribute: 'name', ignoreRecord: true)
```

### Customizing the relationship query

You may customize the database query that retrieves options using the third parameter of the `relationship()` method:

```php
use Filament\Forms\Components\Select;
use Illuminate\Database\Eloquent\Builder;

Select::make('author_id')
    ->relationship(
        name: 'author',
        titleAttribute: 'name',
        modifyQueryUsing: fn (Builder $query) => $query->withTrashed(),
    )
```

If you would like to access the current search query in the `modifyQueryUsing` function, you can inject `$search`.

### Customizing the relationship option labels

If you'd like to customize the label of each option, maybe to be more descriptive, or to concatenate a first and last name, you could use a virtual column in your database migration:

```php
$table->string('full_name')->virtualAs('concat(first_name, \' \', last_name)');
```

```php
use Filament\Forms\Components\Select;

Select::make('author_id')
    ->relationship(name: 'author', titleAttribute: 'full_name')
```

Alternatively, you can use the `getOptionLabelFromRecordUsing()` method to transform an option's Eloquent model into a label:

```php
use Filament\Forms\Components\Select;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;

Select::make('author_id')
    ->relationship(
        name: 'author',
        modifyQueryUsing: fn (Builder $query) => $query->orderBy('first_name')->orderBy('last_name'),
    )
    ->getOptionLabelFromRecordUsing(fn (Model $record) => "{$record->first_name} {$record->last_name}")
    ->searchable(['first_name', 'last_name'])
```

### Saving pivot data to the relationship

If you're using a `multiple()` relationship and your pivot table has additional columns, you can use the `pivotData()` method to specify the data that should be saved in them:

```php
use Filament\Forms\Components\Select;

Select::make('primaryTechnologies')
    ->relationship(name: 'technologies', titleAttribute: 'name')
    ->multiple()
    ->pivotData([
        'is_primary' => true,
    ])
```

### Creating a new option in a modal

You may define a custom form that can be used to create a new record and attach it to the `BelongsTo` relationship:

```php
use Filament\Forms\Components\Select;

Select::make('author_id')
    ->relationship(name: 'author', titleAttribute: 'name')
    ->createOptionForm([
        Forms\Components\TextInput::make('name')
            ->required(),
        Forms\Components\TextInput::make('email')
            ->required()
            ->email(),
    ]),
```

<AutoScreenshot name="forms/fields/select/create-option" alt="Select with create option button" version="3.x" />

The form opens in a modal, where the user can fill it with data. Upon form submission, the new record is selected by the field.

<AutoScreenshot name="forms/fields/select/create-option-modal" alt="Select with create option modal" version="3.x" />

#### Customizing new option creation

You can customize the creation process of the new option defined in the form using the `createOptionUsing()` method, which should return the primary key of the newly created record:

```php
use Filament\Forms\Components\Select;

Select::make('author_id')
    ->relationship(name: 'author', titleAttribute: 'name')
    ->createOptionForm([
       // ...
    ])
    ->createOptionUsing(function (array $data): int {
        return auth()->user()->team->members()->create($data)->getKey();
    }),
```

### Editing the selected option in a modal

You may define a custom form that can be used to edit the selected record and save it back to the `BelongsTo` relationship:

```php
use Filament\Forms\Components\Select;

Select::make('author_id')
    ->relationship(name: 'author', titleAttribute: 'name')
    ->editOptionForm([
        Forms\Components\TextInput::make('name')
            ->required(),
        Forms\Components\TextInput::make('email')
            ->required()
            ->email(),
    ]),
```

<AutoScreenshot name="forms/fields/select/edit-option" alt="Select with edit option button" version="3.x" />

The form opens in a modal, where the user can fill it with data. Upon form submission, the data from the form is saved back to the record.

<AutoScreenshot name="forms/fields/select/edit-option-modal" alt="Select with edit option modal" version="3.x" />

### Handling `MorphTo` relationships

`MorphTo` relationships are special, since they give the user the ability to select records from a range of different models. Because of this, we have a dedicated `MorphToSelect` component which is not actually a select field, rather 2 select fields inside a fieldset. The first select field allows you to select the type, and the second allows you to select the record of that type.

To use the `MorphToSelect`, you must pass `types()` into the component, which tell it how to render options for different types:

```php
use Filament\Forms\Components\MorphToSelect;

MorphToSelect::make('commentable')
    ->types([
        MorphToSelect\Type::make(Product::class)
            ->titleAttribute('name'),
        MorphToSelect\Type::make(Post::class)
            ->titleAttribute('title'),
    ])
```

#### Customizing the option labels for each morphed type

The `titleAttribute()` is used to extract the titles out of each product or post. If you'd like to customize the label of each option, you can use the `getOptionLabelFromRecordUsing()` method to transform the Eloquent model into a label:

```php
use Filament\Forms\Components\MorphToSelect;

MorphToSelect::make('commentable')
    ->types([
        MorphToSelect\Type::make(Product::class)
            ->getOptionLabelFromRecordUsing(fn (Product $record): string => "{$record->name} - {$record->slug}"),
        MorphToSelect\Type::make(Post::class)
            ->titleAttribute('title'),
    ])
```

#### Customizing the relationship query for each morphed type

You may customize the database query that retrieves options using the `modifyOptionsQueryUsing()` method:

```php
use Filament\Forms\Components\MorphToSelect;
use Illuminate\Database\Eloquent\Builder;

MorphToSelect::make('commentable')
    ->types([
        MorphToSelect\Type::make(Product::class)
            ->titleAttribute('name')
            ->modifyOptionsQueryUsing(fn (Builder $query) => $query->whereBelongsTo($this->team)),
        MorphToSelect\Type::make(Post::class)
            ->titleAttribute('title')
            ->modifyOptionsQueryUsing(fn (Builder $query) => $query->whereBelongsTo($this->team)),
    ])
```

> Many of the same options in the select field are available for `MorphToSelect`, including `searchable()`, `preload()`, `native()`, `allowHtml()`, and `optionsLimit()`.

## Allowing HTML in the option labels

By default, Filament will escape any HTML in the option labels. If you'd like to allow HTML, you can use the `allowHtml()` method:

```php
use Filament\Forms\Components\Select;

Select::make('technology')
    ->options([
        'tailwind' => '<span class="text-blue-500">Tailwind</span>',
        'alpine' => '<span class="text-green-500">Alpine</span>',
        'laravel' => '<span class="text-red-500">Laravel</span>',
        'livewire' => '<span class="text-pink-500">Livewire</span>',
    ])
    ->searchable()
    ->allowHtml()
```

Be aware that you will need to ensure that the HTML is safe to render, otherwise your application will be vulnerable to XSS attacks.

## Disable placeholder selection

You can prevent the placeholder (null option) from being selected using the `selectablePlaceholder()` method:

```php
use Filament\Forms\Components\Select;

Select::make('status')
    ->options([
        'draft' => 'Draft',
        'reviewing' => 'Reviewing',
        'published' => 'Published',
    ])
    ->default('draft')
    ->selectablePlaceholder(false)
```

## Disabling specific options

You can disable specific options using the `disableOptionWhen()` method. It accepts a closure, in which you can check if the option with a specific `$value` should be disabled:

```php
use Filament\Forms\Components\Select;

Select::make('status')
    ->options([
        'draft' => 'Draft',
        'reviewing' => 'Reviewing',
        'published' => 'Published',
    ])
    ->default('draft')
    ->disableOptionWhen(fn (string $value): bool => $value === 'published')
```

If you want to retrieve the options that have not been disabled, e.g. for validation purposes, you can do so using `getEnabledOptions()`:

```php
use Filament\Forms\Components\Select;

Select::make('status')
    ->options([
        'draft' => 'Draft',
        'reviewing' => 'Reviewing',
        'published' => 'Published',
    ])
    ->default('draft')
    ->disableOptionWhen(fn (string $value): bool => $value === 'published')
    ->in(fn (Select $component): array => array_keys($component->getEnabledOptions()))
```

## Adding affix text aside the field

You may place text before and after the input using the `prefix()` and `suffix()` methods:

```php
use Filament\Forms\Components\Select;

Select::make('domain')
    ->prefix('https://')
    ->suffix('.com')
```

<AutoScreenshot name="forms/fields/select/affix" alt="Select with affixes" version="3.x" />

### Using icons as affixes

You may place an [icon](https://blade-ui-kit.com/blade-icons?set=1#search) before and after the input using the `prefixIcon()` and `suffixIcon()` methods:

```php
use Filament\Forms\Components\Select;

Select::make('domain')
    ->suffixIcon('heroicon-m-globe-alt')
```

<AutoScreenshot name="forms/fields/select/suffix-icon" alt="Select with suffix icon" version="3.x" />

#### Setting the affix icon's color

Affix icons are gray by default, but you may set a different color using the `prefixIconColor()` and `suffixIconColor()` methods:

```php
use Filament\Forms\Components\Select;

Select::make('domain')
    ->suffixIcon('heroicon-m-check-circle')
    ->suffixIconColor('success')
```

## Setting a custom loading message

When you're using a searchable select or multi-select, you may want to display a custom message while the options are loading. You can do this using the `loadingMessage()` method:

```php
use Filament\Forms\Components\Select;

Select::make('author_id')
    ->relationship(name: 'author', titleAttribute: 'name')
    ->searchable()
    ->loadingMessage('Loading authors...')
```

## Setting a custom no search results message

When you're using a searchable select or multi-select, you may want to display a custom message when no search results are found. You can do this using the `noSearchResultsMessage()` method:

```php
use Filament\Forms\Components\Select;

Select::make('author_id')
    ->relationship(name: 'author', titleAttribute: 'name')
    ->searchable()
    ->noSearchResultsMessage('No authors found.')
```

## Setting a custom search prompt

When you're using a searchable select or multi-select, you may want to display a custom message when the user has not yet entered a search term. You can do this using the `searchPrompt()` method:

```php
use Filament\Forms\Components\Select;

Select::make('author_id')
    ->relationship(name: 'author', titleAttribute: 'name')
    ->searchable(['name', 'email'])
    ->searchPrompt('Search authors by their name or email address')
```

## Setting a custom searching message

When you're using a searchable select or multi-select, you may want to display a custom message while the search results are being loaded. You can do this using the `searchingMessage()` method:

```php
use Filament\Forms\Components\Select;

Select::make('author_id')
    ->relationship(name: 'author', titleAttribute: 'name')
    ->searchable()
    ->searchingMessage('Searching authors...')
```

## Tweaking the search debounce

By default, Filament will wait 1000 milliseconds (1 second) before searching for options when the user types in a searchable select or multi-select. It will also wait 1000 milliseconds between searches, if the user is continuously typing into the search input. You can change this using the `searchDebounce()` method:

```php
use Filament\Forms\Components\Select;

Select::make('author_id')
    ->relationship(name: 'author', titleAttribute: 'name')
    ->searchable()
    ->searchDebounce(500)
```

Ensure that you are not lowering the debounce too much, as this may cause the select to become slow and unresponsive due to a high number of network requests to retrieve options from server.

## Limiting the number of options

You can limit the number of options that are displayed in a searchable select or multi-select using the `optionsLimit()` method. The default is 50:

```php
use Filament\Forms\Components\Select;

Select::make('author_id')
    ->relationship(name: 'author', titleAttribute: 'name')
    ->searchable()
    ->optionsLimit(20)
```

Ensure that you are not raising the limit too high, as this may cause the select to become slow and unresponsive due to high in-browser memory usage.

## Select validation

As well as all rules listed on the [validation](../validation) page, there are additional rules that are specific to selects.

### Selected items validation

You can validate the minimum and maximum number of items that you can select in a [multi-select](#multi-select) by setting the `minItems()` and `maxItems()` methods:

```php
use Filament\Forms\Components\Select;

Select::make('technologies')
    ->multiple()
    ->options([
        'tailwind' => 'Tailwind CSS',
        'alpine' => 'Alpine.js',
        'laravel' => 'Laravel',
        'livewire' => 'Laravel Livewire',
    ])
    ->minItems(1)
    ->maxItems(3)
```

## Customizing the select action objects

This field uses action objects for easy customization of buttons within it. You can customize these buttons by passing a function to an action registration method. The function has access to the `$action` object, which you can use to [customize it](../../actions/trigger-button) or [customize its modal](../../actions/modals). The following methods are available to customize the actions:

- `createOptionAction()`
- `editOptionAction()`
- `manageOptionActions()` (for customizing both the create and edit option actions at once)

Here is an example of how you might customize an action:

```php
use Filament\Forms\Components\Actions\Action;
use Filament\Forms\Components\Select;

Select::make('author_id')
    ->relationship(name: 'author', titleAttribute: 'name')
    ->createOptionAction(
        fn (Action $action) => $action->modalWidth('3xl'),
    )
```

# Documentation for forms. File: 03-fields/04-checkbox.md
---
title: Checkbox
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Overview

The checkbox component, similar to a [toggle](toggle), allows you to interact a boolean value.

```php
use Filament\Forms\Components\Checkbox;

Checkbox::make('is_admin')
```

<AutoScreenshot name="forms/fields/checkbox/simple" alt="Checkbox" version="3.x" />

If you're saving the boolean value using Eloquent, you should be sure to add a `boolean` [cast](https://laravel.com/docs/eloquent-mutators#attribute-casting) to the model property:

```php
use Illuminate\Database\Eloquent\Model;

class User extends Model
{
    protected $casts = [
        'is_admin' => 'boolean',
    ];

    // ...
}
```

## Positioning the label above

Checkbox fields have two layout modes, inline and stacked. By default, they are inline.

When the checkbox is inline, its label is adjacent to it:

```php
use Filament\Forms\Components\Checkbox;

Checkbox::make('is_admin')->inline()
```

<AutoScreenshot name="forms/fields/checkbox/inline" alt="Checkbox with its label inline" version="3.x" />

When the checkbox is stacked, its label is above it:

```php
use Filament\Forms\Components\Checkbox;

Checkbox::make('is_admin')->inline(false)
```

<AutoScreenshot name="forms/fields/checkbox/not-inline" alt="Checkbox with its label above" version="3.x" />

## Checkbox validation

As well as all rules listed on the [validation](../validation) page, there are additional rules that are specific to checkboxes.

### Accepted validation

You may ensure that the checkbox is checked using the `accepted()` method:

```php
use Filament\Forms\Components\Checkbox;

Checkbox::make('terms_of_service')
    ->accepted()
```

### Declined validation

You may ensure that the checkbox is not checked using the `declined()` method:

```php
use Filament\Forms\Components\Checkbox;

Checkbox::make('is_under_18')
    ->declined()
```

# Documentation for forms. File: 03-fields/05-toggle.md
---
title: Toggle
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Overview

The toggle component, similar to a [checkbox](checkbox), allows you to interact a boolean value.

```php
use Filament\Forms\Components\Toggle;

Toggle::make('is_admin')
```

<AutoScreenshot name="forms/fields/toggle/simple" alt="Toggle" version="3.x" />

If you're saving the boolean value using Eloquent, you should be sure to add a `boolean` [cast](https://laravel.com/docs/eloquent-mutators#attribute-casting) to the model property:

```php
use Illuminate\Database\Eloquent\Model;

class User extends Model
{
    protected $casts = [
        'is_admin' => 'boolean',
    ];

    // ...
}
```

## Adding icons to the toggle button

Toggles may also use an [icon](https://blade-ui-kit.com/blade-icons?set=1#search) to represent the "on" and "off" state of the button. To add an icon to the "on" state, use the `onIcon()` method. To add an icon to the "off" state, use the `offIcon()` method:

```php
use Filament\Forms\Components\Toggle;

Toggle::make('is_admin')
    ->onIcon('heroicon-m-bolt')
    ->offIcon('heroicon-m-user')
```

<AutoScreenshot name="forms/fields/toggle/icons" alt="Toggle icons" version="3.x" />

## Customizing the color of the toggle button

You may also customize the color representing the "on" or "off" state of the toggle. These may be either `danger`, `gray`, `info`, `primary`, `success` or `warning`. To add a color to the "on" state, use the `onColor()` method. To add a color to the "off" state, use the `offColor()` method:

```php
use Filament\Forms\Components\Toggle;

Toggle::make('is_admin')
    ->onColor('success')
    ->offColor('danger')
```

<AutoScreenshot name="forms/fields/toggle/off-color" alt="Toggle off color" version="3.x" />

<AutoScreenshot name="forms/fields/toggle/on-color" alt="Toggle on color" version="3.x" />

## Positioning the label above

Toggle fields have two layout modes, inline and stacked. By default, they are inline.

When the toggle is inline, its label is adjacent to it:

```php
use Filament\Forms\Components\Toggle;

Toggle::make('is_admin')
    ->inline()
```

<AutoScreenshot name="forms/fields/toggle/inline" alt="Toggle with its label inline" version="3.x" />

When the toggle is stacked, its label is above it:

```php
use Filament\Forms\Components\Toggle;

Toggle::make('is_admin')
    ->inline(false)
```

<AutoScreenshot name="forms/fields/toggle/not-inline" alt="Toggle with its label above" version="3.x" />

## Toggle validation

As well as all rules listed on the [validation](../validation) page, there are additional rules that are specific to toggles.

### Accepted validation

You may ensure that the toggle is "on" using the `accepted()` method:

```php
use Filament\Forms\Components\Toggle;

Toggle::make('terms_of_service')
    ->accepted()
```

### Declined validation

You may ensure that the toggle is "off" using the `declined()` method:

```php
use Filament\Forms\Components\Toggle;

Toggle::make('is_under_18')
    ->declined()
```

# Documentation for forms. File: 03-fields/06-checkbox-list.md
---
title: Checkbox list
---
import AutoScreenshot from "@components/AutoScreenshot.astro"
import LaracastsBanner from "@components/LaracastsBanner.astro"

## Overview

<LaracastsBanner
    title="Checkbox List"
    description="Watch the Rapid Laravel Development with Filament series on Laracasts - it will teach you the basics of adding checkbox list fields to Filament forms."
    url="https://laracasts.com/series/rapid-laravel-development-with-filament/episodes/5"
    series="rapid-laravel-development"
/>


The checkbox list component allows you to select multiple values from a list of predefined options:

```php
use Filament\Forms\Components\CheckboxList;

CheckboxList::make('technologies')
    ->options([
        'tailwind' => 'Tailwind CSS',
        'alpine' => 'Alpine.js',
        'laravel' => 'Laravel',
        'livewire' => 'Laravel Livewire',
    ])
```

<AutoScreenshot name="forms/fields/checkbox-list/simple" alt="Checkbox list" version="3.x" />

These options are returned in JSON format. If you're saving them using Eloquent, you should be sure to add an `array` [cast](https://laravel.com/docs/eloquent-mutators#array-and-json-casting) to the model property:

```php
use Illuminate\Database\Eloquent\Model;

class App extends Model
{
    protected $casts = [
        'technologies' => 'array',
    ];

    // ...
}
```

## Allowing HTML in the option labels

By default, Filament will escape any HTML in the option labels. If you'd like to allow HTML, you can use the `allowHtml()` method:

```php
use Filament\Forms\Components\CheckboxList;

CheckboxList::make('technology')
    ->options([
        'tailwind' => '<span class="text-blue-500">Tailwind</span>',
        'alpine' => '<span class="text-green-500">Alpine</span>',
        'laravel' => '<span class="text-red-500">Laravel</span>',
        'livewire' => '<span class="text-pink-500">Livewire</span>',
    ])
    ->searchable()
    ->allowHtml()
```

Be aware that you will need to ensure that the HTML is safe to render, otherwise your application will be vulnerable to XSS attacks.

## Setting option descriptions

You can optionally provide descriptions to each option using the `descriptions()` method. This method accepts an array of plain text strings, or instances of `Illuminate\Support\HtmlString` or `Illuminate\Contracts\Support\Htmlable`. This allows you to render HTML, or even markdown, in the descriptions:

```php
use Filament\Forms\Components\CheckboxList;
use Illuminate\Support\HtmlString;

CheckboxList::make('technologies')
    ->options([
        'tailwind' => 'Tailwind CSS',
        'alpine' => 'Alpine.js',
        'laravel' => 'Laravel',
        'livewire' => 'Laravel Livewire',
    ])
    ->descriptions([
        'tailwind' => 'A utility-first CSS framework for rapidly building modern websites without ever leaving your HTML.',
        'alpine' => new HtmlString('A rugged, minimal tool for composing behavior <strong>directly in your markup</strong>.'),
        'laravel' => str('A **web application** framework with expressive, elegant syntax.')->inlineMarkdown()->toHtmlString(),
        'livewire' => 'A full-stack framework for Laravel building dynamic interfaces simple, without leaving the comfort of Laravel.',
    ])
```

<AutoScreenshot name="forms/fields/checkbox-list/option-descriptions" alt="Checkbox list with option descriptions" version="3.x" />

Be sure to use the same `key` in the descriptions array as the `key` in the option array so the right description matches the right option.

## Splitting options into columns

You may split options into columns by using the `columns()` method:

```php
use Filament\Forms\Components\CheckboxList;

CheckboxList::make('technologies')
    ->options([
        // ...
    ])
    ->columns(2)
```

<AutoScreenshot name="forms/fields/checkbox-list/columns" alt="Checkbox list with 2 columns" version="3.x" />

This method accepts the same options as the `columns()` method of the [grid](layout/grid). This allows you to responsively customize the number of columns at various breakpoints.

### Setting the grid direction

By default, when you arrange checkboxes into columns, they will be listed in order vertically. If you'd like to list them horizontally, you may use the `gridDirection('row')` method:

```php
use Filament\Forms\Components\CheckboxList;

CheckboxList::make('technologies')
    ->options([
        // ...
    ])
    ->columns(2)
    ->gridDirection('row')
```

<AutoScreenshot name="forms/fields/checkbox-list/rows" alt="Checkbox list with 2 rows" version="3.x" />

## Disabling specific options

You can disable specific options using the `disableOptionWhen()` method. It accepts a closure, in which you can check if the option with a specific `$value` should be disabled:

```php
use Filament\Forms\Components\CheckboxList;

CheckboxList::make('technologies')
    ->options([
        'tailwind' => 'Tailwind CSS',
        'alpine' => 'Alpine.js',
        'laravel' => 'Laravel',
        'livewire' => 'Laravel Livewire',
    ])
    ->disableOptionWhen(fn (string $value): bool => $value === 'livewire')
```

If you want to retrieve the options that have not been disabled, e.g. for validation purposes, you can do so using `getEnabledOptions()`:

```php
use Filament\Forms\Components\CheckboxList;

CheckboxList::make('technologies')
    ->options([
        'tailwind' => 'Tailwind CSS',
        'alpine' => 'Alpine.js',
        'laravel' => 'Laravel',
        'livewire' => 'Laravel Livewire',
        'heroicons' => 'SVG icons',
    ])
    ->disableOptionWhen(fn (string $value): bool => $value === 'heroicons')
    ->in(fn (CheckboxList $component): array => array_keys($component->getEnabledOptions()))
```

## Searching options

You may enable a search input to allow easier access to many options, using the `searchable()` method:

```php
use Filament\Forms\Components\CheckboxList;

CheckboxList::make('technologies')
    ->options([
        // ...
    ])
    ->searchable()
```

<AutoScreenshot name="forms/fields/checkbox-list/searchable" alt="Searchable checkbox list" version="3.x" />

## Bulk toggling checkboxes

You may allow users to toggle all checkboxes at once using the `bulkToggleable()` method:

```php
use Filament\Forms\Components\CheckboxList;

CheckboxList::make('technologies')
    ->options([
        // ...
    ])
    ->bulkToggleable()
```

<AutoScreenshot name="forms/fields/checkbox-list/bulk-toggleable" alt="Bulk toggleable checkbox list" version="3.x" />

## Integrating with an Eloquent relationship

> If you're building a form inside your Livewire component, make sure you have set up the [form's model](../adding-a-form-to-a-livewire-component#setting-a-form-model). Otherwise, Filament doesn't know which model to use to retrieve the relationship from.

You may employ the `relationship()` method of the `CheckboxList` to point to a `BelongsToMany` relationship. Filament will load the options from the relationship, and save them back to the relationship's pivot table when the form is submitted. The `titleAttribute` is the name of a column that will be used to generate a label for each option:

```php
use Filament\Forms\Components\CheckboxList;

CheckboxList::make('technologies')
    ->relationship(titleAttribute: 'name')
```

When using `disabled()` with `relationship()`, ensure that `disabled()` is called before `relationship()`. This ensures that the `dehydrated()` call from within `relationship()` is not overridden by the call from `disabled()`:

```php
use Filament\Forms\Components\CheckboxList;

CheckboxList::make('technologies')
    ->disabled()
    ->relationship(titleAttribute: 'name')
```

### Customizing the relationship query

You may customize the database query that retrieves options using the `modifyOptionsQueryUsing` parameter of the `relationship()` method:

```php
use Filament\Forms\Components\CheckboxList;
use Illuminate\Database\Eloquent\Builder;

CheckboxList::make('technologies')
    ->relationship(
        titleAttribute: 'name',
        modifyQueryUsing: fn (Builder $query) => $query->withTrashed(),
    )
```

### Customizing the relationship option labels

If you'd like to customize the label of each option, maybe to be more descriptive, or to concatenate a first and last name, you could use a virtual column in your database migration:

```php
$table->string('full_name')->virtualAs('concat(first_name, \' \', last_name)');
```

```php
use Filament\Forms\Components\CheckboxList;

CheckboxList::make('authors')
    ->relationship(titleAttribute: 'full_name')
```

Alternatively, you can use the `getOptionLabelFromRecordUsing()` method to transform an option's Eloquent model into a label:

```php
use Filament\Forms\Components\CheckboxList;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;

CheckboxList::make('authors')
    ->relationship(
        modifyQueryUsing: fn (Builder $query) => $query->orderBy('first_name')->orderBy('last_name'),
    )
    ->getOptionLabelFromRecordUsing(fn (Model $record) => "{$record->first_name} {$record->last_name}")
```

### Saving pivot data to the relationship

If your pivot table has additional columns, you can use the `pivotData()` method to specify the data that should be saved in them:

```php
use Filament\Forms\Components\CheckboxList;

CheckboxList::make('primaryTechnologies')
    ->relationship(name: 'technologies', titleAttribute: 'name')
    ->pivotData([
        'is_primary' => true,
    ])
```

## Setting a custom no search results message

When you're using a searchable checkbox list, you may want to display a custom message when no search results are found. You can do this using the `noSearchResultsMessage()` method:

```php
use Filament\Forms\Components\CheckboxList;

CheckboxList::make('technologies')
    ->options([
        // ...
    ])
    ->searchable()
    ->noSearchResultsMessage('No technologies found.')
```

## Setting a custom search prompt

When you're using a searchable checkbox list, you may want to tweak the search input's placeholder when the user has not yet entered a search term. You can do this using the `searchPrompt()` method:

```php
use Filament\Forms\Components\CheckboxList;

CheckboxList::make('technologies')
    ->options([
        // ...
    ])
    ->searchable()
    ->searchPrompt('Search for a technology')
```

## Tweaking the search debounce

By default, Filament will wait 1000 milliseconds (1 second) before searching for options when the user types in a searchable checkbox list. It will also wait 1000 milliseconds between searches if the user is continuously typing into the search input. You can change this using the `searchDebounce()` method:

```php
use Filament\Forms\Components\CheckboxList;

CheckboxList::make('technologies')
    ->options([
        // ...
    ])
    ->searchable()
    ->searchDebounce(500)
```

## Customizing the checkbox list action objects

This field uses action objects for easy customization of buttons within it. You can customize these buttons by passing a function to an action registration method. The function has access to the `$action` object, which you can use to [customize it](../../actions/trigger-button). The following methods are available to customize the actions:

- `selectAllAction()`
- `deselectAllAction()`

Here is an example of how you might customize an action:

```php
use Filament\Forms\Components\Actions\Action;
use Filament\Forms\Components\CheckboxList;

CheckboxList::make('technologies')
    ->options([
        // ...
    ])
    ->selectAllAction(
        fn (Action $action) => $action->label('Select all technologies'),
    )
```

# Documentation for forms. File: 03-fields/07-radio.md
---
title: Radio
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Overview

The radio input provides a radio button group for selecting a single value from a list of predefined options:

```php
use Filament\Forms\Components\Radio;

Radio::make('status')
    ->options([
        'draft' => 'Draft',
        'scheduled' => 'Scheduled',
        'published' => 'Published'
    ])
```

<AutoScreenshot name="forms/fields/radio/simple" alt="Radio" version="3.x" />

## Setting option descriptions

You can optionally provide descriptions to each option using the `descriptions()` method:

```php
use Filament\Forms\Components\Radio;

Radio::make('status')
    ->options([
        'draft' => 'Draft',
        'scheduled' => 'Scheduled',
        'published' => 'Published'
    ])
    ->descriptions([
        'draft' => 'Is not visible.',
        'scheduled' => 'Will be visible.',
        'published' => 'Is visible.'
    ])
```

<AutoScreenshot name="forms/fields/radio/option-descriptions" alt="Radio with option descriptions" version="3.x" />

Be sure to use the same `key` in the descriptions array as the `key` in the option array so the right description matches the right option.

## Boolean options

If you want a simple boolean radio button group, with "Yes" and "No" options, you can use the `boolean()` method:

```php
Radio::make('feedback')
    ->label('Like this post?')
    ->boolean()
```

<AutoScreenshot name="forms/fields/radio/boolean" alt="Boolean radio" version="3.x" />

## Positioning the options inline with the label

You may wish to display the options `inline()` with the label instead of below it:

```php
Radio::make('feedback')
    ->label('Like this post?')
    ->boolean()
    ->inline()
```

<AutoScreenshot name="forms/fields/radio/inline" alt="Inline radio" version="3.x" />

## Positioning the options inline with each other but below the label

You may wish to display the options `inline()` with each other but below the label:

```php
Radio::make('feedback')
    ->label('Like this post?')
    ->boolean()
    ->inline()
    ->inlineLabel(false)
```

<AutoScreenshot name="forms/fields/radio/inline-under-label" alt="Inline radio under label" version="3.x" />

## Disabling specific options

You can disable specific options using the `disableOptionWhen()` method. It accepts a closure, in which you can check if the option with a specific `$value` should be disabled:

```php
use Filament\Forms\Components\Radio;

Radio::make('status')
    ->options([
        'draft' => 'Draft',
        'scheduled' => 'Scheduled',
        'published' => 'Published',
    ])
    ->disableOptionWhen(fn (string $value): bool => $value === 'published')
```

<AutoScreenshot name="forms/fields/radio/disabled-option" alt="Radio with disabled option" version="3.x" />

If you want to retrieve the options that have not been disabled, e.g. for validation purposes, you can do so using `getEnabledOptions()`:

```php
use Filament\Forms\Components\Radio;

Radio::make('status')
    ->options([
        'draft' => 'Draft',
        'scheduled' => 'Scheduled',
        'published' => 'Published',
    ])
    ->disableOptionWhen(fn (string $value): bool => $value === 'published')
    ->in(fn (Radio $component): array => array_keys($component->getEnabledOptions()))
```

# Documentation for forms. File: 03-fields/08-date-time-picker.md
---
title: Date-time picker
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Overview

The date-time picker provides an interactive interface for selecting a date and/or a time.

```php
use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\TimePicker;

DateTimePicker::make('published_at')
DatePicker::make('date_of_birth')
TimePicker::make('alarm_at')
```

<AutoScreenshot name="forms/fields/date-time-picker/simple" alt="Date time pickers" version="3.x" />

## Customizing the storage format

You may customize the format of the field when it is saved in your database, using the `format()` method. This accepts a string date format, using [PHP date formatting tokens](https://www.php.net/manual/en/datetime.format.php):

```php
use Filament\Forms\Components\DatePicker;

DatePicker::make('date_of_birth')
    ->format('d/m/Y')
```

## Disabling the seconds input

When using the time picker, you may disable the seconds input using the `seconds(false)` method:

```php
use Filament\Forms\Components\DateTimePicker;

DateTimePicker::make('published_at')
    ->seconds(false)
```

<AutoScreenshot name="forms/fields/date-time-picker/without-seconds" alt="Date time picker without seconds" version="3.x" />

## Timezones

If you'd like users to be able to manage dates in their own timezone, you can use the `timezone()` method:

```php
use Filament\Forms\Components\DateTimePicker;

DateTimePicker::make('published_at')
    ->timezone('America/New_York')
```

While dates will still be stored using the app's configured timezone, the date will now load in the new timezone, and it will be converted back when the form is saved.

## Enabling the JavaScript date picker

By default, Filament uses the native HTML5 date picker. You may enable a more customizable JavaScript date picker using the `native(false)` method:

```php
use Filament\Forms\Components\DatePicker;

DatePicker::make('date_of_birth')
    ->native(false)
```

<AutoScreenshot name="forms/fields/date-time-picker/javascript" alt="JavaScript-based date time picker" version="3.x" />

Please be aware that while being accessible, the JavaScript date picker does not support full keyboard input in the same way that the native date picker does. If you require full keyboard input, you should use the native date picker.

### Customizing the display format

You may customize the display format of the field, separately from the format used when it is saved in your database. For this, use the `displayFormat()` method, which also accepts a string date format, using [PHP date formatting tokens](https://www.php.net/manual/en/datetime.format.php):

```php
use Filament\Forms\Components\DatePicker;

DatePicker::make('date_of_birth')
    ->native(false)
    ->displayFormat('d/m/Y')
```

<AutoScreenshot name="forms/fields/date-time-picker/display-format" alt="Date time picker with custom display format" version="3.x" />

You may also configure the locale that is used when rendering the display, if you want to use different locale from your app config. For this, you can use the `locale()` method:

```php
use Filament\Forms\Components\DatePicker;

DatePicker::make('date_of_birth')
    ->native(false)
    ->displayFormat('d F Y')
    ->locale('fr')
```

### Configuring the time input intervals

You may customize the input interval for increasing/decreasing the hours/minutes /seconds using the `hoursStep()` , `minutesStep()` or `secondsStep()` methods:

```php
use Filament\Forms\Components\DateTimePicker;

DateTimePicker::make('published_at')
    ->native(false)
    ->hoursStep(2)
    ->minutesStep(15)
    ->secondsStep(10)
```

### Configuring the first day of the week

In some countries, the first day of the week is not Monday. To customize the first day of the week in the date picker, use the `firstDayOfWeek()` method on the component. 0 to 7 are accepted values, with Monday as 1 and Sunday as 7 or 0:

```php
use Filament\Forms\Components\DateTimePicker;

DateTimePicker::make('published_at')
    ->native(false)
    ->firstDayOfWeek(7)
```

<AutoScreenshot name="forms/fields/date-time-picker/week-starts-on-sunday" alt="Date time picker where the week starts on Sunday" version="3.x" />

There are additionally convenient helper methods to set the first day of the week more semantically:

```php
use Filament\Forms\Components\DateTimePicker;

DateTimePicker::make('published_at')
    ->native(false)
    ->weekStartsOnMonday()

DateTimePicker::make('published_at')
    ->native(false)
    ->weekStartsOnSunday()
```

### Disabling specific dates

To prevent specific dates from being selected:

```php
use Filament\Forms\Components\DateTimePicker;

DateTimePicker::make('date')
    ->native(false)
    ->disabledDates(['2000-01-03', '2000-01-15', '2000-01-20'])
```

<AutoScreenshot name="forms/fields/date-time-picker/disabled-dates" alt="Date time picker where dates are disabled" version="3.x" />

### Closing the picker when a date is selected

To close the picker when a date is selected, you can use the `closeOnDateSelection()` method:

```php
use Filament\Forms\Components\DateTimePicker;

DateTimePicker::make('date')
    ->native(false)
    ->closeOnDateSelection()
```

## Autocompleting dates with a datalist

Unless you're using the [JavaScript date picker](#enabling-the-javascript-date-picker), you may specify [datalist](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/datalist) options for a date picker using the `datalist()` method:

```php
use Filament\Forms\Components\TimePicker;

TimePicker::make('appointment_at')
    ->datalist([
        '09:00',
        '09:30',
        '10:00',
        '10:30',
        '11:00',
        '11:30',
        '12:00',
    ])
```

Datalists provide autocomplete options to users when they use the picker. However, these are purely recommendations, and the user is still able to type any value into the input. If you're looking to strictly limit users to a set of predefined options, check out the [select field](select).

## Adding affix text aside the field

You may place text before and after the input using the `prefix()` and `suffix()` methods:

```php
use Filament\Forms\Components\DatePicker;

DatePicker::make('date')
    ->prefix('Starts')
    ->suffix('at midnight')
```

<AutoScreenshot name="forms/fields/date-time-picker/affix" alt="Date time picker with affixes" version="3.x" />

### Using icons as affixes

You may place an [icon](https://blade-ui-kit.com/blade-icons?set=1#search) before and after the input using the `prefixIcon()` and `suffixIcon()` methods:

```php
use Filament\Forms\Components\TimePicker;

TimePicker::make('at')
    ->prefixIcon('heroicon-m-play')
```

<AutoScreenshot name="forms/fields/date-time-picker/prefix-icon" alt="Date time picker with prefix icon" version="3.x" />

#### Setting the affix icon's color

Affix icons are gray by default, but you may set a different color using the `prefixIconColor()` and `suffixIconColor()` methods:

```php
use Filament\Forms\Components\TimePicker;

TimePicker::make('at')
    ->prefixIcon('heroicon-m-check-circle')
    ->prefixIconColor('success')
```

## Making the field read-only

Not to be confused with [disabling the field](getting-started#disabling-a-field), you may make the field "read-only" using the `readonly()` method:

```php
use Filament\Forms\Components\DatePicker;

DatePicker::make('date_of_birth')
    ->readonly()
```

Please note that this setting is only enforced on native date pickers. If you're using the [JavaScript date picker](#enabling-the-javascript-date-picker), you'll need to use [`disabled()`](getting-started#disabling-a-field).

There are a few differences, compared to [`disabled()`](getting-started#disabling-a-field):

- When using `readOnly()`, the field will still be sent to the server when the form is submitted. It can be mutated with the browser console, or via JavaScript. You can use [`dehydrated(false)`](advanced#preventing-a-field-from-being-dehydrated) to prevent this.
- There are no styling changes, such as less opacity, when using `readOnly()`.
- The field is still focusable when using `readOnly()`.

## Date-time picker validation

As well as all rules listed on the [validation](../validation) page, there are additional rules that are specific to date-time pickers.

### Max date / min date validation

You may restrict the minimum and maximum date that can be selected with the picker. The `minDate()` and `maxDate()` methods accept a `DateTime` instance (e.g. `Carbon`), or a string:

```php
use Filament\Forms\Components\DatePicker;

DatePicker::make('date_of_birth')
    ->native(false)
    ->minDate(now()->subYears(150))
    ->maxDate(now())
```

# Documentation for forms. File: 03-fields/09-file-upload.md
---
title: File upload
---
import AutoScreenshot from "@components/AutoScreenshot.astro"
import LaracastsBanner from "@components/LaracastsBanner.astro"

## Overview

<LaracastsBanner
    title="File Uploads"
    description="Watch the Rapid Laravel Development with Filament series on Laracasts - it will teach you the basics of adding file upload fields to Filament forms."
    url="https://laracasts.com/series/rapid-laravel-development-with-filament/episodes/8"
    series="rapid-laravel-development"
/>

The file upload field is based on [Filepond](https://pqina.nl/filepond).

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('attachment')
```

<AutoScreenshot name="forms/fields/file-upload/simple" alt="File upload" version="3.x" />

> Filament also supports [`spatie/laravel-medialibrary`](https://github.com/spatie/laravel-medialibrary). See our [plugin documentation](/plugins/filament-spatie-media-library) for more information.

## Configuring the storage disk and directory

By default, files will be uploaded publicly to your storage disk defined in the [configuration file](../installation#publishing-configuration). You can also set the `FILAMENT_FILESYSTEM_DISK` environment variable to change this.

> To correctly preview images and other files, FilePond requires files to be served from the same domain as the app, or the appropriate CORS headers need to be present. Ensure that the `APP_URL` environment variable is correct, or modify the [filesystem](https://laravel.com/docs/filesystem) driver to set the correct URL. If you're hosting files on a separate domain like S3, ensure that CORS headers are set up.

To change the disk and directory for a specific field, and the visibility of files, use the `disk()`, `directory()` and `visibility()` methods:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('attachment')
    ->disk('s3')
    ->directory('form-attachments')
    ->visibility('private')
```

> It is the responsibility of the developer to delete these files from the disk if they are removed, as Filament is unaware if they are depended on elsewhere. One way to do this automatically is observing a [model event](https://laravel.com/docs/eloquent#events).

## Uploading multiple files

You may also upload multiple files. This stores URLs in JSON:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('attachments')
    ->multiple()
```

If you're saving the file URLs using Eloquent, you should be sure to add an `array` [cast](https://laravel.com/docs/eloquent-mutators#array-and-json-casting) to the model property:

```php
use Illuminate\Database\Eloquent\Model;

class Message extends Model
{
    protected $casts = [
        'attachments' => 'array',
    ];

    // ...
}
```

### Controlling the maximum parallel uploads

You can control the maximum number of parallel uploads using the `maxParallelUploads()` method:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('attachments')
    ->multiple()
    ->maxParallelUploads(1)
```

This will limit the number of parallel uploads to `1`. If unset, we'll use the [default FilePond value](https://pqina.nl/filepond/docs/api/instance/properties/#core-properties) which is `2`.

## Controlling file names

By default, a random file name will be generated for newly-uploaded files. This is to ensure that there are never any conflicts with existing files.

### Security implications of controlling file names

Before using the `preserveFilenames()` or `getUploadedFileNameForStorageUsing()` methods, please be aware of the security implications. If you allow users to upload files with their own file names, there are ways that they can exploit this to upload malicious files. **This applies even if you use the [`acceptedFileTypes()`](#file-type-validation) method** to restrict the types of files that can be uploaded, since it uses Laravel's `mimetypes` rule which does not validate the extension of the file, only its mime type, which could be manipulated.

This is specifically an issue with the `getClientOriginalName()` method on the `TemporaryUploadedFile` object, which the `preserveFilenames()` method uses. By default, Livewire generates a random file name for each file uploaded, and uses the mime type of the file to determine the file extension.

Using these methods **with the `local` or `public` filesystem disks** will make your app vulnerable to remote code execution if the attacker uploads a PHP file with a deceptive mime type. **Using an S3 disk protects you from this specific attack vector**, as S3 will not execute PHP files in the same way that your server might when serving files from local storage.

If you are using the `local` or `public` disk, you should consider using the [`storeFileNamesIn()` method](#storing-original-file-names-independently) to store the original file names in a separate column in your database, and keep the randomly generated file names in the file system. This way, you can still display the original file names to users, while keeping the file system secure.

On top of this security issue, you should also be aware that allowing users to upload files with their own file names can lead to conflicts with existing files, and can make it difficult to manage your storage. Users could upload files with the same name and overwrite the other's content if you do not scope them to a specific directory, so these features should in all cases only be accessible to trusted users.

### Preserving original file names

> Important: Before using this feature, please ensure that you have read the [security implications](#security-implications-of-controlling-file-names).

To preserve the original filenames of the uploaded files, use the `preserveFilenames()` method:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('attachment')
    ->preserveFilenames()
```

### Generating custom file names

> Important: Before using this feature, please ensure that you have read the [security implications](#security-implications-of-controlling-file-names).

You may completely customize how file names are generated using the `getUploadedFileNameForStorageUsing()` method, and returning a string from the closure based on the `$file` that was uploaded:

```php
use Livewire\Features\SupportFileUploads\TemporaryUploadedFile;

FileUpload::make('attachment')
    ->getUploadedFileNameForStorageUsing(
        fn (TemporaryUploadedFile $file): string => (string) str($file->getClientOriginalName())
            ->prepend('custom-prefix-'),
    )
```

### Storing original file names independently

You can keep the randomly generated file names, while still storing the original file name, using the `storeFileNamesIn()` method:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('attachments')
    ->multiple()
    ->storeFileNamesIn('attachment_file_names')
```

`attachment_file_names` will now store the original file names of your uploaded files, so you can save them to the database when the form is submitted. If you're uploading `multiple()` files, make sure that you add an `array` [cast](https://laravel.com/docs/eloquent-mutators#array-and-json-casting) to this Eloquent model property too.

## Avatar mode

You can enable avatar mode for your file upload field using the `avatar()` method:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('avatar')
    ->avatar()
```

This will only allow images to be uploaded, and when they are, it will display them in a compact circle layout that is perfect for avatars.

This feature pairs well with the [circle cropper](#allowing-users-to-crop-images-as-a-circle).

## Image editor

You can enable an image editor for your file upload field using the `imageEditor()` method:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('image')
    ->image()
    ->imageEditor()
```

You can open the editor once you upload an image by clicking the pencil icon. You can also open the editor by clicking the pencil icon on an existing image, which will remove and re-upload it on save.

### Allowing users to crop images to aspect ratios

You can allow users to crop images to a set of specific aspect ratios using the `imageEditorAspectRatios()` method:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('image')
    ->image()
    ->imageEditor()
    ->imageEditorAspectRatios([
        '16:9',
        '4:3',
        '1:1',
    ])
```

You can also allow users to choose no aspect ratio, "free cropping", by passing `null` as an option:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('image')
    ->image()
    ->imageEditor()
    ->imageEditorAspectRatios([
        null,
        '16:9',
        '4:3',
        '1:1',
    ])
```

### Setting the image editor's mode

You can change the mode of the image editor using the `imageEditorMode()` method, which accepts either `1`, `2` or `3`. These options are explained in the [Cropper.js documentation](https://github.com/fengyuanchen/cropperjs#viewmode):

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('image')
    ->image()
    ->imageEditor()
    ->imageEditorMode(2)
```

### Customizing the image editor's empty fill color

By default, the image editor will make the empty space around the image transparent. You can customize this using the `imageEditorEmptyFillColor()` method:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('image')
    ->image()
    ->imageEditor()
    ->imageEditorEmptyFillColor('#000000')
```

### Setting the image editor's viewport size

You can change the size of the image editor's viewport using the `imageEditorViewportWidth()` and `imageEditorViewportHeight()` methods, which generate an aspect ratio to use across device sizes:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('image')
    ->image()
    ->imageEditor()
    ->imageEditorViewportWidth('1920')
    ->imageEditorViewportHeight('1080')
```

### Allowing users to crop images as a circle

You can allow users to crop images as a circle using the `circleCropper()` method:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('image')
    ->image()
    ->avatar()
    ->imageEditor()
    ->circleCropper()
```

This is perfectly accompanied by the [`avatar()` method](#avatar-mode), which renders the images in a compact circle layout.

### Cropping and resizing images without the editor

Filepond allows you to crop and resize images before they are uploaded, without the need for a separate editor. You can customize this behavior using the `imageCropAspectRatio()`, `imageResizeTargetHeight()` and `imageResizeTargetWidth()` methods. `imageResizeMode()` should be set for these methods to have an effect - either [`force`, `cover`, or `contain`](https://pqina.nl/filepond/docs/api/plugins/image-resize).

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('image')
    ->image()
    ->imageResizeMode('cover')
    ->imageCropAspectRatio('16:9')
    ->imageResizeTargetWidth('1920')
    ->imageResizeTargetHeight('1080')
```

## Altering the appearance of the file upload area

You may also alter the general appearance of the Filepond component. Available options for these methods are available on the [Filepond website](https://pqina.nl/filepond/docs/api/instance/properties/#styles).

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('attachment')
    ->imagePreviewHeight('250')
    ->loadingIndicatorPosition('left')
    ->panelAspectRatio('2:1')
    ->panelLayout('integrated')
    ->removeUploadedFileButtonPosition('right')
    ->uploadButtonPosition('left')
    ->uploadProgressIndicatorPosition('left')
```

### Displaying files in a grid

You can use the [Filepond `grid` layout](https://pqina.nl/filepond/docs/api/style/#grid-layout) by setting the `panelLayout()`:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('attachments')
    ->multiple()
    ->panelLayout('grid')
```

## Reordering files

You can also allow users to re-order uploaded files using the `reorderable()` method:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('attachments')
    ->multiple()
    ->reorderable()
```

When using this method, FilePond may add newly-uploaded files to the beginning of the list, instead of the end. To fix this, use the `appendFiles()` method:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('attachments')
    ->multiple()
    ->reorderable()
    ->appendFiles()
```

## Opening files in a new tab

You can add a button to open each file in a new tab with the `openable()` method:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('attachments')
    ->multiple()
    ->openable()
```

## Downloading files

If you wish to add a download button to each file instead, you can use the `downloadable()` method:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('attachments')
    ->multiple()
    ->downloadable()
```

## Previewing files

By default, some file types can be previewed in FilePond. If you wish to disable the preview for all files, you can use the `previewable(false)` method:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('attachments')
    ->multiple()
    ->previewable(false)
```

## Moving files instead of copying when the form is submitted

By default, files are initially uploaded to Livewire's temporary storage directory, and then copied to the destination directory when the form is submitted. If you wish to move the files instead, providing that temporary uploads are stored on the same disk as permanent files, you can use the `moveFiles()` method:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('attachment')
    ->moveFiles()
```

## Preventing files from being stored permanently

If you wish to prevent files from being stored permanently when the form is submitted, you can use the `storeFiles(false)` method:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('attachment')
    ->storeFiles(false)
```

When the form is submitted, a temporary file upload object will be returned instead of a permanently stored file path. This is perfect for temporary files like imported CSVs.

Please be aware that images, video and audio files will not show the stored file name in the form's preview, unless you use [`previewable(false)`](#previewing-files). This is due to a limitation with the FilePond preview plugin.

## Orienting images from their EXIF data

By default, FilePond will automatically orient images based on their EXIF data. If you wish to disable this behavior, you can use the `orientImagesFromExif(false)` method:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('attachment')
    ->orientImagesFromExif(false)
```

## Hiding the remove file button

It is also possible to hide the remove uploaded file button by using `deletable(false)`:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('attachment')
    ->deletable(false)
```

## Prevent file information fetching

While the form is loaded, it will automatically detect whether the files exist, what size they are, and what type of files they are. This is all done on the backend. When using remote storage with many files, this can be time-consuming. You can use the `fetchFileInformation(false)` method to disable this feature:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('attachment')
    ->fetchFileInformation(false)
```

## Customizing the uploading message

You may customize the uploading message that is displayed in the form's submit button using the `uploadingMessage()` method:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('attachment')
    ->uploadingMessage('Uploading attachment...')
```

## File upload validation

As well as all rules listed on the [validation](../validation) page, there are additional rules that are specific to file uploads.

Since Filament is powered by Livewire and uses its file upload system, you will want to refer to the default Livewire file upload validation rules in the `config/livewire.php` file as well. This also controls the 12MB file size maximum.

### File type validation

You may restrict the types of files that may be uploaded using the `acceptedFileTypes()` method, and passing an array of MIME types.

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('document')
    ->acceptedFileTypes(['application/pdf'])
```

You may also use the `image()` method as shorthand to allow all image MIME types.

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('image')
    ->image()
```

#### Custom MIME type mapping

Some file formats may not be recognized correctly by the browser when uploading files. Filament allows you to manually define MIME types for specific file extensions using the `mimeTypeMap()` method:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('designs')
    ->acceptedFileTypes([
        'x-world/x-3dmf',
        'application/vnd.sketchup.skp',
    ])
    ->mimeTypeMap([
        '3dm' => 'x-world/x-3dmf',
        'skp' => 'application/vnd.sketchup.skp',
    ]);
```

### File size validation

You may also restrict the size of uploaded files in kilobytes:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('attachment')
    ->minSize(512)
    ->maxSize(1024)
```

#### Uploading large files

If you experience issues when uploading large files, such as HTTP requests failing with a response status of 422 in the browser's console, you may need to tweak your configuration.

In the `php.ini` file for your server, increasing the maximum file size may fix the issue:

```ini
post_max_size = 120M
upload_max_filesize = 120M
```

Livewire also validates file size before uploading. To publish the Livewire config file, run:

```bash
php artisan livewire:publish --config
```

The [max upload size can be adjusted in the `rules` key of `temporary_file_upload`]((https://livewire.laravel.com/docs/uploads#global-validation)). In this instance, KB are used in the rule, and 120MB is 122880KB:

```php
'temporary_file_upload' => [
    // ...
    'rules' => ['required', 'file', 'max:122880'],
    // ...
],
```

### Number of files validation

You may customize the number of files that may be uploaded, using the `minFiles()` and `maxFiles()` methods:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('attachments')
    ->multiple()
    ->minFiles(2)
    ->maxFiles(5)
```

# Documentation for forms. File: 03-fields/10-rich-editor.md
---
title: Rich editor
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Overview

The rich editor allows you to edit and preview HTML content, as well as upload images.

```php
use Filament\Forms\Components\RichEditor;

RichEditor::make('content')
```

<AutoScreenshot name="forms/fields/rich-editor/simple" alt="Rich editor" version="3.x" />

## Security

By default, the editor outputs raw HTML, and sends it to the backend. Attackers are able to intercept the value of the component and send a different raw HTML string to the backend. As such, it is important that when outputting the HTML from a rich editor, it is sanitized; otherwise your site may be exposed to Cross-Site Scripting (XSS) vulnerabilities.

When Filament outputs raw HTML from the database in components such as `TextColumn` and `TextEntry`, it sanitizes it to remove any dangerous JavaScript. However, if you are outputting the HTML from a rich editor in your own Blade view, this is your responsibility. One option is to use Filament's `sanitizeHtml()` helper to do this, which is the same tool we use to sanitize HTML in the components mentioned above:

```blade
{!! str($record->content)->sanitizeHtml() !!}
```

## Customizing the toolbar buttons

You may set the toolbar buttons for the editor using the `toolbarButtons()` method. The options shown here are the defaults. In addition to these, `'h1'` is also available:

```php
use Filament\Forms\Components\RichEditor;

RichEditor::make('content')
    ->toolbarButtons([
        'attachFiles',
        'blockquote',
        'bold',
        'bulletList',
        'codeBlock',
        'h2',
        'h3',
        'italic',
        'link',
        'orderedList',
        'redo',
        'strike',
        'underline',
        'undo',
    ])
```

Alternatively, you may disable specific buttons using the `disableToolbarButtons()` method:

```php
use Filament\Forms\Components\RichEditor;

RichEditor::make('content')
    ->disableToolbarButtons([
        'blockquote',
        'strike',
    ])
```

To disable all toolbar buttons, set an empty array with `toolbarButtons([])` or use `disableAllToolbarButtons()`.

## Uploading images to the editor

You may customize how images are uploaded using configuration methods:

```php
use Filament\Forms\Components\RichEditor;

RichEditor::make('content')
    ->fileAttachmentsDisk('s3')
    ->fileAttachmentsDirectory('attachments')
    ->fileAttachmentsVisibility('private')
```

## Disabling Grammarly checks

If the user has Grammarly installed and you would like to prevent it from analyzing the contents of the editor, you can use the `disableGrammarly()` method:

```php
use Filament\Forms\Components\RichEditor;

RichEditor::make('content')
    ->disableGrammarly()
```

# Documentation for forms. File: 03-fields/11-markdown-editor.md
---
title: Markdown editor
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Overview

The markdown editor allows you to edit and preview markdown content, as well as upload images using drag and drop.

```php
use Filament\Forms\Components\MarkdownEditor;

MarkdownEditor::make('content')
```

<AutoScreenshot name="forms/fields/markdown-editor/simple" alt="Markdown editor" version="3.x" />

## Security

By default, the editor outputs raw Markdown and HTML, and sends it to the backend. Attackers are able to intercept the value of the component and send a different raw HTML string to the backend. As such, it is important that when outputting the HTML from a Markdown editor, it is sanitized; otherwise your site may be exposed to Cross-Site Scripting (XSS) vulnerabilities.

When Filament outputs raw HTML from the database in components such as `TextColumn` and `TextEntry`, it sanitizes it to remove any dangerous JavaScript. However, if you are outputting the HTML from a Markdown editor in your own Blade view, this is your responsibility. One option is to use Filament's `sanitizeHtml()` helper to do this, which is the same tool we use to sanitize HTML in the components mentioned above:

```blade
{!! str($record->content)->markdown()->sanitizeHtml() !!}
```

## Customizing the toolbar buttons

You may set the toolbar buttons for the editor using the `toolbarButtons()` method. The options shown here are the defaults:

```php
use Filament\Forms\Components\MarkdownEditor;

MarkdownEditor::make('content')
    ->toolbarButtons([
        'attachFiles',
        'blockquote',
        'bold',
        'bulletList',
        'codeBlock',
        'heading',
        'italic',
        'link',
        'orderedList',
        'redo',
        'strike',
        'table',
        'undo',
    ])
```

Alternatively, you may disable specific buttons using the `disableToolbarButtons()` method:

```php
use Filament\Forms\Components\MarkdownEditor;

MarkdownEditor::make('content')
    ->disableToolbarButtons([
        'blockquote',
        'strike',
    ])
```

To disable all toolbar buttons, set an empty array with `toolbarButtons([])` or use `disableAllToolbarButtons()`.

## Uploading images to the editor

You may customize how images are uploaded using configuration methods:

```php
use Filament\Forms\Components\MarkdownEditor;

MarkdownEditor::make('content')
    ->fileAttachmentsDisk('s3')
    ->fileAttachmentsDirectory('attachments')
    ->fileAttachmentsVisibility('private')
```

# Documentation for forms. File: 03-fields/12-repeater.md
---
title: Repeater
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Overview

The repeater component allows you to output a JSON array of repeated form components.

```php
use Filament\Forms\Components\Repeater;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;

Repeater::make('members')
    ->schema([
        TextInput::make('name')->required(),
        Select::make('role')
            ->options([
                'member' => 'Member',
                'administrator' => 'Administrator',
                'owner' => 'Owner',
            ])
            ->required(),
    ])
    ->columns(2)
```

<AutoScreenshot name="forms/fields/repeater/simple" alt="Repeater" version="3.x" />

We recommend that you store repeater data with a `JSON` column in your database. Additionally, if you're using Eloquent, make sure that column has an `array` cast.

As evident in the above example, the component schema can be defined within the `schema()` method of the component:

```php
use Filament\Forms\Components\Repeater;
use Filament\Forms\Components\TextInput;

Repeater::make('members')
    ->schema([
        TextInput::make('name')->required(),
        // ...
    ])
```

If you wish to define a repeater with multiple schema blocks that can be repeated in any order, please use the [builder](builder).

## Setting empty default items

Repeaters may have a certain number of empty items created by default, using the `defaultItems()` method:

```php
use Filament\Forms\Components\Repeater;

Repeater::make('members')
    ->schema([
        // ...
    ])
    ->defaultItems(3)
```

Note that these default items are only created when the form is loaded without existing data. Inside [panel resources](../../panels/resources#resource-forms) this only works on Create Pages, as Edit Pages will always fill the data from the model.

## Adding items

An action button is displayed below the repeater to allow the user to add a new item.

## Setting the add action button's label

You may set a label to customize the text that should be displayed in the button for adding a repeater item, using the `addActionLabel()` method:

```php
use Filament\Forms\Components\Repeater;

Repeater::make('members')
    ->schema([
        // ...
    ])
    ->addActionLabel('Add member')
```

### Aligning the add action button

By default, the add action is aligned in the center. You may adjust this using the `addActionAlignment()` method, passing an `Alignment` option of `Alignment::Start` or `Alignment::End`:

```php
use Filament\Forms\Components\Repeater;
use Filament\Support\Enums\Alignment;

Repeater::make('members')
    ->schema([
        // ...
    ])
    ->addActionAlignment(Alignment::Start)
```

### Preventing the user from adding items

You may prevent the user from adding items to the repeater using the `addable(false)` method:

```php
use Filament\Forms\Components\Repeater;

Repeater::make('members')
    ->schema([
        // ...
    ])
    ->addable(false)
```

## Deleting items

An action button is displayed on each item to allow the user to delete it.

### Preventing the user from deleting items

You may prevent the user from deleting items from the repeater using the `deletable(false)` method:

```php
use Filament\Forms\Components\Repeater;

Repeater::make('members')
    ->schema([
        // ...
    ])
    ->deletable(false)
```

## Reordering items

A button is displayed on each item to allow the user to drag and drop to reorder it in the list.

### Preventing the user from reordering items

You may prevent the user from reordering items from the repeater using the `reorderable(false)` method:

```php
use Filament\Forms\Components\Repeater;

Repeater::make('members')
    ->schema([
        // ...
    ])
    ->reorderable(false)
```

### Reordering items with buttons

You may use the `reorderableWithButtons()` method to enable reordering items with buttons to move the item up and down:

```php
use Filament\Forms\Components\Repeater;

Repeater::make('members')
    ->schema([
        // ...
    ])
    ->reorderableWithButtons()
```

<AutoScreenshot name="forms/fields/repeater/reorderable-with-buttons" alt="Repeater that is reorderable with buttons" version="3.x" />

### Preventing reordering with drag and drop

You may use the `reorderableWithDragAndDrop(false)` method to prevent items from being ordered with drag and drop:

```php
use Filament\Forms\Components\Repeater;

Repeater::make('members')
    ->schema([
        // ...
    ])
    ->reorderableWithDragAndDrop(false)
```

## Collapsing items

The repeater may be `collapsible()` to optionally hide content in long forms:

```php
use Filament\Forms\Components\Repeater;

Repeater::make('qualifications')
    ->schema([
        // ...
    ])
    ->collapsible()
```

You may also collapse all items by default:

```php
use Filament\Forms\Components\Repeater;

Repeater::make('qualifications')
    ->schema([
        // ...
    ])
    ->collapsed()
```

<AutoScreenshot name="forms/fields/repeater/collapsed" alt="Collapsed repeater" version="3.x" />

## Cloning items

You may allow repeater items to be duplicated using the `cloneable()` method:

```php
use Filament\Forms\Components\Repeater;

Repeater::make('qualifications')
    ->schema([
        // ...
    ])
    ->cloneable()
```

<AutoScreenshot name="forms/fields/repeater/cloneable" alt="Cloneable repeater" version="3.x" />

## Integrating with an Eloquent relationship

> If you're building a form inside your Livewire component, make sure you have set up the [form's model](../adding-a-form-to-a-livewire-component#setting-a-form-model). Otherwise, Filament doesn't know which model to use to retrieve the relationship from.

You may employ the `relationship()` method of the `Repeater` to configure a `HasMany` relationship. Filament will load the item data from the relationship, and save it back to the relationship when the form is submitted. If a custom relationship name is not passed to `relationship()`, Filament will use the field name as the relationship name:

```php
use Filament\Forms\Components\Repeater;

Repeater::make('qualifications')
    ->relationship()
    ->schema([
        // ...
    ])
```

When using `disabled()` with `relationship()`, ensure that `disabled()` is called before `relationship()`. This ensures that the `dehydrated()` call from within `relationship()` is not overridden by the call from `disabled()`:

```php
use Filament\Forms\Components\Repeater;

Repeater::make('qualifications')
    ->disabled()
    ->relationship()
    ->schema([
        // ...
    ])
```

### Reordering items in a relationship

By default, [reordering](#reordering-items) relationship repeater items is disabled. This is because your related model needs a `sort` column to store the order of related records. To enable reordering, you may use the `orderColumn()` method, passing in a name of the column on your related model to store the order in:

```php
use Filament\Forms\Components\Repeater;

Repeater::make('qualifications')
    ->relationship()
    ->schema([
        // ...
    ])
    ->orderColumn('sort')
```

If you use something like [`spatie/eloquent-sortable`](https://github.com/spatie/eloquent-sortable) with an order column such as `order_column`, you may pass this in to `orderColumn()`:

```php
use Filament\Forms\Components\Repeater;

Repeater::make('qualifications')
    ->relationship()
    ->schema([
        // ...
    ])
    ->orderColumn('order_column')
```

### Integrating with a `BelongsToMany` Eloquent relationship

There is a common misconception that using a `BelongsToMany` relationship with a repeater is as simple as using a `HasMany` relationship. This is not the case, as a `BelongsToMany` relationship requires a pivot table to store the relationship data. The repeater saves its data to the related model, not the pivot table. Therefore, if you want to map each repeater item to a row in the pivot table, you must use a `HasMany` relationship with a pivot model to use a repeater with a `BelongsToMany` relationship.

Imagine you have a form to create a new `Order` model. Each order belongs to many `Product` models, and each product belongs to many orders. You have a `order_product` pivot table to store the relationship data. Instead of using the `products` relationship with the repeater, you should create a new relationship called `orderProducts` on the `Order` model, and use that with the repeater:

```php
use Illuminate\Database\Eloquent\Relations\HasMany;

public function orderProducts(): HasMany
{
    return $this->hasMany(OrderProduct::class);
}
```

If you don't already have an `OrderProduct` pivot model, you should create that, with inverse relationships to `Order` and `Product`:

```php
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\Pivot;

class OrderProduct extends Pivot
{
    public $incrementing = true;

    public function order(): BelongsTo
    {
        return $this->belongsTo(Order::class);
    }

    public function product(): BelongsTo
    {
        return $this->belongsTo(Product::class);
    }
}
```

> Please ensure that your pivot model has a primary key column, like `id`, to allow Filament to keep track of which repeater items have been created, updated and deleted. To make sure that Filament keeps track of the primary key, the pivot model needs to have the `$incrementing` property set to `true`.

Now you can use the `orderProducts` relationship with the repeater, and it will save the data to the `order_product` pivot table:

```php
use Filament\Forms\Components\Repeater;
use Filament\Forms\Components\Select;

Repeater::make('orderProducts')
    ->relationship()
    ->schema([
        Select::make('product_id')
            ->relationship('product', 'name')
            ->required(),
        // ...
    ])
```

### Mutating related item data before filling the field

You may mutate the data for a related item before it is filled into the field using the `mutateRelationshipDataBeforeFillUsing()` method. This method accepts a closure that receives the current item's data in a `$data` variable. You must return the modified array of data:

```php
use Filament\Forms\Components\Repeater;

Repeater::make('qualifications')
    ->relationship()
    ->schema([
        // ...
    ])
    ->mutateRelationshipDataBeforeFillUsing(function (array $data): array {
        $data['user_id'] = auth()->id();

        return $data;
    })
```

### Mutating related item data before creating

You may mutate the data for a new related item before it is created in the database using the `mutateRelationshipDataBeforeCreateUsing()` method. This method accepts a closure that receives the current item's data in a `$data` variable. You can choose to return either the modified array of data, or `null` to prevent the item from being created:

```php
use Filament\Forms\Components\Repeater;

Repeater::make('qualifications')
    ->relationship()
    ->schema([
        // ...
    ])
    ->mutateRelationshipDataBeforeCreateUsing(function (array $data): array {
        $data['user_id'] = auth()->id();

        return $data;
    })
```

### Mutating related item data before saving

You may mutate the data for an existing related item before it is saved in the database using the `mutateRelationshipDataBeforeSaveUsing()` method. This method accepts a closure that receives the current item's data in a `$data` variable. You can choose to return either the modified array of data, or `null` to prevent the item from being saved:

```php
use Filament\Forms\Components\Repeater;

Repeater::make('qualifications')
    ->relationship()
    ->schema([
        // ...
    ])
    ->mutateRelationshipDataBeforeSaveUsing(function (array $data): array {
        $data['user_id'] = auth()->id();

        return $data;
    })
```

## Grid layout

You may organize repeater items into columns by using the `grid()` method:

```php
use Filament\Forms\Components\Repeater;

Repeater::make('qualifications')
    ->schema([
        // ...
    ])
    ->grid(2)
```

<AutoScreenshot name="forms/fields/repeater/grid" alt="Repeater with a 2 column grid of items" version="3.x" />

This method accepts the same options as the `columns()` method of the [grid](../layout/grid). This allows you to responsively customize the number of grid columns at various breakpoints.

## Adding a label to repeater items based on their content

You may add a label for repeater items using the `itemLabel()` method. This method accepts a closure that receives the current item's data in a `$state` variable. You must return a string to be used as the item label:

```php
use Filament\Forms\Components\Repeater;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Select;

Repeater::make('members')
    ->schema([
        TextInput::make('name')
            ->required()
            ->live(onBlur: true),
        Select::make('role')
            ->options([
                'member' => 'Member',
                'administrator' => 'Administrator',
                'owner' => 'Owner',
            ])
            ->required(),
    ])
    ->columns(2)
    ->itemLabel(fn (array $state): ?string => $state['name'] ?? null),
```

Any fields that you use from `$state` should be `live()` if you wish to see the item label update live as you use the form.

<AutoScreenshot name="forms/fields/repeater/labelled" alt="Repeater with item labels" version="3.x" />

## Simple repeaters with one field

You can use the `simple()` method to create a repeater with a single field, using a minimal design

```php
use Filament\Forms\Components\Repeater;
use Filament\Forms\Components\TextInput;

Repeater::make('invitations')
    ->simple(
        TextInput::make('email')
            ->email()
            ->required(),
    )
```

<AutoScreenshot name="forms/fields/repeater/simple-one-field" alt="Simple repeater design with only one field" version="3.x" />

Instead of using a nested array to store data, simple repeaters use a flat array of values. This means that the data structure for the above example could look like this:

```php
[
    'invitations' => [
        'dan@filamentphp.com',
        'ryan@filamentphp.com',
    ],
],
```

## Using `$get()` to access parent field values

All form components are able to [use `$get()` and `$set()`](../advanced) to access another field's value. However, you might experience unexpected behavior when using this inside the repeater's schema.

This is because `$get()` and `$set()`, by default, are scoped to the current repeater item. This means that you are able to interact with another field inside that repeater item easily without knowing which repeater item the current form component belongs to.

The consequence of this is that you may be confused when you are unable to interact with a field outside the repeater. We use `../` syntax to solve this problem - `$get('../../parent_field_name')`.

Consider your form has this data structure:

```php
[
    'client_id' => 1,

    'repeater' => [
        'item1' => [
            'service_id' => 2,
        ],
    ],
]
```

You are trying to retrieve the value of `client_id` from inside the repeater item.

`$get()` is relative to the current repeater item, so `$get('client_id')` is looking for `$get('repeater.item1.client_id')`.

You can use `../` to go up a level in the data structure, so `$get('../client_id')` is `$get('repeater.client_id')` and `$get('../../client_id')` is `$get('client_id')`.

The special case of `$get()` with no arguments, or `$get('')` or `$get('./')`, will always return the full data array for the current repeater item.

## Repeater validation

As well as all rules listed on the [validation](../validation) page, there are additional rules that are specific to repeaters.

### Number of items validation

You can validate the minimum and maximum number of items that you can have in a repeater by setting the `minItems()` and `maxItems()` methods:

```php
use Filament\Forms\Components\Repeater;

Repeater::make('members')
    ->schema([
        // ...
    ])
    ->minItems(2)
    ->maxItems(5)
```

### Distinct state validation

In many cases, you will want to ensure some sort of uniqueness between repeater items. A couple of common examples could be:

- Ensuring that only one [checkbox](checkbox) or [toggle](toggle) is activated at once across items in the repeater.
- Ensuring that an option may only be selected once across [select](select), [radio](radio), [checkbox list](checkbox-list), or [toggle buttons](toggle-buttons) fields in a repeater.

You can use the `distinct()` method to validate that the state of a field is unique across all items in the repeater:

```php
use Filament\Forms\Components\Checkbox;
use Filament\Forms\Components\Repeater;

Repeater::make('answers')
    ->schema([
        // ...
        Checkbox::make('is_correct')
            ->distinct(),
    ])
```

The behavior of the `distinct()` validation depends on the data type that the field handles

- If the field returns a boolean, like a [checkbox](checkbox) or [toggle](toggle), the validation will ensure that only one item has a value of `true`. There may be many fields in the repeater that have a value of `false`.
- Otherwise, for fields like a [select](select), [radio](radio), [checkbox list](checkbox-list), or [toggle buttons](toggle-buttons), the validation will ensure that each option may only be selected once across all items in the repeater.

#### Automatically fixing indistinct state

If you'd like to automatically fix indistinct state, you can use the `fixIndistinctState()` method:

```php
use Filament\Forms\Components\Checkbox;
use Filament\Forms\Components\Repeater;

Repeater::make('answers')
    ->schema([
        // ...
        Checkbox::make('is_correct')
            ->fixIndistinctState(),
    ])
```

This method will automatically enable the `distinct()` and `live()` methods on the field.

Depending on the data type that the field handles, the behavior of the `fixIndistinctState()` adapts:

- If the field returns a boolean, like a [checkbox](checkbox) or [toggle](toggle), and one of the fields is enabled, Filament will automatically disable all other enabled fields on behalf of the user.
- Otherwise, for fields like a [select](select), [radio](radio), [checkbox list](checkbox-list), or [toggle buttons](toggle-buttons), when a user selects an option, Filament will automatically deselect all other usages of that option on behalf of the user.

#### Disabling options when they are already selected in another item

If you'd like to disable options in a [select](select), [radio](radio), [checkbox list](checkbox-list), or [toggle buttons](toggle-buttons) when they are already selected in another item, you can use the `disableOptionsWhenSelectedInSiblingRepeaterItems()` method:

```php
use Filament\Forms\Components\Repeater;
use Filament\Forms\Components\Select;

Repeater::make('members')
    ->schema([
        Select::make('role')
            ->options([
                // ...
            ])
            ->disableOptionsWhenSelectedInSiblingRepeaterItems(),
    ])
```

This method will automatically enable the `distinct()` and `live()` methods on the field.

In case you want to add another condition to [disable options](../select#disabling-specific-options) with, you can chain `disableOptionWhen()` with the `merge: true` argument:

```php
use Filament\Forms\Components\Repeater;
use Filament\Forms\Components\Select;

Repeater::make('members')
    ->schema([
        Select::make('role')
            ->options([
                // ...
            ])
            ->disableOptionsWhenSelectedInSiblingRepeaterItems()
            ->disableOptionWhen(fn (string $value): bool => $value === 'super_admin', merge: true),
    ])
```

## Customizing the repeater item actions

This field uses action objects for easy customization of buttons within it. You can customize these buttons by passing a function to an action registration method. The function has access to the `$action` object, which you can use to [customize it](../../actions/trigger-button). The following methods are available to customize the actions:

- `addAction()`
- `cloneAction()`
- `collapseAction()`
- `collapseAllAction()`
- `deleteAction()`
- `expandAction()`
- `expandAllAction()`
- `moveDownAction()`
- `moveUpAction()`
- `reorderAction()`

Here is an example of how you might customize an action:

```php
use Filament\Forms\Components\Actions\Action;
use Filament\Forms\Components\Repeater;

Repeater::make('members')
    ->schema([
        // ...
    ])
    ->collapseAllAction(
        fn (Action $action) => $action->label('Collapse all members'),
    )
```

### Confirming repeater actions with a modal

You can confirm actions with a modal by using the `requiresConfirmation()` method on the action object. You may use any [modal customization method](../../actions/modals) to change its content and behavior:

```php
use Filament\Forms\Components\Actions\Action;
use Filament\Forms\Components\Repeater;

Repeater::make('members')
    ->schema([
        // ...
    ])
    ->deleteAction(
        fn (Action $action) => $action->requiresConfirmation(),
    )
```

> The `collapseAction()`, `collapseAllAction()`, `expandAction()`, `expandAllAction()` and `reorderAction()` methods do not support confirmation modals, as clicking their buttons does not make the network request that is required to show the modal.

### Adding extra item actions to a repeater

You may add new [action buttons](../actions) to the header of each repeater item by passing `Action` objects into `extraItemActions()`:

```php
use Filament\Forms\Components\Actions\Action;
use Filament\Forms\Components\Repeater;
use Filament\Forms\Components\TextInput;
use Illuminate\Support\Facades\Mail;

Repeater::make('members')
    ->schema([
        TextInput::make('email')
            ->label('Email address')
            ->email(),
        // ...
    ])
    ->extraItemActions([
        Action::make('sendEmail')
            ->icon('heroicon-m-envelope')
            ->action(function (array $arguments, Repeater $component): void {
                $itemData = $component->getItemState($arguments['item']);

                Mail::to($itemData['email'])
                    ->send(
                        // ...
                    );
            }),
    ])
```

In this example, `$arguments['item']` gives you the ID of the current repeater item. You can validate the data in that repeater item using the `getItemState()` method on the repeater component. This method returns the validated data for the item. If the item is not valid, it will cancel the action and show an error message for that item in the form.

If you want to get the raw data from the current item without validating it, you can use `$component->getRawItemState($arguments['item'])` instead.

If you want to manipulate the raw data for the entire repeater, for example, to add, remove or modify items, you can use `$component->getState()` to get the data, and `$component->state($state)` to set it again:

```php
use Illuminate\Support\Str;

// Get the raw data for the entire repeater
$state = $component->getState();

// Add an item, with a random UUID as the key
$state[Str::uuid()] = [
    'email' => auth()->user()->email,
];

// Set the new data for the repeater
$component->state($state);
```

## Testing repeaters

Internally, repeaters generate UUIDs for items to keep track of them in the Livewire HTML easier. This means that when you are testing a form with a repeater, you need to ensure that the UUIDs are consistent between the form and the test. This can be tricky, and if you don't do it correctly, your tests can fail as the tests are expecting a UUID, not a numeric key.

However, since Livewire doesn't need to keep track of the UUIDs in a test, you can disable the UUID generation and replace them with numeric keys, using the `Repeater::fake()` method at the start of your test:

```php
use Filament\Forms\Components\Repeater;
use function Pest\Livewire\livewire;

$undoRepeaterFake = Repeater::fake();

livewire(EditPost::class, ['record' => $post])
    ->assertFormSet([
        'quotes' => [
            [
                'content' => 'First quote',
            ],
            [
                'content' => 'Second quote',
            ],
        ],
        // ...
    ]);

$undoRepeaterFake();
```

You may also find it useful to test the number of items in a repeater by passing a function to the `assertFormSet()` method:

```php
use Filament\Forms\Components\Repeater;
use function Pest\Livewire\livewire;

$undoRepeaterFake = Repeater::fake();

livewire(EditPost::class, ['record' => $post])
    ->assertFormSet(function (array $state) {
        expect($state['quotes'])
            ->toHaveCount(2);
    });

$undoRepeaterFake();
```

### Testing repeater actions

In order to test that repeater actions are working as expected, you can utilize the `callFormComponentAction()` method to call your repeater actions and then [perform additional assertions](../testing#actions).

To interact with an action on a particular repeater item, you need to pass in the `item` argument with the key of that repeater item. If your repeater is reading from a relationship, you should prefix the ID (key) of the related record with `record-` to form the key of the repeater item:  

```php
use App\Models\Quote;
use Filament\Forms\Components\Repeater;
use function Pest\Livewire\livewire;

$quote = Quote::first();

livewire(EditPost::class, ['record' => $post])
    ->callFormComponentAction('quotes', 'sendQuote', arguments: [
        'item' => "record-{$quote->getKey()}",
    ])
    ->assertNotified('Quote sent!');
```

# Documentation for forms. File: 03-fields/13-builder.md
---
title: Builder
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Overview

Similar to a [repeater](repeater), the builder component allows you to output a JSON array of repeated form components. Unlike the repeater, which only defines one form schema to repeat, the builder allows you to define different schema "blocks", which you can repeat in any order. This makes it useful for building more advanced array structures.

The primary use of the builder component is to build web page content using predefined blocks. This could be content for a marketing website, or maybe even fields in an online form. The example below defines multiple blocks for different elements in the page content. On the frontend of your website, you could loop through each block in the JSON and format it how you wish.

```php
use Filament\Forms\Components\Builder;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;

Builder::make('content')
    ->blocks([
        Builder\Block::make('heading')
            ->schema([
                TextInput::make('content')
                    ->label('Heading')
                    ->required(),
                Select::make('level')
                    ->options([
                        'h1' => 'Heading 1',
                        'h2' => 'Heading 2',
                        'h3' => 'Heading 3',
                        'h4' => 'Heading 4',
                        'h5' => 'Heading 5',
                        'h6' => 'Heading 6',
                    ])
                    ->required(),
            ])
            ->columns(2),
        Builder\Block::make('paragraph')
            ->schema([
                Textarea::make('content')
                    ->label('Paragraph')
                    ->required(),
            ]),
        Builder\Block::make('image')
            ->schema([
                FileUpload::make('url')
                    ->label('Image')
                    ->image()
                    ->required(),
                TextInput::make('alt')
                    ->label('Alt text')
                    ->required(),
            ]),
    ])
```

<AutoScreenshot name="forms/fields/builder/simple" alt="Builder" version="3.x" />

We recommend that you store builder data with a `JSON` column in your database. Additionally, if you're using Eloquent, make sure that column has an `array` cast.

As evident in the above example, blocks can be defined within the `blocks()` method of the component. Blocks are `Builder\Block` objects, and require a unique name, and a component schema:

```php
use Filament\Forms\Components\Builder;
use Filament\Forms\Components\TextInput;

Builder::make('content')
    ->blocks([
        Builder\Block::make('heading')
            ->schema([
                TextInput::make('content')->required(),
                // ...
            ]),
        // ...
    ])
```

## Setting a block's label

By default, the label of the block will be automatically determined based on its name. To override the block's label, you may use the `label()` method. Customizing the label in this way is useful if you wish to use a [translation string for localization](https://laravel.com/docs/localization#retrieving-translation-strings):

```php
use Filament\Forms\Components\Builder;

Builder\Block::make('heading')
    ->label(__('blocks.heading'))
```

### Labelling builder items based on their content

You may add a label for a builder item using the same `label()` method. This method accepts a closure that receives the item's data in a `$state` variable. If `$state` is null, you should return the block label that should be displayed in the block picker. Otherwise, you should return a string to be used as the item label:

```php
use Filament\Forms\Components\Builder;
use Filament\Forms\Components\TextInput;

Builder\Block::make('heading')
    ->schema([
        TextInput::make('content')
            ->live(onBlur: true)
            ->required(),
        // ...
    ])
    ->label(function (?array $state): string {
        if ($state === null) {
            return 'Heading';
        }

        return $state['content'] ?? 'Untitled heading';
    })
```

Any fields that you use from `$state` should be `live()` if you wish to see the item label update live as you use the form.

<AutoScreenshot name="forms/fields/builder/labelled" alt="Builder with labelled blocks based on the content" version="3.x" />

### Numbering builder items

By default, items in the builder have a number next to their label. You may disable this using the `blockNumbers(false)` method:

```php
use Filament\Forms\Components\Builder;

Builder::make('content')
    ->blocks([
        // ...
    ])
    ->blockNumbers(false)
```

## Setting a block's icon

Blocks may also have an [icon](https://blade-ui-kit.com/blade-icons?set=1#search), which is displayed next to the label. You can add an icon by passing its name to the `icon()` method:

```php
use Filament\Forms\Components\Builder;

Builder\Block::make('paragraph')
    ->icon('heroicon-m-bars-3-bottom-left')
```

<AutoScreenshot name="forms/fields/builder/icons" alt="Builder with block icons in the dropdown" version="3.x" />

### Adding icons to the header of blocks

By default, blocks in the builder don't have an icon next to the header label, just in the dropdown to add new blocks. You may enable this using the `blockIcons()` method:

```php
use Filament\Forms\Components\Builder;

Builder::make('content')
    ->blocks([
        // ...
    ])
    ->blockIcons()
```

## Adding items

An action button is displayed below the builder to allow the user to add a new item.

## Setting the add action button's label

You may set a label to customize the text that should be displayed in the button for adding a builder item, using the `addActionLabel()` method:

```php
use Filament\Forms\Components\Builder;

Builder::make('content')
    ->blocks([
        // ...
    ])
    ->addActionLabel('Add a new block')
```

### Aligning the add action button

By default, the add action is aligned in the center. You may adjust this using the `addActionAlignment()` method, passing an `Alignment` option of `Alignment::Start` or `Alignment::End`:

```php
use Filament\Forms\Components\Builder;
use Filament\Support\Enums\Alignment;

Builder::make('content')
    ->schema([
        // ...
    ])
    ->addActionAlignment(Alignment::Start)
```

### Preventing the user from adding items

You may prevent the user from adding items to the builder using the `addable(false)` method:

```php
use Filament\Forms\Components\Builder;

Builder::make('content')
    ->blocks([
        // ...
    ])
    ->addable(false)
```

## Deleting items

An action button is displayed on each item to allow the user to delete it.

### Preventing the user from deleting items

You may prevent the user from deleting items from the builder using the `deletable(false)` method:

```php
use Filament\Forms\Components\Builder;

Builder::make('content')
    ->blocks([
        // ...
    ])
    ->deletable(false)
```

## Reordering items

A button is displayed on each item to allow the user to drag and drop to reorder it in the list.

### Preventing the user from reordering items

You may prevent the user from reordering items from the builder using the `reorderable(false)` method:

```php
use Filament\Forms\Components\Builder;

Builder::make('content')
    ->blocks([
        // ...
    ])
    ->reorderable(false)
```

### Reordering items with buttons

You may use the `reorderableWithButtons()` method to enable reordering items with buttons to move the item up and down:

```php
use Filament\Forms\Components\Builder;

Builder::make('content')
    ->blocks([
        // ...
    ])
    ->reorderableWithButtons()
```

<AutoScreenshot name="forms/fields/builder/reorderable-with-buttons" alt="Builder that is reorderable with buttons" version="3.x" />

### Preventing reordering with drag and drop

You may use the `reorderableWithDragAndDrop(false)` method to prevent items from being ordered with drag and drop:

```php
use Filament\Forms\Components\Builder;

Builder::make('content')
    ->blocks([
        // ...
    ])
    ->reorderableWithDragAndDrop(false)
```

## Collapsing items

The builder may be `collapsible()` to optionally hide content in long forms:

```php
use Filament\Forms\Components\Builder;

Builder::make('content')
    ->blocks([
        // ...
    ])
    ->collapsible()
```

You may also collapse all items by default:

```php
use Filament\Forms\Components\Builder;

Builder::make('content')
    ->blocks([
        // ...
    ])
    ->collapsed()
```

<AutoScreenshot name="forms/fields/builder/collapsed" alt="Collapsed builder" version="3.x" />

## Cloning items

You may allow builder items to be duplicated using the `cloneable()` method:

```php
use Filament\Forms\Components\Builder;

Builder::make('content')
    ->blocks([
        // ...
    ])
    ->cloneable()
```

<AutoScreenshot name="forms/fields/builder/cloneable" alt="Builder repeater" version="3.x" />

## Customizing the block picker

### Changing the number of columns in the block picker

The block picker has only 1 column. You may customize it by passing a number of columns to `blockPickerColumns()`:

```php
use Filament\Forms\Components\Builder;

Builder::make()
    ->blockPickerColumns(2)
    ->blocks([
        // ...
    ])
```

This method can be used in a couple of different ways:

- You can pass an integer like `blockPickerColumns(2)`. This integer is the number of columns used on the `lg` breakpoint and higher. All smaller devices will have just 1 column.
- You can pass an array, where the key is the breakpoint and the value is the number of columns. For example, `blockPickerColumns(['md' => 2, 'xl' => 4])` will create a 2 column layout on medium devices, and a 4 column layout on extra large devices. The default breakpoint for smaller devices uses 1 column, unless you use a `default` array key.

Breakpoints (`sm`, `md`, `lg`, `xl`, `2xl`) are defined by Tailwind, and can be found in the [Tailwind documentation](https://tailwindcss.com/docs/responsive-design#overview).

### Increasing the width of the block picker

When you [increase the number of columns](#changing-the-number-of-columns-in-the-block-picker), the width of the dropdown should increase incrementally to handle the additional columns. If you'd like more control, you can manually set a maximum width for the dropdown using the `blockPickerWidth()` method. Options correspond to [Tailwind's max-width scale](https://tailwindcss.com/docs/max-width). The options are `xs`, `sm`, `md`, `lg`, `xl`, `2xl`, `3xl`, `4xl`, `5xl`, `6xl`, `7xl`:

```php
use Filament\Forms\Components\Builder;

Builder::make()
    ->blockPickerColumns(3)
    ->blockPickerWidth('2xl')
    ->blocks([
        // ...
    ])
```

## Limiting the number of times a block can be used

By default, each block can be used in the builder an unlimited number of times. You may limit this using the `maxItems()` method on a block:

```php
use Filament\Forms\Components\Builder;

Builder\Block::make('heading')
    ->schema([
        // ...
    ])
    ->maxItems(1)
```

## Builder validation

As well as all rules listed on the [validation](../validation) page, there are additional rules that are specific to builders.

### Number of items validation

You can validate the minimum and maximum number of items that you can have in a builder by setting the `minItems()` and `maxItems()` methods:

```php
use Filament\Forms\Components\Builder;

Builder::make('content')
    ->blocks([
        // ...
    ])
    ->minItems(1)
    ->maxItems(5)
```

## Using `$get()` to access parent field values

All form components are able to [use `$get()` and `$set()`](../advanced) to access another field's value. However, you might experience unexpected behavior when using this inside the builder's schema.

This is because `$get()` and `$set()`, by default, are scoped to the current builder item. This means that you are able to interact with another field inside that builder item easily without knowing which builder item the current form component belongs to.

The consequence of this is that you may be confused when you are unable to interact with a field outside the builder. We use `../` syntax to solve this problem - `$get('../../parent_field_name')`.

Consider your form has this data structure:

```php
[
    'client_id' => 1,

    'builder' => [
        'item1' => [
            'service_id' => 2,
        ],
    ],
]
```

You are trying to retrieve the value of `client_id` from inside the builder item.

`$get()` is relative to the current builder item, so `$get('client_id')` is looking for `$get('builder.item1.client_id')`.

You can use `../` to go up a level in the data structure, so `$get('../client_id')` is `$get('builder.client_id')` and `$get('../../client_id')` is `$get('client_id')`.

The special case of `$get()` with no arguments, or `$get('')` or `$get('./')`, will always return the full data array for the current builder item.

## Customizing the builder item actions

This field uses action objects for easy customization of buttons within it. You can customize these buttons by passing a function to an action registration method. The function has access to the `$action` object, which you can use to [customize it](../../actions/trigger-button). The following methods are available to customize the actions:

- `addAction()`
- `addBetweenAction()`
- `cloneAction()`
- `collapseAction()`
- `collapseAllAction()`
- `deleteAction()`
- `expandAction()`
- `expandAllAction()`
- `moveDownAction()`
- `moveUpAction()`
- `reorderAction()`

Here is an example of how you might customize an action:

```php
use Filament\Forms\Components\Actions\Action;
use Filament\Forms\Components\Builder;

Builder::make('content')
    ->blocks([
        // ...
    ])
    ->collapseAllAction(
        fn (Action $action) => $action->label('Collapse all content'),
    )
```

### Confirming builder actions with a modal

You can confirm actions with a modal by using the `requiresConfirmation()` method on the action object. You may use any [modal customization method](../../actions/modals) to change its content and behavior:

```php
use Filament\Forms\Components\Actions\Action;
use Filament\Forms\Components\Builder;

Builder::make('content')
    ->blocks([
        // ...
    ])
    ->deleteAction(
        fn (Action $action) => $action->requiresConfirmation(),
    )
```

> The `addAction()`, `addBetweenAction()`, `collapseAction()`, `collapseAllAction()`, `expandAction()`, `expandAllAction()` and `reorderAction()` methods do not support confirmation modals, as clicking their buttons does not make the network request that is required to show the modal.

### Adding extra item actions to a builder

You may add new [action buttons](../actions) to the header of each builder item by passing `Action` objects into `extraItemActions()`:

```php
use Filament\Forms\Components\Actions\Action;
use Filament\Forms\Components\Builder;
use Filament\Forms\Components\TextInput;
use Illuminate\Support\Facades\Mail;

Builder::make('content')
    ->blocks([
        Builder\Block::make('contactDetails')
            ->schema([
                TextInput::make('email')
                    ->label('Email address')
                    ->email()
                    ->required(),
                // ...
            ]),
        // ...
    ])
    ->extraItemActions([
        Action::make('sendEmail')
            ->icon('heroicon-m-square-2-stack')
            ->action(function (array $arguments, Builder $component): void {
                $itemData = $component->getItemState($arguments['item']);
                
                Mail::to($itemData['email'])
                    ->send(
                        // ...
                    );
            }),
    ])
```

In this example, `$arguments['item']` gives you the ID of the current builder item. You can validate the data in that builder item using the `getItemState()` method on the builder component. This method returns the validated data for the item. If the item is not valid, it will cancel the action and show an error message for that item in the form.

If you want to get the raw data from the current item without validating it, you can use `$component->getRawItemState($arguments['item'])` instead.

If you want to manipulate the raw data for the entire builder, for example, to add, remove or modify items, you can use `$component->getState()` to get the data, and `$component->state($state)` to set it again:

```php
use Illuminate\Support\Str;

// Get the raw data for the entire builder
$state = $component->getState();

// Add an item, with a random UUID as the key
$state[Str::uuid()] = [
    'type' => 'contactDetails',
    'data' => [
        'email' => auth()->user()->email,
    ],
];

// Set the new data for the builder
$component->state($state);
```

## Previewing blocks

If you prefer to render read-only previews in the builder instead of the blocks' forms, you can use the `blockPreviews()` method. This will render each block's `preview()` instead of the form. Block data will be passed to the preview Blade view in a variable with the same name:

```php
use Filament\Forms\Components\Builder;
use Filament\Forms\Components\Builder\Block;
use Filament\Forms\Components\TextInput;

Builder::make('content')
    ->blockPreviews()
    ->blocks([
        Block::make('heading')
            ->schema([
                TextInput::make('text')
                    ->placeholder('Default heading'),
            ])
            ->preview('filament.content.block-previews.heading'),
    ])
```

In `/resources/views/filament/content/block-previews/heading.blade.php`, you can access the block data like so:

```blade
<h1>
    {{ $text ?? 'Default heading' }}
</h1>
```

### Interactive block previews

By default, preview content is not interactive, and clicking it will open the Edit modal for that block to manage its settings. If you have links and buttons that you'd like to remain interactive in the block previews, you can use the `areInteractive: true` argument of the `blockPreviews()` method:

```php
use Filament\Forms\Components\Builder;

Builder::make('content')
    ->blockPreviews(areInteractive: true)
    ->blocks([
        //
    ])
```

## Testing builders

Internally, builders generate UUIDs for items to keep track of them in the Livewire HTML easier. This means that when you are testing a form with a builder, you need to ensure that the UUIDs are consistent between the form and the test. This can be tricky, and if you don't do it correctly, your tests can fail as the tests are expecting a UUID, not a numeric key.

However, since Livewire doesn't need to keep track of the UUIDs in a test, you can disable the UUID generation and replace them with numeric keys, using the `Builder::fake()` method at the start of your test:

```php
use Filament\Forms\Components\Builder;
use function Pest\Livewire\livewire;

$undoBuilderFake = Builder::fake();

livewire(EditPost::class, ['record' => $post])
    ->assertFormSet([
        'content' => [
            [
                'type' => 'heading',
                'data' => [
                    'content' => 'Hello, world!',
                    'level' => 'h1',
                ],
            ],
            [
                'type' => 'paragraph',
                'data' => [
                    'content' => 'This is a test post.',
                ],
            ],
        ],
        // ...
    ]);

$undoBuilderFake();
```

You may also find it useful to access test the number of items in a repeater by passing a function to the `assertFormSet()` method:

```php
use Filament\Forms\Components\Builder;
use function Pest\Livewire\livewire;

$undoBuilderFake = Builder::fake();

livewire(EditPost::class, ['record' => $post])
    ->assertFormSet(function (array $state) {
        expect($state['content'])
            ->toHaveCount(2);
    });

$undoBuilderFake();
```

# Documentation for forms. File: 03-fields/14-tags-input.md
---
title: Tags input
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Overview

The tags input component allows you to interact with a list of tags.

By default, tags are stored in JSON:

```php
use Filament\Forms\Components\TagsInput;

TagsInput::make('tags')
```

<AutoScreenshot name="forms/fields/tags-input/simple" alt="Tags input" version="3.x" />

If you're saving the JSON tags using Eloquent, you should be sure to add an `array` [cast](https://laravel.com/docs/eloquent-mutators#array-and-json-casting) to the model property:

```php
use Illuminate\Database\Eloquent\Model;

class Post extends Model
{
    protected $casts = [
        'tags' => 'array',
    ];

    // ...
}
```

> Filament also supports [`spatie/laravel-tags`](https://github.com/spatie/laravel-tags). See our [plugin documentation](/plugins/filament-spatie-tags) for more information.

## Comma-separated tags

You may allow the tags to be stored in a separated string, instead of JSON. To set this up, pass the separating character to the `separator()` method:

```php
use Filament\Forms\Components\TagsInput;

TagsInput::make('tags')
    ->separator(',')
```

## Autocompleting tag suggestions

Tags inputs may have autocomplete suggestions. To enable this, pass an array of suggestions to the `suggestions()` method:

```php
use Filament\Forms\Components\TagsInput;

TagsInput::make('tags')
    ->suggestions([
        'tailwindcss',
        'alpinejs',
        'laravel',
        'livewire',
    ])
```

## Defining split keys

Split keys allow you to map specific buttons on your user's keyboard to create a new tag. By default, when the user presses "Enter", a new tag is created in the input. You may also define other keys to create new tags, such as "Tab" or " ". To do this, pass an array of keys to the `splitKeys()` method:

```php
use Filament\Forms\Components\TagsInput;

TagsInput::make('tags')
    ->splitKeys(['Tab', ' '])
```

You can [read more about possible options for keys](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key).

## Adding a prefix and suffix to individual tags

You can add prefix and suffix to tags without modifying the real state of the field. This can be useful if you need to show presentational formatting to users without saving it. This is done with the `tagPrefix()` or `tagSuffix()` method:

```php
use Filament\Forms\Components\TagsInput;

TagsInput::make('percentages')
    ->tagSuffix('%')
```

## Reordering tags

You can allow the user to reorder tags within the field using the `reorderable()` method:

```php
use Filament\Forms\Components\TagsInput;

TagsInput::make('tags')
    ->reorderable()
```

## Changing the color of tags

You can change the color of the tags by passing a color to the `color()` method. It may be either `danger`, `gray`, `info`, `primary`, `success` or `warning`:

```php
use Filament\Forms\Components\TagsInput;

TagsInput::make('tags')
    ->color('danger')
```

## Tags validation

You may add validation rules for each tag by passing an array of rules to the `nestedRecursiveRules()` method:

```php
use Filament\Forms\Components\TagsInput;

TagsInput::make('tags')
    ->nestedRecursiveRules([
        'min:3',
        'max:255',
    ])
```

# Documentation for forms. File: 03-fields/15-textarea.md
---
title: Textarea
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Overview

The textarea allows you to interact with a multi-line string:

```php
use Filament\Forms\Components\Textarea;

Textarea::make('description')
```

<AutoScreenshot name="forms/fields/textarea/simple" alt="Textarea" version="3.x" />

## Resizing the textarea

You may change the size of the textarea by defining the `rows()` and `cols()` methods:

```php
use Filament\Forms\Components\Textarea;

Textarea::make('description')
    ->rows(10)
    ->cols(20)
```

### Autosizing the textarea

You may allow the textarea to automatically resize to fit its content by setting the `autosize()` method:

```php
use Filament\Forms\Components\Textarea;

Textarea::make('description')
    ->autosize()
```

## Making the field read-only

Not to be confused with [disabling the field](getting-started#disabling-a-field), you may make the field "read-only" using the `readOnly()` method:

```php
use Filament\Forms\Components\Textarea;

Textarea::make('description')
    ->readOnly()
```

There are a few differences, compared to [`disabled()`](getting-started#disabling-a-field):

- When using `readOnly()`, the field will still be sent to the server when the form is submitted. It can be mutated with the browser console, or via JavaScript. You can use [`dehydrated(false)`](../advanced#preventing-a-field-from-being-dehydrated) to prevent this.
- There are no styling changes, such as less opacity, when using `readOnly()`.
- The field is still focusable when using `readOnly()`.

## Textarea validation

As well as all rules listed on the [validation](../validation) page, there are additional rules that are specific to textareas.

### Length validation

You may limit the length of the textarea by setting the `minLength()` and `maxLength()` methods. These methods add both frontend and backend validation:

```php
use Filament\Forms\Components\Textarea;

Textarea::make('description')
    ->minLength(2)
    ->maxLength(1024)
```

You can also specify the exact length of the textarea by setting the `length()`. This method adds both frontend and backend validation:

```php
use Filament\Forms\Components\Textarea;

Textarea::make('question')
    ->length(100)
```

# Documentation for forms. File: 03-fields/16-key-value.md
---
title: Key-value
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Overview

The key-value field allows you to interact with one-dimensional JSON object:

```php
use Filament\Forms\Components\KeyValue;

KeyValue::make('meta')
```

<AutoScreenshot name="forms/fields/key-value/simple" alt="Key-value" version="3.x" />

If you're saving the data in Eloquent, you should be sure to add an `array` [cast](https://laravel.com/docs/eloquent-mutators#array-and-json-casting) to the model property:

```php
use Illuminate\Database\Eloquent\Model;

class Post extends Model
{
    protected $casts = [
        'meta' => 'array',
    ];

    // ...
}
```

## Adding rows

An action button is displayed below the field to allow the user to add a new row.

## Setting the add action button's label

You may set a label to customize the text that should be displayed in the button for adding a row, using the `addActionLabel()` method:

```php
use Filament\Forms\Components\KeyValue;

KeyValue::make('meta')
    ->addActionLabel('Add property')
```

### Preventing the user from adding rows

You may prevent the user from adding rows using the `addable(false)` method:

```php
use Filament\Forms\Components\KeyValue;

KeyValue::make('meta')
    ->addable(false)
```

## Deleting rows

An action button is displayed on each item to allow the user to delete it.

### Preventing the user from deleting rows

You may prevent the user from deleting rows using the `deletable(false)` method:

```php
use Filament\Forms\Components\KeyValue;

KeyValue::make('meta')
    ->deletable(false)
```

## Editing keys

### Customizing the key fields' label

You may customize the label for the key fields using the `keyLabel()` method:

```php
use Filament\Forms\Components\KeyValue;

KeyValue::make('meta')
    ->keyLabel('Property name')
```

### Adding key field placeholders

You may also add placeholders for the key fields using the `keyPlaceholder()` method:

```php
use Filament\Forms\Components\KeyValue;

KeyValue::make('meta')
    ->keyPlaceholder('Property name')
```

### Preventing the user from editing keys

You may prevent the user from editing keys using the `editableKeys(false)` method:

```php
use Filament\Forms\Components\KeyValue;

KeyValue::make('meta')
    ->editableKeys(false)
```

## Editing values

### Customizing the value fields' label

You may customize the label for the value fields using the `valueLabel()` method:

```php
use Filament\Forms\Components\KeyValue;

KeyValue::make('meta')
    ->valueLabel('Property value')
```

### Adding value field placeholders

You may also add placeholders for the value fields using the `valuePlaceholder()` method:

```php
use Filament\Forms\Components\KeyValue;

KeyValue::make('meta')
    ->valuePlaceholder('Property value')
```

### Preventing the user from editing values

You may prevent the user from editing values using the `editableValues(false)` method:

```php
use Filament\Forms\Components\KeyValue;

KeyValue::make('meta')
    ->editableValues(false)
```

## Reordering rows

You can allow the user to reorder rows within the table using the `reorderable()` method:

```php
use Filament\Forms\Components\KeyValue;

KeyValue::make('meta')
    ->reorderable()
```

<AutoScreenshot name="forms/fields/key-value/reorderable" alt="Key-value with reorderable rows" version="3.x" />

## Customizing the key-value action objects

This field uses action objects for easy customization of buttons within it. You can customize these buttons by passing a function to an action registration method. The function has access to the `$action` object, which you can use to [customize it](../../actions/trigger-button). The following methods are available to customize the actions:

- `addAction()`
- `deleteAction()`
- `reorderAction()`

Here is an example of how you might customize an action:

```php
use Filament\Forms\Components\Actions\Action;
use Filament\Forms\Components\KeyValue;

KeyValue::make('meta')
    ->deleteAction(
        fn (Action $action) => $action->icon('heroicon-m-x-mark'),
    )
```

# Documentation for forms. File: 03-fields/17-color-picker.md
---
title: Color picker
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Overview

The color picker component allows you to pick a color in a range of formats.

By default, the component uses HEX format:

```php
use Filament\Forms\Components\ColorPicker;

ColorPicker::make('color')
```

<AutoScreenshot name="forms/fields/color-picker/simple" alt="Color picker" version="3.x" />

## Setting the color format

While HEX format is used by default, you can choose which color format to use:

```php
use Filament\Forms\Components\ColorPicker;

ColorPicker::make('hsl_color')
    ->hsl()

ColorPicker::make('rgb_color')
    ->rgb()

ColorPicker::make('rgba_color')
    ->rgba()
```

## Color picker validation

You may use Laravel's validation rules to validate the values of the color picker:

```php
use Filament\Forms\Components\ColorPicker;

ColorPicker::make('hex_color')
    ->regex('/^#([a-f0-9]{6}|[a-f0-9]{3})\b$/')

ColorPicker::make('hsl_color')
    ->hsl()
    ->regex('/^hsl\(\s*(\d+)\s*,\s*(\d*(?:\.\d+)?%)\s*,\s*(\d*(?:\.\d+)?%)\)$/')

ColorPicker::make('rgb_color')
    ->rgb()
    ->regex('/^rgb\((\d{1,3}),\s*(\d{1,3}),\s*(\d{1,3})\)$/')

ColorPicker::make('rgba_color')
    ->rgba()
    ->regex('/^rgba\((\d{1,3}),\s*(\d{1,3}),\s*(\d{1,3}),\s*(\d*(?:\.\d+)?)\)$/')
```

# Documentation for forms. File: 03-fields/18-toggle-buttons.md
---
title: Toggle buttons
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Overview

The toggle buttons input provides a group of buttons for selecting a single value, or multiple values, from a list of predefined options:

```php
use Filament\Forms\Components\ToggleButtons;

ToggleButtons::make('status')
    ->options([
        'draft' => 'Draft',
        'scheduled' => 'Scheduled',
        'published' => 'Published'
    ])
```

<AutoScreenshot name="forms/fields/toggle-buttons/simple" alt="Toggle buttons" version="3.x" />

## Changing the color of option buttons

You can change the color of the option buttons using the `colors()` method. Each key in the array should correspond to an option value, and the value may be either `danger`, `gray`, `info`, `primary`, `success` or `warning`:

```php
use Filament\Forms\Components\ToggleButtons;

ToggleButtons::make('status')
    ->options([
        'draft' => 'Draft',
        'scheduled' => 'Scheduled',
        'published' => 'Published'
    ])
    ->colors([
        'draft' => 'info',
        'scheduled' => 'warning',
        'published' => 'success',
    ])
```

If you are using an enum for the options, you can use the [`HasColor` interface](../../support/enums#enum-colors) to define colors instead.

<AutoScreenshot name="forms/fields/toggle-buttons/colors" alt="Toggle buttons with different colors" version="3.x" />

## Adding icons to option buttons

You can add [icon](https://blade-ui-kit.com/blade-icons?set=1#search) to the option buttons using the `icons()` method. Each key in the array should correspond to an option value, and the value may be any valid [Blade icon](https://blade-ui-kit.com/blade-icons?set=1#search):

```php
use Filament\Forms\Components\ToggleButtons;

ToggleButtons::make('status')
    ->options([
        'draft' => 'Draft',
        'scheduled' => 'Scheduled',
        'published' => 'Published'
    ])
    ->icons([
        'draft' => 'heroicon-o-pencil',
        'scheduled' => 'heroicon-o-clock',
        'published' => 'heroicon-o-check-circle',
    ])
```

If you are using an enum for the options, you can use the [`HasIcon` interface](../../support/enums#enum-icons) to define icons instead.

<AutoScreenshot name="forms/fields/toggle-buttons/icons" alt="Toggle buttons with icons" version="3.x" />

If you want to display only icons, you can use `hiddenButtonLabels()` to hide the option labels.

## Boolean options

If you want a simple boolean toggle button group, with "Yes" and "No" options, you can use the `boolean()` method:

```php
ToggleButtons::make('feedback')
    ->label('Like this post?')
    ->boolean()
```

The options will have [colors](#changing-the-color-of-option-buttons) and [icons](#adding-icons-to-option-buttons) set up automatically, but you can override these with `colors()` or `icons()`.

<AutoScreenshot name="forms/fields/toggle-buttons/boolean" alt="Boolean toggle buttons" version="3.x" />

## Positioning the options inline with each other

You may wish to display the options `inline()` with each other:

```php
ToggleButtons::make('feedback')
    ->label('Like this post?')
    ->boolean()
    ->inline()
```

<AutoScreenshot name="forms/fields/toggle-buttons/inline" alt="Inline toggle buttons" version="3.x" />

## Grouping option buttons

You may wish to group option buttons together so they are more compact, using the `grouped()` method. This also makes them appear horizontally inline with each other:

```php
ToggleButtons::make('feedback')
    ->label('Like this post?')
    ->boolean()
    ->grouped()
```

<AutoScreenshot name="forms/fields/toggle-buttons/grouped" alt="Grouped toggle buttons" version="3.x" />

## Selecting multiple buttons

The `multiple()` method on the `ToggleButtons` component allows you to select multiple values from the list of options:

```php
use Filament\Forms\Components\ToggleButtons;

ToggleButtons::make('technologies')
    ->multiple()
    ->options([
        'tailwind' => 'Tailwind CSS',
        'alpine' => 'Alpine.js',
        'laravel' => 'Laravel',
        'livewire' => 'Laravel Livewire',
    ])
```

<AutoScreenshot name="forms/fields/toggle-buttons/multiple" alt="Multiple toggle buttons selected" version="3.x" />

These options are returned in JSON format. If you're saving them using Eloquent, you should be sure to add an `array` [cast](https://laravel.com/docs/eloquent-mutators#array-and-json-casting) to the model property:

```php
use Illuminate\Database\Eloquent\Model;

class App extends Model
{
    protected $casts = [
        'technologies' => 'array',
    ];

    // ...
}
```

## Splitting options into columns

You may split options into columns by using the `columns()` method:

```php
use Filament\Forms\Components\ToggleButtons;

ToggleButtons::make('technologies')
    ->options([
        // ...
    ])
    ->columns(2)
```

<AutoScreenshot name="forms/fields/toggle-buttons/columns" alt="Toggle buttons with 2 columns" version="3.x" />

This method accepts the same options as the `columns()` method of the [grid](layout/grid). This allows you to responsively customize the number of columns at various breakpoints.

### Setting the grid direction

By default, when you arrange buttons into columns, they will be listed in order vertically. If you'd like to list them horizontally, you may use the `gridDirection('row')` method:

```php
use Filament\Forms\Components\ToggleButtons;

ToggleButtons::make('technologies')
    ->options([
        // ...
    ])
    ->columns(2)
    ->gridDirection('row')
```

<AutoScreenshot name="forms/fields/toggle-buttons/rows" alt="Toggle buttons with 2 rows" version="3.x" />

## Disabling specific options

You can disable specific options using the `disableOptionWhen()` method. It accepts a closure, in which you can check if the option with a specific `$value` should be disabled:

```php
use Filament\Forms\Components\ToggleButtons;

ToggleButtons::make('status')
    ->options([
        'draft' => 'Draft',
        'scheduled' => 'Scheduled',
        'published' => 'Published',
    ])
    ->disableOptionWhen(fn (string $value): bool => $value === 'published')
```

<AutoScreenshot name="forms/fields/toggle-buttons/disabled-option" alt="Toggle buttons with disabled option" version="3.x" />

If you want to retrieve the options that have not been disabled, e.g. for validation purposes, you can do so using `getEnabledOptions()`:

```php
use Filament\Forms\Components\ToggleButtons;

ToggleButtons::make('status')
    ->options([
        'draft' => 'Draft',
        'scheduled' => 'Scheduled',
        'published' => 'Published',
    ])
    ->disableOptionWhen(fn (string $value): bool => $value === 'published')
    ->in(fn (ToggleButtons $component): array => array_keys($component->getEnabledOptions()))
```

# Documentation for forms. File: 03-fields/19-hidden.md
---
title: Hidden
---

## Overview

The hidden component allows you to create a hidden field in your form that holds a value.

```php
use Filament\Forms\Components\Hidden;

Hidden::make('token')
```

Please be aware that the value of this field is still editable by the user if they decide to use the browser's developer tools. You should not use this component to store sensitive or read-only information.

# Documentation for forms. File: 03-fields/20-custom.md
---
title: Custom fields
---
import LaracastsBanner from "@components/LaracastsBanner.astro"

<LaracastsBanner
    title="Build a Custom Form Field"
    description="Watch the Build Advanced Components for Filament series on Laracasts - it will teach you how to build components, and you'll get to know all the internal tools to help you."
    url="https://laracasts.com/series/build-advanced-components-for-filament/episodes/6"
    series="building-advanced-components"
/>

## View fields

Aside from [building custom fields](#custom-field-classes), you may create "view" fields which allow you to create custom fields without extra PHP classes.

```php
use Filament\Forms\Components\ViewField;

ViewField::make('rating')
    ->view('filament.forms.components.range-slider')
```

This assumes that you have a `resources/views/filament/forms/components/range-slider.blade.php` file.

### Passing data to view fields

You can pass a simple array of data to the view using `viewData()`:

```php
use Filament\Forms\Components\ViewField;

ViewField::make('rating')
    ->view('filament.forms.components.range-slider')
    ->viewData([
        'min' => 1,
        'max' => 5,
    ])
```

However, more complex configuration can be achieved with a [custom field class](#custom-field-classes).

## Custom field classes

You may create your own custom field classes and views, which you can reuse across your project, and even release as a plugin to the community.

> If you're just creating a simple custom field to use once, you could instead use a [view field](#view) to render any custom Blade file.

To create a custom field class and view, you may use the following command:

```bash
php artisan make:form-field RangeSlider
```

This will create the following field class:

```php
use Filament\Forms\Components\Field;

class RangeSlider extends Field
{
    protected string $view = 'filament.forms.components.range-slider';
}
```

It will also create a view file at `resources/views/filament/forms/components/range-slider.blade.php`.

## How fields work

Livewire components are PHP classes that have their state stored in the user's browser. When a network request is made, the state is sent to the server, and filled into public properties on the Livewire component class, where it can be accessed in the same way as any other class property in PHP can be.

Imagine you had a Livewire component with a public property called `$name`. You could bind that property to an input field in the HTML of the Livewire component in one of two ways: with the [`wire:model` attribute](https://livewire.laravel.com/docs/properties#data-binding), or by [entangling](https://livewire.laravel.com/docs/javascript#the-wire-object) it with an Alpine.js property:

```blade
<input wire:model="name" />

<!-- Or -->

<div x-data="{ state: $wire.$entangle('name') }">
    <input x-model="state" />
</div>
```

When the user types into the input field, the `$name` property is updated in the Livewire component class. When the user submits the form, the `$name` property is sent to the server, where it can be saved.

This is the basis of how fields work in Filament. Each field is assigned to a public property in the Livewire component class, which is where the state of the field is stored. We call the name of this property the "state path" of the field. You can access the state path of a field using the `$getStatePath()` function in the field's view:

```blade
<input wire:model="{{ $getStatePath() }}" />

<!-- Or -->

<div x-data="{ state: $wire.$entangle('{{ $getStatePath() }}') }">
    <input x-model="state" />
</div>
```

If your component heavily relies on third party libraries, we advise that you asynchronously load the Alpine.js component using the Filament asset system. This ensures that the Alpine.js component is only loaded when it's needed, and not on every page load. To find out how to do this, check out our [Assets documentation](../../support/assets#asynchronous-alpinejs-components).

## Rendering the field wrapper

Filament includes a "field wrapper" component, which is able to render the field's label, validation errors, and any other text surrounding the field. You may render the field wrapper like this in the view:

```blade
<x-dynamic-component
    :component="$getFieldWrapperView()"
    :field="$field"
>
    <!-- Field -->
</x-dynamic-component>
```

It's encouraged to use the field wrapper component whenever appropriate, as it will ensure that the field's design is consistent with the rest of the form.

## Accessing the Eloquent record

Inside your view, you may access the Eloquent record using the `$getRecord()` function:

```blade
<div>
    {{ $getRecord()->name }}
</div>
```

## Obeying state binding modifiers

When you bind a field to a state path, you may use the `defer` modifier to ensure that the state is only sent to the server when the user submits the form, or whenever the next Livewire request is made. This is the default behavior.

However, you may use the [`live()`](../advanced#the-basics-of-reactivity) on a field to ensure that the state is sent to the server immediately when the user interacts with the field. This allows for lots of advanced use cases as explained in the [advanced](../advanced) section of the documentation.

Filament provides a `$applyStateBindingModifiers()` function that you may use in your view to apply any state binding modifiers to a `wire:model` or `$wire.$entangle()` binding:

```blade
<input {{ $applyStateBindingModifiers('wire:model') }}="{{ $getStatePath() }}" />

<!-- Or -->

<div x-data="{ state: $wire.{{ $applyStateBindingModifiers("\$entangle('{$getStatePath()}')") }} }">
    <input x-model="state" />
</div>
```

# Documentation for forms. File: 04-layout/01-getting-started.md
---
title: Getting started
---
import LaracastsBanner from "@components/LaracastsBanner.astro"

## Overview

<LaracastsBanner
    title="Layouts"
    description="Watch the Rapid Laravel Development with Filament series on Laracasts - it will teach you the basics of customizing the layout of a Filament form."
    url="https://laracasts.com/series/rapid-laravel-development-with-filament/episodes/6"
    series="rapid-laravel-development"
/>

Filament forms are not limited to just displaying fields. You can also use "layout components" to organize them into an infinitely nestable structure.

Layout component classes can be found in the `Filament\Forms\Components` namespace. They reside within the schema of your form, alongside any [fields](fields/getting-started).

Components may be created using the static `make()` method. Usually, you will then define the child component `schema()` to display inside:

```php
use Filament\Forms\Components\Grid;

Grid::make(2)
    ->schema([
        // ...
    ])
```

## Available layout components

Filament ships with some layout components, suitable for arranging your form fields depending on your needs:

- [Grid](grid)
- [Fieldset](fieldset)
- [Tabs](tabs)
- [Wizard](wizard)
- [Section](section)
- [Split](split)
- [Placeholder](placeholder)

You may also [create your own custom layout components](custom) to organize fields however you wish.

## Setting an ID

You may define an ID for the component using the `id()` method:

```php
use Filament\Forms\Components\Section;

Section::make()
    ->id('main-section')
```

## Adding extra HTML attributes

You can pass extra HTML attributes to the component, which will be merged onto the outer DOM element. Pass an array of attributes to the `extraAttributes()` method, where the key is the attribute name and the value is the attribute value:

```php
use Filament\Forms\Components\Section;

Section::make()
    ->extraAttributes(['class' => 'custom-section-style'])
```

Classes will be merged with the default classes, and any other attributes will override the default attributes.

## Global settings

If you wish to change the default behavior of a component globally, then you can call the static `configureUsing()` method inside a service provider's `boot()` method, to which you pass a Closure to modify the component using. For example, if you wish to make all section components have [2 columns](grid) by default, you can do it like so:

```php
use Filament\Forms\Components\Section;

Section::configureUsing(function (Section $section): void {
    $section
        ->columns(2);
});
```

Of course, you are still able to overwrite this on each field individually:

```php
use Filament\Forms\Components\Section;

Section::make()
    ->columns(1)
```

# Documentation for forms. File: 04-layout/02-grid.md
---
title: Grid
---

## Overview

Filament's grid system allows you to create responsive, multi-column layouts using any layout component.

## Responsively setting the number of grid columns

All layout components have a `columns()` method that you can use in a couple of different ways:

- You can pass an integer like `columns(2)`. This integer is the number of columns used on the `lg` breakpoint and higher. All smaller devices will have just 1 column.
- You can pass an array, where the key is the breakpoint and the value is the number of columns. For example, `columns(['md' => 2, 'xl' => 4])` will create a 2 column layout on medium devices, and a 4 column layout on extra large devices. The default breakpoint for smaller devices uses 1 column, unless you use a `default` array key.

Breakpoints (`sm`, `md`, `lg`, `xl`, `2xl`) are defined by Tailwind, and can be found in the [Tailwind documentation](https://tailwindcss.com/docs/responsive-design#overview).

## Controlling how many columns a component should span

In addition to specifying how many columns a layout component should have, you may also specify how many columns a component should fill within the parent grid, using the `columnSpan()` method. This method accepts an integer or an array of breakpoints and column spans:

- `columnSpan(2)` will make the component fill up to 2 columns on all breakpoints.
- `columnSpan(['md' => 2, 'xl' => 4])` will make the component fill up to 2 columns on medium devices, and up to 4 columns on extra large devices. The default breakpoint for smaller devices uses 1 column, unless you use a `default` array key.
- `columnSpan('full')` or `columnSpanFull()` or `columnSpan(['default' => 'full'])` will make the component fill the full width of the parent grid, regardless of how many columns it has.

## An example of a responsive grid layout

In this example, we have a form with a [section](section) layout component. Since all layout components support the `columns()` method, we can use it to create a responsive grid layout within the section itself.

We pass an array to `columns()` as we want to specify different numbers of columns for different breakpoints. On devices smaller than the `sm` [Tailwind breakpoint](https://tailwindcss.com/docs/responsive-design#overview), we want to have 1 column, which is default. On devices larger than the `sm` breakpoint, we want to have 3 columns. On devices larger than the `xl` breakpoint, we want to have 6 columns. On devices larger than the `2xl` breakpoint, we want to have 8 columns.

Inside the section, we have a [text input](../fields/text-input). Since text inputs are form components and all form components have a `columnSpan()` method, we can use it to specify how many columns the text input should fill. On devices smaller than the `sm` breakpoint, we want the text input to fill 1 column, which is default. On devices larger than the `sm` breakpoint, we want the text input to fill 2 columns. On devices larger than the `xl` breakpoint, we want the text input to fill 3 columns. On devices larger than the `2xl` breakpoint, we want the text input to fill 4 columns.

```php
use Filament\Forms\Components\Section;
use Filament\Forms\Components\TextInput;

Section::make()
    ->columns([
        'sm' => 3,
        'xl' => 6,
        '2xl' => 8,
    ])
    ->schema([
        TextInput::make('name')
            ->columnSpan([
                'sm' => 2,
                'xl' => 3,
                '2xl' => 4,
            ]),
        // ...
    ])
```

## Grid component

All layout components support the `columns()` method, but you also have access to an additional `Grid` component. If you feel that your form schema would benefit from an explicit grid syntax with no extra styling, it may be useful to you. Instead of using the `columns()` method, you can pass your column configuration directly to `Grid::make()`:

```php
use Filament\Forms\Components\Grid;

Grid::make([
    'default' => 1,
    'sm' => 2,
    'md' => 3,
    'lg' => 4,
    'xl' => 6,
    '2xl' => 8,
])
    ->schema([
        // ...
    ])
```

## Setting the starting column of a component in a grid

If you want to start a component in a grid at a specific column, you can use the `columnStart()` method. This method accepts an integer, or an array of breakpoints and which column the component should start at:

- `columnStart(2)` will make the component start at column 2 on all breakpoints.
- `columnStart(['md' => 2, 'xl' => 4])` will make the component start at column 2 on medium devices, and at column 4 on extra large devices. The default breakpoint for smaller devices uses 1 column, unless you use a `default` array key.

```php
use Filament\Forms\Components\Section;

Section::make()
    ->columns([
        'sm' => 3,
        'xl' => 6,
        '2xl' => 8,
    ])
    ->schema([
        TextInput::make('name')
            ->columnStart([
                'sm' => 2,
                'xl' => 3,
                '2xl' => 4,
            ]),
        // ...
    ])
```

In this example, the grid has 3 columns on small devices, 6 columns on extra large devices, and 8 columns on extra extra large devices. The text input will start at column 2 on small devices, column 3 on extra large devices, and column 4 on extra extra large devices. This is essentially producing a layout whereby the text input always starts halfway through the grid, regardless of how many columns the grid has.

# Documentation for forms. File: 04-layout/03-fieldset.md
---
title: Fieldset
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Overview

You may want to group fields into a Fieldset. Each fieldset has a label, a border, and a two-column grid by default:

```php
use Filament\Forms\Components\Fieldset;

Fieldset::make('Label')
    ->schema([
        // ...
    ])
```

<AutoScreenshot name="forms/layout/fieldset/simple" alt="Fieldset" version="3.x" />

## Using grid columns within a fieldset

You may use the `columns()` method to customize the [grid](grid) within the fieldset:

```php
use Filament\Forms\Components\Fieldset;

Fieldset::make('Label')
    ->schema([
        // ...
    ])
    ->columns(3)
```

# Documentation for forms. File: 04-layout/04-tabs.md
---
title: Tabs
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Overview

Some forms can be long and complex. You may want to use tabs to reduce the number of components that are visible at once:

```php
use Filament\Forms\Components\Tabs;

Tabs::make('Tabs')
    ->tabs([
        Tabs\Tab::make('Tab 1')
            ->schema([
                // ...
            ]),
        Tabs\Tab::make('Tab 2')
            ->schema([
                // ...
            ]),
        Tabs\Tab::make('Tab 3')
            ->schema([
                // ...
            ]),
    ])
```

<AutoScreenshot name="forms/layout/tabs/simple" alt="Tabs" version="3.x" />

## Setting the default active tab

The first tab will be open by default. You can change the default open tab using the `activeTab()` method:

```php
use Filament\Forms\Components\Tabs;

Tabs::make('Tabs')
    ->tabs([
        Tabs\Tab::make('Tab 1')
            ->schema([
                // ...
            ]),
        Tabs\Tab::make('Tab 2')
            ->schema([
                // ...
            ]),
        Tabs\Tab::make('Tab 3')
            ->schema([
                // ...
            ]),
    ])
    ->activeTab(2)
```

## Setting a tab icon

Tabs may have an [icon](https://blade-ui-kit.com/blade-icons?set=1#search), which you can set using the `icon()` method:

```php
use Filament\Forms\Components\Tabs;

Tabs::make('Tabs')
    ->tabs([
        Tabs\Tab::make('Notifications')
            ->icon('heroicon-m-bell')
            ->schema([
                // ...
            ]),
        // ...
    ])
```

<AutoScreenshot name="forms/layout/tabs/icons" alt="Tabs with icons" version="3.x" />

### Setting the tab icon position

The icon of the tab may be positioned before or after the label using the `iconPosition()` method:

```php
use Filament\Forms\Components\Tabs;
use Filament\Support\Enums\IconPosition;

Tabs::make('Tabs')
    ->tabs([
        Tabs\Tab::make('Notifications')
            ->icon('heroicon-m-bell')
            ->iconPosition(IconPosition::After)
            ->schema([
                // ...
            ]),
        // ...
    ])
```

<AutoScreenshot name="forms/layout/tabs/icons-after" alt="Tabs with icons after their labels" version="3.x" />

## Setting a tab badge

Tabs may have a badge, which you can set using the `badge()` method:

```php
use Filament\Forms\Components\Tabs;

Tabs::make('Tabs')
    ->tabs([
        Tabs\Tab::make('Notifications')
            ->badge(5)
            ->schema([
                // ...
            ]),
        // ...
    ])
```

<AutoScreenshot name="forms/layout/tabs/badges" alt="Tabs with badges" version="3.x" />

If you'd like to change the color for a badge, you can use the `badgeColor()` method:

```php
use Filament\Forms\Components\Tabs;

Tabs::make('Tabs')
    ->tabs([
        Tabs\Tab::make('Notifications')
            ->badge(5)
            ->badgeColor('success')
            ->schema([
                // ...
            ]),
        // ...
    ])
```

## Using grid columns within a tab

You may use the `columns()` method to customize the [grid](grid) within the tab:

```php
use Filament\Forms\Components\Tabs;

Tabs::make('Tabs')
    ->tabs([
        Tabs\Tab::make('Tab 1')
            ->schema([
                // ...
            ])
            ->columns(3),
        // ...
    ])
```

## Removing the styled container

By default, tabs and their content are wrapped in a container styled as a card. You may remove the styled container using `contained()`:

```php
use Filament\Forms\Components\Tabs;

Tabs::make('Tabs')
    ->tabs([
        Tabs\Tab::make('Tab 1')
            ->schema([
                // ...
            ]),
        Tabs\Tab::make('Tab 2')
            ->schema([
                // ...
            ]),
        Tabs\Tab::make('Tab 3')
            ->schema([
                // ...
            ]),
    ])
    ->contained(false)
```

## Persisting the current tab

By default, the current tab is not persisted in the browser's local storage. You can change this behavior using the `persistTab()` method. You must also pass in a unique `id()` for the tabs component, to distinguish it from all other sets of tabs in the app. This ID will be used as the key in the local storage to store the current tab:

```php
use Filament\Forms\Components\Tabs;

Tabs::make('Tabs')
    ->tabs([
        // ...
    ])
    ->persistTab()
    ->id('order-tabs')
```

### Persisting the current tab in the URL's query string

By default, the current tab is not persisted in the URL's query string. You can change this behavior using the `persistTabInQueryString()` method:

```php
use Filament\Forms\Components\Tabs;

Tabs::make('Tabs')
    ->tabs([
        Tabs\Tab::make('Tab 1')
            ->schema([
                // ...
            ]),
        Tabs\Tab::make('Tab 2')
            ->schema([
                // ...
            ]),
        Tabs\Tab::make('Tab 3')
            ->schema([
                // ...
            ]),
    ])
    ->persistTabInQueryString()
```

By default, the current tab is persisted in the URL's query string using the `tab` key. You can change this key by passing it to the `persistTabInQueryString()` method:

```php
use Filament\Forms\Components\Tabs;

Tabs::make('Tabs')
    ->tabs([
        Tabs\Tab::make('Tab 1')
            ->schema([
                // ...
            ]),
        Tabs\Tab::make('Tab 2')
            ->schema([
                // ...
            ]),
        Tabs\Tab::make('Tab 3')
            ->schema([
                // ...
            ]),
    ])
    ->persistTabInQueryString('settings-tab')
```


# Documentation for forms. File: 04-layout/05-wizard.md
---
title: Wizard
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Overview

Similar to [tabs](tabs), you may want to use a multistep form wizard to reduce the number of components that are visible at once. These are especially useful if your form has a definite chronological order, in which you want each step to be validated as the user progresses.

```php
use Filament\Forms\Components\Wizard;

Wizard::make([
    Wizard\Step::make('Order')
        ->schema([
            // ...
        ]),
    Wizard\Step::make('Delivery')
        ->schema([
            // ...
        ]),
    Wizard\Step::make('Billing')
        ->schema([
            // ...
        ]),
])
```

<AutoScreenshot name="forms/layout/wizard/simple" alt="Wizard" version="3.x" />

> We have different setup instructions if you're looking to add a wizard to the creation process inside a [panel resource](../../panels/resources/creating-records#using-a-wizard) or an [action modal](../../actions/modals#using-a-wizard-as-a-modal-form). Following that documentation will ensure that the ability to submit the form is only available on the last step of the wizard.

## Rendering a submit button on the last step

You may use the `submitAction()` method to render submit button HTML or a view at the end of the wizard, on the last step. This provides a clearer UX than displaying a submit button below the wizard at all times:

```php
use Filament\Forms\Components\Wizard;
use Illuminate\Support\HtmlString;

Wizard::make([
    // ...
])->submitAction(view('order-form.submit-button'))

Wizard::make([
    // ...
])->submitAction(new HtmlString('<button type="submit">Submit</button>'))
```

Alternatively, you can use the built-in Filament button Blade component:

```php
use Filament\Forms\Components\Wizard;
use Illuminate\Support\Facades\Blade;
use Illuminate\Support\HtmlString;

Wizard::make([
    // ...
])->submitAction(new HtmlString(Blade::render(<<<BLADE
    <x-filament::button
        type="submit"
        size="sm"
    >
        Submit
    </x-filament::button>
BLADE)))
```

You could use this component in a separate Blade view if you want.

## Setting up step icons

Steps may also have an [icon](https://blade-ui-kit.com/blade-icons?set=1#search), set using the `icon()` method:

```php
use Filament\Forms\Components\Wizard;

Wizard\Step::make('Order')
    ->icon('heroicon-m-shopping-bag')
    ->schema([
        // ...
    ]),
```

<AutoScreenshot name="forms/layout/wizard/icons" alt="Wizard with step icons" version="3.x" />

## Customizing the icon for completed steps

You may customize the [icon](#setting-up-step-icons) of a completed step using the `completedIcon()` method:

```php
use Filament\Forms\Components\Wizard;

Wizard\Step::make('Order')
    ->completedIcon('heroicon-m-hand-thumb-up')
    ->schema([
        // ...
    ]),
```

<AutoScreenshot name="forms/layout/wizard/completed-icons" alt="Wizard with completed step icons" version="3.x" />

## Adding descriptions to steps

You may add a short description after the title of each step using the `description()` method:

```php
use Filament\Forms\Components\Wizard;

Wizard\Step::make('Order')
    ->description('Review your basket')
    ->schema([
        // ...
    ]),
```

<AutoScreenshot name="forms/layout/wizard/descriptions" alt="Wizard with step descriptions" version="3.x" />

## Setting the default active step

You may use the `startOnStep()` method to load a specific step in the wizard:

```php
use Filament\Forms\Components\Wizard;

Wizard::make([
    // ...
])->startOnStep(2)
```

## Allowing steps to be skipped

If you'd like to allow free navigation, so all steps are skippable, use the `skippable()` method:

```php
use Filament\Forms\Components\Wizard;

Wizard::make([
    // ...
])->skippable()
```

## Persisting the current step in the URL's query string

By default, the current step is not persisted in the URL's query string. You can change this behavior using the `persistStepInQueryString()` method:

```php
use Filament\Forms\Components\Wizard;

Wizard::make([
    // ...
])->persistStepInQueryString()
```

By default, the current step is persisted in the URL's query string using the `step` key. You can change this key by passing it to the `persistStepInQueryString()` method:

```php
use Filament\Forms\Components\Wizard;

Wizard::make([
    // ...
])->persistStepInQueryString('wizard-step')
```

## Step lifecycle hooks

You may use the `afterValidation()` and `beforeValidation()` methods to run code before and after validation occurs on the step:

```php
use Filament\Forms\Components\Wizard;

Wizard\Step::make('Order')
    ->afterValidation(function () {
        // ...
    })
    ->beforeValidation(function () {
        // ...
    })
    ->schema([
        // ...
    ]),
```

### Preventing the next step from being loaded

Inside `afterValidation()` or `beforeValidation()`, you may throw `Filament\Support\Exceptions\Halt`, which will prevent the wizard from loading the next step:

```php
use Filament\Forms\Components\Wizard;
use Filament\Support\Exceptions\Halt;

Wizard\Step::make('Order')
    ->afterValidation(function () {
        // ...

        if (true) {
            throw new Halt();
        }
    })
    ->schema([
        // ...
    ]),
```

## Using grid columns within a step

You may use the `columns()` method to customize the [grid](grid) within the step:

```php
use Filament\Forms\Components\Wizard;

Wizard::make([
    Wizard\Step::make('Order')
        ->columns(2)
        ->schema([
            // ...
        ]),
    // ...
])
```

## Customizing the wizard action objects

This component uses action objects for easy customization of buttons within it. You can customize these buttons by passing a function to an action registration method. The function has access to the `$action` object, which you can use to [customize it](../../actions/trigger-button). The following methods are available to customize the actions:

- `nextAction()`
- `previousAction()`

Here is an example of how you might customize an action:

```php
use Filament\Forms\Components\Actions\Action;
use Filament\Forms\Components\Wizard;

Wizard::make([
    // ...
])
    ->nextAction(
        fn (Action $action) => $action->label('Next step'),
    )
```

# Documentation for forms. File: 04-layout/06-section.md
---
title: Section
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Overview

You may want to separate your fields into sections, each with a heading and description. To do this, you can use a section component:

```php
use Filament\Forms\Components\Section;

Section::make('Rate limiting')
    ->description('Prevent abuse by limiting the number of requests per period')
    ->schema([
        // ...
    ])
```

<AutoScreenshot name="forms/layout/section/simple" alt="Section" version="3.x" />

You can also use a section without a header, which just wraps the components in a simple card:

```php
use Filament\Forms\Components\Section;

Section::make()
    ->schema([
        // ...
    ])
```

<AutoScreenshot name="forms/layout/section/without-header" alt="Section without header" version="3.x" />

## Adding actions to the section's header or footer

Sections can have actions in their [header](#adding-actions-to-the-sections-header) or [footer](#adding-actions-to-the-sections-footer).

### Adding actions to the section's header

You may add [actions](../actions) to the section's header using the `headerActions()` method:

```php
use Filament\Forms\Components\Actions\Action;
use Filament\Forms\Components\Section;

Section::make('Rate limiting')
    ->headerActions([
        Action::make('test')
            ->action(function () {
                // ...
            }),
    ])
    ->schema([
        // ...
    ])
```

<AutoScreenshot name="forms/layout/section/header/actions" alt="Section with header actions" version="3.x" />

> [Make sure the section has a heading or ID](#adding-actions-to-a-section-without-heading)

### Adding actions to the section's footer

In addition to [header actions](#adding-an-icon-to-the-sections-header), you may add [actions](../actions) to the section's footer using the `footerActions()` method:

```php
use Filament\Forms\Components\Actions\Action;
use Filament\Forms\Components\Section;

Section::make('Rate limiting')
    ->schema([
        // ...
    ])
    ->footerActions([
        Action::make('test')
            ->action(function () {
                // ...
            }),
    ])
```

<AutoScreenshot name="forms/layout/section/footer/actions" alt="Section with footer actions" version="3.x" />

> [Make sure the section has a heading or ID](#adding-actions-to-a-section-without-heading)

#### Aligning section footer actions

Footer actions are aligned to the inline start by default. You may customize the alignment using the `footerActionsAlignment()` method:

```php
use Filament\Forms\Components\Actions\Action;
use Filament\Forms\Components\Section;
use Filament\Support\Enums\Alignment;

Section::make('Rate limiting')
    ->schema([
        // ...
    ])
    ->footerActions([
        Action::make('test')
            ->action(function () {
                // ...
            }),
    ])
    ->footerActionsAlignment(Alignment::End)
```

### Adding actions to a section without heading

If your section does not have a heading, Filament has no way of locating the action inside it. In this case, you must pass a unique `id()` to the section:

```php
use Filament\Forms\Components\Section;

Section::make()
    ->id('rateLimitingSection')
    ->headerActions([
        // ...
    ])
    ->schema([
        // ...
    ])
```

## Adding an icon to the section's header

You may add an [icon](https://blade-ui-kit.com/blade-icons?set=1#search) to the section's header using the `icon()` method:

```php
use Filament\Forms\Components\Section;

Section::make('Cart')
    ->description('The items you have selected for purchase')
    ->icon('heroicon-m-shopping-bag')
    ->schema([
        // ...
    ])
```

<AutoScreenshot name="forms/layout/section/icons" alt="Section with icon" version="3.x" />

## Positioning the heading and description aside

You may use the `aside()` to align heading & description on the left, and the form components inside a card on the right:

```php
use Filament\Forms\Components\Section;

Section::make('Rate limiting')
    ->description('Prevent abuse by limiting the number of requests per period')
    ->aside()
    ->schema([
        // ...
    ])
```

<AutoScreenshot name="forms/layout/section/aside" alt="Section with heading and description aside" version="3.x" />

## Collapsing sections

Sections may be `collapsible()` to optionally hide content in long forms:

```php
use Filament\Forms\Components\Section;

Section::make('Cart')
    ->description('The items you have selected for purchase')
    ->schema([
        // ...
    ])
    ->collapsible()
```

Your sections may be `collapsed()` by default:

```php
use Filament\Forms\Components\Section;

Section::make('Cart')
    ->description('The items you have selected for purchase')
    ->schema([
        // ...
    ])
    ->collapsed()
```

<AutoScreenshot name="forms/layout/section/collapsed" alt="Collapsed section" version="3.x" />

### Persisting collapsed sections

You can persist whether a section is collapsed in local storage using the `persistCollapsed()` method, so it will remain collapsed when the user refreshes the page:

```php
use Filament\Infolists\Components\Section;

Section::make('Cart')
    ->description('The items you have selected for purchase')
    ->schema([
        // ...
    ])
    ->collapsible()
    ->persistCollapsed()
```

To persist the collapse state, the local storage needs a unique ID to store the state. This ID is generated based on the heading of the section. If your section does not have a heading, or if you have multiple sections with the same heading that you do not want to collapse together, you can manually specify the `id()` of that section to prevent an ID conflict:

```php
use Filament\Infolists\Components\Section;

Section::make('Cart')
    ->description('The items you have selected for purchase')
    ->schema([
        // ...
    ])
    ->collapsible()
    ->persistCollapsed()
    ->id('order-cart')
```

## Compact section styling

When nesting sections, you can use a more compact styling:

```php
use Filament\Forms\Components\Section;

Section::make('Rate limiting')
    ->description('Prevent abuse by limiting the number of requests per period')
    ->schema([
        // ...
    ])
    ->compact()
```

<AutoScreenshot name="forms/layout/section/compact" alt="Compact section" version="3.x" />

## Using grid columns within a section

You may use the `columns()` method to easily create a [grid](grid) within the section:

```php
use Filament\Forms\Components\Section;

Section::make('Heading')
    ->schema([
        // ...
    ])
    ->columns(2)
```

# Documentation for forms. File: 04-layout/07-split.md
---
title: Split
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Overview

The `Split` component allows you to define layouts with flexible widths, using flexbox.

```php
use Filament\Forms\Components\Section;
use Filament\Forms\Components\Split;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;

Split::make([
    Section::make([
        TextInput::make('title'),
        Textarea::make('content'),
    ]),
    Section::make([
        Toggle::make('is_published'),
        Toggle::make('is_featured'),
    ])->grow(false),
])->from('md')
```

In this example, the first section will `grow()` to consume available horizontal space, without affecting the amount of space needed to render the second section. This creates a sidebar effect.

The `from()` method is used to control the [Tailwind breakpoint](https://tailwindcss.com/docs/responsive-design#overview) (`sm`, `md`, `lg`, `xl`, `2xl`) at which the split layout should be used. In this example, the split layout will be used on medium devices and larger. On smaller devices, the sections will stack on top of each other.

<AutoScreenshot name="forms/layout/split/simple" alt="Split" version="3.x" />

# Documentation for forms. File: 04-layout/08-custom.md
---
title: Custom layouts
---
import LaracastsBanner from "@components/LaracastsBanner.astro"

<LaracastsBanner
    title="Build a Custom Form Layout"
    description="Watch the Build Advanced Components for Filament series on Laracasts - it will teach you how to build components, and you'll get to know all the internal tools to help you."
    url="https://laracasts.com/series/build-advanced-components-for-filament/episodes/7"
    series="building-advanced-components"
/>

## View components

Aside from [building custom layout components](#custom-layout-classes), you may create "view" components which allow you to create custom layouts without extra PHP classes.

```php
use Filament\Forms\Components\View;

View::make('filament.forms.components.wizard')
```

This assumes that you have a `resources/views/filament/forms/components/wizard.blade.php` file.

## Custom layout classes

You may create your own custom component classes and views, which you can reuse across your project, and even release as a plugin to the community.

> If you're just creating a simple custom component to use once, you could instead use a [view component](#view-components) to render any custom Blade file.

To create a custom component class and view, you may use the following command:

```bash
php artisan make:form-layout Wizard
```

This will create the following layout component class:

```php
use Filament\Forms\Components\Component;

class Wizard extends Component
{
    protected string $view = 'filament.forms.components.wizard';

    public static function make(): static
    {
        return app(static::class);
    }
}
```

It will also create a view file at `resources/views/filament/forms/components/wizard.blade.php`.

## Rendering the component's schema

Inside your view, you may render the component's `schema()` using the `$getChildComponentContainer()` function:

```blade
<div>
    {{ $getChildComponentContainer() }}
</div>
```

## Accessing the Eloquent record

Inside your view, you may access the Eloquent record using the `$getRecord()` function:

```blade
<div>
    {{ $getRecord()->name }}
</div>
```

# Documentation for forms. File: 04-layout/08-placeholder.md
---
title: Placeholder
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Overview

Placeholders can be used to render text-only "fields" within your forms. Each placeholder has `content()`, which cannot be changed by the user.

```php
use App\Models\Post;
use Filament\Forms\Components\Placeholder;

Placeholder::make('created')
    ->content(fn (Post $record): string => $record->created_at->toFormattedDateString())
```

<AutoScreenshot name="forms/layout/placeholder/simple" alt="Placeholder" version="3.x" />

> **Important:** All form fields require a unique name. That also applies to Placeholders!

## Rendering HTML inside the placeholder

You may even render custom HTML within placeholder content:

```php
use Filament\Forms\Components\Placeholder;
use Illuminate\Support\HtmlString;

Placeholder::make('documentation')
    ->content(new HtmlString('<a href="https://filamentphp.com/docs">filamentphp.com</a>'))
```

## Dynamically generating placeholder content

By passing a closure to the `content()` method, you may dynamically generate placeholder content. You have access to any closure parameter explained in the [advanced closure customization](../advanced#closure-customization) documentation:

```php
use Filament\Forms\Components\Placeholder;
use Filament\Forms\Get;

Placeholder::make('total')
    ->content(function (Get $get): string {
        return '€' . number_format($get('cost') * $get('quantity'), 2);
    })
```

# Documentation for forms. File: 05-validation.md
---
title: Validation
---

## Overview

Validation rules may be added to any [field](fields/getting-started).

In Laravel, validation rules are usually defined in arrays like `['required', 'max:255']` or a combined string like `required|max:255`. This is fine if you're exclusively working in the backend with simple form requests. But Filament is also able to give your users frontend validation, so they can fix their mistakes before any backend requests are made.

Filament includes several [dedicated validation methods](#available-rules), but you can also use any [other Laravel validation rules](#other-rules), including [custom validation rules](#custom-rules).

> Beware that some validations rely on the field name and therefore won't work when passed via `->rule()`/`->rules()`. Use the dedicated validation methods whenever you can.

## Available rules

### Active URL

The field must have a valid A or AAAA record according to the `dns_get_record()` PHP function. [See the Laravel documentation.](https://laravel.com/docs/validation#rule-active-url)

```php
Field::make('name')->activeUrl()
```

### After (date)

The field value must be a value after a given date. [See the Laravel documentation.](https://laravel.com/docs/validation#rule-after)

```php
Field::make('start_date')->after('tomorrow')
```

Alternatively, you may pass the name of another field to compare against:

```php
Field::make('start_date')
Field::make('end_date')->after('start_date')
```

### After or equal to (date)

The field value must be a date after or equal to the given date. [See the Laravel documentation.](https://laravel.com/docs/validation#rule-after-or-equal)

```php
Field::make('start_date')->afterOrEqual('tomorrow')
```

Alternatively, you may pass the name of another field to compare against:

```php
Field::make('start_date')
Field::make('end_date')->afterOrEqual('start_date')
```

### Alpha

The field must be entirely alphabetic characters. [See the Laravel documentation.](https://laravel.com/docs/validation#rule-alpha)

```php
Field::make('name')->alpha()
```

### Alpha Dash

The field may have alphanumeric characters, as well as dashes and underscores. [See the Laravel documentation.](https://laravel.com/docs/validation#rule-alpha-dash)

```php
Field::make('name')->alphaDash()
```

### Alpha Numeric

The field must be entirely alphanumeric characters. [See the Laravel documentation.](https://laravel.com/docs/validation#rule-alpha-num)

```php
Field::make('name')->alphaNum()
```

### ASCII

The field must be entirely 7-bit ASCII characters. [See the Laravel documentation.](https://laravel.com/docs/validation#rule-ascii)

```php
Field::make('name')->ascii()
```

### Before (date)

The field value must be a date before a given date. [See the Laravel documentation.](https://laravel.com/docs/validation#rule-before)

```php
Field::make('start_date')->before('first day of next month')
```

Alternatively, you may pass the name of another field to compare against:

```php
Field::make('start_date')->before('end_date')
Field::make('end_date')
```

### Before or equal to (date)

The field value must be a date before or equal to the given date. [See the Laravel documentation.](https://laravel.com/docs/validation#rule-before-or-equal)

```php
Field::make('start_date')->beforeOrEqual('end of this month')
```

Alternatively, you may pass the name of another field to compare against:

```php
Field::make('start_date')->beforeOrEqual('end_date')
Field::make('end_date')
```

### Confirmed

The field must have a matching field of `{field}_confirmation`. [See the Laravel documentation.](https://laravel.com/docs/validation#rule-confirmed)

```php
Field::make('password')->confirmed()
Field::make('password_confirmation')
```

### Different

The field value must be different to another. [See the Laravel documentation.](https://laravel.com/docs/validation#rule-different)

```php
Field::make('backup_email')->different('email')
```

### Doesnt Start With

The field must not start with one of the given values. [See the Laravel documentation.](https://laravel.com/docs/validation#rule-doesnt-start-with)

```php
Field::make('name')->doesntStartWith(['admin'])
```

### Doesnt End With

The field must not end with one of the given values. [See the Laravel documentation.](https://laravel.com/docs/validation#rule-doesnt-end-with)

```php
Field::make('name')->doesntEndWith(['admin'])
```

### Ends With

The field must end with one of the given values. [See the Laravel documentation.](https://laravel.com/docs/validation#rule-ends-with)

```php
Field::make('name')->endsWith(['bot'])
```

### Enum

The field must contain a valid enum value. [See the Laravel documentation.](https://laravel.com/docs/validation#rule-enum)

```php
Field::make('status')->enum(MyStatus::class)
```

### Exists

The field value must exist in the database. [See the Laravel documentation.](https://laravel.com/docs/validation#rule-exists)

```php
Field::make('invitation')->exists()
```

By default, the form's model will be searched, [if it is registered](adding-a-form-to-a-livewire-component#setting-a-form-model). You may specify a custom table name or model to search:

```php
use App\Models\Invitation;

Field::make('invitation')->exists(table: Invitation::class)
```

By default, the field name will be used as the column to search. You may specify a custom column to search:

```php
Field::make('invitation')->exists(column: 'id')
```

You can further customize the rule by passing a [closure](advanced#closure-customization) to the `callback` parameter:

```php
use Illuminate\Validation\Rules\Exists;

Field::make('invitation')
    ->exists(modifyRuleUsing: function (Exists $rule) {
        return $rule->where('is_active', 1);
    })
```

### Filled

The field must not be empty when it is present. [See the Laravel documentation.](https://laravel.com/docs/validation#rule-filled)

```php
Field::make('name')->filled()
```

### Greater than

The field value must be greater than another. [See the Laravel documentation.](https://laravel.com/docs/validation#rule-gt)

```php
Field::make('newNumber')->gt('oldNumber')
```

### Greater than or equal to

The field value must be greater than or equal to another. [See the Laravel documentation.](https://laravel.com/docs/validation#rule-gte)

```php
Field::make('newNumber')->gte('oldNumber')
```

### Hex color

The field value must be a valid color in hexadecimal format. [See the Laravel documentation.](https://laravel.com/docs/validation#rule-hex-color)

```php
Field::make('color')->hexColor()
```

### In
The field must be included in the given list of values. [See the Laravel documentation.](https://laravel.com/docs/validation#rule-in)

```php
Field::make('status')->in(['pending', 'completed'])
```

### Ip Address

The field must be an IP address. [See the Laravel documentation.](https://laravel.com/docs/validation#rule-ip)

```php
Field::make('ip_address')->ip()
Field::make('ip_address')->ipv4()
Field::make('ip_address')->ipv6()
```

### JSON

The field must be a valid JSON string. [See the Laravel documentation.](https://laravel.com/docs/validation#rule-json)

```php
Field::make('ip_address')->json()
```

### Less than

The field value must be less than another. [See the Laravel documentation.](https://laravel.com/docs/validation#rule-lt)

```php
Field::make('newNumber')->lt('oldNumber')
```

### Less than or equal to

The field value must be less than or equal to another. [See the Laravel documentation.](https://laravel.com/docs/validation#rule-lte)

```php
Field::make('newNumber')->lte('oldNumber')
```

### Mac Address

The field must be a MAC address. [See the Laravel documentation.](https://laravel.com/docs/validation#rule-mac)

```php
Field::make('mac_address')->macAddress()
```

### Multiple Of

The field must be a multiple of value. [See the Laravel documentation.](https://laravel.com/docs/validation#multiple-of)

```php
Field::make('number')->multipleOf(2)
```

### Not In

The field must not be included in the given list of values. [See the Laravel documentation.](https://laravel.com/docs/validation#rule-not-in)

```php
Field::make('status')->notIn(['cancelled', 'rejected'])
```

### Not Regex

The field must not match the given regular expression. [See the Laravel documentation.](https://laravel.com/docs/validation#rule-not-regex)

```php
Field::make('email')->notRegex('/^.+$/i')
```

### Nullable

The field value can be empty. This rule is applied by default if the `required` rule is not present. [See the Laravel documentation.](https://laravel.com/docs/validation#rule-nullable)

```php
Field::make('name')->nullable()
```

### Prohibited

The field value must be empty. [See the Laravel documentation.](https://laravel.com/docs/validation#rule-prohibited)

```php
Field::make('name')->prohibited()
```

### Prohibited If

The field must be empty *only if* the other specified field has any of the given values. [See the Laravel documentation.](https://laravel.com/docs/validation#rule-prohibited-if)

```php
Field::make('name')->prohibitedIf('field', 'value')
```

### Prohibited Unless

The field must be empty *unless* the other specified field has any of the given values. [See the Laravel documentation.](https://laravel.com/docs/validation#rule-prohibited-unless)

```php
Field::make('name')->prohibitedUnless('field', 'value')
```

### Prohibits

If the field is not empty, all other specified fields must be empty. [See the Laravel documentation.](https://laravel.com/docs/validation#rule-prohibits)

```php
Field::make('name')->prohibits('field')

Field::make('name')->prohibits(['field', 'another_field'])
```

### Required

The field value must not be empty. [See the Laravel documentation.](https://laravel.com/docs/validation#rule-required)

```php
Field::make('name')->required()
```

### Required If

The field value must not be empty _only if_ the other specified field has any of the given values. [See the Laravel documentation.](https://laravel.com/docs/validation#rule-required-if)

```php
Field::make('name')->requiredIf('field', 'value')
```

### Required If Accepted

The field value must not be empty _only if_ the other specified field is equal to "yes", "on", 1, "1", true, or "true". [See the Laravel documentation.](https://laravel.com/docs/validation#rule-required-if-accepted)

```php
Field::make('name')->requiredIfAccepted('field')
```

### Required Unless

The field value must not be empty _unless_ the other specified field has any of the given values. [See the Laravel documentation.](https://laravel.com/docs/validation#rule-required-unless)

```php
Field::make('name')->requiredUnless('field', 'value')
```

### Required With

The field value must not be empty _only if_ any of the other specified fields are not empty. [See the Laravel documentation.](https://laravel.com/docs/validation#rule-required-with)

```php
Field::make('name')->requiredWith('field,another_field')
```

### Required With All

The field value must not be empty _only if_ all the other specified fields are not empty. [See the Laravel documentation.](https://laravel.com/docs/validation#rule-required-with-all)

```php
Field::make('name')->requiredWithAll('field,another_field')
```

### Required Without

The field value must not be empty _only when_ any of the other specified fields are empty. [See the Laravel documentation.](https://laravel.com/docs/validation#rule-required-without)

```php
Field::make('name')->requiredWithout('field,another_field')
```

### Required Without All

The field value must not be empty _only when_ all the other specified fields are empty. [See the Laravel documentation.](https://laravel.com/docs/validation#rule-required-without-all)

```php
Field::make('name')->requiredWithoutAll('field,another_field')
```

### Regex

The field must match the given regular expression. [See the Laravel documentation.](https://laravel.com/docs/validation#rule-regex)

```php
Field::make('email')->regex('/^.+@.+$/i')
```

### Same

The field value must be the same as another. [See the Laravel documentation.](https://laravel.com/docs/validation#rule-same)

```php
Field::make('password')->same('passwordConfirmation')
```

### Starts With

The field must start with one of the given values. [See the Laravel documentation.](https://laravel.com/docs/validation#rule-starts-with)

```php
Field::make('name')->startsWith(['a'])
```

### String

The field must be a string. [See the Laravel documentation.](https://laravel.com/docs/validation#rule-string)
```php
Field::make('name')->string()
```

### Unique

The field value must not exist in the database. [See the Laravel documentation.](https://laravel.com/docs/validation#rule-unique)

```php
Field::make('email')->unique()
```

By default, the form's model will be searched, [if it is registered](adding-a-form-to-a-livewire-component#setting-a-form-model). You may specify a custom table name or model to search:

```php
use App\Models\User;

Field::make('email')->unique(table: User::class)
```

By default, the field name will be used as the column to search. You may specify a custom column to search:

```php
Field::make('email')->unique(column: 'email_address')
```

Sometimes, you may wish to ignore a given model during unique validation. For example, consider an "update profile" form that includes the user's name, email address, and location. You will probably want to verify that the email address is unique. However, if the user only changes the name field and not the email field, you do not want a validation error to be thrown because the user is already the owner of the email address in question.

```php
Field::make('email')->unique(ignorable: $ignoredUser)
```

If you're using the [Panel Builder](../panels), you can easily ignore the current record by using `ignoreRecord` instead:

```php
Field::make('email')->unique(ignoreRecord: true)
```

You can further customize the rule by passing a [closure](advanced#closure-customization) to the `modifyRuleUsing` parameter:

```php
use Illuminate\Validation\Rules\Unique;

Field::make('email')
    ->unique(modifyRuleUsing: function (Unique $rule) {
        return $rule->where('is_active', 1);
    })
```


### ULID

The field under validation must be a valid [Universally Unique Lexicographically Sortable Identifier](https://github.com/ulid/spec) (ULID). [See the Laravel documentation.](https://laravel.com/docs/validation#rule-ulid)

```php
Field::make('identifier')->ulid()
```

### UUID

The field must be a valid RFC 4122 (version 1, 3, 4, or 5) universally unique identifier (UUID). [See the Laravel documentation.](https://laravel.com/docs/validation#rule-uuid)

```php
Field::make('identifier')->uuid()
```

## Other rules

You may add other validation rules to any field using the `rules()` method:

```php
TextInput::make('slug')->rules(['alpha_dash'])
```

A full list of validation rules may be found in the [Laravel documentation](https://laravel.com/docs/validation#available-validation-rules).

## Custom rules

You may use any custom validation rules as you would do in [Laravel](https://laravel.com/docs/validation#custom-validation-rules):

```php
TextInput::make('slug')->rules([new Uppercase()])
```

You may also use [closure rules](https://laravel.com/docs/validation#using-closures):

```php
use Closure;

TextInput::make('slug')->rules([
    fn (): Closure => function (string $attribute, $value, Closure $fail) {
        if ($value === 'foo') {
            $fail('The :attribute is invalid.');
        }
    },
])
```

You may [inject utilities](advanced#form-component-utility-injection) like [`$get`](advanced#injecting-the-state-of-another-field) into your custom rules, for example if you need to reference other field values in your form:

```php
use Closure;
use Filament\Forms\Get;

TextInput::make('slug')->rules([
    fn (Get $get): Closure => function (string $attribute, $value, Closure $fail) use ($get) {
        if ($get('other_field') === 'foo' && $value !== 'bar') {
            $fail("The {$attribute} is invalid.");
        }
    },
])
```

## Customizing validation attributes

When fields fail validation, their label is used in the error message. To customize the label used in field error messages, use the `validationAttribute()` method:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('name')->validationAttribute('full name')
```

## Validation messages

By default Laravel's validation error message is used. To customize the error messages, use the `validationMessages()` method:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('email')
    ->unique(// ...)
    ->validationMessages([
        'unique' => 'The :attribute has already been registered.',
    ])
```

## Sending validation notifications

If you want to send a notification when validation error occurs, you may do so by using the `onValidationError()` method on your Livewire component:

```php
use Filament\Notifications\Notification;
use Illuminate\Validation\ValidationException;

protected function onValidationError(ValidationException $exception): void
{
    Notification::make()
        ->title($exception->getMessage())
        ->danger()
        ->send();
}
```

Alternatively, if you are using the Panel Builder and want this behavior on all the pages, add this inside the `boot()` method of your `AppServiceProvider`:

```php
use Filament\Notifications\Notification;
use Filament\Pages\Page;
use Illuminate\Validation\ValidationException;

Page::$reportValidationErrorUsing = function (ValidationException $exception) {
    Notification::make()
        ->title($exception->getMessage())
        ->danger()
        ->send();
};
```

# Documentation for forms. File: 06-actions.md
---
title: Actions
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Overview

Filament's forms can use [Actions](../actions). They are buttons that can be added to any form component. For instance, you may want an action to call an API endpoint to generate content with AI, or to create a new option for a select dropdown. Also, you can [render anonymous sets of actions](#adding-anonymous-actions-to-a-form-without-attaching-them-to-a-component) on their own which are not attached to a particular form component.

## Defining a form component action

Action objects inside a form component are instances of `Filament/Forms/Components/Actions/Action`. You must pass a unique name to the action's `make()` method, which is used to identify it amongst others internally within Filament. You can [customize the trigger button](../actions/trigger-button) of an action, and even [open a modal](../actions/modals) with little effort:

```php
use App\Actions\ResetStars;
use Filament\Forms\Components\Actions\Action;

Action::make('resetStars')
    ->icon('heroicon-m-x-mark')
    ->color('danger')
    ->requiresConfirmation()
    ->action(function (ResetStars $resetStars) {
        $resetStars();
    })
```

### Adding an affix action to a field

Certain fields support "affix actions", which are buttons that can be placed before or after its input area. The following fields support affix actions:

- [Text input](fields/text-input)
- [Select](fields/select)
- [Date-time picker](fields/date-time-picker)
- [Color picker](fields/color-picker)

To define an affix action, you can pass it to either `prefixAction()` or `suffixAction()`:

```php
use Filament\Forms\Components\Actions\Action;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Set;

TextInput::make('cost')
    ->prefix('€')
    ->suffixAction(
        Action::make('copyCostToPrice')
            ->icon('heroicon-m-clipboard')
            ->requiresConfirmation()
            ->action(function (Set $set, $state) {
                $set('price', $state);
            })
    )
```

<AutoScreenshot name="forms/fields/actions/suffix" alt="Text input with suffix action" version="3.x" />

Notice `$set` and `$state` injected into the `action()` function in this example. This is [form component action utility injection](#form-component-action-utility-injection).

#### Passing multiple affix actions to a field

You may pass multiple affix actions to a field by passing them in an array to either `prefixActions()` or `suffixActions()`. Either method can be used, or both at once, Filament will render all the registered actions in order:

```php
use Filament\Forms\Components\Actions\Action;
use Filament\Forms\Components\TextInput;

TextInput::make('cost')
    ->prefix('€')
    ->prefixActions([
        Action::make('...'),
        Action::make('...'),
        Action::make('...'),
    ])
    ->suffixActions([
        Action::make('...'),
        Action::make('...'),
    ])
```

### Adding a hint action to a field

All fields support "hint actions", which are rendered aside the field's [hint](fields/getting-started#adding-a-hint-next-to-the-label). To add a hint action to a field, you may pass it to `hintAction()`:

```php
use Filament\Forms\Components\Actions\Action;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Set;

TextInput::make('cost')
    ->prefix('€')
    ->hintAction(
        Action::make('copyCostToPrice')
            ->icon('heroicon-m-clipboard')
            ->requiresConfirmation()
            ->action(function (Set $set, $state) {
                $set('price', $state);
            })
    )
```

Notice `$set` and `$state` injected into the `action()` function in this example. This is [form component action utility injection](#form-component-action-utility-injection).

<AutoScreenshot name="forms/fields/actions/hint" alt="Text input with hint action" version="3.x" />

#### Passing multiple hint actions to a field

You may pass multiple hint actions to a field by passing them in an array to `hintActions()`. Filament will render all the registered actions in order:

```php
use Filament\Forms\Components\Actions\Action;
use Filament\Forms\Components\TextInput;

TextInput::make('cost')
    ->prefix('€')
    ->hintActions([
        Action::make('...'),
        Action::make('...'),
        Action::make('...'),
    ])
```

### Adding an action to a custom form component

If you wish to render an action within a custom form component, `ViewField` object, or `View` component object, you may do so using the `registerActions()` method:

```php
use Filament\Forms\Components\Actions\Action;
use Filament\Forms\Components\ViewField;
use Filament\Forms\Set;

ViewField::make('rating')
    ->view('filament.forms.components.range-slider')
    ->registerActions([
        Action::make('setMaximum')
            ->icon('heroicon-m-star')
            ->action(function (Set $set) {
                $set('rating', 5);
            }),
    ])
```

Notice `$set` injected into the `action()` function in this example. This is [form component action utility injection](#form-component-action-utility-injection).

Now, to render the action in the view of the custom component, you need to call `$getAction()`, passing the name of the action you registered:

```blade
<div x-data="{ state: $wire.$entangle('{{ $getStatePath() }}') }">
    <input x-model="state" type="range" />
    
    {{ $getAction('setMaximum') }}
</div>
```

### Adding "anonymous" actions to a form without attaching them to a component

You may use an `Actions` component to render a set of actions anywhere in the form, avoiding the need to register them to any particular component:

```php
use App\Actions\Star;
use App\Actions\ResetStars;
use Filament\Forms\Components\Actions;
use Filament\Forms\Components\Actions\Action;

Actions::make([
    Action::make('star')
        ->icon('heroicon-m-star')
        ->requiresConfirmation()
        ->action(function (Star $star) {
            $star();
        }),
    Action::make('resetStars')
        ->icon('heroicon-m-x-mark')
        ->color('danger')
        ->requiresConfirmation()
        ->action(function (ResetStars $resetStars) {
            $resetStars();
        }),
]),
```

<AutoScreenshot name="forms/layout/actions/anonymous/simple" alt="Anonymous actions" version="3.x" />

#### Making the independent form actions consume the full width of the form

You can stretch the independent form actions to consume the full width of the form using `fullWidth()`:

```php
use Filament\Forms\Components\Actions;

Actions::make([
    // ...
])->fullWidth(),
```

<AutoScreenshot name="forms/layout/actions/anonymous/full-width" alt="Anonymous actions consuming the full width" version="3.x" />

#### Controlling the horizontal alignment of independent form actions

Independent form actions are aligned to the start of the component by default. You may change this by passing `Alignment::Center` or `Alignment::End` to `alignment()`:

```php
use Filament\Forms\Components\Actions;
use Filament\Support\Enums\Alignment;

Actions::make([
    // ...
])->alignment(Alignment::Center),
```

<AutoScreenshot name="forms/layout/actions/anonymous/horizontally-aligned-center" alt="Anonymous actions horizontally aligned to the center" version="3.x" />

#### Controlling the vertical alignment of independent form actions

Independent form actions are vertically aligned to the start of the component by default. You may change this by passing `Alignment::Center` or `Alignment::End` to `verticalAlignment()`:

```php
use Filament\Forms\Components\Actions;
use Filament\Support\Enums\VerticalAlignment;

Actions::make([
    // ...
])->verticalAlignment(VerticalAlignment::End),
```

<AutoScreenshot name="forms/layout/actions/anonymous/vertically-aligned-end" alt="Anonymous actions vertically aligned to the end" version="3.x" />

## Form component action utility injection

If an action is attached to a form component, the `action()` function is able to [inject utilities](advanced#form-component-utility-injection) directly from that form component. For instance, you can inject [`$set`](advanced#injecting-a-function-to-set-the-state-of-another-field) and [`$state`](advanced#injecting-the-current-state-of-a-field):

```php
use Filament\Forms\Components\Actions\Action;
use Filament\Forms\Set;

Action::make('copyCostToPrice')
    ->icon('heroicon-m-clipboard')
    ->requiresConfirmation()
    ->action(function (Set $set, $state) {
        $set('price', $state);
    })
```

Form component actions also have access to [all utilities that apply to actions](../actions/advanced#action-utility-injection) in general.

# Documentation for forms. File: 07-advanced.md
---
title: Advanced forms
---

## Overview

Filament Form Builder is designed to be flexible and customizable. Many existing form builders allow users to define a form schema, but don't provide a great interface for defining inter-field interactions, or custom logic. Since all Filament forms are built on top of [Livewire](https://livewire.laravel.com), the form can adapt dynamically to user input, even after it has been initially rendered. Developers can use [parameter injection](#form-component-utility-injection) to access many utilities in real time and build dynamic forms based on user input. The [lifecycle](#field-lifecycle) of fields is open to extension using hook functions to define custom functionality for each field. This allows developers to build complex forms with ease.

## The basics of reactivity

[Livewire](https://livewire.laravel.com) is a tool that allows Blade-rendered HTML to dynamically re-render without requiring a full page reload. Filament forms are built on top of Livewire, so they are able to re-render dynamically, allowing their layout to adapt after they are initially rendered.

By default, when a user uses a field, the form will not re-render. Since rendering requires a round-trip to the server, this is a performance optimization. However, if you wish to re-render the form after the user has interacted with a field, you can use the `live()` method:

```php
use Filament\Forms\Components\Select;

Select::make('status')
    ->options([
        'draft' => 'Draft',
        'reviewing' => 'Reviewing',
        'published' => 'Published',
    ])
    ->live()
```

In this example, when the user changes the value of the `status` field, the form will re-render. This allows you to then make changes to fields in the form based on the new value of the `status` field. Also, you can [hook in to the field's lifecycle](#field-updates) to perform custom logic when the field is updated.

### Reactive fields on blur

By default, when a field is set to `live()`, the form will re-render every time the field is interacted with. However, this may not be appropriate for some fields like the text input, since making network requests while the user is still typing results in suboptimal performance. You may wish to re-render the form only after the user has finished using the field, when it becomes out of focus. You can do this using the `live(onBlur: true)` method:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('username')
    ->live(onBlur: true)
```

### Debouncing reactive fields

You may wish to find a middle ground between `live()` and `live(onBlur: true)`, using "debouncing". Debouncing will prevent a network request from being sent until a user has finished typing for a certain period of time. You can do this using the `live(debounce: 500)` method:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('username')
    ->live(debounce: 500) // Wait 500ms before re-rendering the form.
```

In this example, `500` is the number of milliseconds to wait before sending a network request. You can customize this number to whatever you want, or even use a string like `'1s'`.

## Form component utility injection

The vast majority of methods used to configure [fields](fields/getting-started) and [layout components](layout/getting-started) accept functions as parameters instead of hardcoded values:

```php
use App\Models\User;
use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;

DatePicker::make('date_of_birth')
    ->displayFormat(function (): string {
        if (auth()->user()->country_id === 'us') {
            return 'm/d/Y';
        }

        return 'd/m/Y';
    })

Select::make('user_id')
    ->options(function (): array {
        return User::all()->pluck('name', 'id')->all();
    })

TextInput::make('middle_name')
    ->required(fn (): bool => auth()->user()->hasMiddleName())
```

This alone unlocks many customization possibilities.

The package is also able to inject many utilities to use inside these functions, as parameters. All customization methods that accept functions as arguments can inject utilities.

These injected utilities require specific parameter names to be used. Otherwise, Filament doesn't know what to inject.

### Injecting the current state of a field

If you wish to access the current state (value) of the field, define a `$state` parameter:

```php
function ($state) {
    // ...
}
```

### Injecting the current form component instance

If you wish to access the current component instance, define a `$component` parameter:

```php
use Filament\Forms\Components\Component;

function (Component $component) {
    // ...
}
```

### Injecting the current Livewire component instance

If you wish to access the current Livewire component instance, define a `$livewire` parameter:

```php
use Livewire\Component as Livewire;

function (Livewire $livewire) {
    // ...
}
```

### Injecting the current form record

If your form is associated with an Eloquent model instance, define a `$record` parameter:

```php
use Illuminate\Database\Eloquent\Model;

function (?Model $record) {
    // ...
}
```

### Injecting the state of another field

You may also retrieve the state (value) of another field from within a callback, using a `$get` parameter:

```php
use Filament\Forms\Get;

function (Get $get) {
    $email = $get('email'); // Store the value of the `email` field in the `$email` variable.
    //...
}
```

### Injecting a function to set the state of another field

In a similar way to `$get`, you may also set the value of another field from within a callback, using a `$set` parameter:

```php
use Filament\Forms\Set;

function (Set $set) {
    $set('title', 'Blog Post'); // Set the `title` field to `Blog Post`.
    //...
}
```

When this function is run, the state of the `title` field will be updated, and the form will re-render with the new title. This is useful inside the [`afterStateUpdated`](#field-updates) method.

### Injecting the current form operation

If you're writing a form for a panel resource or relation manager, and you wish to check if a form is `create`, `edit` or `view`, use the `$operation` parameter:

```php
function (string $operation) {
    // ...
}
```

> Outside the panel, you can set a form's operation by using the `operation()` method on the form definition.

### Injecting multiple utilities

The parameters are injected dynamically using reflection, so you are able to combine multiple parameters in any order:

```php
use Filament\Forms\Get;
use Filament\Forms\Set;
use Livewire\Component as Livewire;

function (Livewire $livewire, Get $get, Set $set) {
    // ...
}
```

### Injecting dependencies from Laravel's container

You may inject anything from Laravel's container like normal, alongside utilities:

```php
use Filament\Forms\Set;
use Illuminate\Http\Request;

function (Request $request, Set $set) {
    // ...
}
```

## Field lifecycle

Each field in a form has a lifecycle, which is the process it goes through when the form is loaded, when it is interacted with by the user, and when it is submitted. You may customize what happens at each stage of this lifecycle using a function that gets run at that stage.

### Field hydration

Hydration is the process that fills fields with data. It runs when you call the form's `fill()` method. You may customize what happens after a field is hydrated using the `afterStateHydrated()` method.

In this example, the `name` field will always be hydrated with the correctly capitalized name:

```php
use Closure;
use Filament\Forms\Components\TextInput;

TextInput::make('name')
    ->required()
    ->afterStateHydrated(function (TextInput $component, string $state) {
        $component->state(ucwords($state));
    })
```

As a shortcut for formatting the field's state like this when it is hydrated, you can use the `formatStateUsing()` method:

```php
use Closure;
use Filament\Forms\Components\TextInput;

TextInput::make('name')
    ->formatStateUsing(fn (string $state): string => ucwords($state))
```

### Field updates

You may use the `afterStateUpdated()` method to customize what happens after a field is updated by the user. Only changes from the user on the frontend will trigger this function, not manual changes to the state from `$set()` or another PHP function.

Inside this function, you can also inject the `$old` value of the field before it was updated, using the `$old` parameter:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('name')
    ->afterStateUpdated(function (?string $state, ?string $old) {
        // ...
    })
```

For an example of how to use this method, learn how to [automatically generate a slug from a title](#generating-a-slug-from-a-title).

### Field dehydration

Dehydration is the process that gets data from the fields in your forms, and transforms it. It runs when you call the form's `getState()` method.

You may customize how the state is transformed when it is dehydrated using the `dehydrateStateUsing()` function. In this example, the `name` field will always be dehydrated with the correctly capitalized name:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('name')
    ->required()
    ->dehydrateStateUsing(fn (string $state): string => ucwords($state))
```

#### Preventing a field from being dehydrated

You may also prevent a field from being dehydrated altogether using `dehydrated(false)`. In this example, the field will not be present in the array returned from `getState()`:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('password_confirmation')
    ->password()
    ->dehydrated(false)
```

If your form auto-saves data to the database, like in a [resource](../panels/resources/getting-started) or [table action](../tables/actions), this is useful to prevent a field from being saved to the database if it is purely used for presentational purposes.

## Reactive forms cookbook

This section contains a collection of recipes for common tasks you may need to perform when building an advanced form.

### Conditionally hiding a field

To conditionally hide or show a field, you can pass a function to the `hidden()` method, and return `true` or `false` depending on whether you want the field to be hidden or not. The function can [inject utilities](#form-component-utility-injection) as parameters, so you can do things like check the value of another field:

```php
use Filament\Forms\Get;
use Filament\Forms\Components\Checkbox;
use Filament\Forms\Components\TextInput;

Checkbox::make('is_company')
    ->live()

TextInput::make('company_name')
    ->hidden(fn (Get $get): bool => ! $get('is_company'))
```

In this example, the `is_company` checkbox is [`live()`](#the-basics-of-reactivity). This allows the form to rerender when the value of the `is_company` field changes. You can access the value of that field from within the `hidden()` function using the [`$get()` utility](#injecting-the-current-state-of-a-field). The value of the field is inverted using `!` so that the `company_name` field is hidden when the `is_company` field is `false`.

Alternatively, you can use the `visible()` method to show a field conditionally. It does the exact inverse of `hidden()`, and could be used if you prefer the clarity of the code when written this way:

```php
use Filament\Forms\Get;
use Filament\Forms\Components\Checkbox;
use Filament\Forms\Components\TextInput;

Checkbox::make('is_company')
    ->live()
    
TextInput::make('company_name')
    ->visible(fn (Get $get): bool => $get('is_company'))
```

### Conditionally making a field required

To conditionally make a field required, you can pass a function to the `required()` method, and return `true` or `false` depending on whether you want the field to be required or not. The function can [inject utilities](#form-component-utility-injection) as parameters, so you can do things like check the value of another field:

```php
use Filament\Forms\Get;
use Filament\Forms\Components\TextInput;

TextInput::make('company_name')
    ->live(onBlur: true)
    
TextInput::make('vat_number')
    ->required(fn (Get $get): bool => filled($get('company_name')))
```

In this example, the `company_name` field is [`live(onBlur: true)`](#reactive-fields-on-blur). This allows the form to rerender after the value of the `company_name` field changes and the user clicks away. You can access the value of that field from within the `required()` function using the [`$get()` utility](#injecting-the-current-state-of-a-field). The value of the field is checked using `filled()` so that the `vat_number` field is required when the `company_name` field is not `null` or an empty string. The result is that the `vat_number` field is only required when the `company_name` field is filled in.

Using a function is able to make any other [validation rule](validation) dynamic in a similar way.

### Generating a slug from a title

To generate a slug from a title while the user is typing, you can use the [`afterStateUpdated()` method](#field-updates) on the title field to [`$set()`](#injecting-a-function-to-set-the-state-of-another-field) the value of the slug field:

```php
use Filament\Forms\Components\TextInput;
use Filament\Forms\Set;
use Illuminate\Support\Str;

TextInput::make('title')
    ->live(onBlur: true)
    ->afterStateUpdated(fn (Set $set, ?string $state) => $set('slug', Str::slug($state)))
    
TextInput::make('slug')
```

In this example, the `title` field is [`live(onBlur: true)`](#reactive-fields-on-blur). This allows the form to rerender when the value of the `title` field changes and the user clicks away. The `afterStateUpdated()` method is used to run a function after the state of the `title` field is updated. The function injects the [`$set()` utility](#injecting-a-function-to-set-the-state-of-another-field) and the new state of the `title` field. The `Str::slug()` utility method is part of Laravel and is used to generate a slug from a string. The `slug` field is then updated using the `$set()` function.

One thing to note is that the user may customize the slug manually, and we don't want to overwrite their changes if the title changes. To prevent this, we can use the old version of the title to work out if the user has modified it themselves. To access the old version of the title, you can inject `$old`, and to get the current value of the slug before it gets changed, we can use the [`$get()` utility](#injecting-the-state-of-another-field):

```php
use Filament\Forms\Components\TextInput;
use Filament\Forms\Get;
use Filament\Forms\Set;
use Illuminate\Support\Str;

TextInput::make('title')
    ->live(onBlur: true)
    ->afterStateUpdated(function (Get $get, Set $set, ?string $old, ?string $state) {
        if (($get('slug') ?? '') !== Str::slug($old)) {
            return;
        }
    
        $set('slug', Str::slug($state));
    })
    
TextInput::make('slug')
```

### Dependant select options

To dynamically update the options of a [select field](fields/select) based on the value of another field, you can pass a function to the `options()` method of the select field. The function can [inject utilities](#form-component-utility-injection) as parameters, so you can do things like check the value of another field using the [`$get()` utility](#injecting-the-current-state-of-a-field):

```php
use Filament\Forms\Get;
use Filament\Forms\Components\Select;

Select::make('category')
    ->options([
        'web' => 'Web development',
        'mobile' => 'Mobile development',
        'design' => 'Design',
    ])
    ->live()

Select::make('sub_category')
    ->options(fn (Get $get): array => match ($get('category')) {
        'web' => [
            'frontend_web' => 'Frontend development',
            'backend_web' => 'Backend development',
        ],
        'mobile' => [
            'ios_mobile' => 'iOS development',
            'android_mobile' => 'Android development',
        ],
        'design' => [
            'app_design' => 'Panel design',
            'marketing_website_design' => 'Marketing website design',
        ],
        default => [],
    })
```

In this example, the `category` field is [`live()`](#the-basics-of-reactivity). This allows the form to rerender when the value of the `category` field changes. You can access the value of that field from within the `options()` function using the [`$get()` utility](#injecting-the-current-state-of-a-field). The value of the field is used to determine which options should be available in the `sub_category` field. The `match ()` statement in PHP is used to return an array of options based on the value of the `category` field. The result is that the `sub_category` field will only show options relevant to the selected `category` field.

You could adapt this example to use options loaded from an Eloquent model or other data source, by querying within the function:

```php
use Filament\Forms\Get;
use Filament\Forms\Components\Select;
use Illuminate\Support\Collection;

Select::make('category')
    ->options(Category::query()->pluck('name', 'id'))
    ->live()
    
Select::make('sub_category')
    ->options(fn (Get $get): Collection => SubCategory::query()
        ->where('category', $get('category'))
        ->pluck('name', 'id'))
```

### Dynamic fields based on a select option

You may wish to render a different set of fields based on the value of a field, like a select. To do this, you can pass a function to the `schema()` method of any [layout component](layout/getting-started), which checks the value of the field and returns a different schema based on that value. Also, you will need a way to initialise the new fields in the dynamic schema when they are first loaded.

```php
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Grid;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Get;

Select::make('type')
    ->options([
        'employee' => 'Employee',
        'freelancer' => 'Freelancer',
    ])
    ->live()
    ->afterStateUpdated(fn (Select $component) => $component
        ->getContainer()
        ->getComponent('dynamicTypeFields')
        ->getChildComponentContainer()
        ->fill())
    
Grid::make(2)
    ->schema(fn (Get $get): array => match ($get('type')) {
        'employee' => [
            TextInput::make('employee_number')
                ->required(),
            FileUpload::make('badge')
                ->image()
                ->required(),
        ],
        'freelancer' => [
            TextInput::make('hourly_rate')
                ->numeric()
                ->required()
                ->prefix('€'),
            FileUpload::make('contract')
                ->required(),
        ],
        default => [],
    })
    ->key('dynamicTypeFields')
```

In this example, the `type` field is [`live()`](#the-basics-of-reactivity). This allows the form to rerender when the value of the `type` field changes. The `afterStateUpdated()` method is used to run a function after the state of the `type` field is updated. In this case, we [inject the current select field instance](#injecting-the-current-form-component-instance), which we can then use to get the form "container" instance that holds both the select and the grid components. With this container, we can target the grid component using a unique key (`dynamicTypeFields`) that we have assigned to it. With that grid component instance, we can call `fill()`, just as we do on a normal form to initialise it. The `schema()` method of the grid component is then used to return a different schema based on the value of the `type` field. This is done by using the [`$get()` utility](#injecting-the-current-state-of-a-field), and returning a different schema array dynamically.

### Auto-hashing password field

You have a password field:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('password')
    ->password()
```

And you can use a [dehydration function](#field-dehydration) to hash the password when the form is submitted:

```php
use Filament\Forms\Components\TextInput;
use Illuminate\Support\Facades\Hash;

TextInput::make('password')
    ->password()
    ->dehydrateStateUsing(fn (string $state): string => Hash::make($state))
```

But if your form is used to change an existing password, you don't want to overwrite the existing password if the field is empty. You can [prevent the field from being dehydrated](#preventing-a-field-from-being-dehydrated) if the field is null or an empty string (using the `filled()` helper):

```php
use Filament\Forms\Components\TextInput;
use Illuminate\Support\Facades\Hash;

TextInput::make('password')
    ->password()
    ->dehydrateStateUsing(fn (string $state): string => Hash::make($state))
    ->dehydrated(fn (?string $state): bool => filled($state))
```

However, you want to require the password to be filled when the user is being created, by [injecting the `$operation` utility](#injecting-the-current-form-operation), and then [conditionally making the field required](#conditionally-making-a-field-required):

```php
use Filament\Forms\Components\TextInput;
use Illuminate\Support\Facades\Hash;

TextInput::make('password')
    ->password()
    ->dehydrateStateUsing(fn (string $state): string => Hash::make($state))
    ->dehydrated(fn (?string $state): bool => filled($state))
    ->required(fn (string $operation): bool => $operation === 'create')
```

## Saving data to relationships

> If you're building a form inside your Livewire component, make sure you have set up the [form's model](adding-a-form-to-a-livewire-component#setting-a-form-model). Otherwise, Filament doesn't know which model to use to retrieve the relationship from.

As well as being able to give structure to fields, [layout components](layout/getting-started) are also able to "teleport" their nested fields into a relationship. Filament will handle loading data from a `HasOne`, `BelongsTo` or `MorphOne` Eloquent relationship, and then it will save the data back to the same relationship. To set this behavior up, you can use the `relationship()` method on any layout component:

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

This functionality is not just limited to fieldsets - you can use it with any layout component. For example, you could use a `Group` component which has no styling associated with it:

```php
use Filament\Forms\Components\Group;
use Filament\Forms\Components\TextInput;

Group::make()
    ->relationship('customer')
    ->schema([
        TextInput::make('name')
            ->label('Customer')
            ->required(),
        TextInput::make('email')
            ->label('Email address')
            ->email()
            ->required(),
    ])
```

### Saving data to a `BelongsTo` relationship

Please note that if you are saving the data to a `BelongsTo` relationship, then the foreign key column in your database must be `nullable()`. This is because Filament saves the form first, before saving the relationship. Since the form is saved first, the foreign ID does not exist yet, so it must be nullable. Immediately after the form is saved, Filament saves the relationship, which will then fill in the foreign ID and save it again.

It is worth noting that if you have an observer on your form model, then you may need to adapt it to ensure that it does not depend on the relationship existing when it it created. For example, if you have an observer that sends an email to a related record when a form is created, you may need to switch to using a different hook that runs after the relationship is attached, like `updated()`.

### Conditionally saving data to a relationship

Sometimes, saving the related record may be optional. If the user fills out the customer fields, then the customer will be created / updated. Otherwise, the customer will not be created, or will be deleted if it already exists. To do this, you can pass a `condition` function as an argument to `relationship()`, which can use the `$state` of the related form to determine whether the relationship should be saved or not:

```php
use Filament\Forms\Components\Group;
use Filament\Forms\Components\TextInput;

Group::make()
    ->relationship(
        'customer',
        condition: fn (?array $state): bool => filled($state['name']),
    )
    ->schema([
        TextInput::make('name')
            ->label('Customer'),
        TextInput::make('email')
            ->label('Email address')
            ->email()
            ->requiredWith('name'),
    ])
```

In this example, the customer's name is not `required()`, and the email address is only required when the `name` is filled. The `condition` function is used to check whether the `name` field is filled, and if it is, then the customer will be created / updated. Otherwise, the customer will not be created, or will be deleted if it already exists.

## Inserting Livewire components into a form

You may insert a Livewire component directly into a form:

```php
use Filament\Forms\Components\Livewire;
use App\Livewire\Foo;

Livewire::make(Foo::class)
```

If you are rendering multiple of the same Livewire component, please make sure to pass a unique `key()` to each:

```php
use Filament\Forms\Components\Livewire;
use App\Livewire\Foo;

Livewire::make(Foo::class)
    ->key('foo-first')

Livewire::make(Foo::class)
    ->key('foo-second')

Livewire::make(Foo::class)
    ->key('foo-third')
```

### Passing parameters to a Livewire component

You can pass an array of parameters to a Livewire component:

```php
use Filament\Forms\Components\Livewire;
use App\Livewire\Foo;

Livewire::make(Foo::class, ['bar' => 'baz'])
```

Now, those parameters will be passed to the Livewire component's `mount()` method:

```php
class Foo extends Component
{
    public function mount(string $bar): void
    {       
        // ...
    }
}
```

Alternatively, they will be available as public properties on the Livewire component:

```php
class Foo extends Component
{
    public string $bar;
}
```

#### Accessing the current record in the Livewire component

You can access the current record in the Livewire component using the `$record` parameter in the `mount()` method, or the `$record` property:

```php
use Illuminate\Database\Eloquent\Model;

class Foo extends Component
{
    public function mount(?Model $record = null): void
    {       
        // ...
    }
    
    // or
    
    public ?Model $record = null;
}
```

Please be aware that when the record has not yet been created, it will be `null`. If you'd like to hide the Livewire component when the record is `null`, you can use the `hidden()` method:

```php
use Filament\Forms\Components\Livewire;
use Illuminate\Database\Eloquent\Model;

Livewire::make(Foo::class)
    ->hidden(fn (?Model $record): bool => $record === null)
```

### Lazy loading a Livewire component

You may allow the component to [lazily load](https://livewire.laravel.com/docs/lazy#rendering-placeholder-html) using the `lazy()` method:

```php
use Filament\Forms\Components\Livewire;
use App\Livewire\Foo;

Livewire::make(Foo::class)->lazy()       
```

# Documentation for forms. File: 08-adding-a-form-to-a-livewire-component.md
---
title: Adding a form to a Livewire component
---

## Setting up the Livewire component

First, generate a new Livewire component:

```bash
php artisan make:livewire CreatePost
```

Then, render your Livewire component on the page:

```blade
@livewire('create-post')
```

Alternatively, you can use a full-page Livewire component:

```php
use App\Livewire\CreatePost;
use Illuminate\Support\Facades\Route;

Route::get('posts/create', CreatePost::class);
```

## Adding the form

There are 5 main tasks when adding a form to a Livewire component class. Each one is essential:

1) Implement the `HasForms` interface and use the `InteractsWithForms` trait.
2) Define a public Livewire property to store your form's data. In our example, we'll call this `$data`, but you can call it whatever you want.
3) Add a `form()` method, which is where you configure the form. [Add the form's schema](getting-started#form-schemas), and tell Filament to store the form data in the `$data` property (using `statePath('data')`).
4) Initialize the form with `$this->form->fill()` in `mount()`. This is imperative for every form that you build, even if it doesn't have any initial data.
5) Define a method to handle the form submission. In our example, we'll call this `create()`, but you can call it whatever you want. Inside that method, you can validate and get the form's data using `$this->form->getState()`. It's important that you use this method instead of accessing the `$this->data` property directly, because the form's data needs to be validated and transformed into a useful format before being returned.

```php
<?php

namespace App\Livewire;

use App\Models\Post;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\MarkdownEditor;
use Filament\Forms\Concerns\InteractsWithForms;
use Filament\Forms\Contracts\HasForms;
use Filament\Forms\Form;
use Illuminate\Contracts\View\View;
use Livewire\Component;

class CreatePost extends Component implements HasForms
{
    use InteractsWithForms;
    
    public ?array $data = [];
    
    public function mount(): void
    {
        $this->form->fill();
    }
    
    public function form(Form $form): Form
    {
        return $form
            ->schema([
                TextInput::make('title')
                    ->required(),
                MarkdownEditor::make('content'),
                // ...
            ])
            ->statePath('data');
    }
    
    public function create(): void
    {
        dd($this->form->getState());
    }
    
    public function render(): View
    {
        return view('livewire.create-post');
    }
}
```

Finally, in your Livewire component's view, render the form:

```blade
<div>
    <form wire:submit="create">
        {{ $this->form }}
        
        <button type="submit">
            Submit
        </button>
    </form>
    
    <x-filament-actions::modals />
</div>
```

> `<x-filament-actions::modals />` is used to render form component [action modals](actions). The code can be put anywhere outside the `<form>` element, as long as it's within the Livewire component.

Visit your Livewire component in the browser, and you should see the form components from `schema()`:

Submit the form with data, and you'll see the form's data dumped to the screen. You can save the data to a model instead of dumping it:

```php
use App\Models\Post;

public function create(): void
{
    Post::create($this->form->getState());
}
```

## Initializing the form with data

To fill the form with data, just pass that data to the `$this->form->fill()` method. For example, if you're editing an existing post, you might do something like this:

```php
use App\Models\Post;

public function mount(Post $post): void
{
    $this->form->fill($post->toArray());
}
```

It's important that you use the `$this->form->fill()` method instead of assigning the data directly to the `$this->data` property. This is because the post's data needs to be internally transformed into a useful format before being stored.

## Setting a form model

Giving the `$form` access to a model is useful for a few reasons:

- It allows fields within that form to load information from that model. For example, select fields can [load their options from the database](fields/select#integrating-with-an-eloquent-relationship) automatically.
- The form can load and save the model's relationship data automatically. For example, you have an Edit Post form, with a [Repeater](fields/repeater#integrating-with-an-eloquent-relationship) which manages comments associated with that post. Filament will automatically load the comments for that post when you call `$this->form->fill([...])`, and save them back to the relationship when you call `$this->form->getState()`.
- Validation rules like `exists()` and `unique()` can automatically retrieve the database table name from the model.

It is advised to always pass the model to the form when there is one. As explained, it unlocks many new powers of the Filament Form Builder.

To pass the model to the form, use the `$form->model()` method:

```php
use App\Models\Post;
use Filament\Forms\Form;

public Post $post;

public function form(Form $form): Form
{
    return $form
        ->schema([
            // ...
        ])
        ->statePath('data')
        ->model($this->post);
}
```

### Passing the form model after the form has been submitted

In some cases, the form's model is not available until the form has been submitted. For example, in a Create Post form, the post does not exist until the form has been submitted. Therefore, you can't pass it in to `$form->model()`. However, you can pass a model class instead:

```php
use App\Models\Post;
use Filament\Forms\Form;

public function form(Form $form): Form
{
    return $form
        ->schema([
            // ...
        ])
        ->statePath('data')
        ->model(Post::class);
}
```

On its own, this isn't as powerful as passing a model instance. For example, relationships won't be saved to the post after it is created. To do that, you'll need to pass the post to the form after it has been created, and call `saveRelationships()` to save the relationships to it:

```php
use App\Models\Post;

public function create(): void
{
    $post = Post::create($this->form->getState());
    
    // Save the relationships from the form to the post after it is created.
    $this->form->model($post)->saveRelationships();
}
```

## Saving form data to individual properties

In all of our previous examples, we've been saving the form's data to the public `$data` property on the Livewire component. However, you can save the data to individual properties instead. For example, if you have a form with a `title` field, you can save the form's data to the `$title` property instead. To do this, don't pass a `statePath()` to the form at all. Ensure that all of your fields have their own **public** properties on the class.

```php
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\MarkdownEditor;
use Filament\Forms\Form;

public ?string $title = null;

public ?string $content = null;

public function form(Form $form): Form
{
    return $form
        ->schema([
            TextInput::make('title')
                ->required(),
            MarkdownEditor::make('content'),
            // ...
        ]);
}
```

## Using multiple forms

By default, the `InteractsWithForms` trait only handles one form per Livewire component - `form()`. To add more forms to the Livewire component, you can define them in the `getForms()` method, and return an array containing the name of each form:

```php
protected function getForms(): array
{
    return [
        'editPostForm',
        'createCommentForm',
    ];
}
```

Each of these forms can now be defined within the Livewire component, using a method with the same name:

```php
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\MarkdownEditor;
use Filament\Forms\Form;

public function editPostForm(Form $form): Form
{
    return $form
        ->schema([
            TextInput::make('title')
                ->required(),
            MarkdownEditor::make('content'),
            // ...
        ])
        ->statePath('postData')
        ->model($this->post);
}

public function createCommentForm(Form $form): Form
{
    return $form
        ->schema([
            TextInput::make('name')
                ->required(),
            TextInput::make('email')
                ->email()
                ->required(),
            MarkdownEditor::make('content')
                ->required(),
            // ...
        ])
        ->statePath('commentData')
        ->model(Comment::class);
}
```

Now, each form is addressable by its name instead of `form`. For example, to fill the post form, you can use `$this->editPostForm->fill([...])`, or to get the data from the comment form you can use `$this->createCommentForm->getState()`.

You'll notice that each form has its own unique `statePath()`. Each form will write its state to a different array on your Livewire component, so it's important to define these:

```php
public ?array $postData = [];
public ?array $commentData = [];
```

## Resetting a form's data

You can reset a form back to its default data at any time by calling `$this->form->fill()`. For example, you may wish to clear the contents of a form every time it's submitted:

```php
use App\Models\Comment;

public function createComment(): void
{
    Comment::create($this->form->getState());

    // Reinitialize the form to clear its data.
    $this->form->fill();
}
```

## Generating form Livewire components with the CLI

It's advised that you learn how to set up a Livewire component with the Form Builder manually, but once you are confident, you can use the CLI to generate a form for you.

```bash
php artisan make:livewire-form RegistrationForm
```

This will generate a new `app/Livewire/RegistrationForm.php` component, which you can customize.

### Generating a form for an Eloquent model

Filament is also able to generate forms for a specific Eloquent model. These are more powerful, as they will automatically save the data in the form for you, and [ensure the form fields are properly configured](#setting-a-form-model) to access that model.

When generating a form with the `make:livewire-form` command, it will ask for the name of the model:

```bash
php artisan make:livewire-form Products/CreateProduct
```

#### Generating an edit form for an Eloquent record

By default, passing a model to the `make:livewire-form` command will result in a form that creates a new record in your database. If you pass the `--edit` flag to the command, it will generate an edit form for a specific record. This will automatically fill the form with the data from the record, and save the data back to the model when the form is submitted.

```bash
php artisan make:livewire-form Products/EditProduct --edit
```

### Automatically generating form schemas

Filament is also able to guess which form fields you want in the schema, based on the model's database columns. You can use the `--generate` flag when generating your form:

```bash
php artisan make:livewire-form Products/CreateProduct --generate
```

# Documentation for forms. File: 09-testing.md
---
title: Testing
---

## Overview

All examples in this guide will be written using [Pest](https://pestphp.com). To use Pest's Livewire plugin for testing, you can follow the installation instructions in the Pest documentation on plugins: [Livewire plugin for Pest](https://pestphp.com/docs/plugins#livewire). However, you can easily adapt this to PHPUnit.

Since the Form Builder works on Livewire components, you can use the [Livewire testing helpers](https://livewire.laravel.com/docs/testing). However, we have custom testing helpers that you can use with forms:

## Filling a form

To fill a form with data, pass the data to `fillForm()`:

```php
use function Pest\Livewire\livewire;

livewire(CreatePost::class)
    ->fillForm([
        'title' => fake()->sentence(),
        // ...
    ]);
```

> If you have multiple forms on a Livewire component, you can specify which form you want to fill using `fillForm([...], 'createPostForm')`.

To check that a form has data, use `assertFormSet()`:

```php
use Illuminate\Support\Str;
use function Pest\Livewire\livewire;

it('can automatically generate a slug from the title', function () {
    $title = fake()->sentence();

    livewire(CreatePost::class)
        ->fillForm([
            'title' => $title,
        ])
        ->assertFormSet([
            'slug' => Str::slug($title),
        ]);
});
```

> If you have multiple forms on a Livewire component, you can specify which form you want to check using `assertFormSet([...], 'createPostForm')`.

You may also find it useful to pass a function to the `assertFormSet()` method, which allows you to access the form `$state` and perform additional assertions:

```php
use Illuminate\Support\Str;
use function Pest\Livewire\livewire;

it('can automatically generate a slug from the title without any spaces', function () {
    $title = fake()->sentence();

    livewire(CreatePost::class)
        ->fillForm([
            'title' => $title,
        ])
        ->assertFormSet(function (array $state): array {
            expect($state['slug'])
                ->not->toContain(' ');
                
            return [
                'slug' => Str::slug($title),
            ];
        });
});
```

You can return an array from the function if you want Filament to continue to assert the form state after the function has been run.

## Validation

Use `assertHasFormErrors()` to ensure that data is properly validated in a form:

```php
use function Pest\Livewire\livewire;

it('can validate input', function () {
    livewire(CreatePost::class)
        ->fillForm([
            'title' => null,
        ])
        ->call('create')
        ->assertHasFormErrors(['title' => 'required']);
});
```

And `assertHasNoFormErrors()` to ensure there are no validation errors:

```php
use function Pest\Livewire\livewire;

livewire(CreatePost::class)
    ->fillForm([
        'title' => fake()->sentence(),
        // ...
    ])
    ->call('create')
    ->assertHasNoFormErrors();
```

> If you have multiple forms on a Livewire component, you can pass the name of a specific form as the second parameter like `assertHasFormErrors(['title' => 'required'], 'createPostForm')` or `assertHasNoFormErrors([], 'createPostForm')`.

## Form existence

To check that a Livewire component has a form, use `assertFormExists()`:

```php
use function Pest\Livewire\livewire;

it('has a form', function () {
    livewire(CreatePost::class)
        ->assertFormExists();
});
```

> If you have multiple forms on a Livewire component, you can pass the name of a specific form like `assertFormExists('createPostForm')`.

## Fields

To ensure that a form has a given field, pass the field name to `assertFormFieldExists()`:

```php
use function Pest\Livewire\livewire;

it('has a title field', function () {
    livewire(CreatePost::class)
        ->assertFormFieldExists('title');
});
```

You may pass a function as an additional argument in order to assert that a field passes a given "truth test". This is useful for asserting that a field has a specific configuration:

```php
use function Pest\Livewire\livewire;

it('has a title field', function () {
    livewire(CreatePost::class)
        ->assertFormFieldExists('title', function (TextInput $field): bool {
            return $field->isDisabled();
        });
});
```

To assert that a form does not have a given field, pass the field name to `assertFormFieldDoesNotExist()`:

```php
use function Pest\Livewire\livewire;

it('does not have a conditional field', function () {
    livewire(CreatePost::class)
        ->assertFormFieldDoesNotExist('no-such-field');
});
```

> If you have multiple forms on a Livewire component, you can specify which form you want to check for the existence of the field like `assertFormFieldExists('title', 'createPostForm')`.

### Hidden fields

To ensure that a field is visible, pass the name to `assertFormFieldIsVisible()`:

```php
use function Pest\Livewire\livewire;

test('title is visible', function () {
    livewire(CreatePost::class)
        ->assertFormFieldIsVisible('title');
});
```

Or to ensure that a field is hidden you can pass the name to `assertFormFieldIsHidden()`:

```php
use function Pest\Livewire\livewire;

test('title is hidden', function () {
    livewire(CreatePost::class)
        ->assertFormFieldIsHidden('title');
});
```

> For both `assertFormFieldIsHidden()` and `assertFormFieldIsVisible()` you can pass the name of a specific form the field belongs to as the second argument like `assertFormFieldIsHidden('title', 'createPostForm')`.

### Disabled fields

To ensure that a field is enabled, pass the name to `assertFormFieldIsEnabled()`:

```php
use function Pest\Livewire\livewire;

test('title is enabled', function () {
    livewire(CreatePost::class)
        ->assertFormFieldIsEnabled('title');
});
```

Or to ensure that a field is disabled you can pass the name to `assertFormFieldIsDisabled()`:

```php
use function Pest\Livewire\livewire;

test('title is disabled', function () {
    livewire(CreatePost::class)
        ->assertFormFieldIsDisabled('title');
});
```

> For both `assertFormFieldIsEnabled()` and `assertFormFieldIsDisabled()` you can pass the name of a specific form the field belongs to as the second argument like `assertFormFieldIsEnabled('title', 'createPostForm')`.

## Layout components

If you need to check if a particular layout component exists rather than a field, you may use `assertFormComponentExists()`.  As layout components do not have names, this method uses the `key()` provided by the developer:

```php
use Filament\Forms\Components\Section;

Section::make('Comments')
    ->key('comments-section')
    ->schema([
        //
    ])
```

```php
use function Pest\Livewire\livewire;

test('comments section exists', function () {
    livewire(EditPost::class)
        ->assertFormComponentExists('comments-section');
});
```

To assert that a form does not have a given component, pass the component key to `assertFormComponentDoesNotExist()`:

```php
use function Pest\Livewire\livewire;

it('does not have a conditional component', function () {
    livewire(CreatePost::class)
        ->assertFormComponentDoesNotExist('no-such-section');
});
```

To check if the component exists and passes a given truth test, you can pass a function to the second argument of `assertFormComponentExists()`, returning true or false if the component passes the test or not:

```php
use Filament\Forms\Components\Component;

use function Pest\Livewire\livewire;

test('comments section has heading', function () {
    livewire(EditPost::class)
        ->assertFormComponentExists(
            'comments-section',
            function (Component $component): bool {
                return $component->getHeading() === 'Comments';
            },
        );
});
```

If you want more informative test results, you can embed an assertion within your truth test callback:

```php
use Filament\Forms\Components\Component;
use Illuminate\Testing\Assert;

use function Pest\Livewire\livewire;

test('comments section is enabled', function () {
    livewire(EditPost::class)
        ->assertFormComponentExists(
            'comments-section',
            function (Component $component): bool {
                Assert::assertTrue(
                    $component->isEnabled(),
                    'Failed asserting that comments-section is enabled.',
                );
                
                return true;
            },
        );
});
```

### Wizard

To go to a wizard's next step, use `goToNextWizardStep()`:

```php
use function Pest\Livewire\livewire;

it('moves to next wizard step', function () {
    livewire(CreatePost::class)
        ->goToNextWizardStep()
        ->assertHasFormErrors(['title']);
});
```

You can also go to the previous step by calling `goToPreviousWizardStep()`:

```php
use function Pest\Livewire\livewire;

it('moves to next wizard step', function () {
    livewire(CreatePost::class)
        ->goToPreviousWizardStep()
        ->assertHasFormErrors(['title']);
});
```

If you want to go to a specific step, use `goToWizardStep()`, then the `assertWizardCurrentStep` method which can ensure you are on the desired step without validation errors from the previous:

```php
use function Pest\Livewire\livewire;

it('moves to the wizards second step', function () {
    livewire(CreatePost::class)
        ->goToWizardStep(2)
        ->assertWizardCurrentStep(2);
});
```

If you have multiple forms on a single Livewire component, any of the wizard test helpers can accept a `formName` parameter:

```php
use function Pest\Livewire\livewire;

it('moves to next wizard step only for fooForm', function () {
    livewire(CreatePost::class)
        ->goToNextWizardStep(formName: 'fooForm')
        ->assertHasFormErrors(['title'], formName: 'fooForm');
});
```

## Actions

You can call an action by passing its form component name, and then the name of the action to `callFormComponentAction()`:

```php
use function Pest\Livewire\livewire;

it('can send invoices', function () {
    $invoice = Invoice::factory()->create();

    livewire(EditInvoice::class, [
        'invoice' => $invoice,
    ])
        ->callFormComponentAction('customer_id', 'send');

    expect($invoice->refresh())
        ->isSent()->toBeTrue();
});
```

To pass an array of data into an action, use the `data` parameter:

```php
use function Pest\Livewire\livewire;

it('can send invoices', function () {
    $invoice = Invoice::factory()->create();

    livewire(EditInvoice::class, [
        'invoice' => $invoice,
    ])
        ->callFormComponentAction('customer_id', 'send', data: [
            'email' => $email = fake()->email(),
        ])
        ->assertHasNoFormComponentActionErrors();

    expect($invoice->refresh())
        ->isSent()->toBeTrue()
        ->recipient_email->toBe($email);
});
```

If you ever need to only set an action's data without immediately calling it, you can use `setFormComponentActionData()`:

```php
use function Pest\Livewire\livewire;

it('can send invoices', function () {
    $invoice = Invoice::factory()->create();

    livewire(EditInvoice::class, [
        'invoice' => $invoice,
    ])
        ->mountFormComponentAction('customer_id', 'send')
        ->setFormComponentActionData([
            'email' => $email = fake()->email(),
        ])
});
```

### Execution

To check if an action has been halted, you can use `assertFormComponentActionHalted()`:

```php
use function Pest\Livewire\livewire;

it('stops sending if invoice has no email address', function () {
    $invoice = Invoice::factory(['email' => null])->create();

    livewire(EditInvoice::class, [
        'invoice' => $invoice,
    ])
        ->callFormComponentAction('customer_id', 'send')
        ->assertFormComponentActionHalted('customer_id', 'send');
});
```

### Errors

`assertHasNoFormComponentActionErrors()` is used to assert that no validation errors occurred when submitting the action form.

To check if a validation error has occurred with the data, use `assertHasFormComponentActionErrors()`, similar to `assertHasErrors()` in Livewire:

```php
use function Pest\Livewire\livewire;

it('can validate invoice recipient email', function () {
    $invoice = Invoice::factory()->create();

    livewire(EditInvoice::class, [
        'invoice' => $invoice,
    ])
        ->callFormComponentAction('customer_id', 'send', data: [
            'email' => Str::random(),
        ])
        ->assertHasFormComponentActionErrors(['email' => ['email']]);
});
```

To check if an action is pre-filled with data, you can use the `assertFormComponentActionDataSet()` method:

```php
use function Pest\Livewire\livewire;

it('can send invoices to the primary contact by default', function () {
    $invoice = Invoice::factory()->create();
    $recipientEmail = $invoice->company->primaryContact->email;

    livewire(EditInvoice::class, [
        'invoice' => $invoice,
    ])
        ->mountFormComponentAction('customer_id', 'send')
        ->assertFormComponentActionDataSet([
            'email' => $recipientEmail,
        ])
        ->callMountedFormComponentAction()
        ->assertHasNoFormComponentActionErrors();
        
    expect($invoice->refresh())
        ->isSent()->toBeTrue()
        ->recipient_email->toBe($recipientEmail);
});
```

### Action state

To ensure that an action exists or doesn't in a form, you can use the `assertFormComponentActionExists()` or  `assertFormComponentActionDoesNotExist()` method:

```php
use function Pest\Livewire\livewire;

it('can send but not unsend invoices', function () {
    $invoice = Invoice::factory()->create();

    livewire(EditInvoice::class, [
        'invoice' => $invoice,
    ])
        ->assertFormComponentActionExists('customer_id', 'send')
        ->assertFormComponentActionDoesNotExist('customer_id', 'unsend');
});
```

To ensure an action is hidden or visible for a user, you can use the `assertFormComponentActionHidden()` or `assertFormComponentActionVisible()` methods:

```php
use function Pest\Livewire\livewire;

it('can only print customers', function () {
    $invoice = Invoice::factory()->create();

    livewire(EditInvoice::class, [
        'invoice' => $invoice,
    ])
        ->assertFormComponentActionHidden('customer_id', 'send')
        ->assertFormComponentActionVisible('customer_id', 'print');
});
```

To ensure an action is enabled or disabled for a user, you can use the `assertFormComponentActionEnabled()` or `assertFormComponentActionDisabled()` methods:

```php
use function Pest\Livewire\livewire;

it('can only print a customer for a sent invoice', function () {
    $invoice = Invoice::factory()->create();

    livewire(EditInvoice::class, [
        'invoice' => $invoice,
    ])
        ->assertFormComponentActionDisabled('customer_id', 'send')
        ->assertFormComponentActionEnabled('customer_id', 'print');
});
```

To check if an action is hidden to a user, you can use the `assertFormComponentActionHidden()` method:

```php
use function Pest\Livewire\livewire;

it('can not send invoices', function () {
    $invoice = Invoice::factory()->create();

    livewire(EditInvoice::class, [
        'invoice' => $invoice,
    ])
        ->assertFormComponentActionHidden('customer_id', 'send');
});
```

### Button appearance

To ensure an action has the correct label, you can use `assertFormComponentActionHasLabel()` and `assertFormComponentActionDoesNotHaveLabel()`:

```php
use function Pest\Livewire\livewire;

it('send action has correct label', function () {
    $invoice = Invoice::factory()->create();

    livewire(EditInvoice::class, [
        'invoice' => $invoice,
    ])
        ->assertFormComponentActionHasLabel('customer_id', 'send', 'Email Invoice')
        ->assertFormComponentActionDoesNotHaveLabel('customer_id', 'send', 'Send');
});
```

To ensure an action's button is showing the correct icon, you can use `assertFormComponentActionHasIcon()` or `assertFormComponentActionDoesNotHaveIcon()`:

```php
use function Pest\Livewire\livewire;

it('when enabled the send button has correct icon', function () {
    $invoice = Invoice::factory()->create();

    livewire(EditInvoice::class, [
        'invoice' => $invoice,
    ])
        ->assertFormComponentActionEnabled('customer_id', 'send')
        ->assertFormComponentActionHasIcon('customer_id', 'send', 'envelope-open')
        ->assertFormComponentActionDoesNotHaveIcon('customer_id', 'send', 'envelope');
});
```

To ensure that an action's button is displaying the right color, you can use `assertFormComponentActionHasColor()` or `assertFormComponentActionDoesNotHaveColor()`:

```php
use function Pest\Livewire\livewire;

it('actions display proper colors', function () {
    $invoice = Invoice::factory()->create();

    livewire(EditInvoice::class, [
        'invoice' => $invoice,
    ])
        ->assertFormComponentActionHasColor('customer_id', 'delete', 'danger')
        ->assertFormComponentActionDoesNotHaveColor('customer_id', 'print', 'danger');
});
```

### URL

To ensure an action has the correct URL, you can use `assertFormComponentActionHasUrl()`, `assertFormComponentActionDoesNotHaveUrl()`, `assertFormComponentActionShouldOpenUrlInNewTab()`, and `assertFormComponentActionShouldNotOpenUrlInNewTab()`:

```php
use function Pest\Livewire\livewire;

it('links to the correct Filament sites', function () {
    $invoice = Invoice::factory()->create();

    livewire(EditInvoice::class, [
        'invoice' => $invoice,
    ])
        ->assertFormComponentActionHasUrl('customer_id', 'filament', 'https://filamentphp.com/')
        ->assertFormComponentActionDoesNotHaveUrl('customer_id', 'filament', 'https://github.com/filamentphp/filament')
        ->assertFormComponentActionShouldOpenUrlInNewTab('customer_id', 'filament')
        ->assertFormComponentActionShouldNotOpenUrlInNewTab('customer_id', 'github');
});
```

# Documentation for forms. File: 10-upgrade-guide.md
---
title: Upgrading from v2.x
---

> If you see anything missing from this guide, please do not hesitate to [make a pull request](https://github.com/filamentphp/filament/edit/3.x/packages/forms/docs/10-upgrade-guide.md) to our repository! Any help is appreciated!

## New requirements

- Laravel v10.0+
- Livewire v3.0+

Please upgrade Filament before upgrading to Livewire v3. Instructions on how to upgrade Livewire can be found [here](https://livewire.laravel.com/docs/upgrading).

## Upgrading automatically

The easiest way to upgrade your app is to run the automated upgrade script. This script will automatically upgrade your application to the latest version of Filament, and make changes to your code which handle most breaking changes.

```bash
composer require filament/upgrade:"^3.2" -W --dev
vendor/bin/filament-v3
```

Make sure to carefully follow the instructions, and review the changes made by the script. You may need to make some manual changes to your code afterwards, but the script should handle most of the repetitive work for you.

Finally, you must run `php artisan filament:install` to finalize the Filament v3 installation. This command must be run for all new Filament projects.

You can now `composer remove filament/upgrade` as you don't need it anymore.

> Some plugins you're using may not be available in v3 just yet. You could temporarily remove them from your `composer.json` file until they've been upgraded, replace them with a similar plugins that are v3-compatible, wait for the plugins to be upgraded before upgrading your app, or even write PRs to help the authors upgrade them.

## Upgrading manually

After upgrading the dependency via Composer, you should execute `php artisan filament:upgrade` in order to clear any Laravel caches and publish the new frontend assets.

### High-impact changes

#### Config file renamed and combined with other Filament packages

Only one config file is now used for all Filament packages. Most configuration has been moved into other parts of the codebase, and little remains. You should use the v3 documentation as a reference when replace the configuration options you did modify. To publish the new configuration file and remove the old one, run:

```bash
php artisan vendor:publish --tag=filament-config --force
rm config/forms.php
```

#### `FORMS_FILESYSTEM_DRIVER` .env variable

The `FORMS_FILESYSTEM_DRIVER` .env variable has been renamed to `FILAMENT_FILESYSTEM_DISK`. This is to make it more consistent with Laravel, as Laravel v9 introduced this change as well. Please ensure that you update your .env files accordingly, and don't forget production!

#### New `@filamentScripts` and `@filamentStyles` Blade directives

The `@filamentScripts` and `@filamentStyles` Blade directives must be added to your Blade layout file/s. Since Livewire v3 no longer uses similar directives, you can replace `@livewireScripts` with `@filamentScripts`  and `@livewireStyles` with `@filamentStyles`.

#### CSS file removed

The CSS file for form components, `module.esm.css`, has been removed. Check `resources/css/app.css`. That CSS is now automatically loaded by `@filamentStyles`.

#### JavaScript files removed

You no longer need to import the `FormsAlpinePlugin` in your JavaScript files. Alpine plugins are now automatically loaded by `@filamentScripts`.

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

`$get` and `$set` parameters now use a type of either `\Filament\Forms\Get` or `\Filament\Forms\Set` instead of `\Closure`. This allows for better IDE autocomplete support of each function's parameters.

An easy way to upgrade your code quickly is to find and replace:

- `Closure $get` to `\Filament\Forms\Get $get`
- `Closure $set` to `\Filament\Forms\Set $set`

#### `TextInput` masks now use Alpine.js' masking package

Filament v2 had a fluent mask object syntax for managing input masks. In v3, you can use Alpine.js's masking syntax instead. Please see the [input masking documentation](fields/text-input#input-masking) for more information.

### Low-impact changes

#### Rule modification callback parameter renamed

The parameter for modifying rule objects has been renamed to `modifyRuleUsing()`, affecting:

- `exists()`
- `unique()`

