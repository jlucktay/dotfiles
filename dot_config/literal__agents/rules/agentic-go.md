# Agentic engineering of Go code

## Mock-able interfaces for clients of 3rd-party APIs

When dealing with a 3rd-party API and requesting basic CRUD operations thereof, use the following patterns.

For the sake of this example, we will be defining an interface for a few operations and verbs to run against the Google Cloud Compute API.

These two interfaces cover the 'list' verb for Compute instances:

```go
// ComputeInstanceLister substitutes our own iterator return type as another interface so that we can control and implement it as necessary for live use as well as testing.
type ComputeInstanceLister interface {
  List(ctx context.Context, req *computepb.ListInstancesRequest, opts ...gax.CallOption) ComputeInstanceIterator
}

// ComputeInstanceIterator is the necessary interface that allows for testability of the iterator returned by Google Cloud Compute's List() func.
type ComputeInstanceIterator interface {
  Next() (*computepb.Instance, error)
}
```

These three interfaces cover the 'create' and 'delete' verbs for Compute instances:

```go
type ComputeInstanceCreator interface {
  Insert(ctx context.Context, req *computepb.InsertInstanceRequest, opts ...gax.CallOption) (ComputeOperation, error)
}

type ComputeInstanceDeleter interface {
  Delete(ctx context.Context, req *computepb.DeleteInstanceRequest, opts ...gax.CallOption) (ComputeOperation, error)
}

type ComputeOperation interface {
  Name() string
}
```

This last interface covers the 'close' verb for the client itself:

```go
type Closer interface {
  Close() error
}
```

Collect the sub-interfaces together into a single interface:

```go
type ComputeClient interface {
  ComputeInstanceLister
  ComputeInstanceCreator
  ComputeInstanceDeleter
  Closer
}
```

Include a compiler directive for tooling to generate a mock for the client:

```go
//go:generate go tool minimock -g -i ComputeClient -o ./mock/ -s _mock.go
```

This compiler directive to call the `minimock` tool has a corresponding `tool` directive in the appropriate `go.mod` file:

```go
tool github.com/gojuno/minimock/v3/cmd/minimock
```

Finally, define a client creation function:

```go
type ComputeClientCreator func(ctx context.Context, opts ...option.ClientOption) (ComputeClient, error)
```

The client creation `func` can be used in production code, accepting real client implementations with thin wrappers around real 3rd-party API clients and libraries.

This approach also provides hooks for tests to pass in their own mocked clients created through `minimock`.
