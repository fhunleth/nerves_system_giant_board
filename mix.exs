defmodule NervesSystemGiantBoard.MixProject do
  use Mix.Project

  @github_organization "verypossible"
  @app :nerves_system_giant_board
  @version Path.join(__DIR__, "VERSION")
           |> File.read!()
           |> String.trim()

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.6",
      compilers: Mix.compilers() ++ [:nerves_package],
      nerves_package: nerves_package(),
      description: description(),
      package: package(),
      deps: deps(),
      aliases: [loadconfig: [&bootstrap/1]],
      docs: [extras: ["README.md"], main: "readme"]
    ]
  end

  def application do
    []
  end

  defp bootstrap(args) do
    set_target()
    Application.start(:nerves_bootstrap)
    Mix.Task.run("loadconfig", args)
  end

  defp nerves_package do
    [
      type: :system,
      artifact_sites: [
        {:github_releases, "#{@github_organization}/#{@app}"}
      ],
      platform: Nerves.System.BR,
      platform_config: [
        defconfig: "nerves_defconfig"
      ],
      # The :env key is an optional experimental feature for adding environment
      # variables to the crosscompile environment. These are intended for
      # llvm-based tooling that may need more precise processor information.
      env: [
        {"TARGET_ARCH", "arm"},
        {"TARGET_CPU", "cortex_a5"},
        {"TARGET_OS", "linux"},
        {"TARGET_ABI", "gnueabihf"}
      ],
      checksum: package_files()
    ]
  end

  defp deps do
    [
      {:nerves, "~> 1.5.4 or ~> 1.6.0 or ~> 1.7.4", runtime: false},
      {:nerves_system_br, "1.14.4", runtime: false},
      {:nerves_toolchain_armv7_nerves_linux_gnueabihf, "~> 1.4.0", runtime: false},
      {:nerves_system_linter, "~> 0.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.22", only: [:dev, :test], runtime: false}
    ]
  end

  defp description do
    """
    Nerves System - Giant Board (ATSAMA5D2)
    """
  end

  defp package do
    [
      files: package_files(),
      licenses: ["Apache 2.0"],
      links: %{"Github" => "https://github.com/#{@github_organization}/#{@app}"}
    ]
  end

  defp package_files do
    [
      "fwup_include",
      "linux",
      "package",
      "patches",
      "rootfs_overlay",
      "uboot",
      "CHANGELOG.md",
      "Config.in",
      "external.mk",
      "fwup-revert.conf",
      "fwup.conf",
      "LICENSE",
      "mix.exs",
      "nerves_defconfig",
      "post-build.sh",
      "post-createfs.sh",
      "README.md",
      "VERSION"
    ]
  end

  defp set_target() do
    if function_exported?(Mix, :target, 1) do
      apply(Mix, :target, [:target])
    else
      System.put_env("MIX_TARGET", "target")
    end
  end
end
