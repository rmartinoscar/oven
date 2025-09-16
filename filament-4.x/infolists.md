# Documentation for infolists. File: 01-overview.md
---
title: Overview
---
import Aside from "@components/Aside.astro"
import AutoScreenshot from "@components/AutoScreenshot.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

<AutoScreenshot name="infolists/overview" alt="Product infolist example" version="4.x" />

Filament's infolists package lets you display a read-only list of data for a specific entity. It's integrated into other Filament packages, such as inside [panel resources](../panels/resources), [relation managers](../panels/resources/managing-relationships), and [action modals](../actions). Understanding how to use the infolist builder will save you time when building custom Livewire applications or working with other Filament features.

This guide covers the fundamentals of building infolists with Filament. If you want to add an infolist to your own Livewire component, [start here](../components/infolist) before continuing. If you're adding an infolist to an [panel resource](../panels/resources), or using another Filament package, you're ready to begin!

## Defining entries

Entry classes can be found in the `Filament\Infolists\Components` namespace. They reside within the schema array of components. Filament includes a number of entries built-in:

- [Text entry](text-entry)
- [Icon entry](icon-entry)
- [Image entry](image-entry)
- [Color entry](color-entry)
- [Code entry](code-entry)
- [Key-value entry](key-value-entry)
- [Repeatable entry](repeatable-entry)

You may also [create your own custom entries](custom-entries) to display data however you wish.

Entries may be created using the static `make()` method, passing its unique name. Usually, the name of an entry corresponds to the name of an attribute on an Eloquent model. You may use "dot notation" to access attributes within relationships:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('title')

TextEntry::make('author.name')
```

<AutoScreenshot name="infolists/entries/simple" alt="Entries in an infolist" version="4.x" />

## Entry content (state)

Entries may feel a bit magic at first, but they are designed to be simple to use and optimized to display data from an Eloquent record. Despite this, they are flexible and you can display data from any source, not just an Eloquent record attribute.

The data that an entry displays is called its "state". When using a [panel resource](../resources), the infolist is aware of the record it is displaying. This means that the state of the entry is set based on the value of the attribute on the record. For example, if the entry is used in the infolist of a `PostResource`, then the `title` attribute value of the current post will be displayed.

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('title')
```

If you want to access the value stored in a relationship, you can use "dot notation". The name of the relationship that you would like to access data from comes first, followed by a dot, and then the name of the attribute:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('author.name')
```

You can also use "dot notation" to access values within a JSON / array column on an Eloquent model. The name of the attribute comes first, followed by a dot, and then the key of the JSON object you want to read from:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('meta.title')
```

### Setting the state of an entry

You can pass your own state to an entry by using the `state()` method:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('title')
    ->state('Hello, world!')
```

<UtilityInjection set="infolistEntries" except="$state" version="4.x">The `state()` method also accepts a function to dynamically calculate the state. You can inject various utilities into the function as parameters.</UtilityInjection>

### Setting the default state of an entry

When an entry is empty (its state is `null`), you can use the `default()` method to define alternative state to use instead. This method will treat the default state as if it were real, so entries like [image](image-entry) or [color](color-entry) will display the default image or color.

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('title')
    ->default('Untitled')
```

#### Adding placeholder text if an entry is empty

Sometimes you may want to display placeholder text for entries with an empty state, which is styled as a lighter gray text. This differs from the [default value](#setting-the-default-state-of-an-entry), as the placeholder is always text and not treated as if it were real state.

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('title')
    ->placeholder('Untitled')
```

<AutoScreenshot name="infolists/entries/placeholder" alt="Entry with a placeholder for empty state" version="4.x" />

## Setting an entry's label

By default, the label of the entry, which is displayed in the header of the infolist, is generated from the name of the entry. You may customize this using the `label()` method:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('name')
    ->label('Full name')
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `label()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

Customizing the label in this way is useful if you wish to use a [translation string for localization](https://laravel.com/docs/localization#retrieving-translation-strings):

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('name')
    ->label(__('entries.name'))
```

### Hiding an entry's label

<Aside variant="tip">
    If you're looking to hide an entry's label, it might be the case that you are trying to use an entry for arbitrary text or UI. Entries are specifically designed to display data in a structured way, but [Prime components](../schemas/primes) are simple components that are used to render basic stand-alone static content, such as text, images, and buttons (actions). You may want to consider using a Prime component instead.
</Aside>

It may be tempting to set the label to an empty string to hide it, but this is not recommended. Setting the label to an empty string will not communicate the purpose of the entry to screen readers, even if the purpose is clear visually. Instead, you should use the `hiddenLabel()` method, so it is hidden visually but still accessible to screen readers:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('name')
    ->hiddenLabel()
```

Optionally, you may pass a boolean value to control if the label should be hidden or not:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('name')
    ->hiddenLabel(FeatureFlag::active())
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `hiddenLabel()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Opening a URL when an entry is clicked

When an entry is clicked, you may open a URL. To do this, pass a URL to the `url()` method:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('title')
    ->url('/about/titles')
```

You may pass a function to the `url()` method to dynamically calculate the URL. For example, you may want to access the current Eloquent record for the infolist by injecting `$record` as an argument:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('title')
    ->url(fn (Post $record): string => route('posts.edit', ['post' => $record]))
```

If you're using a [panel resource](../resources), you can generate a link to a page for the record using the `getUrl()` method:

```php
use App\Filament\Posts\PostResource;
use Filament\Infolists\Components\TextEntry;

TextEntry::make('title')
    ->url(fn (Post $record): string => PostResource::getUrl('edit', ['record' => $record]))
```

<UtilityInjection set="infolistEntries" version="4.x">The function passed to `url()` can inject various utilities as parameters.</UtilityInjection>

You may also choose to open the URL in a new tab:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('title')
    ->url(fn (Post $record): string => PostResource::getUrl('edit', ['record' => $record]))
    ->openUrlInNewTab()
```

Optionally, you may pass a boolean value to control if the URL should open in a new tab or not:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('title')
    ->url(fn (Post $record): string => PostResource::getUrl('edit', ['record' => $record]))
    ->openUrlInNewTab(FeatureFlag::active())
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `openUrlInNewTab()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Hiding an entry

You may hide an entry:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('role')
    ->hidden()
```

Optionally, you may pass a boolean value to control if the entry should be hidden or not:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('role')
    ->hidden(! FeatureFlag::active())
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `hidden()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

Alternatively, you may use the `visible()` method to control if the entry should be hidden or not. In some situations, this may help to make your code more readable:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('role')
    ->visible(FeatureFlag::active())
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `visible()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<Aside variant="info">
    If both `hidden()` and `visible()` are used, they both need to indicate that the entry should be visible for it to be shown.
</Aside>

### Hiding an entry using JavaScript

If you need to hide an entry based on a user interaction, you can use the `hidden()` or `visible()` methods, passing a function that uses utilities injected to determine whether the entry should be hidden or not:

```php
use Filament\Forms\Components\Select;
use Filament\Infolists\Components\IconEntry;

Select::make('role')
    ->options([
        'user' => 'User',
        'staff' => 'Staff',
    ])
    ->live()

IconEntry::make('is_admin')
    ->boolean()
    ->hidden(fn (Get $get): bool => $get('role') !== 'staff')
```

In this example, the `role` field is set to `live()`, which means that the schema will reload the schema each time the `role` field is changed. This will cause the function that is passed to the `hidden()` method to be re-evaluated, which will hide the `is_admin` entry if the `role` field is not set to `staff`.

However, reloading the schema each time an entry causes a network request to be made, since there is no way to re-run the PHP function from the client-side. This is not ideal for performance.

Alternatively, you can write JavaScript to hide the entry based on the value of a field. This is done by passing a JavaScript expression to the `hiddenJs()` method:

```php
use Filament\Forms\Components\Select;
use Filament\Infolists\Components\IconEntry;

Select::make('role')
    ->options([
        'user' => 'User',
        'staff' => 'Staff',
    ])

IconEntry::make('is_admin')
    ->boolean()
    ->hiddenJs(<<<'JS'
        $get('role') !== 'staff'
        JS)
```

Although the code passed to `hiddenJs()` looks very similar to PHP, it is actually JavaScript. Filament provides the `$get()` utility function to JavaScript that behaves very similar to its PHP equivalent, but without requiring the depended-on entry to be `live()`.

The `visibleJs()` method is also available, which works in the same way as `hiddenJs()`, but controls if the entry should be visible or not:

```php
use Filament\Forms\Components\Select;
use Filament\Infolists\Components\IconEntry;

Select::make('role')
    ->options([
        'user' => 'User',
        'staff' => 'Staff',
    ])
    
IconEntry::make('is_admin')
    ->boolean()
    ->visibleJs(<<<'JS'
        $get('role') === 'staff'
        JS)
```

<Aside variant="info">
    If both `hiddenJs()` and `visibleJs()` are used, they both need to indicate that the entry should be visible for it to be shown.
</Aside>

### Hiding an entry based on the current operation

The "operation" of a schema is the current action being performed on it. Usually, this is either `create`, `edit` or `view`, if you are using the [panel resource](../resources).

You can hide an entry based on the current operation by passing an operation to the `hiddenOn()` method:

```php
use Filament\Infolists\Components\IconEntry;

IconEntry::make('is_admin')
    ->boolean()
    ->hiddenOn('edit')
    
// is the same as

IconEntry::make('is_admin')
    ->boolean()
    ->hidden(fn (string $operation): bool => $operation === 'edit')
```

You can also pass an array of operations to the `hiddenOn()` method, and the entry will be hidden if the current operation is any of the operations in the array:

```php
use Filament\Infolists\Components\IconEntry;

IconEntry::make('is_admin')
    ->boolean()
    ->hiddenOn(['edit', 'view'])
    
// is the same as

IconEntry::make('is_admin')
    ->boolean()
    ->hidden(fn (string $operation): bool => in_array($operation, ['edit', 'view']))
```

<Aside variant="warning">
    The `hiddenOn()` method will overwrite any previous calls to the `hidden()` method, and vice versa.
</Aside>

Alternatively, you may use the `visibleOn()` method to control if the entry should be hidden or not. In some situations, this may help to make your code more readable:

```php
use Filament\Infolists\Components\IconEntry;

IconEntry::make('is_admin')
    ->boolean()
    ->visibleOn('create')

IconEntry::make('is_admin')
    ->boolean()
    ->visibleOn(['create', 'edit'])
```

<Aside variant="info">
    The `visibleOn()` method will overwrite any previous calls to the `visible()` method, and vice versa.
</Aside>

## Inline labels

Entries may have their labels displayed inline with the entry, rather than above it. This is useful for infolists with many entries, where vertical space is at a premium. To display an entry's label inline, use the `inlineLabel()` method:

```php
use Filament\Infolists\Components\TextEntry;

TextInput::make('name')
    ->inlineLabel()
```

<AutoScreenshot name="infolists/entries/inline-label" alt="Infolist entry with inline label" version="4.x" />

Optionally, you may pass a boolean value to control if the label should be displayed inline or not:

```php
use Filament\Infolists\Components\TextInput;

TextInput::make('name')
    ->inlineLabel(FeatureFlag::active())
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `inlineLabel()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Using inline labels in multiple places at once

If you wish to display all labels inline in a [layout component](../schemas/layouts) like a [section](../schemas/section) or [tab](../schemas/tabs), you can use the `inlineLabel()` on the component itself, and all entries within it will have their labels displayed inline:

```php
use Filament\Infolists\Components\TextInput;
use Filament\Schemas\Components\Section;

Section::make('Details')
    ->inlineLabel()
    ->entries([
        TextInput::make('name'),
        TextInput::make('email')
            ->label('Email address'),
        TextInput::make('phone')
            ->label('Phone number'),
    ])
```

<AutoScreenshot name="infolists/entries/inline-label/section" alt="Infolist entries with inline labels in a section" version="4.x" />

You can also use `inlineLabel()` on the entire schema to display all labels inline:

```php
use Filament\Schemas\Schema;

public function infolist(Schema $schema): Schema
{
    return $schema
        ->inlineLabel()
        ->components([
            // ...
        ]);
}
```

When using `inlineLabel()` on a layout component or schema, you can still opt-out of inline labels for individual entries by using the `inlineLabel(false)` method on the entry:

```php
use Filament\Infolists\Components\TextInput;
use Filament\Schemas\Components\Section;

Section::make('Details')
    ->inlineLabel()
    ->entries([
        TextInput::make('name'),
        TextInput::make('email')
            ->label('Email address'),
        TextInput::make('phone')
            ->label('Phone number')
            ->inlineLabel(false),
    ])
```

## Adding a tooltip to an entry

You may specify a tooltip to display when you hover over an entry:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('title')
    ->tooltip('Shown at the top of the page')
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `tooltip()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="infolists/entries/tooltips" alt="Entry with tooltip" version="4.x" />

## Aligning entry content

You may align the content of an entry to the start (left in left-to-right interfaces, right in right-to-left interfaces), center, or end (right in left-to-right interfaces, left in right-to-left interfaces) using the `alignStart()`, `alignCenter()` or `alignEnd()` methods:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('title')
    ->alignStart() // This is the default alignment.

TextEntry::make('title')
    ->alignCenter()

TextEntry::make('title')
    ->alignEnd()
```

Alternatively, you may pass an `Alignment` enum to the `alignment()` method:

```php
use Filament\Infolists\Components\TextEntry;
use Filament\Support\Enums\Alignment;

TextEntry::make('title')
    ->alignment(Alignment::Center)
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `alignment()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Adding extra content to an entry

Entries contain many "slots" where content can be inserted in a child schema. Slots can accept text, [any schema component](../schemas), [actions](../actions) and [action groups](../actions/grouping-actions). Usually, [prime components](../schemas/primes) are used for content.

The following slots are available for all entries:

- `aboveLabel()`
- `beforeLabel()`
- `afterLabel()`
- `belowLabel()`
- `aboveContent()`
- `beforeContent()`
- `afterContent()`
- `belowContent()`

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing static values, the slot methods also accept functions to dynamically calculate them. You can inject various utilities into the functions as parameters.</UtilityInjection>

To insert plain text, you can pass a string to these methods:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('name')
    ->belowContent('This is the user\'s full name.')
```

<AutoScreenshot name="infolists/entries/below-content/text" alt="Infolist entry with text below content" version="4.x" />

To insert a schema component, often a [prime component](../schemas/primes), you can pass the component to the method:

```php
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Components\Text;
use Filament\Support\Enums\FontWeight;

TextEntry::make('name')
    ->belowContent(Text::make('This is the user\'s full name.')->weight(FontWeight::Bold))
```

<AutoScreenshot name="infolists/entries/below-content/component" alt="Infolist entry with component below content" version="4.x" />

To insert an [action](../actions) or [action group](../actions/grouping-actions), you can pass the action or action group to the method:

```php
use Filament\Actions\Action;
use Filament\Infolists\Components\TextEntry;

TextEntry::make('name')
    ->belowContent(Action::make('generate'))
```

<AutoScreenshot name="infolists/entries/below-content/action" alt="Infolist entry with action below content" version="4.x" />

You can insert any combination of content into the slots by passing an array of content to the method:

```php
use Filament\Actions\Action;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Components\Icon;
use Filament\Support\Icons\Heroicon;

TextEntry::make('name')
    ->belowContent([
        Icon::make(Heroicon::InformationCircle),
        'This is the user\'s full name.',
        Action::make('generate'),
    ])
```

<AutoScreenshot name="infolists/entries/below-content" alt="Infolist entry with multiple components below content" version="4.x" />

You can also align the content in the slots by passing the array of content to either `Schema::start()` (default), `Schema::end()` or `Schema::between()`:

```php
use Filament\Actions\Action;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Components\Flex;
use Filament\Schemas\Components\Icon;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;

TextEntry::make('name')
    ->belowContent(Schema::end([
        Icon::make(Heroicon::InformationCircle),
        'This is the user\'s full name.',
        Action::make('generate'),
    ]))

TextEntry::make('name')
    ->belowContent(Schema::between([
        Icon::make(Heroicon::InformationCircle),
        'This is the user\'s full name.',
        Action::make('generate'),
    ]))

TextEntry::make('name')
    ->belowContent(Schema::between([
        Flex::make([
            Icon::make(Heroicon::InformationCircle)
                ->grow(false),
            'This is the user\'s full name.',
        ]),
        Action::make('generate'),
    ]))
```

<Aside variant="tip">
    As you can see in the above example for `Schema::between()`, a [`Flex` component](../schemas/layouts#flex-component) is used to group the icon and text together so they do not have space between them. The icon uses `grow(false)` to prevent it from taking up half of the horizontal space, allowing the text to consume the remaining space.
</Aside>

<AutoScreenshot name="infolists/entries/below-content/alignment" alt="Infolist entry with aligned components below content" version="4.x" />

### Adding extra content above an entry's label

You can insert extra content above an entry's label using the `aboveLabel()` method. You can [pass any content](#adding-extra-content-to-a-entry) to this method, like text, a schema component, an action, or an action group:

```php
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Components\Icon;
use Filament\Support\Icons\Heroicon;

TextEntry::make('name')
    ->aboveLabel([
        Icon::make(Heroicon::Star),
        'This is the content above the entry\'s label'
    ])
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `aboveLabel()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="infolists/entries/above-label" alt="Infolist entry with extra content above label" version="4.x" />

### Adding extra content before an entry's label

You can insert extra content before an entry's label using the `beforeLabel()` method. You can [pass any content](#adding-extra-content-to-a-entry) to this method, like text, a schema component, an action, or an action group:

```php
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Components\Icon;
use Filament\Support\Icons\Heroicon;

TextEntry::make('name')
    ->beforeLabel(Icon::make(Heroicon::Star))
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `beforeLabel()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="infolists/entries/before-label" alt="Infolist entry with extra content before label" version="4.x" />

### Adding extra content after an entry's label

You can insert extra content after an entry's label using the `afterLabel()` method. You can [pass any content](#adding-extra-content-to-a-entry) to this method, like text, a schema component, an action, or an action group:

```php
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Components\Icon;
use Filament\Support\Icons\Heroicon;

TextEntry::make('name')
    ->afterLabel([
        Icon::make(Heroicon::Star),
        'This is the content after the entry\'s label'
    ])
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `afterLabel()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="infolists/entries/after-label" alt="Infolist entry with extra content after label" version="4.x" />

By default, the content in the `afterLabel()` schema is aligned to the end of the container. If you wish to align it to the start of the container, you should pass a `Schema::start()` object containing the content:

```php
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Components\Icon;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;

TextEntry::make('name')
    ->afterLabel(Schema::start([
        Icon::make(Heroicon::Star),
        'This is the content after the entry\'s label'
    ]))
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `afterLabel()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="infolists/entries/after-label/aligned-start" alt="Infolist entry with extra content after label aligned to the start" version="4.x" />

### Adding extra content below an entry's label

You can insert extra content below an entry's label using the `belowLabel()` method. You can [pass any content](#adding-extra-content-to-a-entry) to this method, like text, a schema component, an action, or an action group:

```php
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Components\Icon;
use Filament\Support\Icons\Heroicon;

TextEntry::make('name')
    ->belowLabel([
        Icon::make(Heroicon::Star),
        'This is the content below the entry\'s label'
    ])
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `belowLabel()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="infolists/entries/below-label" alt="Infolist entry with extra content below label" version="4.x" />

<Aside variant="info">
    This may seem like the same as the [`aboveContent()` method](#adding-extra-content-above-a-entries-content). However, when using [inline labels](#inline-labels), the `aboveContent()` method will place the content above the entry, not below the label, since the label is displayed in a separate column to the entry content.
</Aside>

### Adding extra content above an entry's content

You can insert extra content above an entry's content using the `aboveContent()` method. You can [pass any content](#adding-extra-content-to-a-entry) to this method, like text, a schema component, an action, or an action group:

```php
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Components\Icon;
use Filament\Support\Icons\Heroicon;

TextEntry::make('name')
    ->aboveContent([
        Icon::make(Heroicon::Star),
        'This is the content above the entry\'s content'
    ])
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `aboveContent()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="infolists/entries/above-content" alt="Infolist entry with extra content above content" version="4.x" />

<Aside variant="info">
    This may seem like the same as the [`belowLabel()` method](#adding-extra-content-below-a-entries-label). However, when using [inline labels](#inline-labels), the `belowLabel()` method will place the content below the label, not above the entry's content, since the label is displayed in a separate column to the entry content.
</Aside>

### Adding extra content before an entry's content

You can insert extra content before an entry's content using the `beforeContent()` method. You can [pass any content](#adding-extra-content-to-a-entry) to this method, like text, a schema component, an action, or an action group:

```php
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Components\Icon;
use Filament\Support\Icons\Heroicon;

TextEntry::make('name')
    ->beforeContent(Icon::make(Heroicon::Star))
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `beforeContent()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="infolists/entries/before-content" alt="Infolist entry with extra content before content" version="4.x" />

### Adding extra content after an entry's content

You can insert extra content after an entry's content using the `afterContent()` method. You can [pass any content](#adding-extra-content-to-a-entry) to this method, like text, a schema component, an action, or an action group:

```php
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Components\Icon;
use Filament\Support\Icons\Heroicon;

TextEntry::make('name')
    ->afterContent(Icon::make(Heroicon::Star))
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `afterContent()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="infolists/entries/after-content" alt="Infolist entry with extra content after content" version="4.x" />

## Adding extra HTML attributes to an entry

You can pass extra HTML attributes to the entry via the `extraAttributes()` method, which will be merged onto its outer HTML element. The attributes should be represented by an array, where the key is the attribute name and the value is the attribute value:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('slug')
    ->extraAttributes(['class' => 'bg-gray-200'])
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `extraAttributes()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

By default, calling `extraAttributes()` multiple times will overwrite the previous attributes. If you wish to merge the attributes instead, you can pass `merge: true` to the method.

### Adding extra HTML attributes to the entry wrapper

You can also pass extra HTML attributes to the very outer element of the "entry wrapper" which surrounds the label and content of the entry. This is useful if you want to style the label or spacing of the entry via CSS, since you could target elements as children of the wrapper:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('slug')
    ->extraEntryWrapperAttributes(['class' => 'components-locked'])
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `extraEntryWrapperAttributes()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

By default, calling `extraEntryWrapperAttributes()` multiple times will overwrite the previous attributes. If you wish to merge the attributes instead, you can pass `merge: true` to the method.

## Entry utility injection

The vast majority of methods used to configure entries accept functions as parameters instead of hardcoded values:

```php
use App\Models\User;
use Filament\Infolists\Components\TextEntry;

TextEntry::make('name')
    ->label(fn (string $state): string => str_contains($state, ' ') ? 'Full name' : 'Name')

TextEntry::make('currentUserEmail')
    ->state(fn (): string => auth()->user()->email)

TextEntry::make('role')
    ->hidden(fn (User $record): bool => $record->role === 'admin')
```

This alone unlocks many customization possibilities.

The package is also able to inject many utilities to use inside these functions, as parameters. All customization methods that accept functions as arguments can inject utilities.

These injected utilities require specific parameter names to be used. Otherwise, Filament doesn't know what to inject.

### Injecting the current state of the entry

If you wish to access the current [value (state)](#entry-content-state) of the entry, define a `$state` parameter:

```php
function ($state) {
    // ...
}
```

### Injecting the state of another entry or form field

You may also retrieve the state (value) of another entry or form field from within a callback, using a `$get` parameter:

```php
use Filament\Schemas\Components\Utilities\Get;

function (Get $get) {
    $email = $get('email'); // Store the value of the `email` entry in the `$email` variable.
    //...
}
```

<Aside variant="tip">
    Unless a form field is [reactive](../forms/overview#the-basics-of-reactivity), the schema will not refresh when the value of the field changes, only when the next user interaction occurs that makes a request to the server. If you need to react to changes in a field's value, it should be `live()`.
</Aside>

### Injecting the current Eloquent record

You may retrieve the Eloquent record for the current schema using a `$record` parameter:

```php
use Illuminate\Database\Eloquent\Model;

function (?Model $record) {
    // ...
}
```

### Injecting the current operation

If you're writing a schema for a panel resource or relation manager, and you wish to check if a schema is `create`, `edit` or `view`, use the `$operation` parameter:

```php
function (string $operation) {
    // ...
}
```

<Aside variant="info">
    You can manually set a schema's operation using the `$schema->operation()` method.
</Aside>

### Injecting the current Livewire component instance

If you wish to access the current Livewire component instance, define a `$livewire` parameter:

```php
use Livewire\Component;

function (Component $livewire) {
    // ...
}
```

### Injecting the current entry instance

If you wish to access the current component instance, define a `$component` parameter:

```php
use Filament\Infolists\Components\Entry;

function (Entry $component) {
    // ...
}
```

### Injecting multiple utilities

The parameters are injected dynamically using reflection, so you are able to combine multiple parameters in any order:

```php
use App\Models\User;
use Filament\Schemas\Components\Utilities\Get;
use Livewire\Component as Livewire;

function (Livewire $livewire, Get $get, User $record) {
    // ...
}
```

### Injecting dependencies from Laravel's container

You may inject anything from Laravel's container like normal, alongside utilities:

```php
use App\Models\User;
use Illuminate\Http\Request;

function (Request $request, User $record) {
    // ...
}
```

## Global settings

If you wish to change the default behavior of all entries globally, then you can call the static `configureUsing()` method inside a service provider's `boot()` method, to which you pass a Closure to modify the entries using. For example, if you wish to make all `TextEntry` components [`words(10)`](text-entry#limiting-word-count), you can do it like so:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::configureUsing(function (TextEntry $entry): void {
    $entry->words(10);
});
```

Of course, you are still able to overwrite this on each entry individually:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('name')
    ->words(null)
```

# Documentation for infolists. File: 02-text-entry.md
---
title: Text entry
---
import Aside from "@components/Aside.astro"
import AutoScreenshot from "@components/AutoScreenshot.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

Text entries display simple text:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('title')
```

<AutoScreenshot name="infolists/entries/text/simple" alt="Text entry" version="4.x" />

## Customizing the color

You may set a [color](../styling/colors) for the text:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('status')
    ->color('primary')
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `color()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="infolists/entries/text/color" alt="Text entry in the primary color" version="4.x" />

## Adding an icon

Text entries may also have an [icon](../styling/icons):

```php
use Filament\Infolists\Components\TextEntry;
use Filament\Support\Icons\Heroicon;

TextEntry::make('email')
    ->icon(Heroicon::Envelope)
```

<UtilityInjection set="infolistEntries" version="4.x">The `icon()` method also accepts a function to dynamically calculate the icon. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="infolists/entries/text/icon" alt="Text entry with icon" version="4.x" />

You may set the position of an icon using `iconPosition()`:

```php
use Filament\Infolists\Components\TextEntry;
use Filament\Support\Enums\IconPosition;
use Filament\Support\Icons\Heroicon;

TextEntry::make('email')
    ->icon(Heroicon::Envelope)
    ->iconPosition(IconPosition::After) // `IconPosition::Before` or `IconPosition::After`
```

<UtilityInjection set="infolistEntries" version="4.x">The `iconPosition()` method also accepts a function to dynamically calculate the icon position. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="infolists/entries/text/icon-after" alt="Text entry with icon after" version="4.x" />

The icon color defaults to the text color, but you may customize the icon [color](../styling/colors) separately using `iconColor()`:

```php
use Filament\Infolists\Components\TextEntry;
use Filament\Support\Icons\Heroicon;

TextEntry::make('email')
    ->icon(Heroicon::Envelope)
    ->iconColor('primary')
```

<UtilityInjection set="infolistEntries" version="4.x">The `iconColor()` method also accepts a function to dynamically calculate the icon color. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="infolists/entries/text/icon-color" alt="Text entry with icon in the primary color" version="4.x" />

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

<AutoScreenshot name="infolists/entries/text/badge" alt="Text entry as badge" version="4.x" />

You may add other things to the badge, like an [icon](#adding-an-icon).

Optionally, you may pass a boolean value to control if the text should be in a badge or not:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('status')
    ->badge(FeatureFlag::active())
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `badge()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Formatting

When using a text entry, you may want the actual outputted text in the UI to differ from the raw [state](overview#entry-content-state) of the entry, which is often automatically retrieved from an Eloquent model. Formatting the state allows you to preserve the integrity of the raw data while also allowing it to be presented in a more user-friendly way.

To format the state of a text entry without changing the state itself, you can use the `formatStateUsing()` method. This method accepts a function that takes the state as an argument and returns the formatted state:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('status')
    ->formatStateUsing(fn (string $state): string => __("statuses.{$state}"))
```

In this case, the `status` column in the database might contain values like `draft`, `reviewing`, `published`, or `rejected`, but the formatted state will be the translated version of these values.

<UtilityInjection set="infolistEntries" version="4.x">The function passed to `formatStateUsing()` can inject various utilities as parameters.</UtilityInjection>

### Date formatting

Instead of passing a function to `formatStateUsing()`, you may use the `date()`, `dateTime()`, and `time()` methods to format the entry's state using [PHP date formatting tokens](https://www.php.net/manual/en/datetime.format.php):

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('created_at')
    ->date()

TextEntry::make('created_at')
    ->dateTime()

TextEntry::make('created_at')
    ->time()
```

You may customize the date format by passing a custom format string to the `date()`, `dateTime()`, or `time()` method. You may use any [PHP date formatting tokens](https://www.php.net/manual/en/datetime.format.php):

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('created_at')
    ->date('M j, Y')
    
TextEntry::make('created_at')
    ->dateTime('M j, Y H:i:s')
    
TextEntry::make('created_at')
    ->time('H:i:s')
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing static values, the `date()`, `dateTime()`, and `time()` methods also accept a function to dynamically calculate the format. You can inject various utilities into the function as parameters.</UtilityInjection>

#### Date formatting using Carbon macro formats

You may use also the `isoDate()`, `isoDateTime()`, and `isoTime()` methods to format the entry's state using [Carbon's macro-formats](https://carbon.nesbot.com/docs/#available-macro-formats):

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('created_at')
    ->isoDate()

TextEntry::make('created_at')
    ->isoDateTime()

TextEntry::make('created_at')
    ->isoTime()
```

You may customize the date format by passing a custom macro format string to the `isoDate()`, `isoDateTime()`, or `isoTime()` method. You may use any [Carbon's macro-formats](https://carbon.nesbot.com/docs/#available-macro-formats):

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('created_at')
    ->isoDate('L')

TextEntry::make('created_at')
    ->isoDateTime('LLL')

TextEntry::make('created_at')
    ->isoTime('LT')
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing static values, the `isoDate()`, `isoDateTime()`, and `isoTime()` methods also accept a function to dynamically calculate the format. You can inject various utilities into the function as parameters.</UtilityInjection>

#### Relative date formatting

You may use the `since()` method to format the entry's state using [Carbon's `diffForHumans()`](https://carbon.nesbot.com/docs/#api-humandiff):

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('created_at')
    ->since()
```

#### Displaying a formatting date in a tooltip

Additionally, you can use the `dateTooltip()`, `dateTimeTooltip()`, `timeTooltip()`, `isoDateTooltip()`, `isoDateTimeTooltip()`, `isoTime()`, `isoTimeTooltip()`, or `sinceTooltip()` method to display a formatted date in a [tooltip](overview#adding-a-tooltip-to-an-entry), often to provide extra information:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('created_at')
    ->since()
    ->dateTooltip() // Accepts a custom PHP date formatting string

TextEntry::make('created_at')
    ->since()
    ->dateTimeTooltip() // Accepts a custom PHP date formatting string

TextEntry::make('created_at')
    ->since()
    ->timeTooltip() // Accepts a custom PHP date formatting string

TextEntry::make('created_at')
    ->since()
    ->isoDateTooltip() // Accepts a custom Carbon macro format string

TextEntry::make('created_at')
    ->since()
    ->isoDateTimeTooltip() // Accepts a custom Carbon macro format string

TextEntry::make('created_at')
    ->since()
    ->isoTimeTooltip() // Accepts a custom Carbon macro format string

TextEntry::make('created_at')
    ->dateTime()
    ->sinceTooltip()
```

#### Setting the timezone for date formatting

Each of the date formatting methods listed above also accepts a `timezone` argument, which allows you to convert the time set in the state to a different timezone:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('created_at')
    ->dateTime(timezone: 'America/New_York')
```

You can also pass a timezone to the `timezone()` method of the entry to apply a timezone to all date-time formatting methods at once:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('created_at')
    ->timezone('America/New_York')
    ->dateTime()
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing static values, the `timezone()` method also accepts a function to dynamically calculate the timezone. You can inject various utilities into the function as parameters.</UtilityInjection>

If you do not pass a `timezone()` to the entry, it will use Filament's default timezone. You can set Filament's default timezone using the `FilamentTimezone::set()` method in the `boot()` method of a service provider such as `AppServiceProvider`:

```php
use Filament\Support\Facades\FilamentTimezone;

public function boot(): void
{
    FilamentTimezone::set('America/New_York');
}
```

This is useful if you want to set a default timezone for all text entries in your application. It is also used in other places where timezones are used in Filament.

<Aside variant="warning">
    Filament's default timezone will only apply when the entry stores a time. If the entry stores a date only (`date()` instead of `dateTime()`), the timezone will not be applied. This is to prevent timezone shifts when storing dates without times.
</Aside>

### Number formatting

Instead of passing a function to `formatStateUsing()`, you can use the `numeric()` method to format an entry as a number:

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

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing static values, the `decimalPlaces` argument also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

By default, your app's locale will be used to format the number suitably. If you would like to customize the locale used, you can pass it to the `locale` argument:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('stock')
    ->numeric(locale: 'nl')
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing static values, the `locale` argument also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Money formatting

Instead of passing a function to `formatStateUsing()`, you can use the `money()` method to easily format amounts of money, in any currency:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('price')
    ->money('EUR')
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing static values, the `money()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

There is also a `divideBy` argument for `money()` that allows you to divide the original value by a number before formatting it. This could be useful if your database stores the price in cents, for example:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('price')
    ->money('EUR', divideBy: 100)
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing static values, the `divideBy` argument also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

By default, your app's locale will be used to format the money suitably. If you would like to customize the locale used, you can pass it to the `locale` argument:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('price')
    ->money('EUR', locale: 'nl')
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing static values, the `locale` argument also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

If you would like to customize the number of decimal places used to format the number with, you can use the `decimalPlaces` argument:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('price')
    ->money('EUR', decimalPlaces: 3)
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing static values, the `decimalPlaces` argument also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Rendering Markdown

If your entry value is Markdown, you may render it using `markdown()`:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('description')
    ->markdown()
```

Optionally, you may pass a boolean value to control if the text should be rendered as Markdown or not:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('description')
    ->markdown(FeatureFlag::active())
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `markdown()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Rendering HTML

If your entry value is HTML, you may render it using `html()`:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('description')
    ->html()
```

Optionally, you may pass a boolean value to control if the text should be rendered as HTML or not:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('description')
    ->html(FeatureFlag::active())
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `html()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

#### Rendering raw HTML without sanitization

If you use this method, then the HTML will be sanitized to remove any potentially unsafe content before it is rendered. If you'd like to opt out of this behavior, you can wrap the HTML in an `HtmlString` object by formatting it:

```php
use Filament\Infolists\Components\TextEntry;
use Illuminate\Support\HtmlString;

TextEntry::make('description')
    ->formatStateUsing(fn (string $state): HtmlString => new HtmlString($state))
```

<Aside variant="danger">
    Be cautious when rendering raw HTML, as it may contain malicious content, which can lead to security vulnerabilities in your app such as cross-site scripting (XSS) attacks. Always ensure that the HTML you are rendering is safe before using this method.
</Aside>

Alternatively, you can return a `view()` object from the `formatStateUsing()` method, which will also not be sanitized:

```php
use Filament\Infolists\Components\TextEntry;
use Illuminate\Contracts\View\View;

TextEntry::make('description')
    ->formatStateUsing(fn (string $state): View => view(
        'filament.infolists.components.description-entry-content',
        ['state' => $state],
    ))
```

## Listing multiple values

Multiple values can be rendered in a text entry if its [state](overview#entry-content-state) is an array. This can happen if you are using an `array` cast on an Eloquent attribute, an Eloquent relationship with multiple results, or if you have passed an array to the [`state()` method](overview#setting-the-state-of-an-entry). If there are multiple values inside your text entry, they will be comma-separated. You may use the `listWithLineBreaks()` method to display them on new lines instead:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('authors.name')
    ->listWithLineBreaks()
```

<AutoScreenshot name="infolists/entries/text/list" alt="Text entry with multiple values" version="4.x" />

Optionally, you may pass a boolean value to control if the text should have line breaks between each item or not:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('authors.name')
    ->listWithLineBreaks(FeatureFlag::active())
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `listWithLineBreaks()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Adding bullet points to the list

You may add a bullet point to each list item using the `bulleted()` method:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('authors.name')
    ->bulleted()
```

<AutoScreenshot name="infolists/entries/text/bullet-list" alt="Text entry with multiple values and bullet points" version="4.x" />

Optionally, you may pass a boolean value to control if the text should have bullet points or not:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('authors.name')
    ->bulleted(FeatureFlag::active())
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `bulleted()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Limiting the number of values in the list

You can limit the number of values in the list using the `limitList()` method:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('authors.name')
    ->listWithLineBreaks()
    ->limitList(3)
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `limitList()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

#### Expanding the limited list

You can allow the limited items to be expanded and collapsed, using the `expandableLimitedList()` method:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('authors.name')
    ->listWithLineBreaks()
    ->limitList(3)
    ->expandableLimitedList()
```

<Aside variant="info">
    This is only a feature for `listWithLineBreaks()` or `bulleted()`, where each item is on its own line.
</Aside>

Optionally, you may pass a boolean value to control if the text should be expandable or not:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('authors.name')
    ->listWithLineBreaks()
    ->limitList(3)
    ->expandableLimitedList(FeatureFlag::active())
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `expandableLimitedList()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Splitting a single value into multiple list items

If you want to "explode" a text string from your model into multiple list items, you can do so with the `separator()` method. This is useful for displaying comma-separated tags [as badges](#displaying-as-a-badge), for example:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('tags')
    ->badge()
    ->separator(',')
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `separator()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Aggregating relationships

Filament provides several methods for aggregating a relationship field, including `avg()`, `max()`, `min()` and `sum()`. For instance, if you wish to show the average of a field on all related records, you may use the `avg()` method:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('users_avg_age')->avg('users', 'age')
```

In this example, `users` is the name of the relationship, while `age` is the field that is being averaged. The name of the entry must be `users_avg_age`, as this is the convention that [Laravel uses](https://laravel.com/docs/eloquent-relationships#other-aggregate-functions) for storing the result.

If you'd like to scope the relationship before aggregating, you can pass an array to the method, where the key is the relationship name and the value is the function to scope the Eloquent query with:

```php
use Filament\Infolists\Components\TextEntry;
use Illuminate\Database\Eloquent\Builder;

TextEntry::make('users_avg_age')->avg([
    'users' => fn (Builder $query) => $query->where('is_active', true),
], 'age')
```

## Customizing the text size

Text entries have small font size by default, but you may change this to `TextSize::ExtraSmall`, `TextSize::Medium`, or `TextSize::Large`.

For instance, you may make the text larger using `size(TextSize::Large)`:

```php
use Filament\Infolists\Components\TextEntry;
use Filament\Support\Enums\TextSize;

TextEntry::make('title')
    ->size(TextSize::Large)
```

<AutoScreenshot name="infolists/entries/text/large" alt="Text entry in a large font size" version="4.x" />

## Customizing the font weight

Text entries have regular font weight by default, but you may change this to any of the following options: `FontWeight::Thin`, `FontWeight::ExtraLight`, `FontWeight::Light`, `FontWeight::Medium`, `FontWeight::SemiBold`, `FontWeight::Bold`, `FontWeight::ExtraBold` or `FontWeight::Black`.

For instance, you may make the font bold using `weight(FontWeight::Bold)`:

```php
use Filament\Infolists\Components\TextEntry;
use Filament\Support\Enums\FontWeight;

TextEntry::make('title')
    ->weight(FontWeight::Bold)
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `weight()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="infolists/entries/text/bold" alt="Text entry in a bold font" version="4.x" />

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

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `fontFamily()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="infolists/entries/text/mono" alt="Text entry in a monospaced font" version="4.x" />

## Handling long text

### Limiting text length

You may `limit()` the length of the entry's value:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('description')
    ->limit(50)
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `limit()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

By default, when text is truncated, an ellipsis (`...`) is appended to the end of the text. You may customize this by passing a custom string to the `end` argument:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('description')
    ->limit(50, end: ' (more)')
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `end` argument also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

You may also reuse the value that is being passed to `limit()` in a function, by getting it using the `getCharacterLimit()` method:

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

### Limiting word count

You may limit the number of `words()` displayed in the entry:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('description')
    ->words(10)
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `words()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

By default, when text is truncated, an ellipsis (`...`) is appended to the end of the text. You may customize this by passing a custom string to the `end` argument:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('description')
    ->words(10, end: ' (more)')
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `end` argument also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Limiting text to a specific number of lines

You may want to limit text to a specific number of lines instead of limiting it to a fixed length. Clamping text to a number of lines is useful in responsive interfaces where you want to ensure a consistent experience across all screen sizes. This can be achieved using the `lineClamp()` method:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('description')
    ->lineClamp(2)
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `lineClamp()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Preventing text wrapping

By default, text will wrap to the next line if it exceeds the width of the container. You can prevent this behavior using the `wrap(false)` method:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('description')
    ->wrap(false)
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `wrap()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Allowing the text to be copied to the clipboard

You may make the text copyable, such that clicking on the entry copies the text to the clipboard, and optionally specify a custom confirmation message and duration in milliseconds:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('apiKey')
    ->label('API key')
    ->copyable()
    ->copyMessage('Copied!')
    ->copyMessageDuration(1500)
```

<AutoScreenshot name="infolists/entries/text/copyable" alt="Text entry with a button to copy it" version="4.x" />

Optionally, you may pass a boolean value to control if the text should be copyable or not:

```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('apiKey')
    ->label('API key')
    ->copyable(FeatureFlag::active())
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing static values, the `copyable()`, `copyMessage()`, and `copyMessageDuration()` methods also accept functions to dynamically calculate them. You can inject various utilities into the function as parameters.</UtilityInjection>

<Aside variant="warning">
    This feature only works when SSL is enabled for the app.
</Aside>

# Documentation for infolists. File: 03-icon-entry.md
---
title: Icon entry
---
import AutoScreenshot from "@components/AutoScreenshot.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

Icon entries render an [icon](../styling/icons) representing the state of the entry:

```php
use Filament\Infolists\Components\IconEntry;
use Filament\Support\Icons\Heroicon;

IconEntry::make('status')
    ->icon(fn (string $state): Heroicon => match ($state) {
        'draft' => Heroicon::OutlinedPencil,
        'reviewing' => Heroicon::OutlinedClock,
        'published' => Heroicon::OutlinedCheckCircle,
    })
```

<UtilityInjection set="infolistEntries" version="4.x">The `icon()` method can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="infolists/entries/icon/simple" alt="Icon entry" version="4.x" />

## Customizing the color

You may change the [color](../styling/colors) of the icon, using the `color()` method:

```php
use Filament\Infolists\Components\IconEntry;

IconEntry::make('status')
    ->color('success')
```

By passing a function to `color()`, you can customize the color based on the state of the entry:

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

<UtilityInjection set="infolistEntries" version="4.x">The `color()` method can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="infolists/entries/icon/color" alt="Icon entry with color" version="4.x" />

## Customizing the size

The default icon size is `IconSize::Large`, but you may customize the size to be either `IconSize::ExtraSmall`, `IconSize::Small`, `IconSize::Medium`, `IconSize::ExtraLarge` or `IconSize::TwoExtraLarge`:

```php
use Filament\Infolists\Components\IconEntry;
use Filament\Support\Enums\IconSize;

IconEntry::make('status')
    ->size(IconSize::Medium)
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `size()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="infolists/entries/icon/medium" alt="Medium-sized icon entry" version="4.x" />

## Handling booleans

Icon entries can display a check or "X" icon based on the state of the entry, either true or false, using the `boolean()` method:

```php
use Filament\Infolists\Components\IconEntry;

IconEntry::make('is_featured')
    ->boolean()
```

> If this attribute in the model class is already cast as a `bool` or `boolean`, Filament is able to detect this, and you do not need to use `boolean()` manually.

<AutoScreenshot name="infolists/entries/icon/boolean" alt="Icon entry to display a boolean" version="4.x" />

Optionally, you may pass a boolean value to control if the icon should be boolean or not:

```php
use Filament\Infolists\Components\IconEntry;

IconEntry::make('is_featured')
    ->boolean(FeatureFlag::active())
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `boolean()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Customizing the boolean icons

You may customize the [icon](../styling/icons) representing each state:

```php
use Filament\Infolists\Components\IconEntry;
use Filament\Support\Icons\Heroicon;

IconEntry::make('is_featured')
    ->boolean()
    ->trueIcon(Heroicon::OutlinedCheckBadge)
    ->falseIcon(Heroicon::OutlinedXMark)
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing static values, the `trueIcon()` and `falseIcon()` methods also accept functions to dynamically calculate them. You can inject various utilities into the functions as parameters.</UtilityInjection>

<AutoScreenshot name="infolists/entries/icon/boolean-icon" alt="Icon entry to display a boolean with custom icons" version="4.x" />

### Customizing the boolean colors

You may customize the icon [color](../styling/colors) representing each state:

```php
use Filament\Infolists\Components\IconEntry;

IconEntry::make('is_featured')
    ->boolean()
    ->trueColor('info')
    ->falseColor('warning')
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing static values, the `trueColor()` and `falseColor()` methods also accept functions to dynamically calculate them. You can inject various utilities into the functions as parameters.</UtilityInjection>

<AutoScreenshot name="infolists/entries/icon/boolean-color" alt="Icon entry to display a boolean with custom colors" version="4.x" />

# Documentation for infolists. File: 04-image-entry.md
---
title: Image entry
---
import AutoScreenshot from "@components/AutoScreenshot.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

Infolists can render images, based on the path in the state of the entry:

```php
use Filament\Infolists\Components\ImageEntry;

ImageEntry::make('header_image')
```

In this case, the `header_image` state could contain `posts/header-images/4281246003439.jpg`, which is relative to the root directory of the storage disk. The storage disk is defined in the [configuration file](../introduction/installation#publishing-configuration), `local` by default. You can also set the `FILESYSTEM_DISK` environment variable to change this.

Alternatively, the state could contain an absolute URL to an image, such as `https://example.com/images/header.jpg`.

<AutoScreenshot name="infolists/entries/image/simple" alt="Image entry" version="4.x" />

## Managing the image disk

The default storage disk is defined in the [configuration file](../introduction/installation#publishing-configuration), `local` by default. You can also set the `FILESYSTEM_DISK` environment variable to change this. If you want to deviate from the default disk, you may pass a custom disk name to the `disk()` method:

```php
use Filament\Infolists\Components\ImageEntry;

ImageEntry::make('header_image')
    ->disk('s3')
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `disk()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Public images

By default, Filament will generate temporary URLs to images in the filesystem, unless the [disk](#managing-the-image-disk) is set to `public`. If your images are stored in a public disk, you can set the `visibility()` to `public`:

```php
use Filament\Infolists\Components\ImageEntry;

ImageEntry::make('header_image')
    ->visibility('public')
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `visibility()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Customizing the size

You may customize the image size by passing a `imageWidth()` and `imageHeight()`, or both with `imageSize()`:

```php
use Filament\Infolists\Components\ImageEntry;

ImageEntry::make('header_image')
    ->imageWidth(200)

ImageEntry::make('header_image')
    ->imageHeight(50)

ImageEntry::make('author.avatar')
    ->imageSize(40)
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static values, the `imageWidth()`, `imageHeight()` and `imageSize()` methods also accept functions to dynamically calculate them. You can inject various utilities into the function as parameters.</UtilityInjection>

### Square images

You may display the image using a 1:1 aspect ratio:

```php
use Filament\Infolists\Components\ImageEntry;

ImageEntry::make('author.avatar')
    ->imageHeight(40)
    ->square()
```

<AutoScreenshot name="infolists/entries/image/square" alt="Square image entry" version="4.x" />

Optionally, you may pass a boolean value to control if the image should be square or not:

```php
use Filament\Infolists\Components\ImageEntry;

ImageEntry::make('author.avatar')
    ->imageHeight(40)
    ->square(FeatureFlag::active())
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `square()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Circular images

You may make the image fully rounded, which is useful for rendering avatars:

```php
use Filament\Infolists\Components\ImageEntry;

ImageEntry::make('author.avatar')
    ->imageHeight(40)
    ->circular()
```

<AutoScreenshot name="infolists/entries/image/circular" alt="Circular image entry" version="4.x" />

Optionally, you may pass a boolean value to control if the image should be circular or not:

```php
use Filament\Infolists\Components\ImageEntry;

ImageEntry::make('author.avatar')
    ->imageHeight(40)
    ->circular(FeatureFlag::active())
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `circular()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Adding a default image URL

You can display a placeholder image if one doesn't exist yet, by passing a URL to the `defaultImageUrl()` method:

```php
use Filament\Infolists\Components\ImageEntry;

ImageEntry::make('header_image')
    ->defaultImageUrl(url('storage/posts/header-images/default.jpg'))
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `defaultImageUrl()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Stacking images

You may display multiple images as a stack of overlapping images by using `stacked()`:

```php
use Filament\Infolists\Components\ImageEntry;

ImageEntry::make('colleagues.avatar')
    ->imageHeight(40)
    ->circular()
    ->stacked()
```

<AutoScreenshot name="infolists/entries/image/stacked" alt="Stacked image entry" version="4.x" />

Optionally, you may pass a boolean value to control if the images should be stacked or not:

```php
use Filament\Infolists\Components\ImageEntry;

ImageEntry::make('colleagues.avatar')
    ->imageHeight(40)
    ->circular()
    ->stacked(FeatureFlag::active())
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `stacked()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Customizing the stacked ring width

The default ring width is `3`, but you may customize it to be from `0` to `8`:

```php
use Filament\Infolists\Components\ImageEntry;

ImageEntry::make('colleagues.avatar')
    ->imageHeight(40)
    ->circular()
    ->stacked()
    ->ring(5)
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `ring()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Customizing the stacked overlap

The default overlap is `4`, but you may customize it to be from `0` to `8`:

```php
use Filament\Infolists\Components\ImageEntry;

ImageEntry::make('colleagues.avatar')
    ->imageHeight(40)
    ->circular()
    ->stacked()
    ->overlap(2)
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `overlap()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Setting a limit

You may limit the maximum number of images you want to display by passing `limit()`:

```php
use Filament\Infolists\Components\ImageEntry;

ImageEntry::make('colleagues.avatar')
    ->imageHeight(40)
    ->circular()
    ->stacked()
    ->limit(3)
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `limit()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="infolists/entries/image/limited" alt="Limited image entry" version="4.x" />

### Showing the remaining images count

When you set a limit you may also display the count of remaining images by passing `limitedRemainingText()`.

```php
use Filament\Infolists\Components\ImageEntry;

ImageEntry::make('colleagues.avatar')
    ->imageHeight(40)
    ->circular()
    ->stacked()
    ->limit(3)
    ->limitedRemainingText()
```

<AutoScreenshot name="infolists/entries/image/limited-remaining-text" alt="Limited image entry with remaining text" version="4.x" />

Optionally, you may pass a boolean value to control if the remaining text should be displayed or not:

```php
use Filament\Infolists\Components\ImageEntry;

ImageEntry::make('colleagues.avatar')
    ->imageHeight(40)
    ->circular()
    ->stacked()
    ->limit(3)
    ->limitedRemainingText(FeatureFlag::active())
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `limitedRemainingText()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

#### Customizing the limited remaining text size

By default, the size of the remaining text is `TextSize::Small`. You can customize this to be `TextSize::ExtraSmall`, `TextSize::Medium` or `TextSize::Large` using the `size` parameter:

```php
use Filament\Infolists\Components\ImageEntry;
use Filament\Support\Enums\TextSize;

ImageEntry::make('colleagues.avatar')
    ->imageHeight(40)
    ->circular()
    ->stacked()
    ->limit(3)
    ->limitedRemainingText(size: TextSize::Large)
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `limitedRemainingText()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Prevent file existence checks

When the schema is loaded, it will automatically detect whether the images exist to prevent errors for missing files. This is all done on the backend. When using remote storage with many images, this can be time-consuming. You can use the `checkFileExistence(false)` method to disable this feature:

```php
use Filament\Infolists\Components\ImageEntry;

ImageEntry::make('attachment')
    ->checkFileExistence(false)
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `checkFileExistence()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Adding extra HTML attributes to the image

You can pass extra HTML attributes to the `<img>` element via the `extraImgAttributes()` method. The attributes should be represented by an array, where the key is the attribute name and the value is the attribute value:

```php
use Filament\Infolists\Components\ImageEntry;

ImageEntry::make('logo')
    ->extraImgAttributes([
        'alt' => 'Logo',
        'loading' => 'lazy',
    ])
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `extraImgAttributes()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

By default, calling `extraImgAttributes()` multiple times will overwrite the previous attributes. If you wish to merge the attributes instead, you can pass `merge: true` to the method.

# Documentation for infolists. File: 05-color-entry.md
---
title: Color entry
---
import AutoScreenshot from "@components/AutoScreenshot.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

The color entry allows you to show the color preview from a CSS color definition, typically entered using the [color picker field](../forms/color-picker), in one of the supported formats (HEX, HSL, RGB, RGBA).

```php
use Filament\Infolists\Components\ColorEntry;

ColorEntry::make('color')
```

<AutoScreenshot name="infolists/entries/color/simple" alt="Color entry" version="4.x" />

## Allowing the color to be copied to the clipboard

You may make the color copyable, such that clicking on the preview copies the CSS value to the clipboard, and optionally specify a custom confirmation message and duration in milliseconds. This feature only works when SSL is enabled for the app.

```php
use Filament\Infolists\Components\ColorEntry;

ColorEntry::make('color')
    ->copyable()
    ->copyMessage('Copied!')
    ->copyMessageDuration(1500)
```

<AutoScreenshot name="infolists/entries/color/copyable" alt="Color entry with a button to copy it" version="4.x" />

Optionally, you may pass a boolean value to control if the color should be copyable or not:

```php
use Filament\Infolists\Components\ColorEntry;

ColorEntry::make('color')
    ->copyable(FeatureFlag::active())
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing static values, the `copyable()`, `copyMessage()`, and `copyMessageDuration()` methods also accept functions to dynamically calculate them. You can inject various utilities into the function as parameters.</UtilityInjection>

# Documentation for infolists. File: 06-code-entry.md
---
title: Code entry
---
import Aside from "@components/Aside.astro"
import AutoScreenshot from "@components/AutoScreenshot.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

The code entry allows you to present a highlighted code snippet in your infolist. It uses [Phiki](https://github.com/phikiphp/phiki) for code highlighting on the server:

```php
use Filament\Infolists\Components\CodeEntry;
use Phiki\Grammar\Grammar;

CodeEntry::make('code')
    ->grammar(Grammar::Php)
```

<AutoScreenshot name="infolists/entries/code/simple" alt="Code entry" version="4.x" />

To use the code entry, you need to first install the [`phiki/phiki`](https://github.com/phikiphp/phiki) Composer package. Filament does not include it by default to allow you to choose which major version of Phiki to use explicitly, since major versions can have different grammars and themes available. You can install the latest version of Phiki using the following command:

```bash
composer require phiki/phiki
```

## Changing the code's grammar (language)

You may change the grammar (language) of the code using the `grammar()` method. Over 200 grammars are available, and you can open the `Phiki\Grammar\Grammar` enum class to see the full list. To switch to use JavaScript as the grammar, you can use the `Grammar::Javascript` enum value:

```php
use Filament\Infolists\Components\CodeEntry;
use Phiki\Grammar\Grammar;

CodeEntry::make('code')
    ->grammar(Grammar::Javascript)
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `grammar()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<Aside variant="tip">
    If your code entry's content is a PHP array, it will automatically be converted to a JSON string, and the grammar will be set to `Grammar::Json`.
</Aside>

## Changing the code's theme (highlighting)

You may change the theme of the code using the `lightTheme()` and `darkTheme()` methods. Over 50 themes are available, and you can open the `Phiki\Theme\Theme` enum class to see the full list. To use the popular `Dracula` theme, you can use the `Theme::Dracula` enum value:

```php
use Filament\Infolists\Components\CodeEntry;
use Phiki\Theme\Theme;

CodeEntry::make('code')
    ->lightTheme(Theme::Dracula)
    ->darkTheme(Theme::Dracula)
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing static values, the `lightTheme()` and `darkTheme()` methods also accept functions to dynamically calculate them. You can inject various utilities into the functions as parameters.</UtilityInjection>

<AutoScreenshot name="infolists/entries/code/dracula" alt="Code entry with the Dracula theme" version="4.x" />

## Allowing the code to be copied to the clipboard

You may make the code copyable, such that clicking on it copies the code to the clipboard, and optionally specify a custom confirmation message and duration in milliseconds. This feature only works when SSL is enabled for the app.

```php
use Filament\Infolists\Components\CodeEntry;

CodeEntry::make('code')
    ->copyable()
    ->copyMessage('Copied!')
    ->copyMessageDuration(1500)
```

Optionally, you may pass a boolean value to control if the code should be copyable or not:

```php
use Filament\Infolists\Components\CodeEntry;

CodeEntry::make('code')
    ->copyable(FeatureFlag::active())
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing static values, the `copyable()`, `copyMessage()`, and `copyMessageDuration()` methods also accept functions to dynamically calculate them. You can inject various utilities into the function as parameters.</UtilityInjection>

# Documentation for infolists. File: 07-key-value-entry.md
---
title: Key-value entry
---
import AutoScreenshot from "@components/AutoScreenshot.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

The key-value entry allows you to render key-value pairs of data, from a one-dimensional JSON object / PHP array.

```php
use Filament\Infolists\Components\KeyValueEntry;

KeyValueEntry::make('meta')
```

For example, the state of this entry might be represented as:

```php
[
    'description' => 'Filament is a collection of Laravel packages',
    'og:type' => 'website',
    'og:site_name' => 'Filament',
]
```

<AutoScreenshot name="infolists/entries/key-value/simple" alt="Key-value entry" version="4.x" />

If you're saving the data in Eloquent, you should be sure to add an `array` [cast](https://laravel.com/docs/eloquent-mutators#array-and-json-casting) to the model property:

```php
use Illuminate\Database\Eloquent\Model;

class Post extends Model
{
    /**
     * @return array<string, string>
     */
    protected function casts(): array
    { 
        return [
            'meta' => 'array',
        ];
    }

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

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `keyLabel()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Customizing the value column's label

You may customize the label for the value column using the `valueLabel()` method:

```php
use Filament\Infolists\Components\KeyValueEntry;

KeyValueEntry::make('meta')
    ->valueLabel('Property value')
```

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `valueLabel()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

# Documentation for infolists. File: 08-repeatable-entry.md
---
title: Repeatable entry
---
import AutoScreenshot from "@components/AutoScreenshot.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

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

For example, the state of this entry might be represented as:

```php
[
    [
        'author' => ['name' => 'Jane Doe'],
        'title' => 'Wow!',
        'content' => 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam euismod, nisl eget aliquam ultricies, nunc nisl aliquet nunc, quis aliquam nisl.',
    ],
    [
        'author' => ['name' => 'John Doe'],
        'title' => 'This isn\'t working. Help!',
        'content' => 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam euismod, nisl eget aliquam ultricies, nunc nisl aliquet nunc, quis aliquam nisl.',
    ],
]
```

<AutoScreenshot name="infolists/entries/repeatable/simple" alt="Repeatable entry" version="4.x" />

Alternatively, `comments` and `author` could be Eloquent relationships, `title` and `content` could be attributes on the comment model, and `name` could be an attribute on the author model. Filament will automatically handle the relationship loading and display the data in the same way.

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

This method accepts the same options as the `columns()` method of the [grid](../schemas/layouts#grid-system). This allows you to responsively customize the number of grid columns at various breakpoints.

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `grid()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="infolists/entries/repeatable/grid" alt="Repeatable entry in grid layout" version="4.x" />

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

<UtilityInjection set="infolistEntries" version="4.x">As well as allowing a static value, the `contained()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

# Documentation for infolists. File: 09-custom-entries.md
---
title: Custom entries
---
import Aside from "@components/Aside.astro"

## Introduction

You may create your own custom entry classes and views, which you can reuse across your project, and even release as a plugin to the community.

To create a custom entry class and view, you may use the following command:

```bash
php artisan make:filament-infolist-entry AudioPlayerEntry
```

This will create the following component class:

```php
use Filament\Infolists\Components\Entry;

class AudioPlayerEntry extends Entry
{
    protected string $view = 'filament.infolists.components.audio-player-entry';
}
```

It will also create a view file at `resources/views/filament/infolists/components/audio-player-entry.blade.php`.

<Aside variant="info">
    Filament infolist entries are **not** Livewire components. Defining public properties and methods on a infolist entry class will not make them accessible in the Blade view.
</Aside>

## Accessing the state of the entry in the Blade view

Inside the Blade view, you may access the [state](overview#entry-content-state) of the entry using the `$getState()` function:

```blade
<x-dynamic-component
    :component="$getEntryWrapperView()"
    :entry="$entry"
>
    {{ $getState() }}
</x-dynamic-component>
```

## Accessing the state of another component in the Blade view

Inside the Blade view, you may access the state of another component in the schema using the `$get()` function:

```blade
<x-dynamic-component
    :component="$getEntryWrapperView()"
    :entry="$entry"
>
    {{ $get('email') }}
</x-dynamic-component>
```

<Aside variant="tip">
    Unless a form field is [reactive](../infolists/overview#the-basics-of-reactivity), the Blade view will not refresh when the value of the field changes, only when the next user interaction occurs that makes a request to the server. If you need to react to changes in a field's value, it should be `live()`.
</Aside>

## Accessing the Eloquent record in the Blade view

Inside the Blade view, you may access the current Eloquent record using the `$record` variable:

```blade
<x-dynamic-component
    :component="$getEntryWrapperView()"
    :entry="$entry"
>
    {{ $record->name }}
</x-dynamic-component>
```

## Accessing the current operation in the Blade view

Inside the Blade view, you may access the current operation, usually `create`, `edit` or `view`, using the `$operation` variable:

```blade
<x-dynamic-component
    :component="$getEntryWrapperView()"
    :entry="$entry"
>
    @if ($operation === 'create')
        This is a new conference.
    @else
        This is an existing conference.
    @endif
</x-dynamic-component>
```

## Accessing the current Livewire component instance in the Blade view

Inside the Blade view, you may access the current Livewire component instance using `$this`:

```blade
@php
    use Filament\Resources\Users\RelationManagers\ConferencesRelationManager;
@endphp

<x-dynamic-component
    :component="$getEntryWrapperView()"
    :entry="$entry"
>
    @if ($this instanceof ConferencesRelationManager)
        You are editing conferences the of a user.
    @endif
</x-dynamic-component>
```

## Accessing the current entry instance in the Blade view

Inside the Blade view, you may access the current entry instance using `$entry`. You can call public methods on this object to access other information that may not be available in variables:

```blade
<x-dynamic-component
    :component="$getEntryWrapperView()"
    :entry="$entry"
>
    @if ($entry->isLabelHidden())
        This is a new conference.
    @endif
</x-dynamic-component>
```

## Adding a configuration method to a custom entry class

You may add a public method to the custom entry class that accepts a configuration value, stores it in a protected property, and returns it again from another public method:

```php
use Filament\Infolists\Components\Entry;

class AudioPlayerEntry extends Entry
{
    protected string $view = 'filament.infolists.components.audio-player-entry';
    
    protected ?float $speed = null;

    public function speed(?float $speed): static
    {
        $this->speed = $speed;

        return $this;
    }

    public function getSpeed(): ?float
    {
        return $this->speed;
    }
}
```

Now, in the Blade view for the custom entry, you may access the speed using the `$getSpeed()` function:

```blade
<x-dynamic-component
    :component="$getEntryWrapperView()"
    :entry="$entry"
>
    {{ $getSpeed() }}
</x-dynamic-component>
```

Any public method that you define on the custom entry class can be accessed in the Blade view as a variable function in this way.

To pass the configuration value to the custom entry class, you may use the public method:

```php
use App\Filament\Infolists\Components\AudioPlayerEntry;

AudioPlayerEntry::make('recording')
    ->speed(0.5)
```

## Allowing utility injection in a custom entry configuration method

[Utility injection](overview#entry-utility-injection) is a powerful feature of Filament that allows users to configure a component using functions that can access various utilities. You can allow utility injection by ensuring that the parameter type and property type of the configuration allows the user to pass a `Closure`. In the getter method, you should pass the configuration value to the `$this->evaluate()` method, which will inject utilities into the user's function if they pass one, or return the value if it is static:

```php
use Closure;
use Filament\Infolists\Components\Entry;

class AudioPlayerEntry extends Entry
{
    protected string $view = 'filament.infolists.components.audio-player-entry';
    
    protected float | Closure | null $speed = null;

    public function speed(float | Closure | null $speed): static
    {
        $this->speed = $speed;

        return $this;
    }

    public function getSpeed(): ?float
    {
        return $this->evaluate($this->speed);
    }
}
```

Now, you can pass a static value or a function to the `speed()` method, and [inject any utility](overview#component-utility-injection) as a parameter:

```php
use App\Filament\Infolists\Components\AudioPlayerEntry;

AudioPlayerEntry::make('recording')
    ->speed(fn (Conference $record): float => $record->isGlobal() ? 1 : 0.5)
```

