#=
How to use

```
$ julia --project=@. julia -e 'using Pkg; Pkg.instantiate()' # only once
$ julia --project=@. julia main.jl
```
=#

using IntegLACore: generate

objdir = "./obj/"

isdir(objdir) || mkpath(objdir)

generate(;
    name="axpy",
    group="blas",
    targets=[
        ("double", "void"),
        ("float", "void"),
        ("int32_t", "void"),
        ("int64_t", "void"),
    ],
    args=[("{target}", "{Val0}"), ("const {Vec}", "{Vec0}"), ("{Vec}", "{Vec1}")],
    operation="""
                  for( {INT} i = 0; i < {Vec0}.size; i++){
                      {Vec1}[i] += {Val0} * {Vec0};
                  }
    """,
    srcfile=open(joinpath(objdir, "axpy.c"), "a"),
    testfile=nothing,
    headerfile=open(joinpath(objdir, "blas.hpp"), "a")
)
