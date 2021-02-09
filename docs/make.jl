Pkg.activate("./docs")

using Documenter, DeviationsLH, FilesLH

makedocs(
    modules = [DeviationsLH],
    format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
    checkdocs = :exports,
    sitename = "DeviationsLH",
    pages = Any["index.md"]
)

pkgDir = rstrip(normpath(@__DIR__, ".."), '/');
@assert endswith(pkgDir, "DeviationsLH")
deploy_docs(pkgDir);

Pkg.activate(".")

# ------------