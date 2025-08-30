1. Create a table of verses
2. Fetch all the bible passage fpr each verse that's enabled
3. Add the results to the returned table
4. Find a way to run that asynchronously
5. Create a nui popup with the items as different bible versions.
6. Fetch the bible verse corresponding to the version selected either by generating the url and fetvhing from there or using the above approach.


[2025-06-19 00:50]
- [x] Adjust popup to fetch the bible passage from the display text and parse that into the function to fetch the verse
[ ] Add a trigger for character detection
- [x] Auto update menu popup as letters are being typed
- [x] Fix issue of reading books that starts with numbers, such as 1 John, etc.

[2025-08-26 23:44]
- [-] add caching for popup bible text display
- [-] find a faster alternative to luasocket fetching the bible.com page
- [-] code refactor
- [-] update readme
- [-] add documentation
- [-] Test plugin with obsidian nvim

