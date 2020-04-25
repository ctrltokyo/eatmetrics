defmodule KVTest do
  use ExUnit.Case
  doctest KV

  test "supervisor should be started" do
    assert KV.Registry.create(KV.Registry, "shopping") == :ok
  end
end
