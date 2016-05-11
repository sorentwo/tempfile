# Tempfile

[![Build Status](https://travis-ci.org/sorentwo/tempfile.svg?branch=master)](https://travis-ci.org/sorentwo/tempfile)

`Tempfile` is a server specifically for managing temporary files. New random
file are created in a temporary location and are automatically cleaned up when
the requesting process exits.

Because tempfile creation is stateful, the `:tempfile` application must be
started in order to use the `Tempfile` module.

## Acknowledgements & Alternatives

This is almost entirely a port of [plug's][plug] `Plug.Upload` module. There are
some slight modifications around file naming, but the `GenServer` itself is
derived wholesale from `Plug`.

If you want a more robust alternative look at [briefly][briefly], which also
provides temporary file handling (but has a less discoverable name).

## Installation

The package can be installed from hex as `tempfile`:

1. Add tempfile to your list of dependencies in `mix.exs`:

      def deps do
        [{:tempfile, "~> 0.1.0"}]
      end

2. Ensure tempfile is started before your application:

      def application do
        [applications: [:tempfile]]
      end

## Usage

Create a new temporary file with a basename and extension:

```elixir
{:ok, path} = Tempfile.random("tempfile.txt")
File.write!(path, "I am a text file")
```

When the calling process exits the file will be removed automatically.

## License

MIT License, see [LICENSE.txt](LICENSE.txt) for details.

[plug]: https://hex.pm/packages/plug
[briefly]: https://hex.pm/packages/briefly
