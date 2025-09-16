# Documentation for widgets. File: 01-overview.md
---
title: Overview
---

## Introduction

Filament allows you to build dynamic dashboards, comprised of "widgets". Each widget is an element on the dashboard that displays data in a specific way. For example, you can display [stats](stats-overview), [chart](charts), or a [table](#table-widgets).

## Creating a widget

To create a widget, you can use the `make:filament-widget` command:

```bash
php artisan make:filament-widget MyWidget
```

This command will ask you which type of widget you want to create. You can choose from the following options:

- **Custom**: A custom widget that you can build from scratch.
- **Chart**: A widget that displays a [chart](charts).
- **Stats overview**: A widget that displays [statistics](stats-overview).
- **Table**: A widget that displays a [table](#table-widgets).

## Sorting widgets

Each widget class contains a `$sort` property that may be used to change its order on the page, relative to other widgets:

```php
protected static ?int $sort = 2;
```

## Customizing the dashboard page

If you want to customize the dashboard class, for example, to [change the number of widget columns](#customizing-the-widgets-grid), create a new file at `app/Filament/Pages/Dashboard.php`:

```php
<?php

namespace App\Filament\Pages;

use Filament\Pages\Dashboard as BaseDashboard;

class Dashboard extends BaseDashboard
{
    // ...
}
```

Finally, remove the original `Dashboard` class from [configuration file](../panel-configuration):

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->discoverPages(in: app_path('Filament/Pages'), for: 'App\\Filament\\Pages')
        ->pages([]);
}
```

If you don't discover pages with `discoverPages()` in the directory you created the new dashboard class, you should manually register the class in the `pages()` method:

```php
use App\Filament\Pages\Dashboard;
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->pages([
            Dashboard::class,
        ]);
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

The primary dashboard shown to a user is the first one they have access to (controlled by [`canAccess()` method](../navigation/custom-pages#authorization)), according to the defined navigation sort order.

The default sort order for dashboards is `-2`. You can control the sort order of custom dashboards with `$navigationSort`:

```php
protected static ?int $navigationSort = 15;
```

### Customizing the widgets' grid

You may change how many grid columns are used to display widgets.

Firstly, you must [replace the original Dashboard page](#customizing-the-dashboard-page).

Now, in your new `app/Filament/Pages/Dashboard.php` file, you may override the `getColumns()` method to return a number of grid columns to use:

```php
public function getColumns(): int | array
{
    return 2;
}
```

#### Responsive widgets grid

You may wish to change the number of widget grid columns based on the responsive [breakpoint](https://tailwindcss.com/docs/responsive-design#overview) of the browser. You can do this using an array that contains the number of columns that should be used at each breakpoint:

```php
public function getColumns(): int | array
{
    return [
        'md' => 4,
        'xl' => 5,
    ];
}
```

This pairs well with [responsive widget widths](#responsive-widget-widths).

#### Customizing widget width

You may customize the width of a widget using the `$columnSpan` property. You may use a number between 1 and 12 to indicate how many columns the widget should span, or `full` to make it occupy the full width of the page:

```php
protected int | string | array $columnSpan = 'full';
```

##### Responsive widget widths

You may wish to change the widget width based on the responsive [breakpoint](https://tailwindcss.com/docs/responsive-design#overview) of the browser. You can do this using an array that contains the number of columns that the widget should occupy at each breakpoint:

```php
protected int | string | array $columnSpan = [
    'md' => 2,
    'xl' => 3,
];
```

This is especially useful when using a [responsive widgets grid](#responsive-widgets-grid).

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

You may now [customize the table](../tables) by editing the widget file.

## Custom widgets

To get started building a `BlogPostsOverview` widget:

```bash
php artisan make:filament-widget BlogPostsOverview
```

This command will create two files - a widget class in the `/Widgets` directory of the Filament directory, and a view in the `/widgets` directory of the Filament views directory.

The class is a [Livewire component](https://livewire.laravel.com/docs/components), so any Livewire features are available to you. The Blade view can contain any HTML you like, and you can access any public Livewire properties in the view. You can also access the Livewire component instance in the view using `$this`.

## Filtering widget data

You may add a form to the dashboard that allows the user to filter the data displayed across all widgets. When the filters are updated, the widgets will be reloaded with the new data.

Firstly, you must [replace the original Dashboard page](#customizing-the-dashboard-page).

Now, in your new `app/Filament/Pages/Dashboard.php` file, you may add the `HasFiltersForm` trait, and add the `filtersForm()` method to return form components:

```php
use Filament\Forms\Components\DatePicker;
use Filament\Pages\Dashboard as BaseDashboard;
use Filament\Pages\Dashboard\Concerns\HasFiltersForm;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class Dashboard extends BaseDashboard
{
    use HasFiltersForm;

    public function filtersForm(Schema $schema): Schema
    {
        return $schema
            ->components([
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

In widget classes that require data from the filters, you need to add the `InteractsWithPageFilters` trait, which will allow you to use the `$this->pageFilters` property to access the raw data from the filters form:

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
        $startDate = $this->pageFilters['startDate'] ?? null;
        $endDate = $this->pageFilters['endDate'] ?? null;

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

The `$this->pageFilters` array will always reflect the current form data. Please note that this data is not validated, as it is available live and not intended to be used for anything other than querying the database. You must ensure that the data is valid before using it. In this example, we check if the start date is set before using it in the query.

### Filtering widget data using an action modal

Alternatively, you can swap out the filters form for an action modal, that can be opened by clicking a button in the header of the page. There are many benefits to using this approach:

- The filters form is not always visible, which allows you to use the full height of the page for widgets.
- The filters do not update the widgets until the user clicks the "Apply" button, which means that the widgets are not reloaded until the user is ready. This can improve performance if the widgets are expensive to load.
- Validation can be performed on the filters form, which means that the widgets can rely on the fact that the data is valid - the user cannot submit the form until it is. Canceling the modal will discard the user's changes.

To use an action modal instead of a filters form, you can use the `HasFiltersAction` trait instead of `HasFiltersForm`. Then, register the `FilterAction` class as an action in `getHeaderActions()`:

```php
use Filament\Forms\Components\DatePicker;
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
                ->schema([
                    DatePicker::make('startDate'),
                    DatePicker::make('endDate'),
                    // ...
                ]),
        ];
    }
}
```

Handling data from the filter action is the same as handling data from the filters header form, except that the data is validated before being passed to the widget. The `InteractsWithPageFilters` trait still applies.

### Persisting widget filters in the user's session

By default, the dashboard filters applied will persist in the user's session between page loads. To disable this, override the `$persistsFiltersInSession` property in the dashboard page class:

```php
use Filament\Pages\Dashboard as BaseDashboard;
use Filament\Pages\Dashboard\Concerns\HasFiltersForm;

class Dashboard extends BaseDashboard
{
    use HasFiltersForm;

    protected bool $persistsFiltersInSession = false;
}
```

Alternatively, override the `persistsFiltersInSession()` method in the dashboard page class:

```php
use Filament\Pages\Dashboard as BaseDashboard;
use Filament\Pages\Dashboard\Concerns\HasFiltersForm;

class Dashboard extends BaseDashboard
{
    use HasFiltersForm;

    public function persistsFiltersInSession(): bool
    {
        return false;
    }
}
```

## Disabling the default widgets

By default, two widgets are displayed on the dashboard. These widgets can be disabled by updating the `widgets()` array of the [configuration](../panel-configuration):

```php
use Filament\Panel;

public function panel(Panel $panel): Panel
{
    return $panel
        // ...
        ->widgets([]);
}
```

# Documentation for widgets. File: 02-stats-overview.md
---
title: Stats overview widgets
---

## Introduction

Filament comes with a "stats overview" widget template, which you can use to display a number of different stats in a single widget, without needing to write a custom view.

Start by creating a widget with the command:

```bash
php artisan make:filament-widget StatsOverview --stats-overview
```

This command will create a new `StatsOverview.php` file. Open it, and return `Stat` instances from the `getStats()` method:

```php
<?php

namespace App\Filament\Widgets;

use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class StatsOverview extends BaseWidget
{
    protected function getStats(): array
    {
        return [
            Stat::make('Unique views', '192.1k'),
            Stat::make('Bounce rate', '21%'),
            Stat::make('Average time on page', '3:12'),
        ];
    }
}
```

Now, check out your widget in the dashboard.

## Adding a description and icon to a stat

You may add a `description()` to provide additional information, along with a `descriptionIcon()`:

```php
use Filament\Widgets\StatsOverviewWidget\Stat;

protected function getStats(): array
{
    return [
        Stat::make('Unique views', '192.1k')
            ->description('32k increase')
            ->descriptionIcon('heroicon-m-arrow-trending-up'),
        Stat::make('Bounce rate', '21%')
            ->description('7% decrease')
            ->descriptionIcon('heroicon-m-arrow-trending-down'),
        Stat::make('Average time on page', '3:12')
            ->description('3% increase')
            ->descriptionIcon('heroicon-m-arrow-trending-up'),
    ];
}
```

The `descriptionIcon()` method also accepts a second parameter to put the icon before the description instead of after it:

```php
use Filament\Support\Enums\IconPosition;
use Filament\Widgets\StatsOverviewWidget\Stat;

Stat::make('Unique views', '192.1k')
    ->description('32k increase')
    ->descriptionIcon('heroicon-m-arrow-trending-up', IconPosition::Before)
```

## Changing the color of the stat

You may also give stats a [color](../styling/colors):

```php
use Filament\Widgets\StatsOverviewWidget\Stat;

protected function getStats(): array
{
    return [
        Stat::make('Unique views', '192.1k')
            ->description('32k increase')
            ->descriptionIcon('heroicon-m-arrow-trending-up')
            ->color('success'),
        Stat::make('Bounce rate', '21%')
            ->description('7% increase')
            ->descriptionIcon('heroicon-m-arrow-trending-down')
            ->color('danger'),
        Stat::make('Average time on page', '3:12')
            ->description('3% increase')
            ->descriptionIcon('heroicon-m-arrow-trending-up')
            ->color('success'),
    ];
}
```

## Adding extra HTML attributes to a stat

You may also pass extra HTML attributes to stats using `extraAttributes()`:

```php
use Filament\Widgets\StatsOverviewWidget\Stat;

protected function getStats(): array
{
    return [
        Stat::make('Processed', '192.1k')
            ->color('success')
            ->extraAttributes([
                'class' => 'cursor-pointer',
                'wire:click' => "\$dispatch('setStatusFilter', { filter: 'processed' })",
            ]),
        // ...
    ];
}
```

In this example, we are deliberately escaping the `$` in `$dispatch()` since this needs to be passed directly to the HTML, it is not a PHP variable.

## Adding a chart to a stat

You may also add or chain a `chart()` to each stat to provide historical data. The `chart()` method accepts an array of data points to plot:

```php
use Filament\Widgets\StatsOverviewWidget\Stat;

protected function getStats(): array
{
    return [
        Stat::make('Unique views', '192.1k')
            ->description('32k increase')
            ->descriptionIcon('heroicon-m-arrow-trending-up')
            ->chart([7, 2, 10, 3, 15, 4, 17])
            ->color('success'),
        // ...
    ];
}
```

## Live updating stats (polling)

By default, stats overview widgets refresh their data every 5 seconds.

To customize this, you may override the `$pollingInterval` property on the class to a new interval:

```php
protected ?string $pollingInterval = '10s';
```

Alternatively, you may disable polling altogether:

```php
protected ?string $pollingInterval = null;
```

## Disabling lazy loading

By default, widgets are lazy-loaded. This means that they will only be loaded when they are visible on the page.

To disable this behavior, you may override the `$isLazy` property on the widget class:

```php
protected static bool $isLazy = false;
```

## Adding a heading and description

You may also add heading and description text above the widget by overriding the `$heading` and `$description` properties:

```php
protected ?string $heading = 'Analytics';

protected ?string $description = 'An overview of some analytics.';
```

If you need to dynamically generate the heading or description text, you can instead override the `getHeading()` and `getDescription()` methods:

```php
protected function getHeading(): ?string
{
    return 'Analytics';
}

protected function getDescription(): ?string
{
    return 'An overview of some analytics.';
}
```

# Documentation for widgets. File: 03-charts.md
---
title: Chart widgets
---
import Aside from "@components/Aside.astro"

## Introduction

Filament comes with many "chart" widget templates, which you can use to display real-time, interactive charts.

Start by creating a widget with the command:

```bash
php artisan make:filament-widget BlogPostsChart --chart
```

There is a single `ChartWidget` class that is used for all charts. The type of chart is set by the `getType()` method. In this example, that method returns the string `'line'`.

The `protected ?string $heading` variable is used to set the heading that describes the chart. If you need to set the heading dynamically, you can override the `getHeading()` method.

The `getData()` method is used to return an array of datasets and labels. Each dataset is a labeled array of points to plot on the chart, and each label is a string. This structure is identical to the [Chart.js](https://www.chartjs.org/docs) library, which Filament uses to render charts. You may use the [Chart.js documentation](https://www.chartjs.org/docs) to fully understand the possibilities to return from `getData()`, based on the chart type.

```php
<?php

namespace App\Filament\Widgets;

use Filament\Widgets\ChartWidget;

class BlogPostsChart extends ChartWidget
{
    protected ?string $heading = 'Blog Posts';

    protected function getData(): array
    {
        return [
            'datasets' => [
                [
                    'label' => 'Blog posts created',
                    'data' => [0, 10, 5, 2, 21, 32, 45, 74, 65, 45, 77, 89],
                ],
            ],
            'labels' => ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
        ];
    }

    protected function getType(): string
    {
        return 'line';
    }
}
```

Now, check out your widget in the dashboard.

## Available chart types

Below is a list of available chart widget classes which you may extend, and their corresponding [Chart.js](https://www.chartjs.org/docs) documentation page, for inspiration on what to return from `getData()`:

- Bar chart - [Chart.js documentation](https://www.chartjs.org/docs/latest/charts/bar)
- Bubble chart - [Chart.js documentation](https://www.chartjs.org/docs/latest/charts/bubble)
- Doughnut chart - [Chart.js documentation](https://www.chartjs.org/docs/latest/charts/doughnut)
- Line chart - [Chart.js documentation](https://www.chartjs.org/docs/latest/charts/line)
- Pie chart - [Chart.js documentation](https://www.chartjs.org/docs/latest/charts/doughnut.html#pie)
- Polar area chart - [Chart.js documentation](https://www.chartjs.org/docs/latest/charts/polar)
- Radar chart - [Chart.js documentation](https://www.chartjs.org/docs/latest/charts/radar)
- Scatter chart - [Chart.js documentation](https://www.chartjs.org/docs/latest/charts/scatter)

## Customizing the chart color

You can customize the [color](../styling/colors) of the chart data by setting the `$color` property:

```php
protected string $color = 'info';
```

If you're looking to customize the color further, or use multiple colors across multiple datasets, you can still make use of Chart.js's [color options](https://www.chartjs.org/docs/latest/general/colors.html) in the data:

```php
protected function getData(): array
{
    return [
        'datasets' => [
            [
                'label' => 'Blog posts created',
                'data' => [0, 10, 5, 2, 21, 32, 45, 74, 65, 45, 77, 89],
                'backgroundColor' => '#36A2EB',
                'borderColor' => '#9BD0F5',
            ],
        ],
        'labels' => ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
    ];
}
```

## Generating chart data from an Eloquent model

To generate chart data from an Eloquent model, Filament recommends that you install the `flowframe/laravel-trend` package. You can view the [documentation](https://github.com/Flowframe/laravel-trend).

Here is an example of generating chart data from a model using the `laravel-trend` package:

```php
use Flowframe\Trend\Trend;
use Flowframe\Trend\TrendValue;

protected function getData(): array
{
    $data = Trend::model(BlogPost::class)
        ->between(
            start: now()->startOfYear(),
            end: now()->endOfYear(),
        )
        ->perMonth()
        ->count();

    return [
        'datasets' => [
            [
                'label' => 'Blog posts',
                'data' => $data->map(fn (TrendValue $value) => $value->aggregate),
            ],
        ],
        'labels' => $data->map(fn (TrendValue $value) => $value->date),
    ];
}
```

## Filtering chart data

### Basic Select filter

You can set up chart filters to change the data that is presented. Commonly, this is used to change the time period that chart data is rendered for.

To set a default filter value, set the `$filter` property:

```php
public ?string $filter = 'today';
```

Then, define the `getFilters()` method to return an array of values and labels for your filter:

```php
protected function getFilters(): ?array
{
    return [
        'today' => 'Today',
        'week' => 'Last week',
        'month' => 'Last month',
        'year' => 'This year',
    ];
}
```

You can use the active filter value within your `getData()` method:

```php
protected function getData(): array
{
    $activeFilter = $this->filter;

    // ...
}
```

### Custom filters

You can use [schema components](../schemas) to build custom filters for your chart widget. This approach offers a more flexible way to define filters.

To get started, use the `HasFiltersSchema` trait and implement the `filtersSchema()` method:

```php
use Filament\Forms\Components\DatePicker;
use Filament\Schemas\Schema;
use Filament\Widgets\ChartWidget\Concerns\HasFiltersSchema;

class BlogPostsChart extends ChartWidget
{
    use HasFiltersSchema;
    
    // ...
    
    public function filtersSchema(Schema $schema): Schema
    {
        return $schema->components([
            DatePicker::make('startDate')
                ->default(now()->subDays(30)),
            DatePicker::make('endDate')
                ->default(now()),
        ]);
    }
}
```

The filter values are accessible via the `$this->filters` array. You can use these values inside your `getData()` method:

```php
protected function getData(): array
{
    $startDate = $this->filters['startDate'] ?? null;
    $endDate = $this->filters['endDate'] ?? null;

    return [
        // ...
    ];
}
```

The `$this->filters` array will always reflect the current form data. Please note that this data is not validated, as it is available live and not intended to be used for anything other than querying the database. You must ensure that the data is valid before using it.

<Aside variant="info">
    If you want to add filters that apply to multiple widgets at once, see [filtering widget data](overview#filtering-widget-data) in the dashboard.
</Aside>

## Live updating chart data (polling)

By default, chart widgets refresh their data every 5 seconds.

To customize this, you may override the `$pollingInterval` property on the class to a new interval:

```php
protected ?string $pollingInterval = '10s';
```

Alternatively, you may disable polling altogether:

```php
protected ?string $pollingInterval = null;
```

## Setting a maximum chart height

You may place a maximum height on the chart to ensure that it doesn't get too big, using the `$maxHeight` property:

```php
protected ?string $maxHeight = '300px';
```

## Setting chart configuration options

You may specify an `$options` variable on the chart class to control the many configuration options that the Chart.js library provides. For instance, you could turn off the [legend](https://www.chartjs.org/docs/latest/configuration/legend.html) for a line chart:

```php
protected ?array $options = [
    'plugins' => [
        'legend' => [
            'display' => false,
        ],
    ],
];
```

Alternatively, you can override the `getOptions()` method to return a dynamic array of options:

```php
protected function getOptions(): array
{
    return [
        'plugins' => [
            'legend' => [
                'display' => false,
            ],
        ],
    ];
}
```

These PHP arrays will get transformed into JSON objects when the chart is rendered. If you want to return raw JavaScript from this method instead, you can return a `RawJs` object. This is useful if you want to use a JavaScript callback function, for example:

```php
use Filament\Support\RawJs;

protected function getOptions(): RawJs
{
    return RawJs::make(<<<JS
        {
            scales: {
                y: {
                    ticks: {
                        callback: (value) => '€' + value,
                    },
                },
            },
        }
    JS);
}
```

## Adding a description

You may add a description, below the heading of the chart, using the `getDescription()` method:

```php
public function getDescription(): ?string
{
    return 'The number of blog posts published per month.';
}
```

## Disabling lazy loading

By default, widgets are lazy-loaded. This means that they will only be loaded when they are visible on the page.

To disable this behavior, you may override the `$isLazy` property on the widget class:

```php
protected static bool $isLazy = true;
```

## Making the chart collapsible

You may allow the chart to be collapsible by setting the `$isCollapsible` property on the widget class to be `true`:

```php
protected bool $isCollapsible = true;
```

## Using custom Chart.js plugins

Chart.js offers a powerful plugin system that allows you to extend its functionality and create custom chart behaviors. This guide details how to use them in a chart widget.

### Step 1: Install the plugin with NPM

To start with, install the plugin using NPM into your project. In this guide, we will install [`chartjs-plugin-datalabels`](https://chartjs-plugin-datalabels.netlify.app/guide/getting-started.html#installation):

```bash
npm install chartjs-plugin-datalabels --save-dev
```

### Step 2: Create a JavaScript file importing the plugin

Create a new JavaScript file where you will define your custom plugin. In this guide, we'll call it `filament-chart-js-plugins.js`. Import the plugin, and add it to the `window.filamentChartJsPlugins` array:

```javascript
import ChartDataLabels from 'chartjs-plugin-datalabels'

window.filamentChartJsPlugins ??= []
window.filamentChartJsPlugins.push(ChartDataLabels)
```

It's important to initialise the array if it has not been already, before pushing onto it. This ensures that mutliple JavaScript files (especially those from Filament plugins) that register Chart.js plugins do not overwrite each other, regardless of the order they are booted in.

You can push as many plugins to the `filamentChartJsPlugins` array as you would like to install, you do not need a separate file to import each plugin.

### Step 3: Compile the JavaScript file with Vite

Now, you need to build the JavaScript file with Vite, or your bundler of choice. Include the file in your Vite configuration (usually `vite.config.js`). For example:

```javascript
import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';

export default defineConfig({
    plugins: [
        laravel({
            input: [
                'resources/css/app.css',
                'resources/js/app.js',
                'resources/css/filament/admin/theme.css',
                'resources/js/filament-chart-js-plugins.js', // Include the new file in the `input` array so it is built
            ],
        }),
    ],
});
```

Build the file with `npm run build`.

### Step 4: Register the JavaScript file in Filament

Filament needs to know to include this JavaScript file when rendering chart widgets. You can do this in the `boot()` method of a service provider like `AppServiceProvider`:

```php
use Filament\Support\Assets\Js;
use Filament\Support\Facades\FilamentAsset;
use Illuminate\Support\Facades\Vite;

FilamentAsset::register([
    Js::make('chart-js-plugins', Vite::asset('resources/js/filament-chart-js-plugins.js'))->module(),
]);
```

You can find out more about [asset registration](../advanced/assets), and even [register assets for a specific panel](../panel-configuration#registering-assets-for-a-panel).

