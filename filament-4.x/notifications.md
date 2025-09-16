# Documentation for notifications. File: 01-overview.md
---
title: Overview
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Introduction

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

<AutoScreenshot name="notifications/success" alt="Success notification" version="4.x" />

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

Optionally, a notification can have an [icon](../styling/icons) that's displayed in front of its content. You may also set a color for the icon, which is gray by default:

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

<AutoScreenshot name="notifications/icon" alt="Notification with icon" version="4.x" />

Notifications often have a status like `success`, `warning`, `danger` or `info`. Instead of manually setting the corresponding [icons](../styling/icons) and [colors](../styling/colors), there's a `status()` method which you can pass the status. You may also use the dedicated `success()`, `warning()`, `danger()` and `info()` methods instead. So, cleaning up the above example would look like this:

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

<AutoScreenshot name="notifications/statuses" alt="Notifications with various statuses" version="4.x" />

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

<AutoScreenshot name="notifications/color" alt="Notification with background color" version="4.x" />

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

<AutoScreenshot name="notifications/body" alt="Notification with body text" version="4.x" />

## Adding actions to notifications

Notifications support [Actions](../actions/overview), which are buttons that render below the content of the notification. They can open a URL or dispatch a Livewire event. Actions can be defined as follows:

```php
use Filament\Actions\Action;
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

<AutoScreenshot name="notifications/actions" alt="Notification with actions" version="4.x" />

You can learn more about how to style action buttons [here](../actions/overview).

### Opening URLs from notification actions

You can open a URL, optionally in a new tab, when clicking on an action:

```php
use Filament\Actions\Action;
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
use Filament\Actions\Action;
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
use Filament\Actions\Action;
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

## Positioning notifications

You can configure the alignment of the notifications in a service provider or middleware, by calling `Notifications::alignment()` and `Notifications::verticalAlignment()`. You can pass `Alignment::Start`, `Alignment::Center`, `Alignment::End`, `VerticalAlignment::Start`, `VerticalAlignment::Center` or `VerticalAlignment::End`:

```php
use Filament\Notifications\Livewire\Notifications;
use Filament\Support\Enums\Alignment;
use Filament\Support\Enums\VerticalAlignment;

Notifications::alignment(Alignment::Start);
Notifications::verticalAlignment(VerticalAlignment::End);
```

# Documentation for notifications. File: 02-database-notifications.md
---
title: Database notifications
---
import Aside from "@components/Aside.astro"
import AutoScreenshot from "@components/AutoScreenshot.astro"

<AutoScreenshot name="notifications/database" alt="Database notifications" version="4.x" />

## Setting up the notifications database table

Before we start, make sure that the [Laravel notifications table](https://laravel.com/docs/notifications#database-prerequisites) is added to your database:

```bash
php artisan make:notifications-table
```

> If you're using PostgreSQL, make sure that the `data` column in the migration is using `json()`: `$table->json('data')`.

> If you're using UUIDs for your `User` model, make sure that your `notifiable` column is using `uuidMorphs()`: `$table->uuidMorphs('notifiable')`.

## Enabling database notifications in a panel

If you'd like to receive database notifications in a panel, you can enable them in the [configuration](../panel-configuration):

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->databaseNotifications();
}
```

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
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->databaseNotifications()
        ->databaseNotificationsPolling('30s');
}
```

You may completely disable polling if you wish:

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->databaseNotifications()
        ->databaseNotificationsPolling(null);
}
```

### Using Echo to receive new database notifications with websockets

Websockets are a more efficient way to receive new notifications in real-time. To set up websockets, you must [configure it](broadcast-notifications#setting-up-websockets-in-a-panel) in the panel first.

Once websockets are set up, you can automatically dispatch a `DatabaseNotificationsSent` event by setting the `isEventDispatched` parameter to `true` when sending the notification. This will trigger the immediate fetching of new notifications for the user:

```php
use Filament\Notifications\Notification;

$recipient = auth()->user();

Notification::make()
    ->title('Saved successfully')
    ->sendToDatabase($recipient, isEventDispatched: true);
```

## Marking database notifications as read

There is a button at the top of the modal to mark all notifications as read at once. You may also add [Actions](overview#adding-actions-to-notifications) to notifications, which you can use to mark individual notifications as read. To do this, use the `markAsRead()` method on the action:

```php
use Filament\Actions\Action;
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
use Filament\Actions\Action;
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

You can open the database notifications modal from anywhere by dispatching an `open-modal` browser event:

```blade
<button
    x-data="{}"
    x-on:click="$dispatch('open-modal', { id: 'database-notifications' })"
    type="button"
>
    Notifications
</button>
```

# Documentation for notifications. File: 03-broadcast-notifications.md
---
title: Broadcast notifications
---

## Introduction

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

