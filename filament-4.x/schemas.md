# Documentation for schemas. File: 01-overview.md
---
title: Overview
---
import Aside from "@components/Aside.astro"
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Introduction

Schemas form the foundation of Filament's Server-Driven UI approach. They allow you to build user interfaces declaratively using PHP configuration objects. These configuration objects represent components that define the structure and behavior of your UI, such as forms, tables, or lists. Rather than manually writing HTML or JavaScript, you create these schemas to control what gets rendered on the server, streamlining development and ensuring consistency across your app.

Schemas are used extensively across Filament to render UI elements dynamically. Whether you're defining a form field, the layout of your page, or an action button, the schema object defines both the component's configuration and how it interacts with your data. In essence, schemas are the building blocks of Filament UIs.

Filament packages provide you with various components. You can find a full list in the [available components section](#available-components):

- [Form fields](../forms) accept input from the user, for example, a text input, a select, or a checkbox. They come with integrated validation.
- [Infolist entries](../infolists) are components for rendering "description lists." Entries are key-value UI elements that can present read-only information like text, icons, and images. The data for an infolist can be sourced from anywhere but commonly comes from an individual Eloquent record.
- [Layout components](layouts) are used to structure the components. For example, a grid, tabs, or a multi-step form wizard.
- [Prime components](primes) are simple components that are used to render basic stand-alone static content, such as text, images, and buttons (actions).

Schemas act as a container for many components, and you can add any combination of components within them. Components can also nest child schemas within them, allowing for an infinite level of nesting.

A schema is represented by a `Filament\Schemas\Schema` object, and you can pass an array of components to it in the `components()` method.

## Available components

For building [forms](../forms), Filament includes a set of fields for different data types:

- [Text input](../forms/text-input)
- [Select](../forms/select)
- [Checkbox](../forms/checkbox)
- [Toggle](../forms/toggle)
- [Checkbox list](../forms/checkbox-list)
- [Radio](../forms/radio)
- [Date-time picker](../forms/date-time-picker)
- [File upload](../forms/file-upload)
- [Rich editor](../forms/rich-editor)
- [Markdown editor](../forms/markdown-editor)
- [Repeater](../forms/repeater)
- [Builder](../forms/builder)
- [Tags input](../forms/tags-input)
- [Textarea](../forms/textarea)
- [Key-value](../forms/key-value)
- [Color picker](../forms/color-picker)
- [Toggle buttons](../forms/toggle-buttons)
- [Slider](../forms/slider)
- [Code editor](../forms/code-editor)
- [Hidden](../forms/hidden)
- Or, build your own [custom form field](../forms/custom-fields)

For displaying data in a label-value "description list" format, Filament includes [infolist](../infolists) entry components:

- [Text entry](../infolists/text-entry)
- [Icon entry](../infolists/icon-entry)
- [Image entry](../infolists/image-entry)
- [Color entry](../infolists/color-entry)
- [Code entry](../infolists/code-entry)
- [Key-value entry](../infolists/key-value-entry)
- [Repeatable entry](../infolists/repeatable-entry)
- Or, build your own [custom infolist entry](../infolists/custom-entries)

To arrange components into a [layout](layouts), Filament includes layout components:

- [Grid](layouts#grid-component)
- [Flex](layouts#flex-component)
- [Fieldset](layouts#fieldset-component)
- [Section](sections)
- [Tabs](tabs)
- [Wizard](wizards)
- Or, build your own [custom layout component](custom-components#custom-layout-components)

For displaying arbitrary content, Filament includes [prime](primes) components:

- [Text](primes#text-component)
- [Icon](primes#icon-component)
- [Image](primes#image-component)
- [Unordered list](primes#unordered-list-component)

You can also insert "action" buttons into schemas. These can run PHP functions, and even open modals. For more information, see the [actions documentation](../actions).

You can learn more about building custom components to render your own Blade views in the [custom components documentation](custom-components).

## An example schema

For example, you may want to build a form with a schema. The name of the schema is usually dictated by the name of the method that it is defined in (`form` in this example). Filament creates the `Schema` object and passes it to the method, which then returns the schema with the components added:

```php
use Filament\Forms\Components\Checkbox;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Components\Section;

$schema
    ->components([
        Grid::make(2)
            ->schema([
                Section::make('Details')
                    ->schema([
                        TextInput::make('name'),
                        Select::make('position')
                            ->options([
                                'developer' => 'Developer',
                                'designer' => 'Designer',
                            ]),
                        Checkbox::make('is_admin'),
                    ]),
                Section::make('Auditing')
                    ->schema([
                        TextEntry::make('created_at')
                            ->dateTime(),
                        TextEntry::make('updated_at')
                            ->dateTime(),
                    ]),
            ]),
    ])
```

<AutoScreenshot name="schemas/overview/example" alt="Example schema" version="4.x" />

[Grid](layouts#grid-component) is a layout component that renders multiple components together in a responsive grid. The number of columns in the grid is specified in the `make()` method. The `schema()` method is used to nest components within the grid.

[Section](sections) is another layout component that renders multiple components together in a card, with a heading at the top.

[TextInput](../forms/text-input), [Select](../forms/select), and [Checkbox](../forms/checkbox) are form components that accept input from the user.

[TextEntry](../infolists/text-entry) is an infolist component that displays read-only information. In this example, it is used to display the created and updated timestamps of the record. The `dateTime()` method is used to format the timestamps as dates and times.

The schema object is the container for the components and can now be rendered. Rendering the schema will render all the components within it in the correct layout.

## Component utility injection

The vast majority of methods used to configure entries accept functions as parameters instead of hardcoded values:

```php
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Section;

Grid::make(fn (): array => [
    'lg' => auth()->user()->isAdmin() ? 4 : 6,
])->schema([
    // ...
])

Section::make()
    ->heading(fn (): string => auth()->user()->isAdmin() ? 'Admin Dashboard' : 'User Dashboard')
    ->schema([
        // ...
    ])
```

This alone unlocks many customization possibilities.

The package is also able to inject many utilities to use inside these functions, as parameters. All customization methods that accept functions as arguments can inject utilities.

These injected utilities require specific parameter names to be used. Otherwise, Filament doesn't know what to inject.

### Injecting the state of another component

You may also retrieve the state (value) of a form field or infolist entry from within a callback, using a `$get` parameter:

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

### Injecting the current component instance

If you wish to access the current component instance, define a `$component` parameter:

```php
use Filament\Schemas\Components\Component;

function (Component $component) {
    // ...
}
```

### Injecting multiple utilities

The parameters are injected dynamically using reflection, so you are able to combine multiple parameters in any order:

```php
use Filament\Schemas\Components\Utilities\Get;
use Filament\Schemas\Components\Utilities\Set;
use Livewire\Component as Livewire;

function (Livewire $livewire, Get $get, Set $set) {
    // ...
}
```

### Injecting dependencies from Laravel's container

You may inject anything from Laravel's container like normal, alongside utilities:

```php
use Filament\Schemas\Components\Utilities\Set;
use Illuminate\Http\Request;

function (Request $request, Set $set) {
    // ...
}
```

## Global settings

If you wish to change the default behavior of a component globally, then you can call the static `configureUsing()` method inside a service provider's `boot()` method, to which you pass a Closure to modify the component using. For example, if you wish to make all section components have [2 columns](sections#using-grid-columns-within-a-section) by default, you can do it like so:

```php
use Filament\Schemas\Components\Section;

Section::configureUsing(function (Section $section): void {
    $section
        ->columns(2);
});
```

Of course, you are still able to overwrite this on each component individually:

```php
use Filament\Schemas\Components\Section;

Section::make()
    ->columns(1)
```

# Documentation for schemas. File: 02-layouts.md
---
title: Layouts
---
import Aside from "@components/Aside.astro"
import AutoScreenshot from "@components/AutoScreenshot.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

Filament's grid system allows you to create responsive, multi-column layouts using any layout component. Filament provides a set of built-in layout components to help you build these:

- [Grid](#grid-component)
- [Flex](#flex-component)
- [Fieldset](#fieldset-component)
- [Section](sections)
- [Tabs](tabs)
- [Wizard](wizards)

You may also [create your own custom layout components](custom-components#custom-layout-components) to display components however you wish.

## Grid system

All layout components have a `columns()` method that you can use in a couple of different ways:

- You can pass an integer like `columns(2)`. This integer is the number of columns used on the `lg` breakpoint and higher. All smaller devices will have just 1 column.
- You can pass an array, where the key is the breakpoint and the value is the number of columns. For example, `columns(['md' => 2, 'xl' => 4])` will create a 2 column layout on medium devices, and a 4 column layout on extra large devices. The default breakpoint for smaller devices uses 1 column, unless you use a `default` array key.

Breakpoints (`sm`, `md`, `lg`, `xl`, `2xl`) are defined by Tailwind, and can be found in the [Tailwind documentation](https://tailwindcss.com/docs/responsive-design#overview).

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static value, the `columns()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Grid column spans

In addition to specifying how many columns a layout component should have, you may also specify how many columns a component should fill within the parent grid, using the `columnSpan()` method. This method accepts an integer or an array of breakpoints and column spans:

- You can pass an integer like `columnSpan(2)`. This integer is the number of columns that are consumed on the `lg` breakpoint and higher. All smaller devices span just 1 column.
- `columnSpan(['md' => 2, 'xl' => 4])` will make the component fill up to 2 columns on medium devices, and up to 4 columns on extra large devices. The default breakpoint for smaller devices uses 1 column, unless you use a `default` array key.
- `columnSpan('full')` will make the component fill the full width of the parent grid on the `lg` breakpoint and higher, regardless of how many columns there are. All smaller devices span just 1 column.
- `columnSpanFull()` will make the component fill the full width of the parent grid on all devices, regardless of how many columns it has.

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static value, the `columnSpan()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Grid column starts

If you want to start a component in a grid at a specific column, you can use the `columnStart()` method. This method accepts an integer, or an array of breakpoints and which column the component should start at:

- You can pass an integer like `columnStart(2)`. This integer is column that the component will start on for the `lg` breakpoint and higher. All smaller devices start the component on the first column.
- `columnStart(['md' => 2, 'xl' => 4])` will make the component start at column 2 on medium devices, and at column 4 on extra large devices. The default breakpoint for smaller devices uses 1 column, unless you use a `default` array key.

```php
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Grid;

Grid::make()
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

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static value, the `columnStart()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Grid column ordering

If you want to control the visual order of components in a grid without changing their position in the markup, you can use the `columnOrder()` method. This method accepts an integer, a closure, or an array of breakpoints and order values:

- You can pass an integer like `columnOrder(2)`. This integer is the order that the component will appear in for the `lg` breakpoint and higher. All smaller devices use the default order, unless you use a `default` array key.
- `columnOrder(['md' => 2, 'xl' => 4])` will set the component's order to 2 on medium devices, and to 4 on extra large devices. The default breakpoint for smaller devices uses the default order, unless you use a `default` array key.
- `columnOrder(fn () => 1)` will dynamically calculate the order using a closure.

```php
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Grid;

Grid::make()
    ->columns(3)
    ->schema([
        TextInput::make('first')
            ->columnOrder(3), // This will appear last
        TextInput::make('second')
            ->columnOrder(1), // This will appear first
        TextInput::make('third')
            ->columnOrder(2), // This will appear second
    ])
```

You can also use responsive ordering to change the visual order of components based on the screen size:

```php
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Grid;

Grid::make()
    ->columns([
        'sm' => 2,
        'lg' => 3,
    ])
    ->schema([
        TextInput::make('title')
            ->columnOrder([
                'default' => 1,
                'lg' => 3,
            ]),
        TextInput::make('description')
            ->columnOrder([
                'default' => 2,
                'lg' => 1,
            ]),
        TextInput::make('category')
            ->columnOrder([
                'default' => 3,
                'lg' => 2,
            ]),
    ])
```

In this example, on small screens the order will be: title, description, category. On large screens, the order will be: description, category, title.

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static value, the `columnOrder()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### An example of a responsive grid layout

In this example, we have a schema with a [section](sections) layout component. Since all layout components support the `columns()` method, we can use it to create a responsive grid layout within the section itself.

We pass an array to `columns()` as we want to specify different numbers of columns for different breakpoints. On devices smaller than the `sm` [Tailwind breakpoint](https://tailwindcss.com/docs/responsive-design#overview), we want to have 1 column, which is default. On devices larger than the `sm` breakpoint, we want to have 3 columns. On devices larger than the `xl` breakpoint, we want to have 6 columns. On devices larger than the `2xl` breakpoint, we want to have 8 columns.

Inside the section, we have a [text input](../forms/text-input). Since text inputs are form fields and all components have a `columnSpan()` method, we can use it to specify how many columns the text input should fill. On devices smaller than the `sm` breakpoint, we want the text input to fill 1 column, which is default. On devices larger than the `sm` breakpoint, we want the text input to fill 2 columns. On devices larger than the `xl` breakpoint, we want the text input to fill 3 columns. On devices larger than the `2xl` breakpoint, we want the text input to fill 4 columns.

Additionally, we're using the `columnOrder()` method to control the visual order of components in the grid based on screen size. This allows us to change the display order without altering the markup structure.

```php
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Section;

Section::make()
    ->columns([
        'sm' => 3,
        'xl' => 6,
        '2xl' => 8,
    ])
    ->schema([
        TextInput::make('name')
            ->columnSpan([
                'default' => 1,
                'sm' => 2,
                'xl' => 3,
                '2xl' => 4,
            ])
            ->columnOrder([
                'default' => 2,
                'xl' => 1,
            ]),
        TextInput::make('email')
            ->columnSpan([
                'default' => 1,
                'xl' => 2,
            ])
            ->columnOrder([
                'default' => 1,
                'xl' => 2,
            ]),
        // ...
    ])
```

In this example, on screens smaller than the `xl` breakpoint, the email field will appear first followed by the name field. On screens larger than the `xl` breakpoint, the order is reversed with the name field appearing first followed by the email field.

## Basic layout components

### Grid component

All layout components support the `columns()` method, but you also have access to an additional `Grid` component. If you feel that your schema would benefit from an explicit grid syntax with no extra styling, it may be useful to you. Instead of using the `columns()` method, you can pass your column configuration directly to `Grid::make()`:

```php
use Filament\Schemas\Components\Grid;

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

### Flex component

The `Flex` component allows you to define layouts with flexible widths, using flexbox. This component does not use Filament's [grid system](#grid-system).

```php
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Components\Flex;

Flex::make([
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

In this example, the first section will `grow()` to consume available horizontal space, without affecting the amount of space needed to render the second section. This creates a flexible width sidebar effect.

The `from()` method is used to control the [Tailwind breakpoint](https://tailwindcss.com/docs/responsive-design#overview) (`sm`, `md`, `lg`, `xl`, `2xl`) at which the horizontally-split layout should be used. In this example, the horizontally-split layout will be used on medium devices and larger. On smaller devices, the sections will stack on top of each other.

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing static values, the `grow()` and `from()` methods also accept functions to dynamically calculate them. You can inject various utilities into the functions as parameters.</UtilityInjection>

<AutoScreenshot name="schemas/layout/flex/simple" alt="Flex" version="4.x" />

### Fieldset component

You may want to group fields into a Fieldset. Each fieldset has a label, a border, and a two-column grid by default:

```php
use Filament\Schemas\Components\Fieldset;

Fieldset::make('Label')
    ->columns([
        'default' => 1,
        'md' => 2,
        'xl' => 3,
    ])
    ->schema([
        // ...
    ])
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static label, the `make()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="schemas/layout/fieldset/simple" alt="Fieldset" version="4.x" />

### Removing the border from a fieldset

You can remove the container border from a fieldset using the `contained(false)` method:

```php
use Filament\Schemas\Components\Fieldset;

Fieldset::make('Label')
    ->contained(false)
    ->schema([
        // ...
    ])
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static value, the `contained()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="schemas/layout/fieldset/not-contained" alt="Fieldset without a container border" version="4.x" />

## Using container queries

In addition to traditional breakpoints based on the size of the viewport, you can also use [container queries](https://tailwindcss.com/docs/responsive-design#container-queries) to create responsive layouts based on the size of a parent container. This is particularly useful when the size of the parent container is not directly tied to the size of the viewport. For example, when using a collapsible sidebar alongside the content, the content area dynamically adjusts its size depending on the collapse state of the sidebar.

The foundation of a container query is the container itself. The container is the element whose width determines the layout. To designate an element as a container, use the `gridContainer()` method on it. For instance, if you want to define the number of grid columns in a [`Grid` component] based on its width:

```php
use Filament\Schemas\Components\Grid;

Grid::make()
    ->gridContainer()
    ->columns([
        // ...
    ])
    ->schema([
        // ...
    ])
```

Once an element is specified as a grid container, the element or any of its children can utilize [container breakpoints](https://tailwindcss.com/docs/responsive-design#container-size-reference) instead of standard breakpoints. For example, you could use `@md` to define the number of grid columns when the container's width is at least `448px`, and `@xl` for when the width is at least `576px`.

```php
use Filament\Schemas\Components\Grid;

Grid::make()
    ->gridContainer()
    ->columns([
        '@md' => 3,
        '@xl' => 4,
    ])
    ->schema([
        // ...
    ])
```

You can also use container breakpoints in the `columnSpan()`, `columnStart()`, and `columnOrder()` methods:

```php
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Grid;

Grid::make()
    ->gridContainer()
    ->columns([
        '@md' => 3,
        '@xl' => 4,
    ])
    ->schema([
        TextInput::make('name')
            ->columnSpan([
                '@md' => 2,
                '@xl' => 3,
            ])
            ->columnOrder([
                'default' => 2,
                '@xl' => 1,
            ]),
        TextInput::make('email')
            ->columnSpan([
                'default' => 1,
                '@xl' => 1,
            ])
            ->columnOrder([
                'default' => 1,
                '@xl' => 2,
            ]),
        // ...
    ])
```

In this example, when the container width is smaller than the `@xl` breakpoint (576px), the email field will appear first followed by the name field. When the container width is at least 576px, the order is reversed with the name field appearing first followed by the email field.

### Supporting container queries on older browsers

Container queries are not yet widely [supported in browsers](https://caniuse.com/css-container-queries) compared to traditional breakpoints. To support older browsers, you can define an additional layer of breakpoints alongside the container breakpoints. By prefixing the traditional breakpoint with `!@`, you can specify that the fallback breakpoint should be used when container queries are not supported in the browser. 

For example, if you want to use the `@md` container breakpoint for the grid columns but also support older browsers, you can define the `!@md` fallback breakpoint, which will be applied when container queries are unavailable:

```php
use Filament\Schemas\Components\Grid;

Grid::make()
    ->gridContainer()
    ->columns([
        '@md' => 3,
        '@xl' => 4,
        '!@md' => 2,
        '!@xl' => 3,
    ])
    ->schema([
        // ...
    ])
```

You can also use `!@` fallback breakpoints in the `columnSpan()`, `columnStart()`, and `columnOrder()` methods:

```php
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Grid;

Grid::make()
    ->gridContainer()
    ->columns([
        '@md' => 3,
        '@xl' => 4,
        '!@md' => 2,
        '!@xl' => 3,
    ])
    ->schema([
        TextInput::make('name')
            ->columnSpan([
                '@md' => 2,
                '@xl' => 3,
                '!@md' => 2,
                '!@xl' => 2,
            ])
            ->columnOrder([
                'default' => 2,
                '@xl' => 1,
                '!@xl' => 1,
            ]),
        TextInput::make('email')
            ->columnOrder([
                'default' => 1,
                '@xl' => 2,
                '!@xl' => 2,
            ]),
        // ...
    ])
```

In this example, the fallback breakpoints ensure that even in browsers that don't support container queries, the layout will still respond to viewport size changes, with the name field appearing first and the email field second on larger screens.

## Adding extra HTML attributes to a layout component

You can pass extra HTML attributes to the component via the `extraAttributes()` method, which will be merged onto its outer HTML element. The attributes should be represented by an array, where the key is the attribute name and the value is the attribute value:

```php
use Filament\Schemas\Components\Section;

Section::make()
    ->extraAttributes(['class' => 'custom-section-style'])
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static value, the `extraAttributes()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

By default, calling `extraAttributes()` multiple times will overwrite the previous attributes. If you wish to merge the attributes instead, you can pass `merge: true` to the method.

# Documentation for schemas. File: 03-sections.md
---
title: Sections
---
import AutoScreenshot from "@components/AutoScreenshot.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

You may want to separate your fields into sections, each with a heading and description. To do this, you can use a section component:

```php
use Filament\Schemas\Components\Section;

Section::make('Rate limiting')
    ->description('Prevent abuse by limiting the number of requests per period')
    ->schema([
        // ...
    ])
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing static values, the `make()` and `description()` methods also accept functions to dynamically calculate them. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="schemas/layout/section/simple" alt="Section" version="4.x" />

You can also use a section without a header, which just wraps the components in a simple card:

```php
use Filament\Schemas\Components\Section;

Section::make()
    ->schema([
        // ...
    ])
```

<AutoScreenshot name="schemas/layout/section/without-header" alt="Section without header" version="4.x" />

## Adding an icon to the section's header

You may add an [icon](../styling/icons) to the section's header using the `icon()` method:

```php
use Filament\Schemas\Components\Section;
use Filament\Support\Icons\Heroicon;

Section::make('Cart')
    ->description('The items you have selected for purchase')
    ->icon(Heroicon::ShoppingBag)
    ->schema([
        // ...
    ])
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static value, the `icon()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="schemas/layout/section/icons" alt="Section with icon" version="4.x" />

## Positioning the heading and description aside

You may use the `aside()` to align heading & description on the left, and the components inside a card on the right:

```php
use Filament\Schemas\Components\Section;

Section::make('Rate limiting')
    ->description('Prevent abuse by limiting the number of requests per period')
    ->aside()
    ->schema([
        // ...
    ])
```

<AutoScreenshot name="schemas/layout/section/aside" alt="Section with heading and description aside" version="4.x" />

Optionally, you may pass a boolean value to control if the section should be aside or not:

```php
use Filament\Schemas\Components\Section;

Section::make('Rate limiting')
    ->description('Prevent abuse by limiting the number of requests per period')
    ->aside(FeatureFlag::active())
    ->schema([
        // ...
    ])
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static value, the `aside()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Collapsing sections

Sections may be `collapsible()` to optionally hide long content:

```php
use Filament\Schemas\Components\Section;

Section::make('Cart')
    ->description('The items you have selected for purchase')
    ->schema([
        // ...
    ])
    ->collapsible()
```

Your sections may be `collapsed()` by default:

```php
use Filament\Schemas\Components\Section;

Section::make('Cart')
    ->description('The items you have selected for purchase')
    ->schema([
        // ...
    ])
    ->collapsed()
```

<AutoScreenshot name="schemas/layout/section/collapsed" alt="Collapsed section" version="4.x" />

Optionally, the `collapsible()` and `collapsed()` methods accept a boolean value to control if the section should be collapsible and collapsed or not:

```php
use Filament\Schemas\Components\Section;

Section::make('Cart')
    ->description('The items you have selected for purchase')
    ->schema([
        // ...
    ])
    ->collapsible(FeatureFlag::active())
    ->collapsed(FeatureFlag::active())
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing static values, the `collapsible()` and `collapsed()` methods also accept functions to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Persisting collapsed sections in the user's session

You can persist whether a section is collapsed in local storage using the `persistCollapsed()` method, so it will remain collapsed when the user refreshes the page:

```php
use Filament\Schemas\Components\Section;

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
use Filament\Schemas\Components\Section;

Section::make('Cart')
    ->description('The items you have selected for purchase')
    ->schema([
        // ...
    ])
    ->collapsible()
    ->persistCollapsed()
    ->id('order-cart')
```

Optionally, the `persistCollapsed()` method accepts a boolean value to control if the section should persist its collapsed state or not:

```php
use Filament\Schemas\Components\Section;

Section::make('Cart')
    ->description('The items you have selected for purchase')
    ->schema([
        // ...
    ])
    ->collapsible()
    ->persistCollapsed(FeatureFlag::active())
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing static values, the `persistCollapsed()` and `id()` methods also accept functions to dynamically calculate them. You can inject various utilities into the function as parameters.</UtilityInjection>

## Compact section styling

When nesting sections, you can use a more compact styling:

```php
use Filament\Schemas\Components\Section;

Section::make('Rate limiting')
    ->description('Prevent abuse by limiting the number of requests per period')
    ->schema([
        // ...
    ])
    ->compact()
```

<AutoScreenshot name="schemas/layout/section/compact" alt="Compact section" version="4.x" />

Optionally, the `compact()` method accepts a boolean value to control if the section should be compact or not:

```php
use Filament\Schemas\Components\Section;

Section::make('Rate limiting')
    ->description('Prevent abuse by limiting the number of requests per period')
    ->schema([
        // ...
    ])
    ->compact(FeatureFlag::active())
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static value, the `compact()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Secondary section styling

By default, sections have a contrasting background color, which makes them stand out against a gray background. Secondary styling gives the section a less contrasting background, so it is usually slightly darker. This is a better styling when the background color behind the section is the same color as the default section background color, for example when a section is nested inside another section. Secondary sections can be created using the `secondary()` method:

```php
use Filament\Schemas\Components\Section;

Section::make('Notes')
    ->schema([
        // ...
    ])
    ->secondary()
    ->compact()
```

<AutoScreenshot name="schemas/layout/section/secondary" alt="Secondary section" version="4.x" />

Optionally, the `secondary()` method accepts a boolean value to control if the section should be secondary or not:

```php
use Filament\Schemas\Components\Section;

Section::make('Notes')
    ->schema([
        // ...
    ])
    ->secondary(FeatureFlag::active())
```

## Inserting actions and other components in the header of a section

You may insert [actions](../actions) and any other schema component (usually [prime components](primes)) into the header of a section by passing an array of components to the `afterHeader()` method:

```php
use Filament\Schemas\Components\Section;

Section::make('Rate limiting')
    ->description('Prevent abuse by limiting the number of requests per period')
    ->afterHeader([
        Action::make('test'),
    ])
    ->schema([
        // ...
    ])
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static value, the `afterHeader()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="schemas/layout/section/header/actions" alt="Section with actions in the header" version="4.x" />

## Inserting actions and other components in the footer of a section

You may insert [actions](../actions) and any other schema component (usually [prime components](primes)) into the footer of a section by passing an array of components to the `footer()` method:

```php
use Filament\Schemas\Components\Section;

Section::make('Rate limiting')
    ->description('Prevent abuse by limiting the number of requests per period')
    ->schema([
        // ...
    ])
    ->footer([
        Action::make('test'),
    ])
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static value, the `footer()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="schemas/layout/section/footer/actions" alt="Section with actions in the footer" version="4.x" />

## Using grid columns within a section

You may use the `columns()` method to easily create a [grid](layouts#grid-system) within the section:

```php
use Filament\Schemas\Components\Section;

Section::make('Heading')
    ->schema([
        // ...
    ])
    ->columns(2)
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static value, the `columns()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

# Documentation for schemas. File: 04-tabs.md
---
title: Tabs
---
import AutoScreenshot from "@components/AutoScreenshot.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

Some schemas can be long and complex. You may want to use tabs to reduce the number of components that are visible at once:

```php
use Filament\Schemas\Components\Tabs;
use Filament\Schemas\Components\Tabs\Tab;

Tabs::make('Tabs')
    ->tabs([
        Tab::make('Tab 1')
            ->schema([
                // ...
            ]),
        Tab::make('Tab 2')
            ->schema([
                // ...
            ]),
        Tab::make('Tab 3')
            ->schema([
                // ...
            ]),
    ])
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static value, the `make()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="schemas/layout/tabs/simple" alt="Tabs" version="4.x" />

## Setting the default active tab

The first tab will be open by default. You can change the default open tab using the `activeTab()` method:

```php
use Filament\Schemas\Components\Tabs;
use Filament\Schemas\Components\Tabs\Tab;

Tabs::make('Tabs')
    ->tabs([
        Tab::make('Tab 1')
            ->schema([
                // ...
            ]),
        Tab::make('Tab 2')
            ->schema([
                // ...
            ]),
        Tab::make('Tab 3')
            ->schema([
                // ...
            ]),
    ])
    ->activeTab(2)
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static value, the `activeTab()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Setting a tab icon

Tabs may have an [icon](../styling/icons), which you can set using the `icon()` method:

```php
use Filament\Schemas\Components\Tabs;
use Filament\Schemas\Components\Tabs\Tab;
use Filament\Support\Icons\Heroicon;

Tabs::make('Tabs')
    ->tabs([
        Tab::make('Notifications')
            ->icon(Heroicon::Bell)
            ->schema([
                // ...
            ]),
        // ...
    ])
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static value, the `icon()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="schemas/layout/tabs/icons" alt="Tabs with icons" version="4.x" />

### Setting the tab icon position

The icon of the tab may be positioned before or after the label using the `iconPosition()` method:

```php
use Filament\Schemas\Components\Tabs;
use Filament\Schemas\Components\Tabs\Tab;
use Filament\Support\Enums\IconPosition;
use Filament\Support\Icons\Heroicon;

Tabs::make('Tabs')
    ->tabs([
        Tab::make('Notifications')
            ->icon(Heroicon::Bell)
            ->iconPosition(IconPosition::After)
            ->schema([
                // ...
            ]),
        // ...
    ])
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static value, the `iconPosition()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="schemas/layout/tabs/icons-after" alt="Tabs with icons after their labels" version="4.x" />

## Setting a tab badge

Tabs may have a badge, which you can set using the `badge()` method:

```php
use Filament\Schemas\Components\Tabs;
use Filament\Schemas\Components\Tabs\Tab;

Tabs::make('Tabs')
    ->tabs([
        Tab::make('Notifications')
            ->badge(5)
            ->schema([
                // ...
            ]),
        // ...
    ])
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static value, the `badge()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="schemas/layout/tabs/badges" alt="Tabs with badges" version="4.x" />

If you'd like to change the [color](../styling/colors) for a badge, you can use the `badgeColor()` method:

```php
use Filament\Schemas\Components\Tabs;
use Filament\Schemas\Components\Tabs\Tab;

Tabs::make('Tabs')
    ->tabs([
        Tab::make('Notifications')
            ->badge(5)
            ->badgeColor('info')
            ->schema([
                // ...
            ]),
        // ...
    ])
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static value, the `badgeColor()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="schemas/layout/tabs/badges-color" alt="Tabs with badges with color" version="4.x" />

## Using grid columns within a tab

You may use the `columns()` method to customize the [grid](layouts#grid-system) within the tab:

```php
use Filament\Schemas\Components\Tabs;
use Filament\Schemas\Components\Tabs\Tab;

Tabs::make('Tabs')
    ->tabs([
        Tab::make('Tab 1')
            ->schema([
                // ...
            ])
            ->columns(3),
        // ...
    ])
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static value, the `columns()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Using vertical tabs

You can render the tabs vertically by using the `vertical()` method:

```php
use Filament\Schemas\Components\Tabs;
use Filament\Schemas\Components\Tabs\Tab;

Tabs::make('Tabs')
    ->tabs([
        Tab::make('Tab 1')
            ->schema([
                // ...
            ]),
        Tab::make('Tab 2')
            ->schema([
                // ...
            ]),
        Tab::make('Tab 3')
            ->schema([
                // ...
            ]),
    ])
    ->vertical()
```

<AutoScreenshot name="schemas/layout/tabs/vertical" alt="Vertical tabs" version="4.x" />

Optionally, you can pass a boolean value to the `vertical()` method to control if the tabs should be rendered vertically or not:

```php
use Filament\Schemas\Components\Tabs;

Tabs::make('Tabs')
    ->tabs([
        // ...
    ])
    ->vertical(FeatureFlag::active())
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static value, the `vertical()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Removing the styled container

By default, tabs and their content are wrapped in a container styled as a card. You may remove the styled container using `contained()`:

```php
use Filament\Schemas\Components\Tabs;
use Filament\Schemas\Components\Tabs\Tab;

Tabs::make('Tabs')
    ->tabs([
        Tab::make('Tab 1')
            ->schema([
                // ...
            ]),
        Tab::make('Tab 2')
            ->schema([
                // ...
            ]),
        Tab::make('Tab 3')
            ->schema([
                // ...
            ]),
    ])
    ->contained(false)
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static value, the `contained()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Persisting the current tab in the user's session

By default, the current tab is not persisted in the browser's local storage. You can change this behavior using the `persistTab()` method. You must also pass in a unique `id()` for the tabs component, to distinguish it from all other sets of tabs in the app. This ID will be used as the key in the local storage to store the current tab:

```php
use Filament\Schemas\Components\Tabs;

Tabs::make('Tabs')
    ->tabs([
        // ...
    ])
    ->persistTab()
    ->id('order-tabs')
```

Optionally, the `persistTab()` method accepts a boolean value to control if the active tab should persist or not:

```php
use Filament\Schemas\Components\Tabs;

Tabs::make('Tabs')
    ->tabs([
        // ...
    ])
    ->persistTab(FeatureFlag::active())
    ->id('order-tabs')
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing static values, the `persistTab()` and `id()` methods also accept functions to dynamically calculate them. You can inject various utilities into the function as parameters.</UtilityInjection>

### Persisting the current tab in the URL's query string

By default, the current tab is not persisted in the URL's query string. You can change this behavior using the `persistTabInQueryString()` method:

```php
use Filament\Schemas\Components\Tabs;
use Filament\Schemas\Components\Tabs\Tab;

Tabs::make('Tabs')
    ->tabs([
        Tab::make('Tab 1')
            ->schema([
                // ...
            ]),
        Tab::make('Tab 2')
            ->schema([
                // ...
            ]),
        Tab::make('Tab 3')
            ->schema([
                // ...
            ]),
    ])
    ->persistTabInQueryString()
```

When enabled, the current tab is persisted in the URL's query string using the `tab` key. You can change this key by passing it to the `persistTabInQueryString()` method:

```php
use Filament\Schemas\Components\Tabs;
use Filament\Schemas\Components\Tabs\Tab;

Tabs::make('Tabs')
    ->tabs([
        Tab::make('Tab 1')
            ->schema([
                // ...
            ]),
        Tab::make('Tab 2')
            ->schema([
                // ...
            ]),
        Tab::make('Tab 3')
            ->schema([
                // ...
            ]),
    ])
    ->persistTabInQueryString('settings-tab')
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static value, the `persistTabInQueryString()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

# Documentation for schemas. File: 05-wizards.md
---
title: Wizards
---
import Aside from "@components/Aside.astro"
import AutoScreenshot from "@components/AutoScreenshot.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

Similar to [tabs](tabs), you may want to use a multistep wizard to reduce the number of components that are visible at once. These are especially useful if your form has a definite chronological order, in which you want each step to be validated as the user progresses.

```php
use Filament\Schemas\Components\Wizard;
use Filament\Schemas\Components\Wizard\Step;

Wizard::make([
    Step::make('Order')
        ->schema([
            // ...
        ]),
    Step::make('Delivery')
        ->schema([
            // ...
        ]),
    Step::make('Billing')
        ->schema([
            // ...
        ]),
])
```

<AutoScreenshot name="schemas/layout/wizard/simple" alt="Wizard" version="4.x" />

<Aside variant="tip">
    We have different setup instructions if you're looking to add a wizard to the creation process inside a [panel resource](../resources/creating-records#using-a-wizard) or an [action modal](../actions/modals#rendering-a-wizard-in-a-modal). Following that documentation will ensure that the ability to submit the form is only available on the last step of the wizard.
</Aside>

## Rendering a submit button on the last step

You may use the `submitAction()` method to render submit button HTML or a view at the end of the wizard, on the last step. This provides a clearer UX than displaying a submit button below the wizard at all times:

```php
use Filament\Schemas\Components\Wizard;
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
use Filament\Schemas\Components\Wizard;
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

You could extract this component to a separate Blade view if you prefer.

## Setting a step icon

Steps may have an [icon](../styling/icons), which you can set using the `icon()` method:

```php
use Filament\Schemas\Components\Wizard\Step;
use Filament\Support\Icons\Heroicon;

Step::make('Order')
    ->icon(Heroicon::ShoppingBag)
    ->schema([
        // ...
    ]),
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static value, the `icon()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="schemas/layout/wizard/icons" alt="Wizard with step icons" version="4.x" />

## Customizing the icon for completed steps

You may customize the [icon](#setting-up-step-icons) of a completed step using the `completedIcon()` method:

```php
use Filament\Schemas\Components\Wizard\Step;
use Filament\Support\Icons\Heroicon;

Step::make('Order')
    ->completedIcon(Heroicon::HandThumbUp)
    ->schema([
        // ...
    ]),
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static value, the `completedIcon()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="schemas/layout/wizard/completed-icons" alt="Wizard with completed step icons" version="4.x" />

## Adding descriptions to steps

You may add a short description after the title of each step using the `description()` method:

```php
use Filament\Schemas\Components\Wizard\Step;

Step::make('Order')
    ->description('Review your basket')
    ->schema([
        // ...
    ]),
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static value, the `description()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="schemas/layout/wizard/descriptions" alt="Wizard with step descriptions" version="4.x" />

## Setting the default active step

You may use the `startOnStep()` method to load a specific step in the wizard:

```php
use Filament\Schemas\Components\Wizard;

Wizard::make([
    // ...
])->startOnStep(2)
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static value, the `startOnStep()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Allowing steps to be skipped

If you'd like to allow free navigation, so all steps are skippable, use the `skippable()` method:

```php
use Filament\Schemas\Components\Wizard;

Wizard::make([
    // ...
])->skippable()
```

Optionally, the `skippable()` method accepts a boolean value to control if the step is skippable or not:

```php
use Filament\Schemas\Components\Wizard\Step;

Step::make('Order')
    ->skippable(FeatureFlag::active())
    ->schema([
        // ...
    ]),
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static value, the `skippable()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Persisting the current step in the URL's query string

By default, the current step is not persisted in the URL's query string. You can change this behavior using the `persistStepInQueryString()` method:

```php
use Filament\Schemas\Components\Wizard;

Wizard::make([
    // ...
])->persistStepInQueryString()
```

When enabled, the current step is persisted in the URL's query string using the `step` key. You can change this key by passing it to the `persistStepInQueryString()` method:

```php
use Filament\Schemas\Components\Wizard;

Wizard::make([
    // ...
])->persistStepInQueryString('wizard-step')
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static value, the `persistStepInQueryString()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Step lifecycle hooks

You may use the `afterValidation()` and `beforeValidation()` methods to run code before and after validation occurs on the step:

```php
use Filament\Schemas\Components\Wizard\Step;

Step::make('Order')
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

<UtilityInjection set="schemaComponents" version="4.x">You can inject various utilities into the `afterValidation()` and `beforeValidation()` functions as parameters.</UtilityInjection>

### Preventing the next step from being loaded

Inside `afterValidation()` or `beforeValidation()`, you may throw `Filament\Support\Exceptions\Halt`, which will prevent the wizard from loading the next step:

```php
use Filament\Schemas\Components\Wizard\Step;
use Filament\Support\Exceptions\Halt;

Step::make('Order')
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

You may use the `columns()` method to customize the [grid](layouts#grid-system) within the step:

```php
use Filament\Schemas\Components\Wizard;
use Filament\Schemas\Components\Wizard\Step;

Wizard::make([
    Step::make('Order')
        ->columns(2)
        ->schema([
            // ...
        ]),
    // ...
])
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static value, the `columns()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Customizing the wizard action objects

This component uses action objects for easy customization of buttons within it. You can customize these buttons by passing a function to an action registration method. The function has access to the `$action` object, which you can use to [customize it](../actions/overview). The following methods are available to customize the actions:

- `nextAction()`
- `previousAction()`

Here is an example of how you might customize an action:

```php
use Filament\Actions\Action;
use Filament\Schemas\Components\Wizard;

Wizard::make([
    // ...
])
    ->nextAction(
        fn (Action $action) => $action->label('Next step'),
    )
```

<UtilityInjection set="formFields" version="4.x" extras="Action;;Filament\Actions\Action;;$action;;The action object to customize.">The action registration methods can inject various utilities into the function as parameters.</UtilityInjection>

# Documentation for schemas. File: 06-primes.md
---
title: Prime components
---
import Aside from "@components/Aside.astro"
import AutoScreenshot from "@components/AutoScreenshot.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

Within Filament schemas, prime components are the most basic building blocks that can be used to insert arbitrary content into a schema, such as text and images. As the name suggests, prime components are not divisible and cannot be made simpler. Filament provides a set of built-in prime components:

- [Text](#text-component)
- [Icon](#icon-component)
- [Image](#image-component)
- [Unordered list](#unordered-list-component)

You may also [create your own custom components](custom-components) to add your own arbitrary content to a schema.

<AutoScreenshot name="primes/overview/example" alt="An example of using prime components to set up two-factor authentication." version="4.x" />

In this example, prime components are being used to display instructions to the user, a QR code that the user can scan, and list of recovery codes that the user can save:

```php
use Filament\Actions\Action;
use Filament\Schemas\Components\Image;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Components\Text;
use Filament\Schemas\Components\UnorderedList;
use Filament\Support\Enums\FontWeight;
use Filament\Support\Enums\TextSize;

$schema
    ->components([
        Text::make('Scan this QR code with your authenticator app:')
            ->color('neutral'),
        Image::make(
            url: asset('images/qr.jpg'),
            alt: 'QR code to scan with an authenticator app',
        )
            ->imageHeight('12rem')
            ->alignCenter(),
        Section::make()
            ->schema([
                Text::make('Please save the following recovery codes in a safe place. They will only be shown once, but you\'ll need them if you lose access to your authenticator app:')
                    ->weight(FontWeight::Bold)
                    ->color('neutral'),
                UnorderedList::make(fn (): array => array_map(
                    fn (string $recoveryCode): Text => Text::make($recoveryCode)
                        ->copyable()
                        ->fontFamily(FontFamily::Mono)
                        ->size(TextSize::ExtraSmall)
                        ->color('neutral'),
                    ['tYRnCqNLUx-3QOLNKyDiV', 'cKok2eImKc-oWHHH4VhNe', 'C0ZstEcSSB-nrbyk2pv8z', '49EXLRQ8MI-FpWywpSDHE', 'TXjHnvkUrr-KuiVJENPmJ', 'BB574ookll-uI20yxP6oa', 'BbgScF2egu-VOfHrMtsCl', 'cO0dJYqmee-S9ubJHpRFR'],
                ))
                    ->size(TextSize::ExtraSmall),
            ])
            ->compact()
            ->secondary(),
    ])
```

Although text can be rendered in a schema using an [infolist text entry](../infolists/text-entry), entries are intended to render a label-value detail about an entity (like an Eloquent model), and not to render arbitrary text. Prime components are more suitable for this purpose. Infolists can be considered more similar to [description lists](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/dl) in HTML.

Prime component classes can be found in the `Filament\Schemas\Components` namespace. They reside within the schema array of components.

## Text component

Text can be inserted into a schema using the `Text` component. Text content is passed to the `make()` method:

```php
use Filament\Schemas\Components\Text;

Text::make('Modifying these permissions may give users access to sensitive information.')
```

<AutoScreenshot name="primes/text/simple" alt="Text" version="4.x" />

To render raw HTML content, you can pass an `HtmlString` object to the `make()` method:

```php
use Filament\Schemas\Components\Text;
use Illuminate\Support\HtmlString;

Text::make(new HtmlString('<strong>Warning:</strong> Modifying these permissions may give users access to sensitive information.'))
```

<Aside variant="danger">
    Be aware that you will need to ensure that the HTML is safe to render, otherwise your application will be vulnerable to XSS attacks.
</Aside>

<AutoScreenshot name="primes/text/html" alt="Text with HTML" version="4.x" />

To render Markdown, you can use Laravel's `str()` helper to convert Markdown to HTML, and then transform it into an `HtmlString` object:

```php
use Filament\Schemas\Components\Text;

Text::make(
    str('**Warning:** Modifying these permissions may give users access to sensitive information.')
        ->inlineMarkdown()
        ->toHtmlString(),
)
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static value, the `make()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Customizing the text color

You may set a [color](../styling/colors) for the text:

```php
use Filament\Schemas\Components\Text;

Text::make('Information')
    ->color('info')
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static value, the `color()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="primes/text/color" alt="Text in the info color" version="4.x" />

### Using a neutral color

By default, the text color is set to `gray`, which is typically fairly dim against its background. You can darken it using the `color('neutral')` method:

```php
use Filament\Schemas\Components\Text;

Text::make('Modifying these permissions may give users access to sensitive information.')

Text::make('Modifying these permissions may give users access to sensitive information.')
    ->color('neutral')
```

<AutoScreenshot name="primes/text/neutral" alt="Text in the neutral color" version="4.x" />

### Displaying as a "badge"

By default, text is quite plain and has no background color. You can make it appear as a "badge" instead using the `badge()` method. A great use case for this is with statuses, where may want to display a badge with a [color](#customizing-the-text-color) that matches the status:

```php
use Filament\Schemas\Components\Text;

Text::make('Warning')
    ->color('warning')
    ->badge()
```

<AutoScreenshot name="primes/text/badge" alt="Text as badge" version="4.x" />

Optionally, you may pass a boolean value to control if the text should be in a badge or not:

```php
use Filament\Schemas\Components\Text;

Text::make('Warning')
    ->color('warning')
    ->badge(FeatureFlag::active())
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static value, the `badge()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

#### Adding an icon to the badge

You may add other things to the badge, like an [icon](../styling/icons):

```php
use Filament\Schemas\Components\Text;
use Filament\Support\Icons\Heroicon;

Text::make('Warning')
    ->color('warning')
    ->badge()
    ->icon(Heroicon::ExclamationTriangle)
```

<AutoScreenshot name="primes/text/badge-icon" alt="Text as badge with an icon" version="4.x" />

### Customizing the text size

Text has a small font size by default, but you may change this to `TextSize::ExtraSmall`, `TextSize::Medium`, or `TextSize::Large`.

For instance, you may make the text larger using `size(TextSize::Large)`:

```php
use Filament\Schemas\Components\Text;
use Filament\Support\Enums\TextSize;

Text::make('Modifying these permissions may give users access to sensitive information.')
    ->size(TextSize::Large)
```

<AutoScreenshot name="primes/text/large" alt="Text entry in a large font size" version="4.x" />

### Customizing the font weight

Text entries have regular font weight by default, but you may change this to any of the following options: `FontWeight::Thin`, `FontWeight::ExtraLight`, `FontWeight::Light`, `FontWeight::Medium`, `FontWeight::SemiBold`, `FontWeight::Bold`, `FontWeight::ExtraBold` or `FontWeight::Black`.

For instance, you may make the font bold using `weight(FontWeight::Bold)`:

```php
use Filament\Schemas\Components\Text;
use Filament\Support\Enums\FontWeight;

Text::make('Modifying these permissions may give users access to sensitive information.')
    ->weight(FontWeight::Bold)
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static value, the `weight()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="primes/text/bold" alt="Text entry in a bold font" version="4.x" />

### Customizing the font family

You can change the text font family to any of the following options: `FontFamily::Sans`, `FontFamily::Serif` or `FontFamily::Mono`.

For instance, you may make the font monospaced using `fontFamily(FontFamily::Mono)`:

```php
use Filament\Support\Enums\FontFamily;
use Filament\Schemas\Components\Text;

Text::make('28o.-AK%D~xh*.:[4"3)zPiC')
    ->fontFamily(FontFamily::Mono)
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static value, the `fontFamily()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="primes/text/mono" alt="Text entry in a monospaced font" version="4.x" />

### Adding a tooltip to the text

You may add a tooltip to the text using the `tooltip()` method:

```php
use Filament\Schemas\Components\Text;

Text::make('28o.-AK%D~xh*.:[4"3)zPiC')
    ->tooltip('Your secret recovery code')
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static value, the `tooltip()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="primes/text/tooltip" alt="Text with a tooltip" version="4.x" />

### Using JavaScript to determine the content of the text

You can use JavaScript to determine the content of the text. This is useful if you want to display a different message depending on the state of a [form field](../forms/fields), without making a request to the server to re-render the schema. To allow this, you can use the `js()` method:

```php
use Filament\Schemas\Components\Text;

Text::make(<<<'JS'
    $get('name') ? `Hello, ${$get('name')}` : 'Please enter your name.'
    JS)
    ->js()
```

The [`$state`](../forms/fields#injecting-the-current-state-of-the-field) and [`$get()`](../forms/fields#injecting-the-state-of-another-field) utilities are available in the JavaScript context, so you can use them to get the state of fields in the schema.

## Icon component

Icons can be inserted into a schema using the `Icon` component. [Icons](../styling/icons) are passed to the `make()` method:

```php
use Filament\Schemas\Components\Icon;
use Filament\Support\Icons\Heroicon;

Icon::make(Heroicon::Star)
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static value, the `make()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="primes/icon/simple" alt="Icon" version="4.x" />

### Customizing the icon color

You may set a [color](../styling/colors) for the icon:

```php
use Filament\Schemas\Components\Icon;
use Filament\Support\Icons\Heroicon;

Icon::make(Heroicon::ExclamationCircle)
    ->color('danger')
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static value, the `color()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="primes/icon/color" alt="Icon in the danger color" version="4.x" />

### Adding a tooltip to the icon

You may add a tooltip to the icon using the `tooltip()` method:

```php
use Filament\Schemas\Components\Icon;
use Filament\Support\Icons\Heroicon;

Icon::make(Heroicon::ExclamationTriangle)
    ->tooltip('Warning')
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static value, the `tooltip()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="primes/icon/tooltip" alt="Icon with a tooltip" version="4.x" />

## Image component

Images can be inserted into a schema using the `Image` component. The image URL and alt text are passed to the `make()` method:

```php
use Filament\Schemas\Components\Image;

Image::make(
    url: asset('images/qr.jpg'),
    alt: 'QR code to scan with an authenticator app',
)
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static values, the arguments of the `make()` method also accept functions to dynamically calculate them. You can inject various utilities into the functions as parameters.</UtilityInjection>

<AutoScreenshot name="primes/image/simple" alt="Image" version="4.x" />

### Customizing the image size

You may customize the image size by passing a `imageWidth()` and `imageHeight()`, or both with `imageSize()`:

```php
use Filament\Schemas\Components\Image;

Image::make(
    url: asset('images/qr.jpg'),
    alt: 'QR code to scan with an authenticator app',
)
    ->imageWidth('12rem')

Image::make(
    url: asset('images/qr.jpg'),
    alt: 'QR code to scan with an authenticator app',
)
    ->imageHeight('12rem')

Image::make(
    url: asset('images/qr.jpg'),
    alt: 'QR code to scan with an authenticator app',
)
    ->imageSize('12rem')
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static values, the `imageWidth()`, `imageHeight()` and `imageSize()` methods also accept functions to dynamically calculate them. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="primes/image/size" alt="Image with a custom size" version="4.x" />

### Aligning the image

You may align the image to the start (left in left-to-right interfaces, right in right-to-left interfaces), center, or end (right in left-to-right interfaces, left in right-to-left interfaces) using the `alignStart()`, `alignCenter()` or `alignEnd()` methods:

```php
use Filament\Schemas\Components\Image;

Image::make(
    url: asset('images/qr.jpg'),
    alt: 'QR code to scan with an authenticator app',
)
    ->alignStart() // This is the default alignment.

Image::make(
    url: asset('images/qr.jpg'),
    alt: 'QR code to scan with an authenticator app',
)
    ->alignCenter()

Image::make(
    url: asset('images/qr.jpg'),
    alt: 'QR code to scan with an authenticator app',
)
    ->alignEnd()
```

Alternatively, you may pass an `Alignment` enum to the `alignment()` method:

```php
use Filament\Schemas\Components\Image;
use Filament\Support\Enums\Alignment;

Image::make(
    url: asset('images/qr.jpg'),
    alt: 'QR code to scan with an authenticator app',
)
    ->alignment(Alignment::Center)
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static value, the `alignment()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="primes/image/alignment" alt="Image with a custom alignment" version="4.x" />

### Adding a tooltip to the image

You may add a tooltip to the image using the `tooltip()` method:

```php
use Filament\Schemas\Components\Image;

Image::make(
    url: asset('images/qr.jpg'),
    alt: 'QR code to scan with an authenticator app',
)
    ->tooltip('Scan this QR code with your authenticator app')
    ->alignCenter()
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static value, the `tooltip()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="primes/image/tooltip" alt="Image with a tooltip" version="4.x" />

## Unordered list component

Unordered lists can be inserted into a schema using the `UnorderedList` component. The list items, comprising plain text or [text components](#text-component), are passed to the `make()` method:

```php
use Filament\Schemas\Components\UnorderedList;

UnorderedList::make([
    'Tables',
    'Schemas',
    'Actions',
    'Notifications',
])
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static value, the `make()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="primes/unordered-list/simple" alt="Unordered list" version="4.x" />

Text components can be used as list items, which allows you to customize the formatting of each item:

```php
use Filament\Schemas\Components\Text;
use Filament\Schemas\Components\UnorderedList;
use Filament\Support\Enums\FontFamily;

UnorderedList::make([
    Text::make('Tables')->fontFamily(FontFamily::Mono),
    Text::make('Schemas')->fontFamily(FontFamily::Mono),
    Text::make('Actions')->fontFamily(FontFamily::Mono),
    Text::make('Notifications')->fontFamily(FontFamily::Mono),
])
```

### Customizing the bullet size

If you are modifying the text size of the list content, you will probably want to adjust the size of the bullets to match. To do this, you can use the `size()` method. Bullets have small font size by default, but you may change this to `TextSize::ExtraSmall`, `TextSize::Medium`, or `TextSize::Large`.

For instance, you may make the bullets larger using `size(TextSize::Large)`:

```php
use Filament\Schemas\Components\Text;
use Filament\Schemas\Components\UnorderedList;

UnorderedList::make([
    Text::make('Tables')->size(TextSize::Large),
    Text::make('Schemas')->size(TextSize::Large),
    Text::make('Actions')->size(TextSize::Large),
    Text::make('Notifications')->size(TextSize::Large),
])
    ->size(TextSize::Large)
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static value, the `size()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="primes/unordered-list/large" alt="Unordered list with large bullets" version="4.x" />

## Adding extra HTML attributes to a prime component

You can pass extra HTML attributes to the component via the `extraAttributes()` method, which will be merged onto its outer HTML element. The attributes should be represented by an array, where the key is the attribute name and the value is the attribute value:

```php
use Filament\Schemas\Components\Text;

Text::make('Modifying these permissions may give users access to sensitive information.')
    ->extraAttributes(['class' => 'custom-text-style'])
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static value, the `extraAttributes()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

By default, calling `extraAttributes()` multiple times will overwrite the previous attributes. If you wish to merge the attributes instead, you can pass `merge: true` to the method.

# Documentation for schemas. File: 07-custom-components.md
---
title: Custom components
---
import Aside from "@components/Aside.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Inserting a Blade view into a schema

You may use a "view" component to insert a Blade view into a schema arbitrarily:

```php
use Filament\Schemas\Components\View;

View::make('filament.schemas.components.chart')
```

This assumes that you have a `resources/views/filament/schemas/components/chart.blade.php` file.

### Rendering the component's child schema

You may pass an array of child schema components to the `schema()` method of the component:

```php
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\View;

View::make('filament.schemas.components.chart')
    ->schema([
        TextInput::make('subtotal'),
        TextInput::make('total'),
    ])
```

Inside the Blade view, you may render the component's `schema()` using the `$getChildSchema()` function:

```blade
<div>
    {{ $getChildSchema() }}
</div>
```

### Accessing the state of another component in the Blade view

Inside the Blade view, you may access the state of another component in the schema using the `$get()` function:

```blade
<div>
    {{ $get('email') }}
</div>
```

<Aside variant="tip">
    Unless a form field is [reactive](../forms/overview#the-basics-of-reactivity), the Blade view will not refresh when the value of the field changes, only when the next user interaction occurs that makes a request to the server. If you need to react to changes in a field's value, it should be `live()`.
</Aside>

### Accessing the Eloquent record in the Blade view

Inside the Blade view, you may access the current Eloquent record using the `$record` variable:

```blade
<div>
    {{ $record->name }}
</div>
```

### Accessing the current operation in the Blade view

Inside the Blade view, you may access the current operation, usually `create`, `edit` or `view`, using the `$operation` variable:

```blade
<p>
    @if ($operation === 'create')
        This is a new post.
    @else
        This is an existing post.
    @endif
</p>
```

### Accessing the current Livewire component instance in the Blade view

Inside the Blade view, you may access the current Livewire component instance using `$this`:

```blade
@php
    use Filament\Resources\Users\RelationManagers\PostsRelationManager;
@endphp

<p>
    @if ($this instanceof PostsRelationManager)
        You are editing posts the of a user.
    @endif
</p>
```

### Accessing the current component instance in the Blade view

Inside the Blade view, you may access the current component instance using `$schemaComponent`. You can call public methods on this object to access other information that may not be available in variables:

```blade
<p>
    @if ($schemaComponent->getState())
        This is a new post.
    @endif
</p>
```

## Inserting a Livewire component into a schema

You may insert a Livewire component directly into a schema:

```php
use App\Livewire\Chart;
use Filament\Schemas\Components\Livewire;

Livewire::make(Chart::class)
```

<Aside variant="info">
    When inserting a Livewire component into the schema, there are limited capabilities. Only serializable data is accessible from the nested Livewire component, since they are rendered separately. As such, you can't [render a child schema](#rendering-the-components-child-schema), [access another component's live state](#accessing-the-state-of-another-component-in-the-blade-view), [access the current Livewire component instance](#accessing-the-current-livewire-component-instance-in-the-blade-view), or [access the current component instance](#accessing-the-current-component-instance-in-the-blade-view). Only [static data that you pass to the Livewire component](#passing-parameters-to-a-livewire-component), and [the current record](#accessing-the-current-record-in-the-livewire-component) are accessible. Situations where you should render a nested Livewire component instead of a [Blade view](#inserting-a-blade-view-into-a-schema) are rare because of these limitations.
</Aside>

If you are rendering multiple of the same Livewire component, please make sure to pass a unique `key()` to each:

```php
use App\Livewire\Chart;
use Filament\Schemas\Components\Livewire;

Livewire::make(Chart::class)
    ->key('chart-first')

Livewire::make(Chart::class)
    ->key('chart-second')

Livewire::make(Chart::class)
    ->key('chart-third')
```

### Passing parameters to a Livewire component

You can pass an array of parameters to a Livewire component:

```php
use App\Livewire\Chart;
use Filament\Schemas\Components\Livewire;

Livewire::make(Chart::class, ['bar' => 'baz'])
```

<UtilityInjection set="schemaComponents" version="4.x">As well as allowing a static value, the `make()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

Now, those parameters will be passed to the Livewire component's `mount()` method:

```php
class Chart extends Component
{
    public function mount(string $bar): void
    {       
        // ...
    }
}
```

Alternatively, they will be available as public properties on the Livewire component:

```php
class Chart extends Component
{
    public string $bar;
}
```

#### Accessing the current record in the Livewire component

You can access the current record in the Livewire component using the `$record` parameter in the `mount()` method, or the `$record` property:

```php
use Illuminate\Database\Eloquent\Model;

class Chart extends Component
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
use Filament\Schemas\Components\Livewire;
use Illuminate\Database\Eloquent\Model;

Livewire::make(Chart::class)
    ->hidden(fn (?Model $record): bool => $record === null)
```

### Lazy loading a Livewire component

You may allow the component to [lazily load](https://livewire.laravel.com/docs/lazy#rendering-placeholder-html) using the `lazy()` method:

```php
use Filament\Schemas\Components\Livewire;
use App\Livewire\Chart;

Livewire::make(Chart::class)
    ->lazy()       
```

## Custom component classes

You may create your own custom component classes and views, which you can reuse across your project, and even release as a plugin to the community.

<Aside variant="tip">
    If you're just creating a simple custom component to use once, you could instead use a [view component](#inserting-a-blade-view-into-a-schema) to render any custom Blade file.
</Aside>

To create a custom component class and view, you may use the following command:

```bash
php artisan make:filament-schema-component Chart
```

This will create the following component class:

```php
use Filament\Schemas\Components\Component;

class Chart extends Component
{
    protected string $view = 'filament.schemas.components.chart';

    public static function make(): static
    {
        return app(static::class);
    }
}
```

It will also create a view file at `resources/views/filament/schemas/components/chart.blade.php`.

You may use the same utilities as you would when [inserting a Blade view into a schema](#inserting-a-blade-view-into-a-schema) to [render the component's child schema](#rendering-the-components-child-schema), [access another component's live state](#accessing-the-state-of-another-component-in-the-blade-view), [access the current Eloquent record](#accessing-the-eloquent-record-in-the-blade-view), [access the current operation](#accessing-the-current-operation-in-the-blade-view), [access the current Livewire component instance](#accessing-the-current-livewire-component-instance-in-the-blade-view), and [access the current component instance](#accessing-the-current-component-instance-in-the-blade-view).

<Aside variant="info">
    Filament schema components are **not** Livewire components. Defining public properties and methods on a schema component class will not make them accessible in the Blade view.
</Aside>

### Adding a configuration method to a custom component class

You may add a public method to the custom component class that accepts a configuration value, stores it in a protected property, and returns it again from another public method:

```php
use Filament\Schemas\Components\Component;

class Chart extends Component
{
    protected string $view = 'filament.schemas.components.chart';
    
    protected ?string $heading = null;

    public static function make(): static
    {
        return app(static::class);
    }

    public function heading(?string $heading): static
    {
        $this->heading = $heading;

        return $this;
    }

    public function getHeading(): ?string
    {
        return $this->heading;
    }
}
```

Now, in the Blade view for the custom component, you may access the heading using the `$getHeading()` function:

```blade
<div>
    {{ $getHeading() }}
</div>
```

Any public method that you define on the custom component class can be accessed in the Blade view as a variable function in this way.

To pass the configuration value to the custom component class, you may use the public method:

```php
use App\Filament\Schemas\Components\Chart;

Chart::make()
    ->heading('Sales')
```

#### Allowing utility injection in a custom component configuration method

[Utility injection](overview#component-utility-injection) is a powerful feature of Filament that allows users to configure a component using functions that can access various utilities. You can allow utility injection by ensuring that the parameter type and property type of the configuration allows the user to pass a `Closure`. In the getter method, you should pass the configuration value to the `$this->evaluate()` method, which will inject utilities into the user's function if they pass one, or return the value if it is static:

```php
use Closure;
use Filament\Schemas\Components\Component;

class Chart extends Component
{
    protected string $view = 'filament.schemas.components.chart';
    
    protected string | Closure | null $heading = null;

    public static function make(): static
    {
        return app(static::class);
    }

    public function heading(string | Closure | null $heading): static
    {
        $this->heading = $heading;

        return $this;
    }

    public function getHeading(): ?string
    {
        return $this->evaluate($this->heading);
    }
}
```

Now, you can pass a static value or a function to the `heading()` method, and [inject any utility](overview#component-utility-injection) as a parameter:

```php
use App\Filament\Schemas\Components\Chart;

Chart::make()
    ->heading(fn (Product $record): string => "{$record->name} Sales")
```

### Accepting a configuration value in the constructor of a custom component class

You may accept a configuration value in the `make()` constructor method of the custom component and pass it to the corresponding setter method:

```php
use Closure;
use Filament\Schemas\Components\Component;

class Chart extends Component
{
    protected string $view = 'filament.schemas.components.chart';
    
    protected string | Closure | null $heading = null;

    public function __construct(string | Closure | null $heading = null)
    {
        $this->heading($heading)
    }

    public static function make(string | Closure | null $heading = null): static
    {
        return app(static::class, ['heading' => $heading]);
    }
    
    public function heading(string | Closure | null $heading): static
    {
        $this->heading = $heading;

        return $this;
    }

    public function getHeading(): ?string
    {
        return $this->evaluate($this->heading);
    }
}
```

