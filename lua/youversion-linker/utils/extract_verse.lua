local pl = require("pl.pretty")
local http = require("socket.http")
local cjson = require("cjson.safe")

-- Extract passage text with pup
local function extract_verse(html)
  local temp_file = tempfile()
  vim.print(temp_file.path)
  -- local sep = package.config:sub(1, 1)
  -- -- print(debug.getinfo(1).source)
  -- local dirname = string.sub(debug.getinfo(1).source, 2, (string.len('/extract_verse.lua') * -1) -1)
  -- print("Directory: " .. dirname)
  -- local temp_file = dirname .. temp_file .. ".html"
  print(temp_file)
  -- io.open(temp_file, "w"):write(html)
  local fh, err = io.open(temp_file, "w")

  if not fh then
    vim.notify("extract_verse: could not open temp file for writing: " .. err, vim.log.levels.ERROR)
    return nil, err
  end

  local ok, write_err = fh:write(html)

  fh:close()
  -- print(f)
  -- f:close()
  local pup_selector = [[
    script#__NEXT_DATA__ text{}
  ]]
  pup_selector = pup_selector:gsub("%s+", " ")
  local handle = io.popen(string.format("pup '%s' < %s", pup_selector, temp_file))
  local result = handle:read("*a")
  -- print(result)
  -- io.open('result.json', 'w'):write(result):close()
  handle:close()
  os.remove(temp_file)

  print(result)
  return result
end

-- Alternative version using vim.fn.system (Neovim-specific)
local function extract_verse_nvim(html)
  if not html or html == "" then
    return nil, "HTML content is required"
  end

  -- Check if pup is available
  if vim.fn.executable('pup') ~= 1 then

    print("Pup not found")
    return nil, "pup command not found. Please install pup."
  end

  local pup_selector = "script#__NEXT_DATA__ text{}"

  -- Use vim.fn.system to avoid temporary files
  local result = vim.fn.system({'pup', pup_selector}, html)
  print(result)
  if vim.v.shell_error ~= 0 then
    print("pup failed" .. vim.v.shell_error)
    return nil, "pup command failed with exit code: " .. vim.v.shell_error
  end

  -- Trim whitespace
  result = result:gsub("^%s*(.-)%s*$", "%1")

  return result
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
