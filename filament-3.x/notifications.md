# Documentation for notifications. File: 01-installation.md
---
title: Installation
---

**The Notifications package is pre-installed with the [Panel Builder](/docs/panels).** This guide is for using the Notifications package in a custom TALL Stack application (Tailwind, Alpine, Livewire, Laravel).

## Requirements

Filament requires the following to run:

- PHP 8.1+
- Laravel v10.0+
- Livewire v3.0+
- Tailwind v3.0+ [(Using Tailwind v4?)](#installing-tailwind-css)

Require the Notifications package using Composer:

```bash
composer require filament/notifications:"^3.3" -W
```

## New Laravel projects

To quickly get started with Filament in a new Laravel project, run the following commands to install [Livewire](https://livewire.laravel.com), [Alpine.js](https://alpinejs.dev), and [Tailwind CSS](https://tailwindcss.com):

> Since these commands will overwrite existing files in your application, only run this in a new Laravel project!

```bash
php artisan filament:install --scaffold --notifications

npm install

npm run dev
```

## Existing Laravel projects

Run the following command to install the Notifications package assets:

```bash
php artisan filament:install --notifications
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

        @livewire('notifications')

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

# Documentation for notifications. File: 02-sending-notifications.md
---
title: Sending notifications
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Overview

> To start, make sure the package is [installed](installation) - `@livewire('notifications')` should be in your Blade layout somewhere.

Notifications are sent using a `Notification` object that's constructed through a fluent API. Calling the `send()` method on the `Notification` object will dispatch the notification and display it in your application. As the session is used to flash notifications, they can be sent from anywhere in your code, including JavaScript, not just Livewire components.

```php
<?php

namespace App\Livewire;

use Filament\Notifications\Notification;
use Livewire\Component;

class EditPost extends Component
{
    public function save(): void
    {
        // ...

        Notification::make()
            ->title('Saved successfully')
            ->success()
            ->send();
    }
}
```

<AutoScreenshot name="notifications/success" alt="Success notification" version="3.x" />

## Setting a title

The main message of the notification is shown in the title. You can set the title as follows:

```php
use Filament\Notifications\Notification;

Notification::make()
    ->title('Saved successfully')
    ->send();
```

The title text can contain basic, safe HTML elements. To generate safe HTML with Markdown, you can use the [`Str::markdown()` helper](https://laravel.com/docs/strings#method-str-markdown): `title(Str::markdown('Saved **successfully**'))`

Or with JavaScript:

```js
new FilamentNotification()
    .title('Saved successfully')
    .send()
```

## Setting an icon

Optionally, a notification can have an [icon](https://blade-ui-kit.com/blade-icons?set=1#search) that's displayed in front of its content. You may also set a color for the icon, which is gray by default:

```php
use Filament\Notifications\Notification;

Notification::make()
    ->title('Saved successfully')
    ->icon('heroicon-o-document-text')
    ->iconColor('success')
    ->send();
```

Or with JavaScript:

```js
new FilamentNotification()
    .title('Saved successfully')
    .icon('heroicon-o-document-text')
    .iconColor('success')
    .send()
```

<AutoScreenshot name="notifications/icon" alt="Notification with icon" version="3.x" />

Notifications often have a status like `success`, `warning`, `danger` or `info`. Instead of manually setting the corresponding icons and colors, there's a `status()` method which you can pass the status. You may also use the dedicated `success()`, `warning()`, `danger()` and `info()` methods instead. So, cleaning up the above example would look like this:

```php
use Filament\Notifications\Notification;

Notification::make()
    ->title('Saved successfully')
    ->success()
    ->send();
```

Or with JavaScript:

```js
new FilamentNotification()
    .title('Saved successfully')
    .success()
    .send()
```

<AutoScreenshot name="notifications/statuses" alt="Notifications with various statuses" version="3.x" />

## Setting a background color

Notifications have no background color by default. You may want to provide additional context to your notification by setting a color as follows:

```php
use Filament\Notifications\Notification;

Notification::make()
    ->title('Saved successfully')
    ->color('success')
    ->send();
```

Or with JavaScript:

```js
new FilamentNotification()
    .title('Saved successfully')
    .color('success')
    .send()
```

<AutoScreenshot name="notifications/color" alt="Notification with background color" version="3.x" />

## Setting a duration

By default, notifications are shown for 6 seconds before they're automatically closed. You may specify a custom duration value in milliseconds as follows:

```php
use Filament\Notifications\Notification;

Notification::make()
    ->title('Saved successfully')
    ->success()
    ->duration(5000)
    ->send();
```

Or with JavaScript:

```js
new FilamentNotification()
    .title('Saved successfully')
    .success()
    .duration(5000)
    .send()
```

If you prefer setting a duration in seconds instead of milliseconds, you can do so:

```php
use Filament\Notifications\Notification;

Notification::make()
    ->title('Saved successfully')
    ->success()
    ->seconds(5)
    ->send();
```

Or with JavaScript:

```js
new FilamentNotification()
    .title('Saved successfully')
    .success()
    .seconds(5)
    .send()
```

You might want some notifications to not automatically close and require the user to close them manually. This can be achieved by making the notification persistent:

```php
use Filament\Notifications\Notification;

Notification::make()
    ->title('Saved successfully')
    ->success()
    ->persistent()
    ->send();
```

Or with JavaScript:

```js
new FilamentNotification()
    .title('Saved successfully')
    .success()
    .persistent()
    .send()
```

## Setting body text

Additional notification text can be shown in the `body()`:

```php
use Filament\Notifications\Notification;

Notification::make()
    ->title('Saved successfully')
    ->success()
    ->body('Changes to the post have been saved.')
    ->send();
```

The body text can contain basic, safe HTML elements. To generate safe HTML with Markdown, you can use the [`Str::markdown()` helper](https://laravel.com/docs/strings#method-str-markdown): `body(Str::markdown('Changes to the **post** have been saved.'))`

Or with JavaScript:

```js
new FilamentNotification()
    .title('Saved successfully')
    .success()
    .body('Changes to the post have been saved.')
    .send()
```

<AutoScreenshot name="notifications/body" alt="Notification with body text" version="3.x" />

## Adding actions to notifications

Notifications support [Actions](../actions/trigger-button), which are buttons that render below the content of the notification. They can open a URL or dispatch a Livewire event. Actions can be defined as follows:

```php
use Filament\Notifications\Actions\Action;
use Filament\Notifications\Notification;

Notification::make()
    ->title('Saved successfully')
    ->success()
    ->body('Changes to the post have been saved.')
    ->actions([
        Action::make('view')
            ->button(),
        Action::make('undo')
            ->color('gray'),
    ])
    ->send();
```

Or with JavaScript:

```js
new FilamentNotification()
    .title('Saved successfully')
    .success()
    .body('Changes to the post have been saved.')
    .actions([
        new FilamentNotificationAction('view')
            .button(),
        new FilamentNotificationAction('undo')
            .color('gray'),
    ])
    .send()
```

<AutoScreenshot name="notifications/actions" alt="Notification with actions" version="3.x" />

You can learn more about how to style action buttons [here](../actions/trigger-button).

### Opening URLs from notification actions

You can open a URL, optionally in a new tab, when clicking on an action:

```php
use Filament\Notifications\Actions\Action;
use Filament\Notifications\Notification;

Notification::make()
    ->title('Saved successfully')
    ->success()
    ->body('Changes to the post have been saved.')
    ->actions([
        Action::make('view')
            ->button()
            ->url(route('posts.show', $post), shouldOpenInNewTab: true),
        Action::make('undo')
            ->color('gray'),
    ])
    ->send();
```

Or with JavaScript:

```js
new FilamentNotification()
    .title('Saved successfully')
    .success()
    .body('Changes to the post have been saved.')
    .actions([
        new FilamentNotificationAction('view')
            .button()
            .url('/view')
            .openUrlInNewTab(),
        new FilamentNotificationAction('undo')
            .color('gray'),
    ])
    .send()
```

### Dispatching Livewire events from notification actions

Sometimes you want to execute additional code when a notification action is clicked. This can be achieved by setting a Livewire event which should be dispatched on clicking the action. You may optionally pass an array of data, which will be available as parameters in the event listener on your Livewire component:

```php
use Filament\Notifications\Actions\Action;
use Filament\Notifications\Notification;

Notification::make()
    ->title('Saved successfully')
    ->success()
    ->body('Changes to the post have been saved.')
    ->actions([
        Action::make('view')
            ->button()
            ->url(route('posts.show', $post), shouldOpenInNewTab: true),
        Action::make('undo')
            ->color('gray')
            ->dispatch('undoEditingPost', [$post->id]),
    ])
    ->send();
```

You can also `dispatchSelf` and `dispatchTo`:

```php
Action::make('undo')
    ->color('gray')
    ->dispatchSelf('undoEditingPost', [$post->id])

Action::make('undo')
    ->color('gray')
    ->dispatchTo('another_component', 'undoEditingPost', [$post->id])
```

Or with JavaScript:

```js
new FilamentNotification()
    .title('Saved successfully')
    .success()
    .body('Changes to the post have been saved.')
    .actions([
        new FilamentNotificationAction('view')
            .button()
            .url('/view')
            .openUrlInNewTab(),
        new FilamentNotificationAction('undo')
            .color('gray')
            .dispatch('undoEditingPost'),
    ])
    .send()
```

Similarly, `dispatchSelf` and `dispatchTo` are also available:

```js
new FilamentNotificationAction('undo')
    .color('gray')
    .dispatchSelf('undoEditingPost')

new FilamentNotificationAction('undo')
    .color('gray')
    .dispatchTo('another_component', 'undoEditingPost')
```

### Closing notifications from actions

After opening a URL or dispatching an event from your action, you may want to close the notification right away:

```php
use Filament\Notifications\Actions\Action;
use Filament\Notifications\Notification;

Notification::make()
    ->title('Saved successfully')
    ->success()
    ->body('Changes to the post have been saved.')
    ->actions([
        Action::make('view')
            ->button()
            ->url(route('posts.show', $post), shouldOpenInNewTab: true),
        Action::make('undo')
            ->color('gray')
            ->dispatch('undoEditingPost', [$post->id])
            ->close(),
    ])
    ->send();
```

Or with JavaScript:

```js
new FilamentNotification()
    .title('Saved successfully')
    .success()
    .body('Changes to the post have been saved.')
    .actions([
        new FilamentNotificationAction('view')
            .button()
            .url('/view')
            .openUrlInNewTab(),
        new FilamentNotificationAction('undo')
            .color('gray')
            .dispatch('undoEditingPost')
            .close(),
    ])
    .send()
```

## Using the JavaScript objects

The JavaScript objects (`FilamentNotification` and `FilamentNotificationAction`) are assigned to `window.FilamentNotification` and `window.FilamentNotificationAction`, so they are available in on-page scripts.

You may also import them in a bundled JavaScript file:

```js
import { Notification, NotificationAction } from '../../vendor/filament/notifications/dist/index.js'

// ...
```

## Closing a notification with JavaScript

Once a notification has been sent, you can close it on demand by dispatching a browser event on the window called `close-notification`.

The event needs to contain the ID of the notification you sent. To get the ID, you can use the `getId()` method on the `Notification` object:

```php
use Filament\Notifications\Notification;

$notification = Notification::make()
    ->title('Hello')
    ->persistent()
    ->send()

$notificationId = $notification->getId()
```

To close the notification, you can dispatch the event from Livewire:

```php
$this->dispatch('close-notification', id: $notificationId);
```

Or from JavaScript, in this case Alpine.js:

```blade
<button x-on:click="$dispatch('close-notification', { id: notificationId })" type="button">
    Close Notification
</button>
```

If you are able to retrieve the notification ID, persist it, and then use it to close the notification, that is the recommended approach, as IDs are generated uniquely, and you will not risk closing the wrong notification. However, if it is not possible to persist the random ID, you can pass in a custom ID when sending the notification:

```php
use Filament\Notifications\Notification;

Notification::make('greeting')
    ->title('Hello')
    ->persistent()
    ->send()
```

In this case, you can close the notification by dispatching the event with the custom ID:

```blade
<button x-on:click="$dispatch('close-notification', { id: 'greeting' })" type="button">
    Close Notification
</button>
```

Please be aware that if you send multiple notifications with the same ID, you may experience unexpected side effects, so random IDs are recommended.

# Documentation for notifications. File: 03-database-notifications.md
---
title: Database notifications
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

<AutoScreenshot name="notifications/database" alt="Database notifications" version="3.x" />

## Setting up the notifications database table

Before we start, make sure that the [Laravel notifications table](https://laravel.com/docs/notifications#database-prerequisites) is added to your database:

```bash
# Laravel 11 and higher
php artisan make:notifications-table

# Laravel 10
php artisan notifications:table
```

> If you're using PostgreSQL, make sure that the `data` column in the migration is using `json()`: `$table->json('data')`.

> If you're using UUIDs for your `User` model, make sure that your `notifiable` column is using `uuidMorphs()`: `$table->uuidMorphs('notifiable')`.

## Rendering the database notifications modal

> If you want to add database notifications to a panel, [follow this part of the guide](#adding-the-database-notifications-modal-to-a-panel).

If you'd like to render the database notifications modal outside of the [Panel Builder](../panels), you'll need to add a new Livewire component to your Blade layout:

```blade
@livewire('database-notifications')
```

To open the modal, you must have a "trigger" button in your view. Create a new trigger button component in your app, for instance at `/resources/views/filament/notifications/database-notifications-trigger.blade.php`:

```blade
<button type="button">
    Notifications ({{ $unreadNotificationsCount }} unread)
</button>
```

`$unreadNotificationsCount` is a variable automatically passed to this view, which provides it with a real-time count of unread notifications the user has.

In the service provider, point to this new trigger view:

```php
use Filament\Notifications\Livewire\DatabaseNotifications;

DatabaseNotifications::trigger('filament.notifications.database-notifications-trigger');
```

Now, click on the trigger button that is rendered in your view. A modal should appear containing your database notifications when clicked!

### Adding the database notifications modal to a panel

You can enable database notifications in a panel's [configuration](../panels/configuration):

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->databaseNotifications();
}
```

To learn more, visit the [Panel Builder documentation](../panels/notifications).

## Sending database notifications

There are several ways to send database notifications, depending on which one suits you best.

You may use our fluent API:

```php
use Filament\Notifications\Notification;

$recipient = auth()->user();

Notification::make()
    ->title('Saved successfully')
    ->sendToDatabase($recipient);
```

Or, use the `notify()` method:

```php
use Filament\Notifications\Notification;

$recipient = auth()->user();

$recipient->notify(
    Notification::make()
        ->title('Saved successfully')
        ->toDatabase(),
);
```

> Laravel sends database notifications using the queue. Ensure your queue is running in order to receive the notifications.

Alternatively, use a traditional [Laravel notification class](https://laravel.com/docs/notifications#generating-notifications) by returning the notification from the `toDatabase()` method:

```php
use App\Models\User;
use Filament\Notifications\Notification;

public function toDatabase(User $notifiable): array
{
    return Notification::make()
        ->title('Saved successfully')
        ->getDatabaseMessage();
}
```

## Receiving database notifications

Without any setup, new database notifications will only be received when the page is first loaded.

### Polling for new database notifications

Polling is the practice of periodically making a request to the server to check for new notifications. This is a good approach as the setup is simple, but some may say that it is not a scalable solution as it increases server load.

By default, Livewire polls for new notifications every 30 seconds:

```php
use Filament\Notifications\Livewire\DatabaseNotifications;

DatabaseNotifications::pollingInterval('30s');
```

You may completely disable polling if you wish:

```php
use Filament\Notifications\Livewire\DatabaseNotifications;

DatabaseNotifications::pollingInterval(null);
```

### Using Echo to receive new database notifications with websockets

Alternatively, the package has a native integration with [Laravel Echo](https://laravel.com/docs/broadcasting#client-side-installation). Make sure Echo is installed, as well as a [server-side websockets integration](https://laravel.com/docs/broadcasting#server-side-installation) like Pusher.

Once websockets are set up, you can automatically dispatch a `DatabaseNotificationsSent` event by setting the `isEventDispatched` parameter to `true` when sending the notification. This will trigger the immediate fetching of new notifications for the user:

```php
use Filament\Notifications\Notification;

$recipient = auth()->user();

Notification::make()
    ->title('Saved successfully')
    ->sendToDatabase($recipient, isEventDispatched: true);
```

## Marking database notifications as read

There is a button at the top of the modal to mark all notifications as read at once. You may also add [Actions](sending-notifications#adding-actions-to-notifications) to notifications, which you can use to mark individual notifications as read. To do this, use the `markAsRead()` method on the action:

```php
use Filament\Notifications\Actions\Action;
use Filament\Notifications\Notification;

Notification::make()
    ->title('Saved successfully')
    ->success()
    ->body('Changes to the post have been saved.')
    ->actions([
        Action::make('view')
            ->button()
            ->markAsRead(),
    ])
    ->send();
```

Alternatively, you may use the `markAsUnread()` method to mark a notification as unread:

```php
use Filament\Notifications\Actions\Action;
use Filament\Notifications\Notification;

Notification::make()
    ->title('Saved successfully')
    ->success()
    ->body('Changes to the post have been saved.')
    ->actions([
        Action::make('markAsUnread')
            ->button()
            ->markAsUnread(),
    ])
    ->send();
```

## Opening the database notifications modal

Instead of rendering the trigger button as described above, you can always open the database notifications modal from anywhere by dispatching an `open-modal` browser event:

```blade
<button
    x-data="{}"
    x-on:click="$dispatch('open-modal', { id: 'database-notifications' })"
    type="button"
>
    Notifications
</button>
```

# Documentation for notifications. File: 04-broadcast-notifications.md
---
title: Broadcast notifications
---

## Overview

> To start, make sure the package is [installed](installation) - `@livewire('notifications')` should be in your Blade layout somewhere.

By default, Filament will send flash notifications via the Laravel session. However, you may wish that your notifications are "broadcast" to a user in real-time, instead. This could be used to send a temporary success notification from a queued job after it has finished processing.

We have a native integration with [Laravel Echo](https://laravel.com/docs/broadcasting#client-side-installation). Make sure Echo is installed, as well as a [server-side websockets integration](https://laravel.com/docs/broadcasting#server-side-installation) like Pusher.

## Sending broadcast notifications

There are several ways to send broadcast notifications, depending on which one suits you best.

You may use our fluent API:

```php
use Filament\Notifications\Notification;

$recipient = auth()->user();

Notification::make()
    ->title('Saved successfully')
    ->broadcast($recipient);
```

Or, use the `notify()` method:

```php
use Filament\Notifications\Notification;

$recipient = auth()->user();

$recipient->notify(
    Notification::make()
        ->title('Saved successfully')
        ->toBroadcast(),
)
```

Alternatively, use a traditional [Laravel notification class](https://laravel.com/docs/notifications#generating-notifications) by returning the notification from the `toBroadcast()` method:

```php
use App\Models\User;
use Filament\Notifications\Notification;
use Illuminate\Notifications\Messages\BroadcastMessage;

public function toBroadcast(User $notifiable): BroadcastMessage
{
    return Notification::make()
        ->title('Saved successfully')
        ->getBroadcastMessage();
}
```

# Documentation for notifications. File: 05-customizing-notifications.md
---
title: Customizing notifications
---

## Overview

Notifications come fully styled out of the box. However, if you want to apply your own styling or use a custom view to render notifications, there are multiple options.

## Styling notifications

Notifications have dedicated CSS classes you can hook into to apply your own styling. Open the inspector in your browser to find out which classes you need to target.

## Positioning notifications

You can configure the alignment of the notifications in a service provider or middleware, by calling `Notifications::alignment()` and `Notifications::verticalAlignment()`. You can pass `Alignment::Start`, `Alignment::Center`, `Alignment::End`, `VerticalAlignment::Start`, `VerticalAlignment::Center` or `VerticalAlignment::End`:

```php
use Filament\Notifications\Livewire\Notifications;
use Filament\Support\Enums\Alignment;
use Filament\Support\Enums\VerticalAlignment;

Notifications::alignment(Alignment::Start);
Notifications::verticalAlignment(VerticalAlignment::End);
```

## Using a custom notification view

If your desired customization can't be achieved using the CSS classes above, you can create a custom view to render the notification. To configure the notification view, call the static `configureUsing()` method inside a service provider's `boot()` method and specify the view to use:

```php
use Filament\Notifications\Notification;

Notification::configureUsing(function (Notification $notification): void {
    $notification->view('filament.notifications.notification');
});
```

Next, create the view, in this example `resources/views/filament/notifications/notification.blade.php`. The view should use the package's base notification component for the notification functionality and pass the available `$notification` variable through the `notification` attribute. This is the bare minimum required to create your own notification view:

```blade
<x-filament-notifications::notification :notification="$notification">
    {{-- Notification content --}}
</x-filament-notifications::notification>
```

Getters for all notification properties will be available in the view. So, a custom notification view might look like this:

```blade
<x-filament-notifications::notification
    :notification="$notification"
    class="flex w-80 rounded-lg transition duration-200"
    x-transition:enter-start="opacity-0"
    x-transition:leave-end="opacity-0"
>
    <h4>
        {{ $getTitle() }}
    </h4>

    <p>
        {{ $getDate() }}
    </p>

    <p>
        {{ $getBody() }}
    </p>

    <span x-on:click="close">
        Close
    </span>
</x-filament-notifications::notification>
```

## Using a custom notification object

Maybe your notifications require additional functionality that's not defined in the package's `Notification` class. Then you can create your own `Notification` class, which extends the package's `Notification` class. For example, your notification design might need a size property.

Your custom `Notification` class in `app/Notifications/Notification.php` might contain:

```php
<?php

namespace App\Notifications;

use Filament\Notifications\Notification as BaseNotification;

class Notification extends BaseNotification
{
    protected string $size = 'md';

    public function toArray(): array
    {
        return [
            ...parent::toArray(),
            'size' => $this->getSize(),
        ];
    }

    public static function fromArray(array $data): static
    {
        return parent::fromArray($data)->size($data['size']);
    }

    public function size(string $size): static
    {
        $this->size = $size;

        return $this;
    }

    public function getSize(): string
    {
        return $this->size;
    }
}
```

Next, you should bind your custom `Notification` class into the container inside a service provider's `register()` method:

```php
use App\Notifications\Notification;
use Filament\Notifications\Notification as BaseNotification;

$this->app->bind(BaseNotification::class, Notification::class);
```

You can now use your custom `Notification` class in the same way as you would with the default `Notification` object.

# Documentation for notifications. File: 06-testing.md
---
title: Testing
---

## Overview

All examples in this guide will be written using [Pest](https://pestphp.com). To use Pest's Livewire plugin for testing, you can follow the installation instructions in the Pest documentation on plugins: [Livewire plugin for Pest](https://pestphp.com/docs/plugins#livewire). However, you can easily adapt this to PHPUnit.

## Testing session notifications

To check if a notification was sent using the session, use the `assertNotified()` helper:

```php
use function Pest\Livewire\livewire;

it('sends a notification', function () {
    livewire(CreatePost::class)
        ->assertNotified();
});
```

```php
use Filament\Notifications\Notification;

it('sends a notification', function () {
    Notification::assertNotified();
});
```

```php
use function Filament\Notifications\Testing\assertNotified;

it('sends a notification', function () {
    assertNotified();
});
```

You may optionally pass a notification title to test for:

```php
use Filament\Notifications\Notification;
use function Pest\Livewire\livewire;

it('sends a notification', function () {
    livewire(CreatePost::class)
        ->assertNotified('Unable to create post');
});
```

Or test if the exact notification was sent:

```php
use Filament\Notifications\Notification;
use function Pest\Livewire\livewire;

it('sends a notification', function () {
    livewire(CreatePost::class)
        ->assertNotified(
            Notification::make()
                ->danger()
                ->title('Unable to create post')
                ->body('Something went wrong.'),
        );
});
```

Conversely, you can assert that a notification was not sent:

```php
use Filament\Notifications\Notification;
use function Pest\Livewire\livewire;

it('does not send a notification', function () {
    livewire(CreatePost::class)
        ->assertNotNotified()
        // or
        ->assertNotNotified('Unable to create post')
        // or
        ->assertNotNotified(
            Notification::make()
                ->danger()
                ->title('Unable to create post')
                ->body('Something went wrong.'),
        );
```

# Documentation for notifications. File: 07-upgrade-guide.md
---
title: Upgrading from v2.x
---

> If you see anything missing from this guide, please do not hesitate to [make a pull request](https://github.com/filamentphp/filament/edit/3.x/packages/notifications/docs/07-upgrade-guide.md) to our repository! Any help is appreciated!

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
rm config/notifications.php
```

#### New `@filamentScripts` and `@filamentStyles` Blade directives

The `@filamentScripts` and `@filamentStyles` Blade directives must be added to your Blade layout file/s. Since Livewire v3 no longer uses similar directives, you can replace `@livewireScripts` with `@filamentScripts`  and `@livewireStyles` with `@filamentStyles`.

#### JavaScript assets

You no longer need to import the `NotificationsAlpinePlugin` in your JavaScript files. Alpine plugins are now automatically loaded by `@filamentScripts`.

#### Heroicons have been updated to v2

The Heroicons library has been updated to v2. This means that any icons you use in your app may have changed names. You can find a list of changes [here](https://github.com/tailwindlabs/heroicons/releases/tag/v2.0.0).

### Medium-impact changes

#### Secondary color

Filament v2 had a `secondary` color for many components which was gray. All references to `secondary` should be replaced with `gray` to preserve the same appearance. This frees `secondary` to be registered to a new custom color of your choice.

#### Notification JS objects

The `Notification` JavaScript object has been renamed to `FilamentNotification` to avoid conflicts with the native browser `Notification` object. The same has been done for `NotificationAction` (now `FilamentNotificationAction`) and `NotificationActionGroup` (now `FilamentNotificationActionGroup`) for consistency.

