defmodule Revenant.IPCheck do
  require Logger

  def check(ip, server) do
    case check_ip_permissions(ip, server.ip_permissions) do
      true ->
        country_code = geoip_country(ip)
        case check_country_permissions(country_code, server.country_permissions) do
           true ->
             Logger.info("Login from country: #{country_code}")
             :ok
           false ->
             Logger.info("Login from country: #{country_code} banned")
             {:error, "Login from country: #{country_code} banned"}
        end
      false ->
        {:error, "Login from IP banned"}
    end
  end

  defp geoip_country(ip) do
    case GeoIP.lookup(ip) do
      {:ok, resp} ->
        resp.country_code
      {:error, _error} ->
        "XX"
    end
  end

  defp check_ip_permissions(ip, ip_permissions = %{whitelist_enabled: true}) do
    Enum.all?(ip_permissions.blacklist, fn(perm) ->
      {blacklist_ip, maskbits} = convert_ip_and_mask(perm)
      mask_address(ip, maskbits) != blacklist_ip end)
    &&
    Enum.any?(ip_permissions.whitelist, fn(perm) ->
      {whitelist_ip, maskbits} = convert_ip_and_mask(perm)
      mask_address(ip, maskbits) == whitelist_ip end)
  end

  defp check_ip_permissions(ip, ip_permissions = %{whitelist_enabled: false}) do
    Enum.all?(ip_permissions.blacklist, fn(perm) ->
      {blacklist_ip, maskbits} = convert_ip_and_mask(perm)
      mask_address(ip, maskbits) != blacklist_ip end)
  end

  defp check_country_permissions(country, country_permissions = %{whitelist_enabled: true}) do
    !Enum.member?(country_permissions.blacklist, country) &&
    Enum.member?(country_permissions.whitelist, country)
  end

  defp check_country_permissions(country, country_permissions = %{whitelist_enabled: false}) do
    !Enum.member?(country_permissions.blacklist, country)
  end

  defp convert_ip_and_mask(string_ip) do
    [ip, mask] = String.split(string_ip, "/")
    {:ok, ip_address} = :inet.parse_address(to_charlist(ip))
    {ip_address, String.to_integer(mask)}
  end

  def mask_address({a,b,c,d}, maskbits) do
    b = <<a::8, b::8, c::8, d::8>>
    rest = 32 - maskbits
    <<subnet::size(maskbits), _host::size(rest)>> = b
    <<a::8, b::8, c::8, d::8>> = <<subnet::size(maskbits), 0::size(rest)>>
    {a,b,c,d}
  end
end
