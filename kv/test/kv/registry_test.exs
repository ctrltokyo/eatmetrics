defmodule KV.RegistryTest do
  use ExUnit.Case, async: true

  setup context do
    _ = start_supervised!({KV.Registry, name: context.test})
    %{registry: context.test}
  end

  test "spawns buckets", %{registry: registry} do
    assert KV.Registry.lookup(registry, "metrics") == :error

    KV.Registry.create(registry, "metrics")
    assert {:ok, bucket} = KV.Registry.lookup(registry, "metrics")

    KV.Bucket.put(bucket, "milk", 1)
    assert KV.Bucket.get(bucket, "milk") == 1
  end

  test "removes buckets on exit", %{registry: registry} do
    KV.Registry.create(registry, "metrics")
    {:ok, bucket} = KV.Registry.lookup(registry, "metrics")
    Agent.stop(bucket)
    _ = KV.Registry.create(registry, "force_synchronous")
    assert KV.Registry.lookup(registry, "metrics") == :error
  end

  test "removes bucket on crash", %{registry: registry} do
    KV.Registry.create(registry, "metrics")
    {:ok, bucket} = KV.Registry.lookup(registry, "metrics")

    # Stop the bucket with non-normal reason
    Agent.stop(bucket, :shutdown)
    _ = KV.Registry.create(registry, "force_synchronous")
    assert KV.Registry.lookup(registry, "metrics") == :error
  end

  test "bucket can crash at any time", %{registry: registry} do
    KV.Registry.create(registry, "shopping")
    {:ok, bucket} = KV.Registry.lookup(registry, "shopping")

    # Simulate a bucket crash by explicitly and synchronously shutting it down
    Agent.stop(bucket, :shutdown)

    # Now trying to call the dead process causes a :noproc exit
    catch_exit KV.Bucket.put(bucket, "milk", 3)
  end
end
