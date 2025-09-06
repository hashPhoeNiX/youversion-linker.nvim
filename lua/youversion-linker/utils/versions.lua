local M = {}

local bible_versions = {
  NIV = { enabled = true },
  ESV = { enabled = false },
  NASB = { enabled = false },
  KJV = { enabled = true },
  NKJV = { enabled = true },
  NLT = { enabled = true },
  CSB = { enabled = false },
  HCSB = { enabled = false },
  NET = { enabled = false },
  RSV = { enabled = false },
  NRSV = { enabled = false },
  MSG = { enabled = false },
  AMP = { enabled = true },
  TPT = { enabled = false },
  CEV = { enabled = false },
  GNT = { enabled = false },
}

M.get_bible_versions = function()
  return bible_versions
end

M.configure_versions = function(new_versions)
  if new_versions then
    bible_versions = vim.tbl_deep_extend("force", bible_versions, new_versions)
  end
end

return M
