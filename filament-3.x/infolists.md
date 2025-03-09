# Documentation for infolists. File: 01-installation.md
---
title: Installation
---

**The Infolist Builder package is pre-installed with the [Panel Builder](/docs/panels).** This guide is for using the Infolist Builder package in a custom TALL Stack application (Tailwind, Alpine, Livewire, Laravel).

## Requirements

Filament requires the following to run:

- PHP 8.1+
- Laravel v10.0+
- Livewire v3.0+
- Tailwind v3.0+ [(Using Tailwind v4?)](#installing-tailwind-css)

## Installation

Require the Infolist Builder package using Composer:

```bash
composer require filament/infolists:"^3.3" -W
```

## New Laravel projects

To quickly get started with Filament in a new Laravel project, run the following commands to install [Livewire](https://livewire.laravel.com), [Alpine.js](https://alpinejs.dev), and [Tailwind CSS](https://tailwindcss.com):

> Since these commands will overwrite existing files in your application, only run this in a new Laravel project!

```bash
php artisan filament:install --scaffold --infolists

npm install

npm run dev
```

## Existing Laravel projects

Run the following command to install the Infolist Builder package assets:

```bash
php artisan filament:install --infolists
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

# Documentation for infolists. File: 02-getting-started.md
---
title: Getting started
---

## Overview

Filament's infolist package allows you to [render a read-only list of data about a particular entity](adding-an-infolist-to-a-livewire-component). It's also used within other Filament packages, such as the [Panel Builder](../panels) for displaying [app resources](../panels/resources/getting-started) and [relation managers](../panels/resources/relation-managers), as well as for [action modals](../actions). Learning the features of the Infolist Builder will be incredibly time-saving when both building your own custom Livewire applications and using Filament's other packages.

This guide will walk you through the basics of building infolists with Filament's infolist package. If you're planning to add a new infolist to your own Livewire component, you should [do that first](adding-an-infolist-to-a-livewire-component) and then come back. If you're adding an infolist to an [app resource](../panels/resources/getting-started), or another Filament package, you're ready to go!

## Defining entries

The first step to building an infolist is to define the entries that will be displayed in the list. You can do this by calling the `schema()` method on an `Infolist` object. This method accepts an array of entry objects.

```php
use Filament\Infolists\Components\TextEntry;

$infolist
    ->schema([
        TextEntry::make('title'),
        TextEntry::make('slug'),
        TextEntry::make('content'),
    ]);
```

Each entry is a piece of information that should be displayed in the infolist. The `TextEntry` is used for displaying text, but there are [other entry types available](entries/getting-started#available-entries).

Infolists within the Panel Builder and other packages usually have 2 columns by default. For custom infolists, you can use the `columns()` method to achieve the same effect:

```php
$infolist
    ->schema([
        // ...
    ])
    ->columns(2);
```

Now, the `content` entry will only consume half of the available width. We can use the `columnSpan()` method to make it span the full width:

```php
use Filament\Infolists\Components\TextEntry;

[
    TextEntry::make('title'),
    TextEntry::make('slug')
    TextEntry::make('content')
        ->columnSpan(2), // or `columnSpan('full')`,
]
```

You can learn more about columns and spans in the [layout documentation](layout/grid). You can even make them responsive!

## Using layout components

The Infolist Builder allows you to use [layout components](layout/getting-started#available-layout-components) inside the schema array to control how entries are displayed. `Section` is a layout component, and it allows you to add a heading and description to a set of entries. It can also allow entries inside it to collapse, which saves space in long infolists.

```php
use Filament\Infolists\Components\Section;
use Filament\Infolists\Components\TextEntry;

[
    TextEntry::make('title'),
    TextEntry::make('slug'),
    TextEntry::make('content')
        ->columnSpan(2)
        ->markdown(),
    Section::make('Media')
        ->description('Images used in the page layout.')
        ->schema([
            // ...
        ]),
]
```

In this example, you can see how the `Section` component has its own `schema()` method. You can use this to nest other entries and layout components inside:

```php
use Filament\Infolists\Components\ImageEntry;
use Filament\Infolists\Components\Section;
use Filament\Infolists\Components\TextEntry;

Section::make('Media')
    ->description('Images used in the page layout.')
    ->schema([
        ImageEntry::make('hero_image'),
        TextEntry::make('alt_text'),
    ])
```

This section now contains an [`ImageEntry`](entries/image) and a [`TextEntry`](entries/text). You can learn more about those entries and their functionalities on the respective docs pages.

## Next steps with the infolists package

Now you've finished reading this guide, where to next? Here are some suggestions:

- [Explore the available entries to display data in your infolist.](entries/getting-started#available-entries)
- [Discover how to build complex, responsive layouts without touching CSS.](layout/getting-started)

# Documentation for infolists. File: 03-entries/01-getting-started.md
---
title: Getting started
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Overview

Entry classes can be found in the `Filament\Infolists\Components` namespace. You can put them inside the `$infolist->schema()` method:

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

If you're inside a [panel builder resource](../../panels/resources), the `infolist()` method should be static:

```php
use Filament\Infolists\Infolist;

public static function infolist(Infolist $infolist): Infolist
{
    return $infolist
        ->schema([
            // ...
        ]);
}
```

Entries may be created using the static `make()` method, passing its unique name. You may use "dot notation" to access entries within relationships.

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('title')

TextEntry::make('author.name')
```

<AutoScreenshot name="infolists/entries/simple" alt="Entries in an infolist" version="3.x" />

## Available entries

- [Text entry](text)
- [Icon entry](icon)
- [Image entry](image)
- [Color entry](color)
- [Key-value entry](key-value)
- [Repeatable entry](repeatable)

You may also [create your own custom entries](custom) to display data however you wish.

## Setting a label

By default, the label of the entry, which is displayed in the header of the infolist, is generated from the name of the entry. You may customize this using the `label()` method:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('title')
    ->label('Post title')
```

Optionally, you can have the label automatically translated [using Laravel's localization features](https://laravel.com/docs/localization) with the `translateLabel()` method:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('title')
    ->translateLabel() // Equivalent to `label(__('Title'))`
```

## Entry URLs

When an entry is clicked, you may open a URL.

### Opening URLs

To open a URL, you may use the `url()` method, passing a callback or static URL to open. Callbacks accept a `$record` parameter which you may use to customize the URL:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('title')
    ->url(fn (Post $record): string => route('posts.edit', ['post' => $record]))
```

You may also choose to open the URL in a new tab:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('title')
    ->url(fn (Post $record): string => route('posts.edit', ['post' => $record]))
    ->openUrlInNewTab()
```

## Setting a default value

To set a default value for entries with an empty state, you may use the `default()` method. This method will treat the default state as if it were real, so entries like [image](image) or [color](color) will display the default image or color.

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('title')
    ->default('Untitled')
```

## Adding placeholder text if an entry is empty

Sometimes you may want to display placeholder text for entries with an empty state, which is styled as a lighter gray text. This differs from the [default value](#setting-a-default-value), as the placeholder is always text and not treated as if it were real state.

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('title')
    ->placeholder('Untitled')
```

<AutoScreenshot name="infolists/entries/placeholder" alt="Entry with a placeholder for empty state" version="3.x" />

## Adding helper text below the entry

Sometimes, you may wish to provide extra information for the user of the infolist. For this purpose, you may add helper text below the entry.

The `helperText()` method is used to add helper text:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('name')
    ->helperText('Your full name here, including any middle names.')
```

This method accepts a plain text string, or an instance of `Illuminate\Support\HtmlString` or `Illuminate\Contracts\Support\Htmlable`. This allows you to render HTML, or even markdown, in the helper text:

```php
use Filament\Infolists\Components\TextEntry;
use Illuminate\Support\HtmlString;

TextEntry::make('name')
    ->helperText(new HtmlString('Your <strong>full name</strong> here, including any middle names.'))

TextEntry::make('name')
    ->helperText(str('Your **full name** here, including any middle names.')->inlineMarkdown()->toHtmlString())

TextEntry::make('name')
    ->helperText(view('name-helper-text'))
```

<AutoScreenshot name="infolists/entries/helper-text" alt="Entry with helper text" version="3.x" />

## Adding a hint next to the label

As well as [helper text](#adding-helper-text-below-the-entry) below the entry, you may also add a "hint" next to the label of the entry. This is useful for displaying additional information about the entry, such as a link to a help page.

The `hint()` method is used to add a hint:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('apiKey')
    ->label('API key')
    ->hint('Documentation? What documentation?!')
```

This method accepts a plain text string, or an instance of `Illuminate\Support\HtmlString` or `Illuminate\Contracts\Support\Htmlable`. This allows you to render HTML, or even markdown, in the helper text:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('apiKey')
    ->label('API key')
    ->hint(new HtmlString('<a href="/documentation">Documentation</a>'))

TextEntry::make('apiKey')
    ->label('API key')
    ->hint(str('[Documentation](/documentation)')->inlineMarkdown()->toHtmlString())

TextEntry::make('apiKey')
    ->label('API key')
    ->hint(view('api-key-hint'))
```

<AutoScreenshot name="infolists/entries/hint" alt="Entry with hint" version="3.x" />

### Changing the text color of the hint

You can change the text color of the hint. By default, it's gray, but you may use `danger`, `info`, `primary`, `success` and `warning`:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('apiKey')
    ->label('API key')
    ->hint(str('[Documentation](/documentation)')->inlineMarkdown()->toHtmlString())
    ->hintColor('primary')
```

<AutoScreenshot name="infolists/entries/hint-color" alt="Entry with hint color" version="3.x" />

### Adding an icon aside the hint

Hints may also have an [icon](https://blade-ui-kit.com/blade-icons?set=1#search) rendered next to them:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('apiKey')
    ->label('API key')
    ->hint(str('[Documentation](/documentation)')->inlineMarkdown()->toHtmlString())
    ->hintIcon('heroicon-m-question-mark-circle')
```

<AutoScreenshot name="infolists/entries/hint-icon" alt="Entry with hint icon" version="3.x" />

#### Adding a tooltip to a hint icon

Additionally, you can add a tooltip to display when you hover over the hint icon, using the `tooltip` parameter of `hintIcon()`:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('apiKey')
    ->label('API key')
    ->hint(str('[Documentation](/documentation)')->inlineMarkdown()->toHtmlString())
    ->hintIcon('heroicon-m-question-mark-circle', tooltip: 'Read it!')
```

## Hiding entries

To hide an entry conditionally, you may use the `hidden()` and `visible()` methods, whichever you prefer:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('role')
    ->hidden(! auth()->user()->isAdmin())
// or
TextEntry::make('role')
    ->visible(auth()->user()->isAdmin())
```

## Calculated state

Sometimes you need to calculate the state of an entry, instead of directly reading it from a database entry.

By passing a callback function to the `state()` method, you can customize the returned state for that entry:

```php
Infolists\Components\TextEntry::make('amount_including_vat')
    ->state(function (Model $record): float {
        return $record->amount * (1 + $record->vat_rate);
    })
```

## Tooltips

You may specify a tooltip to display when you hover over an entry:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('title')
    ->tooltip('Shown at the top of the page')
```

<AutoScreenshot name="infolists/entries/tooltips" alt="Entry with tooltip" version="3.x" />

This method also accepts a closure that can access the current infolist record:

```php
use Filament\Infolists\Components\TextEntry;
use Illuminate\Database\Eloquent\Model;

TextEntry::make('title')
    ->tooltip(fn (Model $record): string => "By {$record->author->name}")
```

## Custom attributes

The HTML of entries can be customized, by passing an array of `extraAttributes()`:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('slug')
    ->extraAttributes(['class' => 'bg-gray-200'])
```

These get merged onto the outer `<div>` element of each entry in that entry.

You can also pass extra HTML attributes to the entry wrapper which surrounds the label, entry, and any other text:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('slug')
    ->extraEntryWrapperAttributes(['class' => 'entry-locked'])
```

## Global settings

If you wish to change the default behavior of all entries globally, then you can call the static `configureUsing()` method inside a service provider's `boot()` method, to which you pass a Closure to modify the entries using. For example, if you wish to make all `TextEntry` components [`words(10)`](text#limiting-word-count), you can do it like so:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::configureUsing(function (TextEntry $entry): void {
    $entry
        ->words(10);
});
```

Of course, you are still able to overwrite this on each entry individually:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('name')
    ->words(null)
```

# Documentation for infolists. File: 03-entries/02-text.md
---
title: Text entry
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Overview

Text entries display simple text:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('title')
```

<AutoScreenshot name="infolists/entries/text/simple" alt="Text entry" version="3.x" />

## Displaying as a "badge"

By default, text is quite plain and has no background color. You can make it appear as a "badge" instead using the `badge()` method. A great use case for this is with statuses, where may want to display a badge with a [color](#customizing-the-color) that matches the status:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('status')
    ->badge()
    ->color(fn (string $state): string => match ($state) {
        'draft' => 'gray',
        'reviewing' => 'warning',
        'published' => 'success',
        'rejected' => 'danger',
    })
```

<AutoScreenshot name="infolists/entries/text/badge" alt="Text entry as badge" version="3.x" />

You may add other things to the badge, like an [icon](#adding-an-icon).

## Date formatting

You may use the `date()` and `dateTime()` methods to format the entry's state using [PHP date formatting tokens](https://www.php.net/manual/en/datetime.format.php):

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('created_at')
    ->dateTime()
```

You may use the `since()` method to format the entry's state using [Carbon's `diffForHumans()`](https://carbon.nesbot.com/docs/#api-humandiff):

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('created_at')
    ->since()
```

Additionally, you can use the `dateTooltip()`, `dateTimeTooltip()` or `timeTooltip()` method to display a formatted date in a tooltip, often to provide extra information:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('created_at')
    ->since()
    ->dateTimeTooltip()
```

## Number formatting

The `numeric()` method allows you to format an entry as a number:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('stock')
    ->numeric()
```

If you would like to customize the number of decimal places used to format the number with, you can use the `decimalPlaces` argument:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('stock')
    ->numeric(decimalPlaces: 0)
```

By default, your app's locale will be used to format the number suitably. If you would like to customize the locale used, you can pass it to the `locale` argument:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('stock')
    ->numeric(locale: 'nl')
```

Alternatively, you can set the default locale used across your app using the `Infolist::$defaultNumberLocale` method in the `boot()` method of a service provider:

```php
use Filament\Infolists\Infolist;

Infolist::$defaultNumberLocale = 'nl';
```

## Currency formatting

The `money()` method allows you to easily format monetary values, in any currency:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('price')
    ->money('EUR')
```

There is also a `divideBy` argument for `money()` that allows you to divide the original value by a number before formatting it. This could be useful if your database stores the price in cents, for example:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('price')
    ->money('EUR', divideBy: 100)
```

By default, your app's locale will be used to format the money suitably. If you would like to customize the locale used, you can pass it to the `locale` argument:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('price')
    ->money('EUR', locale: 'nl')
```

Alternatively, you can set the default locale used across your app using the `Infolist::$defaultNumberLocale` method in the `boot()` method of a service provider:

```php
use Filament\Infolists\Infolist;

Infolist::$defaultNumberLocale = 'nl';
```

## Limiting text length

You may `limit()` the length of the entry's value:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('description')
    ->limit(50)
```

You may also reuse the value that is being passed to `limit()`:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('description')
    ->limit(50)
    ->tooltip(function (TextEntry $component): ?string {
        $state = $component->getState();

        if (strlen($state) <= $component->getCharacterLimit()) {
            return null;
        }

        // Only render the tooltip if the entry contents exceeds the length limit.
        return $state;
    })
```

## Limiting word count

You may limit the number of `words()` displayed in the entry:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('description')
    ->words(10)
```

## Limiting text to a specific number of lines

You may want to limit text to a specific number of lines instead of limiting it to a fixed length. Clamping text to a number of lines is useful in responsive interfaces where you want to ensure a consistent experience across all screen sizes. This can be achieved using the `lineClamp()` method:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('description')
    ->lineClamp(2)
```

## Listing multiple values

By default, if there are multiple values inside your text entry, they will be comma-separated. You may use the `listWithLineBreaks()` method to display them on new lines instead:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('authors.name')
    ->listWithLineBreaks()
```

<AutoScreenshot name="infolists/entries/text/list" alt="Text entry with multiple values" version="3.x" />

### Adding bullet points to the list

You may add a bullet point to each list item using the `bulleted()` method:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('authors.name')
    ->listWithLineBreaks()
    ->bulleted()
```

<AutoScreenshot name="infolists/entries/text/bullet-list" alt="Text entry with multiple values and bullet points" version="3.x" />

### Limiting the number of values in the list

You can limit the number of values in the list using the `limitList()` method:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('authors.name')
    ->listWithLineBreaks()
    ->limitList(3)
```

#### Expanding the limited list

You can allow the limited items to be expanded and collapsed, using the `expandableLimitedList()` method:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('authors.name')
    ->listWithLineBreaks()
    ->limitList(3)
    ->expandableLimitedList()
```

Please note that this is only a feature for `listWithLineBreaks()` or `bulleted()`, where each item is on its own line.

### Using a list separator

If you want to "explode" a text string from your model into multiple list items, you can do so with the `separator()` method. This is useful for displaying comma-separated tags [as badges](#displaying-as-a-badge), for example:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('tags')
    ->badge()
    ->separator(',')
```

## Rendering HTML

If your entry value is HTML, you may render it using `html()`:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('description')
    ->html()
```

If you use this method, then the HTML will be sanitized to remove any potentially unsafe content before it is rendered. If you'd like to opt out of this behavior, you can wrap the HTML in an `HtmlString` object by formatting it:

```php
use Filament\Infolists\Components\TextEntry;
use Illuminate\Support\HtmlString;

TextEntry::make('description')
    ->formatStateUsing(fn (string $state): HtmlString => new HtmlString($state))
```

Or, you can return a `view()` object from the `formatStateUsing()` method, which will also not be sanitized:

```php
use Filament\Infolists\Components\TextEntry;
use Illuminate\Contracts\View\View;

TextEntry::make('description')
    ->formatStateUsing(fn (string $state): View => view(
        'filament.infolists.components.description-entry-content',
        ['state' => $state],
    ))
```

### Rendering Markdown as HTML

If your entry value is Markdown, you may render it using `markdown()`:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('description')
    ->markdown()
```

## Custom formatting

You may instead pass a custom formatting callback to `formatStateUsing()`, which accepts the `$state` of the entry, and optionally its `$record`:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('status')
    ->formatStateUsing(fn (string $state): string => __("statuses.{$state}"))
```

## Customizing the color

You may set a color for the text, either `danger`, `gray`, `info`, `primary`, `success` or `warning`:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('status')
    ->color('primary')
```

<AutoScreenshot name="infolists/entries/text/color" alt="Text entry in the primary color" version="3.x" />

## Adding an icon

Text entries may also have an [icon](https://blade-ui-kit.com/blade-icons?set=1#search):

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('email')
    ->icon('heroicon-m-envelope')
```

<AutoScreenshot name="infolists/entries/text/icon" alt="Text entry with icon" version="3.x" />

You may set the position of an icon using `iconPosition()`:

```php
use Filament\Infolists\Components\TextEntry;
use Filament\Support\Enums\IconPosition;

TextEntry::make('email')
    ->icon('heroicon-m-envelope')
    ->iconPosition(IconPosition::After) // `IconPosition::Before` or `IconPosition::After`
```

<AutoScreenshot name="infolists/entries/text/icon-after" alt="Text entry with icon after" version="3.x" />

The icon color defaults to the text color, but you may customize the icon color separately using `iconColor()`:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('email')
    ->icon('heroicon-m-envelope')
    ->iconColor('primary')
```

<AutoScreenshot name="infolists/entries/text/icon-color" alt="Text entry with icon in the primary color" version="3.x" />

## Customizing the text size

Text columns have small font size by default, but you may change this to `TextEntrySize::ExtraSmall`, `TextEntrySize::Medium`, or `TextEntrySize::Large`.

For instance, you may make the text larger using `size(TextEntrySize::Large)`:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('title')
    ->size(TextEntry\TextEntrySize::Large)
```

<AutoScreenshot name="infolists/entries/text/large" alt="Text entry in a large font size" version="3.x" />

## Customizing the font weight

Text entries have regular font weight by default, but you may change this to any of the following options: `FontWeight::Thin`, `FontWeight::ExtraLight`, `FontWeight::Light`, `FontWeight::Medium`, `FontWeight::SemiBold`, `FontWeight::Bold`, `FontWeight::ExtraBold` or `FontWeight::Black`.

For instance, you may make the font bold using `weight(FontWeight::Bold)`:

```php
use Filament\Infolists\Components\TextEntry;
use Filament\Support\Enums\FontWeight;

TextEntry::make('title')
    ->weight(FontWeight::Bold)
```

<AutoScreenshot name="infolists/entries/text/bold" alt="Text entry in a bold font" version="3.x" />

## Customizing the font family

You can change the text font family to any of the following options: `FontFamily::Sans`, `FontFamily::Serif` or `FontFamily::Mono`.

For instance, you may make the font monospaced using `fontFamily(FontFamily::Mono)`:

```php
use Filament\Support\Enums\FontFamily;
use Filament\Infolists\Components\TextEntry;

TextEntry::make('apiKey')
    ->label('API key')
    ->fontFamily(FontFamily::Mono)
```

<AutoScreenshot name="infolists/entries/text/mono" alt="Text entry in a monospaced font" version="3.x" />

## Allowing the text to be copied to the clipboard

You may make the text copyable, such that clicking on the entry copies the text to the clipboard, and optionally specify a custom confirmation message and duration in milliseconds. This feature only works when SSL is enabled for the app.

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('apiKey')
    ->label('API key')
    ->copyable()
    ->copyMessage('Copied!')
    ->copyMessageDuration(1500)
```

<AutoScreenshot name="infolists/entries/text/copyable" alt="Text entry with a button to copy it" version="3.x" />

# Documentation for infolists. File: 03-entries/03-icon.md
---
title: Icon entry
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Overview

Icon entries render an [icon](https://blade-ui-kit.com/blade-icons?set=1#search) representing their contents:

```php
use Filament\Infolists\Components\IconEntry;

IconEntry::make('status')
    ->icon(fn (string $state): string => match ($state) {
        'draft' => 'heroicon-o-pencil',
        'reviewing' => 'heroicon-o-clock',
        'published' => 'heroicon-o-check-circle',
    })
```

In the function, `$state` is the value of the entry, and `$record` can be used to access the underlying Eloquent record.

<AutoScreenshot name="infolists/entries/icon/simple" alt="Icon entry" version="3.x" />

## Customizing the color

Icon entries may also have a set of icon colors, using the same syntax. They may be either `danger`, `gray`, `info`, `primary`, `success` or `warning`:

```php
use Filament\Infolists\Components\IconEntry;

IconEntry::make('status')
    ->color(fn (string $state): string => match ($state) {
        'draft' => 'info',
        'reviewing' => 'warning',
        'published' => 'success',
        default => 'gray',
    })
```

In the function, `$state` is the value of the entry, and `$record` can be used to access the underlying Eloquent record.

<AutoScreenshot name="infolists/entries/icon/color" alt="Icon entry with color" version="3.x" />

## Customizing the size

The default icon size is `IconEntrySize::Large`, but you may customize the size to be either `IconEntrySize::ExtraSmall`, `IconEntrySize::Small`, `IconEntrySize::Medium`, `IconEntrySize::ExtraLarge` or `IconEntrySize::TwoExtraLarge`:

```php
use Filament\Infolists\Components\IconEntry;

IconEntry::make('status')
    ->size(IconEntry\IconEntrySize::Medium)
```

<AutoScreenshot name="infolists/entries/icon/medium" alt="Medium-sized icon entry" version="3.x" />

## Handling booleans

Icon entries can display a check or cross icon based on the contents of the database entry, either true or false, using the `boolean()` method:

```php
use Filament\Infolists\Components\IconEntry;

IconEntry::make('is_featured')
    ->boolean()
```

> If this column in the model class is already cast as a `bool` or `boolean`, Filament is able to detect this, and you do not need to use `boolean()` manually.

<AutoScreenshot name="infolists/entries/icon/boolean" alt="Icon entry to display a boolean" version="3.x" />

### Customizing the boolean icons

You may customize the icon representing each state. Icons are the name of a Blade component present. By default, [Heroicons](https://heroicons.com) are installed:

```php
use Filament\Infolists\Components\IconEntry;

IconEntry::make('is_featured')
    ->boolean()
    ->trueIcon('heroicon-o-check-badge')
    ->falseIcon('heroicon-o-x-mark')
```

<AutoScreenshot name="infolists/entries/icon/boolean-icon" alt="Icon entry to display a boolean with custom icons" version="3.x" />

### Customizing the boolean colors

You may customize the icon color representing each state. These may be either `danger`, `gray`, `info`, `primary`, `success` or `warning`:

```php
use Filament\Infolists\Components\IconEntry;

IconEntry::make('is_featured')
    ->boolean()
    ->trueColor('info')
    ->falseColor('warning')
```

<AutoScreenshot name="infolists/entries/icon/boolean-color" alt="Icon entry to display a boolean with custom colors" version="3.x" />

# Documentation for infolists. File: 03-entries/04-image.md
---
title: Image entry
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Overview

Images can be easily displayed within your infolist:

```php
use Filament\Infolists\Components\ImageEntry;

ImageEntry::make('header_image')
```

The entry must contain the path to the image, relative to the root directory of its storage disk, or an absolute URL to it.

<AutoScreenshot name="infolists/entries/image/simple" alt="Image entry" version="3.x" />

## Managing the image disk

By default, the `public` disk will be used to retrieve images. You may pass a custom disk name to the `disk()` method:

```php
use Filament\Infolists\Components\ImageEntry;

ImageEntry::make('header_image')
    ->disk('s3')
```

## Private images

Filament can generate temporary URLs to render private images, you may set the `visibility()` to `private`:

```php
use Filament\Infolists\Components\ImageEntry;

ImageEntry::make('header_image')
    ->visibility('private')
```

## Customizing the size

You may customize the image size by passing a `width()` and `height()`, or both with `size()`:

```php
use Filament\Infolists\Components\ImageEntry;

ImageEntry::make('header_image')
    ->width(200)

ImageEntry::make('header_image')
    ->height(50)

ImageEntry::make('author.avatar')
    ->size(40)
```

## Square image

You may display the image using a 1:1 aspect ratio:

```php
use Filament\Infolists\Components\ImageEntry;

ImageEntry::make('author.avatar')
    ->height(40)
    ->square()
```

<AutoScreenshot name="infolists/entries/image/square" alt="Square image entry" version="3.x" />

## Circular image

You may make the image fully rounded, which is useful for rendering avatars:

```php
use Filament\Infolists\Components\ImageEntry;

ImageEntry::make('author.avatar')
    ->height(40)
    ->circular()
```

<AutoScreenshot name="infolists/entries/image/circular" alt="Circular image entry" version="3.x" />

## Adding a default image URL

You can display a placeholder image if one doesn't exist yet, by passing a URL to the `defaultImageUrl()` method:

```php
use Filament\Infolists\Components\ImageEntry;

ImageEntry::make('avatar')
    ->defaultImageUrl(url('/images/placeholder.png'))
```

## Stacking images

You may display multiple images as a stack of overlapping images by using `stacked()`:

```php
use Filament\Infolists\Components\ImageEntry;

ImageEntry::make('colleagues.avatar')
    ->height(40)
    ->circular()
    ->stacked()
```

<AutoScreenshot name="infolists/entries/image/stacked" alt="Stacked image entry" version="3.x" />

### Customizing the stacked ring width

The default ring width is `3`, but you may customize it to be from `0` to `8`:

```php
use Filament\Infolists\Components\ImageEntry;

ImageEntry::make('colleagues.avatar')
    ->height(40)
    ->circular()
    ->stacked()
    ->ring(5)
```

### Customizing the stacked overlap

The default overlap is `4`, but you may customize it to be from `0` to `8`:

```php
use Filament\Infolists\Components\ImageEntry;

ImageEntry::make('colleagues.avatar')
    ->height(40)
    ->circular()
    ->stacked()
    ->overlap(2)
```

## Setting a limit

You may limit the maximum number of images you want to display by passing `limit()`:

```php
use Filament\Infolists\Components\ImageEntry;

ImageEntry::make('colleagues.avatar')
    ->height(40)
    ->circular()
    ->stacked()
    ->limit(3)
```

<AutoScreenshot name="infolists/entries/image/limited" alt="Limited image entry" version="3.x" />

### Showing the remaining images count

When you set a limit you may also display the count of remaining images by passing `limitedRemainingText()`.

```php
use Filament\Infolists\Components\ImageEntry;

ImageEntry::make('colleagues.avatar')
    ->height(40)
    ->circular()
    ->stacked()
    ->limit(3)
    ->limitedRemainingText()
```

<AutoScreenshot name="infolists/entries/image/limited-remaining-text" alt="Limited image entry with remaining text" version="3.x" />

#### Showing the limited remaining text separately

By default, `limitedRemainingText()` will display the count of remaining images as a number stacked on the other images. If you prefer to show the count as a number after the images, you may use the `isSeparate: true` parameter:

```php
use Filament\Infolists\Components\ImageEntry;

ImageEntry::make('colleagues.avatar')
    ->height(40)
    ->circular()
    ->stacked()
    ->limit(3)
    ->limitedRemainingText(isSeparate: true)
```

<AutoScreenshot name="infolists/entries/image/limited-remaining-text-separately" alt="Limited image entry with remaining text separately" version="3.x" />

#### Customizing the limited remaining text size

By default, the size of the remaining text is `sm`. You can customize this to be `xs`, `md` or `lg` using the `size` parameter:

```php
use Filament\Infolists\Components\ImageEntry;

ImageEntry::make('colleagues.avatar')
    ->height(40)
    ->circular()
    ->stacked()
    ->limit(3)
    ->limitedRemainingText(size: 'lg')
```

## Custom attributes

You may customize the extra HTML attributes of the image using `extraImgAttributes()`:

```php
use Filament\Infolists\Components\ImageEntry;

ImageEntry::make('logo')
    ->extraImgAttributes([
        'alt' => 'Logo',
        'loading' => 'lazy',
    ]),
```

## Prevent file existence checks

When the infolist is loaded, it will automatically detect whether the images exist. This is all done on the backend. When using remote storage with many images, this can be time-consuming. You can use the `checkFileExistence(false)` method to disable this feature:

```php
use Filament\Infolists\Components\ImageEntry;

ImageEntry::make('attachment')
    ->checkFileExistence(false)
```

# Documentation for infolists. File: 03-entries/05-color.md
---
title: Color entry
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Overview

The color entry allows you to show the color preview from a CSS color definition, typically entered using the color picker field, in one of the supported formats (HEX, HSL, RGB, RGBA).

```php
use Filament\Infolists\Components\ColorEntry;

ColorEntry::make('color')
```

<AutoScreenshot name="infolists/entries/color/simple" alt="Color entry" version="3.x" />

## Allowing the color to be copied to the clipboard

You may make the color copyable, such that clicking on the preview copies the CSS value to the clipboard, and optionally specify a custom confirmation message and duration in milliseconds. This feature only works when SSL is enabled for the app.

```php
use Filament\Infolists\Components\ColorEntry;

ColorEntry::make('color')
    ->copyable()
    ->copyMessage('Copied!')
    ->copyMessageDuration(1500)
```

<AutoScreenshot name="infolists/entries/color/copyable" alt="Color entry with a button to copy it" version="3.x" />

# Documentation for infolists. File: 03-entries/06-key-value.md
---
title: Key-value entry
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Overview

The key-value entry allows you to render key-value pairs of data, from a one-dimensional JSON object / PHP array.

```php
use Filament\Infolists\Components\KeyValueEntry;

KeyValueEntry::make('meta')
```

<AutoScreenshot name="infolists/entries/key-value/simple" alt="Key-value entry" version="3.x" />

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

## Customizing the key column's label

You may customize the label for the key column using the `keyLabel()` method:

```php
use Filament\Infolists\Components\KeyValueEntry;

KeyValueEntry::make('meta')
    ->keyLabel('Property name')
```

## Customizing the value column's label

You may customize the label for the value column using the `valueLabel()` method:

```php
use Filament\Infolists\Components\KeyValueEntry;

KeyValueEntry::make('meta')
    ->valueLabel('Property value')
```

# Documentation for infolists. File: 03-entries/07-repeatable.md
---
title: Repeatable entry
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Overview

The repeatable entry allows you to repeat a set of entries and layout components for items in an array or relationship.

```php
use Filament\Infolists\Components\RepeatableEntry;
use Filament\Infolists\Components\TextEntry;

RepeatableEntry::make('comments')
    ->schema([
        TextEntry::make('author.name'),
        TextEntry::make('title'),
        TextEntry::make('content')
            ->columnSpan(2),
    ])
    ->columns(2)
```

As you can see, the repeatable entry has an embedded `schema()` which gets repeated for each item.

<AutoScreenshot name="infolists/entries/repeatable/simple" alt="Repeatable entry" version="3.x" />

## Grid layout

You may organize repeatable items into columns by using the `grid()` method:

```php
use Filament\Infolists\Components\RepeatableEntry;

RepeatableEntry::make('comments')
    ->schema([
        // ...
    ])
    ->grid(2)
```

This method accepts the same options as the `columns()` method of the [grid](../layout/grid). This allows you to responsively customize the number of grid columns at various breakpoints.

<AutoScreenshot name="infolists/entries/repeatable/grid" alt="Repeatable entry in grid layout" version="3.x" />

## Removing the styled container

By default, each item in a repeatable entry is wrapped in a container styled as a card. You may remove the styled container using `contained()`:

```php
use Filament\Infolists\Components\RepeatableEntry;

RepeatableEntry::make('comments')
    ->schema([
        // ...
    ])
    ->contained(false)
```

# Documentation for infolists. File: 03-entries/08-custom.md
---
title: Custom entries
---
import LaracastsBanner from "@components/LaracastsBanner.astro"

<LaracastsBanner
    title="Build a Custom Infolist Entry"
    description="Watch the Build Advanced Components for Filament series on Laracasts - it will teach you how to build components, and you'll get to know all the internal tools to help you."
    url="https://laracasts.com/series/build-advanced-components-for-filament/episodes/8"
    series="building-advanced-components"
/>

## View entries

You may render a custom view for an entry using the `view()` method:

```php
use Filament\Infolists\Components\ViewEntry;

ViewEntry::make('status')
    ->view('filament.infolists.entries.status-switcher')
```

This assumes that you have a `resources/views/filament/infolists/entries/status-switcher.blade.php` file.

## Custom classes

You may create your own custom entry classes and entry views, which you can reuse across your project, and even release as a plugin to the community.

> If you're just creating a simple custom entry to use once, you could instead use a [view entry](#view-entries) to render any custom Blade file.

To create a custom entry class and view, you may use the following command:

```bash
php artisan make:infolist-entry StatusSwitcher
```

This will create the following entry class:

```php
use Filament\Infolists\Components\Entry;

class StatusSwitcher extends Entry
{
    protected string $view = 'filament.infolists.entries.status-switcher';
}
```

It will also create a view file at `resources/views/filament/infolists/entries/status-switcher.blade.php`.

## Accessing the state

Inside your view, you may retrieve the state of the entry using the `$getState()` function:

```blade
<div>
    {{ $getState() }}
</div>
```

## Accessing the Eloquent record

Inside your view, you may access the Eloquent record using the `$getRecord()` function:

```blade
<div>
    {{ $getRecord()->name }}
</div>
```

# Documentation for infolists. File: 04-layout/01-getting-started.md
---
title: Getting started
---

## Overview

Infolists are not limited to just displaying entries. You can also use "layout components" to organize them into an infinitely nestable structure.

Layout component classes can be found in the `Filament\Infolists\Components` namespace. They reside within the schema of your infolist, alongside any [entries](../entries/getting-started).

Components may be created using the static `make()` method. Usually, you will then define the child component `schema()` to display inside:

```php
use Filament\Infolists\Components\Grid;

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
- [Section](section)
- [Split](split)

You may also [create your own custom layout components](custom) to organize fields in whatever way you wish.

## Setting an ID

You may define an ID for the component using the `id()` method:

```php
use Filament\Infolists\Components\Section;

Section::make()
    ->id('main-section')
```

## Adding extra HTML attributes

You can pass extra HTML attributes to the component, which will be merged onto the outer DOM element. Pass an array of attributes to the `extraAttributes()` method, where the key is the attribute name and the value is the attribute value:

```php
use Filament\Infolists\Components\Group;

Section::make()
    ->extraAttributes(['class' => 'custom-section-style'])
```

Classes will be merged with the default classes, and any other attributes will override the default attributes.

## Global settings

If you wish to change the default behavior of a component globally, then you can call the static `configureUsing()` method inside a service provider's `boot()` method, to which you pass a Closure to modify the component using. For example, if you wish to make all section components have [2 columns](grid) by default, you can do it like so:

```php
use Filament\Infolists\Components\Section;

Section::configureUsing(function (Section $section): void {
    $section
        ->columns(2);
});
```

Of course, you are still able to overwrite this on each field individually:

```php
use Filament\Infolists\Components\Section;

Section::make()
    ->columns(1)
```

# Documentation for infolists. File: 04-layout/02-grid.md
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

In this example, we have an infolist with a [section](section) layout component. Since all layout components support the `columns()` method, we can use it to create a responsive grid layout within the section itself.

We pass an array to `columns()` as we want to specify different numbers of columns for different breakpoints. On devices smaller than the `sm` [Tailwind breakpoint](https://tailwindcss.com/docs/responsive-design#overview), we want to have 1 column, which is default. On devices larger than the `sm` breakpoint, we want to have 3 columns. On devices larger than the `xl` breakpoint, we want to have 6 columns. On devices larger than the `2xl` breakpoint, we want to have 8 columns.

Inside the section, we have a [text entry](../entries/text). Since text entries are infolist components and all form components have a `columnSpan()` method, we can use it to specify how many columns the text entry should fill. On devices smaller than the `sm` breakpoint, we want the text entry to fill 1 column, which is default. On devices larger than the `sm` breakpoint, we want the text entry to fill 2 columns. On devices larger than the `xl` breakpoint, we want the text entry to fill 3 columns. On devices larger than the `2xl` breakpoint, we want the text entry to fill 4 columns.

```php
use Filament\Infolists\Components\Section;
use Filament\Infolists\Components\TextEntry;

Section::make()
    ->columns([
        'sm' => 3,
        'xl' => 6,
        '2xl' => 8,
    ])
    ->schema([
        TextEntry::make('name')
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
use Filament\Infolists\Components\Grid;

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
use Filament\Infolists\Components\Grid;
use Filament\Infolists\Components\TextEntry;

Grid::make()
    ->columns([
        'sm' => 3,
        'xl' => 6,
        '2xl' => 8,
    ])
    ->schema([
        TextEntry::make('name')
            ->columnStart([
                'sm' => 2,
                'xl' => 3,
                '2xl' => 4,
            ]),
        // ...
    ])
```

In this example, the grid has 3 columns on small devices, 6 columns on extra large devices, and 8 columns on extra extra large devices. The text entry will start at column 2 on small devices, column 3 on extra large devices, and column 4 on extra extra large devices. This is essentially producing a layout whereby the text entry always starts halfway through the grid, regardless of how many columns the grid has.

# Documentation for infolists. File: 04-layout/03-fieldset.md
---
title: Fieldset
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Overview

You may want to group entries into a Fieldset. Each fieldset has a label, a border, and a two-column grid by default:

```php
use Filament\Infolists\Components\Fieldset;

Fieldset::make('Label')
    ->schema([
        // ...
    ])
```

<AutoScreenshot name="infolists/layout/fieldset/simple" alt="Fieldset" version="3.x" />

## Using grid columns within a fieldset

You may use the `columns()` method to customize the [grid](grid) within the fieldset:

```php
use Filament\Infolists\Components\Fieldset;

Fieldset::make('Label')
    ->schema([
        // ...
    ])
    ->columns(3)
```

# Documentation for infolists. File: 04-layout/04-tabs.md
---
title: Tabs
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Overview

Some infolists can be long and complex. You may want to use tabs to reduce the number of components that are visible at once:

```php
use Filament\Infolists\Components\Tabs;

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

<AutoScreenshot name="infolists/layout/tabs/simple" alt="Tabs" version="3.x" />

## Setting the default active tab

The first tab will be open by default. You can change the default open tab using the `activeTab()` method:

```php
use Filament\Infolists\Components\Tabs;

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
use Filament\Infolists\Components\Tabs;

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

<AutoScreenshot name="infolists/layout/tabs/icons" alt="Tabs with icons" version="3.x" />

### Setting the tab icon position

The icon of the tab may be positioned before or after the label using the `iconPosition()` method:

```php
use Filament\Infolists\Components\Tabs;
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

<AutoScreenshot name="infolists/layout/tabs/icons-after" alt="Tabs with icons after their labels" version="3.x" />

## Setting a tab badge

Tabs may have a badge, which you can set using the `badge()` method:

```php
use Filament\Infolists\Components\Tabs;

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

<AutoScreenshot name="infolists/layout/tabs/badges" alt="Tabs with badges" version="3.x" />

If you'd like to change the color for a badge, you can use the `badgeColor()` method:

```php
use Filament\Infolists\Components\Tabs;

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
use Filament\Infolists\Components\Tabs;

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
use Filament\Infolists\Components\Tabs;

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
use Filament\Infolists\Components\Tabs;

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
use Filament\Infolists\Components\Tabs;

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
use Filament\Infolists\Components\Tabs;

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

# Documentation for infolists. File: 04-layout/05-section.md
---
title: Section
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Overview

You may want to separate your entries into sections, each with a heading and description. To do this, you can use a section component:

```php
use Filament\Infolists\Components\Section;

Section::make('Rate limiting')
    ->description('Prevent abuse by limiting the number of requests per period')
    ->schema([
        // ...
    ])
```

<AutoScreenshot name="infolists/layout/section/simple" alt="Section" version="3.x" />

You can also use a section without a header, which just wraps the components in a simple card:

```php
use Filament\Infolists\Components\Section;

Section::make()
    ->schema([
        // ...
    ])
```

<AutoScreenshot name="infolists/layout/section/without-header" alt="Section without header" version="3.x" />

## Adding actions to the section's header or footer

Sections can have actions in their [header](#adding-actions-to-the-sections-header) or [footer](#adding-actions-to-the-sections-footer).

### Adding actions to the section's header

You may add [actions](../actions) to the section's header using the `headerActions()` method:

```php
use Filament\Infolists\Components\Actions\Action;
use Filament\Infolists\Components\Section;

Section::make('Rate limiting')
    ->headerActions([
        Action::make('edit')
            ->action(function () {
                // ...
            }),
    ])
    ->schema([
        // ...
    ])
```

<AutoScreenshot name="infolists/layout/section/header/actions" alt="Section with header actions" version="3.x" />

> [Make sure the section has a heading or ID](#adding-actions-to-a-section-without-heading)

### Adding actions to the section's footer

In addition to [header actions](#adding-an-icon-to-the-sections-header), you may add [actions](../actions) to the section's footer using the `footerActions()` method:

```php
use Filament\Infolists\Components\Actions\Action;
use Filament\Infolists\Components\Section;

Section::make('Rate limiting')
    ->footerActions([
        Action::make('edit')
            ->action(function () {
                // ...
            }),
    ])
    ->schema([
        // ...
    ])
```

<AutoScreenshot name="infolists/layout/section/footer/actions" alt="Section with footer actions" version="3.x" />

> [Make sure the section has a heading or ID](#adding-actions-to-a-section-without-heading)

#### Aligning section footer actions

Footer actions are aligned to the inline start by default. You may customize the alignment using the `footerActionsAlignment()` method:

```php
use Filament\Infolists\Components\Actions\Action;
use Filament\Infolists\Components\Section;
use Filament\Support\Enums\Alignment;

Section::make('Rate limiting')
    ->footerActions([
        Action::make('edit')
            ->action(function () {
                // ...
            }),
    ])
    ->footerActionsAlignment(Alignment::End)
    ->schema([
        // ...
    ])
```

### Adding actions to a section without heading

If your section does not have a heading, Filament has no way of locating the action inside it. In this case, you must pass a unique `id()` to the section:

```php
use Filament\Infolists\Components\Section;

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

You may add an icon to the section's header using the `icon()` method:

```php
use Filament\Infolists\Components\Section;

Section::make('Cart')
    ->description('The items you have selected for purchase')
    ->icon('heroicon-m-shopping-bag')
    ->schema([
        // ...
    ])
```

<AutoScreenshot name="infolists/layout/section/icons" alt="Section with icon" version="3.x" />

## Positioning the heading and description aside

You may use the `aside()` method to align the heading and description on the left, and the infolist components inside a card on the right:

```php
use Filament\Infolists\Components\Section;

Section::make('Rate limiting')
    ->description('Prevent abuse by limiting the number of requests per period')
    ->aside()
    ->schema([
        // ...
    ])
```

<AutoScreenshot name="infolists/layout/section/aside" alt="Section with heading and description aside" version="3.x" />

## Collapsing sections

Sections may be `collapsible()` to optionally hide content in long infolists:

```php
use Filament\Infolists\Components\Section;

Section::make('Cart')
    ->description('The items you have selected for purchase')
    ->schema([
        // ...
    ])
    ->collapsible()
```

Your sections may be `collapsed()` by default:

```php
use Filament\Infolists\Components\Section;

Section::make('Cart')
    ->description('The items you have selected for purchase')
    ->schema([
        // ...
    ])
    ->collapsed()
```

<AutoScreenshot name="infolists/layout/section/collapsed" alt="Collapsed section" version="3.x" />

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
use Filament\Infolists\Components\Section;

Section::make('Rate limiting')
    ->description('Prevent abuse by limiting the number of requests per period')
    ->schema([
        // ...
    ])
    ->compact()
```

<AutoScreenshot name="infolists/layout/section/compact" alt="Compact section" version="3.x" />

## Using grid columns within a section

You may use the `columns()` method to easily create a [grid](grid) within the section:

```php
use Filament\Infolists\Components\Section;

Section::make('Heading')
    ->schema([
        // ...
    ])
    ->columns(2)
```

# Documentation for infolists. File: 04-layout/06-split.md
---
title: Split
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Overview

The `Split` component allows you to define layouts with flexible widths, using flexbox.

```php
use Filament\Infolists\Components\Section;
use Filament\Infolists\Components\Split;
use Filament\Infolists\Components\TextEntry;
use Filament\Support\Enums\FontWeight;

Split::make([
    Section::make([
        TextEntry::make('title')
            ->weight(FontWeight::Bold),
        TextEntry::make('content')
            ->markdown()
            ->prose(),
    ]),
    Section::make([
        TextEntry::make('created_at')
            ->dateTime(),
        TextEntry::make('published_at')
            ->dateTime(),
    ])->grow(false),
])->from('md')
```

In this example, the first section will `grow()` to consume available horizontal space, without affecting the amount of space needed to render the second section. This creates a sidebar effect.

The `from()` method is used to control the [Tailwind breakpoint](https://tailwindcss.com/docs/responsive-design#overview) (`sm`, `md`, `lg`, `xl`, `2xl`) at which the split layout should be used. In this example, the split layout will be used on medium devices and larger. On smaller devices, the sections will stack on top of each other.

<AutoScreenshot name="infolists/layout/split/simple" alt="Split" version="3.x" />

# Documentation for infolists. File: 04-layout/07-custom.md
---
title: Custom layouts
---
import LaracastsBanner from "@components/LaracastsBanner.astro"

<LaracastsBanner
    title="Build a Custom Infolist Layout"
    description="Watch the Build Advanced Components for Filament series on Laracasts - it will teach you how to build components, and you'll get to know all the internal tools to help you."
    url="https://laracasts.com/series/build-advanced-components-for-filament/episodes/9"
    series="building-advanced-components"
/>

## View components

Aside from [building custom layout components](#custom-layout-classes), you may create "view" components which allow you to create custom layouts without extra PHP classes.

```php
use Filament\Infolists\Components\View;

View::make('filament.infolists.components.box')
```

This assumes that you have a `resources/views/filament/infolists/components/box.blade.php` file.

## Custom layout classes

You may create your own custom component classes and views, which you can reuse across your project, and even release as a plugin to the community.

> If you're just creating a simple custom component to use once, you could instead use a [view component](#view) to render any custom Blade file.

To create a custom component class and view, you may use the following command:

```bash
php artisan make:infolist-layout Box
```

This will create the following layout component class:

```php
use Filament\Infolists\Components\Component;

class Box extends Component
{
    protected string $view = 'filament.infolists.components.box';

    public static function make(): static
    {
        return app(static::class);
    }
}
```

It will also create a view file at `resources/views/filament/infolists/components/box.blade.php`.

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

# Documentation for infolists. File: 05-actions.md
---
title: Actions
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Overview

Filament's infolists can use [Actions](../actions). They are buttons that can be added to any infolist component. Also, you can [render anonymous sets of actions](#adding-anonymous-actions-to-an-infolist-without-attaching-them-to-a-component) on their own, that are not attached to a particular infolist component.

## Defining a infolist component action

Action objects inside an infolist component are instances of `Filament/Infolists/Components/Actions/Action`. You must pass a unique name to the action's `make()` method, which is used to identify it amongst others internally within Filament. You can [customize the trigger button](../actions/trigger-button) of an action, and even [open a modal](../actions/modals) with little effort:

```php
use App\Actions\ResetStars;
use Filament\Infolists\Components\Actions\Action;

Action::make('resetStars')
    ->icon('heroicon-m-x-mark')
    ->color('danger')
    ->requiresConfirmation()
    ->action(function (ResetStars $resetStars) {
        $resetStars();
    })
```

### Adding an affix action to a entry

Certain entries support "affix actions", which are buttons that can be placed before or after its content. The following entries support affix actions:

- [Text entry](entries/text-entry)

To define an affix action, you can pass it to either `prefixAction()` or `suffixAction()`:

```php
use App\Models\Product;
use Filament\Infolists\Components\Actions\Action;
use Filament\Infolists\Components\TextEntry;

TextEntry::make('cost')
    ->prefix('€')
    ->suffixAction(
        Action::make('copyCostToPrice')
            ->icon('heroicon-m-clipboard')
            ->requiresConfirmation()
            ->action(function (Product $record) {
                $record->price = $record->cost;
                $record->save();
            })
    )
```

<AutoScreenshot name="infolists/entries/actions/suffix" alt="Text entry with suffix action" version="3.x" />

#### Passing multiple affix actions to a entry

You may pass multiple affix actions to an entry by passing them in an array to either `prefixActions()` or `suffixActions()`. Either method can be used, or both at once, Filament will render all the registered actions in order:

```php
use Filament\Infolists\Components\Actions\Action;
use Filament\Infolists\Components\TextEntry;

TextEntry::make('cost')
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

### Adding a hint action to an entry

All entries support "hint actions", which are rendered aside the entry's [hint](entries/getting-started#adding-a-hint-next-to-the-label). To add a hint action to a entry, you may pass it to `hintAction()`:

```php
use App\Models\Product;
use Filament\Infolists\Components\Actions\Action;
use Filament\Infolists\Components\TextEntry;

TextEntry::make('cost')
    ->prefix('€')
    ->hintAction(
        Action::make('copyCostToPrice')
            ->icon('heroicon-m-clipboard')
            ->requiresConfirmation()
            ->action(function (Product $record) {
                $record->price = $record->cost;
                $record->save();
            })
    )
```

<AutoScreenshot name="infolists/entries/actions/hint" alt="Text entry with hint action" version="3.x" />

#### Passing multiple hint actions to a entry

You may pass multiple hint actions to a entry by passing them in an array to `hintActions()`. Filament will render all the registered actions in order:

```php
use Filament\Infolists\Components\Actions\Action;
use Filament\Infolists\Components\TextEntry;

TextEntry::make('cost')
    ->prefix('€')
    ->hintActions([
        Action::make('...'),
        Action::make('...'),
        Action::make('...'),
    ])
```

### Adding an action to a custom infolist component

If you wish to render an action within a custom infolist component, `ViewEntry` object, or `View` component object, you may do so using the `registerActions()` method:

```php
use App\Models\Post;
use Filament\Forms\Components\TextInput;
use Filament\Infolists\Components\Actions\Action;
use Filament\Infolists\Components\ViewEntry;
use Filament\Infolists\Set;

ViewEntry::make('status')
    ->view('filament.infolists.entries.status-switcher')
    ->registerActions([
        Action::make('createStatus')
            ->form([
                TextInput::make('name')
                    ->required(),
            ])
            ->icon('heroicon-m-plus')
            ->action(function (array $data, Post $record) {
                $record->status()->create($data);
            }),
    ])
```

Now, to render the action in the view of the custom component, you need to call `$getAction()`, passing the name of the action you registered:

```blade
<div>
    <select></select>
    
    {{ $getAction('createStatus') }}
</div>
```

### Adding "anonymous" actions to an infolist without attaching them to a component

You may use an `Actions` component to render a set of actions anywhere in the infolist, avoiding the need to register them to any particular component:

```php
use App\Actions\Star;
use App\Actions\ResetStars;
use Filament\Infolists\Components\Actions;
use Filament\Infolists\Components\Actions\Action;

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

<AutoScreenshot name="infolists/layout/actions/anonymous/simple" alt="Anonymous actions" version="3.x" />

#### Making the independent infolist actions consume the full width of the infolist

You can stretch the independent infolist actions to consume the full width of the infolist using `fullWidth()`:

```php
use Filament\Infolists\Components\Actions;

Actions::make([
    // ...
])->fullWidth(),
```

<AutoScreenshot name="infolists/layout/actions/anonymous/full-width" alt="Anonymous actions consuming the full width" version="3.x" />

#### Controlling the horizontal alignment of independent infolist actions

Independent infolist actions are aligned to the start of the component by default. You may change this by passing `Alignment::Center` or `Alignment::End` to `alignment()`:

```php
use Filament\Infolists\Components\Actions;
use Filament\Support\Enums\Alignment;

Actions::make([
    // ...
])->alignment(Alignment::Center),
```

<AutoScreenshot name="infolists/layout/actions/anonymous/horizontally-aligned-center" alt="Anonymous actions horizontally aligned to the center" version="3.x" />

#### Controlling the vertical alignment of independent infolist actions

Independent infolist actions are vertically aligned to the start of the component by default. You may change this by passing `Alignment::Center` or `Alignment::End` to `verticalAlignment()`:

```php
use Filament\Infolists\Components\Actions;
use Filament\Support\Enums\VerticalAlignment;

Actions::make([
    // ...
])->verticalAlignment(VerticalAlignment::End),
```

<AutoScreenshot name="infolists/layout/actions/anonymous/vertically-aligned-end" alt="Anonymous actions vertically aligned to the end" version="3.x" />

# Documentation for infolists. File: 06-advanced.md
---
title: Advanced infolists
---

## Inserting Livewire components into an infolist

You may insert a Livewire component directly into an infolist:

```php
use Filament\Infolists\Components\Livewire;
use App\Livewire\Foo;

Livewire::make(Foo::class)
```

If you are rendering multiple of the same Livewire component, please make sure to pass a unique `key()` to each:

```php
use Filament\Infolists\Components\Livewire;
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
use Filament\Infolists\Components\Livewire;
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
    public function mount(Model $record): void
    {       
        // ...
    }
    
    // or
    
    public Model $record;
}
```

### Lazy loading a Livewire component

You may allow the component to [lazily load](https://livewire.laravel.com/docs/lazy#rendering-placeholder-html) using the `lazy()` method:

```php
use Filament\Infolists\Components\Livewire;
use App\Livewire\Foo;

Livewire::make(Foo::class)->lazy()       
```

# Documentation for infolists. File: 07-adding-an-infolist-to-a-livewire-component.md
---
title: Adding an infolist to a Livewire component
---

## Setting up the Livewire component

First, generate a new Livewire component:

```bash
php artisan make:livewire ViewProduct
```

Then, render your Livewire component on the page:

```blade
@livewire('view-product')
```

Alternatively, you can use a full-page Livewire component:

```php
use App\Livewire\ViewProduct;
use Illuminate\Support\Facades\Route;

Route::get('products/{product}', ViewProduct::class);
```

You must use the `InteractsWithInfolists` and `InteractsWithForms` traits, and implement the `HasInfolists` and `HasForms` interfaces on your Livewire component class:

```php
use Filament\Forms\Concerns\InteractsWithForms;
use Filament\Forms\Contracts\HasForms;
use Filament\Infolists\Concerns\InteractsWithInfolists;
use Filament\Infolists\Contracts\HasInfolists;
use Livewire\Component;

class ViewProduct extends Component implements HasForms, HasInfolists
{
    use InteractsWithInfolists;
    use InteractsWithForms;

    // ...
}
```

## Adding the infolist

Next, add a method to the Livewire component which accepts an `$infolist` object, modifies it, and returns it:

```php
use Filament\Infolists\Infolist;

public function productInfolist(Infolist $infolist): Infolist
{
    return $infolist
        ->record($this->product)
        ->schema([
            // ...
        ]);
}
```

Finally, render the infolist in the Livewire component's view:

```blade
{{ $this->productInfolist }}
```

## Passing data to the infolist

You can pass data to the infolist in two ways:

Either pass an Eloquent model instance to the `record()` method of the infolist, to automatically map all the model attributes and relationships to the entries in the infolist's schema:

```php
use Filament\Infolists\Components\TextEntry;
use Filament\Infolists\Infolist;

public function productInfolist(Infolist $infolist): Infolist
{
    return $infolist
        ->record($this->product)
        ->schema([
            TextEntry::make('name'),
            TextEntry::make('category.name'),
            // ...
        ]);
}
```

Alternatively, you can pass an array of data to the `state()` method of the infolist, to manually map the data to the entries in the infolist's schema:

```php
use Filament\Infolists\Components\TextEntry;
use Filament\Infolists\Infolist;

public function productInfolist(Infolist $infolist): Infolist
{
    return $infolist
        ->state([
            'name' => 'MacBook Pro',
            'category' => [
                'name' => 'Laptops',
            ],
            // ...
        ])
        ->schema([
            TextEntry::make('name'),
            TextEntry::make('category.name'),
            // ...
        ]);
}
```

# Documentation for infolists. File: 08-testing.md
---
title: Testing
---

## Overview

All examples in this guide will be written using [Pest](https://pestphp.com). To use Pest's Livewire plugin for testing, you can follow the installation instructions in the Pest documentation on plugins: [Livewire plugin for Pest](https://pestphp.com/docs/plugins#livewire). However, you can easily adapt this to PHPUnit.

Since the Infolist Builder works on Livewire components, you can use the [Livewire testing helpers](https://livewire.laravel.com/docs/testing). However, we have custom testing helpers that you can use with infolists:

## Actions

You can call an action by passing its infolist component key, and then the name of the action to `callInfolistAction()`:

```php
use function Pest\Livewire\livewire;

it('can send invoices', function () {
    $invoice = Invoice::factory()->create();

    livewire(EditInvoice::class, [
        'invoice' => $invoice,
    ])
        ->callInfolistAction('customer', 'send', infolistName: 'infolist');

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
        ->callInfolistAction('customer', 'send', data: [
            'email' => $email = fake()->email(),
        ])
        ->assertHasNoInfolistActionErrors();

    expect($invoice->refresh())
        ->isSent()->toBeTrue()
        ->recipient_email->toBe($email);
});
```

If you ever need to only set an action's data without immediately calling it, you can use `setInfolistActionData()`:

```php
use function Pest\Livewire\livewire;

it('can send invoices', function () {
    $invoice = Invoice::factory()->create();

    livewire(EditInvoice::class, [
        'invoice' => $invoice,
    ])
        ->mountInfolistAction('customer', 'send')
        ->setInfolistActionData([
            'email' => $email = fake()->email(),
        ])
});
```

### Execution

To check if an action has been halted, you can use `assertInfolistActionHalted()`:

```php
use function Pest\Livewire\livewire;

it('stops sending if invoice has no email address', function () {
    $invoice = Invoice::factory(['email' => null])->create();

    livewire(EditInvoice::class, [
        'invoice' => $invoice,
    ])
        ->callInfolistAction('customer', 'send')
        ->assertInfolistActionHalted('customer', 'send');
});
```

### Errors

`assertHasNoInfolistActionErrors()` is used to assert that no validation errors occurred when submitting the action form.

To check if a validation error has occurred with the data, use `assertHasInfolistActionErrors()`, similar to `assertHasErrors()` in Livewire:

```php
use function Pest\Livewire\livewire;

it('can validate invoice recipient email', function () {
    $invoice = Invoice::factory()->create();

    livewire(EditInvoice::class, [
        'invoice' => $invoice,
    ])
        ->callInfolistAction('customer', 'send', data: [
            'email' => Str::random(),
        ])
        ->assertHasInfolistActionErrors(['email' => ['email']]);
});
```

To check if an action is pre-filled with data, you can use the `assertInfolistActionDataSet()` method:

```php
use function Pest\Livewire\livewire;

it('can send invoices to the primary contact by default', function () {
    $invoice = Invoice::factory()->create();
    $recipientEmail = $invoice->company->primaryContact->email;

    livewire(EditInvoice::class, [
        'invoice' => $invoice,
    ])
        ->mountInfolistAction('customer', 'send')
        ->assertInfolistActionDataSet([
            'email' => $recipientEmail,
        ])
        ->callMountedInfolistAction()
        ->assertHasNoInfolistActionErrors();
        
    expect($invoice->refresh())
        ->isSent()->toBeTrue()
        ->recipient_email->toBe($recipientEmail);
});
```

### Action state

To ensure that an action exists or doesn't in an infolist, you can use the `assertInfolistActionExists()` or  `assertInfolistActionDoesNotExist()` method:

```php
use function Pest\Livewire\livewire;

it('can send but not unsend invoices', function () {
    $invoice = Invoice::factory()->create();

    livewire(EditInvoice::class, [
        'invoice' => $invoice,
    ])
        ->assertInfolistActionExists('customer', 'send')
        ->assertInfolistActionDoesNotExist('customer', 'unsend');
});
```

To ensure an action is hidden or visible for a user, you can use the `assertInfolistActionHidden()` or `assertInfolistActionVisible()` methods:

```php
use function Pest\Livewire\livewire;

it('can only print customers', function () {
    $invoice = Invoice::factory()->create();

    livewire(EditInvoice::class, [
        'invoice' => $invoice,
    ])
        ->assertInfolistActionHidden('customer', 'send')
        ->assertInfolistActionVisible('customer', 'print');
});
```

To ensure an action is enabled or disabled for a user, you can use the `assertInfolistActionEnabled()` or `assertInfolistActionDisabled()` methods:

```php
use function Pest\Livewire\livewire;

it('can only print a customer for a sent invoice', function () {
    $invoice = Invoice::factory()->create();

    livewire(EditInvoice::class, [
        'invoice' => $invoice,
    ])
        ->assertInfolistActionDisabled('customer', 'send')
        ->assertInfolistActionEnabled('customer', 'print');
});
```

To check if an action is hidden to a user, you can use the `assertInfolistActionHidden()` method:

```php
use function Pest\Livewire\livewire;

it('can not send invoices', function () {
    $invoice = Invoice::factory()->create();

    livewire(EditInvoice::class, [
        'invoice' => $invoice,
    ])
        ->assertInfolistActionHidden('customer', 'send');
});
```

### Button appearance

To ensure an action has the correct label, you can use `assertInfolistActionHasLabel()` and `assertInfolistActionDoesNotHaveLabel()`:

```php
use function Pest\Livewire\livewire;

it('send action has correct label', function () {
    $invoice = Invoice::factory()->create();

    livewire(EditInvoice::class, [
        'invoice' => $invoice,
    ])
        ->assertInfolistActionHasLabel('customer', 'send', 'Email Invoice')
        ->assertInfolistActionDoesNotHaveLabel('customer', 'send', 'Send');
});
```

To ensure an action's button is showing the correct icon, you can use `assertInfolistActionHasIcon()` or `assertInfolistActionDoesNotHaveIcon()`:

```php
use function Pest\Livewire\livewire;

it('when enabled the send button has correct icon', function () {
    $invoice = Invoice::factory()->create();

    livewire(EditInvoice::class, [
        'invoice' => $invoice,
    ])
        ->assertInfolistActionEnabled('customer', 'send')
        ->assertInfolistActionHasIcon('customer', 'send', 'envelope-open')
        ->assertInfolistActionDoesNotHaveIcon('customer', 'send', 'envelope');
});
```

To ensure that an action's button is displaying the right color, you can use `assertInfolistActionHasColor()` or `assertInfolistActionDoesNotHaveColor()`:

```php
use function Pest\Livewire\livewire;

it('actions display proper colors', function () {
    $invoice = Invoice::factory()->create();

    livewire(EditInvoice::class, [
        'invoice' => $invoice,
    ])
        ->assertInfolistActionHasColor('customer', 'delete', 'danger')
        ->assertInfolistActionDoesNotHaveColor('customer', 'print', 'danger');
});
```

### URL

To ensure an action has the correct URL, you can use `assertInfolistActionHasUrl()`, `assertInfolistActionDoesNotHaveUrl()`, `assertInfolistActionShouldOpenUrlInNewTab()`, and `assertInfolistActionShouldNotOpenUrlInNewTab()`:

```php
use function Pest\Livewire\livewire;

it('links to the correct Filament sites', function () {
    $invoice = Invoice::factory()->create();

    livewire(EditInvoice::class, [
        'invoice' => $invoice,
    ])
        ->assertInfolistActionHasUrl('customer', 'filament', 'https://filamentphp.com/')
        ->assertInfolistActionDoesNotHaveUrl('customer', 'filament', 'https://github.com/filamentphp/filament')
        ->assertInfolistActionShouldOpenUrlInNewTab('customer', 'filament')
        ->assertInfolistActionShouldNotOpenUrlInNewTab('customer', 'github');
});
```

