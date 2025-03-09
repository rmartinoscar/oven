# Documentation for support. File: 01-overview.md
---
title: Overview
---

This section of the documentation contains information that applies to all packages in the Filament ecosystem.

## Eloquent Models 

All of Filament's database interactions rely on Eloquent. If your application needs to work with a static data source like a plain PHP array, you may find [Sushi](https://github.com/calebporzio/sushi) useful for accessing that data from an Eloquent model.

# Documentation for support. File: 02-assets.md
---
title: Assets
---
import LaracastsBanner from "@components/LaracastsBanner.astro"

<LaracastsBanner
    title="Registering Plugin Assets"
    description="Watch the Build Advanced Components for Filament series on Laracasts - it will teach you how to get started with registering assets into a plugin. Alternatively, continue reading this text-based guide."
    url="https://laracasts.com/series/build-advanced-components-for-filament/episodes/14"
    series="building-advanced-components"
/>

## Overview

All packages in the Filament ecosystem share an asset management system. This allows both official plugins and third-party plugins to register CSS and JavaScript files that can then be consumed by Blade views.

## The `FilamentAsset` facade

The `FilamentAsset` facade is used to register files into the asset system. These files may be sourced from anywhere in the filesystem, but are then copied into the `/public` directory of the application when the `php artisan filament:assets` command is run. By copying them into the `/public` directory for you, we can predictably load them in Blade views, and also ensure that third party packages are able to load their assets without having to worry about where they are located.

Assets always have a unique ID chosen by you, which is used as the file name when the asset is copied into the `/public` directory. This ID is also used to reference the asset in Blade views. While the ID is unique, if you are registering assets for a plugin, then you do not need to worry about IDs clashing with other plugins, since the asset will be copied into a directory named after your plugin.

The `FilamentAsset` facade should be used in the `boot()` method of a service provider. It can be used inside an application service provider such as `AppServiceProvider`, or inside a plugin service provider.

The `FilamentAsset` facade has one main method, `register()`, which accepts an array of assets to register:

```php
use Filament\Support\Facades\FilamentAsset;

public function boot(): void
{
    // ...
    
    FilamentAsset::register([
        // ...
    ]);
    
    // ...
}
```

### Registering assets for a plugin

When registering assets for a plugin, you should pass the name of the Composer package as the second argument of the `register()` method:

```php
use Filament\Support\Facades\FilamentAsset;

FilamentAsset::register([
    // ...
], package: 'danharrin/filament-blog');
```

Now, all the assets for this plugin will be copied into their own directory inside `/public`, to avoid the possibility of clashing with other plugins' files with the same names.

## Registering CSS files

To register a CSS file with the asset system, use the `FilamentAsset::register()` method in the `boot()` method of a service provider. You must pass in an array of `Css` objects, which each represents a CSS file that should be registered in the asset system.

Each `Css` object has a unique ID and a path to the CSS file:

```php
use Filament\Support\Assets\Css;
use Filament\Support\Facades\FilamentAsset;

FilamentAsset::register([
    Css::make('custom-stylesheet', __DIR__ . '/../../resources/css/custom.css'),
]);
```

In this example, we use `__DIR__` to generate a relative path to the asset from the current file. For instance, if you were adding this code to `/app/Providers/AppServiceProvider.php`, then the CSS file should exist in `/resources/css/custom.css`.

Now, when the `php artisan filament:assets` command is run, this CSS file is copied into the `/public` directory. In addition, it is now loaded into all Blade views that use Filament. If you're interested in only loading the CSS when it is required by an element on the page, check out the [Lazy loading CSS](#lazy-loading-css) section.

### Using Tailwind CSS in plugins

Typically, registering CSS files is used to register custom stylesheets for your application. If you want to process these files using Tailwind CSS, you need to consider the implications of that, especially if you are a plugin developer.

Tailwind builds are unique to every application - they contain a minimal set of utility classes, only the ones that you are actually using in your application. This means that if you are a plugin developer, you probably should not be building your Tailwind CSS files into your plugin. Instead, you should provide the raw CSS files and instruct the user that they should build the Tailwind CSS file themselves. To do this, they probably just need to add your vendor directory into the `content` array of their `tailwind.config.js` file:

```js
export default {
    content: [
        './resources/**/*.blade.php',
        './vendor/filament/**/*.blade.php',
        './vendor/danharrin/filament-blog/resources/views/**/*.blade.php', // Your plugin's vendor directory
    ],
    // ...
}
```

This means that when they build their Tailwind CSS file, it will include all the utility classes that are used in your plugin's views, as well as the utility classes that are used in their application and the Filament core.

However, with this technique, there might be extra complications for users who use your plugin with the [Panel Builder](../panels). If they have a [custom theme](../panels/themes), they will be fine, since they are building their own CSS file anyway using Tailwind CSS. However, if they are using the default stylesheet which is shipped with the Panel Builder, you might have to be careful about the utility classes that you use in your plugin's views. For instance, if you use a utility class that is not included in the default stylesheet, the user is not compiling it themselves, and it will not be included in the final CSS file. This means that your plugin's views might not look as expected. This is one of the few situations where I would recommend compiling and [registering](#registering-css-files) a Tailwind CSS-compiled stylesheet in your plugin.

### Lazy loading CSS

By default, all CSS files registered with the asset system are loaded in the `<head>` of every Filament page. This is the simplest way to load CSS files, but sometimes they may be quite heavy and not required on every page. In this case, you can leverage the [Alpine.js Lazy Load Assets](https://github.com/tanthammar/alpine-lazy-load-assets) package that comes bundled with Filament. It allows you to easily load CSS files on-demand using Alpine.js. The premise is very simple, you use the `x-load-css` directive on an element, and when that element is loaded onto the page, the specified CSS files are loaded into the `<head>` of the page. This is perfect for both small UI elements and entire pages that require a CSS file:

```blade
<div
    x-data="{}"
    x-load-css="[@js(\Filament\Support\Facades\FilamentAsset::getStyleHref('custom-stylesheet'))]"
>
    <!-- ... -->
</div>
```

To prevent the CSS file from being loaded automatically, you can use the `loadedOnRequest()` method:

```php
use Filament\Support\Assets\Css;
use Filament\Support\Facades\FilamentAsset;

FilamentAsset::register([
    Css::make('custom-stylesheet', __DIR__ . '/../../resources/css/custom.css')->loadedOnRequest(),
]);
```

If your CSS file was [registered to a plugin](#registering-assets-for-a-plugin), you must pass that in as the second argument to the `FilamentAsset::getStyleHref()` method:

```blade
<div
    x-data="{}"
    x-load-css="[@js(\Filament\Support\Facades\FilamentAsset::getStyleHref('custom-stylesheet', package: 'danharrin/filament-blog'))]"
>
    <!-- ... -->
</div>
```

### Registering CSS files from a URL

If you want to register a CSS file from a URL, you may do so. These assets will be loaded on every page as normal, but not copied into the `/public` directory when the `php artisan filament:assets` command is run. This is useful for registering external stylesheets from a CDN, or stylesheets that you are already compiling directly into the `/public` directory:

```php
use Filament\Support\Assets\Css;
use Filament\Support\Facades\FilamentAsset;

FilamentAsset::register([
    Css::make('example-external-stylesheet', 'https://example.com/external.css'),
    Css::make('example-local-stylesheet', asset('css/local.css')),
]);
```

### Registering CSS variables

Sometimes, you may wish to use dynamic data from the backend in CSS files. To do this, you can use the `FilamentAsset::registerCssVariables()` method in the `boot()` method of a service provider:

```php
use Filament\Support\Facades\FilamentAsset;

FilamentAsset::registerCssVariables([
    'background-image' => asset('images/background.jpg'),
]);
```

Now, you can access these variables from any CSS file:

```css
background-image: var(--background-image);
```

## Registering JavaScript files

To register a JavaScript file with the asset system, use the `FilamentAsset::register()` method in the `boot()` method of a service provider. You must pass in an array of `Js` objects, which each represents a JavaScript file that should be registered in the asset system.

Each `Js` object has a unique ID and a path to the JavaScript file:

```php
use Filament\Support\Assets\Js;

FilamentAsset::register([
    Js::make('custom-script', __DIR__ . '/../../resources/js/custom.js'),
]);
```

In this example, we use `__DIR__` to generate a relative path to the asset from the current file. For instance, if you were adding this code to `/app/Providers/AppServiceProvider.php`, then the JavaScript file should exist in `/resources/js/custom.js`.

Now, when the `php artisan filament:assets` command is run, this JavaScript file is copied into the `/public` directory. In addition, it is now loaded into all Blade views that use Filament. If you're interested in only loading the JavaScript when it is required by an element on the page, check out the [Lazy loading JavaScript](#lazy-loading-javascript) section.

### Lazy loading JavaScript

By default, all JavaScript files registered with the asset system are loaded at the bottom of every Filament page. This is the simplest way to load JavaScript files, but sometimes they may be quite heavy and not required on every page. In this case, you can leverage the [Alpine.js Lazy Load Assets](https://github.com/tanthammar/alpine-lazy-load-assets) package that comes bundled with Filament. It allows you to easily load JavaScript files on-demand using Alpine.js. The premise is very simple, you use the `x-load-js` directive on an element, and when that element is loaded onto the page, the specified JavaScript files are loaded at the bottom of the page. This is perfect for both small UI elements and entire pages that require a JavaScript file:

```blade
<div
    x-data="{}"
    x-load-js="[@js(\Filament\Support\Facades\FilamentAsset::getScriptSrc('custom-script'))]"
>
    <!-- ... -->
</div>
```

To prevent the JavaScript file from being loaded automatically, you can use the `loadedOnRequest()` method:

```php
use Filament\Support\Assets\Js;
use Filament\Support\Facades\FilamentAsset;

FilamentAsset::register([
    Js::make('custom-script', __DIR__ . '/../../resources/js/custom.js')->loadedOnRequest(),
]);
```

If your JavaScript file was [registered to a plugin](#registering-assets-for-a-plugin), you must pass that in as the second argument to the `FilamentAsset::getScriptSrc()` method:

```blade
<div
    x-data="{}"
    x-load-js="[@js(\Filament\Support\Facades\FilamentAsset::getScriptSrc('custom-script', package: 'danharrin/filament-blog'))]"
>
    <!-- ... -->
</div>
```

#### Asynchronous Alpine.js components

<LaracastsBanner
    title="Using Async Alpine components"
    description="Watch the Build Advanced Components for Filament series on Laracasts - it will teach you how to get started with Async Alpine components into a plugin."
    url="https://laracasts.com/series/build-advanced-components-for-filament/episodes/15"
    series="building-advanced-components"
/>

Sometimes, you may want to load external JavaScript libraries for your Alpine.js-based components. The best way to do this is by storing the compiled JavaScript and Alpine component in a separate file, and letting us load it whenever the component is rendered.

Firstly, you should install [esbuild](https://esbuild.github.io) via NPM, which we will use to create a single JavaScript file containing your external library and Alpine component:

```bash
npm install esbuild --save-dev
```

Then, you must create a script to compile your JavaScript and Alpine component. You can put this anywhere, for example `bin/build.js`:

```js
import * as esbuild from 'esbuild'

const isDev = process.argv.includes('--dev')

async function compile(options) {
    const context = await esbuild.context(options)

    if (isDev) {
        await context.watch()
    } else {
        await context.rebuild()
        await context.dispose()
    }
}

const defaultOptions = {
    define: {
        'process.env.NODE_ENV': isDev ? `'development'` : `'production'`,
    },
    bundle: true,
    mainFields: ['module', 'main'],
    platform: 'neutral',
    sourcemap: isDev ? 'inline' : false,
    sourcesContent: isDev,
    treeShaking: true,
    target: ['es2020'],
    minify: !isDev,
    plugins: [{
        name: 'watchPlugin',
        setup: function (build) {
            build.onStart(() => {
                console.log(`Build started at ${new Date(Date.now()).toLocaleTimeString()}: ${build.initialOptions.outfile}`)
            })

            build.onEnd((result) => {
                if (result.errors.length > 0) {
                    console.log(`Build failed at ${new Date(Date.now()).toLocaleTimeString()}: ${build.initialOptions.outfile}`, result.errors)
                } else {
                    console.log(`Build finished at ${new Date(Date.now()).toLocaleTimeString()}: ${build.initialOptions.outfile}`)
                }
            })
        }
    }],
}

compile({
    ...defaultOptions,
    entryPoints: ['./resources/js/components/test-component.js'],
    outfile: './resources/js/dist/components/test-component.js',
})
```

As you can see at the bottom of the script, we are compiling a file called `resources/js/components/test-component.js` into `resources/js/dist/components/test-component.js`. You can change these paths to suit your needs. You can compile as many components as you want.

Now, create a new file called `resources/js/components/test-component.js`:

```js
// Import any external JavaScript libraries from NPM here.

export default function testComponent({
    state,
}) {
    return {
        state,
        
        // You can define any other Alpine.js properties here.

        init: function () {
            // Initialise the Alpine component here, if you need to.
        },
        
        // You can define any other Alpine.js functions here.
    }
}
```

Now, you can compile this file into `resources/js/dist/components/test-component.js` by running the following command:

```bash
node bin/build.js
```

If you want to watch for changes to this file instead of compiling once, try the following command:

```bash
node bin/build.js --dev
```

Now, you need to tell Filament to publish this compiled JavaScript file into the `/public` directory of the Laravel application, so it is accessible to the browser. To do this, you can use the `FilamentAsset::register()` method in the `boot()` method of a service provider, passing in an `AlpineComponent` object:

```php
use Filament\Support\Assets\AlpineComponent;
use Filament\Support\Facades\FilamentAsset;

FilamentAsset::register([
    AlpineComponent::make('test-component', __DIR__ . '/../../resources/js/dist/components/test-component.js'),
]);
```

When you run `php artisan filament:assets`, the compiled file will be copied into the `/public` directory.

Finally, you can load this asynchronous Alpine component in your view using `x-load` attributes and the `FilamentAsset::getAlpineComponentSrc()` method:

```blade
<div
    x-load
    x-load-src="{{ \Filament\Support\Facades\FilamentAsset::getAlpineComponentSrc('test-component') }}"
    x-data="testComponent({
        state: $wire.{{ $applyStateBindingModifiers("\$entangle('{$statePath}')") }},
    })"
>
    <input x-model="state" />
</div>
```

This example is for a [custom form field](../forms/fields/custom). It passes the `state` in as a parameter to the `testComponent()` function, which is entangled with a Livewire component property. You can pass in any parameters you want, and access them in the `testComponent()` function. If you're not using a custom form field, you can ignore the `state` parameter in this example.

The `x-load` attributes come from the [Async Alpine](https://async-alpine.dev/docs/strategies) package, and any features of that package can be used here.

### Registering script data

Sometimes, you may wish to make data from the backend available to JavaScript files. To do this, you can use the `FilamentAsset::registerScriptData()` method in the `boot()` method of a service provider:

```php
use Filament\Support\Facades\FilamentAsset;

FilamentAsset::registerScriptData([
    'user' => [
        'name' => auth()->user()?->name,
    ],
]);
```

Now, you can access that data from any JavaScript file at runtime, using the `window.filamentData` object:

```js
window.filamentData.user.name // 'Dan Harrin'
```

### Registering JavaScript files from a URL

If you want to register a JavaScript file from a URL, you may do so. These assets will be loaded on every page as normal, but not copied into the `/public` directory when the `php artisan filament:assets` command is run. This is useful for registering external scripts from a CDN, or scripts that you are already compiling directly into the `/public` directory:

```php
use Filament\Support\Assets\Js;

FilamentAsset::register([
    Js::make('example-external-script', 'https://example.com/external.js'),
    Js::make('example-local-script', asset('js/local.js')),
]);
```

# Documentation for support. File: 03-icons.md
---
title: Icons
---

## Overview

Icons are used throughout the entire Filament UI to visually communicate core parts of the user experience. To render icons, we use the [Blade Icons](https://github.com/blade-ui-kit/blade-icons) package from Blade UI Kit.

They have a website where you can [search all the available icons](https://blade-ui-kit.com/blade-icons?set=1#search) from various Blade Icons packages. Each package contains a different icon set that you can choose from.

## Using custom SVGs as icons

The [Blade Icons](https://github.com/blade-ui-kit/blade-icons) package allows you to register custom SVGs as icons. This is useful if you want to use your own custom icons in Filament.

To start with, publish the Blade Icons configuration file:

```bash
php artisan vendor:publish --tag=blade-icons
```

Now, open the `config/blade-icons.php` file, and uncomment the `default` set in the `sets` array.

Now that the default set exists in the config file, you can simply put any icons you want inside the `resources/svg` directory of your application. For example, if you put an SVG file named `star.svg` inside the `resources/svg` directory, you can reference it anywhere in Filament as `icon-star`. The `icon-` prefix is configurable in the `config/blade-icons.php` file too. You can also render the custom icon in a Blade view using the [`@svg('icon-star')` directive](https://github.com/blade-ui-kit/blade-icons#directive).

## Replacing the default icons

Filament includes an icon management system that allows you to replace any icons that are used by default in the UI with your own. This happens in the `boot()` method of any service provider, like `AppServiceProvider`, or even a dedicated service provider for icons. If you wanted to build a plugin to replace Heroicons with a different set, you could absolutely do that by creating a Laravel package with a similar service provider.

To replace an icon, you can use the `FilamentIcon` facade. It has a `register()` method, which accepts an array of icons to replace. The key of the array is the unique [icon alias](#available-icon-aliases) that identifies the icon in the Filament UI, and the value is name of a Blade icon to replace it instead. Alternatively, you may use HTML instead of an icon name to render an icon from a Blade view for example:

```php
use Filament\Support\Facades\FilamentIcon;

FilamentIcon::register([
    'panels::topbar.global-search.field' => 'fas-magnifying-glass',
    'panels::sidebar.group.collapse-button' => view('icons.chevron-up'),
]);
```

### Allowing users to customize icons from your plugin

If you have built a Filament plugin, your users may want to be able to customize icons in the same way that they can with any core Filament package. This is possible if you replace any manual `@svg()` usages with the `<x-filament::icon>` Blade component. This component allows you to pass in an icon alias, the name of the SVG icon that should be used by default, and any classes or HTML attributes:

```blade
<x-filament::icon
    alias="panels::topbar.global-search.field"
    icon="heroicon-m-magnifying-glass"
    wire:target="search"
    class="h-5 w-5 text-gray-500 dark:text-gray-400"
/>
```

Alternatively, you may pass an SVG element into the component's slot instead of defining a default icon name:

```blade
<x-filament::icon
    alias="panels::topbar.global-search.field"
    wire:target="search"
    class="h-5 w-5 text-gray-500 dark:text-gray-400"
>
    <svg>
        <!-- ... -->
    </svg>
</x-filament::icon>
```

## Available icon aliases

### Panel Builder icon aliases

- `panels::global-search.field` - Global search field
- `panels::pages.dashboard.actions.filter` - Trigger button of the dashboard filter action
- `panels::pages.dashboard.navigation-item` - Dashboard page navigation item
- `panels::pages.password-reset.request-password-reset.actions.login` - Trigger button of the login action on the request password reset page
- `panels::pages.password-reset.request-password-reset.actions.login.rtl` - Trigger button of the login action on the request password reset page (right-to-left direction)
- `panels::resources.pages.edit-record.navigation-item` - Resource edit record page navigation item
- `panels::resources.pages.manage-related-records.navigation-item` - Resource manage related records page navigation item
- `panels::resources.pages.view-record.navigation-item` - Resource view record page navigation item
- `panels::sidebar.collapse-button` - Button to collapse the sidebar
- `panels::sidebar.collapse-button.rtl` - Button to collapse the sidebar (right-to-left direction)
- `panels::sidebar.expand-button` - Button to expand the sidebar
- `panels::sidebar.expand-button.rtl` - Button to expand the sidebar (right-to-left direction)
- `panels::sidebar.group.collapse-button` - Collapse button for a sidebar group
- `panels::tenant-menu.billing-button` - Billing button in the tenant menu
- `panels::tenant-menu.profile-button` - Profile button in the tenant menu
- `panels::tenant-menu.registration-button` - Registration button in the tenant menu
- `panels::tenant-menu.toggle-button` - Button to toggle the tenant menu
- `panels::theme-switcher.light-button` - Button to switch to the light theme from the theme switcher
- `panels::theme-switcher.dark-button` - Button to switch to the dark theme from the theme switcher
- `panels::theme-switcher.system-button` - Button to switch to the system theme from the theme switcher
- `panels::topbar.close-sidebar-button` - Button to close the sidebar
- `panels::topbar.open-sidebar-button` - Button to open the sidebar
- `panels::topbar.group.toggle-button` - Toggle button for a topbar group
- `panels::topbar.open-database-notifications-button` - Button to open the database notifications modal
- `panels::user-menu.profile-item` - Profile item in the user menu
- `panels::user-menu.logout-button` - Button in the user menu to log out
- `panels::widgets.account.logout-button` - Button in the account widget to log out
- `panels::widgets.filament-info.open-documentation-button` - Button to open the documentation from the Filament info widget
- `panels::widgets.filament-info.open-github-button` - Button to open GitHub from the Filament info widget

### Form Builder icon aliases

- `forms::components.builder.actions.clone` - Trigger button of a clone action in a builder item
- `forms::components.builder.actions.collapse` - Trigger button of a collapse action in a builder item
- `forms::components.builder.actions.delete` - Trigger button of a delete action in a builder item
- `forms::components.builder.actions.expand` - Trigger button of an expand action in a builder item
- `forms::components.builder.actions.move-down` - Trigger button of a move down action in a builder item
- `forms::components.builder.actions.move-up` - Trigger button of a move up action in a builder item
- `forms::components.builder.actions.reorder` - Trigger button of a reorder action in a builder item
- `forms::components.checkbox-list.search-field` - Search input in a checkbox list
- `forms::components.file-upload.editor.actions.drag-crop` - Trigger button of a drag crop action in a file upload editor
- `forms::components.file-upload.editor.actions.drag-move` - Trigger button of a drag move action in a file upload editor
- `forms::components.file-upload.editor.actions.flip-horizontal` - Trigger button of a flip horizontal action in a file upload editor
- `forms::components.file-upload.editor.actions.flip-vertical` - Trigger button of a flip vertical action in a file upload editor
- `forms::components.file-upload.editor.actions.move-down` - Trigger button of a move down action in a file upload editor
- `forms::components.file-upload.editor.actions.move-left` - Trigger button of a move left action in a file upload editor
- `forms::components.file-upload.editor.actions.move-right` - Trigger button of a move right action in a file upload editor
- `forms::components.file-upload.editor.actions.move-up` - Trigger button of a move up action in a file upload editor
- `forms::components.file-upload.editor.actions.rotate-left` - Trigger button of a rotate left action in a file upload editor
- `forms::components.file-upload.editor.actions.rotate-right` - Trigger button of a rotate right action in a file upload editor
- `forms::components.file-upload.editor.actions.zoom-100` - Trigger button of a zoom 100 action in a file upload editor
- `forms::components.file-upload.editor.actions.zoom-in` - Trigger button of a zoom in action in a file upload editor
- `forms::components.file-upload.editor.actions.zoom-out` - Trigger button of a zoom out action in a file upload editor
- `forms::components.key-value.actions.delete` - Trigger button of a delete action in a key-value field item
- `forms::components.key-value.actions.reorder` - Trigger button of a reorder action in a key-value field item
- `forms::components.repeater.actions.clone` - Trigger button of a clone action in a repeater item
- `forms::components.repeater.actions.collapse` - Trigger button of a collapse action in a repeater item
- `forms::components.repeater.actions.delete` - Trigger button of a delete action in a repeater item
- `forms::components.repeater.actions.expand` - Trigger button of an expand action in a repeater item
- `forms::components.repeater.actions.move-down` - Trigger button of a move down action in a repeater item
- `forms::components.repeater.actions.move-up` - Trigger button of a move up action in a repeater item
- `forms::components.repeater.actions.reorder` - Trigger button of a reorder action in a repeater item
- `forms::components.select.actions.create-option` - Trigger button of a create option action in a select field
- `forms::components.select.actions.edit-option` - Trigger button of an edit option action in a select field
- `forms::components.text-input.actions.hide-password` - Trigger button of a hide password action in a text input field
- `forms::components.text-input.actions.show-password` - Trigger button of a show password action in a text input field
- `forms::components.toggle-buttons.boolean.false` - "False" option of a `boolean()` toggle buttons field
- `forms::components.toggle-buttons.boolean.true` - "True" option of a `boolean()` toggle buttons field
- `forms::components.wizard.completed-step` - Completed step in a wizard

### Table Builder icon aliases

- `tables::actions.disable-reordering` - Trigger button of the disable reordering action
- `tables::actions.enable-reordering` - Trigger button of the enable reordering action
- `tables::actions.filter` - Trigger button of the filter action
- `tables::actions.group` - Trigger button of a group records action
- `tables::actions.open-bulk-actions` - Trigger button of an open bulk actions action
- `tables::actions.toggle-columns` - Trigger button of the toggle columns action
- `tables::columns.collapse-button` - Button to collapse a column
- `tables::columns.icon-column.false` - Falsy state of an icon column
- `tables::columns.icon-column.true` - Truthy state of an icon column
- `tables::empty-state` - Empty state icon
- `tables::filters.query-builder.constraints.boolean` - Default icon for a boolean constraint in the query builder
- `tables::filters.query-builder.constraints.date` - Default icon for a date constraint in the query builder
- `tables::filters.query-builder.constraints.number` - Default icon for a number constraint in the query builder
- `tables::filters.query-builder.constraints.relationship` - Default icon for a relationship constraint in the query builder
- `tables::filters.query-builder.constraints.select` - Default icon for a select constraint in the query builder
- `tables::filters.query-builder.constraints.text` - Default icon for a text constraint in the query builder
- `tables::filters.remove-all-button` - Button to remove all filters
- `tables::grouping.collapse-button` - Button to collapse a group of records
- `tables::header-cell.sort-asc-button` - Sort button of a column sorted in ascending order
- `tables::header-cell.sort-button` - Sort button of a column when it is currently not sorted
- `tables::header-cell.sort-desc-button` - Sort button of a column sorted in descending order
- `tables::reorder.handle` - Handle to grab in order to reorder a record with drag and drop
- `tables::search-field` - Search input

### Notifications icon aliases

- `notifications::database.modal.empty-state` - Empty state of the database notifications modal
- `notifications::notification.close-button` - Button to close a notification
- `notifications::notification.danger` - Danger notification
- `notifications::notification.info` - Info notification
- `notifications::notification.success` - Success notification
- `notifications::notification.warning` - Warning notification

### Actions icon aliases

- `actions::action-group` - Trigger button of an action group
- `actions::create-action.grouped` - Trigger button of a grouped create action
- `actions::delete-action` - Trigger button of a delete action
- `actions::delete-action.grouped` - Trigger button of a grouped delete action
- `actions::delete-action.modal` - Modal of a delete action
- `actions::detach-action` - Trigger button of a detach action
- `actions::detach-action.modal` - Modal of a detach action
- `actions::dissociate-action` - Trigger button of a dissociate action
- `actions::dissociate-action.modal` - Modal of a dissociate action
- `actions::edit-action` - Trigger button of an edit action
- `actions::edit-action.grouped` - Trigger button of a grouped edit action
- `actions::export-action.grouped` - Trigger button of a grouped export action
- `actions::force-delete-action` - Trigger button of a force delete action
- `actions::force-delete-action.grouped` - Trigger button of a grouped force delete action
- `actions::force-delete-action.modal` - Modal of a force delete action
- `actions::import-action.grouped` - Trigger button of a grouped import action
- `actions::modal.confirmation` - Modal of an action that requires confirmation
- `actions::replicate-action` - Trigger button of a replicate action
- `actions::replicate-action.grouped` - Trigger button of a grouped replicate action
- `actions::restore-action` - Trigger button of a restore action
- `actions::restore-action.grouped` - Trigger button of a grouped restore action
- `actions::restore-action.modal` - Modal of a restore action
- `actions::view-action` - Trigger button of a view action
- `actions::view-action.grouped` - Trigger button of a grouped view action

### Infolist Builder icon aliases

- `infolists::components.icon-entry.false` - Falsy state of an icon entry
- `infolists::components.icon-entry.true` - Truthy state of an icon entry

### UI components icon aliases

- `badge.delete-button` - Button to delete a badge
- `breadcrumbs.separator` - Separator between breadcrumbs
- `breadcrumbs.separator.rtl` - Separator between breadcrumbs (right-to-left direction)
- `modal.close-button` - Button to close a modal
- `pagination.first-button` - Button to go to the first page
- `pagination.first-button.rtl` - Button to go to the first page (right-to-left direction)
- `pagination.last-button` - Button to go to the last page
- `pagination.last-button.rtl` - Button to go to the last page (right-to-left direction)
- `pagination.next-button` - Button to go to the next page
- `pagination.next-button.rtl` - Button to go to the next page (right-to-left direction)
- `pagination.previous-button` - Button to go to the previous page
- `pagination.previous-button.rtl` - Button to go to the previous page (right-to-left direction)
- `section.collapse-button` - Button to collapse a section

# Documentation for support. File: 04-colors.md
---
title: Colors
---

## Overview

Filament uses CSS variables to define its color palette. These CSS variables are mapped to Tailwind classes in the preset file that you load when installing Filament.

## Customizing the default colors

From a service provider's `boot()` method, or middleware, you can call the `FilamentColor::register()` method, which you can use to customize which colors Filament uses for UI elements.

There are 6 default colors that are used throughout Filament that you are able to customize:

```php
use Filament\Support\Colors\Color;
use Filament\Support\Facades\FilamentColor;

FilamentColor::register([
    'danger' => Color::Red,
    'gray' => Color::Zinc,
    'info' => Color::Blue,
    'primary' => Color::Amber,
    'success' => Color::Green,
    'warning' => Color::Amber,
]);
```

The `Color` class contains every [Tailwind CSS color](https://tailwindcss.com/docs/customizing-colors#color-palette-reference) to choose from.

You can also pass in a function to `register()` which will only get called when the app is getting rendered. This is useful if you are calling `register()` from a service provider, and want to access objects like the currently authenticated user, which are initialized later in middleware.

## Using a non-Tailwind color

You can use custom colors that are not included in the [Tailwind CSS color](https://tailwindcss.com/docs/customizing-colors#color-palette-reference) palette by passing an array of color shades from `50` to `950` in RGB format:

```php
use Filament\Support\Facades\FilamentColor;

FilamentColor::register([
    'danger' => [
        50 => '254, 242, 242',
        100 => '254, 226, 226',
        200 => '254, 202, 202',
        300 => '252, 165, 165',
        400 => '248, 113, 113',
        500 => '239, 68, 68',
        600 => '220, 38, 38',
        700 => '185, 28, 28',
        800 => '153, 27, 27',
        900 => '127, 29, 29',
        950 => '69, 10, 10',
    ],
]);
```

### Generating a custom color from a hex code

You can use the `Color::hex()` method to generate a custom color palette from a hex code:

```php
use Filament\Support\Colors\Color;
use Filament\Support\Facades\FilamentColor;

FilamentColor::register([
    'danger' => Color::hex('#ff0000'),
]);
```

### Generating a custom color from an RGB value

You can use the `Color::rgb()` method to generate a custom color palette from an RGB value:

```php
use Filament\Support\Colors\Color;
use Filament\Support\Facades\FilamentColor;

FilamentColor::register([
    'danger' => Color::rgb('rgb(255, 0, 0)'),
]);
```

## Registering extra colors

You can register extra colors that you can use throughout Filament:

```php
use Filament\Support\Colors\Color;
use Filament\Support\Facades\FilamentColor;

FilamentColor::register([
    'indigo' => Color::Indigo,
]);
```

Now, you can use this color anywhere you would normally add `primary`, `danger`, etc.

# Documentation for support. File: 05-style-customization.md
---
title: Style customization
---

## Overview

Filament uses CSS "hook" classes to allow various HTML elements to be customized using CSS.

## Discovering hook classes

We could document all the hook classes across the entire Filament UI, but that would be a lot of work, and probably not very useful to you. Instead, we recommend using your browser's developer tools to inspect the elements you want to customize, and then use the hook classes to target those elements.

All hook classes are prefixed with `fi-`, which is a great way to identify them. They are usually right at the start of the class list, so they are easy to find, but sometimes they may fall further down the list if we have to apply them conditionally with JavaScript or Blade.

If you don't find a hook class you're looking for, try not to hack around it, as it might expose your styling customizations to breaking changes in future releases. Instead, please open a pull request to add the hook class you need. We can help you maintain naming consistency. You probably don't even need to pull down the Filament repository locally for these pull requests, as you can just edit the Blade files directly on GitHub.

## Applying styles to hook classes

For example, if you want to customize the color of the sidebar, you can inspect the sidebar element in your browser's developer tools, see that it uses the `fi-sidebar`, and then add CSS to your app like this:

```css
.fi-sidebar {
    background-color: #fafafa;
}
```

Alternatively, since Filament is built upon Tailwind CSS, you can use their `@apply` directive to apply Tailwind classes to Filament elements:

```css
.fi-sidebar {
    @apply bg-gray-50 dark:bg-gray-950;
}
```

Occasionally, you may need to use the `!important` modifier to override existing styles, but please use this sparingly, as it can make your styles difficult to maintain:

```css
.fi-sidebar {
    @apply bg-gray-50 dark:bg-gray-950 !important;
}
```

You can even apply `!important` to only specific Tailwind classes, which is a little less intrusive, by prefixing the class name with `!`:

```css
.fi-sidebar {
    @apply !bg-gray-50 dark:!bg-gray-950;
}
```

## Common hook class abbreviations

We use a few common abbreviations in our hook classes to keep them short and readable:

- `fi` is short for "Filament"
- `fi-ac` is used to represent classes used in the Actions package
- `fi-fo` is used to represent classes used in the Form Builder package
- `fi-in` is used to represent classes used in the Infolist Builder package
- `fi-no` is used to represent classes used in the Notifications package
- `fi-ta` is used to represent classes used in the Table Builder package
- `fi-wi` is used to represent classes used in the Widgets package
- `btn` is short for "button"
- `col` is short for "column"
- `ctn` is short for "container"
- `wrp` is short for "wrapper"

## Publishing Blade views

You may be tempted to publish the internal Blade views to your application so that you can customize them. We don't recommend this, as it will introduce breaking changes into your application in future updates. Please use the [CSS hook classes](#applying-styles-to-hook-classes) wherever possible.

If you do decide to publish the Blade views, please lock all Filament packages to a specific version in your `composer.json` file, and then update Filament manually by bumping this number, testing your entire application after each update. This will help you identify breaking changes safely.

# Documentation for support. File: 06-render-hooks.md
---
title: Render hooks
---

## Overview

Filament allows you to render Blade content at various points in the frameworks views. It's useful for plugins to be able to inject HTML into the framework. Also, since Filament does not recommend publishing the views due to an increased risk of breaking changes, it's also useful for users.

## Registering render hooks

To register render hooks, you can call `FilamentView::registerRenderHook()` from a service provider or middleware. The first argument is the name of the render hook, and the second argument is a callback that returns the content to be rendered:

```php
use Filament\Support\Facades\FilamentView;
use Filament\View\PanelsRenderHook;
use Illuminate\Support\Facades\Blade;

FilamentView::registerRenderHook(
    PanelsRenderHook::BODY_START,
    fn (): string => Blade::render('@livewire(\'livewire-ui-modal\')'),
);
```

You could also render view content from a file:

```php
use Filament\Support\Facades\FilamentView;
use Filament\View\PanelsRenderHook;
use Illuminate\Contracts\View\View;

FilamentView::registerRenderHook(
    PanelsRenderHook::BODY_START,
    fn (): View => view('impersonation-banner'),
);
```

## Available render hooks

### Panel Builder render hooks

```php
    use Filament\View\PanelsRenderHook;
```

- `PanelsRenderHook::AUTH_LOGIN_FORM_AFTER` - After login form
- `PanelsRenderHook::AUTH_LOGIN_FORM_BEFORE` - Before login form
- `PanelsRenderHook::AUTH_PASSWORD_RESET_REQUEST_FORM_AFTER` - After password reset request form
- `PanelsRenderHook::AUTH_PASSWORD_RESET_REQUEST_FORM_BEFORE` - Before password reset request form
- `PanelsRenderHook::AUTH_PASSWORD_RESET_RESET_FORM_AFTER` - After password reset form
- `PanelsRenderHook::AUTH_PASSWORD_RESET_RESET_FORM_BEFORE` - Before password reset form
- `PanelsRenderHook::AUTH_REGISTER_FORM_AFTER` - After register form
- `PanelsRenderHook::AUTH_REGISTER_FORM_BEFORE` - Before register form
- `PanelsRenderHook::BODY_END` - Before `</body>`
- `PanelsRenderHook::BODY_START` - After `<body>`
- `PanelsRenderHook::CONTENT_END` - After page content, inside `<main>`
- `PanelsRenderHook::CONTENT_START` - Before page content, inside `<main>`
- `PanelsRenderHook::FOOTER` - Footer of the page
- `PanelsRenderHook::GLOBAL_SEARCH_AFTER` - After the [global search](../panels/resources/global-search) container, inside the topbar
- `PanelsRenderHook::GLOBAL_SEARCH_BEFORE` - Before the [global search](../panels/resources/global-search) container, inside the topbar
- `PanelsRenderHook::GLOBAL_SEARCH_END` - The end of the [global search](../panels/resources/global-search) container
- `PanelsRenderHook::GLOBAL_SEARCH_START` - The start of the [global search](../panels/resources/global-search) container
- `PanelsRenderHook::HEAD_END` - Before `</head>`
- `PanelsRenderHook::HEAD_START` - After `<head>`
- `PanelsRenderHook::PAGE_END` - End of the page content container, also [can be scoped](#scoping-render-hooks) to the page or resource class
- `PanelsRenderHook::PAGE_FOOTER_WIDGETS_AFTER` - After the page footer widgets, also [can be scoped](#scoping-render-hooks) to the page or resource class
- `PanelsRenderHook::PAGE_FOOTER_WIDGETS_BEFORE` - Before the page footer widgets, also [can be scoped](#scoping-render-hooks) to the page or resource class
- `PanelsRenderHook::PAGE_HEADER_ACTIONS_AFTER` - After the page header actions, also [can be scoped](#scoping-render-hooks) to the page or resource class
- `PanelsRenderHook::PAGE_HEADER_ACTIONS_BEFORE` - Before the page header actions, also [can be scoped](#scoping-render-hooks) to the page or resource class
- `PanelsRenderHook::PAGE_HEADER_WIDGETS_AFTER` - After the page header widgets, also [can be scoped](#scoping-render-hooks) to the page or resource class
- `PanelsRenderHook::PAGE_HEADER_WIDGETS_BEFORE` - Before the page header widgets, also [can be scoped](#scoping-render-hooks) to the page or resource class
- `PanelsRenderHook::PAGE_START` - Start of the page content container, also [can be scoped](#scoping-render-hooks) to the page or resource class
- `PanelsRenderHook::PAGE_SUB_NAVIGATION_END_AFTER` - After the page sub navigation "end" sidebar position, also [can be scoped](#scoping-render-hooks) to the page or resource class
- `PanelsRenderHook::PAGE_SUB_NAVIGATION_END_BEFORE` - Before the page sub navigation "end" sidebar position, also [can be scoped](#scoping-render-hooks) to the page or resource class
- `PanelsRenderHook::PAGE_SUB_NAVIGATION_SELECT_AFTER` - After the page sub navigation select (for mobile), also [can be scoped](#scoping-render-hooks) to the page or resource class
- `PanelsRenderHook::PAGE_SUB_NAVIGATION_SELECT_BEFORE` - Before the page sub navigation select (for mobile), also [can be scoped](#scoping-render-hooks) to the page or resource class
- `PanelsRenderHook::PAGE_SUB_NAVIGATION_SIDEBAR_AFTER` - After the page sub navigation sidebar, also [can be scoped](#scoping-render-hooks) to the page or resource class
- `PanelsRenderHook::PAGE_SUB_NAVIGATION_SIDEBAR_BEFORE` - Before the page sub navigation sidebar, also [can be scoped](#scoping-render-hooks) to the page or resource class
- `PanelsRenderHook::PAGE_SUB_NAVIGATION_START_AFTER` - After the page sub navigation "start" sidebar position, also [can be scoped](#scoping-render-hooks) to the page or resource class
- `PanelsRenderHook::PAGE_SUB_NAVIGATION_START_BEFORE` - Before the page sub navigation "start" sidebar position, also [can be scoped](#scoping-render-hooks) to the page or resource class
- `PanelsRenderHook::PAGE_SUB_NAVIGATION_TOP_AFTER` - After the page sub navigation "top" tabs position, also [can be scoped](#scoping-render-hooks) to the page or resource class
- `PanelsRenderHook::PAGE_SUB_NAVIGATION_TOP_BEFORE` - Before the page sub navigation "top" tabs position, also [can be scoped](#scoping-render-hooks) to the page or resource class
- `PanelsRenderHook::RESOURCE_PAGES_LIST_RECORDS_TABLE_AFTER` - After the resource table, also [can be scoped](#scoping-render-hooks) to the page or resource class
- `PanelsRenderHook::RESOURCE_PAGES_LIST_RECORDS_TABLE_BEFORE` - Before the resource table, also [can be scoped](#scoping-render-hooks) to the page or resource class
- `PanelsRenderHook::RESOURCE_PAGES_LIST_RECORDS_TABS_END` - The end of the filter tabs (after the last tab), also [can be scoped](#scoping-render-hooks) to the page or resource class
- `PanelsRenderHook::RESOURCE_PAGES_LIST_RECORDS_TABS_START` - The start of the filter tabs (before the first tab), also [can be scoped](#scoping-render-hooks) to the page or resource class
- `PanelsRenderHook::RESOURCE_PAGES_MANAGE_RELATED_RECORDS_TABLE_AFTER` - After the relation manager table, also [can be scoped](#scoping-render-hooks) to the page or resource class
- `PanelsRenderHook::RESOURCE_PAGES_MANAGE_RELATED_RECORDS_TABLE_BEFORE` - Before the relation manager table, also [can be scoped](#scoping-render-hooks) to the page or resource class
- `PanelsRenderHook::RESOURCE_RELATION_MANAGER_AFTER` - After the relation manager table, also [can be scoped](#scoping-render-hooks) to the page or relation manager class
- `PanelsRenderHook::RESOURCE_RELATION_MANAGER_BEFORE` - Before the relation manager table, also [can be scoped](#scoping-render-hooks) to the page or relation manager class
- `PanelsRenderHook::RESOURCE_TABS_END` - The end of the resource tabs (after the last tab), also [can be scoped](#scoping-render-hooks) to the page or resource class
- `PanelsRenderHook::RESOURCE_TABS_START` - The start of the resource tabs (before the first tab), also [can be scoped](#scoping-render-hooks) to the page or resource class
- `PanelsRenderHook::SCRIPTS_AFTER` - After scripts are defined
- `PanelsRenderHook::SCRIPTS_BEFORE` - Before scripts are defined
- `PanelsRenderHook::SIDEBAR_NAV_END` - In the [sidebar](../panels/navigation), before `</nav>`
- `PanelsRenderHook::SIDEBAR_NAV_START` - In the [sidebar](../panels/navigation), after `<nav>`
- `PanelsRenderHook::SIMPLE_PAGE_END` - End of the simple page content container, also [can be scoped](#scoping-render-hooks) to the page class
- `PanelsRenderHook::SIMPLE_PAGE_START` - Start of the simple page content container, also [can be scoped](#scoping-render-hooks) to the page class
- `PanelsRenderHook::SIDEBAR_FOOTER` - Pinned to the bottom of the sidebar, below the content
- `PanelsRenderHook::STYLES_AFTER` - After styles are defined
- `PanelsRenderHook::STYLES_BEFORE` - Before styles are defined
- `PanelsRenderHook::TENANT_MENU_AFTER` - After the [tenant menu](../panels/tenancy#customizing-the-tenant-menu)
- `PanelsRenderHook::TENANT_MENU_BEFORE` - Before the [tenant menu](../panels/tenancy#customizing-the-tenant-menu)
- `PanelsRenderHook::TOPBAR_AFTER` - Below the topbar
- `PanelsRenderHook::TOPBAR_BEFORE` - Above the topbar
- `PanelsRenderHook::TOPBAR_END` - End of the topbar container
- `PanelsRenderHook::TOPBAR_START` - Start of the topbar container
- `PanelsRenderHook::USER_MENU_AFTER` - After the [user menu](../panels/navigation#customizing-the-user-menu)
- `PanelsRenderHook::USER_MENU_BEFORE` - Before the [user menu](../panels/navigation#customizing-the-user-menu)
- `PanelsRenderHook::USER_MENU_PROFILE_AFTER` - After the profile item in the [user menu](../panels/navigation#customizing-the-user-menu)
- `PanelsRenderHook::USER_MENU_PROFILE_BEFORE` - Before the profile item in the [user menu](../panels/navigation#customizing-the-user-menu)


### Table Builder render hooks

All these render hooks [can be scoped](#scoping-render-hooks) to any table Livewire component class. When using the Panel Builder, these classes might be the List or Manage page of a resource, or a relation manager. Table widgets are also Livewire component classes.

```php
    use Filament\Tables\View\TablesRenderHook;
```

- `TablesRenderHook::SELECTION_INDICATOR_ACTIONS_AFTER` - After the "select all" and "deselect all" action buttons in the selection indicator bar
- `TablesRenderHook::SELECTION_INDICATOR_ACTIONS_BEFORE` - Before the "select all" and "deselect all" action buttons in the selection indicator bar
- `TablesRenderHook::HEADER_AFTER` - After the header container
- `TablesRenderHook::HEADER_BEFORE` - Before the header container
- `TablesRenderHook::TOOLBAR_AFTER` - After the toolbar container
- `TablesRenderHook::TOOLBAR_BEFORE` - Before the toolbar container
- `TablesRenderHook::TOOLBAR_END` - The end of the toolbar
- `TablesRenderHook::TOOLBAR_GROUPING_SELECTOR_AFTER` - After the [grouping](../tables/grouping) selector
- `TablesRenderHook::TOOLBAR_GROUPING_SELECTOR_BEFORE` - Before the [grouping](../tables/grouping) selector
- `TablesRenderHook::TOOLBAR_REORDER_TRIGGER_AFTER` - After the [reorder](../tables/advanced#reordering-records) trigger
- `TablesRenderHook::TOOLBAR_REORDER_TRIGGER_BEFORE` - Before the [reorder](../tables/advanced#reordering-records) trigger
- `TablesRenderHook::TOOLBAR_SEARCH_AFTER` - After the [search](../tables/getting-started#making-columns-sortable-and-searchable) container
- `TablesRenderHook::TOOLBAR_SEARCH_BEFORE` - Before the [search](../tables/getting-started#making-columns-sortable-and-searchable) container
- `TablesRenderHook::TOOLBAR_START` - The start of the toolbar
- `TablesRenderHook::TOOLBAR_TOGGLE_COLUMN_TRIGGER_AFTER` - After the [toggle columns](../tables/columns/getting-started#toggling-column-visibility) trigger
- `TablesRenderHook::TOOLBAR_TOGGLE_COLUMN_TRIGGER_BEFORE` - Before the [toggle columns](../tables/columns/getting-started#toggling-column-visibility) trigger


### Widgets render hooks

```php
    use Filament\Widgets\View\WidgetsRenderHook;
```

- `WidgetsRenderHook::TABLE_WIDGET_END` - End of the [table widget](../panels/dashboard#table-widgets), after the table itself, also [can be scoped](#scoping-render-hooks) to the table widget class
- `WidgetsRenderHook::TABLE_WIDGET_START` - Start of the [table widget](../panels/dashboard#table-widgets), before the table itself, also [can be scoped](#scoping-render-hooks) to the table widget class


## Scoping render hooks

Some render hooks can be given a "scope", which allows them to only be output on a specific page or Livewire component. For instance, you might want to register a render hook for just 1 page. To do that, you can pass the class of the page or component as the second argument to `registerRenderHook()`:

```php
use Filament\Support\Facades\FilamentView;
use Filament\View\PanelsRenderHook;
use Illuminate\Support\Facades\Blade;

FilamentView::registerRenderHook(
    PanelsRenderHook::PAGE_START,
    fn (): View => view('warning-banner'),
    scopes: \App\Filament\Resources\UserResource\Pages\EditUser::class,
);
```

You can also pass an array of scopes to register the render hook for:

```php
use Filament\Support\Facades\FilamentView;
use Filament\View\PanelsRenderHook;

FilamentView::registerRenderHook(
    PanelsRenderHook::PAGE_START,
    fn (): View => view('warning-banner'),
    scopes: [
        \App\Filament\Resources\UserResource\Pages\CreateUser::class,
        \App\Filament\Resources\UserResource\Pages\EditUser::class,
    ],
);
```

Some render hooks for the [Panel Builder](#panel-builder-render-hooks) allow you to scope hooks to all pages in a resource:

```php
use Filament\Support\Facades\FilamentView;
use Filament\View\PanelsRenderHook;

FilamentView::registerRenderHook(
    PanelsRenderHook::PAGE_START,
    fn (): View => view('warning-banner'),
    scopes: \App\Filament\Resources\UserResource::class,
);
```

### Retrieving the currently active scopes inside the render hook

The `$scopes` are passed to the render hook function, and you can use them to determine which page or component the render hook is being rendered on:

```php
use Filament\Support\Facades\FilamentView;
use Filament\View\PanelsRenderHook;

FilamentView::registerRenderHook(
    PanelsRenderHook::PAGE_START,
    fn (array $scopes): View => view('warning-banner', ['scopes' => $scopes]),
    scopes: \App\Filament\Resources\UserResource::class,
);
```

## Rendering hooks

Plugin developers might find it useful to expose render hooks to their users. You do not need to register them anywhere, simply output them in Blade like so:

```blade
{{ \Filament\Support\Facades\FilamentView::renderHook(\Filament\View\PanelsRenderHook::PAGE_START) }}
```

To provide scope your render hook, you can pass it as the second argument to `renderHook()`. For instance, if your hook is inside a Livewire component, you can pass the class of the component using `static::class`:

```blade
{{ \Filament\Support\Facades\FilamentView::renderHook(\Filament\View\PanelsRenderHook::PAGE_START, scopes: $this->getRenderHookScopes()) }}
```

You can even pass multiple scopes as an array, and all render hooks that match any of the scopes will be rendered:

```blade
{{ \Filament\Support\Facades\FilamentView::renderHook(\Filament\View\PanelsRenderHook::PAGE_START, scopes: [static::class, \App\Filament\Resources\UserResource::class]) }}
```

# Documentation for support. File: 07-enums.md
---
title: Enums
---

## Overview

Enums are special PHP classes that represent a fixed set of constants. They are useful for modeling concepts that have a limited number of possible values, like days of the week, months in a year, or the suits in a deck of cards.

Since enum "cases" are instances of the enum class, adding interfaces to enums proves to be very useful. Filament provides a collection of interfaces that you can add to enums, which enhance your experience when working with them.

> When using an enum with an attribute on your Eloquent model, please [ensure that it is cast correctly](https://laravel.com/docs/eloquent-mutators#enum-casting).

## Enum labels

The `HasLabel` interface transforms an enum instance into a textual label. This is useful for displaying human-readable enum values in your UI.

```php
use Filament\Support\Contracts\HasLabel;

enum Status: string implements HasLabel
{
    case Draft = 'draft';
    case Reviewing = 'reviewing';
    case Published = 'published';
    case Rejected = 'rejected';
    
    public function getLabel(): ?string
    {
        return $this->name;
        
        // or
    
        return match ($this) {
            self::Draft => 'Draft',
            self::Reviewing => 'Reviewing',
            self::Published => 'Published',
            self::Rejected => 'Rejected',
        };
    }
}
```

### Using the enum label with form field options

The `HasLabel` interface can be used to generate an array of options from an enum, where the enum's value is the key and the enum's label is the value. This applies to Form Builder fields like [`Select`](../forms/fields/select) and [`CheckboxList`](../forms/fields/checkbox-list), as well as the Table Builder's [`SelectColumn`](../tables/columns/select) and [`SelectFilter`](../tables/filters/select):

```php
use Filament\Forms\Components\CheckboxList;
use Filament\Forms\Components\Radio;
use Filament\Forms\Components\Select;
use Filament\Tables\Columns\SelectColumn;
use Filament\Tables\Filters\SelectFilter;

Select::make('status')
    ->options(Status::class)

CheckboxList::make('status')
    ->options(Status::class)

Radio::make('status')
    ->options(Status::class)

SelectColumn::make('status')
    ->options(Status::class)

SelectFilter::make('status')
    ->options(Status::class)
```

In these examples, `Status::class` is the enum class which implements `HasLabel`, and the options are generated from that:

```php
[
    'draft' => 'Draft',
    'reviewing' => 'Reviewing',
    'published' => 'Published',
    'rejected' => 'Rejected',
]
```

### Using the enum label with a text column in your table

If you use a [`TextColumn`](../tables/columns/text) with the Table Builder, and it is cast to an enum in your Eloquent model, Filament will automatically use the `HasLabel` interface to display the enum's label instead of its raw value.

### Using the enum label as a group title in your table

If you use a [grouping](../tables/grouping) with the Table Builder, and it is cast to an enum in your Eloquent model, Filament will automatically use the `HasLabel` interface to display the enum's label instead of its raw value. The label will be displayed as the [title of each group](../tables/grouping#setting-a-group-title).

### Using the enum label with a text entry in your infolist

If you use a [`TextEntry`](../infolists/entries/text) with the Infolist Builder, and it is cast to an enum in your Eloquent model, Filament will automatically use the `HasLabel` interface to display the enum's label instead of its raw value.

## Enum colors

The `HasColor` interface transforms an enum instance into a [color](colors). This is useful for displaying colored enum values in your UI.

```php
use Filament\Support\Contracts\HasColor;

enum Status: string implements HasColor
{
    case Draft = 'draft';
    case Reviewing = 'reviewing';
    case Published = 'published';
    case Rejected = 'rejected';
    
    public function getColor(): string | array | null
    {
        return match ($this) {
            self::Draft => 'gray',
            self::Reviewing => 'warning',
            self::Published => 'success',
            self::Rejected => 'danger',
        };
    }
}
```

### Using the enum color with a text column in your table

If you use a [`TextColumn`](../tables/columns/text) with the Table Builder, and it is cast to an enum in your Eloquent model, Filament will automatically use the `HasColor` interface to display the enum label in its color. This works best if you use the [`badge()`](../tables/columns/text#displaying-as-a-badge) method on the column.

### Using the enum color with a text entry in your infolist

If you use a [`TextEntry`](../infolists/entries/text) with the Infolist Builder, and it is cast to an enum in your Eloquent model, Filament will automatically use the `HasColor` interface to display the enum label in its color. This works best if you use the [`badge()`](../infolists/entries/text#displaying-as-a-badge) method on the entry.

### Using the enum color with a toggle buttons field in your form

If you use a [`ToggleButtons`](../forms/fields/toggle-buttons) with the Form Builder, and it is set to use an enum for its options, Filament will automatically use the `HasColor` interface to display the enum label in its color.

## Enum icons

The `HasIcon` interface transforms an enum instance into an [icon](icons). This is useful for displaying icons alongside enum values in your UI.

```php
use Filament\Support\Contracts\HasIcon;

enum Status: string implements HasIcon
{
    case Draft = 'draft';
    case Reviewing = 'reviewing';
    case Published = 'published';
    case Rejected = 'rejected';
    
    public function getIcon(): ?string
    {
        return match ($this) {
            self::Draft => 'heroicon-m-pencil',
            self::Reviewing => 'heroicon-m-eye',
            self::Published => 'heroicon-m-check',
            self::Rejected => 'heroicon-m-x-mark',
        };
    }
}
```

### Using the enum icon with a text column in your table

If you use a [`TextColumn`](../tables/columns/text) with the Table Builder, and it is cast to an enum in your Eloquent model, Filament will automatically use the `HasIcon` interface to display the enum's icon aside its label. This works best if you use the [`badge()`](../tables/columns/text#displaying-as-a-badge) method on the column.

### Using the enum icon with a text entry in your infolist

If you use a [`TextEntry`](../infolists/entries/text) with the Infolist Builder, and it is cast to an enum in your Eloquent model, Filament will automatically use the `HasIcon` interface to display the enum's icon aside its label. This works best if you use the [`badge()`](../infolists/entries/text#displaying-as-a-badge) method on the entry.

### Using the enum icon with a toggle buttons field in your form

If you use a [`ToggleButtons`](../forms/fields/toggle-buttons) with the Form Builder, and it is set to use an enum for its options, Filament will automatically use the `HasIcon` interface to display the enum's icon aside its label.

## Enum descriptions

The `HasDescription` interface transforms an enum instance into a textual description, often displayed under its [label](#enum-labels). This is useful for displaying human-friendly descriptions in your UI.

```php
use Filament\Support\Contracts\HasDescription;
use Filament\Support\Contracts\HasLabel;

enum Status: string implements HasLabel, HasDescription
{
    case Draft = 'draft';
    case Reviewing = 'reviewing';
    case Published = 'published';
    case Rejected = 'rejected';
    
    public function getLabel(): ?string
    {
        return $this->name;
    }
    
    public function getDescription(): ?string
    {
        return match ($this) {
            self::Draft => 'This has not finished being written yet.',
            self::Reviewing => 'This is ready for a staff member to read.',
            self::Published => 'This has been approved by a staff member and is public on the website.',
            self::Rejected => 'A staff member has decided this is not appropriate for the website.',
        };
    }
}
```

### Using the enum description with form field descriptions

The `HasDescription` interface can be used to generate an array of descriptions from an enum, where the enum's value is the key and the enum's description is the value. This applies to Form Builder fields like [`Radio`](../forms/fields/radio#setting-option-descriptions) and [`CheckboxList`](../forms/fields/checkbox-list#setting-option-descriptions):

```php
use Filament\Forms\Components\CheckboxList;
use Filament\Forms\Components\Radio;

Radio::make('status')
    ->options(Status::class)

CheckboxList::make('status')
    ->options(Status::class)
```

# Documentation for support. File: 08-contributing.md
---
title: Contributing
---

> Parts of this guide are taken from [Laravel's contribution guide](https://laravel.com/docs/contributions), and it served as very useful inspiration.

## Reporting bugs

If you find a bug in Filament, please report it by opening an issue on our [GitHub repository](https://github.com/filamentphp/filament/issues/new/choose). Before opening an issue, please search the [existing issues](https://github.com/filamentphp/filament/issues?q=is%3Aissue) to see if the bug has already been reported.

Please make sure to include as much information as possible, including the version of packages in your app. You can use this Artisan command in your app to open a new issue with all the correct versions pre-filled:

```bash
php artisan make:filament-issue
```

When creating an issue, we require a "reproduction repository". **Please do not link to your actual project**, what we need instead is a _minimal_ reproduction in a fresh project without any unnecessary code. This means it doesn't matter if your real project is private / confidential, since we want a link to a separate, isolated reproduction. This allows us to fix the problem much quicker. **Issues will be automatically closed and not reviewed if this is missing, to preserve maintainer time and to ensure the process is fair for those who put effort into reporting.** If you believe a reproduction repository is not suitable for the issue, which is a very rare case, please `@danharrin` and explain why. Saying that "it's just a simple issue" is not an excuse for not creating a repository! [Need a headstart? We have a template Filament project for you.](https://filament-issue.unitedbycode.com)

Remember, bug reports are created in the hope that others with the same problem will be able to collaborate with you on solving it. Do not expect that the bug report will automatically see any activity or that others will jump to fix it. Creating a bug report serves to help yourself and others start on the path of fixing the problem.

## Development of new features

If you would like to propose a new feature or improvement to Filament, you may use our [discussion form](https://github.com/filamentphp/filament/discussions) hosted on GitHub. If you are intending on implementing the feature yourself in a pull request, we advise you to `@danharrin` in your feature discussion beforehand and ask if it is suitable for the framework to prevent wasting your time.

## Development of plugins

If you would like to develop a plugin for Filament, please refer to the [plugin development section](https://filamentphp.com/docs/support/plugins) here in the documentation. Our [Discord](https://filamentphp.com/discord) server is also a great place to ask questions and get help with plugin development. You can start a conversation in the [`#plugin-developers-chat`](https://discord.com/channels/883083792112300104/970354547723730955) channel.

You can [submit your plugin to the Filament website](https://github.com/filamentphp/filamentphp.com/blob/main/README.md#contributing).

## Developing with a local copy of Filament

If you want to contribute to the Filament packages, then you may want to test it in a real Laravel project:

- Fork [the GitHub repository](https://github.com/filamentphp/filament) to your GitHub account.
- Create a Laravel app locally.
- Clone your fork in your Laravel app's root directory.
- In the `/filament` directory, create a branch for your fix, e.g. `fix/error-message`.

Install the packages in your app's `composer.json`:

```jsonc
{
    // ...
    "require": {
        "filament/filament": "*",
    },
    "minimum-stability": "dev",
    "repositories": [
        {
            "type": "path",
            "url": "filament/packages/*"
        }
    ],
    // ...
}
```

Now, run `composer update`.

Once you're finished making changes, you can commit them and submit a pull request to [the GitHub repository](https://github.com/filamentphp/filament).

## Checking for missing translations

Set up a Laravel app, and install the [panel builder](https://filamentphp.com/docs/admin/installation).

Now, if you want to check for missing Spanish translations, run:

```bash
php artisan filament:check-translations es
```

This will let you know which translations are missing for this locale. You can make a pull request with the changes to [the GitHub repository](https://github.com/filamentphp/filament).

If you've published the translations into your app and you'd like to check those instead, try:

```bash
php artisan filament:check-translations es --source=app
```

## Security vulnerabilities

If you discover a security vulnerability within Filament, please email Dan Harrin via [dan@danharrin.com](mailto:dan@danharrin.com). All security vulnerabilities will be promptly addressed.

## Code of Conduct

Please note that Filament is released with a [Contributor Code of Conduct](https://github.com/filamentphp/filament/blob/afa0c703da18ce78b508951436f571c9d4813db6/CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

# Documentation for support. File: 08-plugins/01-getting-started.md
---
title: Getting started
---
import LaracastsBanner from "@components/LaracastsBanner.astro"

<LaracastsBanner
    title="Setting up a Plugin"
    description="Watch the Build Advanced Components for Filament series on Laracasts - it will teach you how to get started with your plugin. The text-based guide on this page can also give a good overview."
    url="https://laracasts.com/series/build-advanced-components-for-filament/episodes/12"
    series="building-advanced-components"
/>

## Overview

While Filament comes with virtually any tool you'll need to build great apps, sometimes you'll need to add your own functionality either for just your app or as redistributable packages that other developers can include in their own apps. This is why Filament offers a plugin system that allows you to extend its functionality.

Before we dive in, it's important to understand the different contexts in which plugins can be used. There are two main contexts:

1. **Panel Plugins**: These are plugins that are used with [Panel Builders](/docs/3.x/panels/installation). They are typically used only to add functionality when used inside a Panel or as a complete Panel in and of itself. Examples of this are:
   1. A plugin that adds specific functionality to the dashboard in the form of Widgets.
   2. A plugin that adds a set of Resources / functionality to an app like a Blog or User Management feature.
2. **Standalone Plugins**: These are plugins that are used in any context outside a Panel Builder. Examples of this are:
   1. A plugin that adds custom fields to be used with the [Form Builders](/docs/3.x/forms/installation/).
   2. A plugin that adds custom columns or filters to the [Table Builders](/docs/3.x/tables/installation/).

Although these are two different mental contexts to keep in mind when building plugins, they can be used together inside the same plugin. They do not have to be mutually exclusive.

## Important Concepts

Before we dive into the specifics of building plugins, there are a few concepts that are important to understand. You should familiarize yourself with the following before building a plugin:

1. [Laravel Package Development](https://laravel.com/docs/packages)
2. [Spatie Package Tools](https://github.com/spatie/laravel-package-tools)
3. [Filament Asset Management](/docs/3.x/support/assets)

### The Plugin object

Filament v3 introduces the concept of a Plugin object that is used to configure the plugin. This object is a simple PHP class that implements the `Filament\Contracts\Plugin` interface. This class is used to configure the plugin and is the main entry point for the plugin. It is also used to register Resources and Icons that might be used by your plugin.

While the plugin object is extremely helpful, it is not required to build a plugin. You can still build plugins without using the plugin object as you can see in the [Building a Panel Plugin](/docs/3.x/support/plugins/build-a-panel-plugin) tutorial.

> **Info** 
> The Plugin object is only used for Panel Providers. Standalone Plugins do not use this object. All configuration for Standalone Plugins should be handled in the plugin's service provider.

### Registering Assets

All [asset registration](/docs/3.x/support/assets), including CSS, JS and Alpine Components, should be done through the plugin's service provider in the `packageBooted()` method. This allows Filament to register the assets with the Asset Manager and load them when needed.

## Creating a Plugin

While you can certainly build plugins from scratch, we recommend using the [Filament Plugin Skeleton](https://github.com/filamentphp/plugin-skeleton) to quickly get started. This skeleton includes all the necessary boilerplate to get you up and running quickly.

### Usage

To use the skeleton, simply go to the GitHub repo and click the "Use this template" button. This will create a new repo in your account with the skeleton code. After that, you can clone the repo to your machine. Once you have the code on your machine, navigate to the root of the project and run the following command:

```bash
php ./configure.php
```

This will ask you a series of questions to configure the plugin. Once you've answered all the questions, the script will stub out a new plugin for you, and you can begin to build your amazing new extension for Filament.

## Upgrading existing plugins

Since every plugin varies greatly in its scope of use and functionality, there is no one size fits all approaches to upgrading existing plugins. However, one thing to note, that is consistent to all plugins is the deprecation of the `PluginServiceProvider`.

In your plugin service provider, you will need to change it to extend the PackageServiceProvider instead. You will also need to add a static `$name` property to the service provider. This property is used to register the plugin with Filament. Here is an example of what your service provider might look like:

```php
class MyPluginServiceProvider extends PackageServiceProvider
{
    public static string $name = 'my-plugin';

    public function configurePackage(Package $package): void
    {
        $package->name(static::$name);
    }
}
```

### Helpful links

Please read this guide in its entirety before upgrading your plugin. It will help you understand the concepts and how to build your plugin.

1. [Filament Asset Management](/docs/3.x/support/assets)
2. [Panel Plugin Development](/docs/3.x/panels/plugins)
3. [Icon Management](/docs/3.x/support/icons)
4. [Colors Management](/docs/3.x/support/colors)
5. [Style Customization](/docs/3.x/support/style-customization)

# Documentation for support. File: 08-plugins/02-build-a-panel-plugin.md
---
title: Build a panel plugin
---
import LaracastsBanner from "@components/LaracastsBanner.astro"

<LaracastsBanner
    title="Panel Builder Plugins"
    description="Watch the Build Advanced Components for Filament series on Laracasts - it will teach you how to get started with your plugin. The text-based guide on this page can also give a good overview."
    url="https://laracasts.com/series/build-advanced-components-for-filament/episodes/16"
    series="building-advanced-components"
/>

## Preface

Please read the docs on [panel plugin development](/docs/3.x/panels/plugins) and the [getting started guide](/docs/3.x/support/plugins/getting-started) before continuing.

## Overview

In this walkthrough, we'll build a simple plugin that adds a new form field that can be used in forms. This also means it will be available to users in their panels.

You can find the final code for this plugin at [https://github.com/awcodes/clock-widget](https://github.com/awcodes/clock-widget).

## Step 1: Create the plugin

First, we'll create the plugin using the steps outlined in the [getting started guide](/docs/3.x/support/plugins/getting-started#creating-a-plugin).

## Step 2: Clean up

Next, we'll clean up the plugin to remove the boilerplate code we don't need. This will seem like a lot, but since this is a simple plugin, we can remove a lot of the boilerplate code.

Remove the following directories and files:
1. `config`
1. `database`
1. `src/Commands`
1. `src/Facades`
1. `stubs`

Since our plugin doesn't have any settings or additional methods needed for functionality, we can also remove the `ClockWidgetPlugin.php` file.

1. `ClockWidgetPlugin.php`

Since Filament v3 recommends that users style their plugins with a custom filament theme, we'll remove the files needed for using css in the plugin. This is optional, and you can still use css if you want, but it is not recommended.

1. `resources/css`
1. `postcss.config.js`
1. `tailwind.config.js`

Now we can clean up our `composer.json` file to remove unneeded options.

```json
"autoload": {
    "psr-4": {
        // We can remove the database factories
        "Awcodes\\ClockWidget\\Database\\Factories\\": "database/factories/"
    }
},
"extra": {
    "laravel": {
        // We can remove the facade
        "aliases": {
            "ClockWidget": "Awcodes\\ClockWidget\\Facades\\ClockWidget"
        }
    }
},
```

The last step is to update the `package.json` file to remove unneeded options. Replace the contents of `package.json` with the following.

```json
{
    "private": true,
    "type": "module",
    "scripts": {
        "dev": "node bin/build.js --dev",
        "build": "node bin/build.js"
    },
    "devDependencies": {
        "esbuild": "^0.17.19"
    }
}
```

Then we need to install our dependencies.

```bash
npm install
```

You may also remove the Testing directories and files, but we'll leave them in for now, although we won't be using them for this example, and we highly recommend that you write tests for your plugins.

## Step 3: Setting up the provider

Now that we have our plugin cleaned up, we can start adding our code. The boilerplate in the `src/ClockWidgetServiceProvider.php` file has a lot going on so, let's delete everything and start from scratch.

> In this example, we will be registering an [async Alpine component](../assets#asynchronous-alpinejs-components). Since these assets are only loaded on request, we can register them as normal in the `packageBooted()` method. If you are registering assets, like CSS or JS files, that get loaded on every page regardless of if they are used or not, you should register them in the `register()` method of the `Plugin` configuration object, using [`$panel->assets()`](../../panels/configuration#registering-assets-for-a-panel). Otherwise, if you register them in the `packageBooted()` method, they will be loaded in every panel, regardless of whether or not the plugin has been registered for that panel.

We need to be able to register our Widget with the panel and load our Alpine component when the widget is used. To do this, we'll need to add the following to the `packageBooted` method in our service provider. This will register our widget component with Livewire and our Alpine component with the Filament Asset Manager.

```php
use Filament\Support\Assets\AlpineComponent;
use Filament\Support\Facades\FilamentAsset;
use Livewire\Livewire;
use Spatie\LaravelPackageTools\Package;
use Spatie\LaravelPackageTools\PackageServiceProvider;

class ClockWidgetServiceProvider extends PackageServiceProvider
{
    public static string $name = 'clock-widget';

    public function configurePackage(Package $package): void
    {
        $package->name(static::$name)
            ->hasViews()
            ->hasTranslations();
    }

    public function packageBooted(): void
    {
        Livewire::component('clock-widget', ClockWidget::class);

        // Asset Registration
        FilamentAsset::register(
            assets:[
                 AlpineComponent::make('clock-widget', __DIR__ . '/../resources/dist/clock-widget.js'),
            ],
            package: 'awcodes/clock-widget'
        );
    }
}
```

## Step 4: Create the widget

Now we can create our widget. We'll first need to extend Filament's `Widget` class in our `ClockWidget.php` file and tell it where to find the view for the widget. Since we are using the PackageServiceProvider to register our views, we can use the `::` syntax to tell Filament where to find the view.

```php
use Filament\Widgets\Widget;

class ClockWidget extends Widget
{
    protected static string $view = 'clock-widget::widget';
}
```

Next, we'll need to create the view for our widget. Create a new file at `resources/views/widget.blade.php` and add the following code. We'll make use of Filament's blade components to save time on writing the html for the widget.

We are using async Alpine to load our Alpine component, so we'll need to add the `x-load` attribute to the div to tell Alpine to load our component. You can learn more about this in the [Core Concepts](/docs/3.x/support/assets#asynchronous-alpinejs-components) section of the docs.

```blade
<x-filament-widgets::widget>
    <x-filament::section>
        <x-slot name="heading">
            {{ __('clock-widget::clock-widget.title') }}
        </x-slot>

        <div
            x-load
            x-load-src="{{ \Filament\Support\Facades\FilamentAsset::getAlpineComponentSrc('clock-widget', 'awcodes/clock-widget') }}"
            x-data="clockWidget()"
            class="text-center"
        >
            <p>{{ __('clock-widget::clock-widget.description') }}</p>
            <p class="text-xl" x-text="time"></p>
        </div>
    </x-filament::section>
</x-filament-widgets::widget>
```

Next, we need to write our Alpine component in `src/js/index.js`. And build our assets with `npm run build`.

```js
export default function clockWidget() {
    return {
        time: new Date().toLocaleTimeString(),
        init() {
            setInterval(() => {
                this.time = new Date().toLocaleTimeString();
            }, 1000);
        }
    }
}
```

We should also add translations for the text in the widget so users can translate the widget into their language. We'll add the translations to `resources/lang/en/widget.php`.

```php
return [
    'title' => 'Clock Widget',
    'description' => 'Your current time is:',
];
```

## Step 5: Update your README

You'll want to update your `README.md` file to include instructions on how to install your plugin and any other information you want to share with users, Like how to use it in their projects. For example:

```php
// Register the plugin and/or Widget in your Panel provider:

use Awcodes\ClockWidget\ClockWidgetWidget;

public function panel(Panel $panel): Panel
{
    return $panel
        ->widgets([
            ClockWidgetWidget::class,
        ]);
}
```

And, that's it, our users can now install our plugin and use it in their projects.

# Documentation for support. File: 08-plugins/03-build-a-standalone-plugin.md
---
title: Build a standalone plugin
---

## Preface

Please read the docs on [panel plugin development](/docs/3.x/panels/plugins/) and the [getting started guide](/docs/3.x/support/plugins/getting-started) before continuing.

## Overview

In this walkthrough, we'll build a simple plugin that adds a new form component that can be used in forms. This also means it will be available to users in their panels.

You can find the final code for this plugin at [https://github.com/awcodes/headings](https://github.com/awcodes/headings).

## Step 1: Create the plugin

First, we'll create the plugin using the steps outlined in the [getting started guide](/docs/3.x/support/plugins/getting-started#creating-a-plugin).

## Step 2: Clean up

Next, we'll clean up the plugin to remove the boilerplate code we don't need. This will seem like a lot, but since this is a simple plugin, we can remove a lot of the boilerplate code.

Remove the following directories and files:
1. `bin`
1. `config`
1. `database`
1. `src/Commands`
1. `src/Facades`
1. `stubs`
1. `tailwind.config.js`

Now we can clean up our `composer.json` file to remove unneeded options.

```json
"autoload": {
    "psr-4": {
        // We can remove the database factories
        "Awcodes\\Headings\\Database\\Factories\\": "database/factories/"
    }
},
"extra": {
    "laravel": {
        // We can remove the facade
        "aliases": {
            "Headings": "Awcodes\\Headings\\Facades\\ClockWidget"
        }
    }
},
```

Normally, Filament v3 recommends that users style their plugins with a custom filament theme, but for the sake of example let's provide our own stylesheet that can be loaded asynchronously using the new `x-load` features in Filament v3. So, let's update our `package.json` file to include cssnano, postcss, postcss-cli and postcss-nesting to build our stylesheet.

```json
{
    "private": true,
    "scripts": {
        "build": "postcss resources/css/index.css -o resources/dist/headings.css"
    },
    "devDependencies": {
        "cssnano": "^6.0.1",
        "postcss": "^8.4.27",
        "postcss-cli": "^10.1.0",
        "postcss-nesting": "^13.0.0"
    }
}
```

Then we need to install our dependencies.

```bash
npm install
```

We will also need to update our `postcss.config.js` file to configure postcss.

```js
module.exports = {
    plugins: [
        require('postcss-nesting')(),
        require('cssnano')({
            preset: 'default',
        }),
    ],
};
```

You may also remove the testing directories and files, but we'll leave them in for now, although we won't be using them for this example, and we highly recommend that you write tests for your plugins.

## Step 3: Setting up the provider

Now that we have our plugin cleaned up, we can start adding our code. The boilerplate in the `src/HeadingsServiceProvider.php` file has a lot going on so, let's delete everything and start from scratch.

We need to be able to register our stylesheet with the Filament Asset Manager so that we can load it on demand in our blade view. To do this, we'll need to add the following to the `packageBooted` method in our service provider.

***Note the `loadedOnRequest()` method. This is important, because it tells Filament to only load the stylesheet when it's needed.***

```php
namespace Awcodes\Headings;

use Filament\Support\Assets\Css;
use Filament\Support\Facades\FilamentAsset;
use Spatie\LaravelPackageTools\Package;
use Spatie\LaravelPackageTools\PackageServiceProvider;

class HeadingsServiceProvider extends PackageServiceProvider
{
    public static string $name = 'headings';

    public function configurePackage(Package $package): void
    {
        $package->name(static::$name)
            ->hasViews();
    }

    public function packageBooted(): void
    {
        FilamentAsset::register([
            Css::make('headings', __DIR__ . '/../resources/dist/headings.css')->loadedOnRequest(),
        ], 'awcodes/headings');
    }
}
```

## Step 4: Creating our component

Next, we'll need to create our component. Create a new file at `src/Heading.php` and add the following code.

```php
namespace Awcodes\Headings;

use Closure;
use Filament\Forms\Components\Component;
use Filament\Support\Colors\Color;
use Filament\Support\Concerns\HasColor;

class Heading extends Component
{
    use HasColor;

    protected string | int $level = 2;

    protected string | Closure $content = '';

    protected string $view = 'headings::heading';

    final public function __construct(string | int $level)
    {
        $this->level($level);
    }

    public static function make(string | int $level): static
    {
        return app(static::class, ['level' => $level]);
    }

    protected function setUp(): void
    {
        parent::setUp();

        $this->dehydrated(false);
    }

    public function content(string | Closure $content): static
    {
        $this->content = $content;

        return $this;
    }

    public function level(string | int $level): static
    {
        $this->level = $level;

        return $this;
    }

    public function getColor(): array
    {
        return $this->evaluate($this->color) ?? Color::Amber;
    }

    public function getContent(): string
    {
        return $this->evaluate($this->content);
    }

    public function getLevel(): string
    {
        return is_int($this->level) ? 'h' . $this->level : $this->level;
    }
}
```

## Step 5: Rendering our component

Next, we'll need to create the view for our component. Create a new file at `resources/views/heading.blade.php` and add the following code.

We are using x-load to asynchronously load stylesheet, so it's only loaded when necessary. You can learn more about this in the [Core Concepts](/docs/3.x/support/assets#lazy-loading-css) section of the docs.

```blade
@php
    $level = $getLevel();
    $color = $getColor();
@endphp

<{{ $level }}
    x-data
    x-load-css="[@js(\Filament\Support\Facades\FilamentAsset::getStyleHref('headings', package: 'awcodes/headings'))]"
    {{
        $attributes
            ->class([
                'headings-component',
                match ($color) {
                    'gray' => 'text-gray-600 dark:text-gray-400',
                    default => 'text-custom-500',
                },
            ])
            ->style([
                \Filament\Support\get_color_css_variables($color, [500]) => $color !== 'gray',
            ])
    }}
>
    {{ $getContent() }}
</{{ $level }}>
```

## Step 6: Adding some styles

Next, let's provide some custom styling for our field. We'll add the following to `resources/css/index.css`. And run `npm run build` to compile our css.

```css
.headings-component {
    &:is(h1, h2, h3, h4, h5, h6) {
         font-weight: 700;
         letter-spacing: -.025em;
         line-height: 1.1;
     }

    &h1 {
         font-size: 2rem;
     }

    &h2 {
         font-size: 1.75rem;
     }

    &h3 {
         font-size: 1.5rem;
     }

    &h4 {
         font-size: 1.25rem;
     }

    &h5,
    &h6 {
         font-size: 1rem;
     }
}
```

Then we need to build our stylesheet.

```bash
npm run build
```

## Step 7: Update your README

You'll want to update your `README.md` file to include instructions on how to install your plugin and any other information you want to share with users, Like how to use it in their projects. For example:

```php
use Awcodes\Headings\Heading;

Heading::make(2)
    ->content('Product Information')
    ->color(Color::Lime),
```

And, that's it, our users can now install our plugin and use it in their projects.

# Documentation for support. File: 09-blade-components/01-overview.md
---
title: Overview
---

## Overview

Filament packages consume a set of core Blade components that aim to provide a consistent and maintainable foundation for all interfaces. Some of these components are also available for use in your own applications and Filament plugins.

## Available UI components

- [Avatar](avatar)
- [Badge](badge)
- [Breadcrumbs](breadcrumbs)
- [Loading indicator](loading-indicator)
- [Section](section)
- [Tabs](tabs)

### UI components for actions

- [Button](button)
- [Dropdown](dropdown)
- [Icon button](icon-button)
- [Link](link)
- [Modal](modal)

### UI components for forms

- [Checkbox](checkbox)
- [Fieldset](fieldset)
- [Input](input)
- [Input wrapper](input-wrapper)
- [Select](select)

### UI components for tables

- [Pagination](pagination)

# Documentation for support. File: 09-blade-components/02-avatar.md
---
title: Avatar Blade component
---

## Overview

The avatar component is used to render a circular or square image, often used to represent a user or entity as their "profile picture":

```blade
<x-filament::avatar
    src="https://filamentphp.com/dan.jpg"
    alt="Dan Harrin"
/>
```

## Setting the rounding of an avatar

Avatars are fully rounded by default, but you may make them square by setting the `circular` attribute to `false`:

```blade
<x-filament::avatar
    src="https://filamentphp.com/dan.jpg"
    alt="Dan Harrin"
    :circular="false"
/>
```

## Setting the size of an avatar

By default, the avatar will be "medium" size. You can set the size to either `sm`, `md`, or `lg` using the `size` attribute:

```blade
<x-filament::avatar
    src="https://filamentphp.com/dan.jpg"
    alt="Dan Harrin"
    size="lg"
/>
```

You can also pass your own custom size classes into the `size` attribute:

```blade
<x-filament::avatar
    src="https://filamentphp.com/dan.jpg"
    alt="Dan Harrin"
    size="w-12 h-12"
/>

# Documentation for support. File: 09-blade-components/02-badge.md
---
title: Badge Blade component
---

## Overview

The badge component is used to render a small box with some text inside:

```blade
<x-filament::badge>
    New
</x-filament::badge>
```

## Setting the size of a badge

By default, the size of a badge is "medium". You can make it "extra small" or "small" by using the `size` attribute:

```blade
<x-filament::badge size="xs">
    New
</x-filament::badge>

<x-filament::badge size="sm">
    New
</x-filament::badge>
```

## Changing the color of the badge

By default, the color of a badge is "primary". You can change it to be `danger`, `gray`, `info`, `success` or `warning` by using the `color` attribute:

```blade
<x-filament::badge color="danger">
    New
</x-filament::badge>

<x-filament::badge color="gray">
    New
</x-filament::badge>

<x-filament::badge color="info">
    New
</x-filament::badge>

<x-filament::badge color="success">
    New
</x-filament::badge>

<x-filament::badge color="warning">
    New
</x-filament::badge>
```

## Adding an icon to a badge

You can add an [icon](https://blade-ui-kit.com/blade-icons?set=1#search) to a badge by using the `icon` attribute:

```blade
<x-filament::badge icon="heroicon-m-sparkles">
    New
</x-filament::badge>
```

You can also change the icon's position to be after the text instead of before it, using the `icon-position` attribute:

```blade
<x-filament::badge
    icon="heroicon-m-sparkles"
    icon-position="after"
>
    New
</x-filament::badge>
```

# Documentation for support. File: 09-blade-components/02-breadcrumbs.md
---
title: Breadcrumbs Blade component
---

## Overview

The breadcrumbs component is used to render a simple, linear navigation that informs the user of their current location within the application:

```blade
<x-filament::breadcrumbs :breadcrumbs="[
    '/' => 'Home',
    '/dashboard' => 'Dashboard',
    '/dashboard/users' => 'Users',
    '/dashboard/users/create' => 'Create User',
]" />
```

The keys of the array are URLs that the user is able to click on to navigate, and the values are the text that will be displayed for each link.

# Documentation for support. File: 09-blade-components/02-button.md
---
title: Button Blade component
---

## Overview

The button component is used to render a clickable button that can perform an action:

```blade
<x-filament::button wire:click="openNewUserModal">
    New user
</x-filament::button>
```

## Using a button as an anchor link

By default, a button's underlying HTML tag is `<button>`. You can change it to be an `<a>` tag by using the `tag` attribute:

```blade
<x-filament::button
    href="https://filamentphp.com"
    tag="a"
>
    Filament
</x-filament::button>
```

## Setting the size of a button

By default, the size of a button is "medium". You can make it "extra small", "small", "large" or "extra large" by using the `size` attribute:

```blade
<x-filament::button size="xs">
    New user
</x-filament::button>

<x-filament::button size="sm">
    New user
</x-filament::button>

<x-filament::button size="lg">
    New user
</x-filament::button>

<x-filament::button size="xl">
    New user
</x-filament::button>
```

## Changing the color of a button

By default, the color of a button is "primary". You can change it to be `danger`, `gray`, `info`, `success` or `warning` by using the `color` attribute:

```blade
<x-filament::button color="danger">
    New user
</x-filament::button>

<x-filament::button color="gray">
    New user
</x-filament::button>

<x-filament::button color="info">
    New user
</x-filament::button>

<x-filament::button color="success">
    New user
</x-filament::button>

<x-filament::button color="warning">
    New user
</x-filament::button>
```

## Adding an icon to a button

You can add an [icon](https://blade-ui-kit.com/blade-icons?set=1#search) to a button by using the `icon` attribute:

```blade
<x-filament::button icon="heroicon-m-sparkles">
    New user
</x-filament::button>
```

You can also change the icon's position to be after the text instead of before it, using the `icon-position` attribute:

```blade
<x-filament::button
    icon="heroicon-m-sparkles"
    icon-position="after"
>
    New user
</x-filament::button>
```

## Making a button outlined

You can make a button use an "outlined" design using the `outlined` attribute:

```blade
<x-filament::button outlined>
    New user
</x-filament::button>
```

## Adding a tooltip to a button

You can add a tooltip to a button by using the `tooltip` attribute:

```blade
<x-filament::button tooltip="Register a user">
    New user
</x-filament::button>
```

## Adding a badge to a button

You can render a [badge](badge) on top of a button by using the `badge` slot:

```blade
<x-filament::button>
    Mark notifications as read
    
    <x-slot name="badge">
        3
    </x-slot>
</x-filament::button>
```

You can [change the color](badge#changing-the-color-of-the-badge) of the badge using the `badge-color` attribute:

```blade
<x-filament::button badge-color="danger">
    Mark notifications as read
    
    <x-slot name="badge">
        3
    </x-slot>
</x-filament::button>
```

# Documentation for support. File: 09-blade-components/02-checkbox.md
---
title: Checkbox Blade component
---

## Overview

You can use the checkbox component to render a checkbox input that can be used to toggle a boolean value:

```blade
<label>
    <x-filament::input.checkbox wire:model="isAdmin" />

    <span>
        Is Admin
    </span>
</label>
```

## Triggering the error state of the checkbox

The checkbox has special styling that you can use if it is invalid. To trigger this styling, you can use either Blade or Alpine.js.

To trigger the error state using Blade, you can pass the `valid` attribute to the component, which contains either true or false based on if the checkbox is valid or not:

```blade
<x-filament::input.checkbox
    wire:model="isAdmin"
    :valid="! $errors->has('isAdmin')"
/>
```

Alternatively, you can use an Alpine.js expression to trigger the error state, based on if it evaluates to `true` or `false`:

```blade
<div x-data="{ errors: ['isAdmin'] }">
    <x-filament::input.checkbox
        x-model="isAdmin"
        alpine-valid="! errors.includes('isAdmin')"
    />
</div>
```

# Documentation for support. File: 09-blade-components/02-dropdown.md
---
title: Dropdown Blade component
---

## Overview

The dropdown component allows you to render a dropdown menu with a button that triggers it:

```blade
<x-filament::dropdown>
    <x-slot name="trigger">
        <x-filament::button>
            More actions
        </x-filament::button>
    </x-slot>
    
    <x-filament::dropdown.list>
        <x-filament::dropdown.list.item wire:click="openViewModal">
            View
        </x-filament::dropdown.list.item>
        
        <x-filament::dropdown.list.item wire:click="openEditModal">
            Edit
        </x-filament::dropdown.list.item>
        
        <x-filament::dropdown.list.item wire:click="openDeleteModal">
            Delete
        </x-filament::dropdown.list.item>
    </x-filament::dropdown.list>
</x-filament::dropdown>
```

## Using a dropdown item as an anchor link

By default, a dropdown item's underlying HTML tag is `<button>`. You can change it to be an `<a>` tag by using the `tag` attribute:

```blade
<x-filament::dropdown.list.item
    href="https://filamentphp.com"
    tag="a"
>
    Filament
</x-filament::dropdown.list.item>
```

## Changing the color of a dropdown item

By default, the color of a dropdown item is "gray". You can change it to be `danger`, `info`, `primary`, `success` or `warning` by using the `color` attribute:

```blade
<x-filament::dropdown.list.item color="danger">
    Edit
</x-filament::dropdown.list.item>

<x-filament::dropdown.list.item color="info">
    Edit
</x-filament::dropdown.list.item>

<x-filament::dropdown.list.item color="primary">
    Edit
</x-filament::dropdown.list.item>

<x-filament::dropdown.list.item color="success">
    Edit
</x-filament::dropdown.list.item>

<x-filament::dropdown.list.item color="warning">
    Edit
</x-filament::dropdown.list.item>
```

## Adding an icon to a dropdown item

You can add an [icon](https://blade-ui-kit.com/blade-icons?set=1#search) to a dropdown item by using the `icon` attribute:

```blade
<x-filament::dropdown.list.item icon="heroicon-m-pencil">
    Edit
</x-filament::dropdown.list.item>
```

### Changing the icon color of a dropdown item

By default, the icon color uses the [same color as the item itself](#changing-the-color-of-a-dropdown-item). You can override it to be `danger`, `info`, `primary`, `success` or `warning` by using the `icon-color` attribute:

```blade
<x-filament::dropdown.list.item icon="heroicon-m-pencil" icon-color="danger">
    Edit
</x-filament::dropdown.list.item>

<x-filament::dropdown.list.item icon="heroicon-m-pencil" icon-color="info">
    Edit
</x-filament::dropdown.list.item>

<x-filament::dropdown.list.item icon="heroicon-m-pencil" icon-color="primary">
    Edit
</x-filament::dropdown.list.item>

<x-filament::dropdown.list.item icon="heroicon-m-pencil" icon-color="success">
    Edit
</x-filament::dropdown.list.item>

<x-filament::dropdown.list.item icon="heroicon-m-pencil" icon-color="warning">
    Edit
</x-filament::dropdown.list.item>
```

## Adding an image to a dropdown item

You can add a circular image to a dropdown item by using the `image` attribute:

```blade
<x-filament::dropdown.list.item image="https://filamentphp.com/dan.jpg">
    Dan Harrin
</x-filament::dropdown.list.item>
```

## Adding a badge to a dropdown item

You can render a [badge](badge) on top of a dropdown item by using the `badge` slot:

```blade
<x-filament::dropdown.list.item>
    Mark notifications as read
    
    <x-slot name="badge">
        3
    </x-slot>
</x-filament::dropdown.list.item>
```

You can [change the color](badge#changing-the-color-of-the-badge) of the badge using the `badge-color` attribute:

```blade
<x-filament::dropdown.list.item badge-color="danger">
    Mark notifications as read
    
    <x-slot name="badge">
        3
    </x-slot>
</x-filament::dropdown.list.item>
```

## Setting the placement of a dropdown

The dropdown may be positioned relative to the trigger button by using the `placement` attribute:

```blade
<x-filament::dropdown placement="top-start">
    {{-- Dropdown items --}}
</x-filament::dropdown>
```

## Setting the width of a dropdown

The dropdown may be set to a width by using the `width` attribute. Options correspond to [Tailwind's max-width scale](https://tailwindcss.com/docs/max-width). The options are `xs`, `sm`, `md`, `lg`, `xl`, `2xl`, `3xl`, `4xl`, `5xl`, `6xl` and `7xl`:

```blade
<x-filament::dropdown width="xs">
    {{-- Dropdown items --}}
</x-filament::dropdown>
```

## Controlling the maximum height of a dropdown

The dropdown content can have a maximum height using the `max-height` attribute, so that it scrolls. You can pass a [CSS length](https://developer.mozilla.org/en-US/docs/Web/CSS/length):

```blade
<x-filament::dropdown max-height="400px">
    {{-- Dropdown items --}}
</x-filament::dropdown>
```

# Documentation for support. File: 09-blade-components/02-fieldset.md
---
title: Fieldset Blade component
---

## Overview

You can use a fieldset to group multiple form fields together, optionally with a label:

```blade
<x-filament::fieldset>
    <x-slot name="label">
        Address
    </x-slot>
    
    {{-- Form fields --}}
</x-filament::fieldset>
```

# Documentation for support. File: 09-blade-components/02-icon-button.md
---
title: Icon button Blade component
---

## Overview

The button component is used to render a clickable button that can perform an action:

```blade
<x-filament::icon-button
    icon="heroicon-m-plus"
    wire:click="openNewUserModal"
    label="New label"
/>
```

## Using an icon button as an anchor link

By default, an icon button's underlying HTML tag is `<button>`. You can change it to be an `<a>` tag by using the `tag` attribute:

```blade
<x-filament::icon-button
    icon="heroicon-m-arrow-top-right-on-square"
    href="https://filamentphp.com"
    tag="a"
    label="Filament"
/>
```

## Setting the size of an icon button

By default, the size of an icon button is "medium". You can make it "extra small", "small", "large" or "extra large" by using the `size` attribute:

```blade
<x-filament::icon-button
    icon="heroicon-m-plus"
    size="xs"
    label="New label"
/>

<x-filament::icon-button
    icon="heroicon-m-plus"
    size="sm"
    label="New label"
/>

<x-filament::icon-button
    icon="heroicon-s-plus"
    size="lg"
    label="New label"
/>

<x-filament::icon-button
    icon="heroicon-s-plus"
    size="xl"
    label="New label"
/>
```

## Changing the color of an icon button

By default, the color of an icon button is "primary". You can change it to be `danger`, `gray`, `info`, `success` or `warning` by using the `color` attribute:

```blade
<x-filament::icon-button
    icon="heroicon-m-plus"
    color="danger"
    label="New label"
/>

<x-filament::icon-button
    icon="heroicon-m-plus"
    color="gray"
    label="New label"
/>

<x-filament::icon-button
    icon="heroicon-m-plus"
    color="info"
    label="New label"
/>

<x-filament::icon-button
    icon="heroicon-m-plus"
    color="success"
    label="New label"
/>

<x-filament::icon-button
    icon="heroicon-m-plus"
    color="warning"
    label="New label"
/>
```

## Adding a tooltip to an icon button

You can add a tooltip to an icon button by using the `tooltip` attribute:

```blade
<x-filament::icon-button
    icon="heroicon-m-plus"
    tooltip="Register a user"
    label="New label"
/>
```

## Adding a badge to an icon button

You can render a [badge](badge) on top of an icon button by using the `badge` slot:

```blade
<x-filament::icon-button
    icon="heroicon-m-x-mark"
    label="Mark notifications as read"
>
    <x-slot name="badge">
        3
    </x-slot>
</x-filament::icon-button>
```

You can [change the color](badge#changing-the-color-of-the-badge) of the badge using the `badge-color` attribute:

```blade
<x-filament::icon-button
    icon="heroicon-m-x-mark"
    label="Mark notifications as read"
    badge-color="danger"
>
    <x-slot name="badge">
        3
    </x-slot>
</x-filament::icon-button>
```

# Documentation for support. File: 09-blade-components/02-input-wrapper.md
---
title: Input wrapper Blade component
---

## Overview

The input wrapper component should be used as a wrapper around the [input](input) or [select](select) components. It provides a border and other elements such as a prefix or suffix.

```blade
<x-filament::input.wrapper>
    <x-filament::input
        type="text"
        wire:model="name"
    />
</x-filament::input.wrapper>

<x-filament::input.wrapper>
    <x-filament::input.select wire:model="status">
        <option value="draft">Draft</option>
        <option value="reviewing">Reviewing</option>
        <option value="published">Published</option>
    </x-filament::input.select>
</x-filament::input.wrapper>
```

## Triggering the error state of the input

The component has special styling that you can use if it is invalid. To trigger this styling, you can use either Blade or Alpine.js.

To trigger the error state using Blade, you can pass the `valid` attribute to the component, which contains either true or false based on if the input is valid or not:

```blade
<x-filament::input.wrapper :valid="! $errors->has('name')">
    <x-filament::input
        type="text"
        wire:model="name"
    />
</x-filament::input.wrapper>
```

Alternatively, you can use an Alpine.js expression to trigger the error state, based on if it evaluates to `true` or `false`:

```blade
<div x-data="{ errors: ['name'] }">
    <x-filament::input.wrapper alpine-valid="! errors.includes('name')">
        <x-filament::input
            type="text"
            wire:model="name"
        />
    </x-filament::input.wrapper>
</div>
```

## Disabling the input

To disable the input, you must also pass the `disabled` attribute to the wrapper component:

```blade
<x-filament::input.wrapper disabled>
    <x-filament::input
        type="text"
        wire:model="name"
        disabled
    />
</x-filament::input.wrapper>
```

## Adding affix text aside the input

You may place text before and after the input using the `prefix` and `suffix` slots:

```blade
<x-filament::input.wrapper>
    <x-slot name="prefix">
        https://
    </x-slot>

    <x-filament::input
        type="text"
        wire:model="domain"
    />

    <x-slot name="suffix">
        .com
    </x-slot>
</x-filament::input.wrapper>
```

### Using icons as affixes

You may place an [icon](https://blade-ui-kit.com/blade-icons?set=1#search) before and after the input using the `prefix-icon` and `suffix-icon` attributes:

```blade
<x-filament::input.wrapper suffix-icon="heroicon-m-globe-alt">
    <x-filament::input
        type="url"
        wire:model="domain"
    />
</x-filament::input.wrapper>
```

#### Setting the affix icon's color

Affix icons are gray by default, but you may set a different color using the `prefix-icon-color` and `affix-icon-color` attributes:

```blade
<x-filament::input.wrapper
    suffix-icon="heroicon-m-check-circle"
    suffix-icon-color="success"
>
    <x-filament::input
        type="url"
        wire:model="domain"
    />
</x-filament::input.wrapper>
```

# Documentation for support. File: 09-blade-components/02-input.md
---
title: Input Blade component
---

## Overview

The input component is a wrapper around the native `<input>` element. It provides a simple interface for entering a single line of text.

```blade
<x-filament::input.wrapper>
    <x-filament::input
        type="text"
        wire:model="name"
    />
</x-filament::input.wrapper>
```

To use the input component, you must wrap it in an "input wrapper" component, which provides a border and other elements such as a prefix or suffix. You can learn more about customizing the input wrapper component [here](input-wrapper).

# Documentation for support. File: 09-blade-components/02-link.md
---
title: Link Blade component
---

## Overview

The link component is used to render a clickable link that can perform an action:

```blade
<x-filament::link :href="route('users.create')">
    New user
</x-filament::link>
```

## Using a link as a button

By default, a link's underlying HTML tag is `<a>`. You can change it to be a `<button>` tag by using the `tag` attribute:

```blade
<x-filament::link
    wire:click="openNewUserModal"
    tag="button"
>
    New user
</x-filament::link>
```

## Setting the size of a link

By default, the size of a link is "medium". You can make it "small", "large", "extra large" or "extra extra large" by using the `size` attribute:

```blade
<x-filament::link size="sm">
    New user
</x-filament::link>

<x-filament::link size="lg">
    New user
</x-filament::link>

<x-filament::link size="xl">
    New user
</x-filament::link>

<x-filament::link size="2xl">
    New user
</x-filament::link>
```

## Setting the font weight of a link

By default, the font weight of links is `semibold`. You can make it `thin`, `extralight`, `light`, `normal`, `medium`, `bold`, `extrabold` or `black` by using the `weight` attribute:

```blade
<x-filament::link weight="thin">
    New user
</x-filament::link>

<x-filament::link weight="extralight">
    New user
</x-filament::link>

<x-filament::link weight="light">
    New user
</x-filament::link>

<x-filament::link weight="normal">
    New user
</x-filament::link>

<x-filament::link weight="medium">
    New user
</x-filament::link>

<x-filament::link weight="semibold">
    New user
</x-filament::link>
   
<x-filament::link weight="bold">
    New user
</x-filament::link>

<x-filament::link weight="black">
    New user
</x-filament::link> 
```

Alternatively, you can pass in a custom CSS class to define the weight:

```blade
<x-filament::link weight="md:font-[650]">
    New user
</x-filament::link>
```

## Changing the color of a link

By default, the color of a link is "primary". You can change it to be `danger`, `gray`, `info`, `success` or `warning` by using the `color` attribute:

```blade
<x-filament::link color="danger">
    New user
</x-filament::link>

<x-filament::link color="gray">
    New user
</x-filament::link>

<x-filament::link color="info">
    New user
</x-filament::link>

<x-filament::link color="success">
    New user
</x-filament::link>

<x-filament::link color="warning">
    New user
</x-filament::link>
```

## Adding an icon to a link

You can add an [icon](https://blade-ui-kit.com/blade-icons?set=1#search) to a link by using the `icon` attribute:

```blade
<x-filament::link icon="heroicon-m-sparkles">
    New user
</x-filament::link>
```

You can also change the icon's position to be after the text instead of before it, using the `icon-position` attribute:

```blade
<x-filament::link
    icon="heroicon-m-sparkles"
    icon-position="after"
>
    New user
</x-filament::link>
```

## Adding a tooltip to a link

You can add a tooltip to a link by using the `tooltip` attribute:

```blade
<x-filament::link tooltip="Register a user">
    New user
</x-filament::link>
```

## Adding a badge to a link

You can render a [badge](badge) on top of a link by using the `badge` slot:

```blade
<x-filament::link>
    Mark notifications as read

    <x-slot name="badge">
        3
    </x-slot>
</x-filament::link>
```

You can [change the color](badge#changing-the-color-of-the-badge) of the badge using the `badge-color` attribute:

```blade
<x-filament::link badge-color="danger">
    Mark notifications as read

    <x-slot name="badge">
        3
    </x-slot>
</x-filament::link>
```

# Documentation for support. File: 09-blade-components/02-loading-indicator.md
---
title: Loading indicator Blade component
---

## Overview

The loading indicator is an animated SVG that can be used to indicate that something is in progress:

```blade
<x-filament::loading-indicator class="h-5 w-5" />
```

# Documentation for support. File: 09-blade-components/02-modal.md
---
title: Modal Blade component
---

## Overview

The modal component is able to open a dialog window or slide-over with any content:

```blade
<x-filament::modal>
    <x-slot name="trigger">
        <x-filament::button>
            Open modal
        </x-filament::button>
    </x-slot>

    {{-- Modal content --}}
</x-filament::modal>
```

## Controlling a modal from JavaScript

You can use the `trigger` slot to render a button that opens the modal. However, this is not required. You have complete control over when the modal opens and closes through JavaScript. First, give the modal an ID so that you can reference it:

```blade
<x-filament::modal id="edit-user">
    {{-- Modal content --}}
</x-filament::modal>
```

Now, you can dispatch an `open-modal` or `close-modal` browser event, passing the modal's ID, which will open or close the modal. For example, from a Livewire component:

```php
$this->dispatch('open-modal', id: 'edit-user');
```

Or from Alpine.js:

```php
$dispatch('open-modal', { id: 'edit-user' })
```

## Adding a heading to a modal

You can add a heading to a modal by using the `heading` slot:

```blade
<x-filament::modal>
    <x-slot name="heading">
        Modal heading
    </x-slot>

    {{-- Modal content --}}
</x-filament::modal>
```

## Adding a description to a modal

You can add a description, below the heading, to a modal by using the `description` slot:

```blade
<x-filament::modal>
    <x-slot name="heading">
        Modal heading
    </x-slot>

    <x-slot name="description">
        Modal description
    </x-slot>

    {{-- Modal content --}}
</x-filament::modal>
```

## Adding an icon to a modal

You can add an [icon](https://blade-ui-kit.com/blade-icons?set=1#search) to a modal by using the `icon` attribute:

```blade
<x-filament::modal icon="heroicon-o-information-circle">
    <x-slot name="heading">
        Modal heading
    </x-slot>

    {{-- Modal content --}}
</x-filament::modal>
```

By default, the color of an icon is "primary". You can change it to be `danger`, `gray`, `info`, `success` or `warning` by using the `icon-color` attribute:

```blade
<x-filament::modal
    icon="heroicon-o-exclamation-triangle"
    icon-color="danger"
>
    <x-slot name="heading">
        Modal heading
    </x-slot>

    {{-- Modal content --}}
</x-filament::modal>
```

## Adding a footer to a modal

You can add a footer to a modal by using the `footer` slot:

```blade
<x-filament::modal>
    {{-- Modal content --}}
    
    <x-slot name="footer">
        {{-- Modal footer content --}}
    </x-slot>
</x-filament::modal>
```

Alternatively, you can add actions into the footer by using the `footerActions` slot:

```blade
<x-filament::modal>
    {{-- Modal content --}}
    
    <x-slot name="footerActions">
        {{-- Modal footer actions --}}
    </x-slot>
</x-filament::modal>
```

## Changing the modal's alignment

By default, modal content will be aligned to the start, or centered if the modal is `xs` or `sm` in [width](#changing-the-modal-width). If you wish to change the alignment of content in a modal, you can use the `alignment` attribute and pass it `start` or `center`:

```blade
<x-filament::modal alignment="center">
    {{-- Modal content --}}
</x-filament::modal>
```

## Using a slide-over instead of a modal

You can open a "slide-over" dialog instead of a modal by using the `slide-over` attribute:

```blade
<x-filament::modal slide-over>
    {{-- Slide-over content --}}
</x-filament::modal>
```

## Making the modal header sticky

The header of a modal scrolls out of view with the modal content when it overflows the modal size. However, slide-overs have a sticky modal that's always visible. You may control this behavior using the `sticky-header` attribute:

```blade
<x-filament::modal sticky-header>
    <x-slot name="heading">
        Modal heading
    </x-slot>

    {{-- Modal content --}}
</x-filament::modal>
```

## Making the modal footer sticky

The footer of a modal is rendered inline after the content by default. Slide-overs, however, have a sticky footer that always shows when scrolling the content. You may enable this for a modal too using the `sticky-footer` attribute:

```blade
<x-filament::modal sticky-footer>
    {{-- Modal content --}}
    
    <x-slot name="footer">
        {{-- Modal footer content --}}
    </x-slot>
</x-filament::modal>
```

## Changing the modal width

You can change the width of the modal by using the `width` attribute. Options correspond to [Tailwind's max-width scale](https://tailwindcss.com/docs/max-width). The options are `xs`, `sm`, `md`, `lg`, `xl`, `2xl`, `3xl`, `4xl`, `5xl`, `6xl`, `7xl`, and `screen`:

```blade
<x-filament::modal width="5xl">
    {{-- Modal content --}}
</x-filament::modal>
```

## Closing the modal by clicking away

By default, when you click away from a modal, it will close itself. If you wish to disable this behavior for a specific action, you can use the `close-by-clicking-away` attribute:

```blade
<x-filament::modal :close-by-clicking-away="false">
    {{-- Modal content --}}
</x-filament::modal>
```

## Closing the modal by escaping

By default, when you press escape on a modal, it will close itself. If you wish to disable this behavior for a specific action, you can use the `close-by-escaping` attribute:

```blade
<x-filament::modal :close-by-escaping="false">
    {{-- Modal content --}}
</x-filament::modal>
```

## Hiding the modal close button

By default, modals with a header have a close button in the top right corner. You can remove the close button from the modal by using the `close-button` attribute:

```blade
<x-filament::modal :close-button="false">
    <x-slot name="heading">
        Modal heading
    </x-slot>

    {{-- Modal content --}}
</x-filament::modal>
```

## Preventing the modal from autofocusing

By default, modals will autofocus on the first focusable element when opened. If you wish to disable this behavior, you can use the `autofocus` attribute:

```blade
<x-filament::modal :autofocus="false">
    {{-- Modal content --}}
</x-filament::modal>
```

## Disabling the modal trigger button

By default, the trigger button will open the modal even if it is disabled, since the click event listener is registered on a wrapping element of the button itself. If you want to prevent the modal from opening, you should also use the `disabled` attribute on the trigger slot:

```blade
<x-filament::modal>
    <x-slot name="trigger" disabled>
        <x-filament::button :disabled="true">
            Open modal
        </x-filament::button>
    </x-slot>
    {{-- Modal content --}}
</x-filament::modal>
```


# Documentation for support. File: 09-blade-components/02-pagination.md
---
title: Pagination Blade component
---

## Overview

The pagination component can be used in a Livewire Blade view only. It can render a list of paginated links:

```php
use App\Models\User;
use Illuminate\Contracts\View\View;
use Livewire\Component;

class ListUsers extends Component
{
    // ...
    
    public function render(): View
    {
        return view('livewire.list-users', [
            'users' => User::query()->paginate(10),
        ]);
    }
}
```

```blade
<x-filament::pagination :paginator="$users" />
```

Alternatively, you can use simple pagination or cursor pagination, which will just render a "previous" and "next" button:

```php
use App\Models\User;

User::query()->simplePaginate(10)
User::query()->cursorPaginate(10)
```

## Allowing the user to customize the number of items per page

You can allow the user to customize the number of items per page by passing an array of options to the `page-options` attribute. You must also define a Livewire property where the user's selection will be stored:

```php
use App\Models\User;
use Illuminate\Contracts\View\View;
use Livewire\Component;

class ListUsers extends Component
{
    public int | string $perPage = 10;
    
    // ...
    
    public function render(): View
    {
        return view('livewire.list-users', [
            'users' => User::query()->paginate($this->perPage),
        ]);
    }
}
```

```blade
<x-filament::pagination
    :paginator="$users"
    :page-options="[5, 10, 20, 50, 100, 'all']"
    :current-page-option-property="perPage"
/>
```

## Displaying links to the first and the last page

Extreme links are the first and last page links. You can add them by passing the `extreme-links` attribute to the component:

```blade
<x-filament::pagination
    :paginator="$users"
    extreme-links
/>
```

# Documentation for support. File: 09-blade-components/02-section.md
---
title: Section Blade component
---

## Overview

A section can be used to group content together, with an optional heading:

```blade
<x-filament::section>
    <x-slot name="heading">
        User details
    </x-slot>

    {{-- Content --}}
</x-filament::section>
```

## Adding a description to the section

You can add a description below the heading to the section by using the `description` slot:

```blade
<x-filament::section>
    <x-slot name="heading">
        User details
    </x-slot>

    <x-slot name="description">
        This is all the information we hold about the user.
    </x-slot>

    {{-- Content --}}
</x-filament::section>
```

## Adding an icon to the section header

You can add an [icon](https://blade-ui-kit.com/blade-icons?set=1#search) to a section by using the `icon` attribute:

```blade
<x-filament::section icon="heroicon-o-user">
    <x-slot name="heading">
        User details
    </x-slot>

    {{-- Content --}}
</x-filament::section>
```

### Changing the color of the section icon

By default, the color of the section icon is "gray". You can change it to be `danger`, `info`, `primary`, `success` or `warning` by using the `icon-color` attribute:

```blade
<x-filament::section
    icon="heroicon-o-user"
    icon-color="info"
>
    <x-slot name="heading">
        User details
    </x-slot>

    {{-- Content --}}
</x-filament::section>
```

### Changing the size of the section icon

By default, the size of the section icon is "large". You can change it to be "small" or "medium" by using the `icon-size` attribute:

```blade
<x-filament::section
    icon="heroicon-m-user"
    icon-size="sm"
>
    <x-slot name="heading">
        User details
    </x-slot>

    {{-- Content --}}
</x-filament::section>

<x-filament::section
    icon="heroicon-m-user"
    icon-size="md"
>
    <x-slot name="heading">
        User details
    </x-slot>

    {{-- Content --}}
</x-filament::section>
```

## Adding content to the end of the header

You may render additional content at the end of the header, next to the heading and description, using the `headerEnd` slot:

```blade
<x-filament::section>
    <x-slot name="heading">
        User details
    </x-slot>

    <x-slot name="headerEnd">
        {{-- Input to select the user's ID --}}
    </x-slot>

    {{-- Content --}}
</x-filament::section>
```

## Making a section collapsible

You can make the content of a section collapsible by using the `collapsible` attribute:

```blade
<x-filament::section collapsible>
    <x-slot name="heading">
        User details
    </x-slot>

    {{-- Content --}}
</x-filament::section>
```

### Making a section collapsed by default

You can make a section collapsed by default by using the `collapsed` attribute:

```blade
<x-filament::section
    collapsible
    collapsed
>
    <x-slot name="heading">
        User details
    </x-slot>

    {{-- Content --}}
</x-filament::section>
```

### Persisting collapsed sections

You can persist whether a section is collapsed in local storage using the `persist-collapsed` attribute, so it will remain collapsed when the user refreshes the page. You will also need a unique `id` attribute to identify the section from others, so that each section can persist its own collapse state:

```blade
<x-filament::section
    collapsible
    collapsed
    persist-collapsed
    id="user-details"
>
    <x-slot name="heading">
        User details
    </x-slot>

    {{-- Content --}}
</x-filament::section>
```

## Adding the section header aside the content instead of above it

You can change the position of the section header to be aside the content instead of above it by using the `aside` attribute:

```blade
<x-filament::section aside>
    <x-slot name="heading">
        User details
    </x-slot>

    {{-- Content --}}
</x-filament::section>
```

### Positioning the content before the header

You can change the position of the content to be before the header instead of after it by using the `content-before` attribute:

```blade
<x-filament::section
    aside
    content-before
>
    <x-slot name="heading">
        User details
    </x-slot>

    {{-- Content --}}
</x-filament::section>
```

# Documentation for support. File: 09-blade-components/02-select.md
---
title: Select Blade component
---

## Overview

The select component is a wrapper around the native `<select>` element. It provides a simple interface for selecting a single value from a list of options:

```blade
<x-filament::input.wrapper>
    <x-filament::input.select wire:model="status">
        <option value="draft">Draft</option>
        <option value="reviewing">Reviewing</option>
        <option value="published">Published</option>
    </x-filament::input.select>
</x-filament::input.wrapper>
```

To use the select component, you must wrap it in an "input wrapper" component, which provides a border and other elements such as a prefix or suffix. You can learn more about customizing the input wrapper component [here](input-wrapper).

# Documentation for support. File: 09-blade-components/02-tabs.md
---
title: Tabs Blade component
---

## Overview

The tabs component allows you to render a set of tabs, which can be used to toggle between multiple sections of content:

```blade
<x-filament::tabs label="Content tabs">
    <x-filament::tabs.item>
        Tab 1
    </x-filament::tabs.item>

    <x-filament::tabs.item>
        Tab 2
    </x-filament::tabs.item>

    <x-filament::tabs.item>
        Tab 3
    </x-filament::tabs.item>
</x-filament::tabs>
```

## Triggering the active state of the tab

By default, tabs do not appear "active". To make a tab appear active, you can use the `active` attribute:

```blade
<x-filament::tabs>
    <x-filament::tabs.item active>
        Tab 1
    </x-filament::tabs.item>

    {{-- Other tabs --}}
</x-filament::tabs>
```

You can also use the `active` attribute to make a tab appear active conditionally:

```blade
<x-filament::tabs>
    <x-filament::tabs.item
        :active="$activeTab === 'tab1'"
        wire:click="$set('activeTab', 'tab1')"
    >
        Tab 1
    </x-filament::tabs.item>

    {{-- Other tabs --}}
</x-filament::tabs>
```

Or you can use the `alpine-active` attribute to make a tab appear active conditionally using Alpine.js:

```blade
<x-filament::tabs x-data="{ activeTab: 'tab1' }">
    <x-filament::tabs.item
        alpine-active="activeTab === 'tab1'"
        x-on:click="activeTab = 'tab1'"
    >
        Tab 1
    </x-filament::tabs.item>

    {{-- Other tabs --}}
</x-filament::tabs>
```

## Setting a tab icon

Tabs may have an [icon](https://blade-ui-kit.com/blade-icons?set=1#search), which you can set using the `icon` attribute:

```blade
<x-filament::tabs>
    <x-filament::tabs.item icon="heroicon-m-bell">
        Notifications
    </x-filament::tabs.item>

    {{-- Other tabs --}}
</x-filament::tabs>
```

### Setting the tab icon position

The icon of the tab may be positioned before or after the label using the `icon-position` attribute:

```blade
<x-filament::tabs>
    <x-filament::tabs.item
        icon="heroicon-m-bell"
        icon-position="after"
    >
        Notifications
    </x-filament::tabs.item>

    {{-- Other tabs --}}
</x-filament::tabs>
```

## Setting a tab badge

Tabs may have a [badge](badge), which you can set using the `badge` slot:

```blade
<x-filament::tabs>
    <x-filament::tabs.item>
        Notifications

        <x-slot name="badge">
            5
        </x-slot>
    </x-filament::tabs.item>

    {{-- Other tabs --}}
</x-filament::tabs>
```

## Using a tab as an anchor link

By default, a tab's underlying HTML tag is `<button>`. You can change it to be an `<a>` tag by using the `tag` attribute:

```blade
<x-filament::tabs>
    <x-filament::tabs.item
        :href="route('notifications')"
        tag="a"
    >
        Notifications
    </x-filament::tabs.item>

    {{-- Other tabs --}}
</x-filament::tabs>
```

# Documentation for support. File: 09-stubs.md
---
title: Stubs
---

## Publishing the stubs

If you would like to customize the files that are generated by Filament, you can do so by publishing the "stubs" to your application. These are template files that you can modify to your own preferences.

To publish the stubs to the `stubs/filament` directory, run the following command:

```bash
php artisan vendor:publish --tag=filament-stubs
```

# Documentation for support. File: 10-support.md
---
title: Support & Help
---

> We offer a variety of support options, mostly free of charge. If you need help, the community is here for you.

## Discord

We are fortunate to have a growing community of Filament users that help each other out on our [Discord server](https://filamentphp.com/discord). Join now, its free!
We also have many dedicated channels in different languages. Currently, we have channels for the following languages:

- [#ar](https://discord.com/channels/883083792112300104/961199444789973024) - Arabic 🇸🇦
- [#de](https://discord.com/channels/883083792112300104/998221767850070057) - German 🇩🇪
- [#es](https://discord.com/channels/883083792112300104/1049794522181275749) - Spanish 🇪🇸
- [#fa](https://discord.com/channels/883083792112300104/1042736860826443807) - Farsi 🇮🇷
- [#fr](https://discord.com/channels/883083792112300104/978572814317682688) - French 🇫🇷
- [#id](https://discord.com/channels/883083792112300104/1051444835254538271) - Indonesian 🇮🇩
- [#it](https://discord.com/channels/883083792112300104/979015654675996672) - Italian 🇮🇹
- [#nl](https://discord.com/channels/883083792112300104/998685582031061102) - Dutch 🇳🇱
- [#pt-br](https://discord.com/channels/883083792112300104/966832715536162846) - Portuguese (Brazil) 🇧🇷
- [#tr](https://discord.com/channels/883083792112300104/988729996803702794) - Turkish 🇹🇷
- [#ko](https://discord.com/channels/883083792112300104/1221712398017232926) - Korean 🇰🇷

If you are missing a channel for your language, please let us know and we will create one for you.

## GitHub

You can also reach out to us on our [GitHub community forum](https://github.com/filamentphp/filament/discussions). Where our community members and maintainers are happy to help you out.

If you find a bug, you can open an [issue](https://github.com/filamentphp/filament/issues/new/choose), and even donate to the bug fix by using the link automatically added to the bottom of every new issue description.

If you have a feature request, you can create a discussion on GitHub [following these instructions](contributing#development-of-new-features). If you are not planning to contribute the feature yourself but the core team adds it to the roadmap, an issue will be created which you are able to fast-track its development by donating money to it using the link added to the bottom of the issue description.

## One-on-one private support & consulting (paid)

If you're looking for dedicated help with your Filament project, we're here for you. Whether you're a solo developer or running a large company, we provide support and development services that fit your needs. More information can be found on our [consulting page](https://filamentphp.com/consulting).

## Laracasts

[Laracasts](https://laracasts.com) has a dedicated [Filament help section](https://laracasts.com/discuss/channels/filament) where you can ask questions and get help from their community.
Additionally on Laracasts you can find two excellent courses about Filament:

- [Rapid Laravel Apps With Filament](https://laracasts.com/series/rapid-laravel-development-with-filament)
- [Build Advanced Components for Filament](https://laracasts.com/series/build-advanced-components-for-filament) by one of the creators of Filament.

> An active subscription may be required to access these parts of these courses.

## Google

Since we make use of [AnswerOverflow](https://www.answeroverflow.com/c/883083792112300104) on our [Discord](#discord) server, you are often one Google search away from finding an answer to your question or at least a hint on how to solve your problem. You may also find results from [GitHub](#github), the [Laracasts forum](#laracasts), or even Stack Overflow.

## Helping others

We would like to encourage you to join any of the above platforms and help yourself and our community out. Additionally, we would like to encourage you to [contribute](https://filamentphp.com/docs/3.x/support/contributing) to Filament itself. We are always looking for new contributors to help us improve Filament.

