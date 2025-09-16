# Documentation for forms. File: 01-overview.md
---
title: Overview
---
import Aside from "@components/Aside.astro"
import AutoScreenshot from "@components/AutoScreenshot.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

<AutoScreenshot name="forms/overview" alt="Account settings form example" version="4.x" />

Filament's forms package allows you to easily build dynamic forms in your app. It's used within other Filament packages to render forms within [panel resources](../panels/resources), [action modals](../actions/modals), [table filters](../tables/filters), and more. Learning how to build forms is essential to learning how to use these Filament packages.

This guide will walk you through the basics of building forms with Filament's form package. If you're planning to add a new form to your own Livewire component, you should [do that first](../components/form) and then come back. If you're adding a form to a [panel resource](../panels/resources), or another Filament package, you're ready to go!

## Form fields

Form field classes can be found in the `Filament\Form\Components` namespace. They reside within the schema array of components. Filament ships with many types of field, suitable for editing different types of data:

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
- [Slider](slider)
- [Code editor](code-editor)
- [Hidden](hidden)

You may also [create your own custom fields](custom-fields) to edit data however you wish.

Fields may be created using the static `make()` method, passing its unique name. Usually, the name of a field corresponds to the name of an attribute on an Eloquent model:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('name')
```

<AutoScreenshot name="forms/fields/simple" alt="Form field" version="4.x" />

You may use "dot notation" to bind fields to keys in arrays:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('socials.github_url')
```

## Validating fields

In Laravel, validation rules are usually defined in arrays like `['required', 'max:255']` or a combined string like `required|max:255`. This is fine if you're exclusively working in the backend with simple form requests. But Filament is also able to give your users frontend validation, so they can fix their mistakes before any backend requests are made.

In Filament, you can add validation rules to your fields by using methods like `required()` and `maxLength()`. This is also advantageous over Laravel's validation syntax, since your IDE can autocomplete these methods:

```php
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\RichEditor;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Section;

TextInput::make('name')
    ->required()
    ->maxLength(255)
```

In this example, the fields is `required()`, and has a `maxLength()`. We have [methods for most of Laravel's validation rules](validation#available-rules), and you can even add your own [custom rules](validation#custom-rules).

## Setting a field's label

By default, the label of the field will be automatically determined based on its name. To override the field's label, you may use the `label()` method:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('name')
    ->label('Full name')
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `label()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

Customizing the label in this way is useful if you wish to use a [translation string for localization](https://laravel.com/docs/localization#retrieving-translation-strings):

```php
use Filament\Forms\Components\TextInput;

TextInput::make('name')
    ->label(__('fields.name'))
```

<Aside variant="tip">
    You can also [use a JavaScript expression](#using-javascript-to-determine-text-content) to determine the content of the label, which can read the current values of fields in the form.
</Aside>

### Hiding a field's label

It may be tempting to set the label to an empty string to hide it, but this is not recommended. Setting the label to an empty string will not communicate the purpose of the field to screen readers, even if the purpose is clear visually. Instead, you should use the `hiddenLabel()` method, so it is hidden visually but still accessible to screen readers:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('name')
    ->hiddenLabel()
```

Optionally, you may pass a boolean value to control if the label should be hidden or not:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('name')
    ->hiddenLabel(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `hiddenLabel()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Setting the default value of a field

Fields may have a default value. The default is only used when a schema is loaded with no data. In a standard [panel resource](../resources), defaults are used on the Create page, not the Edit page. To define a default value, use the `default()` method:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('name')
    ->default('John')
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `default()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Disabling a field

You may disable a field to prevent it from being edited by the user:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('name')
    ->disabled()
```

<AutoScreenshot name="forms/fields/disabled" alt="Disabled form field" version="4.x" />

Optionally, you may pass a boolean value to control if the field should be disabled or not:

```php
use Filament\Forms\Components\Toggle;

Toggle::make('is_admin')
    ->disabled(! FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `disabled()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

Disabling a field will prevent it from being saved. If you'd like it to be saved, but still not editable, use the `dehydrated()` method:

```php
use Filament\Forms\Components\Toggle;

Toggle::make('is_admin')
    ->disabled()
    ->dehydrated()
```

<Aside variant="danger">
    If you choose to dehydrate the field, a skilled user could still edit the field's value by manipulating Livewire's JavaScript.
</Aside>

Optionally, you may pass a boolean value to control if the field should be dehydrated or not:

```php
use Filament\Forms\Components\Toggle;

Toggle::make('is_admin')
    ->disabled()
    ->dehydrated(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `dehydrated()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Disabling a field based on the current operation

The "operation" of a schema is the current action being performed on it. Usually, this is either `create`, `edit` or `view`, if you are using the [panel resource](../resources).

You can disable a field based on the current operation by passing an operation to the `disabledOn()` method:

```php
use Filament\Forms\Components\Toggle;

Toggle::make('is_admin')
    ->disabledOn('edit')

// is the same as

Toggle::make('is_admin')
    ->disabled(fn (string $operation): bool => $operation === 'edit')
```

You can also pass an array of operations to the `disabledOn()` method, and the field will be disabled if the current operation is any of the operations in the array:

```php
use Filament\Forms\Components\Toggle;

Toggle::make('is_admin')
    ->disabledOn(['edit', 'view'])
    
// is the same as

Toggle::make('is_admin')
    ->disabled(fn (string $operation): bool => in_array($operation, ['edit', 'view']))
```

<Aside variant="warning">
    The `disabledOn()` method will overwrite any previous calls to the `disabled()` method, and vice versa.
</Aside>

## Hiding a field

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
    ->hidden(! FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `hidden()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

Alternatively, you may use the `visible()` method to control if the field should be hidden or not. In some situations, this may help to make your code more readable:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('name')
    ->visible(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `visible()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<Aside variant="info">
    If both `hidden()` and `visible()` are used, they both need to indicate that the field should be visible for it to be shown.
</Aside>

### Hiding a field using JavaScript

If you need to hide a field based on a user interaction, you can use the `hidden()` or `visible()` methods, passing a function that uses utilities injected to determine whether the field should be hidden or not:

```php
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Toggle;

Select::make('role')
    ->options([
        'user' => 'User',
        'staff' => 'Staff',
    ])
    ->live()

Toggle::make('is_admin')
    ->hidden(fn (Get $get): bool => $get('role') !== 'staff')
```

In this example, the `role` field is set to `live()`, which means that the schema will reload the schema each time the `role` field is changed. This will cause the function that is passed to the `hidden()` method to be re-evaluated, which will hide the `is_admin` field if the `role` field is not set to `staff`.

However, reloading the schema each time a field causes a network request to be made, since there is no way to re-run the PHP function from the client-side. This is not ideal for performance.

Alternatively, you can write JavaScript to hide the field based on the value of another field. This is done by passing a JavaScript expression to the `hiddenJs()` method:

```php
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Toggle;

Select::make('role')
    ->options([
        'user' => 'User',
        'staff' => 'Staff',
    ])

Toggle::make('is_admin')
    ->hiddenJs(<<<'JS'
        $get('role') !== 'staff'
        JS)
```

Although the code passed to `hiddenJs()` looks very similar to PHP, it is actually JavaScript. Filament provides the `$get()` utility function to JavaScript that behaves very similar to its PHP equivalent, but without requiring the depended-on field to be `live()`.

<Aside variant="danger">
    Any JS string passed to the `hiddenJs()` method will be executed in the browser, so you should never add user input directly into the string, as it could lead to cross-site scripting (XSS) vulnerabilities. User input from `$state` or `$get()` should never be evaluated as JavaScript code, but is safe to use as a string value, like in the example above.
</Aside>

The `visibleJs()` method is also available, which works in the same way as `hiddenJs()`, but controls if the field should be visible or not:

```php
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Toggle;

Select::make('role')
    ->options([
        'user' => 'User',
        'staff' => 'Staff',
    ])

Toggle::make('is_admin')
    ->visibleJs(<<<'JS'
        $get('role') === 'staff'
        JS)
```

<Aside variant="danger">
    Any JS string passed to the `visibleJs()` method will be executed in the browser, so you should never add user input directly into the string, as it could lead to cross-site scripting (XSS) vulnerabilities. User input from `$state` or `$get()` should never be evaluated as JavaScript code, but is safe to use as a string value, like in the example above.
</Aside>

<Aside variant="info">
    If both `hiddenJs()` and `visibleJs()` are used, they both need to indicate that the field should be visible for it to be shown.
</Aside>

### Hiding a field based on the current operation

The "operation" of a schema is the current action being performed on it. Usually, this is either `create`, `edit` or `view`, if you are using the [panel resource](../resources).

You can hide a field based on the current operation by passing an operation to the `hiddenOn()` method:

```php
use Filament\Forms\Components\Toggle;

Toggle::make('is_admin')
    ->hiddenOn('edit')
    
// is the same as

Toggle::make('is_admin')
    ->hidden(fn (string $operation): bool => $operation === 'edit')
```

You can also pass an array of operations to the `hiddenOn()` method, and the field will be hidden if the current operation is any of the operations in the array:

```php
use Filament\Forms\Components\Toggle;

Toggle::make('is_admin')
    ->hiddenOn(['edit', 'view'])
    
// is the same as

Toggle::make('is_admin')
    ->hidden(fn (string $operation): bool => in_array($operation, ['edit', 'view']))
```

<Aside variant="warning">
    The `hiddenOn()` method will overwrite any previous calls to the `hidden()` method, and vice versa.
</Aside>

Alternatively, you may use the `visibleOn()` method to control if the field should be hidden or not. In some situations, this may help to make your code more readable:

```php
use Filament\Forms\Components\Toggle;

Toggle::make('is_admin')
    ->visibleOn('create')

Toggle::make('is_admin')
    ->visibleOn(['create', 'edit'])
```

<Aside variant="info">
    The `visibleOn()` method will overwrite any previous calls to the `visible()` method, and vice versa.
</Aside>

## Inline labels

Fields may have their labels displayed inline with the field, rather than above it. This is useful for forms with many fields, where vertical space is at a premium. To display a field's label inline, use the `inlineLabel()` method:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('name')
    ->inlineLabel()
```

<AutoScreenshot name="forms/fields/inline-label" alt="Form field with inline label" version="4.x" />

Optionally, you may pass a boolean value to control if the label should be displayed inline or not:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('name')
    ->inlineLabel(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `inlineLabel()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Using inline labels in multiple places at once

If you wish to display all labels inline in a [layout component](../schemas/layouts) like a [section](../schemas/sections) or [tab](../schemas/tabs), you can use the `inlineLabel()` on the component itself, and all fields within it will have their labels displayed inline:

```php
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Section;

Section::make('Details')
    ->inlineLabel()
    ->schema([
        TextInput::make('name'),
        TextInput::make('email')
            ->label('Email address'),
        TextInput::make('phone')
            ->label('Phone number'),
    ])
```

<AutoScreenshot name="forms/fields/inline-label/section" alt="Form fields with inline labels in a section" version="4.x" />

You can also use `inlineLabel()` on the entire schema to display all labels inline:

```php
use Filament\Schemas\Schema;

public function form(Schema $schema): Schema
{
    return $schema
        ->inlineLabel()
        ->components([
            // ...
        ]);
}
```

When using `inlineLabel()` on a layout component or schema, you can still opt-out of inline labels for individual fields by using the `inlineLabel(false)` method on the field:

```php
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Section;

Section::make('Details')
    ->inlineLabel()
    ->schema([
        TextInput::make('name'),
        TextInput::make('email')
            ->label('Email address'),
        TextInput::make('phone')
            ->label('Phone number')
            ->inlineLabel(false),
    ])
```

## Autofocusing a field when the schema is loaded

Most fields are autofocusable. Typically, you should aim for the first significant field in your schema to be autofocused for the best user experience. You can nominate a field to be autofocused using the `autofocus()` method:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('name')
    ->autofocus()
```

Optionally, you may pass a boolean value to control if the field should be autofocused or not:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('name')
    ->autofocus(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `autofocus()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Setting the placeholder of a field

Many fields can display a placeholder for when they have no value. This is displayed in the UI but never saved when the form is submitted. You may customize this placeholder using the `placeholder()` method:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('name')
    ->placeholder('John Doe')
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `placeholder()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/placeholder" alt="Form field with placeholder" version="4.x" />

## Fusing fields together into a group

A `FusedGroup` component can be used to "fuse" multiple fields together. The following fields can be fused together the best:

- [Text input](text-input)
- [Select](select)
- [Date-time picker](date-time-picker)
- [Color picker](color-picker)

The fields that should be fused are passed to the `make()` method of the `FusedGroup` component:

```php
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\FusedGroup;

FusedGroup::make([
    TextInput::make('city')
        ->placeholder('City'),
    Select::make('country')
        ->placeholder('Country')
        ->options([
            // ...
        ]),
])
```

<AutoScreenshot name="forms/fields/fused" alt="Fused group of form fields" version="4.x" />

You can add a label above the group of fields using the `label()` method:

```php
use Filament\Schemas\Components\FusedGroup;

FusedGroup::make([
    // ...
])
    ->label('Location')
```

<AutoScreenshot name="forms/fields/fused-label" alt="Fused group of form fields with label" version="4.x" />

By default, each field will have its own row. On mobile devices, this is often the most optimal experience, but on desktop you can use the `columns()` method, the same as for [layout components](../schemas/layouts#grid-system) to display the fields horizontally:

```php
use Filament\Schemas\Components\FusedGroup;

FusedGroup::make([
    // ...
])
    ->label('Location')
    ->columns(2)
```

<AutoScreenshot name="forms/fields/fused-columns" alt="Fused group of form fields in columns" version="4.x" />

You can adjust the width of the fields in the grid by passing `columnSpan()` to each field:

```php
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\FusedGroup;

FusedGroup::make([
    TextInput::make('city')
        ->placeholder('City')
        ->columnSpan(2),
    Select::make('country')
        ->placeholder('Country')
        ->options([
            // ...
        ]),
])
    ->label('Location')
    ->columns(3)
```

<AutoScreenshot name="forms/fields/fused-columns-span" alt="Fused group of form fields in columns with customized span" version="4.x" />

## Adding extra content to a field

Fields contain many "slots" where content can be inserted in a child schema. Slots can accept text, [any schema component](../schemas), [actions](../actions) and [action groups](../actions/grouping-actions). Usually, [prime components](../schemas/primes) are used for content.

The following slots are available for all fields:

- `aboveLabel()`
- `beforeLabel()`
- `afterLabel()`
- `belowLabel()`
- `aboveContent()`
- `beforeContent()`
- `afterContent()`
- `belowContent()`
- `aboveErrorMessage()`
- `belowErrorMessage()`

<UtilityInjection set="formFields" version="4.x">As well as allowing static values, the slot methods also accept functions to dynamically calculate them. You can inject various utilities into the functions as parameters.</UtilityInjection>

To insert plain text, you can pass a string to these methods:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('name')
    ->belowContent('This is the user\'s full name.')
```

<AutoScreenshot name="forms/fields/below-content/text" alt="Form field with text below content" version="4.x" />

To insert a schema component, often a [prime component](../schemas/primes), you can pass the component to the method:

```php
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Text;
use Filament\Support\Enums\FontWeight;

TextInput::make('name')
    ->belowContent(Text::make('This is the user\'s full name.')->weight(FontWeight::Bold))
```

<AutoScreenshot name="forms/fields/below-content/component" alt="Form field with component below content" version="4.x" />

To insert an [action](../actions) or [action group](../actions/grouping-actions), you can pass the action or action group to the method:

```php
use Filament\Actions\Action;
use Filament\Forms\Components\TextInput;

TextInput::make('name')
    ->belowContent(Action::make('generate'))
```

<AutoScreenshot name="forms/fields/below-content/action" alt="Form field with action below content" version="4.x" />

You can insert any combination of content into the slots by passing an array of content to the method:

```php
use Filament\Actions\Action;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Icon;
use Filament\Support\Icons\Heroicon;

TextInput::make('name')
    ->belowContent([
        Icon::make(Heroicon::InformationCircle),
        'This is the user\'s full name.',
        Action::make('generate'),
    ])
```

<AutoScreenshot name="forms/fields/below-content" alt="Form field with multiple components below content" version="4.x" />

You can also align the content in the slots by passing the array of content to either `Schema::start()` (default), `Schema::end()` or `Schema::between()`:

```php
use Filament\Actions\Action;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Flex;
use Filament\Schemas\Components\Icon;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;

TextInput::make('name')
    ->belowContent(Schema::end([
        Icon::make(Heroicon::InformationCircle),
        'This is the user\'s full name.',
        Action::make('generate'),
    ]))

TextInput::make('name')
    ->belowContent(Schema::between([
        Icon::make(Heroicon::InformationCircle),
        'This is the user\'s full name.',
        Action::make('generate'),
    ]))

TextInput::make('name')
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

<AutoScreenshot name="forms/fields/below-content/alignment" alt="Form field with aligned components below content" version="4.x" />

### Adding extra content above a field's label

You can insert extra content above a field's label using the `aboveLabel()` method. You can [pass any content](#adding-extra-content-to-a-field) to this method, like text, a schema component, an action, or an action group:

```php
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Icon;
use Filament\Support\Icons\Heroicon;

TextInput::make('name')
    ->aboveLabel([
        Icon::make(Heroicon::Star),
        'This is the content above the field\'s label'
    ])
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `aboveLabel()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/above-label" alt="Form field with extra content above label" version="4.x" />

### Adding extra content before a field's label

You can insert extra content before a field's label using the `beforeLabel()` method. You can [pass any content](#adding-extra-content-to-a-field) to this method, like text, a schema component, an action, or an action group:

```php
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Icon;
use Filament\Support\Icons\Heroicon;

TextInput::make('name')
    ->beforeLabel(Icon::make(Heroicon::Star))
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `beforeLabel()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/before-label" alt="Form field with extra content before label" version="4.x" />

### Adding extra content after a field's label

You can insert extra content after a field's label using the `afterLabel()` method. You can [pass any content](#adding-extra-content-to-a-field) to this method, like text, a schema component, an action, or an action group:

```php
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Icon;
use Filament\Support\Icons\Heroicon;

TextInput::make('name')
    ->afterLabel([
        Icon::make(Heroicon::Star),
        'This is the content after the field\'s label'
    ])
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `afterLabel()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/after-label" alt="Form field with extra content after label" version="4.x" />

By default, the content in the `afterLabel()` schema is aligned to the end of the container. If you wish to align it to the start of the container, you should pass a `Schema::start()` object containing the content:

```php
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Icon;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;

TextInput::make('name')
    ->afterLabel(Schema::start([
        Icon::make(Heroicon::Star),
        'This is the content after the field\'s label'
    ]))
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `afterLabel()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/after-label/aligned-start" alt="Form field with extra content after label aligned to the start" version="4.x" />

### Adding extra content below a field's label

You can insert extra content below a field's label using the `belowLabel()` method. You can [pass any content](#adding-extra-content-to-a-field) to this method, like text, a schema component, an action, or an action group:

```php
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Icon;
use Filament\Support\Icons\Heroicon;

TextInput::make('name')
    ->belowLabel([
        Icon::make(Heroicon::Star),
        'This is the content below the field\'s label'
    ])
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `belowLabel()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/below-label" alt="Form field with extra content below label" version="4.x" />

<Aside variant="info">
    This may seem like the same as the [`aboveContent()` method](#adding-extra-content-above-a-fields-content). However, when using [inline labels](#inline-labels), the `aboveContent()` method will place the content above the field, not below the label, since the label is displayed in a separate column to the field content.
</Aside>

### Adding extra content above a field's content

You can insert extra content above a field's content using the `aboveContent()` method. You can [pass any content](#adding-extra-content-to-a-field) to this method, like text, a schema component, an action, or an action group:

```php
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Icon;
use Filament\Support\Icons\Heroicon;

TextInput::make('name')
    ->aboveContent([
        Icon::make(Heroicon::Star),
        'This is the content above the field\'s content'
    ])
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `aboveContent()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/above-content" alt="Form field with extra content above content" version="4.x" />

<Aside variant="info">
    This may seem like the same as the [`belowLabel()` method](#adding-extra-content-below-a-fields-label). However, when using [inline labels](#inline-labels), the `belowLabel()` method will place the content below the label, not above the field's content, since the label is displayed in a separate column to the field content.
</Aside>

### Adding extra content before a field's content

You can insert extra content before a field's content using the `beforeContent()` method. You can [pass any content](#adding-extra-content-to-a-field) to this method, like text, a schema component, an action, or an action group:

```php
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Icon;
use Filament\Support\Icons\Heroicon;

TextInput::make('name')
    ->beforeContent(Icon::make(Heroicon::Star))
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `beforeContent()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/before-content" alt="Form field with extra content before content" version="4.x" />

<Aside variant="tip">
    Some fields, such as the [text input](text-input#adding-affix-text-aside-the-field), [select](select#adding-affix-text-aside-the-field), and [date-time picker](date-time-picker#adding-affix-text-aside-the-field) fields, have a `prefix()` method to insert content before the field's content, adjoined to the field itself. This is often a better UI choice than using `beforeContent()`.

    <AutoScreenshot name="forms/fields/text-input/affix" alt="Text input with affixes" version="4.x" />
</Aside>

### Adding extra content after a field's content

You can insert extra content after a field's content using the `afterContent()` method. You can [pass any content](#adding-extra-content-to-a-field) to this method, like text, a schema component, an action, or an action group:

```php
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Icon;
use Filament\Support\Icons\Heroicon;

TextInput::make('name')
    ->afterContent(Icon::make(Heroicon::Star))
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `afterContent()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/after-content" alt="Form field with extra content after content" version="4.x" />

<Aside variant="tip">
    Some fields, such as the [text input](text-input#adding-affix-text-aside-the-field), [select](select#adding-affix-text-aside-the-field), and [date-time picker](date-time-picker#adding-affix-text-aside-the-field) fields, have a `suffix()` method to insert content after the field's content, adjoined to the field itself. This is often a better UI choice than using `beforeContent()`.

    <AutoScreenshot name="forms/fields/text-input/affix" alt="Text input with affixes" version="4.x" />
</Aside>

### Adding extra content above a field's error message

You can insert extra content above a field's [error message](validation) using the `aboveErrorMessage()` method. It will not be visible unless an error message is displayed. You can [pass any content](#adding-extra-content-to-a-field) to this method, like text, a schema component, an action, or an action group:

```php
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Icon;
use Filament\Support\Icons\Heroicon;

TextInput::make('name')
    ->required()
    ->aboveErrorMessage([
        Icon::make(Heroicon::Star),
        'This is the content above the field\'s error message'
    ])
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `aboveErrorMessage()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/above-error-message" alt="Form field with extra content above error message" version="4.x" />

### Adding extra content below a field's error message

You can insert extra content below a field's [error message](validation) using the `belowErrorMessage()` method. It will not be visible unless an error message is displayed. You can [pass any content](#adding-extra-content-to-a-field) to this method, like text, a schema component, an action, or an action group:

```php
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Icon;
use Filament\Support\Icons\Heroicon;

TextInput::make('name')
    ->required()
    ->belowErrorMessage([
        Icon::make(Heroicon::Star),
        'This is the content below the field\'s error message'
    ])
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `belowErrorMessage()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/below-error-message" alt="Form field with extra content below error message" version="4.x" />

## Adding extra HTML attributes to a field

You can pass extra HTML attributes to the field via the `extraAttributes()` method, which will be merged onto its outer HTML element. The attributes should be represented by an array, where the key is the attribute name and the value is the attribute value:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('name')
    ->extraAttributes(['title' => 'Text input'])
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `extraAttributes()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<Aside variant="tip">
    By default, calling `extraAttributes()` multiple times will overwrite the previous attributes. If you wish to merge the attributes instead, you can pass `merge: true` to the method.
</Aside>

### Adding extra HTML attributes to the input element of a field

Some fields use an underlying `<input>` or `<select>` DOM element, but this is often not the outer element in the field, so the `extraAttributes()` method may not work as you wish. In this case, you may use the `extraInputAttributes()` method, which will merge the attributes onto the `<input>` or `<select>` element in the field's HTML:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('categories')
    ->extraInputAttributes(['width' => 200])
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `extraInputAttributes()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<Aside variant="tip">
    By default, calling `extraInputAttributes()` multiple times will overwrite the previous attributes. If you wish to merge the attributes instead, you can pass `merge: true` to the method.
</Aside>

### Adding extra HTML attributes to the field wrapper

You can also pass extra HTML attributes to the very outer element of the "field wrapper" which surrounds the label and content of the field. This is useful if you want to style the label or spacing of the field via CSS, since you could target elements as children of the wrapper:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('categories')
    ->extraFieldWrapperAttributes(['class' => 'components-locked'])
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `extraFieldWrapperAttributes()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<Aside variant="tip">
    By default, calling `extraFieldWrapperAttributes()` multiple times will overwrite the previous attributes. If you wish to merge the attributes instead, you can pass `merge: true` to the method.
</Aside>

## Field utility injection

The vast majority of methods used to configure fields accept functions as parameters instead of hardcoded values:

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
        return User::query()->pluck('name', 'id')->all();
    })

TextInput::make('middle_name')
    ->required(fn (): bool => auth()->user()->hasMiddleName())
```

This alone unlocks many customization possibilities.

The package is also able to inject many utilities to use inside these functions, as parameters. All customization methods that accept functions as arguments can inject utilities.

These injected utilities require specific parameter names to be used. Otherwise, Filament doesn't know what to inject.

### Injecting the current state of the field

If you wish to access the current value (state) of the field, define a `$state` parameter:

```php
function ($state) {
    // ...
}
```

#### Injecting the raw state of the field

If a field casts its state automatically to a more useful format, you may wish to access the raw state. To do this, define a `$rawState` parameter:

```php
function ($rawState) {
    // ...
}
```

### Injecting the state of another field

You may also retrieve the state (value) of another field from within a callback, using a `$get` parameter:

```php
use Filament\Schemas\Components\Utilities\Get;

function (Get $get) {
    $email = $get('email'); // Store the value of the `email` field in the `$email` variable.
    //...
}
```

<Aside variant="tip">
    Unless a form field is [reactive](#the-basics-of-reactivity), the schema will not refresh when the value of the field changes, only when the next user interaction occurs that makes a request to the server. If you need to react to changes in a field's value, it should be `live()`.
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

### Injecting the current field instance

If you wish to access the current component instance, define a `$component` parameter:

```php
use Filament\Forms\Components\Field;

function (Field $component) {
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

### Using JavaScript to determine text content

Methods that allow HTML to be rendered, such as [`label()`](#setting-a-fields-label) and [`Text::make()` passed to a `belowContent()` method](#adding-extra-content-to-a-field) can use JavaScript to calculate their content instead. This is achieved by passing a `JsContent` object to the method, which is `Htmlable`:

```php
use Filament\Forms\Components\TextInput;
use Filament\Schemas\JsContent;

TextInput::make('greetingResponse')
    ->label(JsContent::make(<<<'JS'
        ($get('name') === 'John Doe') ? 'Hello, John!' : 'Hello, stranger!'
        JS
    ))
```

The [`$state`](#injecting-the-current-state-of-the-field) and [`$get`](#injecting-the-state-of-another-field) utilities are available in this JavaScript context, so you can use them to access the state of the field and other fields in the schema.

## The basics of reactivity

[Livewire](https://livewire.laravel.com) is a tool that allows Blade-rendered HTML to dynamically re-render without requiring a full page reload. Filament schemas are built on top of Livewire, so they are able to re-render dynamically, allowing their content to adapt after they are initially rendered.

By default, when a user uses a field, the schema will not re-render. Since rendering requires a round-trip to the server, this is a performance optimization. However, if you wish to re-render the schema after the user has interacted with a field, you can use the `live()` method:

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

In this example, when the user changes the value of the `status` field, the schema will re-render. This allows you to then make changes to fields in the schema based on the new value of the `status` field. Also, you can [hook in to the field's lifecycle](#field-updates) to perform custom logic when the field is updated.

### Reactive fields on blur

By default, when a field is set to `live()`, the schema will re-render every time the field is interacted with. However, this may not be appropriate for some fields like the text input, since making network requests while the user is still typing results in suboptimal performance. You may wish to re-render the schema only after the user has finished using the field, when it becomes out of focus. You can do this using the `live(onBlur: true)` method:

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
    ->live(debounce: 500) // Wait 500ms before re-rendering the schema.
```

In this example, `500` is the number of milliseconds to wait before sending a network request. You can customize this number to whatever you want, or even use a string like `'1s'`.

## Field lifecycle

Each field in a schema has a lifecycle, which is the process it goes through when the schema is loaded, when it is interacted with by the user, and when it is submitted. You may customize what happens at each stage of this lifecycle using a function that gets run at that stage.

### Field hydration

Hydration is the process that fills fields with data. It runs when you call the schema's `fill()` method. You may customize what happens after a field is hydrated using the `afterStateHydrated()` method.

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

You may use the `afterStateUpdated()` method to customize what happens after the user updates a field:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('name')
    ->afterStateUpdated(function (?string $state, ?string $old) {
        // ...
    })
```

<UtilityInjection set="formFields" version="4.x" extras="Old state;;mixed;;$old;;The old value of the field, before it was updated.||Old raw state;;mixed;;$oldRaw;;The old value of the field, before state casts were applied.||Set function;;Filament\Schemas\Components\Utilities\Set;;$set;;A function to set values in the current form data.">The `afterStateUpdated()` method injects various utilities into the function as parameters.</UtilityInjection>

<Aside variant="tip">
    When using `afterStateUpdated()` on a reactive field, interactions will not feel instant since a network request is made. There are a few ways you can [optimize and avoid rendering](#field-rendering) which will make the interaction feel faster.
</Aside>

#### Setting the state of another field

In a similar way to `$get`, you may also set the value of another field from within `afterStateUpdated()`, using a `$set` parameter:

```php
use Filament\Schemas\Components\Utilities\Set;

function (Set $set) {
    $set('title', 'Blog Post'); // Set the `title` field to `Blog Post`.
    //...
}
```

When this function is run, the state of the `title` field will be updated, and the schema will re-render with the new title.

By default, the `afterStateUpdated()` method of the field you set is not called when you use `$set()`. If you wish to call it, you can pass `shouldCallUpdatedHooks: true` as an argument:

```php
use Filament\Schemas\Components\Utilities\Set;

function (Set $set) {
    $set('title', 'Blog Post', shouldCallUpdatedHooks: true);
    //...
}
```

### Field dehydration

Dehydration is the process that gets data from the fields in your schemas, optionally transforms it, and returns it. It runs when you call the schema's `getState()` method, which is usually called when a form is submitted.

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

If your schema auto-saves data to the database, like in a [resource](../resources), this is useful to prevent a field from being saved to the database if it is purely used for presentational purposes.

<Aside variant="info">
    Even when a field is not dehydrated, it is still validated. To learn more about this behavior, see the [validation](validation#disabling-validation-when-fields-are-not-dehydrated) section.
</Aside>

### Field rendering

Each time a reactive field is updated, the HTML entire Livewire component that the schema belongs to is re-generated and sent to the frontend via a network request. In some cases, this may be overkill, especially if the schema is large and only certain components have changed.

#### Field partial rendering

In this example, the value of the "name" input is used in the label of the "email" input. The "name" input is [`live()`](#the-basics-of-reactivity), so when the user types in the "name" input, the entire schema is re-rendered. This is not ideal, since only the "email" input needs to be re-rendered:

```php
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Utilities\Get;

TextInput::make('name')
    ->live()
    
TextInput::make('email')
    ->label(fn (Get $get): string => filled($get('name')) ? "Email address for {$get('name')}" : 'Email address')
```

In this case, a simple call to `partiallyRenderComponentsAfterStateUpdated()`, passing the names of other fields to re-render, will make the schema re-render only the specified fields [after the state is updated](#field-updates):

```php
use Filament\Forms\Components\TextInput;

TextInput::make('name')
    ->live()
    ->partiallyRenderComponentsAfterStateUpdated(['email'])
```

Alternatively, you can instruct Filament to re-render the current component only, using `partiallyRenderAfterStateUpdated()`. This is useful if the reactive component is the only one that depends on its current state:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('name')
    ->live()
    ->partiallyRenderAfterStateUpdated()
    ->belowContent(fn (Get $get): ?string => filled($get('name')) ? "Hi, {$get('name')}!" : null)
```

#### Preventing the Livewire component from rendering after a field is updated

If you wish to prevent the Livewire component from re-rendering when a field is [updated](#field-updates), you can use the `skipRenderAfterStateUpdated()` method. This is useful if you want to perform some action when the field is updated, but you don't want the Livewire component to re-render:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('name')
    ->live()
    ->skipRenderAfterStateUpdated()
    ->afterStateUpdated(function (string $state) {
        // Do something with the state, but don't re-render the Livewire component.
    })
```

Since [setting the state of another field](#setting-the-state-of-another-field) from an `afterStateUpdated()` function using the `$set()` method will actually just mutate the frontend state of fields, you don't even need a network request in the first place. The `afterStateUpdatedJs()` method accepts a JavaScript expression that runs each time the value of the field changes. The [`$state`](#injecting-the-current-state-of-the-field), [`$get()`](#injecting-the-state-of-another-field) and [`$set()`](#setting-the-state-of-another-field) utilities are available in the JavaScript context, so you can use them to set the state of other fields:

```php
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Utilities\Set;

// Old name input that is `live()`, so it makes a network request and render each time it is updated.
TextInput::make('name')
    ->live()
    ->afterStateUpdated(fn (Set $set, ?string $state) => $set('email', ((string) str($state)->replace(' ', '.')->lower()) . '@example.com'))

// New name input that uses `afterStateUpdatedJs()` to set the state of the email field and doesn't make a network request.
TextInput::make('name')
    ->afterStateUpdatedJs(<<<'JS'
        $set('email', ($state ?? '').replaceAll(' ', '.').toLowerCase() + '@example.com')
        JS)
    
TextInput::make('email')
    ->label('Email address')
```

<Aside variant="danger">
    Any JS string passed to the `afterStateUpdatedJs()` method will be executed in the browser, so you should never add user input directly into the string, as it could lead to cross-site scripting (XSS) vulnerabilities. User input from `$state` or `$get()` should never be evaluated as JavaScript code, but is safe to use as a string value, like in the example above.
</Aside>

## Reactive forms cookbook

This section contains a collection of recipes for common tasks you may need to perform when building an advanced form.

### Conditionally hiding a field

To conditionally hide or show a field, you can pass a function to the `hidden()` method, and return `true` or `false` depending on whether you want the field to be hidden or not. The function can [inject utilities](#field-utility-injection) as parameters, so you can do things like check the value of another field:

```php
use Filament\Schemas\Components\Utilities\Get;
use Filament\Forms\Components\Checkbox;
use Filament\Forms\Components\TextInput;

Checkbox::make('is_company')
    ->live()

TextInput::make('company_name')
    ->hidden(fn (Get $get): bool => ! $get('is_company'))
```

In this example, the `is_company` checkbox is [`live()`](#the-basics-of-reactivity). This allows the schema to rerender when the value of the `is_company` field changes. You can access the value of that field from within the `hidden()` function using the [`$get()` utility](#injecting-the-state-of-another-field). The value of the field is inverted using `!` so that the `company_name` field is hidden when the `is_company` field is `false`.

Alternatively, you can use the `visible()` method to show a field conditionally. It does the exact inverse of `hidden()`, and could be used if you prefer the clarity of the code when written this way:

```php
use Filament\Schemas\Components\Utilities\Get;
use Filament\Forms\Components\Checkbox;
use Filament\Forms\Components\TextInput;

Checkbox::make('is_company')
    ->live()
    
TextInput::make('company_name')
    ->visible(fn (Get $get): bool => $get('is_company'))
```

<Aside variant="tip">
    Using `live()` means the schema reloads every time the field changes, triggering a network request.
    Alternatively, you can use [JavaScript to hide the field based on another field's value](#hiding-a-field-using-javascript).
</Aside>

### Conditionally making a field required

To conditionally make a field required, you can pass a function to the `required()` method, and return `true` or `false` depending on whether you want the field to be required or not. The function can [inject utilities](#field-utility-injection) as parameters, so you can do things like check the value of another field:

```php
use Filament\Schemas\Components\Utilities\Get;
use Filament\Forms\Components\TextInput;

TextInput::make('company_name')
    ->live(onBlur: true)
    
TextInput::make('vat_number')
    ->required(fn (Get $get): bool => filled($get('company_name')))
```

In this example, the `company_name` field is [`live(onBlur: true)`](#reactive-fields-on-blur). This allows the schema to rerender after the value of the `company_name` field changes and the user clicks away. You can access the value of that field from within the `required()` function using the [`$get()` utility](#injecting-the-state-of-another-field). The value of the field is checked using `filled()` so that the `vat_number` field is required when the `company_name` field is not `null` or an empty string. The result is that the `vat_number` field is only required when the `company_name` field is filled in.

Using a function is able to make any other [validation rule](validation) dynamic in a similar way.

### Generating a slug from a title

To generate a slug from a title while the user is typing, you can use the [`afterStateUpdated()` method](#field-updates) on the title field to [`$set()`](#setting-the-state-of-another-field) the value of the slug field:

```php
use Filament\Schemas\Components\Utilities\Set;
use Filament\Forms\Components\TextInput;
use Illuminate\Support\Str;

TextInput::make('title')
    ->live(onBlur: true)
    ->afterStateUpdated(fn (Set $set, ?string $state) => $set('slug', Str::slug($state)))
    
TextInput::make('slug')
```

In this example, the `title` field is [`live(onBlur: true)`](#reactive-fields-on-blur). This allows the schema to rerender when the value of the `title` field changes and the user clicks away. The `afterStateUpdated()` method is used to run a function after the state of the `title` field is updated. The function injects the [`$set()` utility](#setting-the-state-of-another-field) and the new state of the `title` field. The `Str::slug()` utility method is part of Laravel and is used to generate a slug from a string. The `slug` field is then updated using the `$set()` function.

One thing to note is that the user may customize the slug manually, and we don't want to overwrite their changes if the title changes. To prevent this, we can use the old version of the title to work out if the user has modified it themselves. To access the old version of the title, you can inject `$old`, and to get the current value of the slug before it gets changed, we can use the [`$get()` utility](#injecting-the-state-of-another-field):

```php
use Filament\Schemas\Components\Utilities\Get;
use Filament\Schemas\Components\Utilities\Set;
use Filament\Forms\Components\TextInput;
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

To dynamically update the options of a [select field](select) based on the value of another field, you can pass a function to the `options()` method of the select field. The function can [inject utilities](#field-utility-injection) as parameters, so you can do things like check the value of another field using the [`$get()` utility](#injecting-the-state-of-another-field):

```php
use Filament\Schemas\Components\Utilities\Get;
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

In this example, the `category` field is [`live()`](#the-basics-of-reactivity). This allows the schema to rerender when the value of the `category` field changes. You can access the value of that field from within the `options()` function using the [`$get()` utility](#injecting-the-state-of-another-field). The value of the field is used to determine which options should be available in the `sub_category` field. The `match ()` statement in PHP is used to return an array of options based on the value of the `category` field. The result is that the `sub_category` field will only show options relevant to the selected `category` field.

You could adapt this example to use options loaded from an Eloquent model or other data source, by querying within the function:

```php
use Filament\Schemas\Components\Utilities\Get;
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

You may wish to render a different set of fields based on the value of a field, like a select. To do this, you can pass a function to the `schema()` method of any [layout component](../schemas/layouts), which checks the value of the field and returns a different schema based on that value. Also, you will need a way to initialise the new fields in the dynamic schema when they are first loaded.

```php
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Utilities\Get;

Select::make('type')
    ->options([
        'employee' => 'Employee',
        'freelancer' => 'Freelancer',
    ])
    ->live()
    ->afterStateUpdated(fn (Select $component) => $component
        ->getContainer()
        ->getComponent('dynamicTypeFields')
        ->getChildSchema()
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

In this example, the `type` field is [`live()`](#the-basics-of-reactivity). This allows the schema to rerender when the value of the `type` field changes. The `afterStateUpdated()` method is used to run a function after the state of the `type` field is updated. In this case, we [inject the current select field instance](#injecting-the-current-field-instance), which we can then use to get the schema "container" instance that holds both the select and the grid components. With this container, we can target the grid component using a unique key (`dynamicTypeFields`) that we have assigned to it. With that grid component instance, we can call `fill()`, just as we do on a normal form to initialise it. The `schema()` method of the grid component is then used to return a different schema based on the value of the `type` field. This is done by using the [`$get()` utility](#injecting-the-state-of-another-field), and returning a different schema array dynamically.

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

But if your schema is used to change an existing password, you don't want to overwrite the existing password if the field is empty. You can [prevent the field from being dehydrated](#preventing-a-field-from-being-dehydrated) if the field is null or an empty string (using the `filled()` helper):

```php
use Filament\Forms\Components\TextInput;
use Illuminate\Support\Facades\Hash;

TextInput::make('password')
    ->password()
    ->dehydrateStateUsing(fn (string $state): string => Hash::make($state))
    ->dehydrated(fn (?string $state): bool => filled($state))
```

However, you want to require the password to be filled when the user is being created, by [injecting the `$operation` utility](#injecting-the-current-operation), and then [conditionally making the field required](#conditionally-making-a-field-required):

```php
use Filament\Forms\Components\TextInput;
use Illuminate\Support\Facades\Hash;

TextInput::make('password')
    ->password()
    ->dehydrateStateUsing(fn (string $state): string => Hash::make($state))
    ->dehydrated(fn (?string $state): bool => filled($state))
    ->required(fn (string $operation): bool => $operation === 'create')
```

<Aside variant="info">
    In this example, `Hash::make($state)` shows how to use a [dehydration function](#field-dehydration). However, you don't need to do this if your Model uses `'password' => 'hashed'` in its [casts function — Laravel will handle hashing automatically](https://laravel.com/docs/eloquent-mutators#attribute-casting).
</Aside>

## Saving data to relationships

As well as being able to give structure to fields, [layout components](../schemas/layouts) are also able to "teleport" their nested fields into a relationship. Filament will handle loading data from a `HasOne`, `BelongsTo` or `MorphOne` Eloquent relationship, and then it will save the data back to the same relationship. To set this behavior up, you can use the `relationship()` method on any layout component:

```php
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Fieldset;

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
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Group;

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

### Saving data to a `BelongsTo` or `MorphTo` relationship

Please note that if you are saving the data to a `BelongsTo` or `MorphTo` relationship, then the foreign key column in your database must be `nullable()`. This is because Filament saves the schema first, before saving the relationship. Since the schema is saved first, the foreign ID does not exist yet, so it must be nullable. Immediately after the schema is saved, Filament saves the relationship, which will then fill in the foreign ID and save it again.

It is worth noting that if you have an observer on your schema model, then you may need to adapt it to ensure that it does not depend on the relationship existing when it is created. For example, if you have an observer that sends an email to a related record when a schema is created, you may need to switch to using a different hook that runs after the relationship is attached, like `updated()`.

#### Specifying the related model for a `MorphTo` relationship

If you are using a `MorphTo` relationship, and you want Filament to be able to create `MorphTo` records instead of just updating them, you need to specify the related model using the `relatedModel` parameter of the `relationship()` method:

```php
use App\Models\Organization;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Group;

Group::make()
    ->relationship('customer', relatedModel: Organization::class)
    ->schema([
        // ...
    ])
```

In this example, `customer` is a `MorphTo` relationship, and could be an `Individual` or `Organization`. By specifying the `relatedModel` parameter, Filament will be able to create `Organization` records when the form is submitted. If you do not specify this parameter, Filament will only be able to update existing records.

<UtilityInjection set="formFields" version="4.x">The `relatedModel` parameter also accepts a function that returns the related model class name. This is useful if you want to dynamically determine the related model based on the current state of the form. You can inject various utilities into this function.</UtilityInjection>

### Conditionally saving data to a relationship

Sometimes, saving the related record may be optional. If the user fills out the customer fields, then the customer will be created / updated. Otherwise, the customer will not be created, or will be deleted if it already exists. To do this, you can pass a `condition` function as an argument to `relationship()`, which can use the `$state` of the related form to determine whether the relationship should be saved or not:

```php
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Group;

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

# Documentation for forms. File: 02-text-input.md
---
title: Text input
---
import Aside from "@components/Aside.astro"
import AutoScreenshot from "@components/AutoScreenshot.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

The text input allows you to interact with a string:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('name')
```

<AutoScreenshot name="forms/fields/text-input/simple" alt="Text input" version="4.x" />

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

The individual type methods also allow you to pass in a boolean value to control if the field should be that or not:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('text')
    ->email(FeatureFlag::active()) // or
    ->numeric(FeatureFlag::active()) // or
    ->integer(FeatureFlag::active()) // or
    ->password(FeatureFlag::active()) // or
    ->tel(FeatureFlag::active()) // or
    ->url(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value these methods also accept a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Setting the HTML input mode

You may set the [`inputmode` attribute](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input#inputmode) of the input using the `inputMode()` method:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('text')
    ->numeric()
    ->inputMode('decimal')
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `inputMode()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Setting the numeric step

You may set the [`step` attribute](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input#step) of the input using the `step()` method:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('number')
    ->numeric()
    ->step(100)
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `step()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `autocomplete()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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
        'Volkswagen',
    ])
```

Datalists provide autocomplete options to users when they use a text input. However, these are purely recommendations, and the user is still able to type any value into the input. If you're looking to strictly limit users to a set of predefined options, check out the [select field](select).

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `datalist()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Autocapitalizing text

You may allow the text to be [autocapitalized by the browser](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input#autocapitalize) using the `autocapitalize()` method:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('name')
    ->autocapitalize('words')
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `autocapitalize()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Adding affix text aside the field

You may place text before and after the input using the `prefix()` and `suffix()` methods:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('domain')
    ->prefix('https://')
    ->suffix('.com')
```

<UtilityInjection set="formFields" version="4.x">As well as allowing static values, the `prefix()` and `suffix()` methods also accept a function to dynamically calculate them. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/text-input/affix" alt="Text input with affixes" version="4.x" />

### Using icons as affixes

You may place an [icon](../styling/icons) before and after the input using the `prefixIcon()` and `suffixIcon()` methods:

```php
use Filament\Forms\Components\TextInput;
use Filament\Support\Icons\Heroicon;

TextInput::make('domain')
    ->url()
    ->suffixIcon(Heroicon::GlobeAlt)
```

<UtilityInjection set="formFields" version="4.x">As well as allowing static values, the `prefixIcon()` and `suffixIcon()` methods also accept a function to dynamically calculate them. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/text-input/suffix-icon" alt="Text input with suffix icon" version="4.x" />

#### Setting the affix icon's color

Affix icons are gray by default, but you may set a different color using the `prefixIconColor()` and `suffixIconColor()` methods:

```php
use Filament\Forms\Components\TextInput;
use Filament\Support\Icons\Heroicon;

TextInput::make('domain')
    ->url()
    ->suffixIcon(Heroicon::CheckCircle)
    ->suffixIconColor('success')
```

<UtilityInjection set="formFields" version="4.x">As well as allowing static values, the `prefixIconColor()` and `suffixIconColor()` methods also accept a function to dynamically calculate them. You can inject various utilities into the function as parameters.</UtilityInjection>

## Revealable password inputs

When using `password()`, you can also make the input `revealable()`, so that the user can see a plain text version of the password they're typing by clicking a button:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('password')
    ->password()
    ->revealable()
```

<AutoScreenshot name="forms/fields/text-input/revealable-password" alt="Text input with revealable password" version="4.x" />

Optionally, you may pass a boolean value to control if the input should be revealable or not:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('password')
    ->password()
    ->revealable(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `revealable()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Allowing the text to be copied to the clipboard

You may make the text copyable, such that clicking on a button next to the input copies the text to the clipboard, and optionally specify a custom confirmation message and duration in milliseconds:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('apiKey')
    ->label('API key')
    ->copyable(copyMessage: 'Copied!', copyMessageDuration: 1500)
```

Optionally, you may pass a boolean value to control if the text should be copyable or not:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('apiKey')
    ->label('API key')
    ->copyable(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing static values, the `copyable()` method parameters also accept functions to dynamically calculate them. You can inject various utilities into the function as parameters.</UtilityInjection>

<Aside variant="warning">
    This feature only works when SSL is enabled for the app.
</Aside>

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

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `mask()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

Alpine.js will send the entire masked value to the server, so you may need to strip certain characters from the state before validating the field and saving it. You can do this with the `stripCharacters()` method, passing in a character or an array of characters to remove from the masked value:

```php
use Filament\Forms\Components\TextInput;
use Filament\Support\RawJs;

TextInput::make('amount')
    ->mask(RawJs::make('$money($input)'))
    ->stripCharacters(',')
    ->numeric()
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `stripCharacters()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Trimming whitespace

You can automatically trim whitespace from the beginning and end of the input value using the `trim()` method:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('name')
    ->trim()
```

You may want to enable trimming globally for all text inputs, similar to Laravel's `TrimStrings` middleware. You can do this in a service provider using the `configureUsing()` method:

```php
use Filament\Forms\Components\TextInput;

TextInput::configureUsing(function (TextInput $component): void {
    $component->trim();
});
```

## Making the field read-only

Not to be confused with [disabling the field](overview#disabling-a-field), you may make the field "read-only" using the `readOnly()` method:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('name')
    ->readOnly()
```

There are a few differences, compared to [`disabled()`](overview#disabling-a-field):

- When using `readOnly()`, the field will still be sent to the server when the form is submitted. It can be mutated with the browser console, or via JavaScript. You can use [`dehydrated(false)`](overview#preventing-a-field-from-being-dehydrated) to prevent this.
- There are no styling changes, such as less opacity, when using `readOnly()`.
- The field is still focusable when using `readOnly()`.

Optionally, you may pass a boolean value to control if the field should be read-only or not:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('name')
    ->readOnly(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `readOnly()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Text input validation

As well as all rules listed on the [validation](validation) page, there are additional rules that are specific to text inputs.

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

<UtilityInjection set="formFields" version="4.x">As well as allowing static values, the `minLength()`, `maxLength()` and `length()` methods also accept a function to dynamically calculate them. You can inject various utilities into the function as parameters.</UtilityInjection>

### Size validation

You may validate the minimum and maximum value of a numeric input by setting the `minValue()` and `maxValue()` methods:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('number')
    ->numeric()
    ->minValue(1)
    ->maxValue(100)
```

<UtilityInjection set="formFields" version="4.x">As well as allowing static values, the `minValue()` and `maxValue()` methods also accept a function to dynamically calculate them. You can inject various utilities into the function as parameters.</UtilityInjection>

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

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `telRegex()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

# Documentation for forms. File: 03-select.md
---
title: Select
---
import Aside from "@components/Aside.astro"
import AutoScreenshot from "@components/AutoScreenshot.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

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

<UtilityInjection set="formFields" version="4.x">As well as allowing a static array, the `options()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/select/simple" alt="Select" version="4.x" />

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

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `native()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/select/javascript" alt="JavaScript select" version="4.x" />

## Searching options

You may enable a search input to allow easier access to many options, using the `searchable()` method:

```php
use Filament\Forms\Components\Select;

Select::make('author_id')
    ->label('Author')
    ->options(User::query()->pluck('name', 'id'))
    ->searchable()
```

Optionally, you may pass a boolean value to control if the input should be searchable or not:

```php
use Filament\Forms\Components\Select;

Select::make('author_id')
    ->label('Author')
    ->options(User::query()->pluck('name', 'id'))
    ->searchable(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `searchable()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/select/searchable" alt="Searchable select" version="4.x" />

### Returning custom search results

If you have lots of options and want to populate them based on a database search or other external data source, you can use the `getSearchResultsUsing()` and `getOptionLabelUsing()` methods instead of `options()`.

The `getSearchResultsUsing()` method accepts a callback that returns search results in `$key => $value` format. The current user's search is available as `$search`, and you should use that to filter your results.

The `getOptionLabelUsing()` method accepts a callback that transforms the selected option `$value` into a label. This is used when the form is first loaded when the user has not made a search yet. Otherwise, the label used to display the currently selected option would not be available.

Both `getSearchResultsUsing()` and `getOptionLabelUsing()` must be used on the select if you want to provide custom search results:

```php
use Filament\Forms\Components\Select;

Select::make('author_id')
    ->searchable()
    ->getSearchResultsUsing(fn (string $search): array => User::query()
        ->where('name', 'like', "%{$search}%")
        ->limit(50)
        ->pluck('name', 'id')
        ->all())
    ->getOptionLabelUsing(fn ($value): ?string => User::find($value)?->name),
```

`getOptionLabelUsing()` is crucial, since it provides Filament with the label of the selected option, so it doesn't need to execute a full search to find it. If an option is not valid, it should return `null`.

<UtilityInjection set="formFields" version="4.x" extras="Option value;;mixed;;$value;;[<code>getOptionLabelUsing()</code> only] The option value to retrieve the label for.||Option values;;array<mixed>;;$values;;[<code>getOptionLabelsUsing()</code> only] The option values to retrieve the labels for.||Search;;?string;;$search;;[<code>getSearchResultsUsing()</code> only] The current search input value, if the field is searchable.">You can inject various utilities into these functions as parameters.</UtilityInjection>

### Setting a custom loading message

When you're using a searchable select or multi-select, you may want to display a custom message while the options are loading. You can do this using the `loadingMessage()` method:

```php
use Filament\Forms\Components\Select;

Select::make('author_id')
    ->relationship(name: 'author', titleAttribute: 'name')
    ->searchable()
    ->loadingMessage('Loading authors...')
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `loadingMessage()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Setting a custom no search results message

When you're using a searchable select or multi-select, you may want to display a custom message when no search results are found. You can do this using the `noSearchResultsMessage()` method:

```php
use Filament\Forms\Components\Select;

Select::make('author_id')
    ->relationship(name: 'author', titleAttribute: 'name')
    ->searchable()
    ->noSearchResultsMessage('No authors found.')
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `noSearchResultsMessage()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Setting a custom search prompt

When you're using a searchable select or multi-select, you may want to display a custom message when the user has not yet entered a search term. You can do this using the `searchPrompt()` method:

```php
use Filament\Forms\Components\Select;

Select::make('author_id')
    ->relationship(name: 'author', titleAttribute: 'name')
    ->searchable(['name', 'email'])
    ->searchPrompt('Search authors by their name or email address')
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `searchPrompt()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Setting a custom searching message

When you're using a searchable select or multi-select, you may want to display a custom message while the search results are being loaded. You can do this using the `searchingMessage()` method:

```php
use Filament\Forms\Components\Select;

Select::make('author_id')
    ->relationship(name: 'author', titleAttribute: 'name')
    ->searchable()
    ->searchingMessage('Searching authors...')
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `searchingMessage()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Tweaking the search debounce

By default, Filament will wait 1000 milliseconds (1 second) before searching for options when the user types in a searchable select or multi-select. It will also wait 1000 milliseconds between searches, if the user is continuously typing into the search input. You can change this using the `searchDebounce()` method:

```php
use Filament\Forms\Components\Select;

Select::make('author_id')
    ->relationship(name: 'author', titleAttribute: 'name')
    ->searchable()
    ->searchDebounce(500)
```

Ensure that you are not lowering the debounce too much, as this may cause the select to become slow and unresponsive due to a high number of network requests to retrieve options from server.

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `searchDebounce()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

Optionally, you may pass a boolean value to control if the input should be multiple or not:

```php
use Filament\Forms\Components\Select;

Select::make('technologies')
    ->multiple(FeatureFlag::active())
    ->options([
        'tailwind' => 'Tailwind CSS',
        'alpine' => 'Alpine.js',
        'laravel' => 'Laravel',
        'livewire' => 'Laravel Livewire',
    ])
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `multiple()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/select/multiple" alt="Multi-select" version="4.x" />

These options are returned in JSON format. If you're saving them using Eloquent, you should be sure to add an `array` [cast](https://laravel.com/docs/eloquent-mutators#array-and-json-casting) to the model property:

```php
use Illuminate\Database\Eloquent\Model;

class App extends Model
{
    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'technologies' => 'array',
        ];
    }

    // ...
}
```

If you're [returning custom search results](#returning-custom-search-results), you should define `getOptionLabelsUsing()` instead of `getOptionLabelUsing()`. `$values` will be passed into the callback instead of `$value`, and you should return a `$key => $value` array of labels and their corresponding values:

```php
Select::make('technologies')
    ->multiple()
    ->searchable()
    ->getSearchResultsUsing(fn (string $search): array => Technology::query()
        ->where('name', 'like', "%{$search}%")
        ->limit(50)
        ->pluck('name', 'id')
        ->all())
    ->getOptionLabelsUsing(fn (array $values): array => Technology::query()
        ->whereIn('id', $values)
        ->pluck('name', 'id')
        ->all()),
```

`getOptionLabelsUsing()` is crucial, since it provides Filament with the labels of already-selected options, so it doesn't need to execute a full search to find them. It is also used to [validate](#valid-options-validation-in-rule) that the options that the user has selected are valid. If an option is not valid, it should not be present in the array returned by `getOptionLabelsUsing()`.

<UtilityInjection set="formFields" version="4.x" extras="Option values;;array<mixed>;;$values;;[<code>getOptionLabelsUsing()</code> only] The option values to retrieve the labels for.">The `getOptionLabelsUsing()` method can inject various utilities into the function as parameters.</UtilityInjection>

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

<AutoScreenshot name="forms/fields/select/grouped" alt="Grouped select" version="4.x" />

## Integrating with an Eloquent relationship

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

<Aside variant="warning">
    When using `disabled()` with `multiple()` and `relationship()`, ensure that `disabled()` is called before `relationship()`. This ensures that the `dehydrated()` call from within `relationship()` is not overridden by the call from `disabled()`:
    
    ```php
    use Filament\Forms\Components\Select;
    
    Select::make('technologies')
        ->multiple()
        ->disabled()
        ->relationship(titleAttribute: 'name')
    ```
</Aside>

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

Optionally, you may pass a boolean value to control if the input should be preloaded or not:

```php
use Filament\Forms\Components\Select;

Select::make('author_id')
    ->relationship(name: 'author', titleAttribute: 'name')
    ->searchable()
    ->preload(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `preload()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

<UtilityInjection set="formFields" version="4.x" extras="Query;;Illuminate\Database\Eloquent\Builder;;$query;;The Eloquent query builder to modify.||Search;;?string;;$search;;The current search input value, if the field is searchable.">The `modifyQueryUsing` argument can inject various utilities into the function as parameters.</UtilityInjection>

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

<UtilityInjection set="formFields" version="4.x" extras="Eloquent record;;Illuminate\Database\Eloquent\Model;;$record;;The Eloquent record to get the option label for.">The `getOptionLabelFromRecordUsing()` method can inject various utilities into the function as parameters.</UtilityInjection>

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

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `pivotData()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

<UtilityInjection set="formFields" version="4.x" extras="Schema;;Filament\Schemas\Schema;;$schema;;The schema object for the form in the modal.">As well as allowing a static value, the `createOptionForm()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/select/create-option" alt="Select with create option button" version="4.x" />

The form opens in a modal, where the user can fill it with data. Upon form submission, the new record is selected by the field.

<AutoScreenshot name="forms/fields/select/create-option-modal" alt="Select with create option modal" version="4.x" />

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

<UtilityInjection set="formFields" version="4.x" extras="Data;;array<string, mixed>;;$data;;The data from the form in the modal.||Schema;;Filament\Schemas\Schema;;$schema;;The schema object for the form in the modal.">The `createOptionUsing()` method can inject various utilities into the function as parameters.</UtilityInjection>

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

<UtilityInjection set="formFields" version="4.x" extras="Schema;;Filament\Schemas\Schema;;$schema;;The schema object for the form in the modal.">As well as allowing a static value, the `editOptionForm()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/select/edit-option" alt="Select with edit option button" version="4.x" />

The form opens in a modal, where the user can fill it with data. Upon form submission, the data from the form is saved back to the record.

<AutoScreenshot name="forms/fields/select/edit-option-modal" alt="Select with edit option modal" version="4.x" />

#### Customizing option updates

You can customize the update process of the selected option defined in the form using the `updateOptionUsing()` method. The current Eloquent record being edited can be retrieved using the `getRecord()` method on the schema:

```php
use Filament\Forms\Components\Select;
use Filament\Schemas\Schema;

Select::make('author_id')
    ->relationship(name: 'author', titleAttribute: 'name')
    ->editOptionForm([
       // ...
    ])
    ->updateOptionUsing(function (array $data, Schema $schema) {
        $schema->getRecord()?->update($data);
    }),
```

<UtilityInjection set="formFields" version="4.x" extras="Data;;array<string, mixed>;;$data;;The data from the form in the modal.||Schema;;Filament\Schemas\Schema;;$schema;;The schema object for the form in the modal.">The `updateOptionUsing()` method can inject various utilities into the function as parameters.</UtilityInjection>

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

<UtilityInjection set="formFields" version="4.x">The `types()` method can inject various utilities into the function as parameters.</UtilityInjection>

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

<UtilityInjection set="formFields" version="4.x" extras="Eloquent query builder;;Illuminate\Database\Eloquent\Builder;;$query;;The query builder to modify.">The `modifyOptionsQueryUsing()` method can inject various utilities into the function as parameters.</UtilityInjection>

<Aside variant="tip">
    Many of the same options in the select field are available for `MorphToSelect`, including `searchable()`, `preload()`, `native()`, `allowHtml()`, and `optionsLimit()`.
</Aside>

#### Customizing the morph select fields

You may further customize the "key" select field for a specific morph type using the `modifyKeySelectUsing()` method:

```php
use Filament\Forms\Components\MorphToSelect;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;

MorphToSelect::make('commentable')
    ->types([
        MorphToSelect\Type::make(Product::class)
            ->titleAttribute('name')
            ->modifyKeySelectUsing(fn (Select $select): Select => $select
                ->createOptionForm([
                    TextInput::make('title')
                        ->required(),
                ])
                ->createOptionUsing(function (array $data): int {
                    return Product::create($data)->getKey();
                })),
        MorphToSelect\Type::make(Post::class)
            ->titleAttribute('title'),
    ])
```

This is useful if you want to customize the "key" select field for each morphed type individually. If you want to customize the key select for all types, you can use the `modifyKeySelectUsing()` method on the `MorphToSelect` component itself:

```php
use Filament\Forms\Components\MorphToSelect;
use Filament\Forms\Components\Select;

MorphToSelect::make('commentable')
    ->types([
        MorphToSelect\Type::make(Product::class)
            ->titleAttribute('name'),
        MorphToSelect\Type::make(Post::class)
            ->titleAttribute('title'),
    ])
    ->modifyKeySelectUsing(fn (Select $select): Select => $select->native())
```

You can also modify the "type" select field using the `modifyTypeSelectUsing()` method:

```php
use Filament\Forms\Components\MorphToSelect;
use Filament\Forms\Components\Select;

MorphToSelect::make('commentable')
    ->types([
        MorphToSelect\Type::make(Product::class)
            ->titleAttribute('name'),
        MorphToSelect\Type::make(Post::class)
            ->titleAttribute('title'),
    ])
    ->modifyTypeSelectUsing(fn (Select $select): Select => $select->native())
```

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

<Aside variant="danger">
    Be aware that you will need to ensure that the HTML is safe to render, otherwise your application will be vulnerable to XSS attacks.
</Aside>

Optionally, you may pass a boolean value to control if the input should allow HTML or not:

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
    ->allowHtml(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `allowHtml()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Wrap or truncate option labels

When using the JavaScript select, labels that exceed the width of the select element will wrap onto multiple lines by default. Alternatively, you may choose to truncate overflowing labels.

```php
use Filament\Forms\Components\Select;

Select::make('truncate')
    ->wrapOptionLabels(false)
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `wrapOptionLabels()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Disable placeholder selection

You can prevent the placeholder (null option) from being selected using the `selectablePlaceholder(false)` method:

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

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `selectablePlaceholder()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

<UtilityInjection set="formFields" version="4.x" extras="Option value;;mixed;;$value;;The value of the option to disable.||Option label;;string | Illuminate\Contracts\Support\Htmlable;;$label;;The label of the option to disable.">You can inject various utilities into the function as parameters.</UtilityInjection>

## Adding affix text aside the field

You may place text before and after the input using the `prefix()` and `suffix()` methods:

```php
use Filament\Forms\Components\Select;

Select::make('domain')
    ->prefix('https://')
    ->suffix('.com')
```

<UtilityInjection set="formFields" version="4.x">As well as allowing static values, the `prefix()` and `suffix()` methods also accept a function to dynamically calculate them. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/select/affix" alt="Select with affixes" version="4.x" />

### Using icons as affixes

You may place an [icon](../styling/icons) before and after the input using the `prefixIcon()` and `suffixIcon()` methods:

```php
use Filament\Forms\Components\Select;
use Filament\Support\Icons\Heroicon;

Select::make('domain')
    ->suffixIcon(Heroicon::GlobeAlt)
```

<UtilityInjection set="formFields" version="4.x">As well as allowing static values, the `prefixIcon()` and `suffixIcon()` methods also accept a function to dynamically calculate them. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/select/suffix-icon" alt="Select with suffix icon" version="4.x" />

#### Setting the affix icon's color

Affix icons are gray by default, but you may set a different color using the `prefixIconColor()` and `suffixIconColor()` methods:

```php
use Filament\Forms\Components\Select;
use Filament\Support\Icons\Heroicon;

Select::make('domain')
    ->suffixIcon(Heroicon::CheckCircle)
    ->suffixIconColor('success')
```

<UtilityInjection set="formFields" version="4.x">As well as allowing static values, the `prefixIconColor()` and `suffixIconColor()` methods also accept a function to dynamically calculate them. You can inject various utilities into the function as parameters.</UtilityInjection>

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

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `optionsLimit()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Boolean options

If you want a simple boolean select, with "Yes" and "No" options, you can use the `boolean()` method:

```php
use Filament\Forms\Components\Select;

Select::make('feedback')
    ->label('Like this post?')
    ->boolean()
```

To customize the "Yes" label, you can use the `trueLabel` argument on the `boolean()` method:

```php
use Filament\Forms\Components\Select;

Select::make('feedback')
    ->label('Like this post?')
    ->boolean(trueLabel: 'Absolutely!')
```

To customize the "No" label, you can use the `falseLabel` argument on the `boolean()` method:

```php
use Filament\Forms\Components\Select;

Select::make('feedback')
    ->label('Like this post?')
    ->boolean(falseLabel: 'Not at all!')
```

To customize the placeholder that shows when an option has not yet been selected, you can use the `placeholder` argument on the `boolean()` method:

```php
use Filament\Forms\Components\Select;

Select::make('feedback')
    ->label('Like this post?')
    ->boolean(placeholder: 'Make your mind up...')
```

## Selecting options from a table in a modal

You can use the `ModalTableSelect` component to open a Filament [table](../tables) in a modal, allowing users to select records from it. This is useful when you have a [relationship](#integrating-with-an-eloquent-relationship) that has a lot of records, and you want users to be able to perform advanced filtering and searching through them.

To use the `ModalTableSelect`, you must have a table configuration class for the model. You can generate one of these classes using the `make:filament-table` command:

```php
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class CategoriesTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('name')
                    ->searchable(),
                TextColumn::make('slug')
                    ->searchable(),
            ])
            ->filters([
                SelectFilter::make('parent')
                    ->relationship('parent', 'name')
                    ->searchable()
                    ->preload(),
            ]);
    }
}
```

The class must have a `configure()` method that accepts the `Table` object and returns it. The class name needs to be passed to the `tableConfiguration()` method of the `ModalTableSelect` component:

```php
use Filament\Forms\Components\ModalTableSelect;

ModalTableSelect::make('category_id')
    ->relationship('category', 'name')
    ->tableConfiguration(CategoriesTable::class)
```

You can also use the `multiple()` method with a multiple relationship such as `BelongsToMany`:

```php
use Filament\Forms\Components\ModalTableSelect;

ModalTableSelect::make('categories')
    ->relationship('categories', 'name')
    ->multiple()
    ->tableConfiguration(CategoriesTable::class)
```

<UtilityInjection set="formFields" version="4.x">The `tableConfiguration()` method can inject various utilities into the function as parameters.</UtilityInjection>

### Customizing the modal table select actions

You can customize the "Select" button and modal using the [action](../actions) object configuration methods. Passing a function to the `selectAction()` method allows you to modify the `$action` object, for example, to change the button label and the modal heading:

```php
use Filament\Actions\Action;
use Filament\Forms\Components\ModalTableSelect;

ModalTableSelect::make('category_id')
    ->relationship('category', 'name')
    ->tableConfiguration(CategoriesTable::class)
    ->selectAction(
        fn (Action $action) => $action
            ->label('Select a category')
            ->modalHeading('Search categories')
            ->modalSubmitActionLabel('Confirm selection'),
    )
```

<UtilityInjection set="formFields" version="4.x" extras="Action;;Filament\Actions\Action;;$action;;The action object to customize.">The `selectAction()` method can inject various utilities into the function as parameters.</UtilityInjection>

### Customizing the option labels in the modal table select

The `getOptionLabelFromRecordUsing()` method can be used to customize the label of each selected option. This is useful if you want to display a more descriptive label or concatenate two columns together:

```php
use Filament\Forms\Components\ModalTableSelect;

ModalTableSelect::make('category_id')
    ->relationship('category', 'name')
    ->tableConfiguration(CategoriesTable::class)
    ->getOptionLabelFromRecordUsing(fn (Category $record): string => "{$record->name} ({$record->slug})")
```

### Passing additional arguments to the table in a modal select

You can pass arguments from your form to the table configuration class using the `tableArguments()` method. For example, this can be used to modify the table's query based on previously filled form fields:

```php
use Filament\Actions\Action;
use Filament\Forms\Components\ModalTableSelect;
use Filament\Schemas\Components\Utilities\Get;

ModalTableSelect::make('products')
    ->relationship('products', 'name')
    ->multiple()
    ->tableConfiguration(ProductsTable::class)
    ->tableArguments(function (Get $get): array {
        return [
            'category_id' => $get('category_id'),
            'budget_limit' => $get('budget'),
        ];
    })
```

<UtilityInjection set="formFields" version="4.x">The `tableArguments()` method can inject various utilities into the function as parameters.</UtilityInjection>

In your table configuration class, you can access these arguments using the `$table->getArguments()` method:

```php
use Filament\Forms\Components\TableSelect\Livewire\TableSelectLivewireComponent;
use Filament\Tables\Columns\TextColumn;
use Illuminate\Database\Eloquent\Builder;
use Filament\Tables\Table;

class ProductsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->modifyQueryUsing(function (Builder $query) use ($table): Builder {
                $arguments = $table->getArguments();
            
                if ($categoryId = $arguments['category_id'] ?? null) {
                    $query->where('category_id', $categoryId);
                }
                
                if ($budgetLimit = $arguments['budget_limit'] ?? null) {
                    $query->where('price', '<=', $budgetLimit);
                }
                
                return $query;
            })
            ->columns([
                TextColumn::make('name'),
                TextColumn::make('price')
                    ->money(),
                TextColumn::make('category.name')
                    ->hidden(filled($table->getArguments()['category_id'])),
            ]);
    }
}
```

## Select validation

As well as all rules listed on the [validation](validation) page, there are additional rules that are specific to selects.

### Valid options validation (`in()` rule)

The [`in()`](validation#in) rule ensures that users cannot select an option that is not in the list of options. This is an important rule for data integrity purposes, so Filament applies it by default to all select fields.

<Aside variant="warning">
    Selected option validation is crucial, so we strongly suggest that you [write automated tests](../testing/testing-schemas#testing-form-validation) for your forms to ensure that the validation works as expected.
</Aside>

Since there are many ways for a select field to populate its options, and in many cases the options are not all loaded into the select by default and require searching to retrieve them, Filament uses the presence of a valid "option label" to determine whether the selected value exists. It also checks if that option is [disabled](#disabling-specific-options) or not.

If you are using a custom search query to retrieve options, you should ensure that the `getOptionLabelUsing()` method is defined, so that Filament can validate the selected value against the available options:

```php
use Filament\Forms\Components\Select;

Select::make('author_id')
    ->searchable()
    ->getSearchResultsUsing(fn (string $search): array => Author::query()
        ->where('name', 'like', "%{$search}%")
        ->limit(50)
        ->pluck('name', 'id')
        ->all())
    ->getOptionLabelUsing(fn (string $value): ?string => Author::find($value)?->name),
```

The `getOptionLabelUsing()` method should return `null` if the option is not valid, to allow Filament to determine that the selected value is not in the list of options. If the option is valid, it should return the label of the option.

If you are using a `multiple()` select or multi-select, you should define `getOptionLabelsUsing()` instead of `getOptionLabelUsing()`. `$values` will be passed into the callback instead of `$value`, and you should return a `$key => $value` array of labels and their corresponding values:

```php
use Filament\Forms\Components\Select;

Select::make('technologies')
    ->multiple()
    ->searchable()
    ->getSearchResultsUsing(fn (string $search): array => Technology::query()
        ->where('name', 'like', "%{$search}%")
        ->limit(50)
        ->pluck('name', 'id')
        ->all())
    ->getOptionLabelsUsing(fn (array $values): array => Technology::query()
        ->whereIn('id', $values)
        ->pluck('name', 'id')
        ->all()),
```

If you are using the `relationship()` method, the `getOptionLabelUsing()` or `getOptionLabelsUsing()` methods will be automatically defined for you, so you don't need to worry about them.

### Number of selected items validation

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

<UtilityInjection set="formFields" version="4.x">As well as allowing static values, the `minItems()` and `maxItems()` methods also accept a function to dynamically calculate them. You can inject various utilities into the function as parameters.</UtilityInjection>

## Customizing the select action objects

This field uses action objects for easy customization of buttons within it. You can customize these buttons by passing a function to an action registration method. The function has access to the `$action` object, which you can use to [customize it](../actions/overview) or [customize its modal](../actions/modals). The following methods are available to customize the actions:

- `createOptionAction()`
- `editOptionAction()`
- `manageOptionActions()` (for customizing both the create and edit option actions at once)

Here is an example of how you might customize an action:

```php
use Filament\Actions\Action;
use Filament\Forms\Components\Select;

Select::make('author_id')
    ->relationship(name: 'author', titleAttribute: 'name')
    ->createOptionAction(
        fn (Action $action) => $action->modalWidth('3xl'),
    )
```

<UtilityInjection set="formFields" version="4.x" extras="Action;;Filament\Actions\Action;;$action;;The action object to customize.">The action registration methods can inject various utilities into the function as parameters.</UtilityInjection>

# Documentation for forms. File: 04-checkbox.md
---
title: Checkbox
---
import AutoScreenshot from "@components/AutoScreenshot.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

The checkbox component, similar to a [toggle](toggle), allows you to interact a boolean value.

```php
use Filament\Forms\Components\Checkbox;

Checkbox::make('is_admin')
```

<AutoScreenshot name="forms/fields/checkbox/simple" alt="Checkbox" version="4.x" />

If you're saving the boolean value using Eloquent, you should be sure to add a `boolean` [cast](https://laravel.com/docs/eloquent-mutators#attribute-casting) to the model property:

```php
use Illuminate\Database\Eloquent\Model;

class User extends Model
{
    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'is_admin' => 'boolean',
        ];
    }

    // ...
}
```

## Positioning the label above

Checkbox fields have two layout modes, inline and stacked. By default, they are inline.

When the checkbox is inline, its label is adjacent to it:

```php
use Filament\Forms\Components\Checkbox;

Checkbox::make('is_admin')
    ->inline()
```

<AutoScreenshot name="forms/fields/checkbox/inline" alt="Checkbox with its label inline" version="4.x" />

When the checkbox is stacked, its label is above it:

```php
use Filament\Forms\Components\Checkbox;

Checkbox::make('is_admin')
    ->inline(false)
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `inline()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/checkbox/not-inline" alt="Checkbox with its label above" version="4.x" />

## Checkbox validation

As well as all rules listed on the [validation](validation) page, there are additional rules that are specific to checkboxes.

### Accepted validation

You may ensure that the checkbox is checked using the `accepted()` method:

```php
use Filament\Forms\Components\Checkbox;

Checkbox::make('terms_of_service')
    ->accepted()
```

Optionally, you may pass a boolean value to control if the validation rule should be applied or not:

```php
use Filament\Forms\Components\Checkbox;

Checkbox::make('terms_of_service')
    ->accepted(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `accepted()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Declined validation

You may ensure that the checkbox is not checked using the `declined()` method:

```php
use Filament\Forms\Components\Checkbox;

Checkbox::make('is_under_18')
    ->declined()
```

Optionally, you may pass a boolean value to control if the validation rule should be applied or not:

```php
use Filament\Forms\Components\Checkbox;

Checkbox::make('is_under_18')
    ->declined(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `declined()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

# Documentation for forms. File: 05-toggle.md
---
title: Toggle
---
import AutoScreenshot from "@components/AutoScreenshot.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

The toggle component, similar to a [checkbox](checkbox), allows you to interact a boolean value.

```php
use Filament\Forms\Components\Toggle;

Toggle::make('is_admin')
```

<AutoScreenshot name="forms/fields/toggle/simple" alt="Toggle" version="4.x" />

If you're saving the boolean value using Eloquent, you should be sure to add a `boolean` [cast](https://laravel.com/docs/eloquent-mutators#attribute-casting) to the model property:

```php
use Illuminate\Database\Eloquent\Model;

class User extends Model
{
    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'is_admin' => 'boolean',
        ];
    }

    // ...
}
```

## Adding icons to the toggle button

Toggles may also use an [icon](../styling/icons) to represent the "on" and "off" state of the button. To add an icon to the "on" state, use the `onIcon()` method. To add an icon to the "off" state, use the `offIcon()` method:

```php
use Filament\Forms\Components\Toggle;
use Filament\Support\Icons\Heroicon;

Toggle::make('is_admin')
    ->onIcon(Heroicon::Bolt)
    ->offIcon(Heroicon::User)
```

<UtilityInjection set="formFields" version="4.x">As well as allowing static values, the `onIcon()` and `offIcon()` methods also accept functions to dynamically calculate them. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/toggle/icons" alt="Toggle icons" version="4.x" />

## Customizing the color of the toggle button

You may also customize the [color](../styling/colors) representing the "on" or "off" state of the toggle. To add a color to the "on" state, use the `onColor()` method. To add a color to the "off" state, use the `offColor()` method:

```php
use Filament\Forms\Components\Toggle;

Toggle::make('is_admin')
    ->onColor('success')
    ->offColor('danger')
```

<UtilityInjection set="formFields" version="4.x">As well as allowing static values, the `onColor()` and `offColor()` methods also accept functions to dynamically calculate them. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/toggle/off-color" alt="Toggle off color" version="4.x" />

<AutoScreenshot name="forms/fields/toggle/on-color" alt="Toggle on color" version="4.x" />

## Positioning the label above

Toggle fields have two layout modes, inline and stacked. By default, they are inline.

When the toggle is inline, its label is adjacent to it:

```php
use Filament\Forms\Components\Toggle;

Toggle::make('is_admin')
    ->inline()
```

<AutoScreenshot name="forms/fields/toggle/inline" alt="Toggle with its label inline" version="4.x" />

When the toggle is stacked, its label is above it:

```php
use Filament\Forms\Components\Toggle;

Toggle::make('is_admin')
    ->inline(false)
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `inline()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/toggle/not-inline" alt="Toggle with its label above" version="4.x" />

## Toggle validation

As well as all rules listed on the [validation](validation) page, there are additional rules that are specific to toggles.

### Accepted validation

You may ensure that the toggle is "on" using the `accepted()` method:

```php
use Filament\Forms\Components\Toggle;

Toggle::make('terms_of_service')
    ->accepted()
```

Optionally, you may pass a boolean value to control if the validation rule should be applied or not:

```php
use Filament\Forms\Components\Toggle;

Toggle::make('terms_of_service')
    ->accepted(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `accepted()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Declined validation

You may ensure that the toggle is "off" using the `declined()` method:

```php
use Filament\Forms\Components\Toggle;

Toggle::make('is_under_18')
    ->declined()
```

Optionally, you may pass a boolean value to control if the validation rule should be applied or not:

```php
use Filament\Forms\Components\Toggle;

Toggle::make('is_under_18')
    ->declined(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `declined()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>


# Documentation for forms. File: 06-checkbox-list.md
---
title: Checkbox list
---
import Aside from "@components/Aside.astro"
import AutoScreenshot from "@components/AutoScreenshot.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

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

<UtilityInjection set="formFields" version="4.x">As well as allowing a static array, the `options()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/checkbox-list/simple" alt="Checkbox list" version="4.x" />

These options are returned in JSON format. If you're saving them using Eloquent, you should be sure to add an `array` [cast](https://laravel.com/docs/eloquent-mutators#array-and-json-casting) to the model property:

```php
use Illuminate\Database\Eloquent\Model;

class App extends Model
{
    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'technologies' => 'array',
        ];
    }

    // ...
}
```

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

<UtilityInjection set="formFields" version="4.x">As well as allowing a static array, the `descriptions()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/checkbox-list/option-descriptions" alt="Checkbox list with option descriptions" version="4.x" />

<Aside variant="info">
    Be sure to use the same `key` in the descriptions array as the `key` in the option array so the right description matches the right option.
</Aside>

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

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `columns()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/checkbox-list/columns" alt="Checkbox list with 2 columns" version="4.x" />

This method accepts the same options as the `columns()` method of the [grid](../schemas/layouts#grid-system). This allows you to responsively customize the number of columns at various breakpoints.

### Setting the grid direction

By default, when you arrange checkboxes into columns, they will be listed in order vertically. If you'd like to list them horizontally, you may use the `gridDirection(GridDirection::Row)` method:

```php
use Filament\Forms\Components\CheckboxList;
use Filament\Support\Enums\GridDirection;

CheckboxList::make('technologies')
    ->options([
        // ...
    ])
    ->columns(2)
    ->gridDirection(GridDirection::Row)
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `gridDirection()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/checkbox-list/rows" alt="Checkbox list with 2 rows" version="4.x" />

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

<AutoScreenshot name="forms/fields/checkbox-list/searchable" alt="Searchable checkbox list" version="4.x" />

Optionally, you may pass a boolean value to control if the options should be searchable or not:

```php
use Filament\Forms\Components\CheckboxList;

CheckboxList::make('technologies')
    ->options([
        // ...
    ])
    ->searchable(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `searchable()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

<AutoScreenshot name="forms/fields/checkbox-list/bulk-toggleable" alt="Bulk toggleable checkbox list" version="4.x" />

Optionally, you may pass a boolean value to control if the checkboxes should be bulk toggleable or not:

```php
use Filament\Forms\Components\CheckboxList;

CheckboxList::make('technologies')
    ->options([
        // ...
    ])
    ->bulkToggleable(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `bulkToggleable()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

<UtilityInjection set="formFields" version="4.x" extras="Option value;;mixed;;$value;;The value of the option to disable.||Option label;;string | Illuminate\Contracts\Support\Htmlable;;$label;;The label of the option to disable.">You can inject various utilities into the function as parameters.</UtilityInjection>

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

For more information about the `in()` function, please see the [Validation documentation](validation#in).

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

<Aside variant="danger">
    Be aware that you will need to ensure that the HTML is safe to render, otherwise your application will be vulnerable to XSS attacks.
</Aside>

Optionally, you may pass a boolean value to control if the options should allow HTML or not:

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
    ->allowHtml(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `allowHtml()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Integrating with an Eloquent relationship

> If you're building a form inside your Livewire component, make sure you have set up the [form's model](../components/form#setting-a-form-model). Otherwise, Filament doesn't know which model to use to retrieve the relationship from.

You may employ the `relationship()` method of the `CheckboxList` to point to a `BelongsToMany` relationship. Filament will load the options from the relationship, and save them back to the relationship's pivot table when the form is submitted. The `titleAttribute` is the name of a column that will be used to generate a label for each option:

```php
use Filament\Forms\Components\CheckboxList;

CheckboxList::make('technologies')
    ->relationship(titleAttribute: 'name')
```

<Aside variant="warning">
    When using `disabled()` with `relationship()`, ensure that `disabled()` is called before `relationship()`. This ensures that the `dehydrated()` call from within `relationship()` is not overridden by the call from `disabled()`:
    
    ```php
    use Filament\Forms\Components\CheckboxList;
    
    CheckboxList::make('technologies')
        ->disabled()
        ->relationship(titleAttribute: 'name')
    ```
</Aside>

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

<UtilityInjection set="formFields" version="4.x" extras="Query;;Illuminate\Database\Eloquent\Builder;;$query;;The Eloquent query builder to modify.">The `modifyQueryUsing` argument can inject various utilities into the function as parameters.</UtilityInjection>

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

<UtilityInjection set="formFields" version="4.x" extras="Eloquent record;;Illuminate\Database\Eloquent\Model;;$record;;The Eloquent record to get the option label for.">The `getOptionLabelFromRecordUsing()` method can inject various utilities into the function as parameters.</UtilityInjection>

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

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `pivotData()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `noSearchResultsMessage()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `searchPrompt()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `searchDebounce()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Customizing the checkbox list action objects

This field uses action objects for easy customization of buttons within it. You can customize these buttons by passing a function to an action registration method. The function has access to the `$action` object, which you can use to [customize it](../actions/overview). The following methods are available to customize the actions:

- `selectAllAction()`
- `deselectAllAction()`

Here is an example of how you might customize an action:

```php
use Filament\Actions\Action;
use Filament\Forms\Components\CheckboxList;

CheckboxList::make('technologies')
    ->options([
        // ...
    ])
    ->selectAllAction(
        fn (Action $action) => $action->label('Select all technologies'),
    )
```

<UtilityInjection set="formFields" version="4.x" extras="Action;;Filament\Actions\Action;;$action;;The action object to customize.">The action registration methods can inject various utilities into the function as parameters.</UtilityInjection>

# Documentation for forms. File: 07-radio.md
---
title: Radio
---
import Aside from "@components/Aside.astro"
import AutoScreenshot from "@components/AutoScreenshot.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

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

<UtilityInjection set="formFields" version="4.x">As well as allowing a static array, the `options()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/radio/simple" alt="Radio" version="4.x" />

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

<UtilityInjection set="formFields" version="4.x">As well as allowing a static array, the `descriptions()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/radio/option-descriptions" alt="Radio with option descriptions" version="4.x" />

<Aside variant="info">
    Be sure to use the same `key` in the descriptions array as the `key` in the option array so the right description matches the right option.
</Aside>

## Positioning the options inline with each other

You may wish to display the options `inline()` with each other:

```php
use Filament\Forms\Components\Radio;

Radio::make('feedback')
    ->label('Like this post?')
    ->boolean()
    ->inline()
```

<AutoScreenshot name="forms/fields/radio/inline" alt="Inline toggle buttons" version="4.x" />

Optionally, you may pass a boolean value to control if the options should be inline or not:

```php
use Filament\Forms\Components\Radio;

Radio::make('feedback')
    ->label('Like this post?')
    ->boolean()
    ->inline(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `inline()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

<UtilityInjection set="formFields" version="4.x" extras="Option value;;mixed;;$value;;The value of the option to disable.||Option label;;string | Illuminate\Contracts\Support\Htmlable;;$label;;The label of the option to disable.">You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/radio/disabled-option" alt="Radio with disabled option" version="4.x" />

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

For more information about the `in()` function, please see the [Validation documentation](validation#in).

## Boolean options

If you want a simple boolean radio button group, with "Yes" and "No" options, you can use the `boolean()` method:

```php
use Filament\Forms\Components\Radio;

Radio::make('feedback')
    ->label('Like this post?')
    ->boolean()
```

<AutoScreenshot name="forms/fields/radio/boolean" alt="Boolean radio" version="4.x" />

To customize the "Yes" label, you can use the `trueLabel` argument on the `boolean()` method:

```php
use Filament\Forms\Components\Radio;

Radio::make('feedback')
    ->label('Like this post?')
    ->boolean(trueLabel: 'Absolutely!')
```

To customize the "No" label, you can use the `falseLabel` argument on the `boolean()` method:

```php
use Filament\Forms\Components\Radio;

Radio::make('feedback')
    ->label('Like this post?')
    ->boolean(falseLabel: 'Not at all!')
```

# Documentation for forms. File: 08-date-time-picker.md
---
title: Date-time picker
---
import Aside from "@components/Aside.astro"
import AutoScreenshot from "@components/AutoScreenshot.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

The date-time picker provides an interactive interface for selecting a date and/or a time.

```php
use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\TimePicker;

DateTimePicker::make('published_at')
DatePicker::make('date_of_birth')
TimePicker::make('alarm_at')
```

<AutoScreenshot name="forms/fields/date-time-picker/simple" alt="Date time pickers" version="4.x" />

## Customizing the storage format

You may customize the format of the field when it is saved in your database, using the `format()` method. This accepts a string date format, using [PHP date formatting tokens](https://www.php.net/manual/en/datetime.format.php):

```php
use Filament\Forms\Components\DatePicker;

DatePicker::make('date_of_birth')
    ->format('d/m/Y')
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `format()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Disabling the seconds input

When using the time picker, you may disable the seconds input using the `seconds(false)` method:

```php
use Filament\Forms\Components\DateTimePicker;

DateTimePicker::make('published_at')
    ->seconds(false)
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `seconds()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/date-time-picker/without-seconds" alt="Date time picker without seconds" version="4.x" />

## Timezones

If you'd like users to be able to manage dates in their own timezone, you can use the `timezone()` method:

```php
use Filament\Forms\Components\DateTimePicker;

DateTimePicker::make('published_at')
    ->timezone('America/New_York')
```

While dates will still be stored using the app's configured timezone, the date will now load in the new timezone, and it will be converted back when the form is saved.

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `timezone()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

If you do not pass a `timezone()` to the component, it will use Filament's default timezone. You can set Filament's default timezone using the `FilamentTimezone::set()` method in the `boot()` method of a service provider such as `AppServiceProvider`:

```php
use Filament\Support\Facades\FilamentTimezone;

public function boot(): void
{
    FilamentTimezone::set('America/New_York');
}
```

This is useful if you want to set a default timezone for all date-time pickers in your application. It is also used in other places where timezones are used in Filament.

<Aside variant="warning">
    Filament's default timezone will only apply when the field stores a time. If the field stores a date only (`DatePicker` instead of `DateTimePicker` or `TimePicker`), the timezone will not be applied. This is to prevent timezone shifts when storing dates without times.
</Aside>

## Enabling the JavaScript date picker

By default, Filament uses the native HTML5 date picker. You may enable a more customizable JavaScript date picker using the `native(false)` method:

```php
use Filament\Forms\Components\DatePicker;

DatePicker::make('date_of_birth')
    ->native(false)
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `native()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/date-time-picker/javascript" alt="JavaScript-based date time picker" version="4.x" />

<Aside variant="info">
    The JavaScript date picker does not support full keyboard input in the same way that the native date picker does. If you require full keyboard input, you should use the native date picker.
</Aside>

### Customizing the display format

You may customize the display format of the field, separately from the format used when it is saved in your database. For this, use the `displayFormat()` method, which also accepts a string date format, using [PHP date formatting tokens](https://www.php.net/manual/en/datetime.format.php):

```php
use Filament\Forms\Components\DatePicker;

DatePicker::make('date_of_birth')
    ->native(false)
    ->displayFormat('d/m/Y')
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `displayFormat()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/date-time-picker/display-format" alt="Date time picker with custom display format" version="4.x" />

You may also configure the locale that is used when rendering the display, if you want to use different locale from your app config. For this, you can use the `locale()` method:

```php
use Filament\Forms\Components\DatePicker;

DatePicker::make('date_of_birth')
    ->native(false)
    ->displayFormat('d F Y')
    ->locale('fr')
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `locale()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

<UtilityInjection set="formFields" version="4.x">As well as allowing static values, the `hoursStep()`, `minutesStep()`, and `secondsStep()` methods also accept functions to dynamically calculate them. You can inject various utilities into the functions as parameters.</UtilityInjection>

### Configuring the first day of the week

In some countries, the first day of the week is not Monday. To customize the first day of the week in the date picker, use the `firstDayOfWeek()` method on the component. 0 to 7 are accepted values, with Monday as 1 and Sunday as 7 or 0:

```php
use Filament\Forms\Components\DateTimePicker;

DateTimePicker::make('published_at')
    ->native(false)
    ->firstDayOfWeek(7)
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `firstDayOfWeek()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/date-time-picker/week-starts-on-sunday" alt="Date time picker where the week starts on Sunday" version="4.x" />

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

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `disabledDates()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/date-time-picker/disabled-dates" alt="Date time picker where dates are disabled" version="4.x" />

### Closing the picker when a date is selected

To close the picker when a date is selected, you can use the `closeOnDateSelection()` method:

```php
use Filament\Forms\Components\DateTimePicker;

DateTimePicker::make('date')
    ->native(false)
    ->closeOnDateSelection()
```

Optionally, you may pass a boolean value to control if the input should close when a date is selected or not:

```php
use Filament\Forms\Components\DateTimePicker;

DateTimePicker::make('date')
    ->native(false)
    ->closeOnDateSelection(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `closeOnDateSelection()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `datalist()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Focusing a default calendar date

By default, if the field has no state, opening the calendar panel will open the calendar at the current date. This might not be convenient for situations where you want to open the calendar on a specific date instead. You can use the `defaultFocusedDate()` to set a default focused date on the calendar:

```php
use Filament\Forms\Components\DatePicker;

DatePicker::make('custom_starts_at')
    ->native(false)
    ->placeholder(now()->startOfMonth())
    ->defaultFocusedDate(now()->startOfMonth())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `defaultFocusedDate()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Adding affix text aside the field

You may place text before and after the input using the `prefix()` and `suffix()` methods:

```php
use Filament\Forms\Components\DatePicker;

DatePicker::make('date')
    ->prefix('Starts')
    ->suffix('at midnight')
```

<UtilityInjection set="formFields" version="4.x">As well as allowing static values, the `prefix()` and `suffix()` methods also accept a function to dynamically calculate them. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/date-time-picker/affix" alt="Date time picker with affixes" version="4.x" />

### Using icons as affixes

You may place an [icon](../styling/icons) before and after the input using the `prefixIcon()` and `suffixIcon()` methods:

```php
use Filament\Forms\Components\TimePicker;
use Filament\Support\Icons\Heroicon;

TimePicker::make('at')
    ->prefixIcon(Heroicon::Play)
```

<UtilityInjection set="formFields" version="4.x">As well as allowing static values, the `prefixIcon()` and `suffixIcon()` methods also accept a function to dynamically calculate them. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/date-time-picker/prefix-icon" alt="Date time picker with prefix icon" version="4.x" />

#### Setting the affix icon's color

Affix icons are gray by default, but you may set a different color using the `prefixIconColor()` and `suffixIconColor()` methods:

```php
use Filament\Forms\Components\TimePicker;
use Filament\Support\Icons\Heroicon;

TimePicker::make('at')
    ->prefixIcon(Heroicon::CheckCircle)
    ->prefixIconColor('success')
```

<UtilityInjection set="formFields" version="4.x">As well as allowing static values, the `prefixIconColor()` and `suffixIconColor()` methods also accept a function to dynamically calculate them. You can inject various utilities into the function as parameters.</UtilityInjection>

## Making the field read-only

Not to be confused with [disabling the field](overview#disabling-a-field), you may make the field "read-only" using the `readonly()` method:

```php
use Filament\Forms\Components\DatePicker;

DatePicker::make('date_of_birth')
    ->readonly()
```

Please note that this setting is only enforced on native date pickers. If you're using the [JavaScript date picker](#enabling-the-javascript-date-picker), you'll need to use [`disabled()`](overview#disabling-a-field).

There are a few differences, compared to [`disabled()`](overview#disabling-a-field):

- When using `readOnly()`, the field will still be sent to the server when the form is submitted. It can be mutated with the browser console, or via JavaScript. You can use [`dehydrated(false)`](overview#preventing-a-field-from-being-dehydrated) to prevent this.
- There are no styling changes, such as less opacity, when using `readOnly()`.
- The field is still focusable when using `readOnly()`.

Optionally, you may pass a boolean value to control if the field should be read-only or not:

```php
use Filament\Forms\Components\DatePicker;

DatePicker::make('date_of_birth')
    ->readOnly(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `readOnly()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Date-time picker validation

As well as all rules listed on the [validation](validation) page, there are additional rules that are specific to date-time pickers.

### Max date / min date validation

You may restrict the minimum and maximum date that can be selected with the picker. The `minDate()` and `maxDate()` methods accept a `DateTime` instance (e.g. `Carbon`), or a string:

```php
use Filament\Forms\Components\DatePicker;

DatePicker::make('date_of_birth')
    ->native(false)
    ->minDate(now()->subYears(150))
    ->maxDate(now())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing static values, the `minDate()` and `maxDate()` methods also accept functions to dynamically calculate them. If the functions return `null`, the validation rule is not applied. You can inject various utilities into the functions as parameters. </UtilityInjection>
# Documentation for forms. File: 09-file-upload.md
---
title: File upload
---
import Aside from "@components/Aside.astro"
import AutoScreenshot from "@components/AutoScreenshot.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

The file upload field is based on [Filepond](https://pqina.nl/filepond).

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('attachment')
```

<AutoScreenshot name="forms/fields/file-upload/simple" alt="File upload" version="4.x" />

<Aside variant="tip">
    Filament also supports [`spatie/laravel-medialibrary`](https://github.com/spatie/laravel-medialibrary). See our [plugin documentation](/plugins/filament-spatie-media-library) for more information.
</Aside>

## Configuring the storage disk and directory

By default, files will be uploaded to the storage disk defined in the [configuration file](../introduction/installation#publishing-configuration). You can also set the `FILESYSTEM_DISK` environment variable to change this.

<Aside variant="tip">
    To correctly preview images and other files, FilePond requires files to be served from the same domain as the app, or the appropriate CORS headers need to be present. Ensure that the `APP_URL` environment variable is correct, or modify the [filesystem](https://laravel.com/docs/filesystem) driver to set the correct URL. If you're hosting files on a separate domain like S3, ensure that CORS headers are set up.
</Aside>

To change the disk and directory for a specific field, and the visibility of files, use the `disk()`, `directory()` and `visibility()` methods. By default, files are uploaded with `private` visibility to your storage disk, unless the disk is set to `public`:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('attachment')
    ->disk('s3')
    ->directory('form-attachments')
    ->visibility('public')
```

<UtilityInjection set="formFields" version="4.x">As well as allowing static values, the `disk()`, `directory()` and `visibility()` methods accept functions to dynamically calculate them. You can inject various utilities into the functions as parameters. </UtilityInjection>

<Aside variant="info">
    It is the responsibility of the developer to delete these files from the disk if they are removed, as Filament is unaware if they are depended on elsewhere. One way to do this automatically is observing a [model event](https://laravel.com/docs/eloquent#events).
</Aside>

## Uploading multiple files

You may also upload multiple files. This stores URLs in JSON:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('attachments')
    ->multiple()
```

Optionally, you may pass a boolean value to control if multiple files can be uploaded at once:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('attachments')
    ->multiple(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `multiple()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

If you're saving the file URLs using Eloquent, you should be sure to add an `array` [cast](https://laravel.com/docs/eloquent-mutators#array-and-json-casting) to the model property:

```php
use Illuminate\Database\Eloquent\Model;

class Message extends Model
{
    /**
     * @return array<string, string>
     */
    protected function casts(): array
    { 
        return [
            'attachments' => 'array',
        ];
    }

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

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `maxParallelUploads()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Controlling file names

By default, a random file name will be generated for newly-uploaded files. This is to ensure that there are never any conflicts with existing files.

### Security implications of controlling file names

Before using the `preserveFilenames()` or `getUploadedFileNameForStorageUsing()` methods, please be aware of the security implications. If you allow users to upload files with their own file names, there are ways that they can exploit this to upload malicious files. **This applies even if you use the [`acceptedFileTypes()`](#file-type-validation) method** to restrict the types of files that can be uploaded, since it uses Laravel's `mimetypes` rule which does not validate the extension of the file, only its mime type, which could be manipulated.

This is specifically an issue with the `getClientOriginalName()` method on the `TemporaryUploadedFile` object, which the `preserveFilenames()` method uses. By default, Livewire generates a random file name for each file uploaded, and uses the mime type of the file to determine the file extension.

Using these methods **with the `local` or `public` filesystem disks** will make your app vulnerable to remote code execution if the attacker uploads a PHP file with a deceptive mime type. **Using an S3 disk protects you from this specific attack vector**, as S3 will not execute PHP files in the same way that your server might when serving files from local storage.

If you are using the `local` or `public` disk, you should consider using the [`storeFileNamesIn()` method](#storing-original-file-names-independently) to store the original file names in a separate column in your database, and keep the randomly generated file names in the file system. This way, you can still display the original file names to users, while keeping the file system secure.

On top of this security issue, you should also be aware that allowing users to upload files with their own file names can lead to conflicts with existing files, and can make it difficult to manage your storage. Users could upload files with the same name and overwrite the other's content if you do not scope them to a specific directory, so these features should in all cases only be accessible to trusted users.

### Preserving original file names

<Aside variant="danger">
    Before using this feature, please ensure that you have read the [security implications](#security-implications-of-controlling-file-names).
</Aside>

To preserve the original filenames of the uploaded files, use the `preserveFilenames()` method:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('attachment')
    ->preserveFilenames()
```

Optionally, you may pass a boolean value to control if the original file names should be preserved:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('attachment')
    ->preserveFilenames(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `preserveFilenames()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Generating custom file names

<Aside variant="danger">
    Before using this feature, please ensure that you have read the [security implications](#security-implications-of-controlling-file-names).
</Aside>

You may completely customize how file names are generated using the `getUploadedFileNameForStorageUsing()` method, and returning a string from the closure based on the `$file` that was uploaded:

```php
use Livewire\Features\SupportFileUploads\TemporaryUploadedFile;

FileUpload::make('attachment')
    ->getUploadedFileNameForStorageUsing(
        fn (TemporaryUploadedFile $file): string => (string) str($file->getClientOriginalName())
            ->prepend('custom-prefix-'),
    )
```

<UtilityInjection set="formFields" version="4.x" extras="File;;Livewire\Features\SupportFileUploads\TemporaryUploadedFile;;$file;;The temporary file object being uploaded.">You can inject various utilities into the function passed to `getUploadedFileNameForStorageUsing()` as parameters.</UtilityInjection>

### Storing original file names independently

You can keep the randomly generated file names, while still storing the original file name, using the `storeFileNamesIn()` method:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('attachments')
    ->multiple()
    ->storeFileNamesIn('attachment_file_names')
```

`attachment_file_names` will now store the original file names of your uploaded files, so you can save them to the database when the form is submitted. If you're uploading `multiple()` files, make sure that you add an `array` [cast](https://laravel.com/docs/eloquent-mutators#array-and-json-casting) to this Eloquent model property too.

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `storeFileNamesIn()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

Optionally, you may pass a boolean value to control if the image editor is enabled:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('image')
    ->image()
    ->imageEditor(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `imageEditor()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `imageEditorAspectRatios()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Setting the image editor's mode

You can change the mode of the image editor using the `imageEditorMode()` method, which accepts either `1`, `2` or `3`. These options are explained in the [Cropper.js documentation](https://github.com/fengyuanchen/cropperjs#viewmode):

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('image')
    ->image()
    ->imageEditor()
    ->imageEditorMode(2)
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `imageEditorMode()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Customizing the image editor's empty fill color

By default, the image editor will make the empty space around the image transparent. You can customize this using the `imageEditorEmptyFillColor()` method:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('image')
    ->image()
    ->imageEditor()
    ->imageEditorEmptyFillColor('#000000')
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `imageEditorEmptyFillColor()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

<UtilityInjection set="formFields" version="4.x">As well as allowing static values, the `imageEditorViewportWidth()` and `imageEditorViewportHeight()` methods also accept functions to dynamically calculate them. You can inject various utilities into the functions as parameters.</UtilityInjection>

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

Optionally, you may pass a boolean value to control if the circle cropper is enabled:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('image')
    ->image()
    ->avatar()
    ->imageEditor()
    ->circleCropper(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `circleCropper()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

<UtilityInjection set="formFields" version="4.x">As well as allowing static values, the `imageResizeMode()`, `imageCropAspectRatio()`, `imageResizeTargetHeight()` and `imageResizeTargetWidth()` methods also accept functions to dynamically calculate them. You can inject various utilities into the functions as parameters.</UtilityInjection>

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

<UtilityInjection set="formFields" version="4.x">As well as allowing static values, these methods also accept functions to dynamically calculate them. You can inject various utilities into the functions as parameters.</UtilityInjection>

### Displaying files in a grid

You can use the [Filepond `grid` layout](https://pqina.nl/filepond/docs/api/style/#grid-layout) by setting the `panelLayout()`:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('attachments')
    ->multiple()
    ->panelLayout('grid')
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `panelLayout()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

Optionally, the `reorderable()` and `appendFiles()` methods accept a boolean value to control if the files can be reordered and if new files should be appended to the end of the list:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('attachments')
    ->multiple()
    ->reorderable(FeatureFlag::active())
    ->appendFiles(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `reorderable()` and `appendFiles()` methods also accept functions to dynamically calculate them. You can inject various utilities into the functions as parameters.</UtilityInjection>

## Opening files in a new tab

You can add a button to open each file in a new tab with the `openable()` method:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('attachments')
    ->multiple()
    ->openable()
```

Optionally, you may pass a boolean value to control if the files can be opened in a new tab:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('attachments')
    ->multiple()
    ->openable(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `openable()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Downloading files

If you wish to add a download button to each file instead, you can use the `downloadable()` method:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('attachments')
    ->multiple()
    ->downloadable()
```

Optionally, you may pass a boolean value to control if the files can be downloaded:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('attachments')
    ->multiple()
    ->downloadable(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `downloadable()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Previewing files

By default, some file types can be previewed in FilePond. If you wish to disable the preview for all files, you can use the `previewable(false)` method:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('attachments')
    ->multiple()
    ->previewable(false)
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `previewable()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Moving files instead of copying when the form is submitted

By default, files are initially uploaded to Livewire's temporary storage directory, and then copied to the destination directory when the form is submitted. If you wish to move the files instead, providing that temporary uploads are stored on the same disk as permanent files, you can use the `moveFiles()` method:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('attachment')
    ->moveFiles()
```

Optionally, you may pass a boolean value to control if the files should be moved:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('attachment')
    ->moveFiles(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `moveFiles()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Preventing files from being stored permanently

If you wish to prevent files from being stored permanently when the form is submitted, you can use the `storeFiles(false)` method:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('attachment')
    ->storeFiles(false)
```

When the form is submitted, a temporary file upload object will be returned instead of a permanently stored file path. This is perfect for temporary files like imported CSVs.

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `storeFiles()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<Aside variant="warning">
    Images, video and audio files will not show the stored file name in the form's preview, unless you use [`previewable(false)`](#previewing-files). This is due to a limitation with the FilePond preview plugin.
</Aside>

## Orienting images from their EXIF data

By default, FilePond will automatically orient images based on their EXIF data. If you wish to disable this behavior, you can use the `orientImagesFromExif(false)` method:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('attachment')
    ->orientImagesFromExif(false)
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `orientImagesFromExif()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Hiding the remove file button

It is also possible to hide the remove uploaded file button by using `deletable(false)`:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('attachment')
    ->deletable(false)
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `deletable()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Preventing pasting files

You can disable the ability to paste files via the clipboard using the `pasteable(false)` method:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('attachment')
    ->pasteable(false)
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `pasteable()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Preventing file information fetching

While the form is loaded, it will automatically detect whether the files exist, what size they are, and what type of files they are. This is all done on the backend. When using remote storage with many files, this can be time-consuming. You can use the `fetchFileInformation(false)` method to disable this feature:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('attachment')
    ->fetchFileInformation(false)
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `fetchFileInformation()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Customizing the uploading message

You may customize the uploading message that is displayed in the form's submit button using the `uploadingMessage()` method:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('attachment')
    ->uploadingMessage('Uploading attachment...')
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `uploadingMessage()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## File upload validation

As well as all rules listed on the [validation](validation) page, there are additional rules that are specific to file uploads.

Since Filament is powered by Livewire and uses its file upload system, you will want to refer to the default Livewire file upload validation rules in the `config/livewire.php` file as well. This also controls the 12MB file size maximum.

### File type validation

You may restrict the types of files that may be uploaded using the `acceptedFileTypes()` method, and passing an array of MIME types.

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('document')
    ->acceptedFileTypes(['application/pdf'])
```

<UtilityInjection set="formFields" version="4.x">As well as allowing static values, the `acceptedFileTypes()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

<UtilityInjection set="formFields" version="4.x">As well as allowing static values, the `mimeTypeMap()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### File size validation

You may also restrict the size of uploaded files in kilobytes:

```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('attachment')
    ->minSize(512)
    ->maxSize(1024)
```

<UtilityInjection set="formFields" version="4.x">As well as allowing static values, the `minSize()` and `maxSize()` methods also accept functions to dynamically calculate them. You can inject various utilities into the functions as parameters.</UtilityInjection>

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

The [max upload size can be adjusted in the `rules` key of `temporary_file_upload`](https://livewire.laravel.com/docs/uploads#global-validation). In this instance, KB are used in the rule, and 120MB is 122880KB:

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

<UtilityInjection set="formFields" version="4.x">As well as allowing static values, the `minFiles()` and `maxFiles()` methods also accept functions to dynamically calculate them. You can inject various utilities into the functions as parameters.</UtilityInjection>

# Documentation for forms. File: 10-rich-editor.md
---
title: Rich editor
---
import Aside from "@components/Aside.astro"
import AutoScreenshot from "@components/AutoScreenshot.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

The rich editor allows you to edit and preview HTML content, as well as upload images. It uses [TipTap](https://tiptap.dev) as the underlying editor.

```php
use Filament\Forms\Components\RichEditor;

RichEditor::make('content')
```

<AutoScreenshot name="forms/fields/rich-editor/simple" alt="Rich editor" version="4.x" />

## Storing content as JSON

By default, the rich editor stores content as HTML. If you would like to store the content as JSON instead, you can use the `json()` method:

```php
use Filament\Forms\Components\RichEditor;

RichEditor::make('content')
    ->json()
```

The JSON is in [TipTap's](https://tiptap.dev) format, which is a structured representation of the content.

If you're saving the JSON tags using Eloquent, you should be sure to add an `array` [cast](https://laravel.com/docs/eloquent-mutators#array-and-json-casting) to the model property:

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
            'content' => 'array',
        ];
    }

    // ...
}
```

## Customizing the toolbar buttons

You may set the toolbar buttons for the editor using the `toolbarButtons()` method. The options shown here are the defaults:

```php
use Filament\Forms\Components\RichEditor;

RichEditor::make('content')
    ->toolbarButtons([
        ['bold', 'italic', 'underline', 'strike', 'subscript', 'superscript', 'link'],
        ['h2', 'h3', 'alignStart', 'alignCenter', 'alignEnd'],
        ['blockquote', 'codeBlock', 'bulletList', 'orderedList'],
        ['table', 'attachFiles'], // The `customBlocks` and `mergeTags` tools are also added here if those features are used.
        ['undo', 'redo'],
    ])
```

Each nested array in the main array represents a group of buttons in the toolbar.

Additional tools available in the toolbar include:

- `h1` - Applies the "h1" tag to the text.
- `alignJustify` - Justifies the text.
- `clearFormatting` - Clears all formatting from the selected text.
- `details` - Inserts a `<details>` tag, which allows users to create collapsible sections in their content.
- `highlight` - Highlights the selected text with a `<mark>` tag around it.
- `horizontalRule` - Inserts a horizontal rule.
- `lead` - Applies a `lead` class around the text, which is typically used for the first paragraph of an article.
- `small` - Applies the `<small>` tag to the text, which is typically used for small print or disclaimers.
- `code` - Format the selected text as inline code.
- `table` - Creates a table in the editor with a default layout of 3 columns and 2 rows, with the first row configured as a header row.
- `tableAddColumnBefore` - Adds a new column before the current column.
- `tableAddColumnAfter` - Adds a new column after the current column.
- `tableDeleteColumn` - Deletes the current column.
- `tableAddRowBefore` - Adds a new row above the current row.
- `tableAddRowAfter` - Adds a new row below the current row.
- `tableDeleteRow` - Deletes the current row.
- `tableMergeCells` - Merges the selected cells into one cell.
- `tableSplitCell` - Splits the selected cell into multiple cells.
- `tableToggleHeaderRow` - Toggles the header row of the table.
- `tableDelete` - Deletes the table.

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `toolbarButtons()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Customizing floating toolbars

If your toolbar is too full, you can use a floating toolbar to show certain tools in a toolbar below the cursor, only when the user is inside a specific node type. This allows you to keep the main toolbar clean while still providing access to additional tools when needed.

You can customize the floating toolbars that appear when your cursor is placed inside a specific node by using the `floatingToolbars()` method.

In the example below, a floating toolbar appears when the cursor is inside a paragraph node. It shows bold, italic, and similar buttons. When the cursor is in a heading node, it displays heading-related buttons, and when inside a table, it shows table-specific controls.

```php
use Filament\Forms\Components\RichEditor;

RichEditor::make('content')
    ->floatingToolbars([
        'paragraph' => [
            'bold', 'italic', 'underline', 'strike', 'subscript', 'superscript',
        ],
        'heading' => [
            'h1', 'h2', 'h3',
        ],
        'table' => [
            'tableAddColumnBefore', 'tableAddColumnAfter', 'tableDeleteColumn',
            'tableAddRowBefore', 'tableAddRowAfter', 'tableDeleteRow',
            'tableMergeCells', 'tableSplitCell',
            'tableToggleHeaderRow',
            'tableDelete',
        ],
    ])
```

## Rendering rich content

If you're [storing content as JSON](#storing-content-as-json) instead of HTML, or your content requires processing to inject [private image URLs](#using-private-images-in-the-editor) or similar, you'll need to use the `RichContentRenderer` tool in Filament to output HTML:

```php
use Filament\Forms\Components\RichEditor\RichContentRenderer;

RichContentRenderer::make($record->content)->toHtml()
```

The `toHtml()` method returns a string. If you would like to output HTML in a Blade view without escaping the HTML, you can echo the `RichContentRender` object without calling `toHtml()`:

```blade
{{ \Filament\Forms\Components\RichEditor\RichContentRenderer::make($record->content) }}
```

If you have configured the [file attachments behavior](#uploading-images-to-the-editor) of the editor to change the disk or visibility of the uploaded files, you must also pass these settings to the renderer to ensure that the correct URLs are generated:

```php
use Filament\Forms\Components\RichEditor\RichContentRenderer;

RichContentRenderer::make($record->content)
    ->fileAttachmentsDisk('s3')
    ->fileAttachmentsVisibility('private')
    ->toHtml()
```

If you are using [custom blocks](#using-custom-blocks) in the rich editor, you can pass an array of custom blocks to the renderer to ensure that they are rendered correctly:

```php
use Filament\Forms\Components\RichEditor\RichContentRenderer;

RichContentRenderer::make($record->content)
    ->customBlocks([
        HeroBlock::class => [
            'categoryUrl' => $record->category->getUrl(),
        ],
        CallToActionBlock::class,
    ])
    ->toHtml()
```

If you are using [merge tags](#using-merge-tags), you can pass an array of values to replace the merge tags with:

```php
use Filament\Forms\Components\RichEditor\RichContentRenderer;

RichContentRenderer::make($record->content)
    ->mergeTags([
        'name' => $record->user->name,
        'today' => now()->toFormattedDateString(),
    ])
    ->toHtml()
```

## Security

By default, the editor outputs raw HTML, and sends it to the backend. Attackers are able to intercept the value of the component and send a different raw HTML string to the backend. As such, it is important that when outputting the HTML from a rich editor, it is sanitized; otherwise your site may be exposed to Cross-Site Scripting (XSS) vulnerabilities.

When Filament outputs raw HTML from the database in components such as `TextColumn` and `TextEntry`, it sanitizes it to remove any dangerous JavaScript. However, if you are outputting the HTML from a rich editor in your own Blade view, this is your responsibility. One option is to use Filament's `sanitizeHtml()` helper to do this, which is the same tool we use to sanitize HTML in the components mentioned above:

```blade
{!! str($record->content)->sanitizeHtml() !!}
```

If you're [storing content as JSON](#storing-content-as-json) instead of HTML, or your content requires processing to inject [private image URLs](#using-private-images-in-the-editor) or similar, you can use the [content renderer](#rendering-rich-content) to output HTML. This will automatically sanitize the HTML for you, so you don't need to worry about it.

## Uploading images to the editor

By default, uploaded images are stored publicly on your storage disk, so that the rich content stored in the database can be output easily anywhere. You may customize how images are uploaded using configuration methods:

```php
use Filament\Forms\Components\RichEditor;

RichEditor::make('content')
    ->fileAttachmentsDisk('s3')
    ->fileAttachmentsDirectory('attachments')
    ->fileAttachmentsVisibility('private')
```

<UtilityInjection set="formFields" version="4.x">As well as allowing static values, the `fileAttachmentsDisk()`, `fileAttachmentsDirectory()`, and `fileAttachmentsVisibility()` methods also accept functions to dynamically calculate them. You can inject various utilities into the function as parameters.</UtilityInjection>

<Aside variant="tip">
    Filament also supports [`spatie/laravel-medialibrary`](https://github.com/spatie/laravel-medialibrary) for storing rich editor file attachments. See our [plugin documentation](/plugins/filament-spatie-media-library#using-media-library-for-rich-editor-file-attachments) for more information.
</Aside>

### Using private images in the editor

Using private images in the editor adds a layer of complexity to the process, since private images cannot be accessed directly via a permanent URL. Each time the editor is loaded or its content is rendered, temporary URLs need to be generated for each image, which are never stored in the database. Instead, Filament adds a `data-id` attribute to the image tags, which contains an identifier for the image in the storage disk, so that a temporary URL can be generated on demand.

When rendering the content using private images, ensure that you are using the [`RichContentRenderer` tool](#rendering-rich-content) in Filament to output HTML:

```php
use Filament\Forms\Components\RichEditor\RichContentRenderer;

RichContentRenderer::make($record->content)
    ->fileAttachmentsDisk('s3')
    ->fileAttachmentsVisibility('private')
    ->toHtml()
```

## Using custom blocks

Custom blocks are elements that users can drag and drop into the rich editor. You can define custom blocks that user can insert into the rich editor using the `customBlocks()` method:

```php
use Filament\Forms\Components\RichEditor;

RichEditor::make('content')
    ->customBlocks([
        HeroBlock::class,
        CallToActionBlock::class,
    ])
```

To create a custom block, you can use the following command:

```bash
php artisan make:filament-rich-content-custom-block HeroBlock
```

Each block needs a corresponding class that extends the `Filament\Forms\Components\RichEditor\RichContentCustomBlock` class. The `getId()` method should return a unique identifier for the block, and the `getLabel()` method should return the label that will be displayed in the editor's side panel:

```php
use Filament\Forms\Components\RichEditor\RichContentCustomBlock;

class HeroBlock extends RichContentCustomBlock
{
    public static function getId(): string
    {
        return 'hero';
    }

    public static function getLabel(): string
    {
        return 'Hero section';
    }
}
```

When a user drags a custom block into the editor, you can choose to open a modal to collect additional information from the user before inserting the block. To do this, you can use the `configureEditorAction()` method to configure the [modal](../actions/modals) that will be opened when the block is inserted:

```php
use Filament\Actions\Action;
use Filament\Forms\Components\RichEditor\RichContentCustomBlock;

class HeroBlock extends RichContentCustomBlock
{
    // ...

    public static function configureEditorAction(Action $action): Action
    {
        return $action
            ->modalDescription('Configure the hero section')
            ->schema([
                TextInput::make('heading')
                    ->required(),
                TextInput::make('subheading'),
            ]);
    }
}
```

The `schema()` method on the action can define form fields that will be displayed in the modal. When the user submits the form, the form data will be saved as "configuration" for that block.

### Rendering a preview for a custom block

Once a block is inserted into the editor, you may define a "preview" for it using the `toPreviewHtml()` method. This method should return a string of HTML that will be displayed in the editor when the block is inserted, allowing users to see what the block will look like before they save it. You can access the `$config` for the block in this method, which contains the data that was submitted in the modal when the block was inserted:

```php
use Filament\Forms\Components\RichEditor\RichContentCustomBlock;

class HeroBlock extends RichContentCustomBlock
{
    // ...

    /**
     * @param  array<string, mixed>  $config
     */
    public static function toPreviewHtml(array $config): string
    {
        return view('filament.forms.components.rich-editor.rich-content-custom-blocks.hero.preview', [
            'heading' => $config['heading'],
            'subheading' => $config['subheading'] ?? 'Default subheading',
        ])->render();
    }
}
```

The `getPreviewLabel()` can be defined if you would like to customize the label that is displayed above the preview in the editor. By default, it will use the label defined in the `getLabel()` method, but the `getPreviewLabel()` is able to access the `$config` for the block, allowing you to display dynamic information in the label:

```php
use Filament\Forms\Components\RichEditor\RichContentCustomBlock;

class HeroBlock extends RichContentCustomBlock
{
    // ...

    /**
     * @param  array<string, mixed>  $config
     */
    public static function getPreviewLabel(array $config): string
    {
        return "Hero section: {$config['heading']}";
    }
}
```

### Rendering content with custom blocks

When rendering the rich content, you can pass the array of custom blocks to the `RichContentRenderer` to ensure that the blocks are rendered correctly:

```php
use Filament\Forms\Components\RichEditor\RichContentRenderer;

RichContentRenderer::make($record->content)
    ->customBlocks([
        HeroBlock::class,
        CallToActionBlock::class,
    ])
    ->toHtml()
```

Each block class may have a `toHtml()` method that returns the HTML that should be rendered for that block:

```php
use Filament\Forms\Components\RichEditor\RichContentCustomBlock;

class HeroBlock extends RichContentCustomBlock
{
    // ...

    /**
     * @param  array<string, mixed>  $config
     * @param  array<string, mixed>  $data
     */
    public static function toHtml(array $config, array $data): string
    {
        return view('filament.forms.components.rich-editor.rich-content-custom-blocks.hero.index', [
            'heading' => $config['heading'],
            'subheading' => $config['subheading'],
            'buttonLabel' => 'View category',
            'buttonUrl' => $data['categoryUrl'],
        ])->render();
    }
}
```

As seen above, the `toHtml()` method receives two parameters: `$config`, which contains the configuration data submitted in the modal when the block was inserted, and `$data`, which contains any additional data that may be needed to render the block. This allows you to access the configuration data and render the block accordingly. The data can be passed in the `customBlocks()` method:

```php
use Filament\Forms\Components\RichEditor\RichContentRenderer;

RichContentRenderer::make($record->content)
    ->customBlocks([
        HeroBlock::class => [
            'categoryUrl' => $record->category->getUrl(),
        ],
        CallToActionBlock::class,
    ])
    ->toHtml()
```

### Opening the custom blocks panel by default

If you want the custom blocks panel to be open by default when the rich editor is loaded, you can use the `activePanel('customBlocks')` method:

```php
use Filament\Forms\Components\RichEditor;

RichEditor::make('content')
    ->customBlocks([
        HeroBlock::class,
        CallToActionBlock::class,
    ])
    ->activePanel('customBlocks')
```

## Using merge tags

Merge tags allow the user to insert "placeholders" into their rich content, which can be replaced with dynamic values when the content is rendered. This is useful for inserting things like the current user's name, or the current date.

To register merge tags on an editor, use the `mergeTags()` method:

```php
use Filament\Forms\Components\RichEditor;

RichEditor::make('content')
    ->mergeTags([
        'name',
        'today',
    ])
```

Merge tags are surrounded by double curly braces, like `{{ name }}`. When the content is rendered, these tags will be replaced with the corresponding values.

To insert a merge tag into the content, users can start typing `{{` to search for a tag to insert. Alternatively, they can click on the "merge tags" tool in the editor's toolbar, which opens a panel containing all the merge tags. They can then drag a merge tag from the editor's side panel into the content or click to insert it.

### Rendering content with merge tags

When rendering the rich content, you can pass an array of values to replace the merge tags with:

```php
use Filament\Forms\Components\RichEditor\RichContentRenderer;

RichContentRenderer::make($record->content)
    ->mergeTags([
        'name' => $record->user->name,
        'today' => now()->toFormattedDateString(),
    ])
    ->toHtml()
```

If you have many merge tags or you need to run some logic to determine the values, you can use a function as the value of each merge tag. This function will be called when a merge tag is first encountered in the content, and its result is cached for subsequent tags of the same name:

```php
use Filament\Forms\Components\RichEditor\RichContentRenderer;

RichContentRenderer::make($record->content)
    ->mergeTags([
        'name' => fn (): string => $record->user->name,
        'today' => now()->toFormattedDateString(),
    ])
    ->toHtml()
```

### Opening the merge tags panel by default

If you want the merge tags panel to be open by default when the rich editor is loaded, you can use the `activePanel('mergeTags')` method:

```php
use Filament\Forms\Components\RichEditor;

RichEditor::make('content')
    ->mergeTags([
        'name',
        'today',
    ])
    ->activePanel('mergeTags')
```

## Registering rich content attributes

There are elements of the rich editor configuration that apply to both the editor and the renderer. For example, if you are using [private images](#using-private-images-in-the-editor), [custom blocks](#using-custom-blocks), [merge tags](#using-merge-tags), or [plugins](#extending-the-rich-editor), you need to ensure that the same configuration is used in both places. To do this, Filament provides you with a way to register rich content attributes that can be used in both the editor and the renderer.

To register rich content attributes on an Eloquent model, you should use the `InteractsWithRichContent` trait and implement the `HasRichContent` interface. This allows you to register the attributes in the `setUpRichContent()` method:

```php
use Filament\Forms\Components\RichEditor\Models\Concerns\InteractsWithRichContent;
use Filament\Forms\Components\RichEditor\Models\Contracts\HasRichContent;
use Illuminate\Database\Eloquent\Model;

class Post extends Model implements HasRichContent
{
    use InteractsWithRichContent;

    public function setUpRichContent(): void
    {
        $this->registerRichContent('content')
            ->fileAttachmentsDisk('s3')
            ->fileAttachmentsVisibility('private')
            ->customBlocks([
                HeroBlock::class => [
                    'categoryUrl' => fn (): string => $this->category->getUrl(),
                ],
                CallToActionBlock::class,
            ])
            ->mergeTags([
                'name' => fn (): string => $this->user->name,
                'today' => now()->toFormattedDateString(),
            ])
            ->plugins([
                HighlightRichContentPlugin::make(),
            ]);
    }
}
```

Whenever you use the `RichEditor` component, the configuration registered for the corresponding attribute will be used:

```php
use Filament\Forms\Components\RichEditor;

RichEditor::make('content')
```

To easily render the rich content HTML from a model with the given configuration, you can call the `renderRichContent()` method on the model, passing the name of the attribute:

```blade
{!! $record->renderRichContent('content') !!}
```

Alternatively, you can get an `Htmlable` object to render without escaping the HTML:

```blade
{{ $record->getRichContentAttribute('content') }}
```

When using a [text column](../tables/columns/text) in a table or a [text entry](../infolists/text-entry) in an infolist, you don't need to manually render the rich content. Filament will do this for you automatically:

```php
use Filament\Infolists\Components\TextEntry;
use Filament\Tables\Columns\TextColumn;

TextColumn::make('content')

TextEntry::make('content')
```

## Extending the rich editor

You can create plugins for the rich editor, which allow you to add custom TipTap extensions to the editor and renderer, as well as custom toolbar buttons. Create a new class that implements the `RichContentPlugin` interface:

```php
use Filament\Actions\Action;
use Filament\Forms\Components\ColorPicker;
use Filament\Forms\Components\RichEditor;
use Filament\Forms\Components\RichEditor\EditorCommand;
use Filament\Forms\Components\RichEditor\Plugins\Contracts\RichContentPlugin;
use Filament\Forms\Components\RichEditor\RichEditorTool;
use Filament\Support\Enums\Width;
use Filament\Support\Facades\FilamentAsset;
use Filament\Support\Icons\Heroicon;
use Tiptap\Core\Extension;
use Tiptap\Marks\Highlight;

class HighlightRichContentPlugin implements RichContentPlugin
{
    public static function make(): static
    {
        return app(static::class);
    }

    /**
     * @return array<Extension>
     */
    public function getTipTapPhpExtensions(): array
    {
        // This method should return an array of PHP TipTap extension objects.
        // See: https://github.com/ueberdosis/tiptap-php
    
        return [
            app(Highlight::class, [
                'options' => ['multicolor' => true],
            ]),
        ];
    }

    /**
     * @return array<string>
     */
    public function getTipTapJsExtensions(): array
    {
        // This method should return an array of URLs to JavaScript files containing
        // TipTap extensions that should be asynchronously loaded into the editor
        // when the plugin is used.
    
        return [
            FilamentAsset::getScriptSrc('rich-content-plugins/highlight'),
        ];
    }

    /**
     * @return array<RichEditorTool>
     */
    public function getEditorTools(): array
    {
        // This method should return an array of `RichEditorTool` objects, which can then be
        // used in the `toolbarButtons()` of the editor.
        
        // The `jsHandler()` method allows you to access the TipTap editor instance
        // through `$getEditor()`, and `chain()` any TipTap commands to it.
        // See: https://tiptap.dev/docs/editor/api/commands
        
        // The `action()` method allows you to run an action (registered in the `getEditorActions()`
        // method) when the toolbar button is clicked. This allows you to open a modal to
        // collect additional information from the user before running a command.
    
        return [
            RichEditorTool::make('highlight')
                ->jsHandler('$getEditor()?.chain().focus().toggleHighlight().run()')
                ->icon(Heroicon::CursorArrowRays),
            RichEditorTool::make('highlightWithCustomColor')
                ->action(arguments: '{ color: $getEditor().getAttributes(\'highlight\')?.[\'data-color\'] }')
                ->icon(Heroicon::CursorArrowRipple),
        ];
    }

    /**
     * @return array<Action>
     */
    public function getEditorActions(): array
    {
        // This method should return an array of `Action` objects, which can be used by the tools
        // registered in the `getEditorTools()` method. The name of the action should match
        // the name of the tool that uses it.
        
        // The `runCommands()` method allows you to run TipTap commands on the editor instance.
        // It accepts an array of `EditorCommand` objects that define the command to run,
        // as well as any arguments to pass to the command. You should also pass in the
        // `editorSelection` argument, which is the current selection in the editor
        // to apply the commands to.
    
        return [
            Action::make('highlightWithCustomColor')
                ->modalWidth(Width::Large)
                ->fillForm(fn (array $arguments): array => [
                    'color' => $arguments['color'] ?? null,
                ])
                ->schema([
                    ColorPicker::make('color'),
                ])
                ->action(function (array $arguments, array $data, RichEditor $component): void {
                    $component->runCommands(
                        [
                            EditorCommand::make(
                                'toggleHighlight',
                                arguments: [[
                                    'color' => $data['color'],
                                ]],
                            ),
                        ],
                        editorSelection: $arguments['editorSelection'],
                    );
                }),
        ];
    }
}
```

You can use the `plugins()` method to register your plugin with the rich editor and [rich content renderer](#rendering-rich-content):

```php
use Filament\Forms\Components\RichEditor;
use Filament\Forms\Components\RichEditor\RichContentRenderer;

RichEditor::make('content')
    ->toolbarButtons([
        ['bold', 'highlight', 'highlightWithCustomColor'],
        ['h2', 'h3'],
        ['bulletList', 'orderedList'],
    ])
    ->plugins([
        HighlightRichContentPlugin::make(),
    ])

RichContentRenderer::make($record->content)
    ->plugins([
        HighlightRichContentPlugin::make(),
    ])
```

### Setting up a TipTap JavaScript extension

Filament is able to asynchronously load JavaScript extensions for TipTap. To do this, you need to create a JavaScript file that contains the extension, and register it in the `getTipTapJsExtensions()` method of your [plugin](#extending-the-rich-editor).

For instance, if you wanted to use the [TipTap highlight extension](https://tiptap.dev/docs/editor/extensions/marks/highlight), make sure it is installed first:

```bash
npm install @tiptap/extension-highlight --save-dev
```

Then, create a JavaScript file that imports the extension. In this example, create a file called `highlight.js` in the `resources/js/filament/rich-content-plugins` directory, and add the following code to it:

```javascript
import Highlight from '@tiptap/extension-highlight'

export default Highlight.configure({
    multicolor: true,
})
```

One way to compile this file is to use [esbuild](https://esbuild.github.io). You can install it using `npm`:

```bash
npm install esbuild --save-dev
```

You must create an [esbuild](https://esbuild.github.io) script to compile the file. You can put this anywhere, for example `bin/build.js`:

```js
import * as esbuild from 'esbuild'

async function compile(options) {
    const context = await esbuild.context(options)

    await context.rebuild()
    await context.dispose()
}

compile({
    define: {
        'process.env.NODE_ENV': `'production'`,
    },
    bundle: true,
    mainFields: ['module', 'main'],
    platform: 'neutral',
    sourcemap: false,
    sourcesContent: false,
    treeShaking: true,
    target: ['es2020'],
    minify: true,
    entryPoints: ['./resources/js/filament/rich-content-plugins/highlight.js'],
    outfile: './resources/js/dist/filament/rich-content-plugins/highlight.js',
})
```

As you can see at the bottom of the script, we are compiling a file called `resources/js/filament/rich-content-plugins/highlight.js` into `resources/js/dist/filament/rich-content-plugins/highlight.js`. You can change these paths to suit your needs. You can compile as many files as you want.

To run the script and compile this file into `resources/js/dist/filament/rich-content-plugins/highlight.js` run the following command:

```bash
node bin/build.js
```

You should register it in the `boot()` method of a service provider, like `AppServiceProvider`, and use `loadedOnRequest()` so that it is not downloaded until the rich editor is loaded on a page:

```php
use Filament\Support\Assets\Js;
use Filament\Support\Facades\FilamentAsset;

FilamentAsset::register([
    Js::make('rich-content-plugins/highlight', __DIR__ . '/../../resources/js/dist/filament/rich-content-plugins/highlight.js')->loadedOnRequest(),
]);
```

To publish this new JavaScript file into the `/public` directory of your app so that it can be served, you can use the `filament:assets` command:

```bash
php artisan filament:assets
```

In the [plugin object](#extending-the-rich-editor), the `getTipTapJsExtensions()` method should return the path to the JavaScript file you just created. Now that it's registered with `FilamentAsset`, you can use the `getScriptSrc()` method to get the URL to the file:

```php
use Filament\Support\Facades\FilamentAsset;

/**
 * @return array<string>
 */
public function getTipTapJsExtensions(): array
{
    return [
        FilamentAsset::getScriptSrc('rich-content-plugins/highlight'),
    ];
}
```

# Documentation for forms. File: 11-markdown-editor.md
---
title: Markdown editor
---
import AutoScreenshot from "@components/AutoScreenshot.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

The markdown editor allows you to edit and preview markdown content, as well as upload images using drag and drop.

```php
use Filament\Forms\Components\MarkdownEditor;

MarkdownEditor::make('content')
```

<AutoScreenshot name="forms/fields/markdown-editor/simple" alt="Markdown editor" version="4.x" />

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
        ['bold', 'italic', 'strike', 'link'],
        ['heading'],
        ['blockquote', 'codeBlock', 'bulletList', 'orderedList'],
        ['table', 'attachFiles'],
        ['undo', 'redo'],
    ])
```

Each nested array in the main array represents a group of buttons in the toolbar.

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `toolbarButtons()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Uploading images to the editor

Images may be uploaded to the editor. They will always be uploaded to a publicly available URL with public storage permissions, since generating temporary file upload URLs is not supported in static content. You may customize where images are uploaded using configuration methods:

```php
use Filament\Forms\Components\MarkdownEditor;

MarkdownEditor::make('content')
    ->fileAttachmentsDisk('s3')
    ->fileAttachmentsDirectory('attachments')
```

<UtilityInjection set="formFields" version="4.x">As well as allowing static values, the `fileAttachmentsDisk()` and `fileAttachmentsDirectory()` methods also accept functions to dynamically calculate them. You can inject various utilities into the function as parameters.</UtilityInjection>

# Documentation for forms. File: 12-repeater.md
---
title: Repeater
---
import Aside from "@components/Aside.astro"
import AutoScreenshot from "@components/AutoScreenshot.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

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

<AutoScreenshot name="forms/fields/repeater/simple" alt="Repeater" version="4.x" />

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

Repeaters may have a certain number of empty items created by default. The default is only used when a schema is loaded with no data. In a standard [panel resource](../resources), defaults are used on the Create page, not the Edit page. To use default items, pass the number of items to the `defaultItems()` method:

```php
use Filament\Forms\Components\Repeater;

Repeater::make('members')
    ->schema([
        // ...
    ])
    ->defaultItems(3)
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `defaultItems()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `addActionLabel()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `addActionAlignment()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `addable()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `deletable()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `reorderable()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

<AutoScreenshot name="forms/fields/repeater/reorderable-with-buttons" alt="Repeater that is reorderable with buttons" version="4.x" />

Optionally, you may pass a boolean value to control if the repeater should be ordered with buttons or not:

```php
use Filament\Forms\Components\Repeater;

Repeater::make('members')
    ->schema([
        // ...
    ])
    ->reorderableWithButtons(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `reorderableWithButtons()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `reorderableWithDragAndDrop()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

<AutoScreenshot name="forms/fields/repeater/collapsed" alt="Collapsed repeater" version="4.x" />

Optionally, the `collapsible()` and `collapsed()` methods accept a boolean value to control if the repeater should be collapsible and collapsed or not:

```php
use Filament\Forms\Components\Repeater;

Repeater::make('qualifications')
    ->schema([
        // ...
    ])
    ->collapsible(FeatureFlag::active())
    ->collapsed(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing static values, the `collapsible()` and `collapsed()` methods also accept functions to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

<AutoScreenshot name="forms/fields/repeater/cloneable" alt="Cloneable repeater" version="4.x" />

Optionally, the `cloneable()` method accepts a boolean value to control if the repeater should be cloneable or not:

```php
use Filament\Forms\Components\Repeater;

Repeater::make('qualifications')
    ->schema([
        // ...
    ])
    ->cloneable(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `cloneable()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Integrating with an Eloquent relationship

You may employ the `relationship()` method of the `Repeater` to configure a `HasMany` relationship. Filament will load the item data from the relationship, and save it back to the relationship when the form is submitted. If a custom relationship name is not passed to `relationship()`, Filament will use the field name as the relationship name:

```php
use Filament\Forms\Components\Repeater;

Repeater::make('qualifications')
    ->relationship()
    ->schema([
        // ...
    ])
```

<Aside variant="warning">
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
</Aside>

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

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `orderColumn()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

<Aside variant="info">
    Please ensure that your pivot model has a primary key column, like `id`, to allow Filament to keep track of which repeater items have been created, updated and deleted. To make sure that Filament keeps track of the primary key, the pivot model needs to have the `$incrementing` property set to `true`.
</Aside>

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

<UtilityInjection set="formFields" version="4.x" extras="Data;;array<array<string, mixed>>;;$data;;The data that is being filled into the repeater.">You can inject various utilities into the function passed to `mutateRelationshipDataBeforeFillUsing()` as parameters.</UtilityInjection>

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

<UtilityInjection set="formFields" version="4.x" extras="Data;;array<string, mixed>;;$data;;The data that is being saved by the repeater.">You can inject various utilities into the function passed to `mutateRelationshipDataBeforeCreateUsing()` as parameters.</UtilityInjection>

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

<UtilityInjection set="formFields" version="4.x" extras="Data;;array<string, mixed>;;$data;;The data that is being saved by the repeater.">You can inject various utilities into the function passed to `mutateRelationshipDataBeforeSaveUsing()` as parameters.</UtilityInjection>

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

<AutoScreenshot name="forms/fields/repeater/grid" alt="Repeater with a 2 column grid of items" version="4.x" />

This method accepts the same options as the `columns()` method of the [grid](../schemas/layouts#grid-system). This allows you to responsively customize the number of grid columns at various breakpoints.

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `grid()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

<Aside variant="tip">
    Any fields that you use from `$state` should be `live()` if you wish to see the item label update live as you use the form.
</Aside>

<UtilityInjection set="formFields" version="4.x" extras="Item;;Filament\Schemas\Schema;;$item;;The schema object for the current repeater item.||Key;;string;;$key;;The key for the current repeater item.||State;;array<string, mixed>;;$state;;The raw unvalidated data for the current repeater item.">You can inject various utilities into the function passed to `itemLabel()` as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/repeater/labelled" alt="Repeater with item labels" version="4.x" />

## Numbering repeater items

You can add the repeater item's number next to its label using the `itemNumbers()` method:

```php
use Filament\Forms\Components\Repeater;

Repeater::make('members')
    ->schema([
        // ...
    ])
    ->itemNumbers()
```

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

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `simple()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/repeater/simple-one-field" alt="Simple repeater design with only one field" version="4.x" />

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

All form components are able to [use `$get()` and `$set()`](overview#injecting-the-state-of-another-field) to access another field's value. However, you might experience unexpected behavior when using this inside the repeater's schema.

This is because `$get()` and `$set()`, by default, are scoped to the current repeater item. This means that you are able to interact with another field inside that repeater item easily without knowing which repeater item the current form component belongs to.

The consequence of this is that you may be confused when you are unable to interact with a field outside the repeater. We use `../` syntax to solve this problem - `$get('../parent_field_name')`.

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

You can use `../` to go up a level in the data structure, so `$get('../client_id')` is `$get('repeater.client_id')` and `$get('../client_id')` is `$get('client_id')`.

The special case of `$get()` with no arguments, or `$get('')` or `$get('./')`, will always return the full data array for the current repeater item.

## Table repeaters

You can present repeater items in a table format using the `table()` method, which accepts an array of `TableColumn` objects. These objects represent the columns of the table, which correspond to any components in the schema of the repeater:

```php
use Filament\Forms\Components\Repeater;
use Filament\Forms\Components\Repeater\TableColumn;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;

Repeater::make('members')
    ->table([
        TableColumn::make('Name'),
        TableColumn::make('Role'),
    ])
    ->schema([
        TextInput::make('name')
            ->required(),
        Select::make('role')
            ->options([
                'member' => 'Member',
                'administrator' => 'Administrator',
                'owner' => 'Owner',
            ])
            ->required(),
    ])
```

<AutoScreenshot name="forms/fields/repeater/table" alt="Repeater with a table layout" version="4.x" />

The labels displayed in the header of the table are passed to the `TableColumn::make()` method. If you want to provide an accessible label for a column but do not wish to display it, you can use the `hiddenHeaderLabel()` method:

```php
use Filament\Forms\Components\Repeater\TableColumn;

TableColumn::make('Name')
    ->hiddenHeaderLabel()
```

If you would like to mark a column as "required" with a red asterisk, you can use the `markAsRequired()` method:

```php
use Filament\Forms\Components\Repeater\TableColumn;

TableColumn::make('Name')
    ->markAsRequired()
```

You can enable wrapping of the column header using the `wrapHeader()` method:

```php
use Filament\Forms\Components\Repeater\TableColumn;

TableColumn::make('Name')
    ->wrapHeader()
```

You can also adjust the alignment of the column header using the `alignment()` method, passing an `Alignment` option of `Alignment::Start`, `Alignment::Center`, or `Alignment::End`:

```php
use Filament\Forms\Components\Repeater\TableColumn;
use Filament\Support\Enums\Alignment;

TableColumn::make('Name')
    ->alignment(Alignment::Start)
```

You can set a fixed column width using the `width()` method, passing a string value that represents the width of the column. This value is passed directly to the `style` attribute of the column header:

```php
use Filament\Forms\Components\Repeater\TableColumn;

TableColumn::make('Name')
    ->width('200px')
```

## Repeater validation

As well as all rules listed on the [validation](validation) page, there are additional rules that are specific to repeaters.

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

<UtilityInjection set="formFields" version="4.x">As well as allowing static values, the `minItems()` and `maxItems()` methods also accept a function to dynamically calculate them. You can inject various utilities into the function as parameters.</UtilityInjection>

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

Optionally, you may pass a boolean value to the `distinct()` method to control if the field should be distinct or not:

```php
use Filament\Forms\Components\Checkbox;

Checkbox::make('is_correct')
    ->distinct(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `distinct()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

Optionally, you may pass a boolean value to the `fixIndistinctState()` method to control if the field should fix indistinct state or not:

```php
use Filament\Forms\Components\Checkbox;

Checkbox::make('is_correct')
    ->fixIndistinctState(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `fixIndistinctState()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

<Aside variant="warning">
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
</Aside>

## Customizing the repeater item actions

This field uses action objects for easy customization of buttons within it. You can customize these buttons by passing a function to an action registration method. The function has access to the `$action` object, which you can use to [customize it](../actions/overview). The following methods are available to customize the actions:

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
use Filament\Actions\Action;
use Filament\Forms\Components\Repeater;

Repeater::make('members')
    ->schema([
        // ...
    ])
    ->collapseAllAction(
        fn (Action $action) => $action->label('Collapse all members'),
    )
```

<UtilityInjection set="formFields" version="4.x" extras="Action;;Filament\Actions\Action;;$action;;The action object to customize.">The action registration methods can inject various utilities into the function as parameters.</UtilityInjection>

### Confirming repeater actions with a modal

You can confirm actions with a modal by using the `requiresConfirmation()` method on the action object. You may use any [modal customization method](../actions/modals) to change its content and behavior:

```php
use Filament\Actions\Action;
use Filament\Forms\Components\Repeater;

Repeater::make('members')
    ->schema([
        // ...
    ])
    ->deleteAction(
        fn (Action $action) => $action->requiresConfirmation(),
    )
```

<Aside variant="info">
    The `collapseAction()`, `collapseAllAction()`, `expandAction()`, `expandAllAction()` and `reorderAction()` methods do not support confirmation modals, as clicking their buttons does not make the network request that is required to show the modal.
</Aside>

### Adding extra item actions to a repeater

You may add new [action buttons](../actions) to the header of each repeater item by passing `Action` objects into `extraItemActions()`:

```php
use Filament\Actions\Action;
use Filament\Forms\Components\Repeater;
use Filament\Forms\Components\TextInput;
use Filament\Support\Icons\Heroicon;
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
            ->icon(Heroicon::Envelope)
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

# Documentation for forms. File: 13-builder.md
---
title: Builder
---
import Aside from "@components/Aside.astro"
import AutoScreenshot from "@components/AutoScreenshot.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

Similar to a [repeater](repeater), the builder component allows you to output a JSON array of repeated form components. Unlike the repeater, which only defines one form schema to repeat, the builder allows you to define different schema "blocks", which you can repeat in any order. This makes it useful for building more advanced array structures.

The primary use of the builder component is to build web page content using predefined blocks. This could be content for a marketing website, or maybe even fields in an online form. The example below defines multiple blocks for different elements in the page content. On the frontend of your website, you could loop through each block in the JSON and format it how you wish.

```php
use Filament\Forms\Components\Builder;
use Filament\Forms\Components\Builder\Block;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;

Builder::make('content')
    ->blocks([
        Block::make('heading')
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
        Block::make('paragraph')
            ->schema([
                Textarea::make('content')
                    ->label('Paragraph')
                    ->required(),
            ]),
        Block::make('image')
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

<AutoScreenshot name="forms/fields/builder/simple" alt="Builder" version="4.x" />

We recommend that you store builder data with a `JSON` column in your database. Additionally, if you're using Eloquent, make sure that column has an `array` cast.

As evident in the above example, blocks can be defined within the `blocks()` method of the component. Blocks are `Builder\Block` objects, and require a unique name, and a component schema:

```php
use Filament\Forms\Components\Builder;
use Filament\Forms\Components\Builder\Block;
use Filament\Forms\Components\TextInput;

Builder::make('content')
    ->blocks([
        Block::make('heading')
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
use Filament\Forms\Components\Builder\Block;

Block::make('heading')
    ->label(__('blocks.heading'))
```

### Labelling builder items based on their content

You may add a label for a builder item using the same `label()` method. This method accepts a closure that receives the item's data in a `$state` variable. If `$state` is null, you should return the block label that should be displayed in the block picker. Otherwise, you should return a string to be used as the item label:

```php
use Filament\Forms\Components\Builder\Block;
use Filament\Forms\Components\TextInput;

Block::make('heading')
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

<UtilityInjection set="formFields" version="4.x" extras="Key;;string;;$key;;The key for the current block.||State;;array<string, mixed>;;$state;;The raw unvalidated data for the current block.">You can inject various utilities into the function passed to `label()` as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/builder/labelled" alt="Builder with labelled blocks based on the content" version="4.x" />

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

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `blockNumbers()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Setting a block's icon

Blocks may also have an [icon](../styling/icons), which is displayed next to the label. You can add an icon by passing its name to the `icon()` method:

```php
use Filament\Forms\Components\Builder\Block;
use Filament\Support\Icons\Heroicon;

Block::make('paragraph')
    ->icon(Heroicon::Bars3BottomLeft)
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `icon()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/builder/icons" alt="Builder with block icons in the dropdown" version="4.x" />

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

Optionally, you may pass a boolean value to the `blockIcons()` method to control if the icons are displayed in the block headers:

```php
use Filament\Forms\Components\Builder;

Builder::make('content')
    ->blocks([
        // ...
    ])
    ->blockIcons(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `blockIcons()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

Optionally, the `blockPreviews()` method accepts a boolean value to control if the builder should render block previews or not:

```php
use Filament\Forms\Components\Builder;

Builder::make('content')
    ->blocks([
        // ...
    ])
    ->blockPreviews(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing static values, the `blockPreviews()` and `preview()` methods also accept functions to dynamically calculate them. You can inject various utilities into the function as parameters.</UtilityInjection>

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

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `areInteractive` argument also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `addActionLabel()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `addActionAlignment()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `addable()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `deletable()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `reorderable()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

<AutoScreenshot name="forms/fields/builder/reorderable-with-buttons" alt="Builder that is reorderable with buttons" version="4.x" />

Optionally, you may pass a boolean value to control if the builder should be ordered with buttons or not:

```php
use Filament\Forms\Components\Builder;

Builder::make('content')
    ->blocks([
        // ...
    ])
    ->reorderableWithButtons(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `reorderableWithButtons()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `reorderableWithDragAndDrop()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

<AutoScreenshot name="forms/fields/builder/collapsed" alt="Collapsed builder" version="4.x" />

Optionally, the `collapsible()` and `collapsed()` methods accept a boolean value to control if the builder should be collapsible and collapsed or not:

```php
use Filament\Forms\Components\Builder;

Builder::make('content')
    ->blocks([
        // ...
    ])
    ->collapsible(FeatureFlag::active())
    ->collapsed(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing static values, the `collapsible()` and `collapsed()` methods also accept functions to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

<AutoScreenshot name="forms/fields/builder/cloneable" alt="Cloneable repeater" version="4.x" />

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

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `blockPickerColumns()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `blockPickerWidth()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Limiting the number of times a block can be used

By default, each block can be used in the builder an unlimited number of times. You may limit this using the `maxItems()` method on a block:

```php
use Filament\Forms\Components\Builder\Block;

Block::make('heading')
    ->schema([
        // ...
    ])
    ->maxItems(1)
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `maxItems()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Using `$get()` to access parent field values

All form components are able to [use `$get()` and `$set()`](overview#injecting-the-state-of-another-field) to access another field's value. However, you might experience unexpected behavior when using this inside the builder's schema.

This is because `$get()` and `$set()`, by default, are scoped to the current builder item. This means that you are able to interact with another field inside that builder item easily without knowing which builder item the current form component belongs to.

The consequence of this is that you may be confused when you are unable to interact with a field outside the builder. We use `../` syntax to solve this problem - `$get('../parent_field_name')`.

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

You can use `../` to go up a level in the data structure, so `$get('../client_id')` is `$get('builder.client_id')` and `$get('../client_id')` is `$get('client_id')`.

The special case of `$get()` with no arguments, or `$get('')` or `$get('./')`, will always return the full data array for the current builder item.

## Builder validation

As well as all rules listed on the [validation](validation) page, there are additional rules that are specific to builders.

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

<UtilityInjection set="formFields" version="4.x">As well as allowing static values, the `minItems()` and `maxItems()` methods also accept a function to dynamically calculate them. You can inject various utilities into the function as parameters.</UtilityInjection>

## Customizing the builder item actions

This field uses action objects for easy customization of buttons within it. You can customize these buttons by passing a function to an action registration method. The function has access to the `$action` object, which you can use to [customize it](../actions/overview). The following methods are available to customize the actions:

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
use Filament\Actions\Action;
use Filament\Forms\Components\Builder;

Builder::make('content')
    ->blocks([
        // ...
    ])
    ->collapseAllAction(
        fn (Action $action) => $action->label('Collapse all content'),
    )
```

<UtilityInjection set="formFields" version="4.x" extras="Action;;Filament\Actions\Action;;$action;;The action object to customize.">The action registration methods can inject various utilities into the function as parameters.</UtilityInjection>

### Confirming builder actions with a modal

You can confirm actions with a modal by using the `requiresConfirmation()` method on the action object. You may use any [modal customization method](../actions/modals) to change its content and behavior:

```php
use Filament\Actions\Action;
use Filament\Forms\Components\Builder;

Builder::make('content')
    ->blocks([
        // ...
    ])
    ->deleteAction(
        fn (Action $action) => $action->requiresConfirmation(),
    )
```

<Aside variant="info">
    The `addAction()`, `addBetweenAction()`, `collapseAction()`, `collapseAllAction()`, `expandAction()`, `expandAllAction()` and `reorderAction()` methods do not support confirmation modals, as clicking their buttons does not make the network request that is required to show the modal.
</Aside>

### Adding extra item actions to a builder

You may add new [action buttons](../actions) to the header of each builder item by passing `Action` objects into `extraItemActions()`:

```php
use Filament\Actions\Action;
use Filament\Forms\Components\Builder;
use Filament\Forms\Components\Builder\Block;
use Filament\Forms\Components\TextInput;
use Filament\Support\Icons\Heroicon;
use Illuminate\Support\Facades\Mail;

Builder::make('content')
    ->blocks([
        Block::make('contactDetails')
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
            ->icon(Heroicon::Square2Stack)
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

# Documentation for forms. File: 14-tags-input.md
---
title: Tags input
---
import Aside from "@components/Aside.astro"
import AutoScreenshot from "@components/AutoScreenshot.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

The tags input component allows you to interact with a list of tags.

By default, tags are stored in JSON:

```php
use Filament\Forms\Components\TagsInput;

TagsInput::make('tags')
```

<AutoScreenshot name="forms/fields/tags-input/simple" alt="Tags input" version="4.x" />

If you're saving the JSON tags using Eloquent, you should be sure to add an `array` [cast](https://laravel.com/docs/eloquent-mutators#array-and-json-casting) to the model property:

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
            'tags' => 'array',
        ];
    }

    // ...
}
```

<Aside variant="tip">
    Filament also supports [`spatie/laravel-tags`](https://github.com/spatie/laravel-tags). See our [plugin documentation](/plugins/filament-spatie-tags) for more information.
</Aside>

## Comma-separated tags

You may allow the tags to be stored in a separated string, instead of JSON. To set this up, pass the separating character to the `separator()` method:

```php
use Filament\Forms\Components\TagsInput;

TagsInput::make('tags')
    ->separator(',')
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `separator()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

<UtilityInjection set="formFields" version="4.x">As well as allowing a static array, the `suggestions()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Defining split keys

Split keys allow you to map specific buttons on your user's keyboard to create a new tag. By default, when the user presses "Enter", a new tag is created in the input. You may also define other keys to create new tags, such as "Tab" or " ". To do this, pass an array of keys to the `splitKeys()` method:

```php
use Filament\Forms\Components\TagsInput;

TagsInput::make('tags')
    ->splitKeys(['Tab', ' '])
```

You can [read more about possible options for keys](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key).

<UtilityInjection set="formFields" version="4.x">As well as allowing a static array, the `splitKeys()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Adding a prefix and suffix to individual tags

You can add prefix and suffix to tags without modifying the real state of the field. This can be useful if you need to show presentational formatting to users without saving it. This is done with the `tagPrefix()` or `tagSuffix()` method:

```php
use Filament\Forms\Components\TagsInput;

TagsInput::make('percentages')
    ->tagSuffix('%')
```

<UtilityInjection set="formFields" version="4.x">As well as allowing static values, the `tagPrefix()` and `tagSuffix()` methods also accept functions to dynamically calculate them. You can inject various utilities into the functions as parameters.</UtilityInjection>

## Reordering tags

You can allow the user to reorder tags within the field using the `reorderable()` method:

```php
use Filament\Forms\Components\TagsInput;

TagsInput::make('tags')
    ->reorderable()
```

Optionally, you may pass a boolean value to control if the tags should be reorderable or not:

```php
use Filament\Forms\Components\TagsInput;

TagsInput::make('tags')
    ->reorderable(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `reorderable()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Changing the color of tags

You can change the color of the tags by passing a [color](../styling/colors) to the `color()` method:

```php
use Filament\Forms\Components\TagsInput;

TagsInput::make('tags')
    ->color('danger')
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `color()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Trimming whitespace

You can automatically trim whitespace from the beginning and end of each tag using the `trim()` method:

```php
use Filament\Forms\Components\TagsInput;

TagsInput::make('tags')
    ->trim()
```

You may want to enable trimming globally for all tags inputs, similar to Laravel's `TrimStrings` middleware. You can do this in a service provider using the `configureUsing()` method:

```php
use Filament\Forms\Components\TagsInput;

TagsInput::configureUsing(function (TagsInput $component): void {
    $component->trim();
});
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

# Documentation for forms. File: 15-textarea.md
---
title: Textarea
---
import AutoScreenshot from "@components/AutoScreenshot.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

The textarea allows you to interact with a multi-line string:

```php
use Filament\Forms\Components\Textarea;

Textarea::make('description')
```

<AutoScreenshot name="forms/fields/textarea/simple" alt="Textarea" version="4.x" />

## Resizing the textarea

You may change the size of the textarea by defining the `rows()` and `cols()` methods:

```php
use Filament\Forms\Components\Textarea;

Textarea::make('description')
    ->rows(10)
    ->cols(20)
```

<UtilityInjection set="formFields" version="4.x">As well as allowing static values, the `rows()` and `cols()` methods also accept functions to dynamically calculate them. You can inject various utilities into the functions as parameters.</UtilityInjection>

### Autosizing the textarea

You may allow the textarea to automatically resize to fit its content by setting the `autosize()` method:

```php
use Filament\Forms\Components\Textarea;

Textarea::make('description')
    ->autosize()
```

Optionally, you may pass a boolean value to control if the textarea should be autosizeable or not:

```php
use Filament\Forms\Components\Textarea;

Textarea::make('description')
    ->autosize(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `autosize()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Making the field read-only

Not to be confused with [disabling the field](overview#disabling-a-field), you may make the field "read-only" using the `readOnly()` method:

```php
use Filament\Forms\Components\Textarea;

Textarea::make('description')
    ->readOnly()
```

There are a few differences, compared to [`disabled()`](overview#disabling-a-field):

- When using `readOnly()`, the field will still be sent to the server when the form is submitted. It can be mutated with the browser console, or via JavaScript. You can use [`dehydrated(false)`](overview#preventing-a-field-from-being-dehydrated) to prevent this.
- There are no styling changes, such as less opacity, when using `readOnly()`.
- The field is still focusable when using `readOnly()`.

Optionally, you may pass a boolean value to control if the field should be read-only or not:

```php
use Filament\Forms\Components\Textarea;

Textarea::make('description')
    ->readOnly(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `readOnly()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Disabling Grammarly checks

If the user has Grammarly installed and you would like to prevent it from analyzing the contents of the textarea, you can use the `disableGrammarly()` method:

```php
use Filament\Forms\Components\Textarea;

Textarea::make('description')
    ->disableGrammarly()
```

Optionally, you may pass a boolean value to control if the field should disable Grammarly checks or not:

```php
use Filament\Forms\Components\Textarea;

Textarea::make('description')
    ->disableGrammarly(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `disableGrammarly()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Trimming whitespace

You can automatically trim whitespace from the beginning and end of the textarea value using the `trim()` method:

```php
use Filament\Forms\Components\Textarea;

Textarea::make('description')
    ->trim()
```

You may want to enable trimming globally for all textareas, similar to Laravel's `TrimStrings` middleware. You can do this in a service provider using the `configureUsing()` method:

```php
use Filament\Forms\Components\Textarea;

Textarea::configureUsing(function (Textarea $component): void {
    $component->trim();
});
```

## Textarea validation

As well as all rules listed on the [validation](validation) page, there are additional rules that are specific to textareas.

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

<UtilityInjection set="formFields" version="4.x">As well as allowing static values, the `minLength()`, `maxLength()` and `length()` methods also accept a function to dynamically calculate them. You can inject various utilities into the function as parameters.</UtilityInjection>

# Documentation for forms. File: 16-key-value.md
---
title: Key-value
---
import AutoScreenshot from "@components/AutoScreenshot.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

The key-value field allows you to interact with one-dimensional JSON object:

```php
use Filament\Forms\Components\KeyValue;

KeyValue::make('meta')
```

<AutoScreenshot name="forms/fields/key-value/simple" alt="Key-value" version="4.x" />

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

## Adding rows

An action button is displayed below the field to allow the user to add a new row.

## Setting the add action button's label

You may set a label to customize the text that should be displayed in the button for adding a row, using the `addActionLabel()` method:

```php
use Filament\Forms\Components\KeyValue;

KeyValue::make('meta')
    ->addActionLabel('Add property')
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `addActionLabel()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Preventing the user from adding rows

You may prevent the user from adding rows using the `addable(false)` method:

```php
use Filament\Forms\Components\KeyValue;

KeyValue::make('meta')
    ->addable(false)
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `addable()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Deleting rows

An action button is displayed on each item to allow the user to delete it.

### Preventing the user from deleting rows

You may prevent the user from deleting rows using the `deletable(false)` method:

```php
use Filament\Forms\Components\KeyValue;

KeyValue::make('meta')
    ->deletable(false)
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `deletable()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Editing keys

### Customizing the key fields' label

You may customize the label for the key fields using the `keyLabel()` method:

```php
use Filament\Forms\Components\KeyValue;

KeyValue::make('meta')
    ->keyLabel('Property name')
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `keyLabel()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Adding key field placeholders

You may also add placeholders for the key fields using the `keyPlaceholder()` method:

```php
use Filament\Forms\Components\KeyValue;

KeyValue::make('meta')
    ->keyPlaceholder('Property name')
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `keyPlaceholder()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Preventing the user from editing keys

You may prevent the user from editing keys using the `editableKeys(false)` method:

```php
use Filament\Forms\Components\KeyValue;

KeyValue::make('meta')
    ->editableKeys(false)
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `editableKeys()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Editing values

### Customizing the value fields' label

You may customize the label for the value fields using the `valueLabel()` method:

```php
use Filament\Forms\Components\KeyValue;

KeyValue::make('meta')
    ->valueLabel('Property value')
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `valueLabel()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Adding value field placeholders

You may also add placeholders for the value fields using the `valuePlaceholder()` method:

```php
use Filament\Forms\Components\KeyValue;

KeyValue::make('meta')
    ->valuePlaceholder('Property value')
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `valuePlaceholder()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Preventing the user from editing values

You may prevent the user from editing values using the `editableValues(false)` method:

```php
use Filament\Forms\Components\KeyValue;

KeyValue::make('meta')
    ->editableValues(false)
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `editableValues()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Reordering rows

You can allow the user to reorder rows within the table using the `reorderable()` method:

```php
use Filament\Forms\Components\KeyValue;

KeyValue::make('meta')
    ->reorderable()
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `reorderable()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/key-value/reorderable" alt="Key-value with reorderable rows" version="4.x" />

## Customizing the key-value action objects

This field uses action objects for easy customization of buttons within it. You can customize these buttons by passing a function to an action registration method. The function has access to the `$action` object, which you can use to [customize it](../actions/overview). The following methods are available to customize the actions:

- `addAction()`
- `deleteAction()`
- `reorderAction()`

Here is an example of how you might customize an action:

```php
use Filament\Actions\Action;
use Filament\Forms\Components\KeyValue;
use Filament\Support\Icons\Heroicon;

KeyValue::make('meta')
    ->deleteAction(
        fn (Action $action) => $action->icon(Heroicon::XMark),
    )
```

<UtilityInjection set="formFields" version="4.x" extras="Action;;Filament\Actions\Action;;$action;;The action object to customize.">The action registration methods can inject various utilities into the function as parameters.</UtilityInjection>

# Documentation for forms. File: 17-color-picker.md
---
title: Color picker
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Introduction

The color picker component allows you to pick a color in a range of formats.

By default, the component uses HEX format:

```php
use Filament\Forms\Components\ColorPicker;

ColorPicker::make('color')
```

<AutoScreenshot name="forms/fields/color-picker/simple" alt="Color picker" version="4.x" />

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
    ->regex('/^#([a-fA-F0-9]{6}|[a-fA-F0-9]{3})\b$/')

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

# Documentation for forms. File: 18-toggle-buttons.md
---
title: Toggle buttons
---
import AutoScreenshot from "@components/AutoScreenshot.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

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

<UtilityInjection set="formFields" version="4.x">As well as allowing a static array, the `options()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/toggle-buttons/simple" alt="Toggle buttons" version="4.x" />

## Changing the color of option buttons

You can change the [color](../styling/colors) of the option buttons using the `colors()` method. Each key in the array should correspond to an option value:

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

If you are using an enum for the options, you can use the [`HasColor` interface](../advanced/enums#enum-colors) to define colors instead.

<UtilityInjection set="formFields" version="4.x">As well as allowing a static array, the `colors()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/toggle-buttons/colors" alt="Toggle buttons with different colors" version="4.x" />

## Adding icons to option buttons

You can add [icon](../styling/icons) to the option buttons using the `icons()` method. Each key in the array should correspond to an option value, and the value may be any valid [icon](../styling/icons):

```php
use Filament\Forms\Components\ToggleButtons;
use Filament\Support\Icons\Heroicon;

ToggleButtons::make('status')
    ->options([
        'draft' => 'Draft',
        'scheduled' => 'Scheduled',
        'published' => 'Published'
    ])
    ->icons([
        'draft' => Heroicon::OutlinedPencil,
        'scheduled' => Heroicon::OutlinedClock,
        'published' => Heroicon::OutlinedCheckCircle,
    ])
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static array, the `icons()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

If you are using an enum for the options, you can use the [`HasIcon` interface](../advanced/enums#enum-icons) to define icons instead.

<AutoScreenshot name="forms/fields/toggle-buttons/icons" alt="Toggle buttons with icons" version="4.x" />

If you want to display only icons, you can use `hiddenButtonLabels()` to hide the option labels.

## Boolean options

If you want a simple boolean toggle button group, with "Yes" and "No" options, you can use the `boolean()` method:

```php
use Filament\Forms\Components\ToggleButtons;

ToggleButtons::make('feedback')
    ->label('Like this post?')
    ->boolean()
```

The options will have [colors](#changing-the-color-of-option-buttons) and [icons](#adding-icons-to-option-buttons) set up automatically, but you can override these with `colors()` or `icons()`.

<AutoScreenshot name="forms/fields/toggle-buttons/boolean" alt="Boolean toggle buttons" version="4.x" />

To customize the "Yes" label, you can use the `trueLabel` argument on the `boolean()` method:

```php
use Filament\Forms\Components\ToggleButtons;

ToggleButtons::make('feedback')
    ->label('Like this post?')
    ->boolean(trueLabel: 'Absolutely!')
```

To customize the "No" label, you can use the `falseLabel` argument on the `boolean()` method:

```php
use Filament\Forms\Components\ToggleButtons;

ToggleButtons::make('feedback')
    ->label('Like this post?')
    ->boolean(falseLabel: 'Not at all!')
```

## Positioning the options inline with each other

You may wish to display the buttons `inline()` with each other:

```php
use Filament\Forms\Components\ToggleButtons;

ToggleButtons::make('feedback')
    ->label('Like this post?')
    ->boolean()
    ->inline()
```

<AutoScreenshot name="forms/fields/toggle-buttons/inline" alt="Inline toggle buttons" version="4.x" />

Optionally, you may pass a boolean value to control if the buttons should be inline or not:

```php
use Filament\Forms\Components\ToggleButtons;

ToggleButtons::make('feedback')
    ->label('Like this post?')
    ->boolean()
    ->inline(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `inline()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Grouping option buttons

You may wish to group option buttons together so they are more compact, using the `grouped()` method. This also makes them appear horizontally inline with each other:

```php
use Filament\Forms\Components\ToggleButtons;

ToggleButtons::make('feedback')
    ->label('Like this post?')
    ->boolean()
    ->grouped()
```

<AutoScreenshot name="forms/fields/toggle-buttons/grouped" alt="Grouped toggle buttons" version="4.x" />

Optionally, you may pass a boolean value to control if the buttons should be grouped or not:

```php
use Filament\Forms\Components\ToggleButtons;

ToggleButtons::make('feedback')
    ->label('Like this post?')
    ->boolean()
    ->grouped(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `grouped()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

<AutoScreenshot name="forms/fields/toggle-buttons/multiple" alt="Multiple toggle buttons selected" version="4.x" />

These options are returned in JSON format. If you're saving them using Eloquent, you should be sure to add an `array` [cast](https://laravel.com/docs/eloquent-mutators#array-and-json-casting) to the model property:

```php
use Illuminate\Database\Eloquent\Model;

class App extends Model
{
    /**
     * @return array<string, string>
     */
    protected function casts(): array
    { 
        return [
            'technologies' => 'array',
        ];
    }

    // ...
}
```

Optionally, you may pass a boolean value to control if the buttons should allow multiple selections or not:

```php
use Filament\Forms\Components\ToggleButtons;

ToggleButtons::make('technologies')
    ->multiple(FeatureFlag::active())
    ->options([
        'tailwind' => 'Tailwind CSS',
        'alpine' => 'Alpine.js',
        'laravel' => 'Laravel',
        'livewire' => 'Laravel Livewire',
    ])
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `multiple()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `columns()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/toggle-buttons/columns" alt="Toggle buttons with 2 columns" version="4.x" />

This method accepts the same options as the `columns()` method of the [grid](../schemas/layouts#grid-system). This allows you to responsively customize the number of columns at various breakpoints.

### Setting the grid direction

By default, when you arrange buttons into columns, they will be listed in order vertically. If you'd like to list them horizontally, you may use the `gridDirection(GridDirection::Row)` method:

```php
use Filament\Forms\Components\ToggleButtons;
use Filament\Support\Enums\GridDirection;

ToggleButtons::make('technologies')
    ->options([
        // ...
    ])
    ->columns(2)
    ->gridDirection(GridDirection::Row)
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `gridDirection()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/toggle-buttons/rows" alt="Toggle buttons with 2 rows" version="4.x" />

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

<UtilityInjection set="formFields" version="4.x" extras="Option value;;mixed;;$value;;The value of the option to disable.||Option label;;string | Illuminate\Contracts\Support\Htmlable;;$label;;The label of the option to disable.">You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/toggle-buttons/disabled-option" alt="Toggle buttons with disabled option" version="4.x" />

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

For more information about the `in()` function, please see the [Validation documentation](validation#in).

# Documentation for forms. File: 19-slider.md
---
title: Slider
---
import Aside from "@components/Aside.astro"
import AutoScreenshot from "@components/AutoScreenshot.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

The slider component allows you to drag a handle across a track to select one or more numeric values:

```php
use Filament\Forms\Components\Slider;

Slider::make('slider')
```

<AutoScreenshot name="forms/fields/slider/simple" alt="Slider" version="4.x" />

The [noUiSlider](https://refreshless.com/nouislider) package is used for this component, and much of its API is based upon that library.

<Aside variant="warning">
    Due to their nature, slider fields can never be empty. The value of the field can never be `null` or an empty array. If a slider field is empty, the user will not have a handle to drag across the track.

    Because of this, slider fields have a default value set out of the box, which is set to the minimum value allowed in the [range](#controlling-the-range-of-the-slider) of the slider. The default value is used when a form is empty, for example on the Create page of a resource. To learn more about default values, check out the [`default()` documentation](overview#setting-the-default-value-of-a-field).
</Aside>

## Controlling the range of the slider

The minimum and maximum values that can be selected by the slider are 0 and 100 by default. Filament will automatically apply validation rules to ensure that users cannot exceed these values. You can adjust these with the `range()` method:

```php
use Filament\Forms\Components\Slider;

Slider::make('slider')
    ->range(minValue: 40, maxValue: 80)
```

<UtilityInjection set="formFields" version="4.x">As well as allowing static values, the `range()` method also accepts functions to dynamically calculate them. You can inject various utilities into the functions as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/slider/range" alt="Slider with a customized range" version="4.x" />

### Controlling the step size

By default, users can select any decimal value between the minimum and maximum. You can restrict the values to a specific step size using the `step()` method. Filament will automatically apply validation rules to ensure that users cannot deviate from this step size:

```php
use Filament\Forms\Components\Slider;

Slider::make('slider')
    ->range(minValue: 0, maxValue: 100)
    ->step(10)
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `step()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Limiting the number of decimal places

If you would rather allow the user to select any decimal value between the minimum and maximum instead of restricting them to a certain step size, you can define a number of decimal places that their selected values will be rounded to using the `decimalPlaces()` method:

```php
use Filament\Forms\Components\Slider;

Slider::make('slider')
    ->range(minValue: 0, maxValue: 100)
    ->decimalPlaces(2)
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `decimalPlaces()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Controlling the behavioral padding of the track

By default, users can select any value across the entire length of the track. You can add behavioral padding to the track using the `rangePadding()` method. This will ensure that the selected value is always at least a certain distance from the edges of the track. The minimum and maximum value validation that Filament applies to the slider by default will take the padding into account to ensure that users cannot exceed the padded range:

```php
use Filament\Forms\Components\Slider;

Slider::make('slider')
    ->range(minValue: 0, maxValue: 100)
    ->rangePadding(10)
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `rangePadding()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

In this example, even though the minimum value is 0 and the maximum value is 100, the user will only be able to select values between 10 and 90. The padding will be applied to both ends of the track, so the selected value will always be at least 10 units away from the edges of the track.

If you would like to control the padding on each side of the track separately, you can pass an array of two values to the `rangePadding()` method. The first value will be applied to the start of the track, and the second value will be applied to the end of the track:

```php
use Filament\Forms\Components\Slider;

Slider::make('slider')
    ->range(minValue: 0, maxValue: 100)
    ->rangePadding([10, 20])
```

### Right-to-left tracks

By default, a track operates left-to-right. If the user is using a right-to-left locale (e.g. Arabic), the track will be displayed right-to-left automatically. You can also force the track to be displayed right-to-left using the `rtl()` method:

```php
use Filament\Forms\Components\Slider;

Slider::make('slider')
    ->range(minValue: 0, maxValue: 100)
    ->rtl()
```

Optionally, you may pass a boolean value to control if the slider should be right-to-left or not:

```php
use Filament\Forms\Components\Slider;

Slider::make('slider')
    ->range(minValue: 0, maxValue: 100)
    ->rtl(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `rtl()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Adding multiple values to a slider

If the slider is set to an array of values, the user will be able to drag multiple handles across the track within the allowed range. Make sure that the slider has a [`default()` value](overview#setting-the-default-value-of-a-field) set to an array of values to use when a form is empty:

```php
use Filament\Forms\Components\Slider;

Slider::make('slider')
    ->range(minValue: 0, maxValue: 100)
    ->default([20, 70])
```

<AutoScreenshot name="forms/fields/slider/multiple" alt="Slider with multiple values" version="4.x" />

If you're saving multiple slider values using Eloquent, you should be sure to add an `array` [cast](https://laravel.com/docs/eloquent-mutators#array-and-json-casting) to the model property:

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
            'slider' => 'array',
        ];
    }

    // ...
}
```

## Using a vertical track

You can display the slider as a vertical track instead of horizontal, you can use the `vertical()` method:

```php
use Filament\Forms\Components\Slider;

Slider::make('slider')
    ->range(minValue: 0, maxValue: 100)
    ->vertical()
```

<AutoScreenshot name="forms/fields/slider/vertical" alt="Vertical slider" version="4.x" />

Optionally, you may pass a boolean value to control if the slider should be vertical or not:

```php
use Filament\Forms\Components\Slider;

Slider::make('slider')
    ->range(minValue: 0, maxValue: 100)
    ->vertical(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `vertical()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Top-to-bottom tracks

By default, a vertical track operates bottom-to-top. In [noUiSlider](https://refreshless.com/nouislider), this is the [right-to-left behavior](#right-to-left-tracks). To assign the minimum value to the top of the track, you can use the `rtl(false)` method:

```php
use Filament\Forms\Components\Slider;

Slider::make('slider')
    ->range(minValue: 0, maxValue: 100)
    ->vertical()
    ->rtl(false)
```

## Adding tooltips to handles

You can add tooltips to the handles of the slider using the `tooltips()` method. The tooltip will display the current value of the handle:

```php
use Filament\Forms\Components\Slider;

Slider::make('slider')
    ->range(minValue: 0, maxValue: 100)
    ->tooltips()
```

<AutoScreenshot name="forms/fields/slider/tooltips" alt="Slider with tooltips" version="4.x" />

Optionally, you may pass a boolean value to control if the slider should have tooltips or not:

```php
use Filament\Forms\Components\Slider;

Slider::make('slider')
    ->range(minValue: 0, maxValue: 100)
    ->tooltips(FeatureFlag::active())
```

When using multiple handles, multiple tooltips will be displayed, one for each handle. Tooltips also work with [vertical tracks](#using-a-vertical-track).

<AutoScreenshot name="forms/fields/slider/tooltips-vertical" alt="Vertical slider with tooltips" version="4.x" />

### Custom tooltip formatting

You can use JavaScript to customize the formatting of a tooltip. Pass a `RawJs` object to the `tooltips()` method, containing a JavaScript string expression to use. The current value to format will be available in the `$value` variable:

```php
use Filament\Forms\Components\Slider;
use Filament\Support\RawJs;

Slider::make('slider')
    ->range(minValue: 0, maxValue: 100)
    ->tooltips(RawJs::make(<<<'JS'
        `$${$value.toFixed(2)}`
        JS))
```

<AutoScreenshot name="forms/fields/slider/tooltips-formatting" alt="Slider with custom tooltip formatting" version="4.x" />

### Controlling tooltips for multiple handles individually

If the slider is set to an array of values, you can control the tooltips for each handle separately by passing an array of values to the `tooltips()` method. The first value will be applied to the first handle, and the second value will be applied to the second handle, and so on:

```php
use Filament\Forms\Components\Slider;

Slider::make('slider')
    ->range(minValue: 0, maxValue: 100)
    ->tooltips([true, false])
```

<AutoScreenshot name="forms/fields/slider/tooltips-multiple" alt="Slider with multiple tooltips" version="4.x" />

## Filling a track with color

By default, the color of the track is not affected by the position of any handles it has. When using an individual handle, you can fill the part of the track before the handle with color using the `fillTrack()` method:

```php
use Filament\Forms\Components\Slider;

Slider::make('slider')
    ->range(minValue: 0, maxValue: 100)
    ->fillTrack()
```

<AutoScreenshot name="forms/fields/slider/fill" alt="Slider with fill" version="4.x" />

Optionally, you may pass a boolean value to control if the slider should be filled or not:

```php
use Filament\Forms\Components\Slider;

Slider::make('slider')
    ->range(minValue: 0, maxValue: 100)
    ->fillTrack(FeatureFlag::active())
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `fillTrack()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

When using multiple handles, you must manually specify which parts of the track should be filled by passing an array of `true` and `false` values, one for each section. The total number of values should be one more than the number of handles. The first value will be applied to the section before the first handle, the second value will be applied to the section between the first and second handles, and so on:

```php
use Filament\Forms\Components\Slider;

Slider::make('slider')
    ->range(minValue: 0, maxValue: 100)
    ->fillTrack([false, true, false])
```

<AutoScreenshot name="forms/fields/slider/fill-multiple" alt="Slider with multiple fills" version="4.x" />

Filling also works on [vertical tracks](#using-a-vertical-track):

<AutoScreenshot name="forms/fields/slider/fill-vertical" alt="Vertical slider with fill" version="4.x" />

## Adding pips to tracks

You can add pips to tracks, which are small markers that indicate the position of the handles. You can add pips to the track using the `pips()` method:

```php
use Filament\Forms\Components\Slider;

Slider::make('slider')
    ->range(minValue: 0, maxValue: 100)
    ->pips()
```

<AutoScreenshot name="forms/fields/slider/pips" alt="Slider with pips" version="4.x" />

Pips also work when there are multiple handles:

<AutoScreenshot name="forms/fields/slider/pips-multiple" alt="Slider with multiple pips" version="4.x" />

You can also add pips to [vertical tracks](#using-a-vertical-track):

<AutoScreenshot name="forms/fields/slider/pips-vertical" alt="Vertical slider with pips" version="4.x" />

### Adjusting the density of pips

By default, pips are displayed at a density of `10`. This means that for every 10 units of the track, a pip will be displayed. You can adjust this density using the `density` parameter of the `pips()` method:

```php
use Filament\Forms\Components\Slider;

Slider::make('slider')
    ->range(minValue: 0, maxValue: 100)
    ->pips(density: 5)
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `density` parameter also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/slider/pips-density" alt="Slider with a custom pips density" version="4.x" />

### Custom pip label formatting

You can use JavaScript to customize the formatting of a pip label. Pass a `RawJs` object to the `pipsFormatter()` method, containing a JavaScript string expression to use. The current value to format will be available in the `$value` variable:

```php
use Filament\Forms\Components\Slider;
use Filament\Support\RawJs;

Slider::make('slider')
    ->range(minValue: 0, maxValue: 100)
    ->pips()
    ->pipsFormatter(RawJs::make(<<<'JS'
        `$${$value.toFixed(2)}`
        JS))
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `pipsFormatter()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/slider/pips-formatting" alt="Slider with custom pips formatting" version="4.x" />

### Adding pip labels to steps of the track

If you are using [steps](#controlling-the-step-size) to restrict the movement of the track, you can add a pip label to each step. To do this, pass a `PipsMode::Steps` object to the `pips()` method:

```php
use Filament\Forms\Components\Slider;
use Filament\Forms\Components\Slider\Enums\PipsMode;

Slider::make('slider')
    ->range(minValue: 0, maxValue: 100)
    ->step(10)
    ->pips(PipsMode::Steps)
```

<AutoScreenshot name="forms/fields/slider/pips-steps" alt="Slider with pips on steps" version="4.x" />

If you would like to add additional pips to the track without labels, you can [adjust the density](#adjusting-the-density-of-pips) of the pips as well:

```php
use Filament\Forms\Components\Slider;
use Filament\Forms\Components\Slider\Enums\PipsMode;

Slider::make('slider')
    ->range(minValue: 0, maxValue: 100)
    ->step(10)
    ->pips(PipsMode::Steps, density: 5)
```

<AutoScreenshot name="forms/fields/slider/pips-steps-density" alt="Slider with pips on steps and a custom density" version="4.x" />

### Adding pip labels to percentage positions of the track

If you would like to add pip labels to the track at specific percentage positions, you can pass a `PipsMode::Positions` object to the `pips()` method. The percentage positions need to be defined in the `pipsValues()` method in an array of numbers:

```php
use Filament\Forms\Components\Slider;
use Filament\Forms\Components\Slider\Enums\PipsMode;

Slider::make('slider')
    ->range(minValue: 0, maxValue: 100)
    ->pips(PipsMode::Positions)
    ->pipsValues([0, 25, 50, 75, 100])
```

<UtilityInjection set="formFields" version="4.x">As well as allowing static values, the `pipsValues()` method also accepts a function to dynamically calculate them. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/slider/pips-positions" alt="Slider with pips on positions" version="4.x" />

The [density](#adjusting-the-density-of-pips) still controls the spacing of the pips without labels.

### Adding a set number of pip labels to the track

If you would like to add a set number of pip labels to the track, you can pass a `PipsMode::Count` object to the `pips()` method. The number of pips need to be defined in the `pipsValues()` method:

```php
use Filament\Forms\Components\Slider;
use Filament\Forms\Components\Slider\Enums\PipsMode;

Slider::make('slider')
    ->range(minValue: 0, maxValue: 100)
    ->pips(PipsMode::Count)
    ->pipsValues(5)
```

<UtilityInjection set="formFields" version="4.x">As well as allowing static values, the `pipsValues()` method also accepts a function to dynamically calculate them. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/slider/pips-count" alt="Slider with a set number of pips" version="4.x" />

The [density](#adjusting-the-density-of-pips) still controls the spacing of the pips without labels.

### Adding pip labels to set values on the track

Instead of defining [percentage positions](#adding-pip-labels-to-percentage-positions-of-the-track) or a [set number](#adding-a-set-number-of-pip-labels-to-the-track) of pip labels, you can also define a set of values to use for the pip labels. To do this, pass a `PipsMode::Values` object to the `pips()` method. The values need to be defined in the `pipsValues()` method in an array of numbers:

```php
use Filament\Forms\Components\Slider;
use Filament\Forms\Components\Slider\Enums\PipsMode;

Slider::make('slider')
    ->range(minValue: 0, maxValue: 100)
    ->pips(PipsMode::Values)
    ->pipsValues([5, 15, 25, 35, 45, 55, 65, 75, 85, 95])
```

<UtilityInjection set="formFields" version="4.x">As well as allowing static values, the `pipsValues()` method also accepts a function to dynamically calculate them. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/slider/pips-values" alt="Slider with pips on values" version="4.x" />

The [density](#adjusting-the-density-of-pips) still controls the spacing of the pips without labels:

```php
use Filament\Forms\Components\Slider;
use Filament\Forms\Components\Slider\Enums\PipsMode;

Slider::make('slider')
    ->range(minValue: 0, maxValue: 100)
    ->pips(PipsMode::Values, density: 5)
    ->pipsValues([5, 15, 25, 35, 45, 55, 65, 75, 85, 95])
```

<AutoScreenshot name="forms/fields/slider/pips-values-density" alt="Slider with pips on values and a custom density" version="4.x" />

### Manually filtering pips

For even more control over how pips are displayed on a track, you can use a JavaScript expression. The JavaScript expression should return different numbers based on the pip's appearance:

- The expression should return `1` if a large pip label should be displayed.
- The expression should return `2` if a small pip label should be displayed.
- The expression should return `0` if a pip should be displayed without a label.
- The expression should return `-1` if a pip should not be displayed at all.

The [density](#adjusting-the-density-of-pips) of the pips will control which values get passed to the JavaScript expression. The expression should use the `$value` variable to access the current value of the pip. The expression should be defined in a `RawJs` object and passed to the `pipsFilter()` method:

```php
use Filament\Forms\Components\Slider;
use Filament\Support\RawJs;

Slider::make('slider')
    ->range(minValue: 0, maxValue: 100)
    ->pips(density: 5)
    ->pipsFilter(RawJs::make(<<<'JS'
        ($value % 50) === 0
            ? 1
            : ($value % 10) === 0
                ? 2
                : ($value % 25) === 0
                    ? 0
                    : -1
        JS))
```

<UtilityInjection set="formFields" version="4.x">As well as allowing static values, the `pipsFilter()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

In this example the `%` operator is used to determine the divisibility of the pip value. The expression will return `1` for every 50 units, `2` for every 10 units, `0` for every 25 units, and `-1` for all other values:

<AutoScreenshot name="forms/fields/slider/pips-filter" alt="Slider with pips filter" version="4.x" />

## Setting a minimum difference between handles

To set a minimum distance between handles, you can use the `minDifference()` method, passing a number to it. This represents the real difference between the values of both handles, not their visual distance:

```php
use Filament\Forms\Components\Slider;

Slider::make('slider')
    ->range(minValue: 0, maxValue: 100)
    ->minDifference(10)
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `minDifference()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<Aside variant="warning">
    The `minDifference()` method does not impact the validation of the slider. A skilled user could manipulate the value of the slider using JavaScript to select a value that does not align with the minimum difference. They will still be prevented from selecting a value outside the range of the slider.
</Aside>

## Setting a maximum difference between handles

To set a maximum distance between handles, you can use the `maxDifference()` method, passing a number to it. This represents the real difference between the values of both handles, not their visual distance:

```php
use Filament\Forms\Components\Slider;

Slider::make('slider')
    ->range(minValue: 0, maxValue: 100)
    ->maxDifference(40)
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `maxDifference()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<Aside variant="warning">
    The `maxDifference()` method does not impact the validation of the slider. A skilled user could manipulate the value of the slider using JavaScript to select a value that does not align with the maximum difference. They will still be prevented from selecting a value outside the range of the slider.
</Aside>

## Controlling the general behavior of the slider

The `behavior()` method of the slider allows you to pass one or more `Behavior` objects to control the behavior of the slider. The available options are:

- `Behavior::Tap` - The slider will smoothly move to the position of the tap when the user clicks on the track. This is a default behavior, so when applying another behavior, you should also include this one in the array if you want to preserve it.
- `Behavior::Drag` - When there are two handles on the track, the user can drag the track to move both handles at the same time. The [`fillTrack([false, true, false])`](#filling-a-track-with-color) method must be used to ensure that the user has something to drag.
- `Behavior::Drag` and `Behavior::Fixed` - When there are two handles on the track, the user can drag the track to move both handles at the same time, but they cannot change the distance between them. The [`fillTrack([false, true, false])`](#filling-a-track-with-color) method must be used to ensure that the user has something to drag. Be aware that the distance between the handles is not automatically validated on the backend, so a skilled user could manipulate the value of the slider using JavaScript to select a value with a different distance. They will still be prevented from selecting a value outside the range of the slider.
- `Behavior::Unconstrained` - When there are multiple handles on the track, they can be dragged past each other. The [`minDifference()`](#setting-a-minimum-difference-between-handles) and [`maxDifference()`](#setting-a-maximum-difference-between-handles) methods will not work with this behavior.
- `Behavior::SmoothSteps` - While dragging handles, they will not snap to the [steps](#controlling-the-step-size) of the track. Once the user releases the handle, it will snap to the nearest step.

For example, to use `Behavior::Tap`, `Behavior::Drag` and `Behavior::SmoothSteps` all at once:

```php
use Filament\Forms\Components\Slider;
use Filament\Forms\Components\Slider\Enums\Behavior;

Slider::make('slider')
    ->range(minValue: 0, maxValue: 100)
    ->behavior([Behavior::Tap, Behavior::Drag, Behavior::SmoothSteps])
```

To disable all behavior, including the default `Behavior::Tap`, you can use the `behavior(null)` method:

```php
use Filament\Forms\Components\Slider;

Slider::make('slider')
    ->range(minValue: 0, maxValue: 100)
    ->behavior(null)
```

## Non-linear tracks

You can create non-linear tracks, where certain parts of the track are compressed or expanded, by defining an array of percentage points in the `nonLinearPoints()` method of the slider. Each percentage key of the array should have a corresponding real value, which will be used to calculate the position of the handle on the track. The example below features [pips](#adding-pips-to-tracks) to demonstrate the non-linear behavior of the track:

```php
use Filament\Forms\Components\Slider;

Slider::make('slider')
    ->range(minValue: 0, maxValue: 100)
    ->nonLinearPoints(['20%' => 50, '50%' => 75])
    ->pips()
```

<UtilityInjection set="formFields" version="4.x">As well as allowing static values, the `nonLinearPoints()` method also accepts a function to dynamically calculate them. You can inject various utilities into the function as parameters.</UtilityInjection>

When using a non-linear track, you can also control the stepping for each section. By defining an array of two numbers for each percentage point, the first number will be used as the real value for percentage position, and the second number will be used as the step size for that section, active until the next percentage point:

```php
use Filament\Forms\Components\Slider;

Slider::make('slider')
    ->range(minValue: 0, maxValue: 100)
    ->nonLinearPoints(['20%' => [50, 5], '50%' => [75, 1]])
    ->pips()
```

<Aside variant="warning">
    When using a non-linear track, the step values of certain track sections do not affect the validation of the slider. A skilled user could manipulate the value of the slider using JavaScript to select a value that does not align with a step value in the track. They will still be prevented from selecting a value outside the range of the slider.
</Aside>

When using [pips](#adding-pips-to-tracks) with a non-linear track, you can ensure that pip labels are rounded and only displayed at selectable positions on the track. Otherwise, the stepping of a non-linear portion of the track could add labels to positions that are not selectable. To do this, use the `steppedPips()` method:

```php
use Filament\Forms\Components\Slider;
use Filament\Forms\Components\Slider\Enums\PipsMode;

Slider::make('slider')
    ->range(minValue: 0, maxValue: 10000)
    ->nonLinearPoints(['10%' => [500, 500], '50%' => [4000, 1000]])
    ->pips(PipsMode::Positions, density: 4)
    ->pipsValues([0, 25, 50, 75, 100])
    ->steppedPips()
```

# Documentation for forms. File: 20-code-editor.md
---
title: Code editor
---
import AutoScreenshot from "@components/AutoScreenshot.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

The code editor component allows you to write code in a textarea with line numbers. By default, no syntax highlighting is applied.

```php
use Filament\Forms\Components\CodeEditor;

CodeEditor::make('code')
```

<AutoScreenshot name="forms/fields/code-editor/simple" alt="Code editor" version="4.x" />

## Using language syntax highlighting

You may change the language syntax highlighting of the code editor using the `language()` method. The editor supports the following languages:

- C++
- CSS
- Go
- HTML
- Java
- JavaScript
- JSON
- Markdown
- PHP
- Python
- XML
- YAML

You can open the `Filament\Forms\Components\CodeEditor\Enums\Language` enum class to see this list. To switch to using JavaScript syntax highlighting, you can use the `Language::JavaScript` enum value:

```php
use Filament\Forms\Components\CodeEditor;
use Filament\Forms\Components\CodeEditor\Enums\Language;

CodeEditor::make('code')
    ->language(Language::JavaScript)
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `language()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="forms/fields/code-editor/language" alt="Code editor with syntax highlighting" version="4.x" />

# Documentation for forms. File: 21-hidden.md
---
title: Hidden
---

## Introduction

The hidden component allows you to create a hidden field in your form that holds a value.

```php
use Filament\Forms\Components\Hidden;

Hidden::make('token')
```

Please be aware that the value of this field is still editable by the user if they decide to use the browser's developer tools. You should not use this component to store sensitive or read-only information.

# Documentation for forms. File: 22-custom-fields.md
---
title: Custom fields
---
import Aside from "@components/Aside.astro"

## Introduction

Livewire components are PHP classes that have their state stored in the user's browser. When a network request is made, the state is sent to the server, and filled into public properties on the Livewire component class, where it can be accessed in the same way as any other class property in PHP can be.

Imagine you had a Livewire component with a public property called `$name`. You could bind that property to an input field in the HTML of the Livewire component in one of two ways: with the [`wire:model` attribute](https://livewire.laravel.com/docs/properties#data-binding), or by [entangling](https://livewire.laravel.com/docs/javascript#the-wire-object) it with an Alpine.js property:

```blade
<x-dynamic-component
    :component="$getFieldWrapperView()"
    :field="$field"
>
    <input wire:model="name" />
    
    <!-- Or -->
    
    <div x-data="{ state: $wire.$entangle('name') }">
        <input x-model="state" />
    </div>
</x-dynamic-component>
```

When the user types into the input field, the `$name` property is updated in the Livewire component class. When the user submits the form, the `$name` property is sent to the server, where it can be saved.

This is the basis of how fields work in Filament. Each field is assigned to a public property in the Livewire component class, which is where the state of the field is stored. We call the name of this property the "state path" of the field. You can access the state path of a field using the `$getStatePath()` function in the field's view:

```blade
<x-dynamic-component
    :component="$getFieldWrapperView()"
    :field="$field"
>
    <input wire:model="{{ $getStatePath() }}" />

    <!-- Or -->
    
    <div x-data="{ state: $wire.$entangle('{{ $getStatePath() }}') }">
        <input x-model="state" />
    </div>
</x-dynamic-component>
```

If your component heavily relies on third party libraries, we advise that you asynchronously load the Alpine.js component using the Filament asset system. This ensures that the Alpine.js component is only loaded when it's needed, and not on every page load. To find out how to do this, check out our [Assets documentation](../assets#asynchronous-alpinejs-components).

### Custom field classes

You may create your own custom field classes and views, which you can reuse across your project, and even release as a plugin to the community.

To create a custom field class and view, you may use the following command:

```bash
php artisan make:filament-form-field LocationPicker
```

This will create the following component class:

```php
use Filament\Forms\Components\Field;

class LocationPicker extends Field
{
    protected string $view = 'filament.forms.components.location-picker';
}
```

It will also create a view file at `resources/views/filament/forms/components/location-picker.blade.php`.

<Aside variant="info">
    Filament form fields are **not** Livewire components. Defining public properties and methods on a form field class will not make them accessible in the Blade view.
</Aside>

## Accessing the state of another component in the Blade view

Inside the Blade view, you may access the state of another component in the schema using the `$get()` function:

```blade
<x-dynamic-component
    :component="$getFieldWrapperView()"
    :field="$field"
>
    {{ $get('email') }}
</x-dynamic-component>
```

<Aside variant="tip">
    Unless a form field is [reactive](../forms/overview#the-basics-of-reactivity), the Blade view will not refresh when the value of the field changes, only when the next user interaction occurs that makes a request to the server. If you need to react to changes in a field's value, it should be `live()`.
</Aside>

## Accessing the Eloquent record in the Blade view

Inside the Blade view, you may access the current Eloquent record using the `$record` variable:

```blade
<x-dynamic-component
    :component="$getFieldWrapperView()"
    :field="$field"
>
    {{ $record->name }}
</x-dynamic-component>
```

## Accessing the current operation in the Blade view

Inside the Blade view, you may access the current operation, usually `create`, `edit` or `view`, using the `$operation` variable:

```blade
<x-dynamic-component
    :component="$getFieldWrapperView()"
    :field="$field"
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
    :component="$getFieldWrapperView()"
    :field="$field"
>
    @if ($this instanceof ConferencesRelationManager)
        You are editing conferences the of a user.
    @endif
</x-dynamic-component>
```

## Accessing the current field instance in the Blade view

Inside the Blade view, you may access the current field instance using `$field`. You can call public methods on this object to access other information that may not be available in variables:

```blade
<x-dynamic-component
    :component="$getFieldWrapperView()"
    :field="$field"
>
    @if ($field->getState())
        This is a new conference.
    @endif
</x-dynamic-component>
```

## Adding a configuration method to a custom field class

You may add a public method to the custom field class that accepts a configuration value, stores it in a protected property, and returns it again from another public method:

```php
use Filament\Forms\Components\Field;

class LocationPicker extends Field
{
    protected string $view = 'filament.forms.components.location-picker';
    
    protected ?float $zoom = null;

    public function zoom(?float $zoom): static
    {
        $this->zoom = $zoom;

        return $this;
    }

    public function getZoom(): ?float
    {
        return $this->zoom;
    }
}
```

Now, in the Blade view for the custom field, you may access the zoom using the `$getZoom()` function:

```blade
<x-dynamic-component
    :component="$getFieldWrapperView()"
    :field="$field"
>
    {{ $getZoom() }}
</x-dynamic-component>
```

Any public method that you define on the custom field class can be accessed in the Blade view as a variable function in this way.

To pass the configuration value to the custom field class, you may use the public method:

```php
use App\Filament\Forms\Components\LocationPicker;

LocationPicker::make('location')
    ->zoom(0.5)
```

## Allowing utility injection in a custom field configuration method

[Utility injection](overview#field-utility-injection) is a powerful feature of Filament that allows users to configure a component using functions that can access various utilities. You can allow utility injection by ensuring that the parameter type and property type of the configuration allows the user to pass a `Closure`. In the getter method, you should pass the configuration value to the `$this->evaluate()` method, which will inject utilities into the user's function if they pass one, or return the value if it is static:

```php
use Closure;
use Filament\Forms\Components\Field;

class LocationPicker extends Field
{
    protected string $view = 'filament.forms.components.location-picker';
    
    protected float | Closure | null $zoom = null;

    public function zoom(float | Closure | null $zoom): static
    {
        $this->zoom = $zoom;

        return $this;
    }

    public function getZoom(): ?float
    {
        return $this->evaluate($this->zoom);
    }
}
```

Now, you can pass a static value or a function to the `zoom()` method, and [inject any utility](overview#component-utility-injection) as a parameter:

```php
use App\Filament\Forms\Components\LocationPicker;

LocationPicker::make('location')
    ->zoom(fn (Conference $record): float => $record->isGlobal() ? 1 : 0.5)
```

## Obeying state binding modifiers

When you bind a field to a state path, you may use the `defer` modifier to ensure that the state is only sent to the server when the user submits the form, or whenever the next Livewire request is made. This is the default behavior.

However, you may use the [`live()`](overview#the-basics-of-reactivity) on a field to ensure that the state is sent to the server immediately when the user interacts with the field. This allows for lots of advanced use cases as explained in the [reactivity](overview#the-basics-of-reactivity) section of the documentation.

Filament provides a `$applyStateBindingModifiers()` function that you may use in your view to apply any state binding modifiers to a `wire:model` or `$wire.$entangle()` binding:

```blade
<x-dynamic-component
    :component="$getFieldWrapperView()"
    :field="$field"
>
    <input {{ $applyStateBindingModifiers('wire:model') }}="{{ $getStatePath() }}" />
    
    <!-- Or -->
    
    <div x-data="{ state: $wire.{{ $applyStateBindingModifiers("\$entangle('{$getStatePath()}')") }} }">
        <input x-model="state" />
    </div>
</x-dynamic-component>
```

# Documentation for forms. File: 23-validation.md
---
title: Validation
---
import Aside from "@components/Aside.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

Validation rules may be added to any [field](overview#available-fields).

In Laravel, validation rules are usually defined in arrays like `['required', 'max:255']` or a combined string like `required|max:255`. This is fine if you're exclusively working in the backend with simple form requests. But Filament is also able to give your users frontend validation, so they can fix their mistakes before any backend requests are made.

Filament includes many [dedicated validation methods](#available-rules), but you can also use any [other Laravel validation rules](#other-rules), including [custom validation rules](#custom-rules).

<Aside variant="warning">
    Some default Laravel validation rules rely on the correct attribute names and won't work when passed via `rule()`/`rules()`. Use the dedicated validation methods whenever you can.
</Aside>

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

### Doesn't Start With

The field must not start with one of the given values. [See the Laravel documentation.](https://laravel.com/docs/validation#rule-doesnt-start-with)

```php
Field::make('name')->doesntStartWith(['admin'])
```

### Doesn't End With

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

By default, the form's model will be searched, [if it is registered](../components/form#setting-a-form-model). You may specify a custom table name or model to search:

```php
use App\Models\Invitation;

Field::make('invitation')->exists(table: Invitation::class)
```

By default, the field name will be used as the column to search. You may specify a custom column to search:

```php
Field::make('invitation')->exists(column: 'id')
```

You can further customize the rule by passing a [closure](overview#closure-customization) to the `modifyRuleUsing` parameter:

```php
use Illuminate\Validation\Rules\Exists;

Field::make('invitation')
    ->exists(modifyRuleUsing: function (Exists $rule) {
        return $rule->where('is_active', 1);
    })
```

Laravel's `exists` validation rule does not use the Eloquent model to query the database by default, so it will not use any global scopes defined on the model, including for soft-deletes. As such, even if there is a soft-deleted record with the same value, the validation will pass.

Since global scopes are not applied, Filament's multi-tenancy feature also does not scope the query to the current tenant by default.

To do this, you should use the `scopedExists()` method instead, which replaces Laravel's `exists` implementation with one that uses the model to query the database, applying any global scopes defined on the model, including for soft-deletes and multi-tenancy:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('email')
    ->scopedExists()
```

If you would like to modify the Eloquent query used to check for presence, including to remove a global scope, you can pass a function to the `modifyQueryUsing` parameter:

```php
use Filament\Forms\Components\TextInput;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

TextInput::make('email')
    ->scopedExists(modifyQueryUsing: function (Builder $query) {
        return $query->withoutGlobalScope(SoftDeletingScope::class);
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

The [toggle buttons](toggle-buttons), [checkbox list](checkbox-list), [radio](radio) and [select](select#valid-options-validation-in-rule) fields automatically apply the `in()` rule based on their available options, so you do not need to add it manually.

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

#### Marking a field as required

By default, required fields will show an asterisk `*` next to their label. You may want to hide the asterisk on forms where all fields are required, or where it makes sense to add a [hint](#adding-a-hint-next-to-the-label) to optional fields instead:

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

If your Filament form already has an Eloquent model associated with it, such as in a [panel resource](../resources), Filament will use that. You may also specify a custom table name or model to search:

```php
use App\Models\User;

Field::make('email')->unique(table: User::class)
```

By default, the field name will be used as the column to search. You may specify a custom column to search:

```php
Field::make('email')->unique(column: 'email_address')
```

Usually, you wish to ignore a given model during unique validation. For example, consider an "update profile" form that includes the user's name, email address, and location. You will probably want to verify that the email address is unique. However, if the user only changes the name field and not the email field, you do not want a validation error to be thrown because the user is already the owner of the email address in question. If your Filament form already has an Eloquent model associated with it, such as in a [panel resource](../resources), Filament will ignore it.

To prevent Filament from ignoring the current Eloquent record, you can pass `false` to the `ignoreRecord` parameter:

```php
Field::make('email')->unique(ignoreRecord: false)
```

Alternatively, to ignore an Eloquent record of your choice, you can pass it to the `ignorable` parameter:

```php
Field::make('email')->unique(ignorable: $ignoredUser)
```

You can further customize the rule by passing a [closure](overview#closure-customization) to the `modifyRuleUsing` parameter:

```php
use Illuminate\Validation\Rules\Unique;

Field::make('email')
    ->unique(modifyRuleUsing: function (Unique $rule) {
        return $rule->where('is_active', 1);
    })
```

Laravel's `unique` validation rule does not use the Eloquent model to query the database by default, so it will not use any global scopes defined on the model, including for soft-deletes. As such, even if there is a soft-deleted record with the same value, the validation will fail.

Since global scopes are not applied, Filament's multi-tenancy feature also does not scope the query to the current tenant by default.

To do this, you should use the `scopedUnique()` method instead, which replaces Laravel's `unique` implementation with one that uses the model to query the database, applying any global scopes defined on the model, including for soft-deletes and multi-tenancy:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('email')
    ->scopedUnique()
```

If you would like to modify the Eloquent query used to check for uniqueness, including to remove a global scope, you can pass a function to the `modifyQueryUsing` parameter:

```php
use Filament\Forms\Components\TextInput;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

TextInput::make('email')
    ->scopedUnique(modifyQueryUsing: function (Builder $query) {
        return $query->withoutGlobalScope(SoftDeletingScope::class);
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

You may [inject utilities](overview#field-utility-injection) like [`$get`](overview#injecting-the-state-of-another-field) into your custom rules, for example if you need to reference other field values in your form. To do this, wrap the closure rule in another function that returns it:

```php
use Filament\Schemas\Components\Utilities\Get;

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

TextInput::make('name')
    ->validationAttribute('full name')
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `validationAttribute()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

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

<UtilityInjection set="formFields" version="4.x">As well as allowing an array of static value, the `validationMessages()` method also accepts a function for each message. You can inject various utilities into the functions as parameters.</UtilityInjection>

### Allowing HTML in validation messages

By default, validation messages are rendered as plain text to prevent XSS attacks. However, you may need to render HTML in your validation messages, such as when displaying lists or links. To enable HTML rendering for validation messages, use the `allowHtmlValidationMessages()` method:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('password')
    ->required()
    ->rules([
        new CustomRule(), // Custom rule that returns a validation message that contains HTML
    ])
    ->allowHtmlValidationMessages()
```

Be aware that you will need to ensure that the HTML in all validation messages is safe to render, otherwise your application will be vulnerable to XSS attacks.

## Disabling validation when fields are not dehydrated

When a field is [not dehydrated](overview#preventing-a-field-from-being-dehydrated), it is still validated. To disable validation for fields that are not dehydrated, use the `validatedWhenNotDehydrated()` method:

```php
use Filament\Forms\Components\TextInput;

TextInput::make('name')
    ->required()
    ->dehydrated(false)
    ->validatedWhenNotDehydrated(false)
```

<UtilityInjection set="formFields" version="4.x">As well as allowing a static value, the `validatedWhenNotDehydrated()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

