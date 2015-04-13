defmodule Service do
  use Mix.Project

  def project do
    [app: :service,
     version: "1.5.0",
     language: :erlang,
     description: description,
     package: package,
     deps: deps]
  end

  defp deps do
    [{:cloudi_core, "~> 1.5.0"}]
  end

  defp description do
    "Erlang/Elixir Cloud Framework Service Behavior"
  end

  defp package do
    [files: ~w(src doc include rebar.config README.markdown),
     contributors: ["Michael Truog"],
     licenses: ["BSD"],
     links: %{"Website" => "http://cloudi.org",
              "GitHub" => "https://github.com/CloudI/service"}]
   end
end
