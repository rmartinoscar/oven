I want to create a script in bash to automate the following task.
Write the bash code that achieves the below task to: `concatenate_packages.sh`.

For each package (folder) in `filament-docs`, I want to concatenate all files in a package.md file.
Example: For the `filament-docs/actions/docs`, the result output would be `filament-docs/actions.md`

Inside each package there are md files and folders.
I want to concatenate them by order.
I want to put write the contents of file `filament-docs/actions/docs/01-installation.md` like so:
```
<FILE name="01-installation.md">
[Content of the file goes here]
</FILE>
```
If inside a folder, the folder name has the order, and then the files as well.
Example, for file `filament-docs/actions/docs/07-prebuilt-actions/01-create.md`, make it like so:
```
<FILE name="07-prebuilt-actions/01-create.md">
[Content of the file goes here]
</FILE>
```
