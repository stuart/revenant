defmodule Revenant.IPCheckTest do
  use ExUnit.Case

  test "checking with no permissions set should pass" do
    server = %{ip_permissions: %{blacklist: [], whitelist: [], whitelist_enabled: false},
               country_permissions: %{blacklist: [], whitelist: [], whitelist_enabled: false}}

    assert :ok = Revenant.IPCheck.check({123,34,45,67}, server)
  end

  test "checking with a blacklisted address" do
    server = %{ip_permissions: %{blacklist: ["123.34.45.67/32"], whitelist: [], whitelist_enabled: false},
               country_permissions: %{blacklist: [], whitelist: [], whitelist_enabled: false}}

    assert {:error, "Login from IP banned"} = Revenant.IPCheck.check({123,34,45,67}, server)
  end

  test "checking with a blacklisted address range" do
    server = %{ip_permissions: %{blacklist: ["123.34.32.0/24"], whitelist: [], whitelist_enabled: false},
               country_permissions: %{blacklist: [], whitelist: [], whitelist_enabled: false}}

    assert {:error, "Login from IP banned"} = Revenant.IPCheck.check({123,34,32,12}, server)
  end

  test "checking with a whitelisted address range" do
    server = %{ip_permissions: %{blacklist: [], whitelist: ["123.23.45.0/24"], whitelist_enabled: true},
               country_permissions: %{blacklist: [], whitelist: [], whitelist_enabled: false}}

    assert {:error, "Login from IP banned"} = Revenant.IPCheck.check({123,34,45,67}, server)
    assert :ok = Revenant.IPCheck.check({123,23,45,3}, server)
  end

  test "checking with a whitelisted address" do
    server = %{ip_permissions: %{blacklist: [], whitelist: ["123.23.45.3/32"], whitelist_enabled: true},
               country_permissions: %{blacklist: [], whitelist: [], whitelist_enabled: false}}

    assert {:error, "Login from IP banned"} = Revenant.IPCheck.check({123,23,45,4}, server)
    assert :ok = Revenant.IPCheck.check({123,23,45,3}, server)
  end

  test "checking with a blacklisted country" do
    server = %{ip_permissions: %{blacklist: [], whitelist: [], whitelist_enabled: false},
               country_permissions: %{blacklist: ["US"], whitelist: [], whitelist_enabled: false}}

    assert {:error, "Login from country: US banned"} = Revenant.IPCheck.check({8,8,8,8}, server)
    assert :ok = Revenant.IPCheck.check({123,23,45,3}, server)
  end

  test "checking with a whitelisted country" do
    server = %{ip_permissions: %{blacklist: [], whitelist: [], whitelist_enabled: false},
               country_permissions: %{blacklist: [], whitelist: ["US"], whitelist_enabled: true}}

    assert :ok = Revenant.IPCheck.check({8,8,8,8}, server)
    assert {:error, "Login from country: VN banned"} = Revenant.IPCheck.check({123,23,45,3}, server)
  end
end
