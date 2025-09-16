# Documentation for actions. File: 01-overview.md
---
title: Overview
---
import Aside from "@components/Aside.astro"
import AutoScreenshot from "@components/AutoScreenshot.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

"Action" is a word that is used quite a bit within the Laravel community. Traditionally, action PHP classes handle "doing" something in your application's business logic. For instance, logging a user in, sending an email, or creating a new user record in the database.

In Filament, actions also handle "doing" something in your app. However, they are a bit different from traditional actions. They are designed to be used in the context of a user interface. For instance, you might have a button to delete a client record, which opens a modal to confirm your decision. When the user clicks the "Delete" button in the modal, the client is deleted. This whole workflow is an "action".

```php
use Filament\Actions\Action;

Action::make('delete')
    ->requiresConfirmation()
    ->action(fn () => $this->client->delete())
```

Actions can also collect extra information from the user. For instance, you might have a button to email a client. When the user clicks the button, a modal opens to collect the email subject and body. When the user clicks the "Send" button in the modal, the email is sent:

```php
use Filament\Actions\Action;
use Filament\Forms\Components\RichEditor;
use Filament\Forms\Components\TextInput;
use Illuminate\Support\Facades\Mail;

Action::make('sendEmail')
    ->schema([
        TextInput::make('subject')->required(),
        RichEditor::make('body')->required(),
    ])
    ->action(function (array $data) {
        Mail::to($this->client)
            ->send(new GenericEmail(
                subject: $data['subject'],
                body: $data['body'],
            ));
    })
```

<UtilityInjection set="actions" version="4.x">As well as `$data`, the `action()` function can inject various utilities as parameters.</UtilityInjection>

Usually, actions get executed without redirecting the user away from the page. This is because we extensively use Livewire. However, actions can be much simpler, and don't even need a modal. You can pass a URL to an action, and when the user clicks on the button, they are redirected to that page:

```php
use Filament\Actions\Action;

Action::make('edit')
    ->url(fn (): string => route('posts.edit', ['post' => $this->post]))
```

<UtilityInjection set="actions" version="4.x">As well as allowing a static value, the `url()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

The entire look of the action's trigger button and the modal is customizable using fluent PHP methods. We provide a sensible and consistent styling for the UI, but all of this is customizable with CSS.

## Available actions

Filament includes several actions that you can add to your app. Their aim is to simplify the most common Eloquent-related actions:

- [Create](create)
- [Edit](edit)
- [View](view)
- [Delete](delete)
- [Replicate](replicate)
- [Force-delete](force-delete)
- [Restore](restore)
- [Import](import)
- [Export](export)

You can also create your own actions to do anything, these are just common ones that we include out of the box.

## Choosing a trigger style

Out of the box, action triggers have 4 styles - "button", "link", "icon button", and "badge".

"Button" triggers have a background color, label, and optionally an [icon](#setting-an-icon). Usually, this is the default button style, but you can use it manually with the `button()` method:

```php
use Filament\Actions\Action;

Action::make('edit')
    ->button()
```

<AutoScreenshot name="actions/trigger-button/button" alt="Button trigger" version="4.x" />

"Link" triggers have no background color. They must have a label and optionally an [icon](#setting-an-icon). They look like a link that you might find embedded within text. You can switch to that style with the `link()` method:

```php
use Filament\Actions\Action;

Action::make('edit')
    ->link()
```

<AutoScreenshot name="actions/trigger-button/link" alt="Link trigger" version="4.x" />

"Icon button" triggers are circular buttons with an [icon](#setting-an-icon) and no label. You can switch to that style with the `iconButton()` method:

```php
use Filament\Actions\Action;

Action::make('edit')
    ->icon('heroicon-m-pencil-square')
    ->iconButton()
```

<AutoScreenshot name="actions/trigger-button/icon-button" alt="Icon button trigger" version="4.x" />

"Badge" triggers have a background color, label, and optionally an [icon](#setting-an-icon). You can use a badge as trigger using the `badge()` method:

```php
use Filament\Actions\Action;

Action::make('edit')
    ->badge()
```

<AutoScreenshot name="actions/trigger-button/badge" alt="Badge trigger" version="4.x" />

### Using an icon button on mobile devices only

You may want to use a button style with a label on desktop, but remove the label on mobile. This will transform it into an icon button. You can do this with the `labeledFrom()` method, passing in the responsive [breakpoint](https://tailwindcss.com/docs/responsive-design#overview) at which you want the label to be added to the button:

```php
use Filament\Actions\Action;

Action::make('edit')
    ->icon('heroicon-m-pencil-square')
    ->button()
    ->labeledFrom('md')
```

## Setting a label

By default, the label of the trigger button is generated from its name. You may customize this using the `label()` method:

```php
use Filament\Actions\Action;

Action::make('edit')
    ->label('Edit post')
    ->url(fn (): string => route('posts.edit', ['post' => $this->post]))
```

<UtilityInjection set="actions" version="4.x">As well as allowing a static value, the `label()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Setting a color

Buttons may have a [color](../styling/colors) to indicate their significance:

```php
use Filament\Actions\Action;

Action::make('delete')
    ->color('danger')
```

<UtilityInjection set="actions" version="4.x">As well as allowing a static value, the `color()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="actions/trigger-button/danger" alt="Red trigger" version="4.x" />

## Setting a size

Buttons come in 3 sizes - `Size::Small`, `Size::Medium` or `Size::Large`. You can change the size of the action's trigger using the `size()` method:

```php
use Filament\Actions\Action;
use Filament\Support\Enums\Size;

Action::make('create')
    ->size(Size::Large)
```

<UtilityInjection set="actions" version="4.x">As well as allowing a static value, the `size()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="actions/trigger-button/large" alt="Large trigger" version="4.x" />

## Setting an icon

Buttons may have an [icon](../styling/icons) to add more detail to the UI. You can set the icon using the `icon()` method:

```php
use Filament\Actions\Action;

Action::make('edit')
    ->url(fn (): string => route('posts.edit', ['post' => $this->post]))
    ->icon('heroicon-m-pencil-square')
```

<UtilityInjection set="actions" version="4.x">As well as allowing a static value, the `icon()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="actions/trigger-button/icon" alt="Trigger with icon" version="4.x" />

You can also change the icon's position to be after the label instead of before it, using the `iconPosition()` method:

```php
use Filament\Actions\Action;
use Filament\Support\Enums\IconPosition;

Action::make('edit')
    ->url(fn (): string => route('posts.edit', ['post' => $this->post]))
    ->icon('heroicon-m-pencil-square')
    ->iconPosition(IconPosition::After)
```

<UtilityInjection set="actions" version="4.x">As well as allowing a static value, the `iconPosition()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="actions/trigger-button/icon-after" alt="Trigger with icon after the label" version="4.x" />

## Authorization

You may conditionally show or hide actions for certain users. To do this, you can use either the `visible()` or `hidden()` methods:

```php
use Filament\Actions\Action;

Action::make('edit')
    ->url(fn (): string => route('posts.edit', ['post' => $this->post]))
    ->visible(auth()->user()->can('update', $this->post))

Action::make('edit')
    ->url(fn (): string => route('posts.edit', ['post' => $this->post]))
    ->hidden(! auth()->user()->can('update', $this->post))
```

This is useful for authorization of certain actions to only users who have permission.

<UtilityInjection set="actions" version="4.x">As well as allowing static values, the `visible()` and `hidden()` methods also accept functions to dynamically calculate them. You can inject various utilities into the functions as parameters.</UtilityInjection>

### Authorization using a policy

You can use a policy to authorize an action. To do this, pass the name of the policy method to the `authorize()` method, and Filament will use the current Eloquent model for that action to find the correct policy:

```php
use Filament\Actions\Action;

Action::make('edit')
    ->url(fn (): string => route('posts.edit', ['post' => $this->post]))
    ->authorize('update')
```

<Aside variant="info">
    If you're using an action in a panel resource or relation manager, you don't need to use the `authorize()` method, since Filament will automatically read the policy based on the resource model for the built-in actions like `CreateAction`, `EditAction` and `DeleteAction`. For more information, visit the [resource authorization](../resources/overview#authorization) section.
</Aside>

If your policy method returns a [response message](https://laravel.com/docs/authorization#policy-responses), you can disable the action instead of hiding it, and add a tooltip containing the message, using the `authorizationTooltip()` method:

```php
use Filament\Actions\Action;

Action::make('edit')
    ->url(fn (): string => route('posts.edit', ['post' => $this->post]))
    ->authorize('update')
    ->authorizationTooltip()
```

You may instead allow the action to still be clickable even if the user is not authorized, but send a notification containing the response message, using the `authorizationNotification()` method:

```php
use Filament\Actions\Action;

Action::make('edit')
    ->url(fn (): string => route('posts.edit', ['post' => $this->post]))
    ->authorize('update')
    ->authorizationNotification()
```

### Disabling a button

If you want to disable a button instead of hiding it, you can use the `disabled()` method:

```php
use Filament\Actions\Action;

Action::make('delete')
    ->disabled()
```

You can conditionally disable a button by passing a boolean to it:

```php
use Filament\Actions\Action;

Action::make('delete')
    ->disabled(! auth()->user()->can('delete', $this->post))
```

<UtilityInjection set="actions" version="4.x">As well as allowing a static value, the `disabled()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Registering keybindings

You can attach keyboard shortcuts to trigger buttons. These use the same key codes as [Mousetrap](https://craig.is/killing/mice):

```php
use Filament\Actions\Action;

Action::make('save')
    ->action(fn () => $this->save())
    ->keyBindings(['command+s', 'ctrl+s'])
```

<UtilityInjection set="actions" version="4.x">As well as allowing a static value, the `keyBindings()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Adding a badge to the corner of the button

You can add a badge to the corner of the button, to display whatever you want. It's useful for displaying a count of something, or a status indicator:

```php
use Filament\Actions\Action;

Action::make('filter')
    ->iconButton()
    ->icon('heroicon-m-funnel')
    ->badge(5)
```

<UtilityInjection set="actions" version="4.x">As well as allowing a static value, the `badge()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="actions/trigger-button/badged" alt="Trigger with badge" version="4.x" />

You can also pass a [color](../styling/colors) to be used for the badge:

```php
use Filament\Actions\Action;

Action::make('filter')
    ->iconButton()
    ->icon('heroicon-m-funnel')
    ->badge(5)
    ->badgeColor('success')
```

<UtilityInjection set="actions" version="4.x">As well as allowing a static value, the `badgeColor()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="actions/trigger-button/success-badged" alt="Trigger with green badge" version="4.x" />

## Outlined button style

When you're using the "button" trigger style, you might wish to make it less prominent. You could use a different [color](#setting-a-color), but sometimes you might want to make it outlined instead. You can do this with the `outlined()` method:

```php
use Filament\Actions\Action;

Action::make('edit')
    ->url(fn (): string => route('posts.edit', ['post' => $this->post]))
    ->button()
    ->outlined()
```

<AutoScreenshot name="actions/trigger-button/outlined" alt="Outlined trigger button" version="4.x" />

Optionally, you may pass a boolean value to control if the label should be hidden or not:

```php
use Filament\Actions\Action;

Action::make('edit')
    ->url(fn (): string => route('posts.edit', ['post' => $this->post]))
    ->button()
    ->outlined(FeatureFlag::active())
```

<UtilityInjection set="actions" version="4.x">As well as allowing a static value, the `outlined()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Adding extra HTML attributes to an action

You can pass extra HTML attributes to the action via the `extraAttributes()` method, which will be merged onto its outer HTML element. The attributes should be represented by an array, where the key is the attribute name and the value is the attribute value:

```php
use Filament\Actions\Action;

Action::make('edit')
    ->url(fn (): string => route('posts.edit', ['post' => $this->post]))
    ->extraAttributes([
        'title' => 'Edit this post',
    ])
```

<UtilityInjection set="actions" version="4.x">As well as allowing a static value, the `extraAttributes()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<Aside variant="tip">
    By default, calling `extraAttributes()` multiple times will overwrite the previous attributes. If you wish to merge the attributes instead, you can pass `merge: true` to the method.
</Aside>

## Rate limiting actions

You can rate limit actions by using the `rateLimit()` method. This method accepts the number of attempts per minute that a user IP address can make. If the user exceeds this limit, the action will not run and a notification will be shown:

```php
use Filament\Actions\Action;

Action::make('delete')
    ->rateLimit(5)
```

If the action opens a modal, the rate limit will be applied when the modal is submitted.

If an action is opened with arguments or for a specific Eloquent record, the rate limit will apply to each unique combination of arguments or record for each action. The rate limit is also unique to the current Livewire component / page in a panel.

<UtilityInjection set="actions" version="4.x">As well as allowing a static value, the `rateLimit()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Customizing the rate limited notification

When an action is rate limited, a notification is dispatched to the user, which indicates the rate limit.

To customize the title of this notification, use the `rateLimitedNotificationTitle()` method:

```php
use Filament\Actions\DeleteAction;

DeleteAction::make()
    ->rateLimit(5)
    ->rateLimitedNotificationTitle('Slow down!')
```

<UtilityInjection set="actions" version="4.x">As well as allowing a static value, the `rateLimitedNotificationTitle()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

You may customize the entire notification using the `rateLimitedNotification()` method:

```php
use DanHarrin\LivewireRateLimiting\Exceptions\TooManyRequestsException;
use Filament\Actions\DeleteAction;
use Filament\Notifications\Notification;

DeleteAction::make()
    ->rateLimit(5)
    ->rateLimitedNotification(
       fn (TooManyRequestsException $exception): Notification => Notification::make()
            ->warning()
            ->title('Slow down!')
            ->body("You can try deleting again in {$exception->secondsUntilAvailable} seconds."),
    )
```

<UtilityInjection set="actions" version="4.x" extras="Exception;;DanHarrin\LivewireRateLimiting\Exceptions\TooManyRequestsException;;$exception;;The exception encountered when the rate limit was hit.||Minutes until available;;int;;$minutes;;The number of minutes until the rate limit will pass.||Seconds until available;;int;;$seconds;;The number of seconds until the rate limit will pass.||Notification;;Filament\Notifications\Notification;;$notification;;The default notification object for the rate limit, which could be a useful starting point for customization.">As well as allowing a static value, the `rateLimitedNotification()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Customizing the rate limit behavior

If you wish to customize the rate limit behavior, you can use Laravel's [rate limiting](https://laravel.com/docs/rate-limiting#basic-usage) features and Filament's [flash notifications](../notifications/overview) together in the action.

If you want to rate limit immediately when an action modal is opened, you can do so in the `mountUsing()` method:

```php
use Filament\Actions\Action;
use Filament\Notifications\Notification;
use Illuminate\Support\Facades\RateLimiter;

Action::make('delete')
    ->mountUsing(function () {
        if (RateLimiter::tooManyAttempts(
            $rateLimitKey = 'delete:' . auth()->id(),
            maxAttempts: 5,
        )) {
            Notification::make()
                ->title('Too many attempts')
                ->body('Please try again in ' . RateLimiter::availableIn($rateLimitKey) . ' seconds.')
                ->danger()
                ->send();
                
            return;
        }
        
         RateLimiter::hit($rateLimitKey);
    })
```

If you want to rate limit when an action is run, you can do so in the `action()` method:

```php
use Filament\Actions\Action;
use Filament\Notifications\Notification;
use Illuminate\Support\Facades\RateLimiter;

Action::make('delete')
    ->action(function () {
        if (RateLimiter::tooManyAttempts(
            $rateLimitKey = 'delete:' . auth()->id(),
            maxAttempts: 5,
        )) {
            Notification::make()
                ->title('Too many attempts')
                ->body('Please try again in ' . RateLimiter::availableIn($rateLimitKey) . ' seconds.')
                ->danger()
                ->send();
                
            return;
        }
        
         RateLimiter::hit($rateLimitKey);
        
        // ...
    })
```

## Action utility injection

The vast majority of methods used to configure actions accept functions as parameters instead of hardcoded values:

```php
use Filament\Actions\Action;

Action::make('edit')
    ->label('Edit post')
    ->url(fn (): string => route('posts.edit', ['post' => $this->post]))
```

This alone unlocks many customization possibilities.

The package is also able to inject many utilities to use inside these functions, as parameters. All customization methods that accept functions as arguments can inject utilities.

These injected utilities require specific parameter names to be used. Otherwise, Filament doesn't know what to inject.

### Injecting the current modal form data

If you wish to access the current [modal form data](modals#rendering-a-form-in-a-modal), define a `$data` parameter:

```php
function (array $data) {
    // ...
}
```

Be aware that this will be empty if the modal has not been submitted yet.

### Injecting the Eloquent record

If your action is associated with an Eloquent record, for example if it is on a table row, you can inject the record using a `$record` parameter:

```php
use Illuminate\Database\Eloquent\Model;

function (Model $record) {
    // ...
}
```

### Injecting the current arguments

If you wish to access the [current arguments](../components/action#passing-action-arguments) that have been passed to the action, define an `$arguments` parameter:

```php
function (array $arguments) {
    // ...
}
```

### Injecting utilities from a schema

You can access various additional utilities if your action is defined in a schema:

- `$schema` - The schema instance that the action belongs to.
- `$schemaComponent` - The schema component instance that the action belongs to.
- `$schemaComponentState` - The current value of the schema component.
- `$schemaGet` - A function for retrieving values from the schema data. Validation is not run on form fields.
- `$schemaSet` - A function for setting values in the schema data.
- `$schemaOperation` - The current operation being performed by the schema. Usually `create`, `edit`, or `view`.

For more information, please visit the [Schemas section](../schemas/overview#component-utility-injection).

### Injecting the current Livewire component instance

If you wish to access the current Livewire component instance that the action belongs to, define a `$livewire` parameter:

```php
use Livewire\Component;

function (Component $livewire) {
    // ...
}
```

### Injecting the current action instance

If you wish to access the current action instance, define a `$action` parameter:

```php
function (Action $action) {
    // ...
}
```

### Injecting multiple utilities

The parameters are injected dynamically using reflection, so you are able to combine multiple parameters in any order:

```php
use Livewire\Component;

function (array $arguments, Component $livewire) {
    // ...
}
```

### Injecting dependencies from Laravel's container

You may inject anything from Laravel's container like normal, alongside utilities:

```php
use Illuminate\Http\Request;

function (Request $request, array $arguments) {
    // ...
}
```

# Documentation for actions. File: 02-modals.md
---
title: Modals
---
import Aside from "@components/Aside.astro"
import AutoScreenshot from "@components/AutoScreenshot.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

Actions may require additional confirmation or input from the user before they run. You may open a modal before an action is executed to do this.

## Confirmation modals

You may require confirmation before an action is run using the `requiresConfirmation()` method. This is useful for particularly destructive actions, such as those that delete records.

```php
use App\Models\Post;
use Filament\Actions\Action;

Action::make('delete')
    ->action(fn (Post $record) => $record->delete())
    ->requiresConfirmation()
```

<AutoScreenshot name="actions/modal/confirmation" alt="Confirmation modal" version="4.x" />

<Aside variant="warning">
    The confirmation modal is not available when a `url()` is set instead of an `action()`. Instead, you should redirect to the URL within the `action()` closure.
</Aside>

## Controlling modal content

### Customizing the modal's heading, description, and submit action label

You may customize the heading, description and label of the submit button in the modal:

```php
use App\Models\Post;
use Filament\Actions\Action;

Action::make('delete')
    ->action(fn (Post $record) => $record->delete())
    ->requiresConfirmation()
    ->modalHeading('Delete post')
    ->modalDescription('Are you sure you\'d like to delete this post? This cannot be undone.')
    ->modalSubmitActionLabel('Yes, delete it')
```

<AutoScreenshot name="actions/modal/confirmation-custom-text" alt="Confirmation modal with custom text" version="4.x" />

### Rendering a schema in a modal

Filament allows you to render a [schema](../schemas) in a modal, which allows you to render any of the available components to build a UI. Usually, it is useful to build a form in the schema that can collect extra information from the user before the action runs, but any UI can be rendered:

```php
use Filament\Actions\Action;
use Filament\Forms\Components\Checkbox;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Components\Section;

Action::make('viewUser')
    ->schema([
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

<UtilityInjection set="actions" version="4.x">As well as allowing a static value, the `schema()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

#### Rendering a form in a modal

You may use [form field](../forms) to create action modal forms. The data from the form is available in the `$data` array of the `action()` closure:

```php
use App\Models\Post;
use App\Models\User;
use Filament\Actions\Action;
use Filament\Forms\Components\Select;

Action::make('updateAuthor')
    ->schema([
        Select::make('authorId')
            ->label('Author')
            ->options(User::query()->pluck('name', 'id'))
            ->required(),
    ])
    ->action(function (array $data, Post $record): void {
        $record->author()->associate($data['authorId']);
        $record->save();
    })
```

<AutoScreenshot name="actions/modal/form" alt="Modal with form" version="4.x" />

##### Filling the form with existing data

You may fill the form with existing data, using the `fillForm()` method:

```php
use App\Models\Post;
use App\Models\User;
use Filament\Actions\Action;
use Filament\Forms\Components\Select;

Action::make('updateAuthor')
    ->fillForm(fn (Post $record): array => [
        'authorId' => $record->author->id,
    ])
    ->schema([
        Select::make('authorId')
            ->label('Author')
            ->options(User::query()->pluck('name', 'id'))
            ->required(),
    ])
    ->action(function (array $data, Post $record): void {
        $record->author()->associate($data['authorId']);
        $record->save();
    })
```

<UtilityInjection set="actions" version="4.x">The `fillForm()` method also accepts a function to dynamically calculate the data to fill the form with. You can inject various utilities into the function as parameters.</UtilityInjection>

##### Disabling all form fields

You may wish to disable all form fields in the modal, ensuring the user cannot edit them. You may do so using the `disabledForm()` method:

```php
use App\Models\Post;
use Filament\Actions\Action;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;

Action::make('approvePost')
    ->schema([
        TextInput::make('title'),
        Textarea::make('content'),
    ])
    ->disabledForm()
    ->action(function (Post $record): void {
        $record->approve();
    })
```

#### Rendering a wizard in a modal

You may create a [multistep form wizard](../schemas/wizards) inside a modal. Instead of using a `schema()`, define a `steps()` array and pass your `Step` objects:

```php
use Filament\Actions\Action;
use Filament\Forms\Components\MarkdownEditor;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Components\Wizard\Step;

Action::make('create')
    ->steps([
        Step::make('Name')
            ->description('Give the category a unique name')
            ->schema([
                TextInput::make('name')
                    ->required()
                    ->live()
                    ->afterStateUpdated(fn ($state, callable $set) => $set('slug', Str::slug($state))),
                TextInput::make('slug')
                    ->disabled()
                    ->required()
                    ->unique(Category::class, 'slug'),
            ])
            ->columns(2),
        Step::make('Description')
            ->description('Add some extra details')
            ->schema([
                MarkdownEditor::make('description'),
            ]),
        Step::make('Visibility')
            ->description('Control who can view it')
            ->schema([
                Toggle::make('is_visible')
                    ->label('Visible to customers.')
                    ->default(true),
            ]),
    ])
```

<AutoScreenshot name="actions/modal/wizard" alt="Modal with wizard" version="4.x" />

### Adding an icon inside the modal

You may add an [icon](../styling/icons) inside the modal using the `modalIcon()` method:

```php
use App\Models\Post;
use Filament\Actions\Action;

Action::make('delete')
    ->action(fn (Post $record) => $record->delete())
    ->requiresConfirmation()
    ->modalIcon('heroicon-o-trash')
```

<UtilityInjection set="actions" version="4.x">The `modalIcon()` method also accepts a function to dynamically calculate the value. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="actions/modal/icon" alt="Confirmation modal with icon" version="4.x" />

By default, the icon will inherit the color of the action button. You may customize the color of the icon using the `modalIconColor()` method:

```php
use App\Models\Post;
use Filament\Actions\Action;

Action::make('delete')
    ->action(fn (Post $record) => $record->delete())
    ->requiresConfirmation()
    ->color('danger')
    ->modalIcon('heroicon-o-trash')
    ->modalIconColor('warning')
```

<UtilityInjection set="actions" version="4.x">The `modalIconColor()` method also accepts a function to dynamically calculate the value. You can inject various utilities into the function as parameters.</UtilityInjection>

### Customizing the alignment of modal content

By default, modal content will be aligned to the start, or centered if the modal is `xs` or `sm` in [width](#changing-the-modal-width). If you wish to change the alignment of content in a modal, you can use the `modalAlignment()` method and pass it `Alignment::Start` or `Alignment::Center`:

```php
use Filament\Actions\Action;
use Filament\Support\Enums\Alignment;

Action::make('updateAuthor')
    ->schema([
        // ...
    ])
    ->action(function (array $data): void {
        // ...
    })
    ->modalAlignment(Alignment::Center)
```

<UtilityInjection set="actions" version="4.x">The `modalAlignment()` method also accepts a function to dynamically calculate the value. You can inject various utilities into the function as parameters.</UtilityInjection>

### Making the modal header sticky

The header of a modal scrolls out of view with the modal content when it overflows the modal size. However, slide-overs have a sticky header that's always visible. You may control this behavior using `stickyModalHeader()`:

```php
use Filament\Actions\Action;

Action::make('updateAuthor')
    ->schema([
        // ...
    ])
    ->action(function (array $data): void {
        // ...
    })
    ->stickyModalHeader()
```

### Making the modal footer sticky

The footer of a modal is rendered inline after the content by default. Slide-overs, however, have a sticky footer that always shows when scrolling the content. You may enable this for a modal too using `stickyModalFooter()`:

```php
use Filament\Actions\Action;

Action::make('updateAuthor')
    ->schema([
        // ...
    ])
    ->action(function (array $data): void {
        // ...
    })
    ->stickyModalFooter()
```

### Custom modal content

You may define custom content to be rendered inside your modal, which you can specify by passing a Blade view into the `modalContent()` method:

```php
use App\Models\Post;
use Filament\Actions\Action;

Action::make('advance')
    ->action(fn (Post $record) => $record->advance())
    ->modalContent(view('filament.pages.actions.advance'))
```

<UtilityInjection set="actions" version="4.x">The `modalContent()` method also accepts a function to dynamically calculate the value. You can inject various utilities into the function as parameters.</UtilityInjection>

#### Passing data to the custom modal content

You can pass data to the view by returning it from a function. For example, if the `$record` of an action is set, you can pass that through to the view:

```php
use Filament\Actions\Action;
use Illuminate\Contracts\View\View;

Action::make('advance')
    ->action(fn (Contract $record) => $record->advance())
    ->modalContent(fn (Contract $record): View => view(
        'filament.pages.actions.advance',
        ['record' => $record],
    ))
```

#### Adding custom modal content below the form

By default, the custom content is displayed above the modal form if there is one, but you can add content below using `modalContentFooter()` if you wish:

```php
use App\Models\Post;
use Filament\Actions\Action;

Action::make('advance')
    ->action(fn (Post $record) => $record->advance())
    ->modalContentFooter(view('filament.pages.actions.advance'))
```

<UtilityInjection set="actions" version="4.x">The `modalContentFooter()` method also accepts a function to dynamically calculate the value. You can inject various utilities into the function as parameters.</UtilityInjection>

#### Adding an action to custom modal content

You can add an action button to your custom modal content, which is useful if you want to add a button that performs an action other than the main action. You can do this by registering an action with the `registerModalActions()` method, and then passing it to the view:

```php
use App\Models\Post;
use Filament\Actions\Action;
use Illuminate\Contracts\View\View;

Action::make('advance')
    ->registerModalActions([
        Action::make('report')
            ->requiresConfirmation()
            ->action(fn (Post $record) => $record->report()),
    ])
    ->action(fn (Post $record) => $record->advance())
    ->modalContent(fn (Action $action): View => view(
        'filament.pages.actions.advance',
        ['action' => $action],
    ))
```

Now, in the view file, you can render the action button by calling `getModalAction()`:

```blade
<div>
    {{ $action->getModalAction('report') }}
</div>
```

## Using a slide-over instead of a modal

You can open a "slide-over" dialog instead of a modal by using the `slideOver()` method:

```php
use Filament\Actions\Action;

Action::make('updateAuthor')
    ->schema([
        // ...
    ])
    ->action(function (array $data): void {
        // ...
    })
    ->slideOver()
```

<AutoScreenshot name="actions/modal/slide-over" alt="Slide over with form" version="4.x" />

Instead of opening in the center of the screen, the modal content will now slide in from the right and consume the entire height of the browser.

## Changing the modal width

You can change the width of the modal by using the `modalWidth()` method. Options correspond to [Tailwind's max-width scale](https://tailwindcss.com/docs/max-width). The options are `ExtraSmall`, `Small`, `Medium`, `Large`, `ExtraLarge`, `TwoExtraLarge`, `ThreeExtraLarge`, `FourExtraLarge`, `FiveExtraLarge`, `SixExtraLarge`, `SevenExtraLarge`, and `Screen`:

```php
use Filament\Actions\Action;
use Filament\Support\Enums\Width;

Action::make('updateAuthor')
    ->schema([
        // ...
    ])
    ->action(function (array $data): void {
        // ...
    })
    ->modalWidth(Width::FiveExtraLarge)
```

<UtilityInjection set="actions" version="4.x">The `modalWidth()` method also accepts a function to dynamically calculate the value. You can inject various utilities into the function as parameters.</UtilityInjection>

## Executing code when the modal opens

You may execute code within a closure when the modal opens, by passing it to the `mountUsing()` method:

```php
use Filament\Actions\Action;
use Filament\Schemas\Schema;

Action::make('create')
    ->mountUsing(function (Schema $form) {
        $form->fill();

        // ...
    })
```

> The `mountUsing()` method, by default, is used by Filament to initialize the [form](#rendering-a-form-in-a-modal). If you override this method, you will need to call `$form->fill()` to ensure the form is initialized correctly. If you wish to populate the form with data, you can do so by passing an array to the `fill()` method, instead of [using `fillForm()` on the action itself](#filling-the-form-with-existing-data).

## Customizing the action buttons in the footer of the modal

By default, there are two actions in the footer of a modal. The first is a button to submit, which executes the `action()`. The second button closes the modal and cancels the action.

### Modifying the default modal footer action button

To modify the action instance that is used to render one of the default action buttons, you may pass a closure to the `modalSubmitAction()` and `modalCancelAction()` methods:

```php
use Filament\Actions\Action;

Action::make('help')
    ->modalContent(view('actions.help'))
    ->modalCancelAction(fn (Action $action) => $action->label('Close'))
```

The [methods available to customize trigger buttons](overview) will work to modify the `$action` instance inside the closure.

<Aside variant="tip">
    To customize the button labels in your modal, the `modalSubmitActionLabel()` and `modalCancelActionLabel()` methods can be used instead of passing a function to `modalSubmitAction()` and `modalCancelAction()`, if you don't require any further customizations.
</Aside>

### Removing a default modal footer action button

To remove a default action, you may pass `false` to either `modalSubmitAction()` or `modalCancelAction()`:

```php
use Filament\Actions\Action;

Action::make('help')
    ->modalContent(view('actions.help'))
    ->modalSubmitAction(false)
```

### Adding an extra modal action button to the footer

You may pass an array of extra actions to be rendered, between the default actions, in the footer of the modal using the `extraModalFooterActions()` method:

```php
use Filament\Actions\Action;

Action::make('create')
    ->schema([
        // ...
    ])
    // ...
    ->extraModalFooterActions(fn (Action $action): array => [
        $action->makeModalSubmitAction('createAnother', arguments: ['another' => true]),
    ])
```

<UtilityInjection set="actions" version="4.x">The `extraModalFooterActions()` method also accepts a function to dynamically calculate the value. You can inject various utilities into the function as parameters.</UtilityInjection>

`$action->makeModalSubmitAction()` returns an action instance that can be customized using the [methods available to customize trigger buttons](overview).

The second parameter of `makeModalSubmitAction()` allows you to pass an array of arguments that will be accessible inside the action's `action()` closure as `$arguments`. These could be useful as flags to indicate that the action should behave differently based on the user's decision:

```php
use Filament\Actions\Action;

Action::make('create')
    ->schema([
        // ...
    ])
    // ...
    ->extraModalFooterActions(fn (Action $action): array => [
        $action->makeModalSubmitAction('createAnother', arguments: ['another' => true]),
    ])
    ->action(function (array $data, array $arguments): void {
        // Create

        if ($arguments['another'] ?? false) {
            // Reset the form and don't close the modal
        }
    })
```

#### Opening another modal from an extra footer action

You can nest actions within each other, allowing you to open a new modal from an extra footer action:

```php
use Filament\Actions\Action;

Action::make('edit')
    // ...
    ->extraModalFooterActions([
        Action::make('delete')
            ->requiresConfirmation()
            ->action(function () {
                // ...
            }),
    ])
```

Now, the edit modal will have a "Delete" button in the footer, which will open a confirmation modal when clicked. This action is completely independent of the `edit` action, and will not run the `edit` action when it is clicked.

In this example though, you probably want to cancel the `edit` action if the `delete` action is run. You can do this using the `cancelParentActions()` method:

```php
use Filament\Actions\Action;

Action::make('delete')
    ->requiresConfirmation()
    ->action(function () {
        // ...
    })
    ->cancelParentActions()
```

If you have deep nesting with multiple parent actions, but you don't want to cancel all of them, you can pass the name of the parent action you want to cancel, including its children, to `cancelParentActions()`:

```php
use Filament\Actions\Action;

Action::make('first')
    ->requiresConfirmation()
    ->action(function () {
        // ...
    })
    ->extraModalFooterActions([
        Action::make('second')
            ->requiresConfirmation()
            ->action(function () {
                // ...
            })
            ->extraModalFooterActions([
                Action::make('third')
                    ->requiresConfirmation()
                    ->action(function () {
                        // ...
                    })
                    ->extraModalFooterActions([
                        Action::make('fourth')
                            ->requiresConfirmation()
                            ->action(function () {
                                // ...
                            })
                            ->cancelParentActions('second'),
                    ]),
            ]),
    ])
```

In this example, if the `fourth` action is run, the `second` action is canceled, but so is the `third` action since it is a child of `second`. The `first` action is not canceled, however, since it is the parent of `second`. The `first` action's modal will remain open.

## Accessing information about parent actions from a child

You can access the instances of parent actions and their raw data and arguments by injecting the `$mountedActions` array in a function used by your nested action. For example, to get the top-most parent action currently active on the page, you can use `$mountedActions[0]`. From there, you can get the raw data for that action by calling `$mountedActions[0]->getRawData()`. Please be aware that raw data is not validated since the action has not been submitted yet:

```php
use Filament\Actions\Action;
use Filament\Forms\Components\TextInput;

Action::make('first')
    ->schema([
        TextInput::make('foo'),
    ])
    ->action(function () {
        // ...
    })
    ->extraModalFooterActions([
        Action::make('second')
            ->requiresConfirmation()
            ->action(function (array $mountedActions) {
                dd($mountedActions[0]->getRawData());
            
                // ...
            }),
    ])
```

You can do similar with the current arguments for a parent action, with the `$mountedActions[0]->getArguments()` method.

Even if you have multiple layers of nesting, the `$mountedActions` array will contain every action that is currently active, so you can access information about them:

```php
use Filament\Actions\Action;

Action::make('first')
    ->schema([
        TextInput::make('foo'),
    ])
    ->action(function () {
        // ...
    })
    ->extraModalFooterActions([
        Action::make('second')
            ->schema([
                TextInput::make('bar'),
            ])
            ->arguments(['number' => 2])
            ->action(function () {
                // ...
            })
            ->extraModalFooterActions([
                Action::make('third')
                    ->schema([
                        TextInput::make('baz'),
                    ])
                    ->arguments(['number' => 3])
                    ->action(function () {
                        // ...
                    })
                    ->extraModalFooterActions([
                        Action::make('fourth')
                            ->requiresConfirmation()
                            ->action(function (array $mountedActions) {
                                dd(
                                    $mountedActions[0]->getRawData(),
                                    $mountedActions[0]->getArguments(),
                                    $mountedActions[1]->getRawData(),
                                    $mountedActions[1]->getArguments(),
                                    $mountedActions[2]->getRawData(),
                                    $mountedActions[2]->getArguments(),
                                );
                                // ...
                            }),
                    ]),
            ]),
    ])
```

## Closing the modal

### Closing the modal by clicking away

By default, when you click away from a modal, it will close itself. If you wish to disable this behavior for a specific action, you can use the `closeModalByClickingAway(false)` method:

```php
use Filament\Actions\Action;

Action::make('updateAuthor')
    ->schema([
        // ...
    ])
    ->action(function (array $data): void {
        // ...
    })
    ->closeModalByClickingAway(false)
```

<UtilityInjection set="actions" version="4.x">The `closeModalByClickingAway()` method also accepts a function to dynamically calculate the value. You can inject various utilities into the function as parameters.</UtilityInjection>

If you'd like to change the behavior for all modals in the application, you can do so by calling `ModalComponent::closedByClickingAway()` inside a service provider or middleware:

```php
use Filament\Support\View\Components\ModalComponent;

ModalComponent::closedByClickingAway(false);
```

### Closing the modal by escaping

By default, when you press escape on a modal, it will close itself. If you wish to disable this behavior for a specific action, you can use the `closeModalByEscaping(false)` method:

```php
use Filament\Actions\Action;

Action::make('updateAuthor')
    ->schema([
        // ...
    ])
    ->action(function (array $data): void {
        // ...
    })
    ->closeModalByEscaping(false)
```

<UtilityInjection set="actions" version="4.x">The `closeModalByEscaping()` method also accepts a function to dynamically calculate the value. You can inject various utilities into the function as parameters.</UtilityInjection>

If you'd like to change the behavior for all modals in the application, you can do so by calling `ModalComponent::closedByEscaping()` inside a service provider or middleware:

```php
use Filament\Support\View\Components\ModalComponent;

ModalComponent::closedByEscaping(false);
```

### Hiding the modal close button

By default, modals have a close button in the top right corner. If you wish to hide the close button, you can use the `modalCloseButton(false)` method:

```php
use Filament\Actions\Action;

Action::make('updateAuthor')
    ->schema([
        // ...
    ])
    ->action(function (array $data): void {
        // ...
    })
    ->modalCloseButton(false)
```

<UtilityInjection set="actions" version="4.x">The `modalCloseButton()` method also accepts a function to dynamically calculate the value. You can inject various utilities into the function as parameters.</UtilityInjection>

If you'd like to hide the close button for all modals in the application, you can do so by calling `ModalComponent::closeButton(false)` inside a service provider or middleware:

```php
use Filament\Support\View\Components\ModalComponent;

ModalComponent::closeButton(false);
```

## Preventing the modal from autofocusing

By default, modals will autofocus on the first focusable element when opened. If you wish to disable this behavior, you can use the `modalAutofocus(false)` method:

```php
use Filament\Actions\Action;

Action::make('updateAuthor')
    ->schema([
        // ...
    ])
    ->action(function (array $data): void {
        // ...
    })
    ->modalAutofocus(false)
```

<UtilityInjection set="actions" version="4.x">The `modalAutofocus()` method also accepts a function to dynamically calculate the value. You can inject various utilities into the function as parameters.</UtilityInjection>

If you'd like to disable autofocus for all modals in the application, you can do so by calling `ModalComponent::autofocus(false)` inside a service provider or middleware:

```php
use Filament\Support\View\Components\ModalComponent;

ModalComponent::autofocus(false);
```

## Optimizing modal configuration methods

When you use database queries or other heavy operations inside modal configuration methods like `modalHeading()`, they can be executed more than once. This is because Filament uses these methods to decide whether to render the modal or not, and also to render the modal's content.

To skip the check that Filament does to decide whether to render the modal, you can use the `modal()` method, which will inform Filament that the modal exists for this action, and it does not need to check again:

```php
use Filament\Actions\Action;

Action::make('updateAuthor')
    ->modal()
```

## Conditionally hiding the modal

You may have a need to conditionally show a modal for confirmation reasons while falling back to the default action. This can be achieved using `modalHidden()`:

```php
use Filament\Actions\Action;

Action::make('create')
    ->action(function (array $data): void {
        // ...
    })
    ->modalHidden($this->role !== 'admin')
    ->modalContent(view('filament.pages.actions.create'))
```

<UtilityInjection set="actions" version="4.x">The `modalHidden()` method also accepts a function to dynamically calculate the value. You can inject various utilities into the function as parameters.</UtilityInjection>

## Adding extra attributes to the modal window

You can pass extra HTML attributes to the modal window via the `extraModalWindowAttributes()` method, which will be merged onto its outer HTML element. The attributes should be represented by an array, where the key is the attribute name and the value is the attribute value:

```php
use Filament\Actions\Action;

Action::make('updateAuthor')
    ->extraModalWindowAttributes(['class' => 'update-author-modal'])
```

<UtilityInjection set="actions" version="4.x">As well as allowing a static value, the `extraModalWindowAttributes()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<Aside variant="tip">
    By default, calling `extraModalWindowAttributes()` multiple times will overwrite the previous attributes. If you wish to merge the attributes instead, you can pass `merge: true` to the method.
</Aside>

# Documentation for actions. File: 03-grouping-actions.md
---
title: Grouping actions
---
import AutoScreenshot from "@components/AutoScreenshot.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

You may group actions together into a dropdown menu by using an `ActionGroup` object. Groups may contain many actions, or other groups:

```php
use Filament\Actions\Action;
use Filament\Actions\ActionGroup;

ActionGroup::make([
    Action::make('view'),
    Action::make('edit'),
    Action::make('delete'),
])
```

<AutoScreenshot name="actions/group/simple" alt="Action group" version="4.x" />

This page is about customizing the look of the group's trigger button and dropdown.

## Customizing the group trigger style

The button which opens the dropdown may be customized in the same way as a normal action. [All the methods available for trigger buttons](overview) may be used to customize the group trigger button:

```php
use Filament\Actions\ActionGroup;
use Filament\Support\Enums\Size;

ActionGroup::make([
    // Array of actions
])
    ->label('More actions')
    ->icon('heroicon-m-ellipsis-vertical')
    ->size(Size::Small)
    ->color('primary')
    ->button()
```

<AutoScreenshot name="actions/group/customized" alt="Action group with custom trigger style" version="4.x" />

<AutoScreenshot name="tables/actions/group-button" alt="Table with button action group" version="4.x" />

### Using a grouped button design

Instead of a dropdown, an action group can render itself as a group of buttons. This design works with and without button labels. To use this feature, use the `buttonGroup()` method:

```php
use Filament\Actions\Action;
use Filament\Actions\ActionGroup;
use Filament\Support\Icons\Heroicon;

ActionGroup::make([
    Action::make('edit')
        ->color('gray')
        ->icon(Heroicon::PencilSquare)
        ->hiddenLabel(),
    Action::make('delete')
        ->color('gray')
        ->icon(Heroicon::Trash)
        ->hiddenLabel(),
])
    ->buttonGroup()
```

<AutoScreenshot name="actions/group/button-group" alt="Action group using the button group design" version="4.x" />

## Setting the placement of the dropdown

The dropdown may be positioned relative to the trigger button by using the `dropdownPlacement()` method:

```php
use Filament\Actions\ActionGroup;

ActionGroup::make([
    // Array of actions
])
    ->dropdownPlacement('top-start')
```

<UtilityInjection set="actionGroups" version="4.x">The `dropdownPlacement()` method also accepts a function to dynamically calculate the value. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="actions/group/placement" alt="Action group with top placement style" version="4.x" />

## Adding dividers between actions

You may add dividers between groups of actions by using nested `ActionGroup` objects:

```php
use Filament\Actions\ActionGroup;

ActionGroup::make([
    ActionGroup::make([
        // Array of actions
    ])->dropdown(false),
    // Array of actions
])
```

The `dropdown(false)` method puts the actions inside the parent dropdown, instead of a new nested dropdown.

<UtilityInjection set="actionGroups" version="4.x">The `dropdown()` method also accepts a function to dynamically calculate the value. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="actions/group/nested" alt="Action groups nested with dividers" version="4.x" />

## Setting the width of the dropdown

The dropdown may be set to a width by using the `dropdownWidth()` method. Options correspond to [Tailwind's max-width scale](https://tailwindcss.com/docs/max-width). The options are `ExtraSmall`, `Small`, `Medium`, `Large`, `ExtraLarge`, `TwoExtraLarge`, `ThreeExtraLarge`, `FourExtraLarge`, `FiveExtraLarge`, `SixExtraLarge` and `SevenExtraLarge`:

```php
use Filament\Actions\ActionGroup;
use Filament\Support\Enums\Width;

ActionGroup::make([
    // Array of actions
])
    ->dropdownWidth(Width::ExtraSmall)
```

<UtilityInjection set="actionGroups" version="4.x">The `dropdownWidth()` method also accepts a function to dynamically calculate the value. You can inject various utilities into the function as parameters.</UtilityInjection>

## Controlling the dropdown offset

You may control the offset of the dropdown using the `dropdownOffset()` method, by default the offset is set to `8`.

```php
use Filament\Actions\ActionGroup;

ActionGroup::make([
    // Array of actions
])
    ->dropdownOffset(16)
```

<UtilityInjection set="actionGroups" version="4.x">The `dropdownOffset()` method also accepts a function to dynamically calculate the value. You can inject various utilities into the function as parameters.</UtilityInjection>

## Controlling the maximum height of the dropdown

The dropdown content can have a maximum height using the `maxHeight()` method, so that it scrolls. You can pass a [CSS length](https://developer.mozilla.org/en-US/docs/Web/CSS/length):

```php
use Filament\Actions\ActionGroup;

ActionGroup::make([
    // Array of actions
])
    ->maxHeight('400px')
```

<UtilityInjection set="actionGroups" version="4.x">The `maxHeight()` method also accepts a function to dynamically calculate the value. You can inject various utilities into the function as parameters.</UtilityInjection>

# Documentation for actions. File: 04-create.md
---
title: Create action
---
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

Filament includes an action that is able to create Eloquent records. When the trigger button is clicked, a modal will open with a form inside. The user fills the form, and that data is validated and saved into the database. You may use it like so:

```php
use Filament\Actions\CreateAction;
use Filament\Forms\Components\TextInput;

CreateAction::make()
    ->schema([
        TextInput::make('title')
            ->required()
            ->maxLength(255),
        // ...
    ])
```

## Customizing data before saving

Sometimes, you may wish to modify form data before it is finally saved to the database. To do this, you may use the `mutateDataUsing()` method, which has access to the `$data` as an array, and returns the modified version:

```php
use Filament\Actions\CreateAction;

CreateAction::make()
    ->mutateDataUsing(function (array $data): array {
        $data['user_id'] = auth()->id();

        return $data;
    })
```

<UtilityInjection set="actions" version="4.x">As well as `$data`, the `mutateDataUsing()` function can inject various utilities as parameters.</UtilityInjection>

## Customizing the creation process

You can tweak how the record is created with the `using()` method:

```php
use Filament\Actions\CreateAction;
use Illuminate\Database\Eloquent\Model;

CreateAction::make()
    ->using(function (array $data, string $model): Model {
        return $model::create($data);
    })
```

`$model` is the class name of the model, but you can replace this with your own hard-coded class if you wish.

<UtilityInjection set="actions" version="4.x">As well as `$data` and `$model`, the `using()` function can inject various utilities as parameters.</UtilityInjection>

## Redirecting after creation

You may set up a custom redirect when the form is submitted using the `successRedirectUrl()` method:

```php
use Filament\Actions\CreateAction;

CreateAction::make()
    ->successRedirectUrl(route('posts.list'))
```

If you want to redirect using the created record, use the `$record` parameter:

```php
use Filament\Actions\CreateAction;
use Illuminate\Database\Eloquent\Model;

CreateAction::make()
    ->successRedirectUrl(fn (Model $record): string => route('posts.edit', [
        'post' => $record,
    ]))
```

<UtilityInjection set="actions" version="4.x">As well as `$record`, the `successRedirectUrl()` function can inject various utilities as parameters.</UtilityInjection>

## Customizing the save notification

When the record is successfully created, a notification is dispatched to the user, which indicates the success of their action.

To customize the title of this notification, use the `successNotificationTitle()` method:

```php
use Filament\Actions\CreateAction;

CreateAction::make()
    ->successNotificationTitle('User registered')
```

<UtilityInjection set="actions" version="4.x">As well as allowing a static value, the `successNotificationTitle()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

You may customize the entire notification using the `successNotification()` method:

```php
use Filament\Actions\CreateAction;
use Filament\Notifications\Notification;

CreateAction::make()
    ->successNotification(
       Notification::make()
            ->success()
            ->title('User registered')
            ->body('The user has been created successfully.'),
    )
```

<UtilityInjection set="actions" version="4.x" extras="Notification;;Filament\Notifications\Notification;;$notification;;The default notification object, which could be a useful starting point for customization.">As well as allowing a static value, the `successNotification()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

To disable the notification altogether, use the `successNotification(null)` method:

```php
use Filament\Actions\CreateAction;

CreateAction::make()
    ->successNotification(null)
```

## Lifecycle hooks

Hooks may be used to execute code at various points within the action's lifecycle, like before a form is saved.

There are several available hooks:

```php
use Filament\Actions\CreateAction;

CreateAction::make()
    ->beforeFormFilled(function () {
        // Runs before the form fields are populated with their default values.
    })
    ->afterFormFilled(function () {
        // Runs after the form fields are populated with their default values.
    })
    ->beforeFormValidated(function () {
        // Runs before the form fields are validated when the form is submitted.
    })
    ->afterFormValidated(function () {
        // Runs after the form fields are validated when the form is submitted.
    })
    ->before(function () {
        // Runs before the form fields are saved to the database.
    })
    ->after(function () {
        // Runs after the form fields are saved to the database.
    })
```

<UtilityInjection set="actions" version="4.x">These hook functions can inject various utilities as parameters.</UtilityInjection>

## Halting the creation process

At any time, you may call `$action->halt()` from inside a lifecycle hook or mutation method, which will halt the entire creation process:

```php
use App\Models\Post;
use Filament\Actions\Action;
use Filament\Actions\CreateAction;
use Filament\Notifications\Notification;

CreateAction::make()
    ->before(function (CreateAction $action, Post $record) {
        if (! $record->team->subscribed()) {
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
        
            $action->halt();
        }
    })
```

If you'd like the action modal to close too, you can completely `cancel()` the action instead of halting it:

```php
$action->cancel();
```

## Using a wizard

You may easily transform the creation process into a multistep wizard. Instead of using a `schema()`, define a `steps()` array and pass your `Step` objects:

```php
use Filament\Actions\CreateAction;
use Filament\Forms\Components\MarkdownEditor;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Components\Wizard\Step;

CreateAction::make()
    ->steps([
        Step::make('Name')
            ->description('Give the category a unique name')
            ->schema([
                TextInput::make('name')
                    ->required()
                    ->live()
                    ->afterStateUpdated(fn ($state, callable $set) => $set('slug', Str::slug($state))),
                TextInput::make('slug')
                    ->disabled()
                    ->required()
                    ->unique(Category::class, 'slug'),
            ])
            ->columns(2),
        Step::make('Description')
            ->description('Add some extra details')
            ->schema([
                MarkdownEditor::make('description'),
            ]),
        Step::make('Visibility')
            ->description('Control who can view it')
            ->schema([
                Toggle::make('is_visible')
                    ->label('Visible to customers.')
                    ->default(true),
            ]),
    ])
```

Now, create a new record to see your wizard in action! Edit will still use the form defined within the resource class.

If you'd like to allow free navigation, so all the steps are skippable, use the `skippableSteps()` method:

```php
use Filament\Actions\CreateAction;

CreateAction::make()
    ->steps([
        // ...
    ])
    ->skippableSteps()
```

## Creating another record

### Modifying the create another action

If you'd like to modify the "create another" action, you may use the `createAnotherAction()` method, passing a function that returns an action. All methods that are available to [customize action trigger buttons](overview) can be used:

```php
use Filament\Actions\CreateAction;

CreateAction::make()
    ->createAnotherAction(fn (Action $action): Action => $aciton->label('Custom create another label'))
```

### Disabling create another

If you'd like to remove the "create another" button from the modal, you can use the `createAnother(false)` method:

```php
use Filament\Actions\CreateAction;

CreateAction::make()
    ->createAnother(false)
```

<UtilityInjection set="actions" version="4.x">As well as allowing a static value, the `createAnother()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Preserving data when creating another

By default, when the user uses the "create and create another" feature, all the form data is cleared so the user can start fresh. If you'd like to preserve some of the data in the form, you may use the `preserveFormDataWhenCreatingAnother()` method, passing an array of fields to preserve:

```php
use Filament\Actions\CreateAction;

CreateAction::make()
    ->preserveFormDataWhenCreatingAnother(['is_admin', 'organization'])
```

Alternatively, you can define a function that returns an array of the `$data` to preserve:

```php
use Filament\Actions\CreateAction;
use Illuminate\Support\Arr;

CreateAction::make()
    ->preserveFormDataWhenCreatingAnother(fn (array $data): array => Arr::only($data, ['is_admin', 'organization']))
```

To preserve all the data, return the entire `$data` array:

```php
use Filament\Actions\CreateAction;

CreateAction::make()
    ->preserveFormDataWhenCreatingAnother(fn (array $data): array => $data)
```

<UtilityInjection set="actions" version="4.x">As well as allowing a static value, the `preserveFormDataWhenCreatingAnother()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

# Documentation for actions. File: 05-edit.md
---
title: Edit action
---
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

Filament includes an action that is able to edit Eloquent records. When the trigger button is clicked, a modal will open with a form inside. The user fills the form, and that data is validated and saved into the database. You may use it like so:

```php
use Filament\Actions\EditAction;
use Filament\Forms\Components\TextInput;

EditAction::make()
    ->schema([
        TextInput::make('title')
            ->required()
            ->maxLength(255),
        // ...
    ])
```

## Customizing data before filling the form

You may wish to modify the data from a record before it is filled into the form. To do this, you may use the `mutateRecordDataUsing()` method to modify the `$data` array, and return the modified version before it is filled into the form:

```php
use Filament\Actions\EditAction;

EditAction::make()
    ->mutateRecordDataUsing(function (array $data): array {
        $data['user_id'] = auth()->id();

        return $data;
    })
```

<UtilityInjection set="actions" version="4.x">As well as `$data`, the `mutateRecordDataUsing()` function can inject various utilities as parameters.</UtilityInjection>

## Customizing data before saving

Sometimes, you may wish to modify form data before it is finally saved to the database. To do this, you may use the `mutateDataUsing()` method, which has access to the `$data` as an array, and returns the modified version:

```php
use Filament\Actions\EditAction;

EditAction::make()
    ->mutateDataUsing(function (array $data): array {
        $data['last_edited_by_id'] = auth()->id();

        return $data;
    })
```

<UtilityInjection set="actions" version="4.x">As well as `$data`, the `mutateDataUsing()` function can inject various utilities as parameters.</UtilityInjection>

## Customizing the saving process

You can tweak how the record is updated with the `using()` method:

```php
use Filament\Actions\EditAction;
use Illuminate\Database\Eloquent\Model;

EditAction::make()
    ->using(function (Model $record, array $data): Model {
        $record->update($data);

        return $record;
    })
```

<UtilityInjection set="actions" version="4.x">As well as `$record` and `$data`, the `using()` function can inject various utilities as parameters.</UtilityInjection>

## Redirecting after saving

You may set up a custom redirect when the form is submitted using the `successRedirectUrl()` method:

```php
use Filament\Actions\EditAction;

EditAction::make()
    ->successRedirectUrl(route('posts.list'))
```

If you want to redirect using the created record, use the `$record` parameter:

```php
use Filament\Actions\EditAction;
use Illuminate\Database\Eloquent\Model;

EditAction::make()
    ->successRedirectUrl(fn (Model $record): string => route('posts.view', [
        'post' => $record,
    ]))
```

<UtilityInjection set="actions" version="4.x">As well as `$record`, the `successRedirectUrl()` function can inject various utilities as parameters.</UtilityInjection>

## Customizing the save notification

When the record is successfully updated, a notification is dispatched to the user, which indicates the success of their action.

To customize the title of this notification, use the `successNotificationTitle()` method:

```php
use Filament\Actions\EditAction;

EditAction::make()
    ->successNotificationTitle('User updated')
```

<UtilityInjection set="actions" version="4.x">As well as allowing a static value, the `successNotificationTitle()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

You may customize the entire notification using the `successNotification()` method:

```php
use Filament\Actions\EditAction;
use Filament\Notifications\Notification;

EditAction::make()
    ->successNotification(
       Notification::make()
            ->success()
            ->title('User updated')
            ->body('The user has been saved successfully.'),
    )
```

<UtilityInjection set="actions" version="4.x" extras="Notification;;Filament\Notifications\Notification;;$notification;;The default notification object, which could be a useful starting point for customization.">As well as allowing a static value, the `successNotification()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

To disable the notification altogether, use the `successNotification(null)` method:

```php
use Filament\Actions\EditAction;

EditAction::make()
    ->successNotification(null)
```

## Lifecycle hooks

Hooks may be used to execute code at various points within the action's lifecycle, like before a form is saved.

There are several available hooks:

```php
use Filament\Actions\EditAction;

EditAction::make()
    ->beforeFormFilled(function () {
        // Runs before the form fields are populated from the database.
    })
    ->afterFormFilled(function () {
        // Runs after the form fields are populated from the database.
    })
    ->beforeFormValidated(function () {
        // Runs before the form fields are validated when the form is saved.
    })
    ->afterFormValidated(function () {
        // Runs after the form fields are validated when the form is saved.
    })
    ->before(function () {
        // Runs before the form fields are saved to the database.
    })
    ->after(function () {
        // Runs after the form fields are saved to the database.
    })
```

<UtilityInjection set="actions" version="4.x">These hook functions can inject various utilities as parameters.</UtilityInjection>

## Halting the saving process

At any time, you may call `$action->halt()` from inside a lifecycle hook or mutation method, which will halt the entire saving process:

```php
use App\Models\Post;
use Filament\Actions\Action;
use Filament\Actions\EditAction;
use Filament\Notifications\Notification;

EditAction::make()
    ->before(function (EditAction $action, Post $record) {
        if (! $record->team->subscribed()) {
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
        
            $action->halt();
        }
    })
```

If you'd like the action modal to close too, you can completely `cancel()` the action instead of halting it:

```php
$action->cancel();
```

# Documentation for actions. File: 06-view.md
---
title: View action
---
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

Filament includes an action that is able to view Eloquent records. When the trigger button is clicked, a modal will open with information inside. Filament uses form fields to structure this information. All form fields are disabled, so they are not editable by the user. You may use it like so:

```php
use Filament\Actions\ViewAction;
use Filament\Forms\Components\TextInput;

ViewAction::make()
    ->schema([
        TextInput::make('title')
            ->required()
            ->maxLength(255),
        // ...
    ])
```

## Customizing data before filling the form

You may wish to modify the data from a record before it is filled into the form. To do this, you may use the `mutateRecordDataUsing()` method to modify the `$data` array, and return the modified version before it is filled into the form:

```php
use Filament\Actions\ViewAction;

ViewAction::make()
    ->mutateRecordDataUsing(function (array $data): array {
        $data['user_id'] = auth()->id();

        return $data;
    })
```

<UtilityInjection set="actions" version="4.x">As well as `$data`, the `mutateRecordDataUsing()` function can inject various utilities as parameters.</UtilityInjection>

# Documentation for actions. File: 07-delete.md
---
title: Delete action
---
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

Filament includes an action that is able to delete Eloquent records. When the trigger button is clicked, a modal asks the user for confirmation. You may use it like so:

```php
use Filament\Actions\DeleteAction;

DeleteAction::make()
```

Or if you want to add it as a table bulk action, so that the user can choose which rows to delete, use `Filament\Actions\DeleteBulkAction`:

```php
use Filament\Actions\DeleteBulkAction;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->toolbarActions([
            DeleteBulkAction::make(),
        ]);
}
```

## Redirecting after deleting

You may set up a custom redirect when the record is deleted using the `successRedirectUrl()` method:

```php
use Filament\Actions\DeleteAction;

DeleteAction::make()
    ->successRedirectUrl(route('posts.list'))
```

<UtilityInjection set="actions" version="4.x">As well as `$record`, the `successRedirectUrl()` function can inject various utilities as parameters.</UtilityInjection>

## Customizing the delete notification

When the record is successfully deleted, a notification is dispatched to the user, which indicates the success of their action.

To customize the title of this notification, use the `successNotificationTitle()` method:

```php
use Filament\Actions\DeleteAction;

DeleteAction::make()
    ->successNotificationTitle('User deleted')
```

<UtilityInjection set="actions" version="4.x">As well as allowing a static value, the `successNotificationTitle()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

You may customize the entire notification using the `successNotification()` method:

```php
use Filament\Actions\DeleteAction;
use Filament\Notifications\Notification;

DeleteAction::make()
    ->successNotification(
       Notification::make()
            ->success()
            ->title('User deleted')
            ->body('The user has been deleted successfully.'),
    )
```

<UtilityInjection set="actions" version="4.x" extras="Notification;;Filament\Notifications\Notification;;$notification;;The default notification object, which could be a useful starting point for customization.">As well as allowing a static value, the `successNotification()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

To disable the notification altogether, use the `successNotification(null)` method:

```php
use Filament\Actions\DeleteAction;

DeleteAction::make()
    ->successNotification(null)
```

## Lifecycle hooks

You can use the `before()` and `after()` methods to execute code before and after a record is deleted:

```php
use Filament\Actions\DeleteAction;

DeleteAction::make()
    ->before(function () {
        // ...
    })
    ->after(function () {
        // ...
    })
```

<UtilityInjection set="actions" version="4.x">These hook functions can inject various utilities as parameters.</UtilityInjection>

## Improving the performance of delete bulk actions

By default, the `DeleteBulkAction` will load all Eloquent records into memory, before looping over them and deleting them one by one.

If you are deleting a large number of records, you may want to use the `chunkSelectedRecords()` method to fetch a smaller number of records at a time. This will reduce the memory usage of your application:

```php
use Filament\Actions\DeleteBulkAction;

DeleteBulkAction::make()
    ->chunkSelectedRecords(250)
```

Filament loads Eloquent records into memory before deleting them for two reasons:

- To allow individual records in the collection to be authorized with a model policy before deletion (using `authorizeIndividualRecords('delete')`, for example).
- To ensure that model events are run when deleting records, such as the `deleting` and `deleted` events in a model observer.

If you do not require individual record policy authorization and model events, you can use the `fetchSelectedRecords(false)` method, which will not fetch the records into memory before deleting them, and instead will delete them in a single query:

```php
use Filament\Actions\DeleteBulkAction;

DeleteBulkAction::make()
    ->fetchSelectedRecords(false)
```

# Documentation for actions. File: 08-replicate.md
---
title: Replicate action
---
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

Filament includes an action that is able to [replicate](https://laravel.com/docs/eloquent#replicating-models) Eloquent records. You may use it like so:

```php
use Filament\Actions\ReplicateAction;

ReplicateAction::make()
```

## Excluding attributes

The `excludeAttributes()` method is used to instruct the action which columns should be excluded from replication:

```php
use Filament\Actions\ReplicateAction;

ReplicateAction::make()
    ->excludeAttributes(['slug'])
```

## Customizing data before filling the form

You may wish to modify the data from a record before it is filled into the form. To do this, you may use the `mutateRecordDataUsing()` method to modify the `$data` array, and return the modified version before it is filled into the form:

```php
use Filament\Actions\ReplicateAction;

ReplicateAction::make()
    ->mutateRecordDataUsing(function (array $data): array {
        $data['user_id'] = auth()->id();

        return $data;
    })
```

## Redirecting after replication

You may set up a custom redirect when the form is submitted using the `successRedirectUrl()` method:

```php
use Filament\Actions\ReplicateAction;

ReplicateAction::make()
    ->successRedirectUrl(route('posts.list'))
```

<UtilityInjection set="actions" version="4.x" extras="Replica Eloquent record;;Illuminate\Database\Eloquent\Model;;$replica;;The Eloquent model instance that was just created as a replica of the original record.">As well as `$record`, the `successRedirectUrl()` function can inject various utilities as parameters.</UtilityInjection>

## Customizing the replicate notification

When the record is successfully replicated, a notification is dispatched to the user, which indicates the success of their action.

To customize the title of this notification, use the `successNotificationTitle()` method:

```php
use Filament\Actions\ReplicateAction;

ReplicateAction::make()
    ->successNotificationTitle('Category replicated')
```

<UtilityInjection set="actions" version="4.x" extras="Replica Eloquent record;;Illuminate\Database\Eloquent\Model;;$replica;;The Eloquent model instance that was just created as a replica of the original record.">As well as allowing a static value, the `successNotificationTitle()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

You may customize the entire notification using the `successNotification()` method:

```php
use Filament\Actions\ReplicateAction;
use Filament\Notifications\Notification;

ReplicateAction::make()
    ->successNotification(
       Notification::make()
            ->success()
            ->title('Category replicated')
            ->body('The category has been replicated successfully.'),
    )
```

<UtilityInjection set="actions" version="4.x" extras="Notification;;Filament\Notifications\Notification;;$notification;;The default notification object, which could be a useful starting point for customization.||Replica Eloquent record;;Illuminate\Database\Eloquent\Model;;$replica;;The Eloquent model instance that was just created as a replica of the original record.">As well as allowing a static value, the `successNotification()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

To disable the notification altogether, use the `successNotification(null)` method:

```php
use Filament\Actions\RestoreAction;

ReplicateAction::make()
    ->successNotification(null)
```

## Lifecycle hooks

Hooks may be used to execute code at various points within the action's lifecycle, like before the replica is saved.

```php
use Filament\Actions\ReplicateAction;
use Illuminate\Database\Eloquent\Model;

ReplicateAction::make()
    ->before(function () {
        // Runs before the record has been replicated.
    })
    ->beforeReplicaSaved(function (Model $replica): void {
        // Runs after the record has been replicated but before it is saved to the database.
    })
    ->after(function (Model $replica): void {
        // Runs after the replica has been saved to the database.
    })
```

<UtilityInjection set="actions" version="4.x" extras="Replica Eloquent record;;Illuminate\Database\Eloquent\Model;;$replica;;The Eloquent model instance that was just created as a replica of the original record.">These hook functions can inject various utilities as parameters.</UtilityInjection>

## Halting the replication process

At any time, you may call `$action->halt()` from inside a lifecycle hook, which will halt the entire replication process:

```php
use App\Models\Post;
use Filament\Actions\Action;
use Filament\Actions\ReplicateAction;
use Filament\Notifications\Notification;

ReplicateAction::make()
    ->before(function (ReplicateAction $action, Post $record) {
        if (! $record->team->subscribed()) {
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
        
            $action->halt();
        }
    })
```

If you'd like the action modal to close too, you can completely `cancel()` the action instead of halting it:

```php
$action->cancel();
```

# Documentation for actions. File: 09-force-delete.md
---
title: Force-delete action
---
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

Filament includes an action that is able to force-delete [soft-deleted](https://laravel.com/docs/eloquent#soft-deleting) Eloquent records. When the trigger button is clicked, a modal asks the user for confirmation. You may use it like so:

```php
use Filament\Actions\ForceDeleteAction;

ForceDeleteAction::make()
```

Or if you want to add it as a table bulk action, so that the user can choose which rows to force-delete, use `Filament\Actions\ForceDeleteBulkAction`:

```php
use Filament\Actions\ForceDeleteBulkAction;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->toolbarActions([
            ForceDeleteBulkAction::make(),
        ]);
}
```

## Redirecting after force-deleting

You may set up a custom redirect when the form is submitted using the `successRedirectUrl()` method:

```php
use Filament\Actions\ForceDeleteAction;

ForceDeleteAction::make()
    ->successRedirectUrl(route('posts.list'))
```

<UtilityInjection set="actions" version="4.x">As well as `$record`, the `successRedirectUrl()` function can inject various utilities as parameters.</UtilityInjection>

## Customizing the force-delete notification

When the record is successfully force-deleted, a notification is dispatched to the user, which indicates the success of their action.

To customize the title of this notification, use the `successNotificationTitle()` method:

```php
use Filament\Actions\ForceDeleteAction;

ForceDeleteAction::make()
    ->successNotificationTitle('User force-deleted')
```

<UtilityInjection set="actions" version="4.x">As well as allowing a static value, the `successNotificationTitle()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

You may customize the entire notification using the `successNotification()` method:

```php
use Filament\Actions\ForceDeleteAction;
use Filament\Notifications\Notification;

ForceDeleteAction::make()
    ->successNotification(
       Notification::make()
            ->success()
            ->title('User force-deleted')
            ->body('The user has been force-deleted successfully.'),
    )
```

<UtilityInjection set="actions" version="4.x" extras="Notification;;Filament\Notifications\Notification;;$notification;;The default notification object, which could be a useful starting point for customization.">As well as allowing a static value, the `successNotification()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

To disable the notification altogether, use the `successNotification(null)` method:

```php
use Filament\Actions\ForceDeleteAction;

ForceDeleteAction::make()
    ->successNotification(null)
```

## Lifecycle hooks

You can use the `before()` and `after()` methods to execute code before and after a record is force-deleted:

```php
use Filament\Actions\ForceDeleteAction;

ForceDeleteAction::make()
    ->before(function () {
        // ...
    })
    ->after(function () {
        // ...
    })
```

<UtilityInjection set="actions" version="4.x">These hook functions can inject various utilities as parameters.</UtilityInjection>

## Improving the performance of force-delete bulk actions

By default, the `ForceDeleteBulkAction` will load all Eloquent records into memory, before looping over them and deleting them one by one.

If you are deleting a large number of records, you may want to use the `chunkSelectedRecords()` method to fetch a smaller number of records at a time. This will reduce the memory usage of your application:

```php
use Filament\Actions\ForceDeleteBulkAction;

ForceDeleteBulkAction::make()
    ->chunkSelectedRecords(250)
```

Filament loads Eloquent records into memory before deleting them for two reasons:

- To allow individual records in the collection to be authorized with a model policy before deletion (using `authorizeIndividualRecords('forceDelete')`, for example).
- To ensure that model events are run when deleting records, such as the `forceDeleting` and `forceDeleted` events in a model observer.

If you do not require individual record policy authorization and model events, you can use the `fetchSelectedRecords(false)` method, which will not fetch the records into memory before deleting them, and instead will delete them in a single query:

```php
use Filament\Actions\ForceDeleteBulkAction;

ForceDeleteBulkAction::make()
    ->fetchSelectedRecords(false)
```

# Documentation for actions. File: 10-restore.md
---
title: Restore action
---
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

Filament includes an action that is able to restore [soft-deleted](https://laravel.com/docs/eloquent#soft-deleting) Eloquent records. When the trigger button is clicked, a modal asks the user for confirmation. You may use it like so:

```php
use Filament\Actions\RestoreAction;

RestoreAction::make()
```

Or if you want to add it as a table bulk action, so that the user can choose which rows to restore, use `Filament\Actions\RestoreBulkAction`:

```php
use Filament\Actions\RestoreBulkAction;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->toolbarActions([
            RestoreBulkAction::make(),
        ]);
}
```

## Redirecting after restoring

You may set up a custom redirect when the form is submitted using the `successRedirectUrl()` method:

```php
use Filament\Actions\RestoreAction;

RestoreAction::make()
    ->successRedirectUrl(route('posts.list'))
```

<UtilityInjection set="actions" version="4.x">As well as `$record`, the `successRedirectUrl()` function can inject various utilities as parameters.</UtilityInjection>

## Customizing the restore notification

When the record is successfully restored, a notification is dispatched to the user, which indicates the success of their action.

To customize the title of this notification, use the `successNotificationTitle()` method:

```php
use Filament\Actions\RestoreAction;

RestoreAction::make()
    ->successNotificationTitle('User restored')
```

<UtilityInjection set="actions" version="4.x">As well as allowing a static value, the `successNotificationTitle()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

You may customize the entire notification using the `successNotification()` method:

```php
use Filament\Actions\RestoreAction;
use Filament\Notifications\Notification;

RestoreAction::make()
    ->successNotification(
       Notification::make()
            ->success()
            ->title('User restored')
            ->body('The user has been restored successfully.'),
    )
```

<UtilityInjection set="actions" version="4.x" extras="Notification;;Filament\Notifications\Notification;;$notification;;The default notification object, which could be a useful starting point for customization.">As well as allowing a static value, the `successNotification()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

To disable the notification altogether, use the `successNotification(null)` method:

```php
use Filament\Actions\RestoreAction;

RestoreAction::make()
    ->successNotification(null)
```

## Lifecycle hooks

You can use the `before()` and `after()` methods to execute code before and after a record is restored:

```php
use Filament\Actions\RestoreAction;

RestoreAction::make()
    ->before(function () {
        // ...
    })
    ->after(function () {
        // ...
    })
```

<UtilityInjection set="actions" version="4.x">These hook functions can inject various utilities as parameters.</UtilityInjection>

## Improving the performance of restore bulk actions

By default, the `RestoreBulkAction` will load all Eloquent records into memory, before looping over them and restoring them one by one.

If you are restoring a large number of records, you may want to use the `chunkSelectedRecords()` method to fetch a smaller number of records at a time. This will reduce the memory usage of your application:

```php
use Filament\Actions\RestoreBulkAction;

RestoreBulkAction::make()
    ->chunkSelectedRecords(250)
```

Filament loads Eloquent records into memory before restoring them for two reasons:

- To allow individual records in the collection to be authorized with a model policy before restoration (using `authorizeIndividualRecords('restore')`, for example).
- To ensure that model events are run when restoring records, such as the `restoring` and `restored` events in a model observer.

If you do not require individual record policy authorization and model events, you can use the `fetchSelectedRecords(false)` method, which will not fetch the records into memory before restoring them, and instead will restore them in a single query:

```php
use Filament\Actions\RestoreBulkAction;

RestoreBulkAction::make()
    ->fetchSelectedRecords(false)
```

# Documentation for actions. File: 11-import.md
---
title: Import action
---
import Aside from "@components/Aside.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

Filament includes an action that is able to import rows from a CSV. When the trigger button is clicked, a modal asks the user for a file. Once they upload one, they are able to map each column in the CSV to a real column in the database. If any rows fail validation, they will be compiled into a downloadable CSV for the user to review after the rest of the rows have been imported. Users can also download an example CSV file containing all the columns that can be imported.

This feature uses [job batches](https://laravel.com/docs/queues#job-batching) and [database notifications](../../notifications/database-notifications), so you need to publish those migrations from Laravel. Also, you need to publish the migrations for tables that Filament uses to store information about imports:

```bash
php artisan make:queue-batches-table
php artisan make:notifications-table
php artisan vendor:publish --tag=filament-actions-migrations
php artisan migrate
```

<Aside variant="info">
    If you're using PostgreSQL, make sure that the `data` column in the notifications migration is using `json()`: `$table->json('data')`.
</Aside>

<Aside variant="info">
    If you're using UUIDs for your `User` model, make sure that your `notifiable` column in the notifications migration is using `uuidMorphs()`: `$table->uuidMorphs('notifiable')`.
</Aside>

You may use the `ImportAction` like so:

```php
use App\Filament\Imports\ProductImporter;
use Filament\Actions\ImportAction;

ImportAction::make()
    ->importer(ProductImporter::class)
```

If you want to add this action to the header of a table, you may do so like this:

```php
use App\Filament\Imports\ProductImporter;
use Filament\Actions\ImportAction;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->headerActions([
            ImportAction::make()
                ->importer(ProductImporter::class)
        ]);
}
```

The ["importer" class needs to be created](#creating-an-importer) to tell Filament how to import each row of the CSV.

If you have more than one `ImportAction` in the same place, you should give each a unique name in the `make()` method:

```php
use Filament\Actions\ImportAction;

ImportAction::make('importProducts')
    ->importer(ProductImporter::class)

ImportAction::make('importBrands')
    ->importer(BrandImporter::class)
```

## Creating an importer

To create an importer class for a model, you may use the `make:filament-importer` command, passing the name of a model:

```bash
php artisan make:filament-importer Product
```

This will create a new class in the `app/Filament/Imports` directory. You now need to define the [columns](#defining-importer-columns) that can be imported.

### Automatically generating importer columns

If you'd like to save time, Filament can automatically generate the [columns](#defining-importer-columns) for you, based on your model's database columns, using `--generate`:

```bash
php artisan make:filament-importer Product --generate
```

## Defining importer columns

To define the columns that can be imported, you need to override the `getColumns()` method on your importer class, returning an array of `ImportColumn` objects:

```php
use Filament\Actions\Imports\ImportColumn;

public static function getColumns(): array
{
    return [
        ImportColumn::make('name')
            ->requiredMapping()
            ->rules(['required', 'max:255']),
        ImportColumn::make('sku')
            ->label('SKU')
            ->requiredMapping()
            ->rules(['required', 'max:32']),
        ImportColumn::make('price')
            ->numeric()
            ->rules(['numeric', 'min:0']),
    ];
}
```

### Customizing the label of an import column

The label for each column will be generated automatically from its name, but you can override it by calling the `label()` method:

```php
use Filament\Actions\Imports\ImportColumn;

ImportColumn::make('sku')
    ->label('SKU')
```

### Requiring an importer column to be mapped to a CSV column

You can call the `requiredMapping()` method to make a column required to be mapped to a column in the CSV. Columns that are required in the database should be required to be mapped:

```php
use Filament\Actions\Imports\ImportColumn;

ImportColumn::make('sku')
    ->requiredMapping()
```

If you require a column in the database, you also need to make sure that it has a [`rules(['required'])` validation rule](#validating-csv-data).

If a column is not mapped, it will not be validated since there is no data to validate.

If you allow an import to create records as well as [update existing ones](#updating-existing-records-when-importing), but only require a column to be mapped when creating records as it's a required field, you can use the `requiredMappingForNewRecordsOnly()` method instead of `requiredMapping()`:

```php
use Filament\Actions\Imports\ImportColumn;

ImportColumn::make('sku')
    ->requiredMappingForNewRecordsOnly()
```

If the `resolveRecord()` method returns a model instance that is not saved in the database yet, the column will be required to be mapped, just for that row. If the user does not map the column, and one of the rows in the import does not yet exist in the database, just that row will fail and a message will be added to the failed rows CSV after every row has been analyzed.

### Validating CSV data

You can call the `rules()` method to add validation rules to a column. These rules will check the data in each row from the CSV before it is saved to the database:

```php
use Filament\Actions\Imports\ImportColumn;

ImportColumn::make('sku')
    ->rules(['required', 'max:32'])
```

Any rows that do not pass validation will not be imported. Instead, they will be compiled into a new CSV of "failed rows", which the user can download after the import has finished. The user will be shown a list of validation errors for each row that failed.

<UtilityInjection set="importColumns" version="4.x">As well as allowing a static value, the `rules()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Casting state

Before [validation](#validating-csv-data), data from the CSV can be cast. This is useful for converting strings into the correct data type, otherwise validation may fail. For example, if you have a `price` column in your CSV, you may want to cast it to a float:

```php
use Filament\Actions\Imports\ImportColumn;

ImportColumn::make('price')
    ->castStateUsing(function (string $state): ?float {
        if (blank($state)) {
            return null;
        }
        
        $state = preg_replace('/[^0-9.]/', '', $state);
        $state = floatval($state);
    
        return round($state, precision: 2);
    })
```

<UtilityInjection set="importColumns" version="4.x" extras="State;;mixed;;$state;;The state to cast, after it has been processed by other casting methods.||Original state;;mixed;;$originalState;;The state to cast, before it was processed by other casting methods.">As well as `$state`, the `castStateUsing()` method allows you to inject various utilities into the function as parameters.</UtilityInjection>

In this example, we pass in a function that is used to cast the `$state`. This function removes any non-numeric characters from the string, casts it to a float, and rounds it to two decimal places.

<Aside variant="info">
    If a column is not [required by validation](#validating-csv-data), and it is empty, it will not be cast.
</Aside>

Filament also ships with some built-in casting methods:

```php
use Filament\Actions\Imports\ImportColumn;

ImportColumn::make('price')
    ->numeric() // Casts the state to a float.

ImportColumn::make('price')
    ->numeric(decimalPlaces: 2) // Casts the state to a float, and rounds it to 2 decimal places.

ImportColumn::make('quantity')
    ->integer() // Casts the state to an integer.

ImportColumn::make('is_visible')
    ->boolean() // Casts the state to a boolean.
```

#### Mutating the state after it has been cast

If you're using a [built-in casting method](#casting-state) or [array cast](#handling-multiple-values-in-a-single-column), you can mutate the state after it has been cast by passing a function to the `castStateUsing()` method:

```php
use Filament\Actions\Imports\ImportColumn;

ImportColumn::make('price')
    ->numeric()
    ->castStateUsing(function (float $state): ?float {
        if (blank($state)) {
            return null;
        }
    
        return round($state * 100);
    })
```

You can even access the original state before it was cast, by defining an `$originalState` argument in the function:

```php
use Filament\Actions\Imports\ImportColumn;

ImportColumn::make('price')
    ->numeric()
    ->castStateUsing(function (float $state, mixed $originalState): ?float {
        // ...
    })
```

<UtilityInjection set="importColumns" version="4.x" extras="State;;mixed;;$state;;The state to cast, after it has been processed by other casting methods.||Original state;;mixed;;$originalState;;The state to cast, before it was processed by other casting methods.">As well as `$state`, the `castStateUsing()` method allows you to inject various utilities into the function as parameters.</UtilityInjection>

### Handling multiple values in a single column

You may use the `multiple()` method to cast the values in a column to an array. It accepts a delimiter as its first argument, which is used to split the values in the column into an array. For example, if you have a `documentation_urls` column in your CSV, you may want to cast it to an array of URLs:

```php
use Filament\Actions\Imports\ImportColumn;

ImportColumn::make('documentation_urls')
    ->multiple(',')
```

<UtilityInjection set="importColumns" version="4.x">As well as allowing a static value, the `multiple()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

In this example, we pass in a comma as the delimiter, so the values in the column will be split by commas, and cast to an array.

#### Casting each item in an array

If you want to cast each item in the array to a different data type, you can chain the [built-in casting methods](#casting-state):

```php
use Filament\Actions\Imports\ImportColumn;

ImportColumn::make('customer_ratings')
    ->multiple(',')
    ->integer() // Casts each item in the array to an integer.
```

#### Validating each item in an array

If you want to validate each item in the array, you can chain the `nestedRecursiveRules()` method:

```php
use Filament\Actions\Imports\ImportColumn;

ImportColumn::make('customer_ratings')
    ->multiple(',')
    ->integer()
    ->rules(['array'])
    ->nestedRecursiveRules(['integer', 'min:1', 'max:5'])
```

<UtilityInjection set="importColumns" version="4.x">As well as allowing a static value, the `nestedRecursiveRules()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Importing relationships

You may use the `relationship()` method to import a relationship. At the moment, `BelongsTo` and `BelongsToMany` relationships are supported. For example, if you have a `category` column in your CSV, you may want to import the category `BelongsTo` relationship:

```php
use Filament\Actions\Imports\ImportColumn;

ImportColumn::make('author')
    ->relationship()
```

In this example, the `author` column in the CSV will be mapped to the `author_id` column in the database. The CSV should contain the primary keys of authors, usually `id`.

If the column has a value, but the author cannot be found, the import will fail validation. Filament automatically adds validation to all relationship columns, to ensure that the relationship is not empty when it is required.

If you want to import a `BelongsToMany` relationship, make sure that the column is set to [`multiple()`](#handling-multiple-values-in-a-single-column), with the correct separator between values:

```php
use Filament\Actions\Imports\ImportColumn;

ImportColumn::make('authors')
    ->relationship()
    ->multiple(',')
```

#### Customizing the relationship import resolution

If you want to find a related record using a different column, you can pass the column name as `resolveUsing`:

```php
use Filament\Actions\Imports\ImportColumn;

ImportColumn::make('author')
    ->relationship(resolveUsing: 'email')
```

You can pass in multiple columns to `resolveUsing`, and they will be used to find the author, in an "or" fashion. For example, if you pass in `['email', 'username']`, the record can be found by either their email or username:

```php
use Filament\Actions\Imports\ImportColumn;

ImportColumn::make('author')
    ->relationship(resolveUsing: ['email', 'username'])
```

You can also customize the resolution process, by passing in a function to `resolveUsing`, which should return a record to associate with the relationship:

```php
use App\Models\Author;
use Filament\Actions\Imports\ImportColumn;

ImportColumn::make('author')
    ->relationship(resolveUsing: function (string $state): ?Author {
        return Author::query()
            ->where('email', $state)
            ->orWhere('username', $state)
            ->first();
    })
```

<UtilityInjection set="importColumns" version="4.x" extras="State;;mixed;;$state;;The state to resolve into a record.">The function passed to `resolveUsing` allows you to inject various utilities into the function as parameters.</UtilityInjection>

If you are using a `BelongsToMany` relationship, the `$state` will be an array, and you should return a collection of records that you have resolved:

```php
use App\Models\Author;
use Filament\Actions\Imports\ImportColumn;
use Illuminate\Database\Eloquent\Collection;

ImportColumn::make('authors')
    ->relationship(resolveUsing: function (array $states): Collection {
        return Author::query()
            ->whereIn('email', $states)
            ->orWhereIn('username', $states)
            ->get();
    })
```

You could even use this function to dynamically determine which columns to use to resolve the record:

```php
use App\Models\Author;
use Filament\Actions\Imports\ImportColumn;

ImportColumn::make('author')
    ->relationship(resolveUsing: function (string $state): ?Author {
        if (filter_var($state, FILTER_VALIDATE_EMAIL)) {
            return 'email';
        }
    
        return 'username';
    })
```

### Marking column data as sensitive

When import rows fail validation, they are logged to the database, ready for export when the import completes. You may want to exclude certain columns from this logging to avoid storing sensitive data in plain text. To achieve this, you can use the `sensitive()` method on the `ImportColumn` to prevent its data from being logged:

```php
use Filament\Actions\Imports\ImportColumn;

ImportColumn::make('ssn')
    ->label('Social security number')
    ->sensitive()
    ->rules(['required', 'digits:9'])
```

### Customizing how a column is filled into a record

If you want to customize how column state is filled into a record, you can pass a function to the `fillRecordUsing()` method:

```php
use App\Models\Product;
use Filament\Actions\Imports\ImportColumn;

ImportColumn::make('sku')
    ->fillRecordUsing(function (Product $record, string $state): void {
        $record->sku = strtoupper($state);
    })
```

<UtilityInjection set="importColumns" version="4.x" extras="State;;mixed;;$state;;The state to fill into the record.">The function passed to the `fillRecordUsing()` method allows you to inject various utilities into the function as parameters.</UtilityInjection>

### Adding helper text below the import column

Sometimes, you may wish to provide extra information for the user before validation. You can do this by adding `helperText()` to a column, which gets displayed below the mapping select:

```php
use Filament\Actions\Imports\ImportColumn;

ImportColumn::make('skus')
    ->multiple(',')
    ->helperText('A comma-separated list of SKUs.')
```

## Updating existing records when importing

When generating an importer class, you will see this `resolveRecord()` method:

```php
use App\Models\Product;

public function resolveRecord(): ?Product
{
    // return Product::firstOrNew([
    //     // Update existing records, matching them by `$this->data['column_name']`
    //     'email' => $this->data['email'],
    // ]);

    return new Product();
}
```

This method is called for each row in the CSV, and is responsible for returning a model instance that will be filled with the data from the CSV, and saved to the database. By default, it will create a new record for each row. However, you can customize this behavior to update existing records instead. For example, you might want to update a product if it already exists, and create a new one if it doesn't. To do this, you can uncomment the `firstOrNew()` line, and pass the column name that you want to match on. For a product, we might want to match on the `sku` column:

```php
use App\Models\Product;

public function resolveRecord(): ?Product
{
    return Product::firstOrNew([
        'sku' => $this->data['sku'],
    ]);
}
```

### Updating existing records when importing only

If you want to write an importer that only updates existing records, and does not create new ones, you can return `null` if no record is found:

```php
use App\Models\Product;

public function resolveRecord(): ?Product
{
    return Product::query()
        ->where('sku', $this->data['sku'])
        ->first();
}
```

If you'd like to fail the import row if no record is found, you can throw a `RowImportFailedException` with a message:

```php
use App\Models\Product;
use Filament\Actions\Imports\Exceptions\RowImportFailedException;

public function resolveRecord(): ?Product
{
    $product = Product::query()
        ->where('sku', $this->data['sku'])
        ->first();

    if (! $product) {
        throw new RowImportFailedException("No product found with SKU [{$this->data['sku']}].");
    }

    return $product;
}
```

When the import is completed, the user will be able to download a CSV of failed rows, which will contain the error messages.

### Ignoring blank state for an import column

By default, if a column in the CSV is blank, and mapped by the user, and it's not required by validation, the column will be imported as `null` in the database. If you'd like to ignore blank state, and use the existing value in the database instead, you can call the `ignoreBlankState()` method:

```php
use Filament\Actions\Imports\ImportColumn;

ImportColumn::make('price')
    ->ignoreBlankState()
```

## Using import options

The import action can render extra form components that the user can interact with when importing a CSV. This can be useful to allow the user to customize the behavior of the importer. For instance, you might want a user to be able to choose whether to update existing records when importing, or only create new ones. To do this, you can return options form components from the `getOptionsFormComponents()` method on your importer class:

```php
use Filament\Forms\Components\Checkbox;

public static function getOptionsFormComponents(): array
{
    return [
        Checkbox::make('updateExisting')
            ->label('Update existing records'),
    ];
}
```

Alternatively, you can pass a set of static options to the importer through the `options()` method on the action:

```php
use App\Filament\Imports\ProductImporter;
use Filament\Actions\ImportAction;

ImportAction::make()
    ->importer(ProductImporter::class)
    ->options([
        'updateExisting' => true,
    ])
```

Now, you can access the data from these options inside the importer class, by calling `$this->options`. For example, you might want to use it inside `resolveRecord()` to [update an existing product](#updating-existing-records-when-importing):

```php
use App\Models\Product;

public function resolveRecord(): ?Product
{
    if ($this->options['updateExisting'] ?? false) {
        return Product::firstOrNew([
            'sku' => $this->data['sku'],
        ]);
    }

    return new Product();
}
```

## Improving import column mapping guesses

By default, Filament will attempt to "guess" which columns in the CSV match which columns in the database, to save the user time. It does this by attempting to find different combinations of the column name, with spaces, `-`, `_`, all cases insensitively. However, if you'd like to improve the guesses, you can call the `guess()` method with more examples of the column name that could be present in the CSV:

```php
use Filament\Actions\Imports\ImportColumn;

ImportColumn::make('sku')
    ->guess(['id', 'number', 'stock-keeping unit'])
```

## Providing example CSV data

Before the user uploads a CSV, they have an option to download an example CSV file, containing all the available columns that can be imported. This is useful, as it allows the user to import this file directly into their spreadsheet software, and fill it out.

You can also add an example row to the CSV, to show the user what the data should look like. To fill in this example row, you can pass in an example column value to the `example()` method:

```php
use Filament\Actions\Imports\ImportColumn;

ImportColumn::make('sku')
    ->example('ABC123')
```

Or if you want to add more than one example row, you can pass an array to the `examples()` method:

```php
use Filament\Actions\Imports\ImportColumn;

ImportColumn::make('sku')
    ->examples(['ABC123', 'DEF456'])
```

By default, the name of the column is used in the header of the example CSV. You can customize the header per-column using `exampleHeader()`:

```php
use Filament\Actions\Imports\ImportColumn;

ImportColumn::make('sku')
    ->exampleHeader('SKU')
```

## Using a custom user model

By default, the `imports` table has a `user_id` column. That column is constrained to the `users` table:

```php
$table->foreignId('user_id')->constrained()->cascadeOnDelete();
```

In the `Import` model, the `user()` relationship is defined as a `BelongsTo` relationship to the `App\Models\User` model. If the `App\Models\User` model does not exist, or you want to use a different one, you can bind a new `Authenticatable` model to the container in a service provider's `register()` method:

```php
use App\Models\Admin;
use Illuminate\Contracts\Auth\Authenticatable;

$this->app->bind(Authenticatable::class, Admin::class);
```

If your authenticatable model uses a different table to `users`, you should pass that table name to `constrained()`:

```php
$table->foreignId('user_id')->constrained('admins')->cascadeOnDelete();
```

### Using a polymorphic user relationship

If you want to associate imports with multiple user models, you can use a polymorphic `MorphTo` relationship instead. To do this, you need to replace the `user_id` column in the `imports` table:

```php
$table->morphs('user');
```

Then, in a service provider's `boot()` method, you should call `Import::polymorphicUserRelationship()` to swap the `user()` relationship on the `Import` model to a `MorphTo` relationship:

```php
use Filament\Actions\Imports\Models\Import;

Import::polymorphicUserRelationship();
```

## Limiting the maximum number of rows that can be imported

To prevent server overload, you may wish to limit the maximum number of rows that can be imported from one CSV file. You can do this by calling the `maxRows()` method on the action:

```php
use App\Filament\Imports\ProductImporter;
use Filament\Actions\ImportAction;

ImportAction::make()
    ->importer(ProductImporter::class)
    ->maxRows(100000)
```

<UtilityInjection set="actions" version="4.x">As well as allowing a static value, the `maxRows()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Changing the import chunk size

Filament will chunk the CSV, and process each chunk in a different queued job. By default, chunks are 100 rows at a time. You can change this by calling the `chunkSize()` method on the action:

```php
use App\Filament\Imports\ProductImporter;
use Filament\Actions\ImportAction;

ImportAction::make()
    ->importer(ProductImporter::class)
    ->chunkSize(250)
```

<UtilityInjection set="actions" version="4.x">As well as allowing a static value, the `chunkSize()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<Aside variant="tip">
    If you are encountering memory or timeout issues when importing large CSV files, you may wish to reduce the chunk size.
</Aside>

## Changing the CSV delimiter

The default delimiter for CSVs is the comma (`,`). If your import uses a different delimiter, you may call the `csvDelimiter()` method on the action, passing a new one:

```php
use App\Filament\Imports\ProductImporter;
use Filament\Actions\ImportAction;

ImportAction::make()
    ->importer(ProductImporter::class)
    ->csvDelimiter(';')
```

<UtilityInjection set="actions" version="4.x">As well as allowing a static value, the `csvDelimiter()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

You can only specify a single character, otherwise an exception will be thrown.

## Changing the column header offset

If your column headers are not on the first row of the CSV, you can call the `headerOffset()` method on the action, passing the number of rows to skip:

```php
use App\Filament\Imports\ProductImporter;
use Filament\Actions\ImportAction;

ImportAction::make()
    ->importer(ProductImporter::class)
    ->headerOffset(5)
```

<UtilityInjection set="actions" version="4.x">As well as allowing a static value, the `headerOffset()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Customizing the import job

The default job for processing imports is `Filament\Actions\Imports\Jobs\ImportCsv`. If you want to extend this class and override any of its methods, you may replace the original class in the `register()` method of a service provider:

```php
use App\Jobs\ImportCsv;
use Filament\Actions\Imports\Jobs\ImportCsv as BaseImportCsv;

$this->app->bind(BaseImportCsv::class, ImportCsv::class);
```

Or, you can pass the new job class to the `job()` method on the action, to customize the job for a specific import:

```php
use App\Filament\Imports\ProductImporter;
use App\Jobs\ImportCsv;
use Filament\Actions\ImportAction;

ImportAction::make()
    ->importer(ProductImporter::class)
    ->job(ImportCsv::class)
```

### Customizing the import queue and connection

By default, the import system will use the default queue and connection. If you'd like to customize the queue used for jobs of a certain importer, you may override the `getJobQueue()` method in your importer class:

```php
public function getJobQueue(): ?string
{
    return 'imports';
}
```

You can also customize the connection used for jobs of a certain importer, by overriding the `getJobConnection()` method in your importer class:

```php
public function getJobConnection(): ?string
{
    return 'sqs';
}
```

### Customizing the import job middleware

By default, the import system will only process one job at a time from each import. This is to prevent the server from being overloaded, and other jobs from being delayed by large imports. That functionality is defined in the `WithoutOverlapping` middleware on the importer class:

```php
use Illuminate\Queue\Middleware\WithoutOverlapping;

public function getJobMiddleware(): array
{
    return [
        (new WithoutOverlapping("import{$this->import->getKey()}"))->expireAfter(600),
    ];
}
```

If you'd like to customize the middleware that is applied to jobs of a certain importer, you may override this method in your importer class. You can read more about job middleware in the [Laravel docs](https://laravel.com/docs/queues#job-middleware).

### Customizing the import job retries

By default, the import system will retry a job for 24 hours, or until it fails 5 times with unhandled exceptions, whichever happens first. This is to allow for temporary issues, such as the database being unavailable, to be resolved. You may change the time period for the job to retry, which is defined in the `getJobRetryUntil()` method on the exporter class:

```php
use Carbon\CarbonInterface;

public function getJobRetryUntil(): ?CarbonInterface
{
    return now()->addHours(12);
}
```

You can read more about job retries in the [Laravel docs](https://laravel.com/docs/queues#max-job-attempts-and-timeout).

#### Customizing the import job backoff strategy

By default, the import system will wait 1 minute, then 2 minutes, then 5 minutes, then 10 minutes thereafter, before retrying a job. This is to prevent the server from being overloaded by a job that is failing repeatedly. That functionality is defined in the `getJobBackoff()` method on the importer class:

```php
/**
* @return int | array<int> | null
 */
public function getJobBackoff(): int | array | null
{
    return [60, 120, 300, 600];
}
```

You can read more about job backoff, including how to configure exponential backoffs, in the [Laravel docs](https://laravel.com/docs/queues#dealing-with-failed-jobs).

### Customizing the import job tags

By default, the import system will tag each job with the ID of the import. This is to allow you to easily find all jobs related to a certain import. That functionality is defined in the `getJobTags()` method on the importer class:

```php
public function getJobTags(): array
{
    return ["import{$this->import->getKey()}"];
}
```

If you'd like to customize the tags that are applied to jobs of a certain importer, you may override this method in your importer class.

### Customizing the import job batch name

By default, the import system doesn't define any name for the job batches. If you'd like to customize the name that is applied to job batches of a certain importer, you may override the `getJobBatchName()` method in your importer class:

```php
public function getJobBatchName(): ?string
{
    return 'product-import';
}
```

## Customizing import validation messages

The import system will automatically validate the CSV file before it is imported. If there are any errors, the user will be shown a list of them, and the import will not be processed. If you'd like to override any default validation messages, you may do so by overriding the `getValidationMessages()` method on your importer class:

```php
public function getValidationMessages(): array
{
    return [
        'name.required' => 'The name column must not be empty.',
    ];
}
```

To learn more about customizing validation messages, read the [Laravel docs](https://laravel.com/docs/validation#customizing-the-error-messages).

### Customizing import validation attributes

When columns fail validation, their label is used in the error message. To customize the label used in field error messages, use the `validationAttribute()` method:

```php
use Filament\Actions\Imports\ImportColumn;

ImportColumn::make('name')
    ->validationAttribute('full name')
```

## Customizing import file validation

You can add new [Laravel validation rules](https://laravel.com/docs/validation#available-validation-rules) for the import file using the `fileRules()` method:

```php
use Filament\Actions\ImportAction;
use Illuminate\Validation\Rules\File;

ImportAction::make()
    ->importer(ProductImporter::class)
    ->fileRules([
        'max:1024',
        // or
        File::types(['csv', 'txt'])->max(1024),
    ]),
```

<UtilityInjection set="actions" version="4.x">As well as allowing a static value, the `fileRules()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Lifecycle hooks

Hooks may be used to execute code at various points within an importer's lifecycle, like before a record is saved. To set up a hook, create a protected method on the importer class with the name of the hook:

```php
protected function beforeSave(): void
{
    // ...
}
```

In this example, the code in the `beforeSave()` method will be called before the validated data from the CSV is saved to the database.

There are several available hooks for importers:

```php
use Filament\Actions\Imports\Importer;

class ProductImporter extends Importer
{
    // ...

    protected function beforeValidate(): void
    {
        // Runs before the CSV data for a row is validated.
    }

    protected function afterValidate(): void
    {
        // Runs after the CSV data for a row is validated.
    }

    protected function beforeFill(): void
    {
        // Runs before the validated CSV data for a row is filled into a model instance.
    }

    protected function afterFill(): void
    {
        // Runs after the validated CSV data for a row is filled into a model instance.
    }

    protected function beforeSave(): void
    {
        // Runs before a record is saved to the database.
    }

    protected function beforeCreate(): void
    {
        // Similar to `beforeSave()`, but only runs when creating a new record.
    }

    protected function beforeUpdate(): void
    {
        // Similar to `beforeSave()`, but only runs when updating an existing record.
    }

    protected function afterSave(): void
    {
        // Runs after a record is saved to the database.
    }
    
    protected function afterCreate(): void
    {
        // Similar to `afterSave()`, but only runs when creating a new record.
    }
    
    protected function afterUpdate(): void
    {
        // Similar to `afterSave()`, but only runs when updating an existing record.
    }
}
```

Inside these hooks, you can access the current row's data using `$this->data`. You can also access the original row of data from the CSV, before it was [cast](#casting-state) or mapped, using `$this->originalData`.

The current record (if it exists yet) is accessible in `$this->record`, and the [import form options](#using-import-options) using `$this->options`.

## Authorization

By default, only the user who started the import may access the failure CSV file that gets generated if part of an import fails. If you'd like to customize the authorization logic, you may create an `ImportPolicy` class, and [register it in your `AuthServiceProvider`](https://laravel.com/docs/authorization#registering-policies):

```php
use App\Policies\ImportPolicy;
use Filament\Actions\Imports\Models\Import;

protected $policies = [
    Import::class => ImportPolicy::class,
];
```

The `view()` method of the policy will be used to authorize access to the failure CSV file.

Please note that if you define a policy, the existing logic of ensuring only the user who started the import can access the failure CSV file will be removed. You will need to add that logic to your policy if you want to keep it:

```php
use App\Models\User;
use Filament\Actions\Imports\Models\Import;

public function view(User $user, Import $import): bool
{
    return $import->user()->is($user);
}
```

# Documentation for actions. File: 12-export.md
---
title: Export action
---
import Aside from "@components/Aside.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

Filament includes an action that is able to export rows to a CSV or XLSX file. When the trigger button is clicked, a modal asks for the columns that they want to export, and what they should be labeled. This feature uses [job batches](https://laravel.com/docs/queues#job-batching) and [database notifications](../../notifications/database-notifications), so you need to publish those migrations from Laravel. Also, you need to publish the migrations for tables that Filament uses to store information about exports:

```bash
php artisan make:queue-batches-table
php artisan make:notifications-table
php artisan vendor:publish --tag=filament-actions-migrations
php artisan migrate
```

<Aside variant="info">
    If you're using PostgreSQL, make sure that the `data` column in the notifications migration is using `json()`: `$table->json('data')`.
</Aside>

<Aside variant="info">
    If you're using UUIDs for your `User` model, make sure that your `notifiable` column in the notifications migration is using `uuidMorphs()`: `$table->uuidMorphs('notifiable')`.
</Aside>

You may use the `ExportAction` like so:

```php
use App\Filament\Exports\ProductExporter;
use Filament\Actions\ExportAction;

ExportAction::make()
    ->exporter(ProductExporter::class)
```

If you want to add this action to the header of a table, you may do so like this:

```php
use App\Filament\Exports\ProductExporter;
use Filament\Actions\ExportAction;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->headerActions([
            ExportAction::make()
                ->exporter(ProductExporter::class),
        ]);
}
```

Or if you want to add it as a table bulk action, so that the user can choose which rows to export, they can use `Filament\Actions\ExportBulkAction`:

```php
use App\Filament\Exports\ProductExporter;
use Filament\Actions\ExportBulkAction;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->toolbarActions([
            ExportBulkAction::make()
                ->exporter(ProductExporter::class),
        ]);
}
```

The ["exporter" class needs to be created](#creating-an-exporter) to tell Filament how to export each row.

## Creating an exporter

To create an exporter class for a model, you may use the `make:filament-exporter` command, passing the name of a model:

```bash
php artisan make:filament-exporter Product
```

This will create a new class in the `app/Filament/Exports` directory. You now need to define the [columns](#defining-exporter-columns) that can be exported.

### Automatically generating exporter columns

If you'd like to save time, Filament can automatically generate the [columns](#defining-exporter-columns) for you, based on your model's database columns, using `--generate`:

```bash
php artisan make:filament-exporter Product --generate
```

## Defining exporter columns

To define the columns that can be exported, you need to override the `getColumns()` method on your exporter class, returning an array of `ExportColumn` objects:

```php
use Filament\Actions\Exports\ExportColumn;

public static function getColumns(): array
{
    return [
        ExportColumn::make('name'),
        ExportColumn::make('sku')
            ->label('SKU'),
        ExportColumn::make('price'),
    ];
}
```

### Customizing the label of an export column

The label for each column will be generated automatically from its name, but you can override it by calling the `label()` method:

```php
use Filament\Actions\Exports\ExportColumn;

ExportColumn::make('sku')
    ->label('SKU')
```

### Configuring the default column selection

By default, all columns will be selected when the user is asked which columns they would like to export. You can customize the default selection state for a column with the `enabledByDefault()` method:

```php
use Filament\Actions\Exports\ExportColumn;

ExportColumn::make('description')
    ->enabledByDefault(false)
```

### Configuring the column selection form layout

By default, the column selection form uses a single column layout. You can change this using the `columnMappingColumns()` method, passing the number of columns you would like to use for the layout on large screens:

```php
use App\Filament\Exports\ProductExporter;
use Filament\Actions\ExportAction;

ExportAction::make()
    ->exporter(ProductExporter::class)
    ->columnMappingColumns(3)
```

This will display the column selection checkboxes and label inputs in a 3-column layout, making better use of available space when you have many exportable columns. Note that while there will be three columns in the layout on large screens, the layout will still be responsive and there will be fewer columns displayed on smaller screens.

### Disabling column selection

By default, user will be asked which columns they would like to export. You can disable this functionality using `columnMapping(false)`:

```php
use App\Filament\Exports\ProductExporter;
use Filament\Actions\ExportAction;

ExportAction::make()
    ->exporter(ProductExporter::class)
    ->columnMapping(false)
```

### Calculated export column state

Sometimes you need to calculate the state of a column, instead of directly reading it from a database column.

By passing a callback function to the `state()` method, you can customize the returned state for that column based on the `$record`:

```php
use App\Models\Order;
use Filament\Actions\Exports\ExportColumn;

ExportColumn::make('amount_including_vat')
    ->state(function (Order $record): float {
        return $record->amount * (1 + $record->vat_rate);
    })
```

<UtilityInjection set="exportColumns" version="4.x">As well as `$record`, the `state()` function can inject various utilities as parameters.</UtilityInjection>

### Formatting the value of an export column

You may instead pass a custom formatting callback to `formatStateUsing()`, which accepts the `$state` of the cell, and optionally the Eloquent `$record`:

```php
use Filament\Actions\Exports\ExportColumn;

ExportColumn::make('status')
    ->formatStateUsing(fn (string $state): string => __("statuses.{$state}"))
```

<UtilityInjection set="exportColumns" version="4.x" extras="State;;mixed;;$state;;The state to format.">As well as `$state`, the `formatStateUsing()` function can inject various utilities as parameters.</UtilityInjection>

If there are [multiple values](#exporting-multiple-values-in-a-cell) in the column, the function will be called for each value.

#### Limiting text length

You may `limit()` the length of the cell's value:

```php
use Filament\Actions\Exports\ExportColumn;

ExportColumn::make('description')
    ->limit(50)
```

<UtilityInjection set="exportColumns" version="4.x">As well as allowing a static value, the `limit()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

#### Limiting word count

You may limit the number of `words()` displayed in the cell:

```php
use Filament\Actions\Exports\ExportColumn;

ExportColumn::make('description')
    ->words(10)
```

<UtilityInjection set="exportColumns" version="4.x">As well as allowing a static value, the `words()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

#### Adding a prefix or suffix

You may add a `prefix()` or `suffix()` to the cell's value:

```php
use Filament\Actions\Exports\ExportColumn;

ExportColumn::make('domain')
    ->prefix('https://')
    ->suffix('.com')
```

<UtilityInjection set="exportColumns" version="4.x">As well as allowing static values, the `prefix()` and `suffix()` methods also accept functions to dynamically calculate them. You can inject various utilities into the functions as parameters.</UtilityInjection>

### Exporting multiple values in a cell

By default, if there are multiple values in the column, they will be comma-separated. You may use the `listAsJson()` method to list them as a JSON array instead:

```php
use Filament\Actions\Exports\ExportColumn;

ExportColumn::make('tags')
    ->listAsJson()
```

### Displaying data from relationships

You may use "dot notation" to access columns within relationships. The name of the relationship comes first, followed by a period, followed by the name of the column to display:

```php
use Filament\Actions\Exports\ExportColumn;

ExportColumn::make('author.name')
```

### Counting relationships

If you wish to count the number of related records in a column, you may use the `counts()` method:

```php
use Filament\Actions\Exports\ExportColumn;

ExportColumn::make('users_count')
    ->counts('users')
```

In this example, `users` is the name of the relationship to count from. The name of the column must be `users_count`, as this is the convention that [Laravel uses](https://laravel.com/docs/eloquent-relationships#counting-related-models) for storing the result.

If you'd like to scope the relationship before counting, you can pass an array to the method, where the key is the relationship name and the value is the function to scope the Eloquent query with:

```php
use Filament\Actions\Exports\ExportColumn;
use Illuminate\Database\Eloquent\Builder;

ExportColumn::make('users_count')
    ->counts([
        'users' => fn (Builder $query) => $query->where('is_active', true),
    ])
```

### Determining relationship existence

If you simply wish to indicate whether related records exist in a column, you may use the `exists()` method:

```php
use Filament\Actions\Exports\ExportColumn;

ExportColumn::make('users_exists')
    ->exists('users')
```

In this example, `users` is the name of the relationship to check for existence. The name of the column must be `users_exists`, as this is the convention that [Laravel uses](https://laravel.com/docs/eloquent-relationships#other-aggregate-functions) for storing the result.

If you'd like to scope the relationship before checking existance, you can pass an array to the method, where the key is the relationship name and the value is the function to scope the Eloquent query with:

```php
use Filament\Actions\Exports\ExportColumn;
use Illuminate\Database\Eloquent\Builder;

ExportColumn::make('users_exists')
    ->exists([
        'users' => fn (Builder $query) => $query->where('is_active', true),
    ])
```

### Aggregating relationships

Filament provides several methods for aggregating a relationship field, including `avg()`, `max()`, `min()` and `sum()`. For instance, if you wish to show the average of a field on all related records in a column, you may use the `avg()` method:

```php
use Filament\Actions\Exports\ExportColumn;

ExportColumn::make('users_avg_age')
    ->avg('users', 'age')
```

In this example, `users` is the name of the relationship, while `age` is the field that is being averaged. The name of the column must be `users_avg_age`, as this is the convention that [Laravel uses](https://laravel.com/docs/eloquent-relationships#other-aggregate-functions) for storing the result.

If you'd like to scope the relationship before aggregating, you can pass an array to the method, where the key is the relationship name and the value is the function to scope the Eloquent query with:

```php
use Filament\Actions\Exports\ExportColumn;
use Illuminate\Database\Eloquent\Builder;

ExportColumn::make('users_avg_age')
    ->avg([
        'users' => fn (Builder $query) => $query->where('is_active', true),
    ], 'age')
```

## Configuring the export formats

By default, the export action will allow the user to choose between both CSV and XLSX formats. You can use the `ExportFormat` enum to customize this, by passing an array of formats to the `formats()` method on the action:

```php
use App\Filament\Exports\ProductExporter;
use Filament\Actions\ExportAction;
use Filament\Actions\Exports\Enums\ExportFormat;

ExportAction::make()
    ->exporter(ProductExporter::class)
    ->formats([
        ExportFormat::Csv,
    ])
    // or
    ->formats([
        ExportFormat::Xlsx,
    ])
    // or
    ->formats([
        ExportFormat::Xlsx,
        ExportFormat::Csv,
    ])
```

Alternatively, you can override the `getFormats()` method on the exporter class, which will set the default formats for all actions that use that exporter:

```php
use Filament\Actions\Exports\Enums\ExportFormat;

public function getFormats(): array
{
    return [
        ExportFormat::Csv,
    ];
}
```

## Modifying the export query

By default, if you are using the `ExportAction` with a table, the action will use the table's currently filtered and sorted query to export the data. If you don't have a table, it will use the model's default query. To modify the query builder before exporting, you can use the `modifyQueryUsing()` method on the action:

```php
use App\Filament\Exports\ProductExporter;
use Filament\Actions\ExportAction;
use Illuminate\Database\Eloquent\Builder;

ExportAction::make()
    ->exporter(ProductExporter::class)
    ->modifyQueryUsing(fn (Builder $query) => $query->where('is_active', true))
```

You may inject the `$options` argument into the function, which is an array of [options](#using-export-options) for that export:

```php
use App\Filament\Exports\ProductExporter;
use Illuminate\Database\Eloquent\Builder;

ExportAction::make()
    ->exporter(ProductExporter::class)
    ->modifyQueryUsing(fn (Builder $query, array $options) => $query->where('is_active', $options['isActive'] ?? true))
```

Alternatively, you can override the `modifyQuery()` method on the exporter class, which will modify the query for all actions that use that exporter:

```php
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Relations\MorphTo;

public static function modifyQuery(Builder $query): Builder
{
    return $query->with([
        'purchasable' => fn (MorphTo $morphTo) => $morphTo->morphWith([
            ProductPurchase::class => ['product'],
            ServicePurchase::class => ['service'],
            Subscription::class => ['plan'],
        ]),
    ]);
}
```

## Configuring the export filesystem

### Customizing the storage disk

By default, exported files will be uploaded to the storage disk defined in the [configuration file](../../installation#publishing-configuration), which is `public` by default. You can set the `FILAMENT_FILESYSTEM_DISK` environment variable to change this.

While using the `public` disk a good default for many parts of Filament, using it for exports would result in exported files being stored in a public location. As such, if the default filesystem disk is `public` and a `local` disk exists in your `config/filesystems.php`, Filament will use the `local` disk for exports instead. If you override the disk to be `public` for an `ExportAction` or inside an exporter class, Filament will use that.

In production, you should use a disk such as `s3` with a private access policy, to prevent unauthorized access to the exported files.

If you want to use a different disk for a specific export, you can pass the disk name to the `disk()` method on the action:

```php
use Filament\Actions\ExportAction;

ExportAction::make()
    ->exporter(ProductExporter::class)
    ->fileDisk('s3')
```

You may set the disk for all export actions at once in the `boot()` method of a service provider such as `AppServiceProvider`:

```php
use Filament\Actions\ExportAction;

ExportAction::configureUsing(fn (ExportAction $action) => $action->fileDisk('s3'));
```

Alternatively, you can override the `getFileDisk()` method on the exporter class, returning the name of the disk:

```php
public function getFileDisk(): string
{
    return 's3';
}
```

Export files that are created are the developer's responsibility to delete if they wish. Filament does not delete these files in case the exports need to be downloaded again at a later date.

### Configuring the export file names

By default, exported files will have a name generated based on the ID and type of the export. You can also use the `fileName()` method on the action to customize the file name:

```php
use Filament\Actions\ExportAction;
use Filament\Actions\Exports\Models\Export;

ExportAction::make()
    ->exporter(ProductExporter::class)
    ->fileName(fn (Export $export): string => "products-{$export->getKey()}.csv")
```

Alternatively, you can override the `getFileName()` method on the exporter class, returning a string:

```php
use Filament\Actions\Exports\Models\Export;

public function getFileName(Export $export): string
{
    return "products-{$export->getKey()}.csv";
}
```

## Using export options

The export action can render extra form components that the user can interact with when exporting a CSV. This can be useful to allow the user to customize the behavior of the exporter. For instance, you might want a user to be able to choose the format of specific columns when exporting. To do this, you can return options form components from the `getOptionsFormComponents()` method on your exporter class:

```php
use Filament\Forms\Components\TextInput;

public static function getOptionsFormComponents(): array
{
    return [
        TextInput::make('descriptionLimit')
            ->label('Limit the length of the description column content')
            ->integer(),
    ];
}
```

Alternatively, you can pass a set of static options to the exporter through the `options()` method on the action:

```php
use App\Filament\Exports\ProductExporter;
use Filament\Actions\ExportAction;

ExportAction::make()
    ->exporter(ProductExporter::class)
    ->options([
        'descriptionLimit' => 250,
    ])
```

<UtilityInjection set="actions" version="4.x">As well as allowing a static value, the `options()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

Now, you can access the data from these options inside the exporter class, by injecting the `$options` argument into any closure function. For example, you might want to use it inside `formatStateUsing()` to [format a column's value](#formatting-the-value-of-an-export-column):

```php
use Filament\Actions\Exports\ExportColumn;

ExportColumn::make('description')
    ->formatStateUsing(function (string $state, array $options): string {
        return (string) str($state)->limit($options['descriptionLimit'] ?? 100);
    })
```

Alternatively, since the `$options` argument is passed to all closure functions, you can access it inside `limit()`:

```php
use Filament\Actions\Exports\ExportColumn;

ExportColumn::make('description')
    ->limit(fn (array $options): int => $options['descriptionLimit'] ?? 100)
```

## Using a custom user model

By default, the `exports` table has a `user_id` column. That column is constrained to the `users` table:

```php
$table->foreignId('user_id')->constrained()->cascadeOnDelete();
```

In the `Export` model, the `user()` relationship is defined as a `BelongsTo` relationship to the `App\Models\User` model. If the `App\Models\User` model does not exist, or you want to use a different one, you can bind a new `Authenticatable` model to the container in a service provider's `register()` method:

```php
use App\Models\Admin;
use Illuminate\Contracts\Auth\Authenticatable;

$this->app->bind(Authenticatable::class, Admin::class);
```

If your authenticatable model uses a different table to `users`, you should pass that table name to `constrained()`:

```php
$table->foreignId('user_id')->constrained('admins')->cascadeOnDelete();
```

### Using a polymorphic user relationship

If you want to associate exports with multiple user models, you can use a polymorphic `MorphTo` relationship instead. To do this, you need to replace the `user_id` column in the `exports` table:

```php
$table->morphs('user');
```

Then, in a service provider's `boot()` method, you should call `Export::polymorphicUserRelationship()` to swap the `user()` relationship on the `Export` model to a `MorphTo` relationship:

```php
use Filament\Actions\Exports\Models\Export;

Export::polymorphicUserRelationship();
```

## Limiting the maximum number of rows that can be exported

To prevent server overload, you may wish to limit the maximum number of rows that can be exported from one CSV file. You can do this by calling the `maxRows()` method on the action:

```php
use App\Filament\Exports\ProductExporter;
use Filament\Actions\ExportAction;

ExportAction::make()
    ->exporter(ProductExporter::class)
    ->maxRows(100000)
```

## Changing the export chunk size

Filament will chunk the CSV, and process each chunk in a different queued job. By default, chunks are 100 rows at a time. You can change this by calling the `chunkSize()` method on the action:

```php
use App\Filament\Exports\ProductExporter;
use Filament\Actions\ExportAction;

ExportAction::make()
    ->exporter(ProductExporter::class)
    ->chunkSize(250)
```

<UtilityInjection set="actions" version="4.x">As well as allowing a static value, the `chunkSize()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<Aside variant="tip">
    If you are encountering memory or timeout issues when importing large CSV files, you may wish to reduce the chunk size.
</Aside>

## Changing the CSV delimiter

The default delimiter for CSVs is the comma (`,`). If you want to export using a different delimiter, you may override the `getCsvDelimiter()` method on the exporter class, returning a new one:

```php
public static function getCsvDelimiter(): string
{
    return ';';
}
```

<UtilityInjection set="actions" version="4.x">As well as allowing a static value, the `csvDelimiter()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

You can only specify a single character, otherwise an exception will be thrown.

## Customizing XLSX files

### Styling XLSX rows

If you want to style the cells of the XLSX file, you may override the `getXlsxCellStyle()` method on the exporter class, returning an [OpenSpout `Style` object](https://github.com/openspout/openspout/blob/4.x/docs/documentation.md#styling):

```php
use OpenSpout\Common\Entity\Style\Style;

public function getXlsxCellStyle(): ?Style
{
    return (new Style())
        ->setFontSize(12)
        ->setFontName('Consolas');
}
```

If you want to use a different style for the header cells of the XLSX file only, you may override the `getXlsxHeaderCellStyle()` method on the exporter class, returning an [OpenSpout `Style` object](https://github.com/openspout/openspout/blob/4.x/docs/documentation.md#styling):

```php
use OpenSpout\Common\Entity\Style\CellAlignment;
use OpenSpout\Common\Entity\Style\CellVerticalAlignment;
use OpenSpout\Common\Entity\Style\Color;
use OpenSpout\Common\Entity\Style\Style;

public function getXlsxHeaderCellStyle(): ?Style
{
    return (new Style())
        ->setFontBold()
        ->setFontItalic()
        ->setFontSize(14)
        ->setFontName('Consolas')
        ->setFontColor(Color::rgb(255, 255, 77))
        ->setBackgroundColor(Color::rgb(0, 0, 0))
        ->setCellAlignment(CellAlignment::CENTER)
        ->setCellVerticalAlignment(CellVerticalAlignment::CENTER);
}
```

### Styling XLSX columns

The `makeXlsxRow()` and `makeXlsxHeaderRow()` methods on the exporter class allow you to customize the styling of individual cells within a row. By default, the methods are implemented like this:

```php
use OpenSpout\Common\Entity\Row;
use OpenSpout\Common\Entity\Style\Style;

/**
 * @param array<mixed> $values
 */
public function makeXlsxRow(array $values, ?Style $style = null): Row
{
    return Row::fromValues($values, $style);
}
```

When a user exports, they can choose which columns to export. As such, the `$this->columnMap` property may be used to determine which columns are being exported and in which order. You can replace `Row::fromValues()` with an array of `Cell` objects, which allow you to style them individually using [OpenSpout `Style` objects](https://github.com/openspout/openspout/blob/4.x/docs/documentation.md#styling). A `StyleMerger` can be used to merge the default style with the custom style for a cell, allowing you to apply additional styles on top of the default ones:

```php
use OpenSpout\Common\Entity\Cell;
use OpenSpout\Common\Entity\Row;
use OpenSpout\Common\Entity\Style\Style;
use OpenSpout\Writer\Common\Manager\Style\StyleMerger;

/**
 * @param array<mixed> $values
 */
public function makeXlsxRow(array $values, ?Style $style = null): Row
{
    $styleMerger = new StyleMerger();

    $cells = [];
    
    foreach (array_keys($this->columnMap) as $columnIndex => $column) {
        $cells[] = match ($column) {
            'name' => Cell::fromValue(
                $values[$columnIndex],
                $styleMerger->merge(
                    (new Style())->setFontUnderline(),
                    $style,
                ),
            ),
            'price' => Cell::fromValue(
                $values[$columnIndex],
                (new Style())->setFontSize(12),
            ),
            default => Cell::fromValue($values[$columnIndex]),
        },
    }
    
    return new Row($cells, $style);
}
```

### Customizing the XLSX writer

If you want to pass "options" to the [OpenSpout XLSX `Writer`](https://github.com/openspout/openspout/blob/4.x/docs/documentation.md#column-widths), you can return an `OpenSpout\Writer\XLSX\Options` instance from the `getXlsxWriterOptions()` method of the exporter class:

```php
use OpenSpout\Writer\XLSX\Options;

public function getXlsxWriterOptions(): ?Options
{
    $options = new Options();
    $options->setColumnWidth(10, 1);
    $options->setColumnWidthForRange(12, 2, 3);
    
    return $options;
}
```

If you want to customize the XLSX writer before it is closed, you can override the `configureXlsxWriterBeforeClosing()` method on the exporter class. This method receives the `Writer` instance as a parameter, and you can modify it before it is closed:

```php
use OpenSpout\Writer\XLSX\Entity\SheetView;
use OpenSpout\Writer\XLSX\Writer;

public function configureXlsxWriterBeforeClose(Writer $writer): Writer
{
    $sheetView = new SheetView();
    $sheetView->setFreezeRow(2);
    $sheetView->setFreezeColumn('B');
    
    $sheet = $writer->getCurrentSheet();
    $sheet->setSheetView($sheetView);
    $sheet->setName('export');
    
    return $writer;
}
```

## Customizing the export job

The default job for processing exports is `Filament\Actions\Exports\Jobs\PrepareCsvExport`. If you want to extend this class and override any of its methods, you may replace the original class in the `register()` method of a service provider:

```php
use App\Jobs\PrepareCsvExport;
use Filament\Actions\Exports\Jobs\PrepareCsvExport as BasePrepareCsvExport;

$this->app->bind(BasePrepareCsvExport::class, PrepareCsvExport::class);
```

Or, you can pass the new job class to the `job()` method on the action, to customize the job for a specific export:

```php
use App\Filament\Exports\ProductExporter;
use App\Jobs\PrepareCsvExport;
use Filament\Actions\ExportAction;

ExportAction::make()
    ->exporter(ProductExporter::class)
    ->job(PrepareCsvExport::class)
```

### Customizing the export queue and connection

By default, the export system will use the default queue and connection. If you'd like to customize the queue used for jobs of a certain exporter, you may override the `getJobQueue()` method in your exporter class:

```php
public function getJobQueue(): ?string
{
    return 'exports';
}
```

You can also customize the connection used for jobs of a certain exporter, by overriding the `getJobConnection()` method in your exporter class:

```php
public function getJobConnection(): ?string
{
    return 'sqs';
}
```

### Customizing the export job middleware

By default, the export system will only process one job at a time from each export. This is to prevent the server from being overloaded, and other jobs from being delayed by large exports. That functionality is defined in the `WithoutOverlapping` middleware on the exporter class:

```php
public function getJobMiddleware(): array
{
    return [
        (new WithoutOverlapping("export{$this->export->getKey()}"))->expireAfter(600),
    ];
}
```

If you'd like to customize the middleware that is applied to jobs of a certain exporter, you may override this method in your exporter class. You can read more about job middleware in the [Laravel docs](https://laravel.com/docs/queues#job-middleware).

### Customizing the export job retries

By default, the export system will retry a job for 24 hours, or until it fails with 5 unhandled exceptions, whichever happens first. This is to allow for temporary issues, such as the database being unavailable, to be resolved. You may change the time period for the job to retry, which is defined in the `getJobRetryUntil()` method on the exporter class:

```php
use Carbon\CarbonInterface;

public function getJobRetryUntil(): ?CarbonInterface
{
    return now()->addHours(12);
}
```

You can read more about job retries in the [Laravel docs](https://laravel.com/docs/queues#max-job-attempts-and-timeout).

#### Customizing the export job backoff strategy

By default, the export system will wait 1 minute, then 2 minutes, then 5 minutes, then 10 minutes thereafter before retrying a job. This is to prevent the server from being overloaded by a job that is failing repeatedly. That functionality is defined in the `getJobBackoff()` method on the exporter class:

```php
/**
* @return int | array<int> | null
 */
public function getJobBackoff(): int | array | null
{
    return [60, 120, 300, 600];
}
```

You can read more about job backoff, including how to configure exponential backoffs, in the [Laravel docs](https://laravel.com/docs/queues#dealing-with-failed-jobs).

### Customizing the export job tags

By default, the export system will tag each job with the ID of the export. This is to allow you to easily find all jobs related to a certain export. That functionality is defined in the `getJobTags()` method on the exporter class:

```php
public function getJobTags(): array
{
    return ["export{$this->export->getKey()}"];
}
```

If you'd like to customize the tags that are applied to jobs of a certain exporter, you may override this method in your exporter class.

### Customizing the export job batch name

By default, the export system doesn't define any name for the job batches. If you'd like to customize the name that is applied to job batches of a certain exporter, you may override the `getJobBatchName()` method in your exporter class:

```php
public function getJobBatchName(): ?string
{
    return 'product-export';
}
```

## Authorization

By default, only the user who started the export may download files that get generated. If you'd like to customize the authorization logic, you may create an `ExportPolicy` class, and [register it in your `AuthServiceProvider`](https://laravel.com/docs/authorization#registering-policies):

```php
use App\Policies\ExportPolicy;
use Filament\Actions\Exports\Models\Export;

protected $policies = [
    Export::class => ExportPolicy::class,
];
```

The `view()` method of the policy will be used to authorize access to the downloads.

Please note that if you define a policy, the existing logic of ensuring only the user who started the export can access it will be removed. You will need to add that logic to your policy if you want to keep it:

```php
use App\Models\User;
use Filament\Actions\Exports\Models\Export;

public function view(User $user, Export $export): bool
{
    return $export->user()->is($user);
}
```

