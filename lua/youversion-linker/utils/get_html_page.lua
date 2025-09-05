local ok, http = pcall(require, "socket.http")

if not ok then
  vim.notify("Missing 'luasocket' dependency! Please check the documentation for instructions to install.",
    vim.log.levels.ERROR)
  return nil
end

http.TIMEOUT = 10 --set timeout to 10 seconds

local function fetch_url(url)
  local data, code, headers, status = http.request(url)
  if not data or code ~= 200 then
    return nil, "Failed to fetch URL. HTTP code: " .. tostring(code) .. ", status: " .. tostring(status)
  end
  return data
end

return {
  fetch_url = fetch_url,
}
