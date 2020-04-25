defmodule KVTest do
  use ExUnit.Case
  doctest KV

  test "supervisor should be started" do
    KV.Registry.create(KV.Registry, "metrics")
    assert KV.Registry.lookup(KV.Registry, "metrics") != :error
  end
end
