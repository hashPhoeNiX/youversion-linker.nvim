local loader = require("nui.bible-completion.bible.loader")
local state = require("nui.bible-completion.state")

-- Move utilities to the top for better organization
local pl = require("pl.pretty")
local regex = require("utils.regex_utils")
local book_lookup = require("utils.book_lookup")
local generate_url = require("utils.build_url")
local get_page = require("utils.get_html_page")
local extract_data = require("utils.extract_verse")

local M = {}

-- FIXED: Better Bible passage parsing with position tracking
M.get_bible_passage = function(line, cursor_col)
  if not line or line == "" then
    return nil
  end
  
  local success, reference = pcall(regex.detectBibleReference, line)
  if not success or not reference then
    return nil
  end
  
  local parse_success, parsed = pcall(regex.parseBookChapterVerses, reference)
  if not parse_success or not parsed or not parsed.book then
    return nil
  end


  -- https://www.bible.com/bible/1/GEN.18.4-8.KJV
  local bible_url_success, bible_url = pcall(generate_url.buildYouVersionURL, parsed)
  if not bible_url_success or not bible_url then
    return nil
  end
  
  -- -- FIXED: Find the actual position of the reference in the line
  -- local ref_start, ref_end = line:find(vim.pesc(reference))
  -- if ref_start then
  --   state.set_reference_start_col(ref_start - 1)  -- 0-indexed
  --   state.set_reference_end_col(ref_end - 1)      -- 0-indexed
  -- end
  
  -- Build passage string
  local parts = {
    book = { parsed.book },
    bible_url = bible_url,
    display_text = M.get_book(parsed.book),
  }
  
  if parsed.chapter then
    table.insert(parts.book, tostring(parsed.chapter))
  end
  
  if parsed.verseSection and type(parsed.verseSection) == "string" then
    local verses = parsed.verseSection:gsub("%s+", "")
    if verses ~= "" then
      parts.book[#parts.book] = parts.book[#parts.book] .. ":" .. verses
    end
  -- pl.dump(parts)
  end
  parts.book = table.concat(parts.book, " ")
  
  return parts -- table.concat(parts, " ")
end

M.parse_book_chapter_verses = function(biblePassage)
  return regex.parseBookChapterVerses(biblePassage)
end

M.get_book = function(book_name)
  return book_lookup.getBook(book_name)
end

M.get_bible_passage_text = function(biblePassageURL, version)
  -- TODO: append version to url
  print(biblePassageURL)
  if version then
    biblePassageURL = biblePassageURL .. "." .. version
  end
  -- Get html_page from url
  local html_success, html_page = pcall(get_page.fetch_url, biblePassageURL)
  if not html_success or not html_page then
    return nil
  end

  -- TODO: extract verse from html page
  local raw_json, extract_err = extract_data.extract_verse(html_page)
  if not raw_json then
    return nil, "Error extracting data: " .. extract_err
  end
  
  local verse_data, parse_err = extract_data.parse_json(raw_json)
  if not verse_data then
    return nil, "Error parsing JSON: " .. parse_err
  end

  return verse_data.verses
end

-- NEW: Parse trigger text (text after @)
M.parse_trigger_text = function(trigger_text)
  if not trigger_text or trigger_text == "" then
    return nil
  end
  
  -- Try to parse as a Bible reference
  local success, reference = pcall(regex.detectBibleReference, trigger_text)
  if not success or not reference then
    -- If it doesn't match a full reference, try to parse it as a partial book name
    return M.parse_partial_reference(trigger_text)
  end
  
  -- Use existing parsing logic
  local parse_success, parsed = pcall(regex.parseBookChapterVerses, reference)
  if not parse_success or not parsed or not parsed.book then
    return M.parse_partial_reference(trigger_text)
  end
  
  local bible_url_success, bible_url = pcall(generate_url.buildYouVersionURL, parsed)
  if not bible_url_success or not bible_url then
    return nil
  end
  
  local parts = {
    book = parsed.book,
    bible_url = bible_url,
    display_text = parsed.book
  }
  
  if parsed.chapter then
    table.insert(parts, tostring(parsed.chapter))
  end
  
  if parsed.verseSection and type(parsed.verseSection) == "string" then
    local verses = parsed.verseSection:gsub("%s+", "")
    if verses ~= "" then
      parts.book = parts.book .. ":" .. verses
    end
  end
  
  return parts
end

-- NEW: Handle partial references (like just "john" or "1cor")
M.parse_partial_reference = function(partial_text)
  if not partial_text or partial_text == "" then
    return nil
  end
  
  -- Try to match it as a book name or abbreviation
  local book_success, book = pcall(book_lookup.getBook, partial_text)
  if not book_success or not book then
    return nil
  end
  
  -- Create a default reference (e.g., John 1:1)
  local default_parsed = {
    book = book,
    chapter = 1,
    verseSection = "1"
  }
  
  local bible_url_success, bible_url = pcall(generate_url.buildYouVersionURL, default_parsed)
  if not bible_url_success or not bible_url then
    return nil
  end
  
  return {
    book = book,
    bible_url = bible_url,
    display_text = book .. " 1:1"
  }
end

return M
