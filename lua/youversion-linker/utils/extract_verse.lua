-- local pl = require("pl.pretty")
-- local http = require("socket.http")
local ok, cjson = pcall(require, "cjson.safe")
if not ok then
  vim.notify("Missing 'cjson' dependency! Please check the documentation for instructions to install.",
    vim.log.levels.ERROR)
  return nil
end

local function extract_verse_lua(html)
  if not html or html == "" then
    return nil, "HTML content is required"
  end

  -- Look for script tag with id="__NEXT_DATA__"
  local script_content = html:match('<script[^>]*id="__NEXT_DATA__"[^>]*>(.-)</script>')

  if not script_content then
    return nil, "Could not find __NEXT_DATA__ script tag"
  end

  -- Trim whitespace
  script_content = script_content:gsub("^%s*(.-)%s*$", "%1")

  -- Debug output (conditional)
  if os.getenv("NVIM_PLUGIN_DEBUG") then
    local debug_file = io.open('result.json', 'w')
    if debug_file then
      debug_file:write(script_content)
      debug_file:close()
    end
  end

  return script_content
end

-- parse the json result
local function parse_json(raw_json)
  -- print(raw_json)
  local data = cjson.decode(raw_json)
  local title = data.props.pageProps.referenceTitle.title
  local version = data.props.pageProps.version.local_abbreviation
  local verses = data.props.pageProps.verses

  local verses_table = {}
  for _, verse in ipairs(verses) do
    table.insert(verses_table, verse.content)
  end

  local verses = table.concat(verses_table, " ")

  return {
    title = title,
    version = version,
    verses = verses,
  }
end

return {
  extract_verse = extract_verse_lua, --extract_verse,
  parse_json = parse_json,
}
