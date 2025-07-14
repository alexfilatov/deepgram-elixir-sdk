defmodule Deepgram.MixProject do
  use Mix.Project

  @version "0.1.0"
  @description "Elixir SDK for Deepgram's speech-to-text, text-to-speech, text intelligence, and AI voice agent services"
  @source_url "https://github.com/alexfilatov/deepgram-elixir-sdk"
  @homepage_url "https://www.deepgram.com"

  def project do
    [
      app: :deepgram,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: @description,
      package: package(),
      source_url: @source_url,
      homepage_url: @homepage_url,
      name: "Deepgram",
      docs: docs(),
      aliases: aliases()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :crypto]
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 2.0"},
      {:jason, "~> 1.4"},
      {:websockex, "~> 0.4"},
      {:ex_doc, "~> 0.30", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:mox, "~> 1.0", only: :test}
    ]
  end

  defp package do
    [
      maintainers: ["Alex Filatov", "Contributors"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Deepgram API Docs" => "https://developers.deepgram.com/",
        "Deepgram" => @homepage_url
      },
      files: [
        "lib",
        "mix.exs",
        "README.md",
        "LICENSE",
        "CHANGELOG.md"
      ],
      exclude_patterns: [
        "priv/tmp",
        "priv/static"
      ]
    ]
  end

  defp docs do
    [
      main: "Deepgram",
      source_ref: "v#{@version}",
      canonical: "http://hexdocs.pm/deepgram",
      extras: [
        "README.md",
        "CHANGELOG.md"
      ],
      groups_for_extras: [
        Introduction: ~r/README/,
        Guides: ~r/guides/
      ],
      groups_for_modules: [
        Core: [Deepgram, Deepgram.Client, Deepgram.Config],
        Services: [
          Deepgram.Listen,
          Deepgram.Speak,
          Deepgram.Read,
          Deepgram.Agent,
          Deepgram.Manage
        ],
        Types: [
          Deepgram.Types.Listen,
          Deepgram.Types.Speak,
          Deepgram.Types.Read,
          Deepgram.Types.Agent,
          Deepgram.Types.Manage
        ],
        Errors: [Deepgram.Error],
        WebSocket: [Deepgram.Listen.WebSocket, Deepgram.Speak.WebSocket, Deepgram.Agent.WebSocket]
      ]
    ]
  end

  defp aliases do
    [
      lint: ["format", "credo --strict"],
      test_all: ["test", "dialyzer"],
      docs: ["docs", &copy_assets/1]
    ]
  end

  # Copy assets for documentation
  defp copy_assets(_) do
    File.mkdir_p!("doc/assets")
    # Add any assets copy operations here if needed
    :ok
  end
end
