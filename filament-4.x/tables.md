# Documentation for tables. File: 01-overview.md
---
title: Overview
---
import Aside from "@components/Aside.astro"
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Introduction

Tables are a common UI pattern for displaying lists of records in web applications. Filament provides a PHP-based API for defining tables with many features, while also being incredibly customizable.

### Defining table columns

The basis of any table is rows and columns. Filament uses Eloquent to get the data for rows in the table, and you are responsible for defining the columns that are used in that row.

Filament includes many column types prebuilt for you, and you can [view a full list here](columns/overview). You can even [create your own custom column types](columns/custom-columns) to display data in whatever way you need.

Columns are stored in an array, as objects within the `$table->columns()` method:

```php
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->columns([
            TextColumn::make('title'),
            TextColumn::make('slug'),
            IconColumn::make('is_featured')
                ->boolean(),
        ]);
}
```

<AutoScreenshot name="tables/overview/columns" alt="Table with columns" version="4.x" />

In this example, there are 3 columns in the table. The first two display [text](columns/text) - the title and slug of each row in the table. The third column displays an [icon](columns/icon), either a green check or a red cross depending on if the row is featured or not.

#### Making columns sortable and searchable

You can easily modify columns by chaining methods onto them. For example, you can make a column [searchable](columns/overview#searching) using the `searchable()` method. Now, there will be a search field in the table, and you will be able to filter rows by the value of that column:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('title')
    ->searchable()
```

<AutoScreenshot name="tables/overview/searchable-columns" alt="Table with searchable column" version="4.x" />

You can make multiple columns searchable, and Filament will be able to search for matches within any of them, all at once.

You can also make a column [sortable](columns/overview#sorting) using the `sortable()` method. This will add a sort button to the column header, and clicking it will sort the table by that column:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('title')
    ->sortable()
```

<AutoScreenshot name="tables/overview/sortable-columns" alt="Table with sortable column" version="4.x" />

#### Accessing related data from columns

You can also display data in a column that belongs to a relationship. For example, if you have a `Post` model that belongs to a `User` model (the author of the post), you can display the user's name in the table:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('author.name')
```

<AutoScreenshot name="tables/overview/relationship-columns" alt="Table with relationship column" version="4.x" />

In this case, Filament will search for an `author` relationship on the `Post` model, and then display the `name` attribute of that relationship. We call this "dot notation", and you can use it to display any attribute of any relationship, even nested relationships. Filament uses this dot notation to eager-load the results of that relationship for you.

For more information about column relationships, visit the [Relationships section](columns/overview#displaying-data-from-relationships).

#### Adding new columns alongside existing columns

While the `columns()` method redefines all columns for a table, you may sometimes want to add columns to an existing configuration without overriding it completely. This is particularly useful when you have global column configurations that should appear across multiple tables.

Filament provides the `pushColumns()` method for this purpose. Unlike `columns()`, which replaces the entire column configuration, `pushColumns()` appends new columns to any existing ones.

This is especially powerful when combined with [global table settings](#global-settings) in the `boot()` method of a service provider, such as `AppServiceProvider`:

```php
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

Table::configureUsing(function (Table $table) {
    $table
        ->pushColumns([
            TextColumn::make('created_at')
                ->label('Created')
                ->sortable()
                ->toggleable(isToggledHiddenByDefault: true),

            TextColumn::make('updated_at')
                ->label('Updated')
                ->sortable()
                ->toggleable(isToggledHiddenByDefault: true),
        ]);
});
```

### Defining table filters

As well as making columns `searchable()`, which allows the user to filter the table by searching the content of columns, you can also allow the users to filter rows in the table in other ways. [Filters](filters) can be defined in the `$table->filters()` method:

```php
use Filament\Tables\Filters\Filter;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

public function table(Table $table): Table
{
    return $table
        ->columns([
            // ...
        ])
        ->filters([
            Filter::make('is_featured')
                ->query(fn (Builder $query) => $query->where('is_featured', true)),
            SelectFilter::make('status')
                ->options([
                    'draft' => 'Draft',
                    'reviewing' => 'Reviewing',
                    'published' => 'Published',
                ]),
        ]);
}
```

<AutoScreenshot name="tables/overview/filters" alt="Table with filters" version="4.x" />

In this example, we have defined 2 table filters. On the table, there is now a "filter" icon button in the top corner. Clicking it will open a dropdown with the 2 filters we have defined.

The first filter is rendered as a checkbox. When it's checked, only featured rows in the table will be displayed. When it's unchecked, all rows will be displayed.

The second filter is rendered as a select dropdown. When a user selects an option, only rows with that status will be displayed. When no option is selected, all rows will be displayed.

You can use any [schema component](../schemas) to build the UI for a filter. For example, you could create [a custom date range filter](filters/custom).

### Defining table actions

Filament's tables can use [actions](../actions/overview). They are buttons that can be added to the [end of any table row](actions#record-actions), or even in the [header](actions#header-actions) of a table. For instance, you may want an action to "create" a new record in the header, and then "edit" and "delete" actions on each row. [Bulk actions](actions#bulk-actions) can be used to execute code when records in the table are selected.

```php
use App\Models\Post;
use Filament\Actions\Action;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;

public function table(Table $table): Table
{
    return $table
        ->columns([
            // ...
        ])
        ->recordActions([
            Action::make('feature')
                ->action(function (Post $record) {
                    $record->is_featured = true;
                    $record->save();
                })
                ->hidden(fn (Post $record): bool => $record->is_featured),
            Action::make('unfeature')
                ->action(function (Post $record) {
                    $record->is_featured = false;
                    $record->save();
                })
                ->visible(fn (Post $record): bool => $record->is_featured),
        ])
        ->toolbarActions([
            BulkActionGroup::make([
                DeleteBulkAction::make(),
            ]),
        ]);
}
```

<AutoScreenshot name="tables/overview/actions" alt="Table with actions" version="4.x" />

In this example, we define 2 actions for table rows. The first action is a "feature" action. When clicked, it will set the `is_featured` attribute on the record to `true` - which is written within the `action()` method. Using the `hidden()` method, the action will be hidden if the record is already featured. The second action is an "unfeature" action. When clicked, it will set the `is_featured` attribute on the record to `false`. Using the `visible()` method, the action will be hidden if the record is not featured.

We also define a bulk action. When bulk actions are defined, each row in the table will have a checkbox. This bulk action is [built-in to Filament](../actions/delete#bulk-delete), and it will delete all selected records. However, you can [write your own custom bulk actions](actions#bulk-actions) easily too.

<AutoScreenshot name="tables/overview/actions-modal" alt="Table with action modal open" version="4.x" />

Actions can also open modals to request confirmation from the user, as well as render forms inside to collect extra data. It's a good idea to read the [Actions documentation](../actions) to learn more about their extensive capabilities throughout Filament.

## Pagination

By default, Filament tables will be paginated. The user can choose between 5, 10, 25, and 50 records per page. If there are more records than the selected number, the user can navigate between pages using the pagination buttons.

### Customizing the pagination options

You may customize the options for the paginated records per page select by passing them to the `paginated()` method:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->paginated([10, 25, 50, 100, 'all']);
}
```

<Aside variant="warning">
    Be aware when using very high numbers and `all` as large number of records can cause performance issues.
</Aside>

### Customizing the default pagination page option

To customize the default number of records shown use the `defaultPaginationPageOption()` method:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->defaultPaginationPageOption(25);
}
```

<Aside variant="info">
    Make sure that the default pagination page option is included in the [pagination options](#customizing-the-pagination-options).
</Aside>

### Displaying links to the first and the last pagination page

To add "extreme" links to the first and the last page using the `extremePaginationLinks()` method:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->extremePaginationLinks();
}
```

### Using simple pagination

You may use simple pagination by using the `paginationMode(PaginationMode::Simple)` method:

```php
use Filament\Tables\Enums\PaginationMode;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->paginationMode(PaginationMode::Simple);
}
```

### Using cursor pagination

You may use cursor pagination by using the `paginationMode(PaginationMode::Cursor)` method:

```php
use Filament\Tables\Enums\PaginationMode;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->paginationMode(PaginationMode::Cursor);
}
```

### Preventing query string conflicts with the pagination page

By default, Livewire stores the pagination state in a `page` parameter of the URL query string. If you have multiple tables on the same page, this will mean that the pagination state of one table may be overwritten by the state of another table.

To fix this, you may define a `$table->queryStringIdentifier()`, to return a unique query string identifier for that table:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->queryStringIdentifier('users');
}
```

### Disabling pagination

By default, tables will be paginated. To disable this, you should use the `$table->paginated(false)` method:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->paginated(false);
}
```

## Record URLs (clickable rows)

You may allow table rows to be completely clickable by using the `$table->recordUrl()` method:

```php
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Model;

public function table(Table $table): Table
{
    return $table
        ->recordUrl(
            fn (Model $record): string => route('posts.edit', ['record' => $record]),
        );
}
```

When using a [resource](../resources) table, the URL for each row is usually already set up for you, but this method can be called to override the default URL for each row.

<Aside variant="tip">
    You can also [override the URL](columns/overview#opening-urls) for a specific column, or [trigger an action](columns/overview#triggering-actions) when a column is clicked.
</Aside>

You may also open the URL in a new tab:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->openRecordUrlInNewTab();
}
```

## Reordering records

To allow the user to reorder records using drag and drop in your table, you can use the `$table->reorderable()` method:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->reorderable('sort');
}
```

The `sort` database column in this example will be used to store the order of records in the table. Whenever you order a database query using that column, they will be returned in the defined order. If you're using mass assignment protection on your model, you will also need to add the `sort` attribute to the `$fillable` array there.

When making the table reorderable, a new button will be available on the table to toggle reordering.

<AutoScreenshot name="tables/reordering" alt="Table with reorderable rows" version="4.x" />

The `reorderable()` method accepts the name of a column to store the record order in. If you use something like [`spatie/eloquent-sortable`](https://github.com/spatie/eloquent-sortable) with an order column such as `order_column`, you may use this instead:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->reorderable('order_column');
}
```

The `reorderable()` method also accepts a boolean condition as its second parameter, allowing you to conditionally enable reordering:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->reorderable('sort', auth()->user()->isAdmin());
}
```

You can pass a `direction` parameter as `desc` to reorder the records in descending order instead of ascending:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->reorderable('sort', direction: 'desc');
}
```

### Enabling pagination while reordering

Pagination will be disabled in reorder mode to allow you to move records between pages. It is generally a bad experience to have pagination while reordering, but if would like to override this use `$table->paginatedWhileReordering()`:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->paginatedWhileReordering();
}
```

### Customizing the reordering trigger action

To customize the reordering trigger button, you may use the `reorderRecordsTriggerAction()` method, passing a closure that returns an action. All methods that are available to [customize action trigger buttons](../actions/overview) can be used:

```php
use Filament\Actions\Action;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->reorderRecordsTriggerAction(
            fn (Action $action, bool $isReordering) => $action
                ->button()
                ->label($isReordering ? 'Disable reordering' : 'Enable reordering'),
        );
}
```

<AutoScreenshot name="tables/reordering/custom-trigger-action" alt="Table with reorderable rows and a custom trigger action" version="4.x" />

## Customizing the table header

You can add a heading to a table using the `$table->heading()` method:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->heading('Clients')
        ->columns([
            // ...
        ]);
```

You can also add a description below the heading using the `$table->description()` method:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->heading('Clients')
        ->description('Manage your clients here.')
        ->columns([
            // ...
        ]);
```

You can pass a view to the `$table->header()` method to customize the entire header HTML:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->header(view('tables.header', [
            'heading' => 'Clients',
        ]))
        ->columns([
            // ...
        ]);
```

## Polling table content

You may poll table content so that it refreshes at a set interval, using the `$table->poll()` method:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->poll('10s');
}
```

## Deferring loading

Tables with lots of data might take a while to load, in which case you can load the table data asynchronously using the `deferLoading()` method:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->deferLoading();
}
```

## Searching records with Laravel Scout

While Filament doesn't provide a direct integration with [Laravel Scout](https://laravel.com/docs/scout), you may use the `searchUsing()` method with a `whereKey()` clause to filter the query for Scout results:

```php
use App\Models\Post;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

public function table(Table $table): Table
{
    return $table
        ->searchUsing(fn (Builder $query, string $search) => $query->whereKey(Post::search($search)->keys()));
```

Under normal circumstances Scout uses the `whereKey()` (`whereIn()`) method to retrieve results internally, so there is no performance penalty for using it.

For the global search input to show, at least one column in the table needs to be `searchable()`. Alternatively, if you are using Scout to control which columns are searchable already, you can simply pass `searchable()` to the entire table instead:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->searchable();
}
```

## Styling table rows

### Striped table rows

To enable striped table rows, you can use the `striped()` method:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->striped();
}
```

<AutoScreenshot name="tables/striped" alt="Table with striped rows" version="4.x" />

### Custom row classes

You may want to conditionally style rows based on the record data. This can be achieved by specifying a string or array of CSS classes to be applied to the row using the `$table->recordClasses()` method:

```php
use App\Models\Post;
use Closure;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Model;

public function table(Table $table): Table
{
    return $table
        ->recordClasses(fn (Post $record) => match ($record->status) {
            'draft' => 'draft-post-table-row',
            'reviewing' => 'reviewing-post-table-row',
            'published' => 'published-post-table-row',
            default => null,
        });
}
```

## Global settings

To customize the default configuration used for all tables, you can call the static `configureUsing()` method from the `boot()` method of a service provider. The function will be run for each table that gets created:

```php
use Filament\Tables\Enums\FiltersLayout;
use Filament\Tables\Table;

Table::configureUsing(function (Table $table): void {
    $table
        ->reorderableColumns()
        ->filtersLayout(FiltersLayout::AboveContentCollapsible)
        ->paginationPageOptions([10, 25, 50]);
});
```

# Documentation for tables. File: 02-columns/01-overview.md
---
title: Overview
---
import Aside from "@components/Aside.astro"
import AutoScreenshot from "@components/AutoScreenshot.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

Column classes can be found in the `Filament\Tables\Columns` namespace. They reside within the `$table->columns()` method. Filament includes a number of columns built-in:

- [Text column](text)
- [Icon column](icon)
- [Image column](image)
- [Color column](color)

Editable columns allow the user to update data in the database without leaving the table:

- [Select column](select)
- [Toggle column](toggle)
- [Text input column](text-input)
- [Checkbox column](checkbox)

You may also [create your own custom columns](custom-columns) to display data however you wish.

Columns may be created using the static `make()` method, passing its unique name. Usually, the name of a column corresponds to the name of an attribute on an Eloquent model. You may use "dot notation" to access attributes within relationships:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('title')

TextColumn::make('author.name')
```

## Column content (state)

Columns may feel a bit magic at first, but they’re designed to be simple to use and optimized to display data from an Eloquent record. Despite this, they’re flexible and you can display data from any source, not just an Eloquent record attribute.

The data that a column displays is called its "state". When using a [panel resource](../resources), the table is aware of the records it is displaying. This means that the state of the column is set based on the value of the attribute on the record. For example, if the column is used in the table of a `PostResource`, then the `title` attribute value of the current post will be displayed.

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('title')
```

If you want to access the value stored in a relationship, you can use "dot notation". The name of the relationship that you would like to access data from comes first, followed by a dot, and then the name of the attribute:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('author.name')
```

You can also use "dot notation" to access values within a JSON / array column on an Eloquent model. The name of the attribute comes first, followed by a dot, and then the key of the JSON object you want to read from:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('meta.title')
```

### Setting the state of a column

You can pass your own state to a column by using the `state()` method:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('title')
    ->state('Hello, world!')
```

<UtilityInjection set="tableColumns" except="$state" version="4.x">The `state()` method also accepts a function to dynamically calculate the state. You can inject various utilities into the function as parameters.</UtilityInjection>

### Setting the default state of a column

When a column is empty (its state is `null`), you can use the `default()` method to define alternative state to use instead. This method will treat the default state as if it were real, so columns like [image](image) or [color](color) will display the default image or color.

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('title')
    ->default('Untitled')
```

#### Adding placeholder text if a column is empty

Sometimes you may want to display placeholder text for columns with an empty state, which is styled as a lighter gray text. This differs from the [default value](#setting-the-default-state-of-an-column), as the placeholder is always text and not treated as if it were real state.

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('title')
    ->placeholder('Untitled')
```

<AutoScreenshot name="tables/columns/placeholder" alt="Column with a placeholder for empty state" version="4.x" />

### Displaying data from relationships

You may use "dot notation" to access columns within relationships. The name of the relationship comes first, followed by a period, followed by the name of the column to display:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('author.name')
```

#### Counting relationships

If you wish to count the number of related records in a column, you may use the `counts()` method:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('users_count')->counts('users')
```

In this example, `users` is the name of the relationship to count from. The name of the column must be `users_count`, as this is the convention that [Laravel uses](https://laravel.com/docs/eloquent-relationships#counting-related-models) for storing the result.

If you'd like to scope the relationship before counting, you can pass an array to the method, where the key is the relationship name and the value is the function to scope the Eloquent query with:

```php
use Filament\Tables\Columns\TextColumn;
use Illuminate\Database\Eloquent\Builder;

TextColumn::make('users_count')->counts([
    'users' => fn (Builder $query) => $query->where('is_active', true),
])
```

#### Determining relationship existence

If you simply wish to indicate whether related records exist in a column, you may use the `exists()` method:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('users_exists')->exists('users')
```

In this example, `users` is the name of the relationship to check for existence. The name of the column must be `users_exists`, as this is the convention that [Laravel uses](https://laravel.com/docs/eloquent-relationships#other-aggregate-functions) for storing the result.

If you'd like to scope the relationship before checking existance, you can pass an array to the method, where the key is the relationship name and the value is the function to scope the Eloquent query with:

```php
use Filament\Tables\Columns\TextColumn;
use Illuminate\Database\Eloquent\Builder;

TextColumn::make('users_exists')->exists([
    'users' => fn (Builder $query) => $query->where('is_active', true),
])
```

#### Aggregating relationships

Filament provides several methods for aggregating a relationship field, including `avg()`, `max()`, `min()` and `sum()`. For instance, if you wish to show the average of a field on all related records in a column, you may use the `avg()` method:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('users_avg_age')->avg('users', 'age')
```

In this example, `users` is the name of the relationship, while `age` is the field that is being averaged. The name of the column must be `users_avg_age`, as this is the convention that [Laravel uses](https://laravel.com/docs/eloquent-relationships#other-aggregate-functions) for storing the result.

If you'd like to scope the relationship before aggregating, you can pass an array to the method, where the key is the relationship name and the value is the function to scope the Eloquent query with:

```php
use Filament\Tables\Columns\TextColumn;
use Illuminate\Database\Eloquent\Builder;

TextColumn::make('users_avg_age')->avg([
    'users' => fn (Builder $query) => $query->where('is_active', true),
], 'age')
```

## Setting a column's label

By default, the label of the column, which is displayed in the header of the table, is generated from the name of the column. You may customize this using the `label()` method:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('name')
    ->label('Full name')
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `label()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

Customizing the label in this way is useful if you wish to use a [translation string for localization](https://laravel.com/docs/localization#retrieving-translation-strings):

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('name')
    ->label(__('columns.name'))
```

## Sorting

Columns may be sortable, by clicking on the column label. To make a column sortable, you must use the `sortable()` method:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('name')
    ->sortable()
```

<AutoScreenshot name="tables/columns/sortable" alt="Table with sortable column" version="4.x" />

Using the name of the column, Filament will apply an `orderBy()` clause to the Eloquent query. This is useful for simple cases where the column name matches the database column name. It can also handle [relationships](#displaying-data-from-relationships).

However, many columns are not as simple. The [state](#column-content-state) of the column might be customized, or using an [Eloquent accessor](https://laravel.com/docs/eloquent-mutators#accessors-and-mutators). In this case, you may need to customize the sorting behavior.

You can pass an array of real database columns in the table to sort the column with:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('full_name')
    ->sortable(['first_name', 'last_name'])
```

In this instance, the `full_name` column is not a real column in the database, but the `first_name` and `last_name` columns are. When the `full_name` column is sorted, Filament will sort the table by the `first_name` and `last_name` columns. The reason why two columns are passed is that if two records have the same `first_name`, the `last_name` will be used to sort them. If your use case doesn’t require this, you can pass only one column in the array if you wish.

You may also directly interact with the Eloquent query to customize how sorting is applied for that column:

```php
use Filament\Tables\Columns\TextColumn;
use Illuminate\Database\Eloquent\Builder;

TextColumn::make('full_name')
    ->sortable(query: function (Builder $query, string $direction): Builder {
        return $query
            ->orderBy('last_name', $direction)
            ->orderBy('first_name', $direction);
    })
```

<UtilityInjection set="tableColumns" version="4.x" extras="Direction;;string;;$direction;;The direction that the column is currently being sorted on, either <code>'asc'</code> or <code>'desc'</code>.||Eloquent query builder;;Illuminate\Database\Eloquent\Builder;;$query;;The query builder to modify.">The `query` parameter's function can inject various utilities as parameters.</UtilityInjection>

### Sorting by default

You may choose to sort a table by default if no other sort is applied. You can use the `defaultSort()` method for this:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->columns([
            // ...
        ])
        ->defaultSort('stock', direction: 'desc');
}
```

The second parameter is optional and defaults to `'asc'`.

If you pass the name of a table column as the first parameter, Filament will use that column's sorting behavior (custom sorting columns or query function). However, if you need to sort by a column that doesn’t exist in the table or in the database, you should pass a query function instead:

```php
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

public function table(Table $table): Table
{
    return $table
        ->columns([
            // ...
        ])
        ->defaultSort(function (Builder $query): Builder {
            return $query->orderBy('stock');
        });
}
```

### Persisting the sort in the user's session

To persist the sorting in the user's session, use the `persistSortInSession()` method:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->columns([
            // ...
        ])
        ->persistSortInSession();
}
```

### Setting a default sort option label

To set a default sort option label, use the `defaultSortOptionLabel()` method:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->columns([
            // ...
        ])
        ->defaultSortOptionLabel('Date');
}
```

## Disabling default primary key sorting

By default, Filament will automatically add a primary key sort to the table query to ensure that the order of records is consistent. If your table doesn't have a primary key, or you wish to disable this behavior, you can use the `defaultKeySort(false)` method:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->columns([
            // ...
        ])
        ->defaultKeySort(false);
}
```

## Searching

Columns may be searchable by using the text input field in the top right of the table. To make a column searchable, you must use the `searchable()` method:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('name')
    ->searchable()
```

<AutoScreenshot name="tables/columns/searchable" alt="Table with searchable column" version="4.x" />

By default, Filament will apply a `where` clause to the Eloquent query, searching for the column name. This is useful for simple cases where the column name matches the database column name. It can also handle [relationships](#displaying-data-from-relationships).

However, many columns are not as simple. The [state](#column-content-state) of the column might be customized, or using an [Eloquent accessor](https://laravel.com/docs/eloquent-mutators#accessors-and-mutators). In this case, you may need to customize the search behavior.

You can pass an array of real database columns in the table to search the column with:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('full_name')
    ->searchable(['first_name', 'last_name'])
```

In this instance, the `full_name` column is not a real column in the database, but the `first_name` and `last_name` columns are. When the `full_name` column is searched, Filament will search the table by the `first_name` and `last_name` columns.

You may also directly interact with the Eloquent query to customize how searching is applied for that column:

```php
use Filament\Tables\Columns\TextColumn;
use Illuminate\Database\Eloquent\Builder;

TextColumn::make('full_name')
    ->searchable(query: function (Builder $query, string $search): Builder {
        return $query
            ->where('first_name', 'like', "%{$search}%")
            ->orWhere('last_name', 'like', "%{$search}%");
    })
```

<UtilityInjection set="tableColumns" version="4.x" extras="Search;;string;;$search;;The current search input value.||Eloquent query builder;;Illuminate\Database\Eloquent\Builder;;$query;;The query builder to modify.">The `query` parameter's function can inject various utilities as parameters.</UtilityInjection>

### Adding extra searchable columns to the table

You may allow the table to search with extra columns that aren’t present in the table by passing an array of column names to the `searchable()` method:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->columns([
            // ...
        ])
        ->searchable(['id']);
}
```

You may use dot notation to search within relationships:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->columns([
            // ...
        ])
        ->searchable(['id', 'author.id']);
}
```

You may also pass custom functions to search using:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->columns([
            // ...
        ])
        ->searchable([
            'id',
            'author.id',
            function (Builder $query, string $search): Builder {
                if (! is_numeric($search)) {
                    return $query;
                }
            
                return $query->whereYear('published_at', $search);
            },
        ]);
}
```

### Customizing the table search field placeholder

You may customize the placeholder in the search field using the `searchPlaceholder()` method on the `$table`:

```php
use Filament\Tables\Table;

public static function table(Table $table): Table
{
    return $table
        ->columns([
            // ...
        ])
        ->searchPlaceholder('Search (ID, Name)');
}
```

### Searching individually

You can choose to enable a per-column search input field using the `isIndividual` parameter:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('name')
    ->searchable(isIndividual: true)
```

<AutoScreenshot name="tables/columns/individually-searchable" alt="Table with individually searchable column" version="4.x" />

If you use the `isIndividual` parameter, you may still search that column using the main "global" search input field for the entire table.

To disable that functionality while still preserving the individual search functionality, you need the `isGlobal` parameter:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('title')
    ->searchable(isIndividual: true, isGlobal: false)
```

### Customizing the table search debounce

You may customize the debounce time in all table search fields using the `searchDebounce()` method on the `$table`. By default, it is set to `500ms`:

```php
use Filament\Tables\Table;

public static function table(Table $table): Table
{
    return $table
        ->columns([
            // ...
        ])
        ->searchDebounce('750ms');
}
```

### Searching when the input is blurred

Instead of automatically reloading the table contents while the user is typing their search, which is affected by the [debounce](#customizing-the-table-search-debounce) of the search field, you may change the behavior so that the table is only searched when the user blurs the input (tabs or clicks out of it), using the `searchOnBlur()` method:

```php
use Filament\Tables\Table;

public static function table(Table $table): Table
{
    return $table
        ->columns([
            // ...
        ])
        ->searchOnBlur();
}
```

### Persisting the search in the user's session

To persist the table or individual column search in the user's session, use the `persistSearchInSession()` or `persistColumnSearchInSession()` method:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->columns([
            // ...
        ])
        ->persistSearchInSession()
        ->persistColumnSearchesInSession();
}
```

### Disabling search term splitting

By default, the table search will split the search term into individual words and search for each word separately. This allows for more flexible search queries. However, it can have a negative impact on performance when large datasets are involved. You can disable this behavior using the `splitSearchTerms(false)` method on the table:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->columns([
            // ...
        ])
        ->splitSearchTerms(false);
}
```

## Clickable cell content

When a cell is clicked, you may open a URL or trigger an "action".

### Opening URLs

To open a URL, you may use the `url()` method:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('title')
    ->url(fn (Post $record): string => route('posts.edit', ['post' => $record]))
```

<UtilityInjection set="tableColumns" version="4.x">The `url()` method also accepts a function to dynamically calculate the value. You can inject various utilities into the function as parameters.</UtilityInjection>

<Aside variant="tip">
    You can also pick a URL for the entire row to open, not just a singular column. Please see the [Record URLs section](../overview#record-urls-clickable-rows).

    When using a record URL and a column URL, the column URL will override the record URL for those cells only.
</Aside>

You may also choose to open the URL in a new tab:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('title')
    ->url(fn (Post $record): string => route('posts.edit', ['post' => $record]))
    ->openUrlInNewTab()
```

### Triggering actions

To run a function when a cell is clicked, you may use the `action()` method. Each method accepts a `$record` parameter which you may use to customize the behavior of the action:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('title')
    ->action(function (Post $record): void {
        $this->dispatch('open-post-edit-modal', post: $record->getKey());
    })
```

#### Action modals

You may open [action modals](../../actions#modals) by passing in an `Action` object to the `action()` method:

```php
use Filament\Actions\Action;
use Filament\Tables\Columns\TextColumn;

TextColumn::make('title')
    ->action(
        Action::make('select')
            ->requiresConfirmation()
            ->action(function (Post $record): void {
                $this->dispatch('select-post', post: $record->getKey());
            }),
    )
```

Action objects passed into the `action()` method must have a unique name to distinguish it from other actions within the table.

#### Preventing cells from being clicked

You may prevent a cell from being clicked by using the `disabledClick()` method:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('title')
    ->disabledClick()
```

If [row URLs](../overview#record-urls-clickable-rows) are enabled, the cell will not be clickable.

## Adding a tooltip to a column

You may specify a tooltip to display when you hover over a cell:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('title')
    ->tooltip('Title')
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `tooltip()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="tables/columns/tooltips" alt="Table with column triggering a tooltip" version="4.x" />

## Aligning column content

### Horizontally aligning column content

You may align the content of an column to the start (left in left-to-right interfaces, right in right-to-left interfaces), center, or end (right in left-to-right interfaces, left in right-to-left interfaces) using the `alignStart()`, `alignCenter()` or `alignEnd()` methods:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('email')
    ->alignStart() // This is the default alignment.

TextColumn::make('email')
    ->alignCenter()

TextColumn::make('email')
    ->alignEnd()
```

Alternatively, you may pass an `Alignment` enum to the `alignment()` method:

```php
use Filament\Support\Enums\Alignment;
use Filament\Tables\Columns\TextColumn;

TextColumn::make('email')
    ->label('Email address')
    ->alignment(Alignment::End)
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `alignment()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="tables/columns/alignment" alt="Table with column aligned to the end" version="4.x" />

### Vertically aligning column content

You may align the content of a column to the start, center, or end using the `verticallyAlignStart()`, `verticallyAlignCenter()` or `verticallyAlignEnd()` methods:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('name')
    ->verticallyAlignStart()

TextColumn::make('name')
    ->verticallyAlignCenter() // This is the default alignment.

TextColumn::make('name')
    ->verticallyAlignEnd()
```

Alternatively, you may pass a `VerticalAlignment` enum to the `verticalAlignment()` method:

```php
use Filament\Support\Enums\VerticalAlignment;
use Filament\Tables\Columns\TextColumn;

TextColumn::make('name')
    ->verticalAlignment(VerticalAlignment::Start)
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `verticalAlignment()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="tables/columns/vertical-alignment" alt="Table with column vertically aligned to the start" version="4.x" />

## Allowing column headers to wrap

By default, column headers will not wrap onto multiple lines if they need more space. You may allow them to wrap using the `wrapHeader()` method:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('name')
    ->wrapHeader()
```

Optionally, you may pass a boolean value to control if the header should wrap:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('name')
    ->wrapHeader(FeatureFlag::active())
```

<UtilityInjection set="tableColumns" version="4.x">The `wrapHeader()` method also accepts a function to dynamically calculate the value. You can inject various utilities into the function as parameters.</UtilityInjection>

## Controlling the width of columns

By default, columns will take up as much space as they need. You may allow some columns to consume more space than others by using the `grow()` method:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('name')
    ->grow()
```

Alternatively, you can define a width for the column, which is passed to the header cell using the `style` attribute, so you can use any valid CSS value:

```php
use Filament\Tables\Columns\IconColumn;

IconColumn::make('is_paid')
    ->label('Paid')
    ->boolean()
    ->width('1%')
```

<UtilityInjection set="tableColumns" version="4.x">The `width()` method also accepts a function to dynamically calculate the value. You can inject various utilities into the function as parameters.</UtilityInjection>

## Grouping columns

You group multiple columns together underneath a single heading using a `ColumnGroup` object:

```php
use Filament\Tables\Columns\ColumnGroup;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->columns([
            TextColumn::make('title'),
            TextColumn::make('slug'),
            ColumnGroup::make('Visibility', [
                TextColumn::make('status'),
                IconColumn::make('is_featured'),
            ]),
            TextColumn::make('author.name'),
        ]);
}
```

The first argument is the label of the group, and the second is an array of column objects that belong to that group.

<AutoScreenshot name="tables/columns/grouping" alt="Table with grouped columns" version="4.x" />

You can also control the group header [alignment](#horizontally-aligning-column-content) and [wrapping](#allowing-column-headers-to-wrap) on the `ColumnGroup` object. To improve the multi-line fluency of the API, you can chain the `columns()` onto the object instead of passing it as the second argument:

```php
use Filament\Support\Enums\Alignment;
use Filament\Tables\Columns\ColumnGroup;

ColumnGroup::make('Website visibility')
    ->columns([
        // ...
    ])
    ->alignCenter()
    ->wrapHeader()
```

## Hiding columns

You may hide a column by using the `hidden()` or `visible()` method:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('email')
    ->hidden()

TextColumn::make('email')
    ->visible()
```

To hide a column conditionally, you may pass a boolean value to either method:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('role')
    ->hidden(FeatureFlag::active())

TextColumn::make('role')
    ->visible(FeatureFlag::active())
```

### Allowing users to manage columns

#### Toggling column visibility

Users may hide or show columns themselves in the table. To make a column toggleable, use the `toggleable()` method:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('email')
    ->toggleable()
```

<AutoScreenshot name="tables/columns/column-manager" alt="Table with column manager" version="4.x" />

##### Making toggleable columns hidden by default

By default, toggleable columns are visible. To make them hidden instead:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('id')
    ->toggleable(isToggledHiddenByDefault: true)
```

#### Reordering columns

You may allow columns to be reordered in the table using the `reorderableColumns()` method:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->columns([
            // ...
        ])
        ->reorderableColumns();
}
```

<AutoScreenshot name="tables/columns/column-manager-reorderable" alt="Table with reorderable column manager" version="4.x" />

#### Live column manager

By default, column manager changes (toggling and reordering columns) are deferred and do not affect the table, until the user clicks an "Apply" button. To disable this and make the filters "live" instead, use the `deferColumnManager(false)` method:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->columns([
            // ...
        ])
        ->reorderableColumns()
        ->deferColumnManager(false);
}
```

#### Customizing the column manager dropdown trigger action

To customize the column manager dropdown trigger button, you may use the `columnManagerTriggerAction()` method, passing a closure that returns an action. All methods that are available to [customize action trigger buttons](../actions/overview) can be used:

```php
use Filament\Actions\Action;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->filters([
            // ...
        ])
        ->columnManagerTriggerAction(
            fn (Action $action) => $action
                ->button()
                ->label('Column Manager'),
        );
}
```

## Adding extra HTML attributes to a column content

You can pass extra HTML attributes to the column content via the `extraAttributes()` method, which will be merged onto its outer HTML element. The attributes should be represented by an array, where the key is the attribute name and the value is the attribute value:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('slug')
    ->extraAttributes(['class' => 'slug-column'])
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `extraAttributes()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

By default, calling `extraAttributes()` multiple times will overwrite the previous attributes. If you wish to merge the attributes instead, you can pass `merge: true` to the method.

### Adding extra HTML attributes to the cell

You can also pass extra HTML attributes to the table cell which surrounds the content of the column:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('slug')
    ->extraCellAttributes(['class' => 'slug-cell'])
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `extraCellAttributes()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

By default, calling `extraCellAttributes()` multiple times will overwrite the previous attributes. If you wish to merge the attributes instead, you can pass `merge: true` to the method.

### Adding extra attributes to the header cell

You can pass extra HTML attributes to the table header cell which surrounds the content of the column:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('slug')
    ->extraHeaderAttributes(['class' => 'slug-header-cell'])
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `extraHeaderAttributes()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

By default, calling `extraHeaderAttributes()` multiple times will overwrite the previous attributes. If you wish to merge the attributes instead, you can pass `merge: true` to the method.

## Column utility injection

The vast majority of methods used to configure columns accept functions as parameters instead of hardcoded values:

```php
use App\Models\User;
use Filament\Tables\Columns\TextColumn;

TextColumn::make('email')
    ->placeholder(fn (User $record): string => "No email for {$record->name}")

TextColumn::make('role')
    ->hidden(fn (User $record): bool => $record->role === 'admin')

TextColumn::make('name')
    ->extraAttributes(fn (User $record): array => ['class' => "{$record->getKey()}-name-column"])
```

This alone unlocks many customization possibilities.

The package is also able to inject many utilities to use inside these functions, as parameters. All customization methods that accept functions as arguments can inject utilities.

These injected utilities require specific parameter names to be used. Otherwise, Filament doesn't know what to inject.

### Injecting the current state of the column

If you wish to access the current [value (state)](#column-content-state) of the column, define a `$state` parameter:

```php
function ($state) {
    // ...
}
```

### Injecting the current Eloquent record

You may retrieve the Eloquent record for the current schema using a `$record` parameter:

```php
use Illuminate\Database\Eloquent\Model;

function (?Model $record) {
    // ...
}
```

### Injecting the row loop

To access the [row loop](https://laravel.com/docs/blade#the-loop-variable) object for the current table row, define a `$rowLoop` parameter:

```php
function (stdClass $rowLoop) {
    // ...
}
```

### Injecting the current Livewire component instance

If you wish to access the current Livewire component instance, define a `$livewire` parameter:

```php
use Livewire\Component;

function (Component $livewire) {
    // ...
}
```

### Injecting the current column instance

If you wish to access the current component instance, define a `$component` parameter:

```php
use Filament\Tables\Columns\Column;

function (Column $component) {
    // ...
}
```

### Injecting the current table instance

If you wish to access the current table instance, define a `$table` parameter:

```php
use Filament\Tables\Table;

function (Table $table) {
    // ...
}
```

### Injecting multiple utilities

The parameters are injected dynamically using reflection, so you’re able to combine multiple parameters in any order:

```php
use App\Models\User;
use Livewire\Component as Livewire;

function (Livewire $livewire, mixed $state, User $record) {
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

If you wish to change the default behavior of all columns globally, then you can call the static `configureUsing()` method inside a service provider's `boot()` method, to which you pass a Closure to modify the columns using. For example, if you wish to make all `TextColumn` columns [`toggleable()`](#toggling-column-visibility), you can do it like so:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::configureUsing(function (TextColumn $column): void {
    $column->toggleable();
});
```

Of course, you’re still able to overwrite this on each column individually:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('name')
    ->toggleable(false)
```

# Documentation for tables. File: 02-columns/02-text.md
---
title: Text column
---
import Aside from "@components/Aside.astro"
import AutoScreenshot from "@components/AutoScreenshot.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

Text columns display simple text:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('title')
```

<AutoScreenshot name="tables/columns/text/simple" alt="Text column" version="4.x" />

## Customizing the color

You may set a [color](../../styling/colors) for the text:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('status')
    ->color('primary')
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `color()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="tables/columns/text/color" alt="Text column in the primary color" version="4.x" />

## Adding an icon

Text columns may also have an [icon](../../styling/icons):

```php
use Filament\Tables\Columns\TextColumn;
use Filament\Support\Icons\Heroicon;

TextColumn::make('email')
    ->icon(Heroicon::Envelope)
```

<UtilityInjection set="tableColumns" version="4.x">The `icon()` method also accepts a function to dynamically calculate the icon. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="tables/columns/text/icon" alt="Text column with icon" version="4.x" />

You may set the position of an icon using `iconPosition()`:

```php
use Filament\Tables\Columns\TextColumn;
use Filament\Support\Enums\IconPosition;
use Filament\Support\Icons\Heroicon;

TextColumn::make('email')
    ->icon(Heroicon::Envelope)
    ->iconPosition(IconPosition::After) // `IconPosition::Before` or `IconPosition::After`
```

<UtilityInjection set="tableColumns" version="4.x">The `iconPosition()` method also accepts a function to dynamically calculate the icon position. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="tables/columns/text/icon-after" alt="Text column with icon after" version="4.x" />

The icon color defaults to the text color, but you may customize the icon [color](../../styling/colors) separately using `iconColor()`:

```php
use Filament\Tables\Columns\TextColumn;
use Filament\Support\Icons\Heroicon;

TextColumn::make('email')
    ->icon(Heroicon::Envelope)
    ->iconColor('primary')
```

<UtilityInjection set="tableColumns" version="4.x">The `iconColor()` method also accepts a function to dynamically calculate the icon color. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="tables/columns/text/icon-color" alt="Text column with icon in the primary color" version="4.x" />

## Displaying as a "badge"

By default, text is quite plain and has no background color. You can make it appear as a "badge" instead using the `badge()` method. A great use case for this is with statuses, where may want to display a badge with a [color](#customizing-the-color) that matches the status:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('status')
    ->badge()
    ->color(fn (string $state): string => match ($state) {
        'draft' => 'gray',
        'reviewing' => 'warning',
        'published' => 'success',
        'rejected' => 'danger',
    })
```

<AutoScreenshot name="tables/columns/text/badge" alt="Text column as badge" version="4.x" />

You may add other things to the badge, like an [icon](#adding-an-icon).

Optionally, you may pass a boolean value to control if the text should be in a badge or not:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('status')
    ->badge(FeatureFlag::active())
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `badge()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Formatting

When using a text column, you may want the actual outputted text in the UI to differ from the raw [state](overview#column-content-state) of the column, which is often automatically retrieved from an Eloquent model. Formatting the state allows you to preserve the integrity of the raw data while also allowing it to be presented in a more user-friendly way.

To format the state of a text column without changing the state itself, you can use the `formatStateUsing()` method. This method accepts a function that takes the state as an argument and returns the formatted state:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('status')
    ->formatStateUsing(fn (string $state): string => __("statuses.{$state}"))
```

In this case, the `status` column in the database might contain values like `draft`, `reviewing`, `published`, or `rejected`, but the formatted state will be the translated version of these values.

<UtilityInjection set="tableColumns" version="4.x">The function passed to `formatStateUsing()` can inject various utilities as parameters.</UtilityInjection>

### Date formatting

Instead of passing a function to `formatStateUsing()`, you may use the `date()`, `dateTime()`, and `time()` methods to format the column's state using [PHP date formatting tokens](https://www.php.net/manual/en/datetime.format.php):

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('created_at')
    ->date()

TextColumn::make('created_at')
    ->dateTime()

TextColumn::make('created_at')
    ->time()
```

You may customize the date format by passing a custom format string to the `date()`, `dateTime()`, or `time()` method. You may use any [PHP date formatting tokens](https://www.php.net/manual/en/datetime.format.php):

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('created_at')
    ->date('M j, Y')
    
TextColumn::make('created_at')
    ->dateTime('M j, Y H:i:s')
    
TextColumn::make('created_at')
    ->time('H:i:s')
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing static values, the `date()`, `dateTime()`, and `time()` methods also accept a function to dynamically calculate the format. You can inject various utilities into the function as parameters.</UtilityInjection>

#### Date formatting using Carbon macro formats

You may use also the `isoDate()`, `isoDateTime()`, and `isoTime()` methods to format the column's state using [Carbon's macro-formats](https://carbon.nesbot.com/docs/#available-macro-formats):

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('created_at')
    ->isoDate()

TextColumn::make('created_at')
    ->isoDateTime()

TextColumn::make('created_at')
    ->isoTime()
```

You may customize the date format by passing a custom macro format string to the `isoDate()`, `isoDateTime()`, or `isoTime()` method. You may use any [Carbon's macro-formats](https://carbon.nesbot.com/docs/#available-macro-formats):

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('created_at')
    ->isoDate('L')

TextColumn::make('created_at')
    ->isoDateTime('LLL')

TextColumn::make('created_at')
    ->isoTime('LT')
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing static values, the `isoDate()`, `isoDateTime()`, and `isoTime()` methods also accept a function to dynamically calculate the format. You can inject various utilities into the function as parameters.</UtilityInjection>

#### Relative date formatting

You may use the `since()` method to format the column's state using [Carbon's `diffForHumans()`](https://carbon.nesbot.com/docs/#api-humandiff):

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('created_at')
    ->since()
```

#### Displaying a formatting date in a tooltip

Additionally, you can use the `dateTooltip()`, `dateTimeTooltip()`, `timeTooltip()`, `isoDateTooltip()`, `isoDateTimeTooltip()`, `isoTime()`, `isoTimeTooltip()`, or `sinceTooltip()` method to display a formatted date in a [tooltip](overview#adding-a-tooltip-to-an-column), often to provide extra information:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('created_at')
    ->since()
    ->dateTooltip() // Accepts a custom PHP date formatting string

TextColumn::make('created_at')
    ->since()
    ->dateTimeTooltip() // Accepts a custom PHP date formatting string

TextColumn::make('created_at')
    ->since()
    ->timeTooltip() // Accepts a custom PHP date formatting string

TextColumn::make('created_at')
    ->since()
    ->isoDateTooltip() // Accepts a custom Carbon macro format string

TextColumn::make('created_at')
    ->since()
    ->isoDateTimeTooltip() // Accepts a custom Carbon macro format string

TextColumn::make('created_at')
    ->since()
    ->isoTimeTooltip() // Accepts a custom Carbon macro format string

TextColumn::make('created_at')
    ->dateTime()
    ->sinceTooltip()
```

#### Setting the timezone for date formatting

Each of the date formatting methods listed above also accepts a `timezone` argument, which allows you to convert the time set in the state to a different timezone:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('created_at')
    ->dateTime(timezone: 'America/New_York')
```

You can also pass a timezone to the `timezone()` method of the column to apply a timezone to all date-time formatting methods at once:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('created_at')
    ->timezone('America/New_York')
    ->dateTime()
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing static values, the `timezone()` method also accepts a function to dynamically calculate the timezone. You can inject various utilities into the function as parameters.</UtilityInjection>

If you do not pass a `timezone()` to the column, it will use Filament's default timezone. You can set Filament's default timezone using the `FilamentTimezone::set()` method in the `boot()` method of a service provider such as `AppServiceProvider`:

```php
use Filament\Support\Facades\FilamentTimezone;

public function boot(): void
{
    FilamentTimezone::set('America/New_York');
}
```

This is useful if you want to set a default timezone for all text columns in your application. It is also used in other places where timezones are used in Filament.

<Aside variant="warning">
    Filament's default timezone will only apply when the column stores a time. If the column stores a date only (`date()` instead of `dateTime()`), the timezone will not be applied. This is to prevent timezone shifts when storing dates without times.
</Aside>

### Number formatting

Instead of passing a function to `formatStateUsing()`, you can use the `numeric()` method to format a column as a number:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('stock')
    ->numeric()
```

If you would like to customize the number of decimal places used to format the number with, you can use the `decimalPlaces` argument:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('stock')
    ->numeric(decimalPlaces: 0)
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing static values, the `decimalPlaces` argument also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

By default, your app's locale will be used to format the number suitably. If you would like to customize the locale used, you can pass it to the `locale` argument:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('stock')
    ->numeric(locale: 'nl')
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing static values, the `locale` argument also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Money formatting

Instead of passing a function to `formatStateUsing()`, you can use the `money()` method to easily format amounts of money, in any currency:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('price')
    ->money('EUR')
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing static values, the `money()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

There is also a `divideBy` argument for `money()` that allows you to divide the original value by a number before formatting it. This could be useful if your database stores the price in cents, for example:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('price')
    ->money('EUR', divideBy: 100)
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing static values, the `divideBy` argument also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

By default, your app's locale will be used to format the money suitably. If you would like to customize the locale used, you can pass it to the `locale` argument:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('price')
    ->money('EUR', locale: 'nl')
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing static values, the `locale` argument also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

If you would like to customize the number of decimal places used to format the number with, you can use the `decimalPlaces` argument:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('price')
    ->money('EUR', decimalPlaces: 3)
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing static values, the `decimalPlaces` argument also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Rendering Markdown

If your column value is Markdown, you may render it using `markdown()`:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('description')
    ->markdown()
```

Optionally, you may pass a boolean value to control if the text should be rendered as Markdown or not:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('description')
    ->markdown(FeatureFlag::active())
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `markdown()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Rendering HTML

If your column value is HTML, you may render it using `html()`:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('description')
    ->html()
```

Optionally, you may pass a boolean value to control if the text should be rendered as HTML or not:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('description')
    ->html(FeatureFlag::active())
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `html()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

#### Rendering raw HTML without sanitization

If you use this method, then the HTML will be sanitized to remove any potentially unsafe content before it is rendered. If you'd like to opt out of this behavior, you can wrap the HTML in an `HtmlString` object by formatting it:

```php
use Filament\Tables\Columns\TextColumn;
use Illuminate\Support\HtmlString;

TextColumn::make('description')
    ->formatStateUsing(fn (string $state): HtmlString => new HtmlString($state))
```

<Aside variant="danger">
    Be cautious when rendering raw HTML, as it may contain malicious content, which can lead to security vulnerabilities in your app such as cross-site scripting (XSS) attacks. Always ensure that the HTML you are rendering is safe before using this method.
</Aside>

Alternatively, you can return a `view()` object from the `formatStateUsing()` method, which will also not be sanitized:

```php
use Filament\Tables\Columns\TextColumn;
use Illuminate\Contracts\View\View;

TextColumn::make('description')
    ->formatStateUsing(fn (string $state): View => view(
        'filament.tables.columns.description-column-content',
        ['state' => $state],
    ))
```

## Displaying a description

Descriptions may be used to easily render additional text above or below the column contents.

You can display a description below the contents of a text column using the `description()` method:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('title')
    ->description(fn (Post $record): string => $record->description)
```

<UtilityInjection set="tableColumns" version="4.x">The function passed to `description()` can inject various utilities as parameters.</UtilityInjection>

<AutoScreenshot name="tables/columns/text/description" alt="Text column with description" version="4.x" />

By default, the description is displayed below the main text, but you can move it using `'above'` as the second parameter:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('title')
    ->description(fn (Post $record): string => $record->description, position: 'above')
```

<AutoScreenshot name="tables/columns/text/description-above" alt="Text column with description above the content" version="4.x" />

## Listing multiple values

Multiple values can be rendered in a text column if its [state](overview#column-content-state) is an array. This can happen if you are using an `array` cast on an Eloquent attribute, an Eloquent relationship with multiple results, or if you have passed an array to the [`state()` method](overview#setting-the-state-of-an-column). If there are multiple values inside your text column, they will be comma-separated. You may use the `listWithLineBreaks()` method to display them on new lines instead:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('authors.name')
    ->listWithLineBreaks()
```

Optionally, you may pass a boolean value to control if the text should have line breaks between each item or not:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('authors.name')
    ->listWithLineBreaks(FeatureFlag::active())
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `listWithLineBreaks()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Adding bullet points to the list

You may add a bullet point to each list item using the `bulleted()` method:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('authors.name')
    ->bulleted()
```

Optionally, you may pass a boolean value to control if the text should have bullet points or not:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('authors.name')
    ->bulleted(FeatureFlag::active())
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `bulleted()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Limiting the number of values in the list

You can limit the number of values in the list using the `limitList()` method:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('authors.name')
    ->listWithLineBreaks()
    ->limitList(3)
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `limitList()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

#### Expanding the limited list

You can allow the limited items to be expanded and collapsed, using the `expandableLimitedList()` method:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('authors.name')
    ->listWithLineBreaks()
    ->limitList(3)
    ->expandableLimitedList()
```

<Aside variant="info">
    This is only a feature for `listWithLineBreaks()` or `bulleted()`, where each item is on its own line.
</Aside>

Optionally, you may pass a boolean value to control if the text should be expandable or not:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('authors.name')
    ->listWithLineBreaks()
    ->limitList(3)
    ->expandableLimitedList(FeatureFlag::active())
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `expandableLimitedList()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Splitting a single value into multiple list items

If you want to "explode" a text string from your model into multiple list items, you can do so with the `separator()` method. This is useful for displaying comma-separated tags [as badges](#displaying-as-a-badge), for example:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('tags')
    ->badge()
    ->separator(',')
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `separator()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Customizing the text size

Text columns have small font size by default, but you may change this to `TextSize::ExtraSmall`, `TextSize::Medium`, or `TextSize::Large`.

For instance, you may make the text larger using `size(TextSize::Large)`:

```php
use Filament\Tables\Columns\TextColumn;
use Filament\Support\Enums\TextSize;

TextColumn::make('title')
    ->size(TextSize::Large)
```

<AutoScreenshot name="tables/columns/text/large" alt="Text column in a large font size" version="4.x" />

## Customizing the font weight

Text columns have regular font weight by default, but you may change this to any of the following options: `FontWeight::Thin`, `FontWeight::ExtraLight`, `FontWeight::Light`, `FontWeight::Medium`, `FontWeight::SemiBold`, `FontWeight::Bold`, `FontWeight::ExtraBold` or `FontWeight::Black`.

For instance, you may make the font bold using `weight(FontWeight::Bold)`:

```php
use Filament\Tables\Columns\TextColumn;
use Filament\Support\Enums\FontWeight;

TextColumn::make('title')
    ->weight(FontWeight::Bold)
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `weight()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="tables/columns/text/bold" alt="Text column in a bold font" version="4.x" />

## Customizing the font family

You can change the text font family to any of the following options: `FontFamily::Sans`, `FontFamily::Serif` or `FontFamily::Mono`.

For instance, you may make the font monospaced using `fontFamily(FontFamily::Mono)`:

```php
use Filament\Support\Enums\FontFamily;
use Filament\Tables\Columns\TextColumn;

TextColumn::make('email')
    ->fontFamily(FontFamily::Mono)
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `fontFamily()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="tables/columns/text/mono" alt="Text column in a monospaced font" version="4.x" />

## Handling long text

### Limiting text length

You may `limit()` the length of the column's value:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('description')
    ->limit(50)
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `limit()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

By default, when text is truncated, an ellipsis (`...`) is appended to the end of the text. You may customize this by passing a custom string to the `end` argument:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('description')
    ->limit(50, end: ' (more)')
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `end` argument also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

You may also reuse the value that is being passed to `limit()` in a function, by getting it using the `getCharacterLimit()` method:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('description')
    ->limit(50)
    ->tooltip(function (TextColumn $column): ?string {
        $state = $column->getState();

        if (strlen($state) <= $column->getCharacterLimit()) {
            return null;
        }

        // Only render the tooltip if the column contents exceeds the length limit.
        return $state;
    })
```

### Limiting word count

You may limit the number of `words()` displayed in the column:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('description')
    ->words(10)
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `words()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

By default, when text is truncated, an ellipsis (`...`) is appended to the end of the text. You may customize this by passing a custom string to the `end` argument:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('description')
    ->words(10, end: ' (more)')
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `end` argument also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Allowing text wrapping

By default, text will not wrap to the next line if it exceeds the width of the container. You can enable this behavior using the `wrap()` method:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('description')
    ->wrap()
```

Optionally, you may pass a boolean value to control if the text should wrap or not:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('description')
    ->wrap(FeatureFlag::active())
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `wrap()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

#### Limiting text to a specific number of lines

You may want to limit text to a specific number of lines instead of limiting it to a fixed length. Clamping text to a number of lines is useful in responsive interfaces where you want to ensure a consistent experience across all screen sizes. This can be achieved using the `lineClamp()` method:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('description')
    ->wrap()
    ->lineClamp(2)
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `lineClamp()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Allowing the text to be copied to the clipboard

You may make the text copyable, such that clicking on the column copies the text to the clipboard, and optionally specify a custom confirmation message and duration in milliseconds:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('email')
    ->copyable()
    ->copyMessage('Email address copied')
    ->copyMessageDuration(1500)
```

<AutoScreenshot name="tables/columns/text/copyable" alt="Text column with a button to copy it" version="4.x" />

Optionally, you may pass a boolean value to control if the text should be copyable or not:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('email')
    ->copyable(FeatureFlag::active())
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing static values, the `copyable()`, `copyMessage()`, and `copyMessageDuration()` methods also accept functions to dynamically calculate them. You can inject various utilities into the function as parameters.</UtilityInjection>

<Aside variant="warning">
    This feature only works when SSL is enabled for the app.
</Aside>

# Documentation for tables. File: 02-columns/03-icon.md
---
title: Icon column
---
import AutoScreenshot from "@components/AutoScreenshot.astro"
import Aside from "@components/Aside.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

Icon columns render an [icon](../../styling/icons) representing the state of the column:

```php
use Filament\Tables\Columns\IconColumn;
use Filament\Support\Icons\Heroicon;

IconColumn::make('status')
    ->icon(fn (string $state): Heroicon => match ($state) {
        'draft' => Heroicon::OutlinedPencil,
        'reviewing' => Heroicon::OutlinedClock,
        'published' => Heroicon::OutlinedCheckCircle,
    })
```

<UtilityInjection set="tableColumns" version="4.x">The `icon()` method can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="tables/columns/icon/simple" alt="Icon column" version="4.x" />

## Customizing the color

You may change the [color](../../styling/colors) of the icon, using the `color()` method:

```php
use Filament\Tables\Columns\IconColumn;

IconColumn::make('status')
    ->color('success')
```

By passing a function to `color()`, you can customize the color based on the state of the column:

```php
use Filament\Tables\Columns\IconColumn;

IconColumn::make('status')
    ->color(fn (string $state): string => match ($state) {
        'draft' => 'info',
        'reviewing' => 'warning',
        'published' => 'success',
        default => 'gray',
    })
```

<UtilityInjection set="tableColumns" version="4.x">The `color()` method can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="tables/columns/icon/color" alt="Icon column with color" version="4.x" />

## Customizing the size

The default icon size is `IconSize::Large`, but you may customize the size to be either `IconSize::ExtraSmall`, `IconSize::Small`, `IconSize::Medium`, `IconSize::ExtraLarge` or `IconSize::TwoExtraLarge`:

```php
use Filament\Tables\Columns\IconColumn;
use Filament\Support\Enums\IconSize;

IconColumn::make('status')
    ->size(IconSize::Medium)
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `size()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="tables/columns/icon/medium" alt="Medium-sized icon column" version="4.x" />

## Handling booleans

Icon columns can display a check or "X" icon based on the state of the column, either true or false, using the `boolean()` method:

```php
use Filament\Tables\Columns\IconColumn;

IconColumn::make('is_featured')
    ->boolean()
```

> If this attribute in the model class is already cast as a `bool` or `boolean`, Filament is able to detect this, and you do not need to use `boolean()` manually.

<AutoScreenshot name="tables/columns/icon/boolean" alt="Icon column to display a boolean" version="4.x" />

Optionally, you may pass a boolean value to control if the icon should be boolean or not:

```php
use Filament\Tables\Columns\IconColumn;

IconColumn::make('is_featured')
    ->boolean(FeatureFlag::active())
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `boolean()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Customizing the boolean icons

You may customize the [icon](../../styling/icons) representing each state:

```php
use Filament\Tables\Columns\IconColumn;
use Filament\Support\Icons\Heroicon;

IconColumn::make('is_featured')
    ->boolean()
    ->trueIcon(Heroicon::OutlinedCheckBadge)
    ->falseIcon(Heroicon::OutlinedXMark)
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing static values, the `trueIcon()` and `falseIcon()` methods also accept functions to dynamically calculate them. You can inject various utilities into the functions as parameters.</UtilityInjection>

<AutoScreenshot name="tables/columns/icon/boolean-icon" alt="Icon column to display a boolean with custom icons" version="4.x" />

### Customizing the boolean colors

You may customize the icon [color](../../styling/colors) representing each state:

```php
use Filament\Tables\Columns\IconColumn;

IconColumn::make('is_featured')
    ->boolean()
    ->trueColor('info')
    ->falseColor('warning')
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing static values, the `trueColor()` and `falseColor()` methods also accept functions to dynamically calculate them. You can inject various utilities into the functions as parameters.</UtilityInjection>

<AutoScreenshot name="tables/columns/icon/boolean-color" alt="Icon column to display a boolean with custom colors" version="4.x" />

## Wrapping multiple icons

When displaying multiple icons, they can be set to wrap if they can't fit on one line, using `wrap()`:

```php
use Filament\Tables\Columns\IconColumn;

IconColumn::make('icon')
    ->wrap()
```

<Aside variant="tip">
    The "width" for wrapping is affected by the column label, so you may need to use a shorter or hidden label to wrap more tightly.
</Aside>

# Documentation for tables. File: 02-columns/04-image.md
---
title: Image column
---
import AutoScreenshot from "@components/AutoScreenshot.astro"
import Aside from "@components/Aside.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

Tables can render images, based on the path in the state of the column:

```php
use Filament\Tables\Columns\ImageColumn;

ImageColumn::make('avatar')
```

In this case, the `header_image` state could contain `posts/header-images/4281246003439.jpg`, which is relative to the root directory of the storage disk. The storage disk is defined in the [configuration file](../../introduction/installation#publishing-configuration), `local` by default. You can also set the `FILESYSTEM_DISK` environment variable to change this.

Alternatively, the state could contain an absolute URL to an image, such as `https://example.com/images/header.jpg`.

<AutoScreenshot name="tables/columns/image/simple" alt="Image column" version="4.x" />

## Managing the image disk

The default storage disk is defined in the [configuration file](../../introduction/installation#publishing-configuration), `local` by default. You can also set the `FILESYSTEM_DISK` environment variable to change this. If you want to deviate from the default disk, you may pass a custom disk name to the `disk()` method:

```php
use Filament\Tables\Columns\ImageColumn;

ImageColumn::make('header_image')
    ->disk('s3')
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `disk()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Public images

By default, Filament will generate temporary URLs to images in the filesystem, unless the [disk](#managing-the-image-disk) is set to `public`. If your images are stored in a public disk, you can set the `visibility()` to `public`:

```php
use Filament\Tables\Columns\ImageColumn;

ImageColumn::make('header_image')
    ->visibility('public')
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `visibility()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Customizing the size

You may customize the image size by passing a `imageWidth()` and `imageHeight()`, or both with `imageSize()`:

```php
use Filament\Tables\Columns\ImageColumn;

ImageColumn::make('header_image')
    ->imageWidth(200)

ImageColumn::make('header_image')
    ->imageHeight(50)

ImageColumn::make('avatar')
    ->imageSize(40)
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static values, the `imageWidth()`, `imageHeight()` and `imageSize()` methods also accept functions to dynamically calculate them. You can inject various utilities into the function as parameters.</UtilityInjection>

### Square images

You may display the image using a 1:1 aspect ratio:

```php
use Filament\Tables\Columns\ImageColumn;

ImageColumn::make('avatar')
    ->imageHeight(40)
    ->square()
```

<AutoScreenshot name="tables/columns/image/square" alt="Square image column" version="4.x" />

Optionally, you may pass a boolean value to control if the image should be square or not:

```php
use Filament\Tables\Columns\ImageColumn;

ImageColumn::make('avatar')
    ->imageHeight(40)
    ->square(FeatureFlag::active())
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `square()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Circular images

You may make the image fully rounded, which is useful for rendering avatars:

```php
use Filament\Tables\Columns\ImageColumn;

ImageColumn::make('avatar')
    ->imageHeight(40)
    ->circular()
```

<AutoScreenshot name="tables/columns/image/circular" alt="Circular image column" version="4.x" />

Optionally, you may pass a boolean value to control if the image should be circular or not:

```php
use Filament\Tables\Columns\ImageColumn;

ImageColumn::make('avatar')
    ->imageHeight(40)
    ->circular(FeatureFlag::active())
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `circular()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Adding a default image URL

You can display a placeholder image if one doesn't exist yet, by passing a URL to the `defaultImageUrl()` method:

```php
use Filament\Tables\Columns\ImageColumn;

ImageColumn::make('header_image')
    ->defaultImageUrl(url('storage/posts/header-images/default.jpg'))
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `defaultImageUrl()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Stacking images

You may display multiple images as a stack of overlapping images by using `stacked()`:

```php
use Filament\Tables\Columns\ImageColumn;

ImageColumn::make('colleagues.avatar')
    ->imageHeight(40)
    ->circular()
    ->stacked()
```

<AutoScreenshot name="tables/columns/image/stacked" alt="Stacked image column" version="4.x" />

Optionally, you may pass a boolean value to control if the images should be stacked or not:

```php
use Filament\Tables\Columns\ImageColumn;

ImageColumn::make('colleagues.avatar')
    ->imageHeight(40)
    ->circular()
    ->stacked(FeatureFlag::active())
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `stacked()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Customizing the stacked ring width

The default ring width is `3`, but you may customize it to be from `0` to `8`:

```php
use Filament\Tables\Columns\ImageColumn;

ImageColumn::make('colleagues.avatar')
    ->imageHeight(40)
    ->circular()
    ->stacked()
    ->ring(5)
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `ring()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Customizing the stacked overlap

The default overlap is `4`, but you may customize it to be from `0` to `8`:

```php
use Filament\Tables\Columns\ImageColumn;

ImageColumn::make('colleagues.avatar')
    ->imageHeight(40)
    ->circular()
    ->stacked()
    ->overlap(2)
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `overlap()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Setting a limit

You may limit the maximum number of images you want to display by passing `limit()`:

```php
use Filament\Tables\Columns\ImageColumn;

ImageColumn::make('colleagues.avatar')
    ->imageHeight(40)
    ->circular()
    ->stacked()
    ->limit(3)
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `limit()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="tables/columns/image/limited" alt="Limited image column" version="4.x" />

### Showing the remaining images count

When you set a limit you may also display the count of remaining images by passing `limitedRemainingText()`.

```php
use Filament\Tables\Columns\ImageColumn;

ImageColumn::make('colleagues.avatar')
    ->imageHeight(40)
    ->circular()
    ->stacked()
    ->limit(3)
    ->limitedRemainingText()
```

<AutoScreenshot name="tables/columns/image/limited-remaining-text" alt="Limited image column with remaining text" version="4.x" />

Optionally, you may pass a boolean value to control if the remaining text should be displayed or not:

```php
use Filament\Tables\Columns\ImageColumn;

ImageColumn::make('colleagues.avatar')
    ->imageHeight(40)
    ->circular()
    ->stacked()
    ->limit(3)
    ->limitedRemainingText(FeatureFlag::active())
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `limitedRemainingText()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

#### Customizing the limited remaining text size

By default, the size of the remaining text is `TextSize::Small`. You can customize this to be `TextSize::ExtraSmall`, `TextSize::Medium` or `TextSize::Large` using the `size` parameter:

```php
use Filament\Tables\Columns\ImageColumn;
use Filament\Support\Enums\TextSize;

ImageColumn::make('colleagues.avatar')
    ->imageHeight(40)
    ->circular()
    ->stacked()
    ->limit(3)
    ->limitedRemainingText(size: TextSize::Large)
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `limitedRemainingText()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Prevent file existence checks

When the schema is loaded, it will automatically detect whether the images exist to prevent errors for missing files. This is all done on the backend. When using remote storage with many images, this can be time-consuming. You can use the `checkFileExistence(false)` method to disable this feature:

```php
use Filament\Tables\Columns\ImageColumn;

ImageColumn::make('attachment')
    ->checkFileExistence(false)
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `checkFileExistence()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Wrapping multiple images

Images can be set to wrap if they can't fit on one line, by setting `wrap()`:

```php
use Filament\Tables\Columns\ImageColumn;

ImageColumn::make('colleagues.avatar')
    ->circular()
    ->stacked()
    ->wrap()
```

<Aside variant="tip">
    The "width" for wrapping is affected by the column label, so you may need to use a shorter or hidden label to wrap more tightly.
</Aside>

## Adding extra HTML attributes to the image

You can pass extra HTML attributes to the `<img>` element via the `extraImgAttributes()` method. The attributes should be represented by an array, where the key is the attribute name and the value is the attribute value:

```php
use Filament\Tables\Columns\ImageColumn;

ImageColumn::make('logo')
    ->extraImgAttributes([
        'alt' => 'Logo',
        'loading' => 'lazy',
    ])
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `extraImgAttributes()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

By default, calling `extraImgAttributes()` multiple times will overwrite the previous attributes. If you wish to merge the attributes instead, you can pass `merge: true` to the method.

# Documentation for tables. File: 02-columns/05-color.md
---
title: Color column
---
import Aside from "@components/Aside.astro"
import AutoScreenshot from "@components/AutoScreenshot.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

The color column allows you to show the color preview from a CSS color definition, typically entered using the [color picker field](../../forms/color-picker), in one of the supported formats (HEX, HSL, RGB, RGBA).

```php
use Filament\Tables\Components\ColorColumn;

ColorColumn::make('color')
```

<AutoScreenshot name="tables/columns/color/simple" alt="Color column" version="4.x" />

## Allowing the color to be copied to the clipboard

You may make the color copyable, such that clicking on the preview copies the CSS value to the clipboard, and optionally specify a custom confirmation message and duration in milliseconds. This feature only works when SSL is enabled for the app.

```php
use Filament\Tables\Components\ColorColumn;

ColorColumn::make('color')
    ->copyable()
    ->copyMessage('Copied!')
    ->copyMessageDuration(1500)
```

<AutoScreenshot name="tables/columns/color/copyable" alt="Color column with a button to copy it" version="4.x" />

Optionally, you may pass a boolean value to control if the text should be copyable or not:

```php
use Filament\Tables\Components\ColorColumn;

ColorColumn::make('color')
    ->copyable(FeatureFlag::active())
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing static values, the `copyable()`, `copyMessage()`, and `copyMessageDuration()` methods also accept functions to dynamically calculate them. You can inject various utilities into the function as parameters.</UtilityInjection>

## Wrapping multiple color blocks

Color blocks can be set to wrap if they can't fit on one line, by setting `wrap()`:

```php
use Filament\Tables\Columns\ColorColumn;

ColorColumn::make('color')
    ->wrap()
```

<Aside variant="tip">
    The "width" for wrapping is affected by the column label, so you may need to use a shorter or hidden label to wrap more tightly.
</Aside>

# Documentation for tables. File: 02-columns/06-select.md
---
title: Select column
---
import Aside from "@components/Aside.astro"
import AutoScreenshot from "@components/AutoScreenshot.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

The select column allows you to render a select field inside the table, which can be used to update that database record without needing to open a new page or a modal.

You must pass options to the column:

```php
use Filament\Tables\Columns\SelectColumn;

SelectColumn::make('status')
    ->options([
        'draft' => 'Draft',
        'reviewing' => 'Reviewing',
        'published' => 'Published',
    ])
```

<AutoScreenshot name="tables/columns/select/simple" alt="Select column" version="4.x" />

## Enabling the JavaScript select

By default, Filament uses the native HTML5 select. You may enable a more customizable JavaScript select using the `native(false)` method:

```php
use Filament\Tables\Columns\SelectColumn;

SelectColumn::make('status')
    ->options([
        'draft' => 'Draft',
        'reviewing' => 'Reviewing',
        'published' => 'Published',
    ])
    ->native(false)
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `native()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Searching options

You may enable a search input to allow easier access to many options, using the `searchableOptions()` method:

```php
use Filament\Tables\Columns\SelectColumn;

SelectColumn::make('author_id')
    ->label('Author')
    ->options(User::query()->pluck('name', 'id'))
    ->searchableOptions()
```

Optionally, you may pass a boolean value to control if the input should be searchable or not:

```php
use Filament\Tables\Columns\SelectColumn;

SelectColumn::make('author_id')
    ->label('Author')
    ->options(User::query()->pluck('name', 'id'))
    ->searchableOptions(FeatureFlag::active())
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `searchableOptions()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Returning custom search results

If you have lots of options and want to populate them based on a database search or other external data source, you can use the `getOptionsSearchResultsUsing()` and `getOptionLabelUsing()` methods instead of `options()`.

The `getOptionsSearchResultsUsing()` method accepts a callback that returns search results in `$key => $value` format. The current user's search is available as `$search`, and you should use that to filter your results.

The `getOptionLabelUsing()` method accepts a callback that transforms the selected option `$value` into a label. This is used when the form is first loaded when the user has not made a search yet. Otherwise, the label used to display the currently selected option would not be available.

Both `getOptionsSearchResultsUsing()` and `getOptionLabelUsing()` must be used on the select if you want to provide custom search results:

```php
use Filament\Tables\Columns\SelectColumn;

SelectColumn::make('author_id')
    ->searchableOptions()
    ->getOptionsSearchResultsUsing(fn (string $search): array => User::query()
        ->where('name', 'like', "%{$search}%")
        ->limit(50)
        ->pluck('name', 'id')
        ->all())
    ->getOptionLabelUsing(fn ($value): ?string => User::find($value)?->name),
```

`getOptionLabelUsing()` is crucial, since it provides Filament with the label of the selected option, so it doesn't need to execute a full search to find it. If an option is not valid, it should return `null`.

<UtilityInjection set="tableColumns" version="4.x" extras="Option value;;mixed;;$value;;The option value to retrieve the label for.||Search;;?string;;$search;;[<code>getOptionsSearchResultsUsing()</code> only] The current search input value, if the field is searchable.">You can inject various utilities into these functions as parameters.</UtilityInjection>

### Setting a custom loading message

When you're using a searchable select or multi-select, you may want to display a custom message while the options are loading. You can do this using the `optionsLoadingMessage()` method:

```php
use Filament\Tables\Columns\SelectColumn;

SelectColumn::make('author_id')
    ->optionsRelationship(name: 'author', titleAttribute: 'name')
    ->searchableOptions()
    ->optionsLoadingMessage('Loading authors...')
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `optionsLoadingMessage()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Setting a custom no search results message

When you're using a searchable select or multi-select, you may want to display a custom message when no search results are found. You can do this using the `noOptionsSearchResultsMessage()` method:

```php
use Filament\Tables\Columns\SelectColumn;

SelectColumn::make('author_id')
    ->optionsRelationship(name: 'author', titleAttribute: 'name')
    ->searchableOptions()
    ->noOptionsSearchResultsMessage('No authors found.')
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `noOptionsSearchResultsMessage()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Setting a custom search prompt

When you're using a searchable select or multi-select, you may want to display a custom message when the user has not yet entered a search term. You can do this using the `optionsSearchPrompt()` method:

```php
use Filament\Tables\Columns\SelectColumn;

SelectColumn::make('author_id')
    ->optionsRelationship(name: 'author', titleAttribute: 'name')
    ->searchableOptions(['name', 'email'])
    ->optionsSearchPrompt('Search authors by their name or email address')
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `optionsSearchPrompt()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Setting a custom searching message

When you're using a searchable select or multi-select, you may want to display a custom message while the search results are being loaded. You can do this using the `optionsSearchingMessage()` method:

```php
use Filament\Tables\Columns\SelectColumn;

SelectColumn::make('author_id')
    ->optionsRelationship(name: 'author', titleAttribute: 'name')
    ->searchableOptions()
    ->optionsSearchingMessage('Searching authors...')
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `optionsSearchingMessage()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Tweaking the search debounce

By default, Filament will wait 1000 milliseconds (1 second) before searching for options when the user types in a searchable select or multi-select. It will also wait 1000 milliseconds between searches, if the user is continuously typing into the search input. You can change this using the `optionsSearchDebounce()` method:

```php
use Filament\Tables\Columns\SelectColumn;

SelectColumn::make('author_id')
    ->optionsRelationship(name: 'author', titleAttribute: 'name')
    ->searchableOptions()
    ->optionsSearchDebounce(500)
```

Ensure that you are not lowering the debounce too much, as this may cause the select to become slow and unresponsive due to a high number of network requests to retrieve options from server.

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `optionsSearchDebounce()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Integrating with an Eloquent relationship

You may employ the `optionsRelationship()` method of the `SelectColumn` to configure a `BelongsTo` relationship to automatically retrieve options from. The `titleAttribute` is the name of a column that will be used to generate a label for each option:

```php
use Filament\Tables\Columns\SelectColumn;

SelectColumn::make('author_id')
    ->optionsRelationship(name: 'author', titleAttribute: 'name')
```

### Searching relationship options across multiple columns

By default, if the select is also searchable, Filament will return search results for the relationship based on the title column of the relationship. If you'd like to search across multiple columns, you can pass an array of columns to the `searchableOptions()` method:

```php
use Filament\Tables\Columns\SelectColumn;

SelectColumn::make('author_id')
    ->optionsRelationship(name: 'author', titleAttribute: 'name')
    ->searchableOptions(['name', 'email'])
```

### Preloading relationship options

If you'd like to populate the searchable options from the database when the page is loaded, instead of when the user searches, you can use the `preloadOptions()` method:

```php
use Filament\Tables\Columns\SelectColumn;

SelectColumn::make('author_id')
    ->optionsRelationship(name: 'author', titleAttribute: 'name')
    ->searchableOptions()
    ->preloadOptions()
```

Optionally, you may pass a boolean value to control if the input should be preloaded or not:

```php
use Filament\Tables\Columns\SelectColumn;

SelectColumn::make('author_id')
    ->optionsRelationship(name: 'author', titleAttribute: 'name')
    ->searchableOptions()
    ->preload(FeatureFlag::active())
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `preload()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

### Excluding the current record

When working with recursive relationships, you will likely want to remove the current record from the set of results.

This can be easily be done using the `ignoreRecord` argument:

```php
use Filament\Tables\Columns\SelectColumn;

SelectColumn::make('parent_id')
    ->optionsRelationship(name: 'parent', titleAttribute: 'name', ignoreRecord: true)
```

### Customizing the relationship query

You may customize the database query that retrieves options using the third parameter of the `optionsRelationship()` method:

```php
use Filament\Tables\Columns\SelectColumn;
use Illuminate\Database\Eloquent\Builder;

SelectColumn::make('author_id')
    ->optionsRelationship(
        name: 'author',
        titleAttribute: 'name',
        modifyQueryUsing: fn (Builder $query) => $query->withTrashed(),
    )
```

<UtilityInjection set="tableColumns" version="4.x" extras="Query;;Illuminate\Database\Eloquent\Builder;;$query;;The Eloquent query builder to modify.||Search;;?string;;$search;;The current search input value, if the field is searchable.">The `modifyQueryUsing` argument can inject various utilities into the function as parameters.</UtilityInjection>

### Customizing the relationship option labels

If you'd like to customize the label of each option, maybe to be more descriptive, or to concatenate a first and last name, you could use a virtual column in your database migration:

```php
$table->string('full_name')->virtualAs('concat(first_name, \' \', last_name)');
```

```php
use Filament\Tables\Columns\SelectColumn;

SelectColumn::make('author_id')
    ->optionsRelationship(name: 'author', titleAttribute: 'full_name')
```

Alternatively, you can use the `getOptionLabelFromRecordUsing()` method to transform an option's Eloquent model into a label:

```php
use Filament\Tables\Columns\SelectColumn;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;

SelectColumn::make('author_id')
    ->optionsRelationship(
        name: 'author',
        modifyQueryUsing: fn (Builder $query) => $query->orderBy('first_name')->orderBy('last_name'),
    )
    ->getOptionLabelFromRecordUsing(fn (Model $record) => "{$record->first_name} {$record->last_name}")
    ->searchableOptions(['first_name', 'last_name'])
```

<UtilityInjection set="tableColumns" version="4.x" extras="Eloquent record;;Illuminate\Database\Eloquent\Model;;$record;;The Eloquent record to get the option label for.">The `getOptionLabelFromRecordUsing()` method can inject various utilities into the function as parameters.</UtilityInjection>

### Remembering options

By default, when using `optionsRelationship()`, Filament will remember the options for the duration of the table page to improve performance. This means that the options function will only run once per table page instead of once per cell. You can disable this behavior using the `rememberOptions(false)` method:

```php
use Filament\Tables\Columns\SelectColumn;

SelectColumn::make('author_id')
    ->optionsRelationship(name: 'author', titleAttribute: 'name')
    ->rememberOptions(false)
```

<Aside variant="warning">
    When options are remembered, any record-specific options or disabled options will not work correctly, as the same options will be used for all records in the table. If you need record-specific options or disabled options, you should disable option remembering.
</Aside>

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `rememberOptions()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Allowing HTML in the option labels

By default, Filament will escape any HTML in the option labels. If you'd like to allow HTML, you can use the `allowOptionsHtml()` method:

```php
use Filament\Tables\Columns\SelectColumn;

SelectColumn::make('technology')
    ->options([
        'tailwind' => '<span class="text-blue-500">Tailwind</span>',
        'alpine' => '<span class="text-green-500">Alpine</span>',
        'laravel' => '<span class="text-red-500">Laravel</span>',
        'livewire' => '<span class="text-pink-500">Livewire</span>',
    ])
    ->searchableOptions()
    ->allowOptionsHtml()
```

<Aside variant="danger">
    Be aware that you will need to ensure that the HTML is safe to render, otherwise your application will be vulnerable to XSS attacks.
</Aside>

Optionally, you may pass a boolean value to control if the input should allow HTML or not:

```php
use Filament\Tables\Columns\SelectColumn;

SelectColumn::make('technology')
    ->options([
        'tailwind' => '<span class="text-blue-500">Tailwind</span>',
        'alpine' => '<span class="text-green-500">Alpine</span>',
        'laravel' => '<span class="text-red-500">Laravel</span>',
        'livewire' => '<span class="text-pink-500">Livewire</span>',
    ])
    ->searchableOptions()
    ->allowOptionsHtml(FeatureFlag::active())
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `allowOptionsHtml()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Wrap or truncate option labels

When using the JavaScript select, labels that exceed the width of the select element will wrap onto multiple lines by default. Alternatively, you may choose to truncate overflowing labels.

```php
use Filament\Tables\Columns\SelectColumn;

SelectColumn::make('truncate')
    ->wrapOptionLabels(false)
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `wrapOptionLabels()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Disable placeholder selection

You can prevent the placeholder (null option) from being selected using the `selectablePlaceholder(false)` method:

```php
use Filament\Tables\Columns\SelectColumn;

SelectColumn::make('status')
    ->options([
        'draft' => 'Draft',
        'reviewing' => 'Reviewing',
        'published' => 'Published',
    ])
    ->selectablePlaceholder(false)
```

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `selectablePlaceholder()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Disabling specific options

You can disable specific options using the `disableOptionWhen()` method. It accepts a closure, in which you can check if the option with a specific `$value` should be disabled:

```php
use Filament\Tables\Columns\SelectColumn;

SelectColumn::make('status')
    ->options([
        'draft' => 'Draft',
        'reviewing' => 'Reviewing',
        'published' => 'Published',
    ])
    ->default('draft')
    ->disableOptionWhen(fn (string $value): bool => $value === 'published')
```

<UtilityInjection set="tableColumns" version="4.x" extras="Option value;;mixed;;$value;;The value of the option to disable.||Option label;;string | Illuminate\Contracts\Support\Htmlable;;$label;;The label of the option to disable.">You can inject various utilities into the function as parameters.</UtilityInjection>

## Limiting the number of options

You can limit the number of options that are displayed in a searchable select or multi-select using the `optionsLimit()` method. The default is 50:

```php
use Filament\Tables\Columns\SelectColumn;

SelectColumn::make('author_id')
    ->optionsRelationship(name: 'author', titleAttribute: 'name')
    ->searchableOptions()
    ->optionsLimit(20)
```

Ensure that you are not raising the limit too high, as this may cause the select to become slow and unresponsive due to high in-browser memory usage.

<UtilityInjection set="tableColumns" version="4.x">As well as allowing a static value, the `optionsLimit()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Validation

You can validate the input by passing any [Laravel validation rules](https://laravel.com/docs/validation#available-validation-rules) in an array:

```php
use Filament\Tables\Columns\SelectColumn;

SelectColumn::make('status')
    ->options([
        'draft' => 'Draft',
        'reviewing' => 'Reviewing',
        'published' => 'Published',
    ])
    ->rules(['required'])
```

### Valid options validation (`in` rule)

The `in` rule ensures that users cannot select an option that is not in the list of options. This is an important rule for data integrity purposes, so Filament applies it by default to all select fields.

Since there are many ways for a select field to populate its options, and in many cases the options are not all loaded into the select by default and require searching to retrieve them, Filament uses the presence of a valid "option label" to determine whether the selected value exists. It also checks if that option is [disabled](#disabling-specific-options) or not.

If you are using a custom search query to retrieve options, you should ensure that the `getOptionLabelUsing()` method is defined, so that Filament can validate the selected value against the available options:

```php
use Filament\Tables\Columns\SelectColumn;

SelectColumn::make('author_id')
    ->searchableOptions()
    ->getOptionsSearchResultsUsing(fn (string $search): array => Author::query()
        ->where('name', 'like', "%{$search}%")
        ->limit(50)
        ->pluck('name', 'id')
        ->all())
    ->getOptionLabelUsing(fn (string $value): ?string => Author::find($value)?->name),
```

The `getOptionLabelUsing()` method should return `null` if the option is not valid, to allow Filament to determine that the selected value is not in the list of options. If the option is valid, it should return the label of the option.

If you are using the `optionsRelationship()` method, the `getOptionLabelUsing()` method will be automatically defined for you, so you don't need to worry about it.

## Lifecycle hooks

Hooks may be used to execute code at various points within the select's lifecycle:

```php
SelectColumn::make()
    ->beforeStateUpdated(function ($record, $state) {
        // Runs before the state is saved to the database.
    })
    ->afterStateUpdated(function ($record, $state) {
        // Runs after the state is saved to the database.
    })
```

# Documentation for tables. File: 02-columns/07-toggle.md
---
title: Toggle column
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Introduction

The toggle column allows you to render a toggle button inside the table, which can be used to update that database record without needing to open a new page or a modal:

```php
use Filament\Tables\Columns\ToggleColumn;

ToggleColumn::make('is_admin')
```

<AutoScreenshot name="tables/columns/toggle/simple" alt="Toggle column" version="4.x" />

## Lifecycle hooks

Hooks may be used to execute code at various points within the toggle's lifecycle:

```php
ToggleColumn::make()
    ->beforeStateUpdated(function ($record, $state) {
        // Runs before the state is saved to the database.
    })
    ->afterStateUpdated(function ($record, $state) {
        // Runs after the state is saved to the database.
    })
```

# Documentation for tables. File: 02-columns/08-text-input.md
---
title: Text input column
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Introduction

The text input column allows you to render a text input inside the table, which can be used to update that database record without needing to open a new page or a modal:

```php
use Filament\Tables\Columns\TextInputColumn;

TextInputColumn::make('email')
```

<AutoScreenshot name="tables/columns/text-input/simple" alt="Text input column" version="4.x" />

## Validation

You can validate the input by passing any [Laravel validation rules](https://laravel.com/docs/validation#available-validation-rules) in an array:

```php
use Filament\Tables\Columns\TextInputColumn;

TextInputColumn::make('name')
    ->rules(['required', 'max:255'])
```

## Customizing the HTML input type

You may use the `type()` method to pass a custom [HTML input type](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input#input_types):

```php
use Filament\Tables\Columns\TextInputColumn;

TextInputColumn::make('background_color')->type('color')
```

## Lifecycle hooks

Hooks may be used to execute code at various points within the input's lifecycle:

```php
TextInputColumn::make()
    ->beforeStateUpdated(function ($record, $state) {
        // Runs before the state is saved to the database.
    })
    ->afterStateUpdated(function ($record, $state) {
        // Runs after the state is saved to the database.
    })
```

# Documentation for tables. File: 02-columns/09-checkbox.md
---
title: Checkbox column
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Introduction

The checkbox column allows you to render a checkbox inside the table, which can be used to update that database record without needing to open a new page or a modal:

```php
use Filament\Tables\Columns\CheckboxColumn;

CheckboxColumn::make('is_admin')
```

<AutoScreenshot name="tables/columns/checkbox/simple" alt="Checkbox column" version="4.x" />

## Lifecycle hooks

Hooks may be used to execute code at various points within the checkbox's lifecycle:

```php
CheckboxColumn::make()
    ->beforeStateUpdated(function ($record, $state) {
        // Runs before the state is saved to the database.
    })
    ->afterStateUpdated(function ($record, $state) {
        // Runs after the state is saved to the database.
    })
```

# Documentation for tables. File: 02-columns/10-custom-columns.md
---
title: Custom columns
---
import Aside from "@components/Aside.astro"

## Introduction

You may create your own custom column classes and views, which you can reuse across your project, and even release as a plugin to the community.

To create a custom column class and view, you may use the following command:

```bash
php artisan make:filament-table-column AudioPlayerColumn
```

This will create the following component class:

```php
use Filament\Tables\Columns\Column;

class AudioPlayerColumn extends Column
{
    protected string $view = 'filament.tables.columns.audio-player-column';
}
```

It will also create a view file at `resources/views/filament/tables/columns/audio-player-column.blade.php`.

<Aside variant="info">
    Filament table columns are **not** Livewire components. Defining public properties and methods on a table column class will not make them accessible in the Blade view.
</Aside>

## Accessing the state of the column in the Blade view

Inside the Blade view, you may access the [state](overview#column-content-state) of the column using the `$getState()` function:

```blade
<div>
    {{ $getState() }}
</div>
```

## Accessing the Eloquent record in the Blade view

Inside the Blade view, you may access the current table row's Eloquent record using the `$record` variable:

```blade
<div>
    {{ $record->name }}
</div>
```

## Accessing the current Livewire component instance in the Blade view

Inside the Blade view, you may access the current Livewire component instance using `$this`:

```blade
@php
    use Filament\Resources\Users\RelationManagers\ConferencesRelationManager;
@endphp

<div>
    @if ($this instanceof ConferencesRelationManager)
        You are editing the conferences of a user.
    @endif
</div>
```

## Accessing the current column instance in the Blade view

Inside the Blade view, you may access the current column instance using `$column`. You can call public methods on this object to access other information that may not be available in variables:

```blade
<div>
    @if ($column->isLabelHidden())
        This is a new conference.
    @endif
</div>
```

## Adding a configuration method to a custom column class

You may add a public method to the custom column class that accepts a configuration value, stores it in a protected property, and returns it again from another public method:

```php
use Filament\Tables\Columns\Column;

class AudioPlayerColumn extends Column
{
    protected string $view = 'filament.tables.columns.audio-player-column';
    
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

Now, in the Blade view for the custom column, you may access the speed using the `$getSpeed()` function:

```blade
<div>
    {{ $getSpeed() }}
</div>
```

Any public method that you define on the custom column class can be accessed in the Blade view as a variable function in this way.

To pass the configuration value to the custom column class, you may use the public method:

```php
use App\Filament\Tables\Columns\AudioPlayerColumn;

AudioPlayerColumn::make('recording')
    ->speed(0.5)
```

## Allowing utility injection in a custom column configuration method

[Utility injection](overview#column-utility-injection) is a powerful feature of Filament that allows users to configure a component using functions that can access various utilities. You can allow utility injection by ensuring that the parameter type and property type of the configuration allows the user to pass a `Closure`. In the getter method, you should pass the configuration value to the `$this->evaluate()` method, which will inject utilities into the user's function if they pass one, or return the value if it is static:

```php
use Closure;
use Filament\Tables\Columns\Column;

class AudioPlayerColumn extends Column
{
    protected string $view = 'filament.tables.columns.audio-player-column';
    
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
use App\Filament\Tables\Columns\AudioPlayerColumn;

AudioPlayerColumn::make('recording')
    ->speed(fn (Conference $record): float => $record->isGlobal() ? 1 : 0.5)
```

# Documentation for tables. File: 03-filters/01-overview.md
---
title: Overview
---
import AutoScreenshot from "@components/AutoScreenshot.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

Filters allow you to define certain constraints on your data, and allow users to scope it to find the information they need. You put them in the `$table->filters()` method.

Filters may be created using the static `make()` method, passing its unique name. You should then pass a callback to `query()` which applies your filter's scope:

```php
use Filament\Tables\Filters\Filter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

public function table(Table $table): Table
{
    return $table
        ->filters([
            Filter::make('is_featured')
                ->query(fn (Builder $query): Builder => $query->where('is_featured', true))
            // ...
        ]);
}
```

<AutoScreenshot name="tables/filters/simple" alt="Table with filter" version="4.x" />

## Available filters

By default, using the `Filter::make()` method will render a checkbox form component. When the checkbox is on, the `query()` will be activated.

- You can also [replace the checkbox with a toggle](#using-a-toggle-button-instead-of-a-checkbox).
- You may use a [select filter](select) to allow users to select from a list of options, and filter using the selection.
- You can use a [ternary filter](ternary) to replace the checkbox with a select field to allow users to pick between 3 states - usually "true", "false" and "blank". This is useful for filtering boolean columns.
- The [trashed filter](ternary#filtering-soft-deletable-records) is a pre-built ternary filter that allows you to filter soft-deletable records.
- Using a [query builder](query-builder), users can create complex sets of filters, with an advanced user interface for combining constraints.
- You may build [custom filters](custom) with other form fields, to do whatever you want.

## Setting a label

By default, the label of the filter is generated from the name of the filter. You may customize this using the `label()` method:

```php
use Filament\Tables\Filters\Filter;

Filter::make('is_featured')
    ->label('Featured')
```

<UtilityInjection set="tableFilters" version="4.x">As well as allowing a static value, the `label()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

Customizing the label in this way is useful if you wish to use a [translation string for localization](https://laravel.com/docs/localization#retrieving-translation-strings):

```php
use Filament\Tables\Filters\Filter;

Filter::make('is_featured')
    ->label(__('filters.is_featured'))
```

## Customizing the filter schema

By default, creating a filter with the `Filter` class will render a [checkbox form component](../../forms/fields/checkbox). When the checkbox is checked, the `query()` function will be applied to the table's query, scoping the records in the table. When the checkbox is unchecked, the `query()` function will be removed from the table's query.

Filters are built entirely on Filament's form fields. They can render any combination of form fields, which users can then interact with to filter the table.

### Using a toggle button instead of a checkbox

The simplest example of managing the form field that is used for a filter is to replace the [checkbox](../../forms/fields/checkbox) with a [toggle button](../../forms/fields/toggle), using the `toggle()` method:

```php
use Filament\Tables\Filters\Filter;

Filter::make('is_featured')
    ->toggle()
```

<AutoScreenshot name="tables/filters/toggle" alt="Table with toggle filter" version="4.x" />

### Customizing the built-in filter form field

Whether you are using a checkbox, a [toggle](#using-a-toggle-button-instead-of-a-checkbox) or a [select](select), you can customize the built-in form field used for the filter, using the `modifyFormFieldUsing()` method. The method accepts a function with a `$field` parameter that gives you access to the form field object to customize:

```php
use Filament\Forms\Components\Checkbox;
use Filament\Tables\Filters\Filter;

Filter::make('is_featured')
    ->modifyFormFieldUsing(fn (Checkbox $field) => $field->inline(false))
```

<UtilityInjection set="tableFilters" version="4.x" extras="Field;;Filament\Forms\Components\Field;;$field;;The field object to modify.">The function passed to `modifyFormFieldUsing()` can inject various utilities as parameters.</UtilityInjection>

## Applying the filter by default

You may set a filter to be enabled by default, using the `default()` method:

```php
use Filament\Tables\Filters\Filter;

Filter::make('is_featured')
    ->default()
```

If you're using a [select filter](select), [visit the "applying select filters by default" section](select#applying-select-filters-by-default).

## Persisting filters in the user's session

To persist the table filters in the user's session, use the `persistFiltersInSession()` method:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->filters([
            // ...
        ])
        ->persistFiltersInSession();
}
```

## Live filters

By default, filter changes are deferred and do not affect the table, until the user clicks an "Apply" button. To disable this and make the filters "live" instead, use the `deferFilters(false)` method:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->filters([
            // ...
        ])
        ->deferFilters(false);
}
```

### Customizing the apply filters action

When deferring filters, you can customize the "Apply" button, using the `filtersApplyAction()` method, passing a closure that returns an action. All methods that are available to [customize action trigger buttons](../../actions/overview) can be used:

```php
use Filament\Actions\Action;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->filters([
            // ...
        ])
        ->filtersApplyAction(
            fn (Action $action) => $action
                ->link()
                ->label('Save filters to table'),
        );
}
```

## Deselecting records when filters change

By default, all records will be deselected when the filters change. Using the `deselectAllRecordsWhenFiltered(false)` method, you can disable this behavior:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->filters([
            // ...
        ])
        ->deselectAllRecordsWhenFiltered(false);
}
```

## Modifying the base query

By default, modifications to the Eloquent query performed in the `query()` method will be applied inside a scoped `where()` clause. This is to ensure that the query does not clash with any other filters that may be applied, especially those that use `orWhere()`.

However, the downside of this is that the `query()` method cannot be used to modify the query in other ways, such as removing global scopes, since the base query needs to be modified directly, not the scoped query.

To modify the base query directly, you may use the `baseQuery()` method, passing a closure that receives the base query:

```php
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;
use Filament\Tables\Filters\TernaryFilter;

TernaryFilter::make('trashed')
    // ...
    ->baseQuery(fn (Builder $query) => $query->withoutGlobalScopes([
        SoftDeletingScope::class,
    ]))
```

## Customizing the filters trigger action

To customize the filters trigger buttons, you may use the `filtersTriggerAction()` method, passing a closure that returns an action. All methods that are available to [customize action trigger buttons](../../actions/overview) can be used:

```php
use Filament\Actions\Action;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->filters([
            // ...
        ])
        ->filtersTriggerAction(
            fn (Action $action) => $action
                ->button()
                ->label('Filter'),
        );
}
```

<AutoScreenshot name="tables/filters/custom-trigger-action" alt="Table with custom filters trigger action" version="4.x" />

## Filter utility injection

The vast majority of methods used to configure filters accept functions as parameters instead of hardcoded values:

```php
use App\Models\Author;
use Filament\Tables\Filters\SelectFilter;

SelectFilter::make('author')
    ->options(fn (): array => Author::query()->pluck('name', 'id')->all())
```

This alone unlocks many customization possibilities.

The package is also able to inject many utilities to use inside these functions, as parameters. All customization methods that accept functions as arguments can inject utilities.

These injected utilities require specific parameter names to be used. Otherwise, Filament doesn't know what to inject.

### Injecting the current filter instance

If you wish to access the current filter instance, define a `$filter` parameter:

```php
use Filament\Tables\Filters\BaseFilter;

function (BaseFilter $filter) {
    // ...
}
```

### Injecting the current Livewire component instance

If you wish to access the current Livewire component instance that the table belongs to, define a `$livewire` parameter:

```php
use Filament\Tables\Contracts\HasTable;

function (HasTable $livewire) {
    // ...
}
```

### Injecting the current table instance

If you wish to access the current table configuration instance that the filter belongs to, define a `$table` parameter:

```php
use Filament\Tables\Table;

function (Table $table) {
    // ...
}
```

### Injecting multiple utilities

The parameters are injected dynamically using reflection, so you are able to combine multiple parameters in any order:

```php
use Filament\Tables\Contracts\HasTable;
use Filament\Tables\Table;

function (HasTable $livewire, Table $table) {
    // ...
}
```

### Injecting dependencies from Laravel's container

You may inject anything from Laravel's container like normal, alongside utilities:

```php
use Filament\Tables\Table;
use Illuminate\Http\Request;

function (Request $request, Table $table) {
    // ...
}
```

# Documentation for tables. File: 03-filters/02-select.md
---
title: Select filters
---
import AutoScreenshot from "@components/AutoScreenshot.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Introduction

Often, you will want to use a [select field](../../forms/fields/select) instead of a checkbox. This is especially true when you want to filter a column based on a set of pre-defined options that the user can choose from. To do this, you can create a filter using the `SelectFilter` class:

```php
use Filament\Tables\Filters\SelectFilter;

SelectFilter::make('status')
    ->options([
        'draft' => 'Draft',
        'reviewing' => 'Reviewing',
        'published' => 'Published',
    ])
```

The `options()` that are passed to the filter are the same as those that are passed to the [select field](../../forms/fields/select).

<UtilityInjection set="tableFilters" version="4.x">As well as allowing a static value, the `options()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Customizing the column used by a select filter

Select filters do not require a custom `query()` method. The column name used to scope the query is the name of the filter. To customize this, you may use the `attribute()` method:

```php
use Filament\Tables\Filters\SelectFilter;

SelectFilter::make('status')
    ->options([
        'draft' => 'Draft',
        'reviewing' => 'Reviewing',
        'published' => 'Published',
    ])
    ->attribute('status_id')
```

<UtilityInjection set="tableFilters" version="4.x">As well as allowing a static value, the `attribute()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>

## Multi-select filters

These allow the user to [select multiple options](../../forms/select#multi-select) to apply the filter to their table. For example, a status filter may present the user with a few status options to pick from and filter the table using. When the user selects multiple options, the table will be filtered to show records that match any of the selected options. You can enable this behavior using the `multiple()` method:

```php
use Filament\Tables\Filters\SelectFilter;

SelectFilter::make('status')
    ->multiple()
    ->options([
        'draft' => 'Draft',
        'reviewing' => 'Reviewing',
        'published' => 'Published',
    ])
```

## Relationship select filters

Select filters are also able to automatically populate themselves based on a relationship. For example, if your table has a `author` relationship with a `name` column, you may use `relationship()` to filter the records belonging to an author:

```php
use Filament\Tables\Filters\SelectFilter;

SelectFilter::make('author')
    ->relationship('author', 'name')
```

### Preloading the select filter relationship options

If you'd like to populate the searchable options from the database when the page is loaded, instead of when the user searches, you can use the `preload()` method:

```php
use Filament\Tables\Filters\SelectFilter;

SelectFilter::make('author')
    ->relationship('author', 'name')
    ->searchable()
    ->preload()
```

### Filtering empty relationships

By default, upon selecting an option, all records that have an empty relationship will be excluded from the results. If you want to introduce an additional "None" option for the user to select, which will include all records that do not have a relationship, you can use the `hasEmptyOption()` argument of the `relationship()` method:

```php
use Filament\Tables\Filters\SelectFilter;

SelectFilter::make('author')
    ->relationship('author', 'name', hasEmptyOption: true)
```

You can rename the "None" option using the `emptyRelationshipOptionLabel()` method:

```php
use Filament\Tables\Filters\SelectFilter;

SelectFilter::make('author')
    ->relationship('author', 'name', hasEmptyOption: true)
    ->emptyRelationshipOptionLabel('No author')
```

### Customizing the select filter relationship query

You may customize the database query that retrieves options using the third parameter of the `relationship()` method:

```php
use Filament\Tables\Filters\SelectFilter;
use Illuminate\Database\Eloquent\Builder;

SelectFilter::make('author')
    ->relationship('author', 'name', fn (Builder $query) => $query->withTrashed())
```

### Searching select filter options

You may enable a search input to allow easier access to many options, using the `searchable()` method:

```php
use Filament\Tables\Filters\SelectFilter;

SelectFilter::make('author')
    ->relationship('author', 'name')
    ->searchable()
```

## Disable placeholder selection

You can remove the placeholder (null option), which disables the filter so all options are applied, using the `selectablePlaceholder()` method:

```php
use Filament\Tables\Filters\SelectFilter;

SelectFilter::make('status')
    ->options([
        'draft' => 'Draft',
        'reviewing' => 'Reviewing',
        'published' => 'Published',
    ])
    ->default('draft')
    ->selectablePlaceholder(false)
```

## Applying select filters by default

You may set a select filter to be enabled by default, using the `default()` method. If using a single select filter, the `default()` method accepts a single option value. If using a `multiple()` select filter, the `default()` method accepts an array of option values:

```php
use Filament\Tables\Filters\SelectFilter;

SelectFilter::make('status')
    ->options([
        'draft' => 'Draft',
        'reviewing' => 'Reviewing',
        'published' => 'Published',
    ])
    ->default('draft')

SelectFilter::make('status')
    ->options([
        'draft' => 'Draft',
        'reviewing' => 'Reviewing',
        'published' => 'Published',
    ])
    ->multiple()
    ->default(['draft', 'reviewing'])
```

<UtilityInjection set="tableFilters" version="4.x">As well as allowing a static value, the `default()` method also accepts a function to dynamically calculate it. You can inject various utilities into the function as parameters.</UtilityInjection>


# Documentation for tables. File: 03-filters/03-ternary.md
---
title: Ternary filters
---

## Introduction

Ternary filters allow you to easily create a select filter which has three states - usually true, false and blank. To filter a column named `is_admin` to be `true` or `false`, you may use the ternary filter:

```php
use Filament\Tables\Filters\TernaryFilter;

TernaryFilter::make('is_admin')
```

## Using a ternary filter with a nullable column

Another common pattern is to use a nullable column. For example, when filtering verified and unverified users using the `email_verified_at` column, unverified users have a null timestamp in this column. To apply that logic, you may use the `nullable()` method:

```php
use Filament\Tables\Filters\TernaryFilter;

TernaryFilter::make('email_verified_at')
    ->nullable()
```

## Customizing the column used by a ternary filter

The column name used to scope the query is the name of the filter. To customize this, you may use the `attribute()` method:

```php
use Filament\Tables\Filters\TernaryFilter;

TernaryFilter::make('verified')
    ->nullable()
    ->attribute('status_id')
```

## Customizing the ternary filter option labels

You may customize the labels used for each state of the ternary filter. The true option label can be customized using the `trueLabel()` method. The false option label can be customized using the `falseLabel()` method. The blank (default) option label can be customized using the `placeholder()` method:

```php
use Illuminate\Database\Eloquent\Builder;
use Filament\Tables\Filters\TernaryFilter;

TernaryFilter::make('email_verified_at')
    ->label('Email verification')
    ->nullable()
    ->placeholder('All users')
    ->trueLabel('Verified users')
    ->falseLabel('Not verified users')
```

## Customizing how a ternary filter modifies the query

You may customize how the query changes for each state of the ternary filter, use the `queries()` method:

```php
use Illuminate\Database\Eloquent\Builder;
use Filament\Tables\Filters\TernaryFilter;

TernaryFilter::make('email_verified_at')
    ->label('Email verification')
    ->placeholder('All users')
    ->trueLabel('Verified users')
    ->falseLabel('Not verified users')
    ->queries(
        true: fn (Builder $query) => $query->whereNotNull('email_verified_at'),
        false: fn (Builder $query) => $query->whereNull('email_verified_at'),
        blank: fn (Builder $query) => $query, // In this example, we do not want to filter the query when it is blank.
    )
```

## Filtering soft-deletable records

The `TrashedFilter` can be used to filter soft-deleted records. It is a type of ternary filter that is built-in to Filament. You can use it like so:

```php
use Filament\Tables\Filters\TrashedFilter;

TrashedFilter::make()
```

# Documentation for tables. File: 03-filters/04-query-builder.md
---
title: Query builder
---

## Introduction

The query builder allows you to define a complex set of conditions to filter the data in your table. It is able to handle unlimited nesting of conditions, which you can group together with "and" and "or" operations.

To use it, you need to define a set of "constraints" that will be used to filter the data. Filament includes some built-in constraints, that follow common data types, but you can also define your own custom constraints.

You can add a query builder to any table using the `QueryBuilder` filter:

```php
use Filament\Tables\Filters\QueryBuilder;
use Filament\Tables\Filters\QueryBuilder\Constraints\BooleanConstraint;
use Filament\Tables\Filters\QueryBuilder\Constraints\DateConstraint;
use Filament\Tables\Filters\QueryBuilder\Constraints\NumberConstraint;
use Filament\Tables\Filters\QueryBuilder\Constraints\RelationshipConstraint;
use Filament\Tables\Filters\QueryBuilder\Constraints\RelationshipConstraint\Operators\IsRelatedToOperator;
use Filament\Tables\Filters\QueryBuilder\Constraints\SelectConstraint;
use Filament\Tables\Filters\QueryBuilder\Constraints\TextConstraint;

QueryBuilder::make()
    ->constraints([
        TextConstraint::make('name'),
        BooleanConstraint::make('is_visible'),
        NumberConstraint::make('stock'),
        SelectConstraint::make('status')
            ->options([
                'draft' => 'Draft',
                'reviewing' => 'Reviewing',
                'published' => 'Published',
            ])
            ->multiple(),
        DateConstraint::make('created_at'),
        RelationshipConstraint::make('categories')
            ->multiple()
            ->selectable(
                IsRelatedToOperator::make()
                    ->titleAttribute('name')
                    ->searchable()
                    ->multiple(),
            ),
        NumberConstraint::make('reviewsRating')
            ->relationship('reviews', 'rating')
            ->integer(),
    ])
```

When deeply nesting the query builder, you might need to increase the amount of space that the filters can consume. One way of doing this is to [position the filters above the table content](layout#displaying-filters-above-the-table-content):

```php
use Filament\Tables\Enums\FiltersLayout;
use Filament\Tables\Filters\QueryBuilder;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->filters([
            QueryBuilder::make()
                ->constraints([
                    // ...
                ]),
        ], layout: FiltersLayout::AboveContent);
}
```

## Available constraints

Filament ships with many different constraints that you can use out of the box. You can also [create your own custom constraints](#creating-custom-constraints):

- [Text constraint](#text-constraints)
- [Boolean constraint](#boolean-constraints)
- [Number constraint](#number-constraints)
- [Date constraint](#date-constraints)
- [Select constraint](#select-constraints)
- [Relationship constraint](#relationship-constraints)

### Text constraints

Text constraints allow you to filter text fields. They can be used to filter any text field, including via relationships.

```php
use Filament\Tables\Filters\QueryBuilder\Constraints\TextConstraint;

TextConstraint::make('name') // Filter the `name` column

TextConstraint::make('creatorName')
    ->relationship(name: 'creator', titleAttribute: 'name') // Filter the `name` column on the `creator` relationship
```

By default, the following operators are available:

- Contains - filters a column to contain the search term
- Does not contain - filters a column to not contain the search term
- Starts with - filters a column to start with the search term
- Does not start with - filters a column to not start with the search term
- Ends with - filters a column to end with the search term
- Does not end with - filters a column to not end with the search term
- Equals - filters a column to equal the search term
- Does not equal - filters a column to not equal the search term
- Is filled - filters a column to not be empty
- Is blank - filters a column to be empty

### Boolean constraints

Boolean constraints allow you to filter boolean fields. They can be used to filter any boolean field, including via relationships.

```php
use Filament\Tables\Filters\QueryBuilder\Constraints\BooleanConstraint;

BooleanConstraint::make('is_visible') // Filter the `is_visible` column

BooleanConstraint::make('creatorIsAdmin')
    ->relationship(name: 'creator', titleAttribute: 'is_admin') // Filter the `is_admin` column on the `creator` relationship
```

By default, the following operators are available:

- Is true - filters a column to be `true`
- Is false - filters a column to be `false`

### Number constraints

Number constraints allow you to filter numeric fields. They can be used to filter any numeric field, including via relationships.

```php
use Filament\Tables\Filters\QueryBuilder\Constraints\NumberConstraint;

NumberConstraint::make('stock') // Filter the `stock` column

NumberConstraint::make('ordersItemCount')
    ->relationship(name: 'orders', titleAttribute: 'item_count') // Filter the `item_count` column on the `orders` relationship
```

By default, the following operators are available:

- Is minimum - filters a column to be greater than or equal to the search number
- Is less than - filters a column to be less than the search number
- Is maximum - filters a column to be less than or equal to the search number
- Is greater than - filters a column to be greater than the search number
- Equals - filters a column to equal the search number
- Does not equal - filters a column to not equal the search number
- Is filled - filters a column to not be empty
- Is blank - filters a column to be empty

When using `relationship()` with a number constraint, users also have the ability to "aggregate" related records. This means that they can filter the column to be the sum, average, minimum or maximum of all the related records at once.

#### Integer constraints

By default, number constraints will allow decimal values. If you'd like to only allow integer values, you can use the `integer()` method:

```php
use Filament\Tables\Filters\QueryBuilder\Constraints\NumberConstraint;

NumberConstraint::make('stock')
    ->integer()
```

### Date constraints

Date constraints allow you to filter date fields. They can be used to filter any date field, including via relationships.

```php
use Filament\Tables\Filters\QueryBuilder\Constraints\DateConstraint;

DateConstraint::make('created_at') // Filter the `created_at` column

DateConstraint::make('creatorCreatedAt')
    ->relationship(name: 'creator', titleAttribute: 'created_at') // Filter the `created_at` column on the `creator` relationship
```

By default, the following operators are available:

- Is after - filters a column to be after the search date
- Is not after - filters a column to not be after the search date, or to be the same date
- Is before - filters a column to be before the search date
- Is not before - filters a column to not be before the search date, or to be the same date
- Is date - filters a column to be the same date as the search date
- Is not date - filters a column to not be the same date as the search date
- Is month - filters a column to be in the same month as the selected month
- Is not month - filters a column to not be in the same month as the selected month
- Is year - filters a column to be in the same year as the searched year
- Is not year - filters a column to not be in the same year as the searched year

### Select constraints

Select constraints allow you to filter fields using a select field. They can be used to filter any field, including via relationships.

```php
use Filament\Tables\Filters\QueryBuilder\Constraints\SelectConstraint;

SelectConstraint::make('status') // Filter the `status` column
    ->options([
        'draft' => 'Draft',
        'reviewing' => 'Reviewing',
        'published' => 'Published',
    ])
    
SelectConstraint::make('creatorStatus')
    ->relationship(name: 'creator', titleAttribute: 'department') // Filter the `department` column on the `creator` relationship
    ->options([
        'sales' => 'Sales',
        'marketing' => 'Marketing',
        'engineering' => 'Engineering',
        'purchasing' => 'Purchasing',
    ])
```

#### Searchable select constraints

By default, select constraints will not allow the user to search the options. If you'd like to allow the user to search the options, you can use the `searchable()` method:

```php
use Filament\Tables\Filters\QueryBuilder\Constraints\SelectConstraint;

SelectConstraint::make('status')
    ->searchable()
    ->options([
        'draft' => 'Draft',
        'reviewing' => 'Reviewing',
        'published' => 'Published',
    ])
```

#### Multi-select constraints

By default, select constraints will only allow the user to select a single option. If you'd like to allow the user to select multiple options, you can use the `multiple()` method:

```php
use Filament\Tables\Filters\QueryBuilder\Constraints\SelectConstraint;

SelectConstraint::make('status')
    ->multiple()
    ->options([
        'draft' => 'Draft',
        'reviewing' => 'Reviewing',
        'published' => 'Published',
    ])
```

When the user selects multiple options, the table will be filtered to show records that match any of the selected options.

### Relationship constraints

Relationship constraints allow you to filter fields using data about a relationship:

```php
use Filament\Tables\Filters\QueryBuilder\Constraints\RelationshipConstraint;
use Filament\Tables\Filters\QueryBuilder\Constraints\RelationshipConstraint\Operators\IsRelatedToOperator;

RelationshipConstraint::make('creator') // Filter the `creator` relationship
    ->selectable(
        IsRelatedToOperator::make()
            ->titleAttribute('name')
            ->searchable()
            ->multiple(),
    )
```

The `IsRelatedToOperator` is used to configure the "Is / Contains" and "Is not / Does not contain" operators. It provides a select field which allows the user to filter the relationship by which records are attached to it. The `titleAttribute()` method is used to specify which attribute should be used to identify each related record in the list. The `searchable()` method makes the list searchable. The `multiple()` method allows the user to select multiple related records, and if they do, the table will be filtered to show records that match any of the selected related records.

#### Multiple relationships

By default, relationship constraints only include operators that are appropriate for filtering a singular relationship, like a `BelongsTo`. If you have a relationship such as a `HasMany` or `BelongsToMany`, you may wish to mark the constraint as `multiple()`:

```php
use Filament\Tables\Filters\QueryBuilder\Constraints\RelationshipConstraint;

RelationshipConstraint::make('categories')
    ->multiple()
```

This will add the following operators to the constraint:

- Has minimum - filters a column to have at least the specified number of related records
- Has less than - filters a column to have less than the specified number of related records
- Has maximum - filters a column to have at most the specified number of related records
- Has more than - filters a column to have more than the specified number of related records
- Has - filters a column to have the specified number of related records
- Does not have - filters a column to not have the specified number of related records

#### Empty relationship constraints

The `RelationshipConstraint` does not support [`nullable()`](#nullable-constraints) in the same way as other constraints.

If the relationship is `multiple()`, then the constraint will show an option to filter out "empty" relationships. This means that the relationship has no related records. If your relationship is singular, then you can use the `emptyable()` method to show an option to filter out "empty" relationships:

```php
use Filament\Tables\Filters\QueryBuilder\Constraints\RelationshipConstraint;

RelationshipConstraint::make('creator')
    ->emptyable()
```

If you have a `multiple()` relationship that must always have at least 1 related record, then you can use the `emptyable(false)` method to hide the option to filter out "empty" relationships:

```php
use Filament\Tables\Filters\QueryBuilder\Constraints\RelationshipConstraint;

RelationshipConstraint::make('categories')
    ->emptyable(false)
```

#### Nullable constraints

By default, constraints will not show an option to filter `null` values. If you'd like to show an option to filter `null` values, you can use the `nullable()` method:

```php
use Filament\Tables\Filters\QueryBuilder\Constraints\TextConstraint;

TextConstraint::make('name')
    ->nullable()
```

Now, the following operators are also available:

- Is filled - filters a column to not be empty
- Is blank - filters a column to be empty

## Scoping relationships

When you use the `relationship()` method on a constraint, you can scope the relationship to filter the related records using the `modifyQueryUsing` argument:

```php
use Filament\Tables\Filters\QueryBuilder\Constraints\TextConstraint;
use Illuminate\Database\Eloquent\Builder;

TextConstraint::make('adminCreatorName')
    ->relationship(
        name: 'creator',
        titleAttribute: 'name',
        modifyQueryUsing: fn (Builder $query) => $query->where('is_admin', true),
    )
```

## Customizing the constraint icon

Each constraint type has a default [icon](../../styling/icons), which is displayed next to the label in the picker. You can customize the icon for a constraint by passing its name to the `icon()` method:

```php
use Filament\Tables\Filters\QueryBuilder\Constraints\TextConstraint;

TextConstraint::make('author')
    ->relationship(name: 'author', titleAttribute: 'name')
    ->icon('heroicon-m-user')
```

## Overriding the default operators

Each constraint type has a set of default operators, which you can customize by using the `operators()`method:

```php
use Filament\Tables\Filters\QueryBuilder\Constraints\Operators\IsFilledOperator;
use Filament\Tables\Filters\QueryBuilder\Constraints\TextConstraint;

TextConstraint::make('author')
    ->relationship(name: 'author', titleAttribute: 'name')
    ->operators([
        IsFilledOperator::make(),
    ])
```

This will remove all operators, and register the `EqualsOperator`.

If you'd like to add an operator to the end of the list, use `pushOperators()` instead:

```php
use Filament\Tables\Filters\QueryBuilder\Constraints\Operators\IsFilledOperator;
use Filament\Tables\Filters\QueryBuilder\Constraints\TextConstraint;

TextConstraint::make('author')
    ->relationship(name: 'author', titleAttribute: 'name')
    ->pushOperators([
        IsFilledOperator::class,
    ])
```

If you'd like to add an operator to the start of the list, use `unshiftOperators()` instead:

```php
use Filament\Tables\Filters\QueryBuilder\Constraints\Operators\IsFilledOperator;
use Filament\Tables\Filters\QueryBuilder\Constraints\TextConstraint;

TextConstraint::make('author')
    ->relationship(name: 'author', titleAttribute: 'name')
    ->unshiftOperators([
        IsFilledOperator::class,
    ])
```

## Creating custom constraints

Custom constraints can be created "inline" with other constraints using the `Constraint::make()` method. You should also pass an [icon](#customizing-the-constraint-icon) to the `icon()` method:

```php
use Filament\Tables\Filters\QueryBuilder\Constraints\Constraint;

Constraint::make('subscribed')
    ->icon('heroicon-m-bell')
    ->operators([
        // ...
    ]),
```

If you want to customize the label of the constraint, you can use the `label()` method:

```php
use Filament\Tables\Filters\QueryBuilder\Constraints\Constraint;

Constraint::make('subscribed')
    ->label('Subscribed to updates')
    ->icon('heroicon-m-bell')
    ->operators([
        // ...
    ]),
```

Now, you must [define operators](#creating-custom-operators) for the constraint. These are options that you can pick from to filter the column. If the column is [nullable](#nullable-constraints), you can also register that built-in operator for your custom constraint:

```php
use Filament\Tables\Filters\QueryBuilder\Constraints\Constraint;
use Filament\Tables\Filters\QueryBuilder\Constraints\Operators\IsFilledOperator;

Constraint::make('subscribed')
    ->label('Subscribed to updates')
    ->icon('heroicon-m-bell')
    ->operators([
        // ...
        IsFilledOperator::class,
    ]),
```

### Creating custom operators

Custom operators can be created using the `Operator::make()` method:

```php
use Filament\Tables\Filters\QueryBuilder\Constraints\Operators\Operator;

Operator::make('subscribed')
    ->label(fn (bool $isInverse): string => $isInverse ? 'Not subscribed' : 'Subscribed')
    ->summary(fn (bool $isInverse): string => $isInverse ? 'You are not subscribed' : 'You are subscribed')
    ->baseQuery(fn (Builder $query, bool $isInverse) => $query->{$isInverse ? 'whereDoesntHave' : 'whereHas'}(
        'subscriptions.user',
        fn (Builder $query) => $query->whereKey(auth()->user()),
    )),
```

In this example, the operator is able to filter records based on whether or not the authenticated user is subscribed to the record. A subscription is recorded in the `subscriptions` relationship of the table.

The `baseQuery()` method is used to define the query that will be used to filter the records. The `$isInverse` argument is `false` when the "Subscribed" option is selected, and `true` when the "Not subscribed" option is selected. The function is applied to the base query of the table, where `whereHas()` can be used. If your function does not need to be applied to the base query of the table, like when you are using a simple `where()` or `whereIn()`, you can use the `query()` method instead, which has the bonus of being able to be used inside nested "OR" groups.

The `label()` method is used to render the options in the operator select. Two options are registered for each operator, one for when the operator is not inverted, and one for when it is inverted.

The `summary()` method is used in the header of the constraint when it is applied to the query, to provide an overview of the active constraint.

## Customizing the constraint picker

### Changing the number of columns in the constraint picker

The constraint picker has only 1 column. You may customize it by passing a number of columns to `constraintPickerColumns()`:

```php
use Filament\Tables\Filters\QueryBuilder;

QueryBuilder::make()
    ->constraintPickerColumns(2)
    ->constraints([
        // ...
    ])
```

This method can be used in a couple of different ways:

- You can pass an integer like `constraintPickerColumns(2)`. This integer is the number of columns used on the `lg` breakpoint and higher. All smaller devices will have just 1 column.
- You can pass an array, where the key is the breakpoint and the value is the number of columns. For example, `constraintPickerColumns(['md' => 2, 'xl' => 4])` will create a 2 column layout on medium devices, and a 4 column layout on extra large devices. The default breakpoint for smaller devices uses 1 column, unless you use a `default` array key.

Breakpoints (`sm`, `md`, `lg`, `xl`, `2xl`) are defined by Tailwind, and can be found in the [Tailwind documentation](https://tailwindcss.com/docs/responsive-design#overview).

### Increasing the width of the constraint picker

When you [increase the number of columns](#changing-the-number-of-columns-in-the-constraint-picker), the width of the dropdown should increase incrementally to handle the additional columns. If you'd like more control, you can manually set a maximum width for the dropdown using the `constraintPickerWidth()` method. Options correspond to [Tailwind's max-width scale](https://tailwindcss.com/docs/max-width). The options are `xs`, `sm`, `md`, `lg`, `xl`, `2xl`, `3xl`, `4xl`, `5xl`, `6xl`, `7xl`:

```php
use Filament\Tables\Filters\QueryBuilder;

QueryBuilder::make()
    ->constraintPickerColumns(3)
    ->constraintPickerWidth('2xl')
    ->constraints([
        // ...
    ])
```

# Documentation for tables. File: 03-filters/05-custom.md
---
title: Custom filters
---
import AutoScreenshot from "@components/AutoScreenshot.astro"
import UtilityInjection from "@components/UtilityInjection.astro"

## Custom filter schemas

You may use [schema components](../../schemas) to create custom filters. The data from the custom filter schema is available in the `$data` array of the `query()` callback:

```php
use Filament\Forms\Components\DatePicker;
use Filament\Tables\Filters\Filter;
use Illuminate\Database\Eloquent\Builder;

Filter::make('created_at')
    ->schema([
        DatePicker::make('created_from'),
        DatePicker::make('created_until'),
    ])
    ->query(function (Builder $query, array $data): Builder {
        return $query
            ->when(
                $data['created_from'],
                fn (Builder $query, $date): Builder => $query->whereDate('created_at', '>=', $date),
            )
            ->when(
                $data['created_until'],
                fn (Builder $query, $date): Builder => $query->whereDate('created_at', '<=', $date),
            );
    })
```

<UtilityInjection set="formFields" version="4.x" extras="Query;;Illuminate\Database\Eloquent\Builder;;$query;;The Eloquent query builder to modify.||Data;;array<string, mixed>;;$data;;The data from the filter's form fields.">The `query()` function can inject various utilities into the function as parameters.</UtilityInjection>

<AutoScreenshot name="tables/filters/custom-form" alt="Table with custom filter schema" version="4.x" />

### Setting default values for custom filter fields

To customize the default value of a field in a custom filter schema, you may use the `default()` method:

```php
use Filament\Forms\Components\DatePicker;
use Filament\Tables\Filters\Filter;

Filter::make('created_at')
    ->schema([
        DatePicker::make('created_from'),
        DatePicker::make('created_until')
            ->default(now()),
    ])
```

## Active indicators

When a filter is active, an indicator is displayed above the table content to signal that the table query has been scoped.

<AutoScreenshot name="tables/filters/indicators" alt="Table with filter indicators" version="4.x" />

By default, the label of the filter is used as the indicator. You can override this using the `indicator()` method:

```php
use Filament\Tables\Filters\Filter;

Filter::make('is_admin')
    ->label('Administrators only?')
    ->indicator('Administrators')
```

If you are using a [custom filter schema](#custom-filter-schemas), you should use [`indicateUsing()`](#custom-active-indicators) to display an active indicator.

Please note: if you do not have an indicator for your filter, then the badge-count of how many filters are active in the table will not include that filter.

### Custom active indicators

Not all indicators are simple, so you may need to use `indicateUsing()` to customize which indicators should be shown at any time.

For example, if you have a custom date filter, you may create a custom indicator that formats the selected date:

```php
use Carbon\Carbon;
use Filament\Forms\Components\DatePicker;
use Filament\Tables\Filters\Filter;

Filter::make('created_at')
    ->schema([DatePicker::make('date')])
    // ...
    ->indicateUsing(function (array $data): ?string {
        if (! $data['date']) {
            return null;
        }

        return 'Created at ' . Carbon::parse($data['date'])->toFormattedDateString();
    })
```

### Multiple active indicators

You may even render multiple indicators at once, by returning an array of `Indicator` objects. If you have different fields associated with different indicators, you should set the field using the `removeField()` method on the `Indicator` object to ensure that the correct field is reset when the filter is removed:

```php
use Carbon\Carbon;
use Filament\Forms\Components\DatePicker;
use Filament\Tables\Filters\Filter;
use Filament\Tables\Filters\Indicator;

Filter::make('created_at')
    ->schema([
        DatePicker::make('from'),
        DatePicker::make('until'),
    ])
    // ...
    ->indicateUsing(function (array $data): array {
        $indicators = [];

        if ($data['from'] ?? null) {
            $indicators[] = Indicator::make('Created from ' . Carbon::parse($data['from'])->toFormattedDateString())
                ->removeField('from');
        }

        if ($data['until'] ?? null) {
            $indicators[] = Indicator::make('Created until ' . Carbon::parse($data['until'])->toFormattedDateString())
                ->removeField('until');
        }

        return $indicators;
    })
```

### Preventing indicators from being removed

You can prevent users from removing an indicator using `removable(false)` on an `Indicator` object:

```php
use Carbon\Carbon;
use Filament\Tables\Filters\Indicator;

Indicator::make('Created from ' . Carbon::parse($data['from'])->toFormattedDateString())
    ->removable(false)
```

# Documentation for tables. File: 03-filters/06-layout.md
---
title: Filter layout
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Positioning filters into grid columns

To change the number of columns that filters may occupy, you may use the `filtersFormColumns()` method:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->filters([
            // ...
        ])
        ->filtersFormColumns(3);
}
```

## Controlling the width of the filters dropdown

To customize the dropdown width, you may use the `filtersFormWidth()` method, and specify a width - `ExtraSmall`, `Small`, `Medium`, `Large`, `ExtraLarge`, `TwoExtraLarge`, `ThreeExtraLarge`, `FourExtraLarge`, `FiveExtraLarge`, `SixExtraLarge` or `SevenExtraLarge`. By default, the width is `ExtraSmall`:

```php
use Filament\Support\Enums\Width;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->filters([
            // ...
        ])
        ->filtersFormWidth(Width::FourExtraLarge);
}
```

## Controlling the maximum height of the filters dropdown

To add a maximum height to the filters' dropdown content, so that they scroll, you may use the `filtersFormMaxHeight()` method, passing a [CSS length](https://developer.mozilla.org/en-US/docs/Web/CSS/length):

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->filters([
            // ...
        ])
        ->filtersFormMaxHeight('400px');
}
```

## Displaying filters in a modal

To render the filters in a modal instead of in a dropdown, you may use:

```php
use Filament\Tables\Enums\FiltersLayout;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->filters([
            // ...
        ], layout: FiltersLayout::Modal);
}
```

You may use the [trigger action API](overview#customizing-the-filters-trigger-action) to [customize the modal](../actions/modals), including [using a `slideOver()`](../actions/modals#using-a-slide-over-instead-of-a-modal).

## Displaying filters above the table content

To render the filters above the table content instead of in a dropdown, you may use:

```php
use Filament\Tables\Enums\FiltersLayout;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->filters([
            // ...
        ], layout: FiltersLayout::AboveContent);
}
```

<AutoScreenshot name="tables/filters/above-content" alt="Table with filters above content" version="4.x" />

### Allowing filters above the table content to be collapsed

To allow the filters above the table content to be collapsed, you may use:

```php
use Filament\Tables\Enums\FiltersLayout;

public function table(Table $table): Table
{
    return $table
        ->filters([
            // ...
        ], layout: FiltersLayout::AboveContentCollapsible);
}
```

## Displaying filters below the table content

To render the filters below the table content instead of in a dropdown, you may use:

```php
use Filament\Tables\Enums\FiltersLayout;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->filters([
            // ...
        ], layout: FiltersLayout::BelowContent);
}
```

<AutoScreenshot name="tables/filters/below-content" alt="Table with filters below content" version="4.x" />

## Hiding the filter indicators

To hide the active filters indicators above the table, you may use `hiddenFilterIndicators()`:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->filters([
            // ...
        ])
        ->hiddenFilterIndicators();
}
```

## Customizing the filter form schema

You may customize the [form schema](../../schemas/layouts) of the entire filter form at once, in order to rearrange filters into your desired layout, and use any of the [layout components](../../schemas/layout) available to forms. To do this, use the `filterFormSchema()` method, passing a closure function that receives the array of defined `$filters` that you can insert:

```php
use Filament\Schemas\Components\Section;
use Filament\Tables\Filters\Filter;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->filters([
            Filter::make('is_featured'),
            Filter::make('published_at'),
            Filter::make('author'),
        ])
        ->filtersFormColumns(2)
        ->filtersFormSchema(fn (array $filters): array => [
            Section::make('Visibility')
                ->description('These filters affect the visibility of the records in the table.')
                ->schema([
                    $filters['is_featured'],
                    $filters['published_at'],
                ])
                    ->columns(2)
                ->columnSpanFull(),
            $filters['author'],
        ]);
}
```

In this example, we have put two of the filters inside a [section](../../schemas/sections) component, and used the `columns()` method to specify that the section should have two columns. We have also used the `columnSpanFull()` method to specify that the section should span the full width of the filter form, which is also 2 columns wide. We have inserted each filter into the form schema by using the filter's name as the key in the `$filters` array.

# Documentation for tables. File: 04-actions.md
---
title: Actions
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Introduction

Filament's tables can use [Actions](../actions). They are buttons that can be added to the [end of any table row](#record-actions), or even in the [header](#header-actions) or [toolbar](#toolbar-actions) of a table. For instance, you may want an action to "create" a new record in the header, and then "edit" and "delete" actions on each row. [Bulk actions](#bulk-actions) can be used to execute code when records in the table are selected. Additionally, actions can be added to any [table column](#column-actions), such that each cell in that column is a trigger for your action.

It's highly advised that you read the documentation about [customizing action trigger buttons](../actions/overview) and [action modals](../actions/modals) to that you are aware of the full capabilities of actions.

## Record actions

Action buttons can be rendered at the end of each table row. You can put them in the `$table->recordActions()` method:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->recordActions([
            // ...
        ]);
}
```

Actions may be created using the static `make()` method, passing its unique name.

You can then pass a function to `action()` which executes the task, or a function to `url()` which creates a link:

```php
use App\Models\Post;
use Filament\Actions\Action;

Action::make('edit')
    ->url(fn (Post $record): string => route('posts.edit', $record))
    ->openUrlInNewTab()

Action::make('delete')
    ->requiresConfirmation()
    ->action(fn (Post $record) => $record->delete())
```

All methods on the action accept callback functions, where you can access the current table `$record` that was clicked.

<AutoScreenshot name="tables/actions/simple" alt="Table with actions" version="4.x" />

### Positioning record actions before columns

By default, the record actions in your table are rendered in the final cell of each row. You may move them before the columns by using the `position` argument:

```php
use Filament\Tables\Enums\RecordActionsPosition;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->recordActions([
            // ...
        ], position: RecordActionsPosition::BeforeColumns);
}
```

<AutoScreenshot name="tables/actions/before-columns" alt="Table with actions before columns" version="4.x" />

### Positioning record actions before the checkbox column

By default, the record actions in your table are rendered in the final cell of each row. You may move them before the checkbox column by using the `position` argument:

```php
use Filament\Tables\Enums\RecordActionsPosition;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->recordActions([
            // ...
        ], position: RecordActionsPosition::BeforeCells);
}
```

### Global record action settings

To customize the default configuration used for ungrouped record actions, you can use `modifyUngroupedRecordActionsUsing()` from a [`Table::configureUsing()` function](overview#global-settings) in the `boot()` method of a service provider:

```php
use Filament\Actions\Action;
use Filament\Tables\Table;

Table::configureUsing(function (Table $table): void {
    $table
        ->modifyUngroupedRecordActionsUsing(fn (Action $action) => $action->iconButton());
});
```

<AutoScreenshot name="tables/actions/before-cells" alt="Table with actions before cells" version="4.x" />

### Accessing the selected table rows

You may want an action to be able to access all the selected rows in the table. Usually, this is done with a [bulk action](#bulk-actions) in the header of the table. However, you may want to do this with a row action, where the selected rows provide context for the action.

For example, you may want to have a row action that copies the row data to all the selected records. To force the table to be selectable, even if there aren't bulk actions defined, you need to use the `selectable()` method. To allow the action to access the selected records, you need to use the `accessSelectedRecords()` method. Then, you can use the `$selectedRecords` parameter in your action to access the selected records:

```php
use Filament\Actions\Action;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Database\Eloquent\Model;

public function table(Table $table): Table
{
    return $table
        ->selectable()
        ->recordActions([
            Action::make('copyToSelected')
                ->accessSelectedRecords()
                ->action(function (Model $record, Collection $selectedRecords) {
                    $selectedRecords->each(
                        fn (Model $selectedRecord) => $selectedRecord->update([
                            'is_active' => $record->is_active,
                        ]),
                    );
                }),
        ]);
}
```

## Bulk actions

Tables also support "bulk actions". These can be used when the user selects rows in the table. Traditionally, when rows are selected, a "bulk actions" button appears. When the user clicks this button, they are presented with a dropdown menu of actions to choose from. You can put them in the `$table->toolbarActions()` or `$table->headerActions()` methods:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->toolbarActions([
            // ...
        ]);
}
```

Bulk actions may be created using the static `make()` method, passing its unique name. You should then pass a callback to `action()` which executes the task:

```php
use Filament\Actions\BulkAction;
use Illuminate\Database\Eloquent\Collection;

BulkAction::make('delete')
    ->requiresConfirmation()
    ->action(fn (Collection $records) => $records->each->delete())
```

The function allows you to access the current table `$records` that are selected. It is an Eloquent collection of models.

<AutoScreenshot name="tables/actions/bulk" alt="Table with bulk action" version="4.x" />

### Authorizing bulk actions

When using a bulk action, you may check a policy method for each record that is selected. This is useful for checking if the user has permission to perform the action on each record. You can use the `authorizeIndividualRecords()` method, passing the name of a policy method, which will be called for each record. If the policy denies authorization, the record will not be present in the bulk action's `$records` parameter:

```php
use Filament\Actions\BulkAction;
use Illuminate\Database\Eloquent\Collection;

BulkAction::make('delete')
    ->requiresConfirmation()
    ->authorizeIndividualRecords('delete')
    ->action(fn (Collection $records) => $records->each->delete())
```

### Bulk action notifications

After a bulk action is completed, you may want to send a notification to the user with a summary of the action's success. This is especially useful if you're using [authorization](#authorizing-bulk-actions) for individual records, as the user may not know how many records were actually affected.

To send a notification after the bulk action is completed, you should set the `successNotificationTitle()` and `failureNotificationTitle()`:

- The `successNotificationTitle()` is used as the title of the notification when all records have been successfully processed.
- The `failureNotificationTitle()` is used as the title of the notification when some or all of the records failed to be processed. By passing a function to this methods, you can inject the `$successCount` and `$failureCount` parameters, to provide this information to the user.

For example:

```php
use Filament\Actions\BulkAction;
use Illuminate\Database\Eloquent\Collection;

BulkAction::make('delete')
    ->requiresConfirmation()
    ->authorizeIndividualRecords('delete')
    ->action(fn (Collection $records) => $records->each->delete())
    ->successNotificationTitle('Deleted users')
    ->failureNotificationTitle(function (int $successCount, int $totalCount): string {
        if ($successCount) {
            return "{$successCount} of {$totalCount} users deleted";
        }

        return 'Failed to delete any users';
    })
```

You can also use a special [authorization response object](https://laravel.com/docs/authorization#policy-responses) in a policy method to provide a custom message about why the authorization failed. The special object is called `DenyResponse` and replaces `Response::deny()`, allowing the developer to pass a function as the message which can receive information about how many records were denied by that authorization check:

```php
use App\Models\User;
use Filament\Support\Authorization\DenyResponse;
use Illuminate\Auth\Access\Response;

class UserPolicy
{
    public function delete(User $user, User $model): bool | Response
    {
        if (! $model->is_admin) {
            return true;
        }

        return DenyResponse::make('cannot_delete_admin', message: function (int $failureCount, int $totalCount): string {
            if (($failureCount === 1) && ($totalCount === 1)) {
                return 'You cannot delete an admin user.';
            }

            if ($failureCount === $totalCount) {
                return 'All users selected were admin users.';
            }

            if ($failureCount === 1) {
                return 'One of the selected users was an admin user.';
            }

            return "{$failureCount} of the selected users were admin users.";
        });
    }
}
```

The first argument to the `make()` method is a unique key to identify that failure type. If multiple failures of that key are detected, they are grouped together and only one message is generated. If there are multiple points of failure in the policy method, each response object can have its own key, and the messages will be concatenated together in the notification.

#### Reporting failures in bulk action processing

Alongside [individual record authorization](#authorizing-bulk-actions) messages, you can also report failures in the bulk action processing itself. This is useful if you want to provide a message for each record that failed to be processed for a particular reason, even after authorization passes. This is done by injecting the `Action` instance into the `action()` function, and calling the `reportBulkProcessingFailure()` method on it, passing a key and message function similar to `DenyResponse`:

```php
use Filament\Actions\BulkAction;
use Illuminate\Database\Eloquent\Collection;

BulkAction::make('delete')
    ->requiresConfirmation()
    ->authorizeIndividualRecords('delete')
    ->action(function (BulkAction $action, Collection $records) {
        $records->each(function (Model $record) use ($action) {
            $record->delete() || $action->reportBulkProcessingFailure(
                'deletion_failed',
                message: function (int $failureCount, int $totalCount): string {
                    if (($failureCount === 1) && ($totalCount === 1)) {
                        return 'One user failed to delete.';
                    }
        
                    if ($failureCount === $totalCount) {
                        return 'All users failed to delete.';
                    }
        
                    if ($failureCount === 1) {
                        return 'One of the selected users failed to delete.';
                    }
        
                    return "{$failureCount} of the selected users failed to delete.";
                },
            );
        });
    })
    ->successNotificationTitle('Deleted users')
    ->failureNotificationTitle(function (int $successCount, int $totalCount): string {
        if ($successCount) {
            return "{$successCount} of {$totalCount} users deleted";
        }

        return 'Failed to delete any users';
    })
```

The `delete()` method on an Eloquent model returns `false` if the deletion fails, so you can use that to determine if the record was deleted successfully. The `reportBulkProcessingFailure()` method will then add a failure message to the notification, which will be displayed when the action is completed.

The `reportBulkProcessingFailure()` method can be called at multiple points during the action execution for different reasons, but you should only call it once per record. You should not proceed with the action for that particular record once you have called the method for it.

### Grouping bulk actions

You may use a `BulkActionGroup` object to [group multiple bulk actions together](../actions/grouping-actions) in a dropdown. Any bulk actions that remain outside the `BulkActionGroup` will be rendered next to the dropdown's trigger button:

```php
use Filament\Actions\BulkAction;
use Filament\Actions\BulkActionGroup;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->toolbarActions([
            BulkActionGroup::make([
                BulkAction::make('delete')
                    ->requiresConfirmation()
                    ->action(fn (Collection $records) => $records->each->delete()),
                BulkAction::make('forceDelete')
                    ->requiresConfirmation()
                    ->action(fn (Collection $records) => $records->each->forceDelete()),
            ]),
            BulkAction::make('export')->button()->action(fn (Collection $records) => ...),
        ]);
}
```

Alternatively, if all of your bulk actions are grouped, you can use the shorthand `groupedBulkActions()` method:

```php
use Filament\Actions\BulkAction;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->groupedBulkActions([
            BulkAction::make('delete')
                ->requiresConfirmation()
                ->action(fn (Collection $records) => $records->each->delete()),
            BulkAction::make('forceDelete')
                ->requiresConfirmation()
                ->action(fn (Collection $records) => $records->each->forceDelete()),
        ]);
}
```

### Deselecting records once a bulk action has finished

You may deselect the records after a bulk action has been executed using the `deselectRecordsAfterCompletion()` method:

```php
use Filament\Actions\BulkAction;
use Illuminate\Database\Eloquent\Collection;

BulkAction::make('delete')
    ->action(fn (Collection $records) => $records->each->delete())
    ->deselectRecordsAfterCompletion()
```

### Disabling bulk actions for some rows

You may conditionally disable bulk actions for a specific record:

```php
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Model;

public function table(Table $table): Table
{
    return $table
        ->toolbarActions([
            // ...
        ])
        ->checkIfRecordIsSelectableUsing(
            fn (Model $record): bool => $record->status === Status::Enabled,
        );
}
```

### Limiting the number of selectable records

You may restrict how many records the user can select in total:

```php
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Model;

public function table(Table $table): Table
{
    return $table
        ->toolbarActions([
            // ...
        ])
        ->maxSelectableRecords(4);
}
```

### Preventing bulk-selection of all pages

The `selectCurrentPageOnly()` method can be used to prevent the user from easily bulk-selecting all records in the table at once, and instead only allows them to select one page at a time:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->toolbarActions([
            // ...
        ])
        ->selectCurrentPageOnly();
}
```

### Improving the performance of bulk actions

By default, a bulk action will load all Eloquent records into memory before passing them to the `action()` function.

If you are processing a large number of records, you may want to use the `chunkSelectedRecords()` method to fetch a smaller number of records at a time. This will reduce the memory usage of your application:

```php
use Filament\Actions\BulkAction;
use Illuminate\Support\LazyCollection;

BulkAction::make()
    ->chunkSelectedRecords(250)
    ->action(function (LazyCollection $records) {
        // Process the records...
    })
```

You can still loop through the `$records` collection as normal, but the collection will be a `LazyCollection` instead of a normal collection.

You can also prevent Filament from fetching the Eloquent models in the first place, and instead just pass the IDs of the selected records to the `action()` function. This is useful if you are processing a large number of records, and you don't need to load them into memory:

```php
use Filament\Actions\BulkAction;
use Illuminate\Support\Collection;

BulkAction::make()
    ->fetchSelectedRecords(false)
    ->action(function (Collection $records) {
        // Process the records...
    })
```

## Header actions

Both actions and [bulk actions](#bulk-actions) can be rendered in the header of the table. You can put them in the `$table->headerActions()` method:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->headerActions([
            // ...
        ]);
}
```

This is useful for things like "create" actions, which are not related to any specific table row, or bulk actions that need to be more visible.

<AutoScreenshot name="tables/actions/header" alt="Table with header actions" version="4.x" />

## Toolbar actions

Both actions and [bulk actions](#bulk-actions) can be rendered in the toolbar of the table. You can put them in the `$table->toolbarActions()` method:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->toolbarActions([
            // ...
        ]);
}
```

This is useful for things like "create" actions, which are not related to any specific table row, or bulk actions that need to be more visible.

<AutoScreenshot name="tables/actions/toolbar" alt="Table with toolbar actions" version="4.x" />

## Column actions

Actions can be added to columns, such that when a cell in that column is clicked, it acts as the trigger for an action. You can learn more about [column actions](columns/overview#triggering-actions) in the documentation.

## Grouping actions

You may use an `ActionGroup` object to group multiple table actions together in a dropdown:

```php
use Filament\Actions\ActionGroup;
use Filament\Actions\DeleteAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->recordActions([
            ActionGroup::make([
                ViewAction::make(),
                EditAction::make(),
                DeleteAction::make(),
            ]),
            // ...
        ]);
}
```

You may find out more about customizing action groups in the [Actions documentation](../actions/grouping-actions).

<AutoScreenshot name="tables/actions/group" alt="Table with action group" version="4.x" />

# Documentation for tables. File: 05-layout.md
---
title: Layout
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## The problem with traditional table layouts

Traditional tables are notorious for having bad responsiveness. On mobile, there is only so much flexibility you have when rendering content that is horizontally long:

- Allow the user to scroll horizontally to see more table content
- Hide non-important columns on smaller devices

Both of these are possible with Filament. Tables automatically scroll horizontally when they overflow anyway, and you may choose to show and hide columns based on the responsive [breakpoint](https://tailwindcss.com/docs/responsive-design#overview) of the browser. To do this, you may use a `visibleFrom()` or `hiddenFrom()` method:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('slug')
    ->visibleFrom('md')
```

This is fine, but there is still a glaring issue - **on mobile, the user is unable to see much information in a table row at once without scrolling**.

Thankfully, Filament lets you build responsive table-like interfaces, without touching HTML or CSS. These layouts let you define exactly where content appears in a table row, at each responsive breakpoint.

<AutoScreenshot name="tables/layout/demo" alt="Table with responsive layout" version="4.x" />

<AutoScreenshot name="tables/layout/demo/mobile" alt="Table with responsive layout on mobile" version="4.x" />

## Allowing columns to stack on mobile

Let's introduce a component - `Split`:

```php
use Filament\Support\Enums\FontWeight;
use Filament\Tables\Columns\Layout\Split;
use Filament\Tables\Columns\TextColumn;

Split::make([
    ImageColumn::make('avatar')
        ->circular(),
    TextColumn::make('name')
        ->weight(FontWeight::Bold)
        ->searchable()
        ->sortable(),
    TextColumn::make('email'),
])
```

<AutoScreenshot name="tables/layout/split" alt="Table with a split layout" version="4.x" />

<AutoScreenshot name="tables/layout/split/mobile" alt="Table with a split layout on mobile" version="4.x" />

A `Split` component is used to wrap around columns, and allow them to stack on mobile.

By default, columns within a split will appear aside each other all the time. However, you may choose a responsive [breakpoint](https://tailwindcss.com/docs/responsive-design#overview) where this behavior starts `from()`. Before this point, the columns will stack on top of each other:

```php
use Filament\Support\Enums\FontWeight;
use Filament\Tables\Columns\Layout\Split;
use Filament\Tables\Columns\ImageColumn;
use Filament\Tables\Columns\TextColumn;

Split::make([
    ImageColumn::make('avatar')
        ->circular(),
    TextColumn::make('name')
        ->weight(FontWeight::Bold)
        ->searchable()
        ->sortable(),
    TextColumn::make('email'),
])->from('md')
```

In this example, the columns will only appear horizontally aside each other from `md` [breakpoint](https://tailwindcss.com/docs/responsive-design#overview) devices onwards:

<AutoScreenshot name="tables/layout/split-desktop" alt="Table with a split layout on desktop" version="4.x" />

<AutoScreenshot name="tables/layout/split-desktop/mobile" alt="Table with a stacked layout on mobile" version="4.x" />

### Preventing a column from creating whitespace

Splits, like table columns, will automatically adjust their whitespace to ensure that each column has proportionate separation. You can prevent this from happening, using `grow(false)`. In this example, we will make sure that the avatar image will sit tightly against the name column:

```php
use Filament\Support\Enums\FontWeight;
use Filament\Tables\Columns\Layout\Split;
use Filament\Tables\Columns\ImageColumn;
use Filament\Tables\Columns\TextColumn;

Split::make([
    ImageColumn::make('avatar')
        ->circular()
        ->grow(false),
    TextColumn::make('name')
        ->weight(FontWeight::Bold)
        ->searchable()
        ->sortable(),
    TextColumn::make('email'),
])
```

The other columns which are allowed to `grow()` will adjust to consume the newly-freed space:

<AutoScreenshot name="tables/layout/grow-disabled" alt="Table with a column that doesn't grow" version="4.x" />

<AutoScreenshot name="tables/layout/grow-disabled/mobile" alt="Table with a column that doesn't grow on mobile" version="4.x" />

### Stacking within a split

Inside a split, you may stack multiple columns on top of each other vertically. This allows you to display more data inside fewer columns on desktop:

```php
use Filament\Support\Enums\FontWeight;
use Filament\Tables\Columns\Layout\Split;
use Filament\Tables\Columns\Layout\Stack;
use Filament\Tables\Columns\ImageColumn;
use Filament\Tables\Columns\TextColumn;

Split::make([
    ImageColumn::make('avatar')
        ->circular(),
    TextColumn::make('name')
        ->weight(FontWeight::Bold)
        ->searchable()
        ->sortable(),
    Stack::make([
        TextColumn::make('phone')
            ->icon('heroicon-m-phone'),
        TextColumn::make('email')
            ->icon('heroicon-m-envelope'),
    ]),
])
```

<AutoScreenshot name="tables/layout/stack" alt="Table with a stack" version="4.x" />

<AutoScreenshot name="tables/layout/stack/mobile" alt="Table with a stack on mobile" version="4.x" />

#### Hiding a stack on mobile

Similar to individual columns, you may choose to hide a stack based on the responsive [breakpoint](https://tailwindcss.com/docs/responsive-design#overview) of the browser. To do this, you may use a `visibleFrom()` method:

```php
use Filament\Support\Enums\FontWeight;
use Filament\Tables\Columns\Layout\Split;
use Filament\Tables\Columns\Layout\Stack;
use Filament\Tables\Columns\ImageColumn;
use Filament\Tables\Columns\TextColumn;

Split::make([
    ImageColumn::make('avatar')
        ->circular(),
    TextColumn::make('name')
        ->weight(FontWeight::Bold)
        ->searchable()
        ->sortable(),
    Stack::make([
        TextColumn::make('phone')
            ->icon('heroicon-m-phone'),
        TextColumn::make('email')
            ->icon('heroicon-m-envelope'),
    ])->visibleFrom('md'),
])
```

<AutoScreenshot name="tables/layout/stack-hidden-on-mobile" alt="Table with a stack" version="4.x" />

<AutoScreenshot name="tables/layout/stack-hidden-on-mobile/mobile" alt="Table with no stack on mobile" version="4.x" />

#### Aligning stacked content

By default, columns within a stack are aligned to the start. You may choose to align columns within a stack to the `Alignment::Center` or `Alignment::End`:

```php
use Filament\Support\Enums\Alignment;
use Filament\Support\Enums\FontWeight;
use Filament\Tables\Columns\Layout\Split;
use Filament\Tables\Columns\Layout\Stack;
use Filament\Tables\Columns\ImageColumn;
use Filament\Tables\Columns\TextColumn;

Split::make([
    ImageColumn::make('avatar')
        ->circular(),
    TextColumn::make('name')
        ->weight(FontWeight::Bold)
        ->searchable()
        ->sortable(),
    Stack::make([
        TextColumn::make('phone')
            ->icon('heroicon-m-phone')
            ->grow(false),
        TextColumn::make('email')
            ->icon('heroicon-m-envelope')
            ->grow(false),
    ])
        ->alignment(Alignment::End)
        ->visibleFrom('md'),
])
```

Ensure that the columns within the stack have `grow(false)` set, otherwise they will stretch to fill the entire width of the stack and follow their own alignment configuration instead of the stack's.

<AutoScreenshot name="tables/layout/stack-aligned-right" alt="Table with a stack aligned right" version="4.x" />

#### Spacing stacked content

By default, stacked content has no vertical padding between columns. To add some, you may use the `space()` method, which accepts either `1`, `2`, or `3`, corresponding to [Tailwind's spacing scale](https://tailwindcss.com/docs/space):

```php
use Filament\Tables\Columns\Layout\Stack;
use Filament\Tables\Columns\TextColumn;

Stack::make([
    TextColumn::make('phone')
        ->icon('heroicon-m-phone'),
    TextColumn::make('email')
        ->icon('heroicon-m-envelope'),
])->space(1)
```

## Controlling column width using a grid

Sometimes, using a `Split` creates inconsistent widths when columns contain lots of content. This is because it's powered by Flexbox internally and each row individually controls how much space is allocated to content.

Instead, you may use a `Grid` layout, which uses CSS Grid Layout to allow you to control column widths:

```php
use Filament\Tables\Columns\Layout\Grid;
use Filament\Tables\Columns\TextColumn;

Grid::make([
    'lg' => 2,
])
    ->schema([
        TextColumn::make('phone')
            ->icon('heroicon-m-phone'),
        TextColumn::make('email')
            ->icon('heroicon-m-envelope'),
    ])
```

These columns will always consume equal width within the grid, from the `lg` [breakpoint](https://tailwindcss.com/docs/responsive-design#overview).

You may choose to customize the number of columns within the grid at other breakpoints:

```php
use Filament\Tables\Columns\Layout\Grid;
use Filament\Tables\Columns\Layout\Stack;
use Filament\Tables\Columns\TextColumn;

Grid::make([
    'lg' => 2,
    '2xl' => 4,
])
    ->schema([
        Stack::make([
            TextColumn::make('name'),
            TextColumn::make('job'),
        ]),
        TextColumn::make('phone')
            ->icon('heroicon-m-phone'),
        TextColumn::make('email')
            ->icon('heroicon-m-envelope'),
    ])
```

And you can even control how many grid columns will be consumed by each component at each [breakpoint](https://tailwindcss.com/docs/responsive-design#overview):

```php
use Filament\Tables\Columns\Layout\Grid;
use Filament\Tables\Columns\Layout\Stack;
use Filament\Tables\Columns\TextColumn;

Grid::make([
    'lg' => 2,
    '2xl' => 5,
])
    ->schema([
        Stack::make([
            TextColumn::make('name'),
            TextColumn::make('job'),
        ])->columnSpan([
            'lg' => 'full',
            '2xl' => 2,
        ]),
        TextColumn::make('phone')
            ->icon('heroicon-m-phone')
            ->columnSpan([
                '2xl' => 2,
            ]),
        TextColumn::make('email')
            ->icon('heroicon-m-envelope'),
    ])
```

## Collapsible content

When you're using a column layout like split or stack, then you can also add collapsible content. This is very useful for when you don't want to display all data in the table at once, but still want it to be accessible to the user if they need to access it, without navigating away.

Split and stack components can be made `collapsible()`, but there is also a dedicated `Panel` component that provides a pre-styled background color and border radius, to separate the collapsible content from the rest:

```php
use Filament\Support\Enums\FontWeight;
use Filament\Tables\Columns\Layout\Panel;
use Filament\Tables\Columns\Layout\Split;
use Filament\Tables\Columns\Layout\Stack;
use Filament\Tables\Columns\ImageColumn;
use Filament\Tables\Columns\TextColumn;

[
    Split::make([
        ImageColumn::make('avatar')
            ->circular(),
        TextColumn::make('name')
            ->weight(FontWeight::Bold)
            ->searchable()
            ->sortable(),
    ]),
    Panel::make([
        Stack::make([
            TextColumn::make('phone')
                ->icon('heroicon-m-phone'),
            TextColumn::make('email')
                ->icon('heroicon-m-envelope'),
        ]),
    ])->collapsible(),
]
```

You can expand a panel by default using the `collapsed(false)` method:

```php
use Filament\Tables\Columns\Layout\Panel;
use Filament\Tables\Columns\Layout\Split;
use Filament\Tables\Columns\TextColumn;

Panel::make([
    Split::make([
        TextColumn::make('phone')
            ->icon('heroicon-m-phone'),
        TextColumn::make('email')
            ->icon('heroicon-m-envelope'),
    ])->from('md'),
])->collapsed(false)
```

<AutoScreenshot name="tables/layout/collapsible" alt="Table with collapsible content" version="4.x" />

<AutoScreenshot name="tables/layout/collapsible/mobile" alt="Table with collapsible content on mobile" version="4.x" />

## Arranging records into a grid

Sometimes, you may find that your data fits into a grid format better than a list. Filament can handle that too!

Simply use the `$table->contentGrid()` method:

```php
use Filament\Tables\Columns\Layout\Stack;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->columns([
            Stack::make([
                // Columns
            ]),
        ])
        ->contentGrid([
            'md' => 2,
            'xl' => 3,
        ]);
}
```

In this example, the rows will be displayed in a grid:

- On mobile, they will be displayed in 1 column only.
- From the `md` [breakpoint](https://tailwindcss.com/docs/responsive-design#overview), they will be displayed in 2 columns.
- From the `xl` [breakpoint](https://tailwindcss.com/docs/responsive-design#overview) onwards, they will be displayed in 3 columns.

These settings are fully customizable, any [breakpoint](https://tailwindcss.com/docs/responsive-design#overview) from `sm` to `2xl` can contain `1` to `12` columns.

<AutoScreenshot name="tables/layout/grid" alt="Table with grid layout" version="4.x" />

<AutoScreenshot name="tables/layout/grid/mobile" alt="Table with grid layout on mobile" version="4.x" />

## Custom HTML

You may add custom HTML to your table using a `View` component. It can even be `collapsible()`:

```php
use Filament\Support\Enums\FontWeight;
use Filament\Tables\Columns\Layout\Split;
use Filament\Tables\Columns\Layout\View;
use Filament\Tables\Columns\ImageColumn;
use Filament\Tables\Columns\TextColumn;

[
    Split::make([
        ImageColumn::make('avatar')
            ->circular(),
        TextColumn::make('name')
            ->weight(FontWeight::Bold)
            ->searchable()
            ->sortable(),
    ]),
    View::make('users.table.collapsible-row-content')
        ->collapsible(),
]
```

Now, create a `/resources/views/users/table/collapsible-row-content.blade.php` file, and add in your HTML. You can access the table record using `$getRecord()`:

```blade
<p class="px-4 py-3 bg-gray-100 rounded-lg">
    <span class="font-medium">
        Email address:
    </span>

    <span>
        {{ $getRecord()->email }}
    </span>
</p>
```

### Embedding other components

You could even pass in columns or other layout components to the `components()` method:

```php
use Filament\Support\Enums\FontWeight;
use Filament\Tables\Columns\Layout\Split;
use Filament\Tables\Columns\Layout\View;
use Filament\Tables\Columns\ImageColumn;
use Filament\Tables\Columns\TextColumn;

[
    Split::make([
        ImageColumn::make('avatar')
            ->circular(),
        TextColumn::make('name')
            ->weight(FontWeight::Bold)
            ->searchable()
            ->sortable(),
    ]),
    View::make('users.table.collapsible-row-content')
        ->components([
            TextColumn::make('email')
                ->icon('heroicon-m-envelope'),
        ])
        ->collapsible(),
]
```

Now, render the components in the Blade file:

```blade
<div class="px-4 py-3 bg-gray-100 rounded-lg">
    @foreach ($getComponents() as $layoutComponent)
        {{ $layoutComponent
            ->record($getRecord())
            ->recordKey($getRecordKey())
            ->rowLoop($getRowLoop())
            ->renderInLayout() }}
    @endforeach
</div>
```

# Documentation for tables. File: 06-summaries.md
---
title: Summaries
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Introduction

You may render a "summary" section below your table content. This is great for displaying the results of calculations such as averages, sums, counts, and ranges of the data in your table.

By default, there will be a single summary line for the current page of data, and an additional summary line for the totals for all data if multiple pages are available. You may also add summaries for [groups](grouping) of records, see ["Summarising groups of rows"](#summarising-groups-of-rows).

"Summarizer" objects can be added to any [table column](columns) using the `summarize()` method:

```php
use Filament\Tables\Columns\Summarizers\Average;
use Filament\Tables\Columns\TextColumn;

TextColumn::make('rating')
    ->summarize(Average::make())
```

Multiple "summarizers" may be added to the same column:

```php
use Filament\Tables\Columns\Summarizers\Average;
use Filament\Tables\Columns\Summarizers\Range;
use Filament\Tables\Columns\TextColumn;

TextColumn::make('rating')
    ->numeric()
    ->summarize([
        Average::make(),
        Range::make(),
    ])
```

> The first column in a table may not use summarizers. That column is used to render the heading and subheading/s of the summary section.

<AutoScreenshot name="tables/summaries" alt="Table with summaries" version="4.x" />

## Available summarizers

Filament ships with four types of summarizer:

- [Average](#average)
- [Count](#count)
- [Range](#range)
- [Sum](#sum)

You may also [create your own custom summarizers](#custom-summaries) to display data in whatever way you wish.

## Average

Average can be used to calculate the average of all values in the dataset:

```php
use Filament\Tables\Columns\Summarizers\Average;
use Filament\Tables\Columns\TextColumn;

TextColumn::make('rating')
    ->summarize(Average::make())
```

In this example, all ratings in the table will be added together and divided by the number of ratings.

## Count

Count can be used to find the total number of values in the dataset. Unless you just want to calculate the number of rows, you will probably want to [scope the dataset](#scoping-the-dataset) as well:

```php
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\Summarizers\Count;
use Illuminate\Database\Query\Builder;

IconColumn::make('is_published')
    ->boolean()
    ->summarize(
        Count::make()->query(fn (Builder $query) => $query->where('is_published', true)),
    ),
```

In this example, the table will calculate how many posts are published.

### Counting the occurrence of icons

Using a count on an [icon column](columns/icon) allows you to use the `icons()` method, which gives the user a visual representation of how many of each icon are in the table:

```php
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\Summarizers\Count;
use Illuminate\Database\Query\Builder;

IconColumn::make('is_published')
    ->boolean()
    ->summarize(Count::make()->icons()),
```

## Range

Range can be used to calculate the minimum and maximum value in the dataset:

```php
use Filament\Tables\Columns\Summarizers\Range;
use Filament\Tables\Columns\TextColumn;

TextColumn::make('price')
    ->summarize(Range::make())
```

In this example, the minimum and maximum price in the table will be found.

### Date range

You may format the range as dates using the `minimalDateTimeDifference()` method:

```php
use Filament\Tables\Columns\Summarizers\Range;
use Filament\Tables\Columns\TextColumn;

TextColumn::make('created_at')
    ->dateTime()
    ->summarize(Range::make()->minimalDateTimeDifference())
```

This method will present the minimal difference between the minimum and maximum date. For example:

- If the minimum and maximum dates are different days, only the dates will be displayed.
- If the minimum and maximum dates are on the same day at different times, both the date and time will be displayed.
- If the minimum and maximum dates and times are identical, they will only appear once.

### Text range

You may format the range as text using the `minimalTextualDifference()` method:

```php
use Filament\Tables\Columns\Summarizers\Range;
use Filament\Tables\Columns\TextColumn;

TextColumn::make('sku')
    ->summarize(Range::make()->minimalTextualDifference())
```

This method will present the minimal difference between the minimum and maximum. For example:

- If the minimum and maximum start with different letters, only the first letters will be displayed.
- If the minimum and maximum start with the same letter, more of the text will be rendered until a difference is found.
- If the minimum and maximum are identical, they will only appear once.

### Including null values in the range

By default, we will exclude null values from the range. If you would like to include them, you may use the `excludeNull(false)` method:

```php
use Filament\Tables\Columns\Summarizers\Range;
use Filament\Tables\Columns\TextColumn;

TextColumn::make('sku')
    ->summarize(Range::make()->excludeNull(false))
```

## Sum

Sum can be used to calculate the total of all values in the dataset:

```php
use Filament\Tables\Columns\Summarizers\Sum;
use Filament\Tables\Columns\TextColumn;

TextColumn::make('price')
    ->summarize(Sum::make())
```

In this example, all prices in the table will be added together.

## Setting a label

You may set a summarizer's label using the `label()` method:

```php
use Filament\Tables\Columns\Summarizers\Sum;
use Filament\Tables\Columns\TextColumn;

TextColumn::make('price')
    ->summarize(Sum::make()->label('Total'))
```

## Scoping the dataset

You may apply a database query scope to a summarizer's dataset using the `query()` method:

```php
use Filament\Tables\Columns\Summarizers\Average;
use Filament\Tables\Columns\TextColumn;
use Illuminate\Database\Query\Builder;

TextColumn::make('rating')
    ->summarize(
        Average::make()->query(fn (Builder $query) => $query->where('is_published', true)),
    ),
```

In this example, now only rows where `is_published` is set to `true` will be used to calculate the average.

This feature is especially useful with the [count](#count) summarizer, as it can count how many records in the dataset pass a test:

```php
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\Summarizers\Count;
use Illuminate\Database\Query\Builder;

IconColumn::make('is_published')
    ->boolean()
    ->summarize(
        Count::make()->query(fn (Builder $query) => $query->where('is_published', true)),
    ),
```

In this example, the table will calculate how many posts are published.

## Formatting

### Number formatting

The `numeric()` method allows you to format an entry as a number:

```php
use Filament\Tables\Columns\Summarizers\Average;
use Filament\Tables\Columns\TextColumn;

TextColumn::make('rating')
    ->summarize(Average::make()->numeric())
```

If you would like to customize the number of decimal places used to format the number with, you can use the `decimalPlaces` argument:

```php
use Filament\Tables\Columns\Summarizers\Average;
use Filament\Tables\Columns\TextColumn;

TextColumn::make('rating')
    ->summarize(Average::make()->numeric(
        decimalPlaces: 0,
    ))
```

By default, your app's locale will be used to format the number suitably. If you would like to customize the locale used, you can pass it to the `locale` argument:

```php
use Filament\Tables\Columns\Summarizers\Average;
use Filament\Tables\Columns\TextColumn;

TextColumn::make('rating')
    ->summarize(Average::make()->numeric(
        locale: 'nl',
    ))
```

### Currency formatting

The `money()` method allows you to easily format monetary values, in any currency:

```php
use Filament\Tables\Columns\Summarizers\Sum;
use Filament\Tables\Columns\TextColumn;

TextColumn::make('price')
    ->summarize(Sum::make()->money('EUR'))
```

There is also a `divideBy` argument for `money()` that allows you to divide the original value by a number before formatting it. This could be useful if your database stores the price in cents, for example:

```php
use Filament\Tables\Columns\Summarizers\Sum;
use Filament\Tables\Columns\TextColumn;

TextColumn::make('price')
    ->summarize(Sum::make()->money('EUR', divideBy: 100))
```

By default, your app's locale will be used to format the money suitably. If you would like to customize the locale used, you can pass it to the `locale` argument:

```php
use Filament\Tables\Columns\Summarizers\Average;
use Filament\Tables\Columns\TextColumn;

TextColumn::make('price')
    ->summarize(Sum::make()->money('EUR', locale: 'nl'))
```

If you would like to customize the number of decimal places used to format the number with, you can use the `decimalPlaces` argument:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('price')
    ->summarize(Sum::make()->money('EUR', decimalPlaces: 3))
```

### Limiting text length

You may `limit()` the length of the summary's value:

```php
use Filament\Tables\Columns\Summarizers\Range;
use Filament\Tables\Columns\TextColumn;

TextColumn::make('sku')
    ->summarize(Range::make()->limit(5))
```

### Adding a prefix or suffix

You may add a prefix or suffix to the summary's value:

```php
use Filament\Tables\Columns\Summarizers\Sum;
use Filament\Tables\Columns\TextColumn;
use Illuminate\Support\HtmlString;

TextColumn::make('volume')
    ->summarize(Sum::make()
        ->prefix('Total volume: ')
        ->suffix(new HtmlString(' m&sup3;'))
    )
```

## Custom summaries

You may create a custom summary by returning the value from the `using()` method:

```php
use Filament\Tables\Columns\Summarizers\Summarizer;
use Filament\Tables\Columns\TextColumn;
use Illuminate\Database\Query\Builder;

TextColumn::make('name')
    ->summarize(Summarizer::make()
        ->label('First last name')
        ->using(fn (Builder $query): string => $query->min('last_name')))
```

The callback has access to the database `$query` builder instance to perform calculations with. It should return the value to display in the table.

## Conditionally hiding the summary

To hide a summary, you may pass a boolean, or a function that returns a boolean, to the `hidden()` method. If you need it, you can access the Eloquent query builder instance for that summarizer via the `$query` argument of the function:

```php
use Filament\Tables\Columns\Summarizers\Summarizer;
use Filament\Tables\Columns\TextColumn;
use Illuminate\Database\Eloquent\Builder;

TextColumn::make('sku')
    ->summarize(Summarizer::make()
        ->hidden(fn (Builder $query): bool => ! $query->exists()))
```

Alternatively, you can use the `visible()` method to achieve the opposite effect:

```php
use Filament\Tables\Columns\Summarizers\Summarizer;
use Filament\Tables\Columns\TextColumn;
use Illuminate\Database\Eloquent\Builder;

TextColumn::make('sku')
    ->summarize(Summarizer::make()
        ->visible(fn (Builder $query): bool => $query->exists()))
```

## Summarising groups of rows

You can use summaries with [groups](grouping) to display a summary of the records inside a group. This works automatically if you choose to add a summariser to a column in a grouped table.

### Hiding the grouped rows and showing the summary only

You may hide the rows inside groups and just show the summary of each group using the `groupsOnly()` method. This is beneficial in many reporting scenarios.

```php
use Filament\Tables\Columns\Summarizers\Sum;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->columns([
            TextColumn::make('views_count')
                ->summarize(Sum::make()),
            TextColumn::make('likes_count')
                ->summarize(Sum::make()),
        ])
        ->defaultGroup('category')
        ->groupsOnly();
}
```

# Documentation for tables. File: 07-grouping.md
---
title: Grouping rows
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Introduction

You may allow users to group table rows together using a common attribute. This is useful for displaying lots of data in a more organized way.

Groups can be set up using the name of the attribute to group by (e.g. `'status'`), or a `Group` object which allows you to customize the behavior of that grouping (e.g. `Group::make('status')->collapsible()`).

## Grouping rows by default

You may want to always group posts by a specific attribute. To do this, pass the group to the `defaultGroup()` method:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->defaultGroup('status');
}
```

<AutoScreenshot name="tables/grouping" alt="Table with grouping" version="4.x" />

## Allowing users to choose between groupings

You may also allow users to pick between different groupings, by passing them in an array to the `groups()` method:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->groups([
            'status',
            'category',
        ]);
}
```

You can use both `groups()` and `defaultGroup()` together to allow users to choose between different groupings, but have a default grouping set:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->groups([
            'status',
            'category',
        ])
        ->defaultGroup('status');
}
```

## Grouping by a relationship attribute

You can also group by a relationship attribute using dot-syntax. For example, if you have an `author` relationship which has a `name` attribute, you can use `author.name` as the name of the attribute:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->groups([
            'author.name',
        ]);
}
```

## Setting a grouping label

By default, the label of the grouping will be generated based on the attribute. You may customize it with a `Group` object, using the `label()` method:

```php
use Filament\Tables\Grouping\Group;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->groups([
            Group::make('author.name')
                ->label('Author name'),
        ]);
}
```

## Setting a group title

By default, the title of a group will be the value of the attribute. You may customize it by returning a new title from the `getTitleFromRecordUsing()` method of a `Group` object:

```php
use Filament\Tables\Grouping\Group;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->groups([
            Group::make('status')
                ->getTitleFromRecordUsing(fn (Post $record): string => ucfirst($record->status->getLabel())),
        ]);
}
```

### Disabling the title label prefix

By default, the title is prefixed with the label of the group. To disable this prefix, utilize the `titlePrefixedWithLabel(false)` method:

```php
use Filament\Tables\Grouping\Group;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->groups([
            Group::make('status')
                ->titlePrefixedWithLabel(false),
        ]);
}
```

## Setting a group description

You may also set a description for a group, which will be displayed underneath the group title. To do this, use the `getDescriptionFromRecordUsing()` method on a `Group` object:

```php
use Filament\Tables\Grouping\Group;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->groups([
            Group::make('status')
                ->getDescriptionFromRecordUsing(fn (Post $record): string => $record->status->getDescription()),
        ]);
}
```

<AutoScreenshot name="tables/grouping-descriptions" alt="Table with group descriptions" version="4.x" />

## Setting a group key

By default, the key of a group will be the value of the attribute. It is used internally as a raw identifier of that group, instead of the [title](#setting-a-group-title). You may customize it by returning a new key from the `getKeyFromRecordUsing()` method of a `Group` object:

```php
use Filament\Tables\Grouping\Group;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->groups([
            Group::make('status')
                ->getKeyFromRecordUsing(fn (Post $record): string => $record->status->value),
        ]);
}
```

## Date groups

When using a date-time column as a group, you may want to group by the date only, and ignore the time. To do this, use the `date()` method on a `Group` object:

```php
use Filament\Tables\Grouping\Group;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->groups([
            Group::make('created_at')
                ->date(),
        ]);
}
```

## Collapsible groups

You can allow rows inside a group to be collapsed underneath their group title. To enable this, use a `Group` object with the `collapsible()` method:

```php
use Filament\Tables\Grouping\Group;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->groups([
            Group::make('author.name')
                ->collapsible(),
        ]);
}
```

## Summarising groups

You can use [summaries](summaries) with groups to display a summary of the records inside a group. This works automatically if you choose to add a summariser to a column in a grouped table.

### Hiding the grouped rows and showing the summary only

You may hide the rows inside groups and just show the summary of each group using the `groupsOnly()` method. This is very useful in many reporting scenarios.

```php
use Filament\Tables\Columns\Summarizers\Sum;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->columns([
            TextColumn::make('views_count')
                ->summarize(Sum::make()),
            TextColumn::make('likes_count')
                ->summarize(Sum::make()),
        ])
        ->defaultGroup('category')
        ->groupsOnly();
}
```

## Customizing the Eloquent query ordering behavior

Some features require the table to be able to order an Eloquent query according to a group. You can customize how we do this using the `orderQueryUsing()` method on a `Group` object:

```php
use Filament\Tables\Grouping\Group;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

public function table(Table $table): Table
{
    return $table
        ->groups([
            Group::make('status')
                ->orderQueryUsing(fn (Builder $query, string $direction) => $query->orderBy('status', $direction)),
        ]);
}
```

## Customizing the Eloquent query scoping behavior

Some features require the table to be able to scope an Eloquent query according to a group. You can customize how we do this using the `scopeQueryByKeyUsing()` method on a `Group` object:

```php
use Filament\Tables\Grouping\Group;
use Illuminate\Database\Eloquent\Builder;

public function table(Table $table): Table
{
    return $table
        ->groups([
            Group::make('status')
                ->scopeQueryByKeyUsing(fn (Builder $query, string $key) => $query->where('status', $key)),
        ]);
}
```

## Customizing the Eloquent query grouping behavior

Some features require the table to be able to group an Eloquent query according to a group. You can customize how we do this using the `groupQueryUsing()` method on a `Group` object:

```php
use Filament\Tables\Grouping\Group;
use Illuminate\Database\Eloquent\Builder;

public function table(Table $table): Table
{
    return $table
        ->groups([
            Group::make('status')
                ->groupQueryUsing(fn (Builder $query) => $query->groupBy('status')),
        ]);
}
```

## Customizing the groups dropdown trigger action

To customize the groups dropdown trigger button, you may use the `groupRecordsTriggerAction()` method, passing a closure that returns an action. All methods that are available to [customize action trigger buttons](../actions/overview) can be used:

```php
use Filament\Actions\Action;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->groups([
            // ...
        ])
        ->groupRecordsTriggerAction(
            fn (Action $action) => $action
                ->button()
                ->label('Group records'),
        );
}
```

## Using the grouping settings dropdown on desktop

By default, the grouping settings dropdown will only be shown on mobile devices. On desktop devices, the grouping settings are in the header of the table. You can enable the dropdown on desktop devices too by using the `groupingSettingsInDropdownOnDesktop()` method:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->groups([
            // ...
        ])
        ->groupingSettingsInDropdownOnDesktop();
}
```

## Hiding the grouping settings

You can hide the grouping settings interface using the `groupingSettingsHidden()` method:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
		->defaultGroup('status')
        ->groupingSettingsHidden();
}
```

### Hiding the grouping direction setting only

You can hide the grouping direction select interface using the `groupingDirectionSettingHidden()` method:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
		->defaultGroup('status')
        ->groupingDirectionSettingHidden();
}
```

# Documentation for tables. File: 08-empty-state.md
---
title: Empty state
---
import AutoScreenshot from "@components/AutoScreenshot.astro"

## Introduction

The table's "empty state" is rendered when there are no rows in the table.

<AutoScreenshot name="tables/empty-state" alt="Table with empty state" version="4.x" />

## Setting the empty state heading

To customize the heading of the empty state, use the `emptyStateHeading()` method:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->emptyStateHeading('No posts yet');
}
```

<AutoScreenshot name="tables/empty-state-heading" alt="Table with customized empty state heading" version="4.x" />

## Setting the empty state description

To customize the description of the empty state, use the `emptyStateDescription()` method:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->emptyStateDescription('Once you write your first post, it will appear here.');
}
```

<AutoScreenshot name="tables/empty-state-description" alt="Table with empty state description" version="4.x" />

## Setting the empty state icon

To customize the [icon](../styling/icons) of the empty state, use the `emptyStateIcon()` method:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->emptyStateIcon('heroicon-o-bookmark');
}
```

<AutoScreenshot name="tables/empty-state-icon" alt="Table with customized empty state icon" version="4.x" />

## Adding empty state actions

You can add [Actions](actions) to the empty state to prompt users to take action. Pass these to the `emptyStateActions()` method:

```php
use Filament\Actions\Action;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->emptyStateActions([
            Action::make('create')
                ->label('Create post')
                ->url(route('posts.create'))
                ->icon('heroicon-m-plus')
                ->button(),
        ]);
}
```

<AutoScreenshot name="tables/empty-state-actions" alt="Table with empty state actions" version="4.x" />

## Using a custom empty state view

You may use a completely custom empty state view by passing it to the `emptyState()` method:

```php
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->emptyState(view('tables.posts.empty-state'));
}
```

# Documentation for tables. File: 09-custom-data.md
---
title: Custom data
---
import Aside from "@components/Aside.astro"

## Introduction

[Filament's table builder](overview/#introduction) was originally designed to render data directly from a SQL database using [Eloquent models](https://laravel.com/docs/eloquent) in a Laravel application. Each row in a Filament table corresponds to a row in the database, represented by an Eloquent model instance.

However, this setup isn't always possible or practical. You might need to display data that isn't stored in a database—or data that is stored, but not accessible via Eloquent.

In such cases, you can use custom data instead. Pass a function to the `records()` method of the table builder that returns an array of data. This function is called when the table renders, and the value it returns is used to populate the table.

```php
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

public function table(Table $table): Table
{
    return $table
        ->records(fn (): array => [
            1 => [
                'title' => 'First item',
                'slug' => 'first-item',
                'is_featured' => true,
            ],
            2 => [
                'title' => 'Second item',
                'slug' => 'second-item',
                'is_featured' => false,
            ],
            3 => [
                'title' => 'Third item',
                'slug' => 'third-item',
                'is_featured' => true,
            ],
        ])
        ->columns([
            TextColumn::make('title'),
            TextColumn::make('slug'),
            IconColumn::make('is_featured')
                ->boolean(),
        ]);
}
```

<Aside variant="warning">
    The array keys `(e.g., 1, 2, 3)` represent the record IDs. Use unique and consistent keys to ensure proper diffing and state tracking. This helps prevent issues with record integrity during Livewire interactions and updates.
</Aside>

## Columns

[Columns](columns) in the table work similarly to how they do when using [Eloquent models](https://laravel.com/docs/eloquent), but with one key difference: instead of referring to a model attribute or relationship, the column name represents a key in the array returned by the `records()` function.

When working with the current record inside a column function, set the `$record` type to `array` instead of `Model`. For example, to define a column using the [`state()`](columns#setting-the-state-of-a-column) function, you could do the following:

```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('is_featured')
    ->state(function (array $record): string {
        return $record['is_featured'] ? 'Featured' : 'Not featured';
    })
```

### Sorting

Filament's built-in [sorting](columns#sorting) function uses SQL to sort data. When working with custom data, you'll need to handle sorting yourself.

To access the currently sorted column and direction, you can inject `$sortColumn` and `$sortDirection` into the `records()` function. These variables are `null` if no sorting is applied.

In the example below, a [collection](https://laravel.com/docs/collections#method-sortby) is used to sort the data by key. The collection is returned instead of an array, and Filament handles it the same way. However, using a collection is not required to use this feature.

```php
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Illuminate\Support\Collection;

public function table(Table $table): Table
{
    return $table
        ->records(
            fn (?string $sortColumn, ?string $sortDirection): Collection => collect([
                1 => ['title' => 'First item'],
                2 => ['title' => 'Second item'],
                3 => ['title' => 'Third item'],
            ])->when(
                filled($sortColumn),
                fn (Collection $data): Collection => $data->sortBy(
                    $sortColumn,
                    SORT_REGULAR,
                    $sortDirection === 'desc',
                ),
            )
        )
        ->columns([
            TextColumn::make('title')
                ->sortable(),
        ]);
}
```

<Aside variant="info">
    It might seem like Filament should sort the data for you, but in many cases, it's better to let your data source—like a custom query or API call—handle the sorting instead.
</Aside>

### Searching

Filament's built-in [searching](columns#searching) function uses SQL to search data. When working with custom data, you'll need to handle searching yourself.

To access the current search query, you can inject `$search` into the `records()` function. This variable is `null` if no search query is currently being used.

In the example below, a [collection](https://laravel.com/docs/collections#method-filter) is used to filter the data by the search query. The collection is returned instead of an array, and Filament handles it the same way. However, using a collection is not required to use this feature.

```php
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Illuminate\Support\Collection;
use Illuminate\Support\Str;

public function table(Table $table): Table
{
    return $table
        ->records(
            fn (?string $search): Collection => collect([
                1 => ['title' => 'First item'],
                2 => ['title' => 'Second item'],
                3 => ['title' => 'Third item'],
            ])->when(
                filled($search),
                fn (Collection $data): Collection => $data->filter(
                    fn (array $record): bool => str_contains(
                        Str::lower($record['title']),
                        Str::lower($search),
                    ),
                ),
            )
        )
        ->columns([
            TextColumn::make('title'),
        ])
        ->searchable();
}
```

In this example, specific columns like `title` do not need to be `searchable()` because the search logic is handled inside the `records()` function. However, if you want to enable the search field without enabling search for a specific column, you can use the `searchable()` method on the entire table.

<Aside variant="info">
    It might seem like Filament should search the data for you, but in many cases, it's better to let your data source—like a custom query or API call—handle the searching instead.
</Aside>

#### Searching individual columns

The [individual column searches](#searching-individually) feature provides a way to render a search field separately for each column, allowing more precise filtering. When using custom data, you need to implement this feature yourself.

Instead of injecting `$search` into the `records()` function, you can inject an array of `$columnSearches`, which contains the search queries for each column.

```php
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Illuminate\Support\Collection;
use Illuminate\Support\Str;

public function table(Table $table): Table
{
    return $table
        ->records(
            fn (array $columnSearches): Collection => collect([
                1 => ['title' => 'First item'],
                2 => ['title' => 'Second item'],
                3 => ['title' => 'Third item'],
            ])->when(
                filled($columnSearches['title'] ?? null),
                fn (Collection $data) => $data->filter(
                    fn (array $record): bool => str_contains(
                        Str::lower($record['title']),
                        Str::lower($columnSearches['title'])
                    ),
                ),
            )
        )
        ->columns([
            TextColumn::make('title')
                ->searchable(isIndividual: true),
        ]);
}
```

<Aside variant="info">
    It might seem like Filament should search the data for you, but in many cases, it's better to let your data source—like a custom query or API call—handle the searching instead.
</Aside>

## Filters

Filament also provides a way to filter data using [filters](filters). When working with custom data, you'll need to handle filtering yourself. 

Filament gives you access to an array of filter data by injecting `$filters` into the `records()` function. The array contains the names of the filters as keys and the values of the filter forms themselves.

In the example below, a [collection](https://laravel.com/docs/collections#method-where) is used to filter the data. The collection is returned instead of an array, and Filament handles it the same way. However, using a collection is not required to use this feature.

```php
use Filament\Forms\Components\DatePicker;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\Filter;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use Illuminate\Support\Collection;

public function table(Table $table): Table
{
    return $table
        ->records(fn (array $filters): Collection => collect([
            1 => [
                'title' => 'What is Filament?',
                'slug' => 'what-is-filament',
                'author' => 'Dan Harrin',
                'is_featured' => true,
                'creation_date' => '2021-01-01',
            ],
            2 => [
                'title' => 'Top 5 best features of Filament',
                'slug' => 'top-5-features',
                'author' => 'Ryan Chandler',
                'is_featured' => false,
                'creation_date' => '2021-03-01',
            ],
            3 => [
                'title' => 'Tips for building a great Filament plugin',
                'slug' => 'plugin-tips',
                'author' => 'Zep Fietje',
                'is_featured' => true,
                'creation_date' => '2023-06-01',
            ],
        ])
            ->when(
                $filters['is_featured']['isActive'] ?? false,
                fn (Collection $data): Collection => $data->where(
                    'is_featured', true
                ),
            )
            ->when(
                filled($author = $filters['author']['value'] ?? null),
                fn (Collection $data): Collection => $data->where(
                    'author', $author
                ),
            )
            ->when(
                filled($date = $filters['creation_date']['date'] ?? null),
                fn (Collection $data): Collection => $data->where(
                    'creation_date', $date
                ),
            )
        )
        ->columns([
            TextColumn::make('title'),
            TextColumn::make('slug'),
            IconColumn::make('is_featured')
                ->boolean(),
            TextColumn::make('author'),
        ])
        ->filters([
            Filter::make('is_featured'),
            SelectFilter::make('author')
                ->options([
                    'Dan Harrin' => 'Dan Harrin',
                    'Ryan Chandler' => 'Ryan Chandler',
                    'Zep Fietje' => 'Zep Fietje',
                ]),
            Filter::make('creation_date')
                ->schema([
                    DatePicker::make('date'),
                ]),
        ]);
}
```

Filter values aren't directly accessible via `$filters['filterName']`. Instead, each filter contains one or more form fields, and those field names are used as keys within the filter's data array. For example:

- [Checkbox](filters/overview#introduction) or [Toggle filters](filters/overview#using-a-toggle-button-instead-of-a-checkbox) without a custom schema (e.g., featured) use `isActive` as the `key`: `$filters['featured']['isActive']`

- [Select filters](filters/select#introduction) (e.g., author) use `value`: `$filters['author']['value']`

- [Custom schema filters](filters/custom#custom-filter-schemas) (e.g., creation_date) use the actual form field names. If the field is named `date`, access it like this: `$filters['creation_date']['date']`

<Aside variant="info">
    It might seem like Filament should filter the data for you, but in many cases, it's better to let your data source—like a custom query or API call—handle the filtering instead.
</Aside>

## Pagination

Filament's built-in [pagination](overview#pagination) feature uses SQL to paginate the data. When working with custom data, you'll need to handle pagination yourself. 

The `$page` and `$recordsPerPage` arguments are injected into the `records()` function, and you can use them to paginate the data. A `LengthAwarePaginator` should be returned from the `records()` function, and Filament will handle the pagination links and other pagination features for you:

```php
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Support\Collection;

public function table(Table $table): Table
{
    return $table
        ->records(function (int $page, int $recordsPerPage): LengthAwarePaginator {
            $records = collect([
                1 => ['title' => 'What is Filament?'],
                2 => ['title' => 'Top 5 best features of Filament'],
                3 => ['title' => 'Tips for building a great Filament plugin'],
            ])->forPage($page, $recordsPerPage);

            return new LengthAwarePaginator(
                $records,
                total: 30, // Total number of records across all pages
                perPage: $recordsPerPage,
                currentPage: $page,
            );
        })
        ->columns([
            TextColumn::make('title'),
        ]);
}
```

In this example, the `forPage()` method is used to paginate the data. This probably isn't the most efficient way to paginate data from a query or API, but it is a simple way to demonstrate how to paginate data from a custom array.

<Aside variant="info">
    It might seem like Filament should paginate the data for you, but in many cases, it's better to let your data source—like a custom query or API call—handle the pagination instead.
</Aside>

## Actions

[Actions](actions) in the table work similarly to how they do when using [Eloquent models](https://laravel.com/docs/eloquent). The only difference is that the `$record` parameter in the action's callback function will be an `array` instead of a `Model`.

```php
use Filament\Actions\Action;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Illuminate\Support\Collection;

public function table(Table $table): Table
{
    return $table
        ->records(fn (): Collection => collect([
            1 => [
                'title' => 'What is Filament?',
                'slug' => 'what-is-filament',
            ],
            2 => [
                'title' => 'Top 5 best features of Filament',
                'slug' => 'top-5-features',
            ],
            3 => [
                'title' => 'Tips for building a great Filament plugin',
                'slug' => 'plugin-tips',
            ],
        ]))
        ->columns([
            TextColumn::make('title'),
            TextColumn::make('slug'),
        ])
        ->recordActions([
            Action::make('view')
                ->color('gray')
                ->icon(Heroicon::Eye)
                ->url(fn (array $record): string => route('posts.view', $record['slug'])),
        ]);
}
```

### Bulk actions

For actions that interact with a single record, the record is always present on the current table page, so the `records()` method can be used to fetch the data. However for bulk actions, records can be selected across pagination pages. If you would like to use a bulk action that selects records across pages, you need to give Filament a way to fetch records across pages, otherwise it will only return the records from the current page. The `resolveSelectedRecordsUsing()` method should accept a function which has a `$keys` parameter, and returns an array of record data:

```php
use Filament\Actions\BulkAction;
use Filament\Tables\Table;
use Illuminate\Support\Arr;
use Illuminate\Support\Collection;

public function table(Table $table): Table
{
    return $table
        ->records(function (): array {
            // ...
        })
        ->resolveSelectedRecordsUsing(function (array $keys): array {
            return Arr::only([
                1 => [
                    'title' => 'First item',
                    'slug' => 'first-item',
                    'is_featured' => true,
                ],
                2 => [
                    'title' => 'Second item',
                    'slug' => 'second-item',
                    'is_featured' => false,
                ],
                3 => [
                    'title' => 'Third item',
                    'slug' => 'third-item',
                    'is_featured' => true,
                ],
            ], $keys);
        })
        ->columns([
            // ...
        ])
        ->recordActions([
            BulkAction::make('feature')
                ->requiresConfirmation()
                ->action(function (Collection $records): void {
                    // Do something with the collection of `$records` data
                }),
        ]);
}
```

However, if your user uses the "Select All" button to select all records across pagination pages, Filament will internally switch to tracking *deselected* records instead of selected records. This is an efficient mechanism in significantly large datasets. You can inject two additional parameters into the `resolveSelectedRecordsUsing()` method to handle this case: `$isTrackingDeselectedKeys` and `$deselectedKeys`.

`$isTrackingDeselectedKeys` is a boolean that indicates whether the user is tracking deselected keys. If it's `true`, `$deselectedKeys` will contain the keys of the records that are currently deselected. You can use this information to filter out the deselected records from the array of records returned by the `resolveSelectedRecordsUsing()` method:

```php
use Filament\Actions\BulkAction;
use Filament\Tables\Table;
use Illuminate\Support\Arr;
use Illuminate\Support\Collection;

public function table(Table $table): Table
{
    return $table
        ->records(function (): array {
            // ...
        })
        ->resolveSelectedRecordsUsing(function (
            array $keys,
            bool $isTrackingDeselectedKeys,
            array $deselectedKeys
        ): array {
            $records = [
                1 => [
                    'title' => 'First item',
                    'slug' => 'first-item',
                    'is_featured' => true,
                ],
                2 => [
                    'title' => 'Second item',
                    'slug' => 'second-item',
                    'is_featured' => false,
                ],
                3 => [
                    'title' => 'Third item',
                    'slug' => 'third-item',
                    'is_featured' => true,
                ],
            ];
            
            if ($isTrackingDeselectedKeys) {
                return Arr::except(
                    $records,
                    $deselectedKeys,
                );
            }
            
            return Arr::only(
                $records,
                $keys,
            );
        })
        ->columns([
            // ...
        ])
        ->recordActions([
            BulkAction::make('feature')
                ->requiresConfirmation()
                ->action(function (Collection $records): void {
                    // Do something with the collection of `$records` data
                }),
        ]);
}
```

## Using an external API as a table data source

[Filament's table builder](overview/#introduction) allows you to populate tables with data fetched from any external source—not just [Eloquent models](https://laravel.com/docs/eloquent). This is particularly useful when you want to display data from a REST API or a third-party service.

### Fetching data from an external API

The example below demonstrates how to consume data from [DummyJSON](https://dummyjson.com), a free fake REST API for placeholder JSON, and display it in a [Filament table](overview/#introduction):

```php
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Illuminate\Support\Facades\Http;

public function table(Table $table): Table
{
    return $table
        ->records(fn (): array => Http::baseUrl('https://dummyjson.com')
            ->get('products')
            ->collect()
            ->get('products', [])
        )
        ->columns([
            TextColumn::make('title'),
            TextColumn::make('category'),
            TextColumn::make('price')
                ->money(),
        ]);
}
```

`get('products')` makes a `GET` request to [`https://dummyjson.com/products`](https://dummyjson.com/products). The `collect()` method converts the JSON response into a [Laravel collection](https://laravel.com/docs/collections#main-content). Finally, `get('products', [])` retrieves the array of products from the response. If the key is missing, it safely returns an empty array.

<Aside variant="warning">
    This is a basic example for demonstration purposes only. It's the developer's responsibility to implement proper authentication, authorization, validation, error handling, rate limiting, and other best practices when working with APIs.
</Aside>

<Aside variant="info">
    DummyJSON returns 30 items by default. You can use the [limit and skip](#external-api-pagination) query parameters to paginate through all items or use [`limit=0`](https://dummyjson.com/docs/products#products-limit_skip) to get all items.
</Aside>

#### Setting the state of a column using API data

[Columns](#columns) map to the array keys returned by the `records()` function.

When working with the current record inside a column function, set the `$record` type to `array` instead of `Model`. For example, to define a column using the [`state()`](columns/overview#setting-the-state-of-a-column) function, you could do the following:

```php
use Filament\Tables\Columns\TextColumn;
use Illuminate\Support\Str;

TextColumn::make('category_brand')
    ->label('Category - Brand')
    ->state(function (array $record): string {
        $category = Str::headline($record['category']);
        $brand = Str::title($record['brand'] ?? 'Unknown');

        return "{$category} - {$brand}";
    })
```

<Aside variant="tip">
    You can use the [`formatStateUsing()`](columns/text#formatting) method to format the state of a text column without changing the state itself.
</Aside>

### External API sorting

You can enable [sorting](columns#sorting) in [columns](columns) even when using an external API as the data source. The example below demonstrates how to pass sorting parameters (`sort_column` and `sort_direction`) to the [DummyJSON](https://dummyjson.com/docs/products#products-sort) API and how they are handled by the API.

```php
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Illuminate\Support\Facades\Http;

public function table(Table $table): Table
{
    return $table
        ->records(function (?string $sortColumn, ?string $sortDirection): array {
            $response = Http::baseUrl('https://dummyjson.com/')
                ->get('products', [
                    'sortBy' => $sortColumn,
                    'order' => $sortDirection,
                ]);

            return $response
                ->collect()
                ->get('products', []);
        })
        ->columns([
            TextColumn::make('title'),
            TextColumn::make('category')
                ->sortable(),
            TextColumn::make('price')
                ->money(),
        ]);
}
```
`get('products')` makes a `GET` request to [`https://dummyjson.com/products`](https://dummyjson.com/products). The request includes two parameters: `sortBy`, which specifies the column to sort by (e.g., category), and `order`, which specifies the direction of the sort (e.g., asc or desc). The `collect()` method converts the JSON response into a [Laravel collection](https://laravel.com/docs/collections#main-content). Finally, `get('products', [])` retrieves the array of products from the response. If the key is missing, it safely returns an empty array.

<Aside variant="warning">
    This is a basic example for demonstration purposes only. It's the developer's responsibility to implement proper authentication, authorization, validation, error handling, rate limiting, and other best practices when working with APIs.
</Aside>

<Aside variant="info">
    DummyJSON returns 30 items by default. You can use the [limit and skip](#external-api-pagination) query parameters to paginate through all items or use [`limit=0`](https://dummyjson.com/docs/products#products-limit_skip) to get all items.
</Aside>

### External API searching

You can enable [searching](columns#searching) in [columns](columns) even when using an external API as the data source. The example below demonstrates how to pass the `search` parameter to the [DummyJSON](https://dummyjson.com/docs/products#products-search) API and how it is handled by the API.

```php
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Illuminate\Support\Facades\Http;

public function table(Table $table): Table
{
    return $table
        ->records(function (?string $search): array {
            $response = Http::baseUrl('https://dummyjson.com/')
                ->get('products/search', [
                    'q' => $search,
                ]);

            return $response
                ->collect()
                ->get('products', []);
        })
        ->columns([
            TextColumn::make('title'),
            TextColumn::make('category'),
            TextColumn::make('price')
                ->money(),
        ])
        ->searchable();
}
```

`get('products/search')` makes a `GET` request to [`https://dummyjson.com/products/search`](https://dummyjson.com/products/search). The request includes the `q` parameter, which is used to filter the results based on the `search` query. The `collect()` method converts the JSON response into a [Laravel collection](https://laravel.com/docs/collections#main-content). Finally, `get('products', [])` retrieves the array of products from the response. If the key is missing, it safely returns an empty array.

<Aside variant="warning">
    This is a basic example for demonstration purposes only. It's the developer's responsibility to implement proper authentication, authorization, validation, error handling, rate limiting, and other best practices when working with APIs.
</Aside>

<Aside variant="info">
    DummyJSON returns 30 items by default. You can use the [limit and skip](#external-api-pagination) query parameters to paginate through all items or use [`limit=0`](https://dummyjson.com/docs/products#products-limit_skip) to get all items.
</Aside>

### External API filtering

You can enable [filtering](filters) in your table even when using an external API as the data source. The example below demonstrates how to pass the `filter` parameter to the [DummyJSON](https://dummyjson.com/docs/products#products-search) API and how it is handled by the API.

```php
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Http;

public function table(Table $table): Table
{
    return $table
        ->records(function (array $filters): array {
            $category = $filters['category']['value'] ?? null;

            $endpoint = filled($category)
                ? "products/category/{$category}"
                : 'products';

            $response = Http::baseUrl('https://dummyjson.com/')
                ->get($endpoint);

            return $response
                ->collect()
                ->get('products', []);
        })
        ->columns([
            TextColumn::make('title'),
            TextColumn::make('category'),
            TextColumn::make('price')
                ->money(),
        ])
        ->filters([
            SelectFilter::make('category')
                ->label('Category')
                ->options(fn (): Collection => Http::baseUrl('https://dummyjson.com/')
                    ->get('products/categories')
                    ->collect()
                    ->pluck('name', 'slug')
                ),
        ]);
}
```

If a category filter is selected, the request is made to `/products/category/{category}`; otherwise, it defaults to `/products`. The `get()` method sends a `GET` request to the appropriate endpoint. The `collect()` method converts the JSON response into a [Laravel collection](https://laravel.com/docs/collections#main-content). Finally, `get('products', [])` retrieves the array of products from the response. If the key is missing, it safely returns an empty array.

<Aside variant="warning">
    This is a basic example for demonstration purposes only. It's the developer's responsibility to implement proper authentication, authorization, validation, error handling, rate limiting, and other best practices when working with APIs.
</Aside>

<Aside variant="info">
    DummyJSON returns 30 items by default. You can use the [limit and skip](#external-api-pagination) query parameters to paginate through all items or use [`limit=0`](https://dummyjson.com/docs/products#products-limit_skip) to get all items.
</Aside>

### External API pagination

You can enable [pagination](overview#pagination) when using an external API as the table data source. Filament will pass the current page and the number of records per page to your `records()` function. The example below demonstrates how to construct a `LengthAwarePaginator` manually and fetch paginated data from the [DummyJSON](https://dummyjson.com/docs/products#products-limit_skip) API, which uses `limit` and `skip` parameters for pagination:

```php
public function table(Table $table): Table
{
    return $table
        ->records(function (int $page, int $recordsPerPage): LengthAwarePaginator {
            $skip = ($page - 1) * $recordsPerPage;

            $response = Http::baseUrl('https://dummyjson.com')
                ->get('products', [
                    'limit' => $recordsPerPage,
                    'skip' => $skip,
                ])
                ->collect();

            return new LengthAwarePaginator(
                items: $response['products'],
                total: $response['total'],
                perPage: $recordsPerPage,
                currentPage: $page
            );
        })
        ->columns([
            TextColumn::make('title'),
            TextColumn::make('category'),
            TextColumn::make('price')
                ->money(),
        ]);
}
```

`$page` and `$recordsPerPage` are automatically injected by Filament based on the current pagination state.
The calculated `skip` value tells the API how many records to skip before returning results for the current page.
The response contains `products` (the paginated items) and `total` (the total number of available items).
These values are passed to a `LengthAwarePaginator`, which Filament uses to render pagination controls correctly.

<Aside variant="warning">
    This is a basic example for demonstration purposes only. It's the developer's responsibility to implement proper authentication, authorization, validation, error handling, rate limiting, and other best practices when working with APIs.
</Aside>

### External API actions

When using [actions](../actions/overview) in a table with an external API, the process is almost identical to working with [Eloquent models](https://laravel.com/docs/eloquent). The main difference is that the `$record` parameter in the action's callback function will be an `array` instead of a `Model` instance.

Filament provides a variety of [built-in actions](../actions/overview#available-actions) that you can use in your application. However, you are not limited to these. You can create [custom actions](../actions/overview#introduction) tailored to your application's needs.

The examples below demonstrate how to create and use actions with an external API using [DummyJSON](https://dummyjson.com) as a simulated API source.

#### External API create action example

The create action in this example provides a [modal form](../actions/modals#rendering-a-form-in-a-modal) that allows users to create a new product using an external API. When the form is submitted, a `POST` request is sent to the API to create the new product.

```php
use Filament\Actions\Action;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Notifications\Notification;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Http;

public function table(Table $table): Table
{
    $baseUrl = 'https://dummyjson.com';

    return $table
        ->records(fn (): array => Http::baseUrl($baseUrl)
            ->get('products')
            ->collect()
            ->get('products', [])
        )
        ->columns([
            TextColumn::make('title'),
            TextColumn::make('category'),
        ])
        ->headerActions([
            Action::make('create')
                ->modalHeading('Create product')
                ->schema([
                    TextInput::make('title')
                        ->required(),
                    Select::make('category')
                        ->options(fn (): Collection => Http::get("{$baseUrl}/products/categories")
                            ->collect()
                            ->pluck('name', 'slug')
                        )
                        ->required(),
                ])
                ->action(function (array $data) use ($baseUrl) {
                    $response = Http::post("{$baseUrl}/products/add", [
                        'title' => $data['title'],
                        'category' => $data['category'],
                    ]);

                    if ($response->failed()) {
                        Notification::make()
                            ->title('Product failed to create')
                            ->danger()
                            ->send();
                            
                        return;
                    }
                    
                    Notification::make()
                        ->title('Product created')
                        ->success()
                        ->send();
                }),
        ]);
}
```

- [`modalHeading()`](../actions/modals#customizing-the-modals-heading-description-and-submit-action-label) sets the title of the modal that appears when the action is triggered.
- [`schema()`](../actions/modals#rendering-a-schema-in-a-modal) defines the form fields displayed in the modal.
- `action()` defines the logic that will be executed when the user submits the form.

<Aside variant="warning">
    This is a basic example for demonstration purposes only. It's the developer's responsibility to implement proper authentication, authorization, validation, error handling, rate limiting, and other best practices when working with APIs.
</Aside>

<Aside variant="warning">
    [`DummyJSON`](https://dummyjson.com/docs/products#products-update) API will not add it into the server. It will simulate a `POST` request and will return the new created product with a new id.
</Aside>

If you don't need a modal, you can directly redirect users to a specified URL when they click the create action button. In this case, you can define a custom URL pointing to the product creation page:

```php
use Filament\Actions\Action;

Action::make('create')
    ->url(route('products.create'))
```

#### External API edit action example

The edit action in this example provides a [modal form](../actions/modals#rendering-a-form-in-a-modal) for editing product details fetched from an external API. Users can update fields such as the product title and category, and the changes will be sent to the external API using a `PUT` request.

```php
use Filament\Actions\Action;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Notifications\Notification;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Http;

public function table(Table $table): Table
{
    $baseUrl = 'https://dummyjson.com';

    return $table
        ->records(fn (): array => Http::baseUrl($baseUrl)
            ->get('products')
            ->collect()
            ->get('products', [])
        )
        ->columns([
            TextColumn::make('title'),
            TextColumn::make('category'),
        ])
        ->recordActions([
            Action::make('edit')
                ->icon(Heroicon::PencilSquare)
                ->modalHeading('Edit product')
                ->fillForm(fn (array $record) => $record)
                ->schema([
                    TextInput::make('title')
                        ->required(),
                    Select::make('category')
                        ->options(fn (): Collection => Http::get("{$baseUrl}/products/categories")
                            ->collect()
                            ->pluck('name', 'slug')
                        )
                        ->required(),
                ])
                ->action(function (array $data, array $record) use ($baseUrl) {
                    $response = Http::put("{$baseUrl}/products/{$record['id']}", [
                        'title' => $data['title'],
                        'category' => $data['category'],
                    ]);

                    if ($response->failed()) {
                        Notification::make()
                            ->title('Product failed to save')
                            ->danger()
                            ->send();
                            
                        return;
                    }
                    
                    Notification::make()
                        ->title('Product save')
                        ->success()
                        ->send();
                }),
        ]);
}
```

- `icon()` defines the icon shown for this action in the table.
- [`modalHeading()`](../actions/modals#customizing-the-modals-heading-description-and-submit-action-label) sets the title of the modal that appears when the action is triggered.
- [`fillForm()`](../actions/modals#filling-the-form-with-existing-data) automatically fills the form fields with the existing values of the selected record.
- [`schema()`](../actions/modals#rendering-a-schema-in-a-modal) defines the form fields displayed in the modal.
- `action()` defines the logic that will be executed when the user submits the form.

<Aside variant="warning">
    This is a basic example for demonstration purposes only. It's the developer's responsibility to implement proper authentication, authorization, validation, error handling, rate limiting, and other best practices when working with APIs.
</Aside>

<Aside variant="warning">
    [`DummyJSON`](https://dummyjson.com/docs/products#products-update) API will not update it into the server. It will simulate a `PUT`/`PATCH` request and will return updated product with modified data.
</Aside>

If you don't need a modal, you can directly redirect users to a specified URL when they click the action button. You can achieve this by defining a URL with a dynamic route that includes the `record` parameter:

```php
use Filament\Actions\Action;

Action::make('edit')
    ->url(fn (array $record): string => route('products.edit', ['product' => $record['id']]))
```

#### External API view action example

The view action in this example opens a [modal](../actions/modals) displaying detailed product information fetched from an external API. This allows you to build a user interface with various components such as [text entries](../infolists/text-entry) and [images](../infolists/image-entry).

```php
use Filament\Actions\Action;
use Filament\Infolists\Components\ImageEntry;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Components\Flex;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Section;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Illuminate\Support\Facades\Http;

public function table(Table $table): Table
{
    $baseUrl = 'https://dummyjson.com';

    return $table
        ->records(fn (): array => Http::baseUrl($baseUrl)
            ->get('products', [
                'select' => 'id,title,description,brand,category,thumbnail,price',
            ])
            ->collect()
            ->get('products', [])
        )
        ->columns([
            TextColumn::make('title'),
            TextColumn::make('category'),
        ])
        ->recordActions([
            Action::make('view')
                ->color('gray')
                ->icon(Heroicon::Eye)
                ->modalHeading('View product')
                ->schema([
                    Section::make()
                        ->schema([
                            Flex::make([
                                Grid::make(2)
                                    ->schema([
                                        TextEntry::make('title'),
                                        TextEntry::make('category'),
                                        TextEntry::make('brand'),
                                        TextEntry::make('price')
                                            ->money(),
                                    ]),
                                ImageEntry::make('thumbnail')
                                    ->hiddenLabel()
                                    ->grow(false),
                            ])->from('md'),
                            TextEntry::make('description')
                                ->prose(),
                        ]),
                ])
                ->modalSubmitAction(false)
                ->modalCancelActionLabel('Close'),
        ]);
}
```

- `color()` sets the color of the action button.
- `icon()` defines the icon shown for this action in the table.
- [`modalHeading()`](../actions/modals#customizing-the-modals-heading-description-and-submit-action-label) sets the title of the modal that appears when the action is triggered.
- [`schema()`](../actions/modals#rendering-a-schema-in-a-modal) defines the form fields displayed in the modal.
- [`modalSubmitAction(false)`](../actions/modals#modifying-the-default-modal-footer-action-button) disables the submit button, making this a read-only view action.
- [`modalCancelActionLabel()`](../actions/modals#modifying-the-default-modal-footer-action-button) customizes the label for the close button.

<Aside variant="warning">
    This is a basic example for demonstration purposes only. It's the developer's responsibility to implement proper authentication, authorization, validation, error handling, rate limiting, and other best practices when working with APIs.
</Aside>

<Aside variant="info">
    The [`select`](https://dummyjson.com/docs/products#products-limit_skip) parameter is used to limit the fields returned by the API. This helps reduce payload size and improves performance when rendering the table.
</Aside>

If you don't need a modal, you can directly redirect users to a specified URL when they click the action button. You can achieve this by defining a URL with a dynamic route that includes the `record` parameter:

```php
use Filament\Actions\Action;

Action::make('view')
    ->url(fn (array $record): string => route('products.view', ['product' => $record['id']]))
```

#### External API delete action example

The delete action in this example allows users to delete a product fetched from an external API.

```php
use Filament\Actions\Action;
use Filament\Notifications\Notification;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Illuminate\Support\Facades\Http;

public function table(Table $table): Table
{
    $baseUrl = 'https://dummyjson.com';

    return $table
        ->records(fn (): array => Http::baseUrl($baseUrl)
            ->get('products')
            ->collect()
            ->get('products', [])
        )
        ->columns([
            TextColumn::make('title'),
            TextColumn::make('category'),
            TextColumn::make('price')
                ->money(),
        ])
        ->recordActions([
            Action::make('delete')
                ->color('danger')
                ->icon(Heroicon::Trash)
                ->modalIcon(Heroicon::OutlinedTrash)
                ->modalHeading('Delete Product')
                ->requiresConfirmation()
                ->action(function (array $record) use ($baseUrl) {
                    $response = Http::baseUrl($baseUrl)
                        ->delete("products/{$record['id']}");

                    if ($response->failed()) {
                        Notification::make()
                            ->title('Product failed to delete')
                            ->danger()
                            ->send();
                            
                        return;
                    }
                    
                    Notification::make()
                        ->title('Product deleted')
                        ->success()
                        ->send();
                }),
        ]);
}
```

- `color()` sets the color of the action button.
- `icon()` defines the icon shown for this action in the table.
- [`modalIcon()`](../actions/modals#adding-an-icon-inside-the-modal) sets the icon that will appear in the confirmation modal.
- [`modalHeading()`](../actions/modals#customizing-the-modals-heading-description-and-submit-action-label) sets the title of the modal that appears when the action is triggered.
- [`requiresConfirmation()`](../actions/modals#confirmation-modals) ensures that the user must confirm the deletion before it is executed.
- `action()` defines the logic that will be executed when the user confirms the submission.

<Aside variant="warning">
    This is a basic example for demonstration purposes only. It's the developer's responsibility to implement proper authentication, authorization, validation, error handling, rate limiting, and other best practices when working with APIs.
</Aside>

<Aside variant="warning">
    [`DummyJSON`](https://dummyjson.com/docs/products#products-update) API will not delete it into the server. It will simulate a `DELETE` request and will return deleted product with `isDeleted` and `deletedOn` keys.
</Aside>

### External API full example

This example demonstrates how to combine [sorting](#external-api-sorting), [search](#external-api-searching), [category filtering](#external-api-filtering), and [pagination](#external-api-pagination) when using an external API as the data source. The API used here is [DummyJSON](https://dummyjson.com), which supports these features individually but **does not allow combining all of them in a single request**. This is because each feature uses a different endpoint:

- [Search](#external-api-searching) is performed through the `/products/search` endpoint using the `q` parameter.
- [Category filtering](#external-api-filtering) uses the `/products/category/{category}` endpoint.
- [Sorting](#external-api-sorting) is handled by sending `sortBy` and `order` parameters to the `/products` endpoint.

The only feature that can be combined with each of the above is [pagination](#external-api-pagination), since the `limit` and `skip` parameters are supported across all three endpoints.

```php
use Filament\Tables\Columns\ImageColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;

public function table(Table $table): Table
{
    $baseUrl = 'https://dummyjson.com/';

    return $table
        ->records(function (
            ?string $sortColumn,
            ?string $sortDirection,
            ?string $search,
            array $filters,
            int $page,
            int $recordsPerPage
        ) use ($baseUrl): LengthAwarePaginator {
            // Get the selected category from filters (if any)
            $category = $filters['category']['value'] ?? null;

            // Choose endpoint depending on search or filter
            $endpoint = match (true) {
                filled($search) => 'products/search',
                filled($category) => "products/category/{$category}",
                default => 'products',
            };

            // Determine skip offset
            $skip = ($page - 1) * $recordsPerPage;

            // Base query parameters for all requests
            $params = [
                'limit' => $recordsPerPage,
                'skip' => $skip,
                'select' => 'id,title,brand,category,thumbnail,price,sku,stock',
            ];

            // Add search query if applicable
            if (filled($search)) {
                $params['q'] = $search;
            }

            // Add sorting parameters
            if ($endpoint === 'products' && $sortColumn) {
                $params['sortBy'] = $sortColumn;
                $params['order'] = $sortDirection ?? 'asc';
            }

            $response = Http::baseUrl($baseUrl)
                ->get($endpoint, $params)
                ->collect();

            return new LengthAwarePaginator(
                items: $response['products'],
                total: $response['total'],
                perPage: $recordsPerPage,
                currentPage: $page
            );
        })
        ->columns([
            ImageColumn::make('thumbnail')
                ->label('Image'),
            TextColumn::make('title')
                ->sortable(),
            TextColumn::make('brand')
                ->state(fn (array $record): string => Str::title($record['brand'] ?? 'Unknown')),
            TextColumn::make('category')
                ->formatStateUsing(fn (string $state): string => Str::headline($state)),
            TextColumn::make('price')
                ->money(),
            TextColumn::make('sku')
                ->label('SKU'),
            TextColumn::make('stock')
                ->label('Stock')
                ->sortable(),
        ])
        ->filters([
            SelectFilter::make('category')
                ->label('Category')
                ->options(fn (): Collection => Http::baseUrl($baseUrl)
                    ->get('products/categories')
                    ->collect()
                    ->pluck('name', 'slug')
                ),
        ])
        ->searchable();
}
```

<Aside variant="warning">
    This is a basic example for demonstration purposes only. It's the developer's responsibility to implement proper authentication, authorization, validation, error handling, rate limiting, and other best practices when working with APIs.
</Aside>

<Aside variant="warning">
    The [DummyJSON](https://dummyjson.com) API does not support combining sorting, search, and category filtering in a single request.
</Aside>

<Aside variant="info">
    The [`select`](https://dummyjson.com/docs/products#products-limit_skip) parameter is used to limit the fields returned by the API. This helps reduce payload size and improves performance when rendering the table.
</Aside>

